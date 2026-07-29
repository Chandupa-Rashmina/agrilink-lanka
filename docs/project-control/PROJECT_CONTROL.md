# AgriLink Lanka Project Control

**Repository:** `/home/lordpakeer/development/agrilink-lanka`  
**Stable branch:** `agrilink-lanka-stable`  
**Working branch:** `setup/agrilink-lanka-foundation`  
**Workflow:** ChatGPT-guided manual implementation

---

## 1. Mandatory Session Header

Every AgriLink Lanka task must begin with these six items.

### Architecture
State which component is being built, what it connects to, and why it exists.

### Current Checkpoint
State the exact branch, latest verified artifact, completed phase, and unresolved blockers.

### One Practical Milestone
Choose one visible and testable outcome for the session. Do not combine several major goals.

### Verification
Define the commands, tests, HTTP response, UI result, or other evidence that proves the milestone works.

### Git Checkpoint
Review the Git diff and commit only after verification succeeds. Do not develop directly on the stable branch.

### Progress Record
Update completed work, current status, errors, recovery actions, and the next step before ending the session.

---

## 2. Current Architecture

```text
Flutter mobile/desktop ─┐
                        ├── Laravel REST API ─── PostgreSQL
Nuxt web frontend ──────┘          │
                                   └── Redis, queues and cache later

Docker Compose:
- PostgreSQL
- Redis
- Laravel development services
- Nuxt development services
- Mail and storage support later

GitHub Actions:
- automated checks
- tests
- builds
- deployment gates

Environments:
local → CI → staging → production
```

### Component responsibilities

- **Flutter:** native mobile and desktop client.
- **Nuxt:** browser frontend and administration interface.
- **Laravel:** API, authentication, validation, authorisation and business rules.
- **PostgreSQL:** authoritative relational data.
- **Redis:** queues, cache, throttling and temporary state when introduced.
- **Docker Compose:** repeatable local service environment.
- **Git:** change history and recovery.
- **GitHub:** remote repository, pull requests and CI/CD.
- **DevOps:** the process that makes development, testing, deployment, monitoring, backup and recovery repeatable.

---

## 3. Current Verified Checkpoint

**Snapshot time:** 2026-07-30 01:17 +05:30

### Repository

- Root: `/home/lordpakeer/development/agrilink-lanka`
- Remote: `https://github.com/Chandupa-Rashmina/agrilink-lanka.git`
- Current branch: `agrilink-lanka-stable`
- Commits: none
- Remote branches: none
- Current upstream display: `origin/main [gone]`
- Git identity:
  - Name: `Chandupa-Rashmina`
  - Email: `rashminaamarasinghe@gmail.com`

### Existing project files

```text
docs/environment/tool-installation.md
ops/scripts/verify-workstation.sh
```

### Workstation status

The verification script reports:

```text
PASS: workstation is ready for AgriLink Lanka.
```

Verified tooling includes:

- Debian 13
- Git and GitHub CLI
- Docker Engine, Compose and Buildx
- Node.js, npm, Corepack and pnpm
- PHP, Composer and required Laravel extensions
- Java, Android SDK and ADB
- Flutter and Dart

### Phase status

- Phase 0 — Architecture approval: substantially complete
- Phase 1 — Debian and repository audit: complete for the new empty repository
- Phase 2 — Safe tool installation: complete
- Phase 3 — Git safety and branches: in progress
- Phase 4 onward: not started

---

## 4. Immediate Practical Milestone

### Milestone

Create and push the first verified repository baseline.

### Included files

```text
docs/environment/tool-installation.md
ops/scripts/verify-workstation.sh
```

### Acceptance criteria

1. Verification script passes.
2. Only the intended files are staged.
3. The staged diff is reviewed.
4. The first commit is created on `agrilink-lanka-stable`.
5. The stable branch is pushed to GitHub.
6. The working branch `setup/agrilink-lanka-foundation` is created from that commit.

### Next visible milestone after Git safety

Create the monorepo foundation and then run:

```text
Laravel API + PostgreSQL container + tested health endpoint
```

This will be the first visible full-stack runtime milestone.

---

## 5. Required Task Format

For every new task, ChatGPT must provide:

1. **Current phase**
2. **Architecture context**
3. **One measurable goal**
4. **Why it matters in production**
5. **Known evidence**
6. **Commands or complete replacement file**
7. **Expected result**
8. **Verification**
9. **Risks**
10. **Rollback**
11. **Exact output to return**
12. **Git checkpoint**
13. **Progress record update**

Do not continue to another major task until the current milestone has verified evidence.

---

## 6. Decision Rules

- Do not develop directly on `agrilink-lanka-stable`.
- Do not introduce a technology before the project needs it.
- Do not claim success without command output, tests, or observable evidence.
- Do not modify several unrelated areas in one milestone.
- Do not let a small troubleshooting issue replace the main project objective.
- Audit first, repair second, verify third, commit last.
- Prefer one complete, noticeable result per session.
- Keep stable checkpoints recoverable.
- Record why each file and service exists.

---

## 7. Session Closing Record

At the end of each session, update this section or create a dated learning log.

```md
## Session Result

### Completed

### Verification Evidence

### Files Changed

### Git State

### Problems Encountered

### Recovery Actions

### What I Learned

### Exact Next Step
```

Learning logs should be stored as:

```text
docs/learning-log/YYYY-MM-DD-prompt-XX.md
```

---

## 8. Next Action

The next action is not more environment setup.

The next action is:

1. stage the two verified Phase 2 files;
2. review the staged diff;
3. create the first stable commit;
4. push `agrilink-lanka-stable`;
5. create `setup/agrilink-lanka-foundation`;
6. start the monorepo foundation.
