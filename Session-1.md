# Session 1: Introduction to Software Engineering Tools

| Field | Details |
|---|---|
| **Course** | Software Development Project (SDP) |
| **Session** | 1 |
| **Topic** | Introduction to Software Engineering Tools |
| **Deliverable** | GitHub Repository Setup |
| **Industry Mapping** | Collaborative Development |
| **Project Domain** | HealthCare |
| **Project Title** | Eunoia — Healthcare & Mental Wellness Platform |
| **GitHub Repository** | https://github.com/HarshBhardwaj00/Eunoia |

---

## Objective

To understand industry-standard software engineering tools and practices, take the first
step of the software project lifecycle by setting up a version-controlled GitHub repository,
and formally establish the team along with the selected project domain.

**Learning Outcomes:**
1. Understand what Git and GitHub are and how they differ.
2. Create a repository and apply version control basics (add, commit, push, pull).
3. Describe the software project lifecycle followed in the industry.
4. Form a team and select a project domain with justification.

---

## Part A: Introduction to Git and GitHub

### What is Git?
**Git** is a free, open-source **distributed version control system (DVCS)** created by
Linus Torvalds in 2005. It tracks changes to files (source code, documents, configs)
over time so that:

- Every change is recorded with **who, what, when, and why**.
- Any previous version can be restored at any time (**revert/rollback**).
- Multiple developers can work **in parallel** without overwriting each other.
- Work happens **offline**; the full history lives on every developer's machine.

**Key Git concepts:**

| Concept | Meaning |
|---|---|
| Repository (repo) | A project folder tracked by Git, containing full history in `.git/` |
| Commit | An immutable snapshot of the staged changes with a message |
| Staging area (index) | A draft area where changes are prepared before committing |
| Branch | An independent line of development (default: `main`) |
| HEAD | Pointer to the current commit/branch being worked on |
| Clone | A local copy of a remote repository with full history |
| Merge / Conflict | Combining branches; a conflict occurs when the same lines change on both sides |

### What is GitHub?
**GitHub** is a **cloud-based hosting platform for Git repositories** that adds a
collaboration layer on top of Git. Git is the *tool*; GitHub is the *service*.

GitHub provides:
- Remote repository hosting and backup.
- **Pull Requests** — proposing, reviewing, and discussing code changes.
- **Issues** and **Projects** — bug tracking and kanban-style planning.
- **Actions** — CI/CD automation (build, test, deploy pipelines).
- Code review tools, branches protection, wikis, and team permissions.

**Git vs GitHub (summary):**

| Git | GitHub |
|---|---|
| Version control tool (CLI) | Cloud hosting + collaboration platform |
| Works offline | Online service (internet needed) |
| Installed locally | Web-based (+ GitHub Desktop/CLI) |
| Made by Linus Torvalds | Owned by Microsoft |
| No Git → no GitHub | GitHub without Git is meaningless |

---

## Part B: Repository Creation and Version Control Basics

### Step 1 — Configure Git identity (one time per machine)

```bash
git config --global user.name  "Your Name"
git config --global user.email "your-email@example.com"
git config --list
```

### Step 2 — Create a repository

**Option 1 (Remote-first):** Create an empty repository on GitHub
(*New repository → name → Public → no README*), then clone it:

```bash
git clone https://github.com/<username>/SDP-experiments.git
cd SDP-experiments
```

**Option 2 (Local-first — used in this session):**

```bash
git init
```

*Result observed:*
```
Initialized empty Git repository in D:/SDP-experiments/.git/
```

### Step 3 — Basic version control workflow

The daily workflow is a cycle: **edit → stage → commit → push**.

```bash
git status                 # see what changed
git add Session_1_Introduction_to_Software_Engineering_Tools.md   # stage a file
git add .                  # stage all changes
git commit -m "Session 1: add session record and init repository"   # save snapshot
git log --oneline          # view history
```

### Step 4 — Connect local repo to GitHub (remote)

```bash
git remote add origin https://github.com/<team-owner>/SDP-experiments.git
git push -u origin main    # first push, sets upstream
git pull                   # fetch + merge latest remote changes
```

### Useful commands used in this session

| Command | Purpose |
|---|---|
| `git init` | Create a new local repository |
| `git status` | Show working-tree status |
| `git add <file>` / `git add .` | Stage changes |
| `git commit -m "msg"` | Commit staged changes with message |
| `git log --oneline` | Compact commit history |
| `git remote add origin <url>` | Link a GitHub remote |
| `git push -u origin main` | Upload commits to GitHub |
| `git pull` | Download and merge remote changes |
| `git branch` / `git checkout -b` | List / create-switch branches |

