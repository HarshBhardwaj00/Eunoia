# Session 4: SRS Documentation

| Field | Details |
|---|---|
| **Course** | Software Development Project (SDP) |
| **Session** | 4 |
| **Topic** | Software Requirement Specification (SRS) |
| **Standard** | IEEE 830 / ISO-IECIEEE 29148 style formatting |
| **Tools** | Google Docs / MS Word / Overleaf *(this record maintained in Markdown, converted copy kept on Docs)* |
| **Deliverable** | Complete SRS Document |
| **Industry Mapping** | Formal Documentation Standards |
| **Project Domain** | HealthCare |
| **Project Title** | Eunoia — Healthcare & Mental Wellness Platform |
| **GitHub Repository** | https://github.com/HarshBhardwaj00/Eunoia |
| **Input from Session 3** | 13 elicited user stories + NFRs → formalized below |

---

## Objective

To convert the elicited requirements of Session 3 into a **formal, standards-compliant
Software Requirement Specification (SRS)** following the **IEEE SRS structure**
(Introduction → Overall Description → Functional Requirements → Non-Functional
Requirements) — the single authoritative reference for design, build and testing.

**Learning Outcomes:**
1. Understand the purpose and structure of an SRS.
2. Write requirements that are unambiguous, verifiable and numbered.
3. Follow IEEE format professionally (industry documentation standard).

---

## 📄 SOFTWARE REQUIREMENT SPECIFICATION (SRS)
### Eunoia — Healthcare & Mental Wellness Platform
*Version 1.0 — prepared by Team Eunoia (Harsh Bhardwaj, Kritagya Jha)*

---

### 1. Introduction

#### 1.1 Purpose
This document specifies the complete functional and non-functional requirements of
**Eunoia**, a cross-platform mental-wellness application. It is intended for the
development team, testers, evaluators (academic stakeholders) and any future
maintainers. It replaces informal notes from Sessions 2–3 and becomes the
**contract-style** baseline of v1 scope.

#### 1.2 Scope
Eunoia is a mobile-first application allowing users to: register securely, log daily
mood/sleep/stress in under a minute, visualize trends, practice guided journaling and
meditation, and optionally book free text sessions with student counsellors. An admin
subsystem moderates the platform. Distributed-tracking wearables sync, video therapy,
medical advice and payments are **out of scope for v1** (see Session 2 Exclusions).

#### 1.3 Definitions, Acronyms & Abbreviations

| Term | Meaning |
|---|---|
| SRS | Software Requirement Specification |
| FR / NFR | Functional / Non-Functional Requirement |
| MVP | Minimum Viable Product |
| MoSCoW | Must / Should / Could / Won't prioritization |
| Firestore | Cloud Firestore, NoSQL document database (Firebase) |
| RBAC | Role-Based Access Control (User / Counsellor / Admin) |
| AC | Acceptance Criteria |
| UAT | User Acceptance Testing |

#### 1.4 References
1. IEEE Std 830-1998, *Recommended Practice for Software Requirements Specifications*.
2. Session 2 problem statement & feasibility analysis (SDP-Sessions/Session-2.md).
3. Session 3 requirement gathering report (SDP-Sessions/Session-3.md).
4. Firebase official documentation (Auth, Firestore, FCM).

#### 1.5 Overview
Section 2 gives the overall product context; Section 3 details every functional
requirement; Section 4 lists non-functional requirements; Section 5 notes
assumption/dependency changes and approval.

---

### 2. Overall Description

#### 2.1 Product Perspective
Eunoia is a **new, self-contained mobile application** built on:
- **Frontend:** Flutter (Android-first, Web-ready single codebase — existing repo).
- **Backend services:** Firebase Authentication, Cloud Firestore, Firebase Cloud Messaging.
- **Hosting/VC:** GitHub (version control established in Session 1).

The product fills a documented gap (Session 2/3): fragmented, costly, and
privacy-weak wellness apps.

#### 2.2 Product Functions (high level)
1. Secure registration/login (RBAC: User, Counsellor, Admin).
2. Ultra-fast daily wellness logging (mood, sleep hours, stress level).
3. Personal trend visualization (weekly/monthly charts).
4. Guided self-care: journaling prompts + meditation timer + checklists.
5. Optional anonymous mode.
6. Counsellor slot publishing + booking + consent-based summary sharing.
7. Admin moderation dashboard + anonymized usage analytics.
8. Daily gentle reminder notifications.

#### 2.3 User Characteristics & Classes

