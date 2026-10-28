# Session 2: Problem Identification & Feasibility Analysis

| Field | Details |
|---|---|
| **Course** | Software Development Project (SDP) |
| **Session** | 2 |
| **Topic** | Problem Identification & Feasibility Analysis |
| **Deliverable** | Problem Statement Document |
| **Industry Mapping** | Product Requirement Analysis |
| **Project Domain** | HealthCare |
| **Project Title** | Eunoia — Healthcare & Mental Wellness Platform |
| **GitHub Repository** | https://github.com/HarshBhardwaj00/Eunoia |

---

## Objective

To identify a genuine, real-world software problem in the selected domain, convert it
into a well-written problem statement, test the idea against **Technical** and
**Operational** feasibility, and define a clear project **scope** — exactly how product
teams prepare a "Product Requirement Analysis" before writing any code.

**Learning Outcomes:**
1. Learn methods to spot and select real-world software problems.
2. Write a professional problem statement (industry format).
3. Perform technical and operational feasibility analysis.
4. Define project scope and set clear boundaries (in-scope / out-of-scope).

---

## Part A: Identification of Real-World Software Problems

### Where does a good problem come from?

A real-world problem has at least one of these signals — a group of people who suffer a
repeated pain point that existing solutions fail to solve affordably or conveniently.

**Techniques used to identify our problem:**

| Technique | Description | Eunoia observation |
|---|---|---|
| Brainstorming | Freely list problems in the domain, then filter | Listed 12+ problems in healthcare & daily life |
| Domain research | Study existing apps (who they miss, what they charge) | Existing wellness apps are either too costly, generic, or data-heavy |
| Observation | Watch how people around us behave | Students use different apps for mood, sleep, journaling, and counselling — all disconnected |
| Problem-validation checklist | Is it frequent? Is it painful? Does app-solving fit? | Yes to all — daily tracking and instant support fit an app perfectly |

### Problems we considered (and why they were rejected / accepted)

| # | Candidate Problem | Verdict | Reason |
|---|---|---|---|
| 1 | Online doctor appointment booking | Rejected | Too many mature solutions; limited learning novelty |
| 2 | Pharmacy / medicine delivery | Rejected | Needs supply-chain Partners, full-time operations — out of student reach |
| 3 | **Disorganized mental wellness & health tracking** | **Selected ✅** | Students/employees track mood, sleep and stress on paper or in scattered apps; counselling access is slow, costly and stigmatized; one affordable connected platform is missing |

---

## Part B: Problem Statement Writing

### What makes a good problem statement?
Industry-standard check: the statement should be **specific, user-centered, evidence-based,
and scoped** — no solutions in it, only the problem.

### ✅ Final Problem Statement (Deliverable)

> **Problem Statement — Eunoia**
>
> Students and young working professionals today experience high levels of stress,
> anxiety and disrupted sleep, yet they lack a single, affordable and private space to
> manage their mental well-being. Existing solutions are fragmented: mood is tracked in
> one app, journaling in a notebook, meditation in another app, and professional counselling
> is expensive, slow to access and carried with social stigma. As a result, early signs of
> deteriorating mental health go unnoticed, individuals cannot see trends in their own
> state of mind, and help is reached only after problems become serious.
>
> There is a need for an accessible digital wellness platform that allows users to
> record and visualize daily mood and health indicators, practice guided self-care
> activities such as journaling, meditation and checklists, and connect with counsellors
> when self-help is not enough — all in one privacy-respecting application
> (**Eunoia** — "beautiful thinking").

**Pain points captured (→ later become requirements at Session 3):**
1. No single place for mood + sleep + stress tracking.
2. No visual trend of "how am I doing over the week."
3. Counselling is costly, slow, and stigmatized.
4. Self-care activities (meditation/journaling) are scattered across apps.
5. Privacy fear prevents honest self-recording.

---

## Part C: Technical and Operational Feasibility

A feasibility study answers one question early: *"Can we (technically) and should we
(operationally) build this?"*

### 1. Technical Feasibility — do we have the technology & skills?