**Deliverable status:** ✅ Repository initialized locally, connected to GitHub remote
(`https://github.com/HarshBhardwaj00/Eunoia`), and pushed.

---

## Part C: Software Project Lifecycle in Industry

Industry projects follow a structured lifecycle so that quality is planned in from
day one and risk is reduced early.

### Phases

1. **Requirement Analysis** — gather and document functional (what it does) and
   non-functional (performance, security, usability) requirements; SRS document.
2. **Planning & Feasibility** — scope, schedule, cost estimation, risk analysis,
   team allocation.
3. **Design (UI/UX + Architecture)** — system architecture, database schema, wireframes,
   tech-stack selection.
4. **Development / Implementation** — coding in sprints using Git feature branches.
5. **Testing** — unit → integration → system → user-acceptance testing (UAT).
6. **Deployment** — release to staging/production, possibly with CI/CD pipelines.
7. **Maintenance & Support** — bug fixes, updates, feature enhancement (longest phase).

### Industry Development Models

| Model | Approach | When used |
|---|---|---|
| **Waterfall** | Linear, phase-by-phase | Fixed, well-understood requirements |
| **Agile / Scrum** | Iterative sprints (1–4 weeks), daily stand-ups, retrospective | Changing requirements — industry default today |
| **DevOps** | Dev + Ops merged; continuous integration & delivery | Fast, reliable release cycles |

### Scrum vocabulary used in industry
`Product Backlog · Sprint Backlog · Sprint (1–4 weeks) · Daily Stand-up ·
Sprint Review · Retrospective · Product Owner · Scrum Master · Velocity`

---

## Part D: Team Formation and Project Domain Selection

### Selected Domain: HealthCare

**Project title:** *Eunoia — Healthcare & Mental Wellness Platform*
(Under the HealthCare domain; hosted at https://github.com/HarshBhardwaj00/Eunoia.
*"Eunoia" = beautiful thinking — a state of positive mental well-being, which the app
aims to build through guided wellness and health-tracking features.)

**Why HealthCare?**
1. **Real social impact** — improves patient access to doctors and reduces manual paperwork in clinics.
2. **Rich, learnable problem space** — involves scheduling, records, roles (patient/doctor/admin), and privacy.
3. **Industry relevance** — the health-tech sector (Telemedicine, EHR, e-pharmacy) is a fast-growing industry.
4. **Well-bounded scope for an academic SDP** — a working MVP (appointments + e-records) is achievable in one semester.

**Proposed core features (MVP):**
- User registration & login (role-based access: User / Counsellor / Admin).
- Daily mood & health tracking dashboard with visual insights.
- Guided wellness activities: meditation/journaling/self-care checklists.
- Counsellor connect: book appointments and maintain personal well-being records.
- Admin dashboard: manage content, users, and engagement reports.

### Team Formation

| Role | Member | Responsibility |
|---|---|---|
| Team Leader | Harsh Bhardwaj | Coordination & planning, backend development, Git/GitHub repository admin, reviews |
| Developer & Docs | Kritagya Jha | Frontend/UI development, testing, documentation & session records |

> **Note:** Both team members act as Git collaborators on the shared repository
> (https://github.com/HarshBhardwaj00/Eunoia), practicing peer code review
> through pull requests.

**Collaboration rules adopted (Industry Mapping):**
- One branch per feature: `feature/<short-name>`; never commit directly to `main`.
- Every change enters `main` only via a reviewed **Pull Request**.
- Commit messages follow the convention: `Task: short description` (e.g., `Session1: init repo`).
- `main` must always contain runnable code.

---

## Deliverable — GitHub Repository Setup (Evidence Summary)

| Checklist item | Status |
|---|---|
| Git installed and identity configured | ✅ |
| Local repository initialized (`git init`) | ✅ |
| Session 1 record file added and committed (`git add` + `git commit`) | ✅ |
| Remote added and first push performed (`git push -u origin main`) | ✅ |
| Team members (Harsh Bhardwaj, Kritagya Jha) added as collaborators | 🔲 *add both accounts on GitHub → Settings → Collaborators* |

---

## Conclusion

In this session we installed and understood Git, initialized a version-controlled
repository, learned the core version-control commands (`init/status/add/commit/push/pull`),
studied how the industry runs projects through the software lifecycle and Agile/Scrum,
formed our team, and selected the **HealthCare** domain for the SDP project
*Eunoia*. The repository (https://github.com/HarshBhardwaj00/Eunoia) is now the
single source of truth for the project — every
future session's deliverable will be added to it as a new versioned commit, practicing
collaborative development exactly as done in the industry.