| User class | Technical literacy | Frequency of use | Expected training |
|---|---|---|---|
| End User (student/professional) | General smartphone user | Daily (logg) / weekly (charts) | None — task ≤ 1 min |
| Counsellor (student volunteer) | Moderate | Weekly (slot mgmt + sessions) | One walkthrough |
| Admin | High | Occasional moderation | Internal documentation |

#### 2.4 Constraints
- **Privacy:** all wellness logs are private to the user unless explicitly shared.
- **Platform:** Firebase free (Spark) tier limits; Android-first release.
- **Operational (students):** counsellors are volunteers → session cap enforced (US-09).
- **Legal/ethical:** no diagnosis/prescription; supportive, wellness-only stance.

#### 2.5 Assumptions & Dependencies
- Users own a smartphone with internet connectivity.
- Firebase services remain available under the free tier for the pilot.
- Counsellors are vetted by the college wellness cell (quality assumption).

---

### 3. Functional Requirements

*(Traced from Session 3 user stories — US-xx shown per requirement. Each FR is atomic,
unambiguous and verifiable.)*

#### 3.1 Authentication & Roles

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-01 | The system shall allow a user to register with a valid email and password (min 8 chars, 1 letter + 1 number). | US-01 | Test: weak passwords rejected; duplicate email rejected |
| FR-02 | The system shall verify email before enabling login. | US-01 | Test: unverified login blocked |
| FR-03 | The system shall authenticate users and assign exactly one role at session start: User, Counsellor, or Admin (RBAC). | US-01, US-10 | Test: role-specific screens render |
| FR-04 | The system shall allow password reset via registered email. | US-01 | Test: reset link flow works |

#### 3.2 Daily Wellness Logging

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-05 | The system shall enable recording of mood (5-level), sleep hours (0–14, step 0.5) and stress level (1–5) in a single screen. | US-02 | Test: complete in ≤ 1 min |
| FR-06 | The system shall timestamp and store every entry to the signed-in user's account only. | US-02 | Test: entry visible to owner, invisible to others |
| FR-07 | The system shall prevent modification of past entries (append-only log) while allowing a fresh entry for the same day as an update of that day's record. | US-02 | Test: history integrity preserved |

#### 3.3 Visualization

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-08 | The system shall display mood/stress/sleep trends for the last 7 days and the last 30 days. | US-03 | Test: charts render with ≥ 7 days data |
| FR-09 | The system shall restrict all visualizations to the authenticated user's own data. | US-03, US-05 | Test: user A sees no trace of user B |

#### 3.4 Self-Care Tools

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-10 | The system shall provide ≥ 5 journaling prompts; entries saved with date. | US-04 | Test: create/edit/list journal entries |
| FR-11 | The system shall provide a meditation timer with start/stop and session duration history. | US-04 | Test: timer logs durations |
| FR-12 | The system shall offer self-care checklists with progress state persisted. | US-04 | Test: state survives app restart |

#### 3.5 Privacy Features

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-13 | The system shall support an anonymous mode where the display name is neutral and activity is not attributed publicly. | US-05 | Test: identity not exposed in any shared surface |
| FR-14 | The system shall share with a counsellor, for a booked session, only that content the user explicitly consents to (default share = none). | US-08 | Test: default view shows "not shared" |
| FR-15 | The system shall allow users to export their own logs (CSV) when v1.1 ships. | US-13 (deferred) | — marked future |

#### 3.6 Counselling Subsystem

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-16 | The system shall allow counsellors to create, edit and delete availability slots (date/time text-session). | US-06 | Test: slot CRUD |
| FR-17 | The system shall prevent a slot from being booked twice. | US-06 | Test: parallel booking race rejected |
| FR-18 | The system shall allow users to book/cancel an available slot with a confirmation. | US-07 | Test: booking confirmation shown |
| FR-19 | The system shall warn a counsellor after the first booked session and block third booking/day. | US-09 | Test: cap behavior at 2/day |
| FR-20 | The system shall provide a text conversation surface inside booked sessions. | US-07 | Test: messages persist per session |

#### 3.7 Administration

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-21 | The system shall allow admins to approve or remove counsellor listings; actions are logged. | US-10 | Test: non-admin denied |
| FR-22 | The system shall show admins anonymized aggregates (DAU, log counts) with no individual entries. | US-11 | Test: no PII in dashboard |

#### 3.8 Notifications

