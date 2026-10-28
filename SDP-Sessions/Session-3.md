# Session 3: Requirements Engineering — Elicitation

| Field | Details |
|---|---|
| **Course** | Software Development Project (SDP) |
| **Session** | 3 |
| **Topic** | Requirements Engineering — Elicitation |
| **Deliverable** | Requirement Gathering Report |
| **Industry Mapping** | Business Analysis and Client Interaction |
| **Project Domain** | HealthCare |
| **Project Title** | Eunoia — Healthcare & Mental Wellness Platform |
| **GitHub Repository** | https://github.com/HarshBhardwaj00/Eunoia |
| **Input from Session 2** | Problem statement + pain-point list → converted into requirements |

---

## Objective

To systematically **elicit (discover and collect)** requirements for Eunoia from the
right stakeholders using industry techniques — interviews, questionnaires and
personas — and to express them as **user stories**, exactly the way a Business Analyst
prepares for client interaction before requirements are formalized.

**Learning Outcomes:**
1. Identify all stakeholders and their interests in the project.
2. Apply requirement-gathering techniques (interview simulation, questionnaire, personas).
3. Write industry-style user stories with acceptance criteria.

---

## Part A: Stakeholder Identification

Stakeholder = anyone who affects, or is affected by, the system. Eunoia's stakeholder map:

| Stakeholder | Who they are | Interest / what they expect from Eunoia |
|---|---|---|
| **End User (Student / Young Professional)** | Primary users facing stress, irregular sleep, exam/work pressure | Fast, private, free way to track mood, get self-care tools, reach help |
| **Student Counsellor (Volunteer Mentor)** | Trained student volunteers / junior counsellors listing on the app | Manage availability, see only consented session bookings, avoid overload |
| **Admin (Team / Platform Operations)** | Team members who run the platform | Moderate users & content, view anonymized usage stats, keep platform safe |
| **Product Owner / Business Analyst** | Harsh Bhardwaj (Team Leader) | Owns scope, prioritizes requirements (PRD owner) |
| **Development Team** | Harsh Bhardwaj, Kritagya Jha | Clear, testable, prioritized requirements |
| **Indirect stakeholders** | Parents/family (trust in privacy), college wellness cell (referral partner), Firebase/Google (platform provider) | Data safety, easy adoption, platform stability |
| **Regulator / Society** | Privacy norms & mental-health ethics | Confidentiality of sensitive wellness data |

**Stakeholder–power/interest insight:** End users have high interest; counsellors and
admins have the power to make or break day-to-day operation → all three directly
interviewed/surveyed below.

---

## Part B: Requirement Gathering Techniques

### Technique 1 — Interview Simulation (with personas standing in for clients)

Since the "client" is a set of end users, simulated **interviews** were conducted
(2 sample transcripts, condensed).

**Interview 1 — Student (UG, heavy exam season):**
> **Q. How do you currently track your mood or stress?**
> A. Bas mood notes app mein, but scattered. Mostly I don't track.
> **Q. When do you actually feel you need help?**
> A. Sleep kharab hone lagta hai, deadlines pe panic — tab tak already 1-2 weeks late.
> **Q. What would make you actually use an app daily?**
> A. 1 minute ka kaam hona chahiye, visually motivating, sirf meri koi third party ko na dikhe.
>
> **Requirements surfaced:** ultra-fast daily logging (≤1 min), visual progress/trends, **privacy-first design**, early-warning signs.

**Interview 2 — Student Counsellor (volunteer):**
> **Q. How do you currently manage bookings?**
> A. WhatsApp messages — timing clash hota hai, kabhi kabhi double-book.
> **Q. What do you want to see about the user before a session?**
> A. Only what they *choose* to share — self-reported summary, full logs unke private rahen.
> **Q. Limits?**
> A. Max 2 sessions/day warn nahi ho to overload ho jata hai.
>
> **Requirements surfaced:** slot-based booking (no clashes), consent-based **partial** info sharing, daily session cap / workload guard.

