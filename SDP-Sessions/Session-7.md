# Session 7: UML — Sequence and Activity Diagram Modeling

| Field | Details |
|---|---|
| **Course** | Software Development Project (SDP) |
| **Session** | 7 |
| **Topic** | UML — Sequence and Activity Diagram Modeling |
| **Deliverable** | Sequence and Activity Diagram |
| **Industry Mapping** | Interaction and Workflow Modeling |
| **Project Domain** | HealthCare |
| **Project Title** | Eunoia — Healthcare & Mental Wellness Platform |
| **GitHub Repository** | https://github.com/HarshBhardwaj00/Eunoia |
| **Input from Sessions 5–6** | Use cases (UC-02, UC-03, UC-09, UC-11) + domain classes → interaction & workflow models |

---

## Objective

To design **interaction-level and workflow-level UML models** for Eunoia's critical
scenarios: **sequence diagrams** showing the exact message exchanges (time-ordered)
between UI, services and domain objects, and **activity diagrams** modeling business
workflows with decisions, parallel paths and swimlanes — closing the gap between the
class design (Session 6) and implementation.

**Learning Outcomes:**
1. Design sequence diagrams with lifelines, activations and message types.
2. Represent message flow precisely (sync/async, returns, `alt`/`opt`/`loop` fragments).
3. Model workflows using activity diagrams with decision nodes and swimlanes.

---

## Part A: Sequence Diagram Design

**Selection of critical flows (design decision):** the three highest-risk /
highest-value interactions, taken from Session 5's narratives and Session 6's classes

| Scenario | Source | Why modeled first |
|---|---|---|
| SD-01 Login & Role Resolution | UC-02 · FR-01..04 · `AuthService` | Gateway to every other flow |
| SD-02 Daily Wellness Log Save | UC-03 · FR-05..07 · `DailyLog` | Most used path; offline case is a real risk (NFR-04) |
| SD-03 Book Counselling Session | UC-09/10/11 · FR-14,17,18,19 · `Slot`, `Booking` | Concurrency (double-booking) + privacy consent — the highest-risk flow |

**Lifeline set derived from class diagram (no new objects invented):**
`EndUser ↔ EunoiaUI ↔ AuthService / Firestore ↔ Domain classes (DailyLog, Slot, Booking) ↔ NotificationService`.

---

## Part B: Message Flow Representation

**Notation duty-check (what messages we use and mean):**

| Symbol | Meaning | Where we used |
|---|---|---|
| solid arrow filled head `→` | **synchronous** call, waits for return | UI → domain/save calls |
| half/return arrow `-->` | reply/return value | validation results, data loads |
| open-head arrow `→` (async in text) | **asynchronous** fire-and-forget | FCM reminder dispatch |
| `alt / else` fragment | branching | slot free vs taken; online vs offline |
| `opt` fragment | optional block | consent summary selection |
| `loop` fragment | repetition | slot list re-render |
| activation bar | object is executing | save in progress |

### SD-01 — Login & Role Resolution

```mermaid
sequenceDiagram
    autonumber
    actor U as EndUser
    participant UI as EunoiaUI
    participant Auth as AuthService
    participant FB as Firestore
    participant NS as NotificationService

    U->>UI: open app
    UI->>Auth: login(email, password)
    activate Auth
    Auth->>FB: query credentials (TLS)
    alt credentials valid & email verified
        FB-->>Auth: user doc {uid, role}
        Auth-->>UI: session(role) ✔
        deactivate Auth
        alt role == "EndUser"
            UI->>UI: render dashboard (home)
        else role == "Counsellor"
            UI->>UI: render slot management
        else role == "Admin"
            UI->>UI: render moderation queue
        end
        UI->>NS: scheduleDailyReminder(uid)   [async]
        NS-->>U: (later) 1 gentle reminder/day  [FR-23]
    else invalid or unverified
        FB-->>Auth: reject
        Auth-->>UI: error(msg) ✖   [FR-04 reset offered]
        deactivate Auth
    end
```

### SD-02 — Daily Wellness Log Save (with offline branch)

```mermaid
sequenceDiagram
    autonumber
    actor U as EndUser
    participant UI as EunoiaUI
    participant DL as DailyLog
    participant FS as Firestore

    U->>UI: complete check-in (mood, sleep, stress)
    activate UI
    UI->>DL: validate(entry)
    DL-->>UI: valid ✔   [FR-05 ranges enforced]
    UI->>DL: save()
    activate DL
    alt online
        DL->>FS: txn upsert today's entry {uid, date}
        FS-->>DL: committed ✔
        DL-->>UI: saved → streak++  [same-day = update FR-07]
    else offline
        DL->>DL: queue in local cache
        UI-->>U: "Saved offline, syncing soon"
        loop when connectivity returns
            DL->>FS: flush queue
            FS-->>DL: ack ✔  [NFR-04 graceful recovery]
        end
    end
    deactivate DL
    deactivate UI
```

### SD-03 — Book Counselling Session (double-booking & consent guarded)