| Aspect | Assessment | Status |
|---|---|---|
| App framework | Flutter (already in team's repo, cross-platform Android/iOS/Web from one codebase) | ✅ Feasible |
| Frontend | Flutter/Dart — team has learning curve but solid community docs | ✅ Feasible |
| Backend/Auth/Database | Firebase Authentication + Cloud Firestore (realtime NoSQL) | ✅ Feasible |
| Push notifications | Firebase Cloud Messaging | ✅ Feasible |
| Version control & CI | Git + GitHub (repo already setup in Session 1) | ✅ Feasible |
| Charts/analytics inside app | Ready-made Flutter chart packages | ✅ Feasible |
| Team skills | Programming fundamentals known; Flutter/Firebase to be learned in parallel — planned in sprint study time | ⚠️ Feasible with learning plan |

**Conclusion:** All required technology is free-tier friendly, well-documented, and the
team can acquire missing skills during the project. **Technically feasible.**

### 2. Operational Feasibility — will people actually use it & can we operate it?

| Aspect | Assessment |
|---|---|
| User demand | Stress/mental-wellness is a felt need among students; survey of peers shows willingness to try a free, private tracker ✅ |
| Ease of use | Simple daily 2–3 tap flow; no training needed ✅ |
| Cost to operate | Firebase free (Spark) tier covers development & pilot users; zero server bills ✅ |
| Sensitivity of data | Health data must be private — role-based access, no public sharing of records; mitigation planned ⚠️ |
| Counsellor side | Real professional counselling is out of students' operational power — scope handles this (see Part D) ⚠️ |
| Maintenance | Team can maintain through the course; codebase small and documented ✅ |

**Conclusion:** Operationally feasible **within the defined scope**, after consciously
excluding the heavy operational parts (real doctors, medical-grade advice, paid counselling).

### 3. (Context) Other classic feasibility dimensions briefly noted
- **Economic feasibility:** development cost ≈ ₹0 (free tools) — feasible.
- **Schedule feasibility:** MVP achievable within semester sprints — feasible.
- **Legal feasibility:** compliance = privacy-first design, clear data disclaimer — feasible.

---

## Part D: Project Scope Definition

### Scope statement
Eunoia will deliver a **cross-platform mobile app** where a user can: register securely,
log daily mood/sleep/stress, view personal trend charts, practice guided journaling and
meditation checklists, and — when they choose — connect for supportive conversations with
student volunteers/counsellors through an in-app booking (text sessions). An admin module
manages users and content.

### In-Scope (v1 / MVP)

| Feature | Description |
|---|---|
| Secure registration & login | Role-based access: User / Counsellor / Admin |
| Daily wellness log | Mood, sleep hours, stress level — 2–3 taps a day |
| Trend dashboard | Personal charts of the last week / month |
| Guided self-care | Journaling prompts, meditation timer, self-care checklists |
| Counsellor connect | Browse student counsellors, book a text-based session slot |
| Privacy control | Private logs, optional anonymous mode, data stays in user's account |
| Admin dashboard | Manage users, counsellors, and content |

### Out-of-Scope (explicitly excluded in v1)

| Excluded | Reason |
|---|---|
| Live video/audio therapy sessions | Real-time infra & licensed professionals needed — operational risk |
| Medical diagnosis or prescription advice | Legal & safety boundary; app only supports wellness |
| Wearables/sensor auto-sync (smartwatch data) | Nice-to-have; adds hardware scope in v1 |
| Multi-language support | English + Hindi later if time permits |
| Online payments | No paid bookings in v1 to avoid legal/financial complexity |

### Minimum Viable Product (MVP) definition
**Successful v1 =** a new user can register, record daily wellness for a week, see a
trend chart of their data, complete a journaling/meditation activity, and book one
counselling text session — without any data leak to other users.

---

## Deliverable — Problem Statement Document (Evidence Summary)

| Checklist item | Status |
|---|---|
| Real-world problem identified & justified (Part A) | ✅ |
| Professional problem statement written (Part B) | ✅ |
| Technical feasibility table completed (Part C) | ✅ |
| Operational feasibility table completed (Part C) | ✅ |
| MVP scope + explicit exclusions defined (Part D) | ✅ |
| Document added to repository `SDP-Sessions/` folder | ✅ *(added locally this session)* |

---

## Industry Mapping — Product Requirement Analysis

In the industry, this session's work is the first half of a **Product Requirement
Analysis** (also called PRD — Product Requirements Document, prepared by Product
Managers / Business Analysts):

| Our SDP practice | Industry equivalent |
|---|---|
| Problem identification | Market research / user research (pain-point discovery) |
| Problem statement | PRD "Problem & Opportunity" section |
| Feasibility study | Tech-feasibility spike by engineering + Business/ops review |
| Scope & MVP definition | PRD "Scope, Goals & Non-goals" + release planning |
| Pain-point list | Raw requirements fed into next session's SRS (Session 3) |

**Deliverable review:** ❌ No shortcuts — the exclusions list is as important as the
inclusions: it prevents **scope creep**, which product teams fight through the whole lifecycle.

---

## Conclusion

In Session 2 we selected one strong problem — fragmented, stigmatized, and
privacy-heavy mental wellness management — from a studied pool of problems in the
HealthCare domain, turned it into an industry-style problem statement for **Eunoia**,
proved that the problem is **technically feasible** (Flutter + Firebase free tier) and
**operationally feasible** within student constraints, and locked the MVP scope with
clear non-goals. The pain points listed here are now the input for the next session,
where they will be converted into formal functional requirements and an SRS.