*(Cross-team note: both interviews were role-played by team members, script + answers
documented — in a real company this would be with actual customers.)*

### Technique 2 — Questionnaire Design

Google-Forms style questionnaire circulated to target group (students & young
professionals). **Design rules used:** short funnel (easy→specific), mix of MCQ + Likert
scale + open-ended, no leading questions, anonymous submission.

**Sample questionnaire (sent to peers of both members):**

| # | Question | Type |
|---|---|---|
| Q1 | Do you feel stress/anxiety affecting sleep or focus? (Rarely / Sometimes / Often / Daily) | Single choice |
| Q2 | How do you currently cope? (journalling, music, friends, chat, no method, …) | Multi select |
| Q3 | How likely would you use a single app for mood + meditation + journaling? (Likert 1–5) | Likert |
| Q4 | What feature you'd use the most? (mood tracker / chart / journaling / meditation / counselling) | Single choice |
| Q5 | How comfortable are you typing honestly into an app? (1–5) | Likert |
| Q6 | Would you occasionally chat with a counsellor in the app? (Yes / Maybe / No) | Single choice |
| Q7 | What stops you using existing wellness apps? (cost, ads, complexity, privacy) | Multi select |
| Q8 | Any feature you wish an app like this had? (open text) | Open-ended |

**Synthesis of responses (simulated class data, n = 20+):**
- ~80% feel stress affecting sleep/focus at least sometimes (validates problem of Session 2).
- Most-used desired feature: **mood tracker + trend visualization**.
- Top blockers in existing apps: privacy (largest), cost second, complexity third.
- Counselling: majority "Maybe" → design to be **optional & low-pressure**.

### Technique 3 — User Persona Creation

**Persona 1 — "Aarav", 20, B.Tech 3rd-year (Primary User)**
- **Goals:** Stay calm in exam season; understand "kya cycle chal raha hai mera"; sleep better.
- **Frustrations:** Apps too heavy/costly; cannot trust them with honest logs; counselling feels taboo.
- **Behaviour:** Phone-heavy user, uses an app only if the daily task is < 1 minute.
- **Quote:** "Main vo app use karunga jo mujhe weekly picture de, par sirf mujhe."

**Persona 2 — "Meera", 22, Psychology honours, student counsellor (Counsellor User)**
- **Goals:** Help juniors efficiently; avoid schedule chaos; protect both sides' privacy.
- **Frustrations:** WhatsApp bookings clash; overload on bad days; gets asked personal questions by admins.
- **Quote:** "Slot system dedo aur user ki full diary mujhe mat dikha, bas client ke hone share ki hui summary."

**Persona 3 — "Platform Admin" (operation/ethos guardian)**
- **Goals:** Keep the platform respectful, safe, and dupe-light; get simple usage insights.
- **Needs:** Moderate counsellor list; ensure no one faces abuse; anonymized dashboards.

---

## Part C: User Story Writing