```mermaid
sequenceDiagram
    autonumber
    actor U as EndUser
    participant UI as EunoiaUI
    participant SL as Slot
    participant B as Booking
    participant C as Counsellor
    participant FS as Firestore

    U->>UI: pick counsellor + slot
    UI->>SL: isAvailable()
    alt slot available
        opt user chooses what to share  [FR-14]
            U->>B: setShareSummary(none | brief | full)
        end
        UI->>B: confirm(consent)
        activate B
        B->>FS: begin transaction
        B->>B: cap check via Counsellor.guardCap(today)  [FR-19]
        alt cap OK & slot still free
            FS-->>B: txn: mark slot booked + create booking
            B-->>UI: confirmed(dt) ✔
            UI-->>U: show confirmation
            B->>FS: create Conversation(shareSummary)
        else slot taken concurrently  [A1 race]
            FS-->>B: conflict ✖
            B-->>UI: "slot just got booked"
            loop refresh
                UI-->>U: updated slot list
            end
        else cap exceeded
            B-->>UI: blocked(2/day cap message)
        end
        deactivate B
    else unavailable
        SL-->>UI: false ✖
    end
```

*(Same message-flow notation applied; remaining UCs get modeled exactly like this in
design-review sessions — kept compact here.)*

---

## Part C: Workflow Modeling — Activity Diagrams

### AD-01 — End-to-end booking workflow (swimlanes)

```mermaid
flowchart TD
    subgraph EndUser
    A[start: open Find Counsellor] --> B{logged in?}
    B -->|no| C[login / register]
    B -->|yes| D[browse counsellors]
    D --> E{slot chosen & free?}
    E -->|no| D
    E -->|yes| F{share summary choice?}
    F -->|skip| G[consent = none]
    F -->|select| H[save consent level]
    end
    subgraph System
    G --> I[txn: reserve slot FR-17]
    H --> I
    I --> J{cap OK? FR-19}
    J -->|yes| K[create Booking + Conversation]
    J -->|no| L[block & message]
    K --> M[notify both parties]
    L --> D
    end
    subgraph Counsellor_side
    M --> N[start text session at slot time]
    N --> O{sharing consent exists?}
    O -->|no| P[session notes, booking closed]
    O -->|yes| Q[view only consented summary]
    Q --> P
    end
    P --> R([end])
```

### AD-02 — Daily check-in workflow (decision + action flow)

```mermaid
flowchart TD
    S([start]) --> T[app opened or reminder received]
    T --> U{already logged today?}
    U -->|yes| V[open charts]
    U -->|no| W[show logger: mood / sleep / stress]
    W --> X{inputs valid? FR-05}
    X -->|no| X2[inline errors] --> W
    X -->|yes| Y{online?}
    Y -->|yes| Z1[save + streak update]
    Y -->|no| Z2[cache offline] --> Z1
    Z1 --> AA{weekly trend ready?}
    AA -->|7+ days| AB[show trend insight]
    AA -->|< 7 days| AC[encourage continuation]
    AB --> AD([end])
    AC --> AD
    V --> AD
```

**Workflow coverage check:** both activity diagrams contain decision nodes (`{}`),
rework loops (invalid input → back to logger), parallel/alternative paths (online vs
offline), and swimlane-style responsibility separation — complete workflow notation.

---

## Deliverable — Sequence and Activity Diagram (Evidence Summary)

| Checklist item | Status |
|---|---|
| 3 critical scenarios selected & justified (Part A) | ✅ |
| 3 sequence diagrams with lifelines, activations, sync/async/return messages (Part B) | ✅ |
| `alt` / `opt` / `loop` fragments used & explained (Part B) | ✅ |
| 2 activity diagrams with decisions, loops & swimlanes (Part C) | ✅ |
| Traceability UC-xx / FR-xx maintained on every diagram | ✅ |
| Deliverable added to repository `SDP-Sessions/` folder | ✅ *(added locally this session)* |

---

## Industry Mapping — Interaction and Workflow Modeling

| Our SDP practice | Industry equivalent |
|---|---|
| Sequence diagrams for riskiest flows | Design reviews where backend/QA finalize API contracts |
| `alt` on slot race | Concurrency handling spec the coder implements as transactions |
| Activity diagram with swimlanes | BPMN-style workflow docs handed to both dev and support teams |
| Offline branch modeling | PWA/mobile sync design pattern discussions |
| Diagram-as-code in repo | Living documentation — same PR that changes code changes the design doc |
| Traceability UC/FR ← diagram | RTM extended to interaction level; QA derives test steps from alt-flows |

**Business reality:** in code review, the argument "bro isne race ka case dekha?" dies
instantly when SD-03 already contains the `alt slot taken` branch — these diagrams are
the reason cross-team miscommunication rarely survives past design review.

---

## Conclusion

Session 7 models Eunoia's dynamics: three fully detailed sequence diagrams (login +
role routing, resilient daily log with offline sync, and the concurrency- and
consent-guarded booking flow) using correct message-flow notation, plus two activity
diagrams with decisions and swimlanes covering the booking workflow and daily
check-in workflow. Requirements (FR), use cases (UC) and classes are now connected
through interactions — with modeling complete, the next session's
**system architecture & database schema design** can be drawn directly from these.