| Req. ID | Requirement | Source | Verification |
|---|---|---|---|
| FR-23 | The system shall send at most one daily reminder if a check-in is missed; user can disable it. | US-12 | Test: toggle honored |

---

### 4. Non-Functional Requirements

| Req. ID | Category | Requirement (IEEE) | Verification |
|---|---|---|---|
| NFR-01 | **Security/Privacy** | All wellness data encrypted in transit (TLS) and shielded by Firestore security rules; no user can read/write another user's documents. | Security test + rules unit tests |
| NFR-02 | **Performance** | Daily log screen opens < 2 s on a mid-range Android; a log insert completes < 1 s. | Instrumented timing |
| NFR-03 | **Usability** | Daily check-in achievable in ≤ 3 taps / ≤ 1 min; first-use without any tutorial. | UAT with 5 novice users |
| NFR-04 | **Reliability** | App recovers gracefully from network loss; queued writes sync when online. | Offline/online switch test |
| NFR-05 | **Availability** | 99 % availability of backend for pilot users (Firebase SLA posture). | Monitoring |
| NFR-06 | **Maintainability** | Code passes linting; feature branches + PR review before merge (Session 1 rules). | CI checks |
| NFR-07 | **Portability** | Same codebase builds runnable debug APK for Android ≥ 8 and Flutter web build. | Build matrix |
| NFR-08 | **Scalability (local)** | Pilot scale = 100 users / 10 counsellors on the free tier without cost. | Load-spot check |
| NFR-09 | **Legal/Ethical** | No diagnosis or medical advice anywhere in UI text; a clear wellness disclaimer is shown on first launch. | Content review |
| NFR-10 | **Internationalization-readiness** | All UI strings externalized for later Hindi addition. | Code review |

---

### 5. Other Sections (IEEE completeness)

#### 5.1 External Interfaces
- **User interfaces:** onboarding → home dashboard; logger; charts; journaling; booking; admin (role-gated).
- **Hardware:** standard Android device (camera/mic not used in v1).
- **Software/Communication:** Firebase SDKs (HTTPS), FCM push.

#### 5.2 Data Requirements (key entities)
`users {uid, role, displayName, email, consentFlags}` ·
`daily_logs {uid, date, mood, sleepHours, stress}` · `journal {uid, date, promptId, body}` ·
`counsellors {uid, verified, dailyCap}` · `slots {counsellorUid, datetime, status}` ·
`bookings {slotId, userUid, shareSummary, conversation}` · `admin_actions {adminUid, action, target, at}`

#### 5.3 Approval & Sign-off

| Role | Name | Sign-off |
|---|---|---|
| Product Owner / BA | Harsh Bhardwaj | ✅ (this record) |
| Developer / Documentation | Kritagya Jha | ✅ (this record) |

---

## Deliverable — Complete SRS Document (Evidence Summary)

| Checklist item | Status |
|---|---|
| IEEE sections 1–5 written (Introduction, Overall Description, FRs, NFRs, extras) | ✅ |
| 23 FRs numbered + traceable to user stories (US-xx) | ✅ |
| 10 NFRs with verifiable criteria | ✅ |
| Data model & interfaces specified | ✅ |
| Tools noted (Google Docs copy + this authoritative Markdown in repo) | ✅ |
| SRS added to repository `SDP-Sessions/` folder | ✅ *(added locally this session)* |

---

## Industry Mapping — Formal Documentation Standards

| Our SDP practice | Industry equivalent |
|---|---|
| IEEE-style SRS v1.0 | Formal requirement baselines (IEEE 830 / ISO-IEC-IEEE 29148) |
| Numbered, verifiable FRs | Testable requirement entries reviewed by QA before a line is coded |
| Traceability (US → FR) | Requirements Traceability Matrix living inside the PRD/SRS |
| Version 1.0 + sign-off | Baseline freeze under change control (future changes = change request/CR) |
| Docs copy + repo source | Docs-as-code: source of truth in Git, exportable to Word/PDF |

**Why standards matter (business reality):** an SRS converts "kuch accha sa wellness app
banana hai" into a **measurable contract** — testers derive test cases directly from
FR/NFR IDs, estimations become realistic, and scope disputes die with a document link.

---

## Conclusion

Session 4 formalized Eunoia's requirements into a complete **IEEE-structured SRS**:
23 traceable functional requirements, 10 verifiable non-functional requirements,
data model, interfaces, constraints and sign-off. The document is now the single
baseline for v1 — in the next session it will be translated into **design**
architecture, UI flows, and ER/database schema for implementation.