Format used (industry standard):
**As a** `<role>`, **I want** `<goal/action>` **so that** `<benefit>`.
Each story carries priority (MoSCoW: Must/Should/Could/Won't) and acceptance criteria (AC).

### User Stories — Eunoia v1

| ID | User Story | Priority | Acceptance Criteria (AC) |
|---|---|---|---|
| US-01 | As a **new user**, I want to **register securely with email/password** so that I can keep my data private. | Must | Registration via email OTP/verification; validation errors handled; password rules enforced |
| US-02 | As a **user**, I want to **log my mood, sleep hours, and stress with 2–3 taps daily** so that tracking takes less than a minute. | Must | Single-screen logger; saving under 30 s; remains in local + synced to user's Firestore account |
| US-03 | As a **user**, I want to **view my weekly/monthly trend charts**, so that I can see patterns in my well-being. | Must | Charts for ≥7 days; data only from user's own account; month view toggle |
| US-04 | As a **user**, I want **journaling prompts and a meditation timer** so that I can practise self-care inside the app. | Must | Minimum 5 prompts; timer with start/stop; entries saved with date |
| US-05 | As a **user**, I want an **anonymous mode**, so that sensitive entries feel safe even if I'm seen using the app. | Should | App opens neutral-named; entries shareable only on user's explicit consent |
| US-06 | As a **counsellor**, I want to **publish my availability slots** so that bookings don't overlap. | Must | Slot CRUD; slots prevent double-booking; visible only when active |
| US-07 | As a **user**, I want to **book a free text session with a counsellor** so that help is accessible without stigma. | Must | Book from available slots; booking confirmation; cancel allowed anytime |
| US-08 | As a **counsellor**, I want to **see only the summary the user opted to share** so that full private logs stay private. | Must | Consent flag per booking; default shares none; session view shows shared summary only |
| US-09 | As a **counsellor**, I want a **daily session cap warning** so that I am not overloaded. | Should | Warn at 1 session, block after 2/day with a clear message |
| US-10 | As an **admin**, I want to **approve/remove counsellor listings** so that only verified helpers appear. | Should | Admin role gates listing management; actions logged |
| US-11 | As an **admin**, I want an **anonymized usage dashboard** so that I can understand adoption without touching private data. | Could | Aggregates only (DAU, counts); no individual entry exposed |
| US-12 | As a **user**, I want **gentle reminders** so that I remember my daily check-in. | Should | Daily notification ≤ 1; can be disabled in settings |
| US-13 | As a **user**, I want to **export my data (CSV)** so that I always own my records. | Won't (v1) | Deferred by scope of Session 2 |

**Traceability snapshot:** Pain points (Session 2) → requirements (here):
- PP-1 "no single place" → US-02, US-04; PP-2 "trends" → US-03; PP-3 "counselling access/stigma" → US-06, US-07, US-08; PP-4 "scattered self-care" → US-04; PP-5 "privacy fear" → US-01, US-05, US-08.

**Non-functional requirements noted at elicitation** (to formalize in next session):
Privacy/security first, simple & fast UI (≤1 min log), responsive Android-first, low memory footprint, multilingual-ready.

---

## Deliverable — Requirement Gathering Report (Evidence Summary)

| Checklist item | Status |
|---|---|
| Stakeholder identification table (Part A) | ✅ |
| Interview simulation recorded with extracted requirements (Part B-1) | ✅ |
| Questionnaire designed (8 questions) + response synthesis (Part B-2) | ✅ |
| 3 user personas created (Part B-3) | ✅ |
| 13 user stories with MoSCoW priority and acceptance criteria (Part C) | ✅ |
| Traceability Session-2 pain points → stories maintained | ✅ |
| Report added to repository `SDP-Sessions/` folder | ✅ *(added locally this session)* |

---

## Industry Mapping — Business Analysis and Client Interaction

| Our SDP practice | Industry equivalent |
|---|---|
| Stakeholder map | Stakeholder analysis, RACI/Power-Interest grid (BA technique) |
| Interview simulation | User/Client interviews led by Business Analysts |
| Questionnaire | User surveys (Google Forms / Typeform pipelines) |
| User personas | Design personas (UX research teams) |
| User stories + AC in MoSCoW | Backlog items on Jira/Azure DevOps, ready for sprint planning |
| Traceability matrix | Requirements Traceability Matrix (RTM) used till testing |

**Client-interaction skills practiced:** active listening, funnel questioning,
no-leading-questions rule, capturing "why" (benefit) in every story, and getting
priorities (MoSCoW) agreed with the client — exactly what happens in a company's
**elicitation → PRD → backlog** flow.

---

## Conclusion

Session 3 completed the **elicitation** phase for Eunoia: stakeholders were mapped,
requirements were gathered through simulated interviews and a designed questionnaire,
insights were humanized into three personas, and everything was converted into 13
MoSCoW-prioritized, acceptance-criteria-backed user stories, with full traceability
to the Session 2 pain points. The next session will analyze, prioritize and formally
**specify** these elicited requirements (SRS-style documentation).
