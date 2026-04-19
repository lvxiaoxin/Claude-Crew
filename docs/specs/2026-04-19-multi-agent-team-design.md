# Multi-Agent Team Design Spec

## Overview

A reusable, project-agnostic multi-agent team system for Claude Code. Six specialized agent roles collaborate through a Task-based coordination bus, with persistent state and a visual project board. The human provides ideas and feedback at key checkpoints; agents handle everything else.

## Architecture

### Layers

| Layer | Mechanism | Purpose |
|---|---|---|
| Role definition | `.claude/skills/agents/*.md` | Who each agent is and what they can do |
| Role instance | `TeamCreate` | Persistent, named agents with memory across tasks |
| Task coordination | Task system | Task state, dependencies, assignment |
| Agent communication | `SendMessage` | Direct inter-agent dialogue |
| Persistence | `docs/project/` files | Board, tasks, documents — survives across sessions |
| Human interface | Stage-gate approval | PM notifies human at key checkpoints |

### Directory Structure

```
claude-crew/
├── skills/
│   ├── agents/                    # 6 role definitions
│   │   ├── pm.md
│   │   ├── architect.md
│   │   ├── designer.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   └── devops.md
│   └── workflows/                 # Workflow definitions
│       ├── project-init.md        # Project kickoff flow
│       ├── stage-gate.md          # Stage approval flow
│       └── board-update.md        # Task completion → board refresh
├── templates/
│   └── project/                   # Copied to each new project's docs/project/
│       ├── tasks.yaml
│       ├── board.json
│       └── board.html
└── README.md
```

Deployment: copy `skills/` to `~/.claude/skills/` for use in any project.

---

## Global Rules

### Autonomy Levels

A single global parameter controlling how all agents interact with the human:

| Level | Name | Behavior |
|---|---|---|
| Default | **supervised** | PM seeks human approval at each stage gate |
| Mid | **advisory** | PM only escalates major decisions, risks, or ambiguity |
| Full | **autonomous** | Agents operate independently; human intervenes proactively |

The human can switch at any time by telling PM (e.g., "switch to advisory"). PM updates `tasks.yaml` and all agents follow.

### Communication Rules

**Communication matrix** (bidirectional — ✓ means either side can initiate):

```
         PM  Arch  Design  Dev  Test  DevOps  Human
PM        -   ✓     ✓      ✓    ✓     ✓       ✓
Arch      ✓   -     ✗      ✓    ✗     ✓       ✗
Design    ✓   ✗     -      ✓    ✗     ✗       ✗
Dev       ✓   ✓     ✓      -    ✓     ✓       ✗
Test      ✓   ✗     ✗      ✓    -     ✗       ✗
DevOps    ✓   ✓     ✗      ✓    ✗     -       ✗
```

- **All agents can communicate with PM** (for escalation, status updates, etc.).
- **PM is the only agent that talks to the human.** Other agents escalate through PM.
- **Technical discussions** allowed directly between connected roles.
- **Cross-domain communication** goes through PM.

### Escalation Path

When any agent encounters a blocker:
1. Contact the relevant role directly (if allowed by communication matrix)
2. If unresolved, escalate to PM
3. PM decides whether to escalate to human (based on autonomy level)

---

## Role Definitions

### PM (Project Manager)

**Responsibilities:**
- Requirement decomposition — break human ideas into actionable tasks
- Task assignment — delegate to appropriate roles
- Progress tracking — maintain visual project board (board.html)
- Dependency management — identify task ordering and blockers
- Risk identification — flag potential issues early
- Stage-gate sync — summarize progress and request human approval
- Document index — maintain a central index of all project documents

**Tools & Capabilities:**
- Task system (create, update, query)
- File read/write (tasks.yaml, board.json, board.html, docs)
- Board generation (HTML visualization)

**Outputs:**
- `docs/project/brief.md` — structured project brief from human's idea
- `docs/project/prd.md` — product requirements document
- `docs/project/tasks.yaml` — task data (single source of truth)
- `docs/project/board.json` — board data for rendering
- `docs/project/board.html` — visual board (browser-viewable)

**Collaboration:**
- Can SendMessage to all roles
- Only agent that communicates with the human
- Receives task completion notifications from all roles

**Board auto-update:** Whenever any agent completes a task, PM re-reads tasks.yaml, regenerates board.json and board.html, and commits the changes.

---

### Architect

**Responsibilities:**
- Technology selection (frameworks, languages, key dependencies)
- System architecture design (layering, module boundaries, data flow)
- Architecture documentation
- Technical risk assessment
- Define testing strategy (high-level direction for Tester)
- Define build standards when DevOps is not activated
- Provide technical guidance to Developer and DevOps

**Tools & Capabilities:**
- File read/write
- WebSearch / WebFetch (technical research)
- Bash (for POC code — only when uncertain, skip when confident)

**Outputs:**
- `docs/project/architecture.md` — system architecture document
- `docs/project/tech-selection.md` — technology selection rationale
- POC code (temporary, in `docs/project/poc/`, only when needed)

**Collaboration:**
- Direct communication with: Developer, DevOps
- Cross-domain requests go through PM

**Key boundaries:**
- Produces documents only, does not scaffold project code (except POC)
- Architecture changes follow the global autonomy level (supervised → needs human approval, advisory/autonomous → Architect decides)

---

### Designer

**Responsibilities:**
- UI/UX design (layouts, interaction flows, visual style)
- Generate design prompts for external tools (e.g., Google Stitch)
- Write UI design documentation (design specs, component descriptions)
- Optionally provide UI component code when confident (Developer must verify)

**Tools & Capabilities:**
- File read/write
- Abstract design tool interface (currently: generate prompts for human to execute in Stitch)
- Future: MCP integration when design tool APIs become available

**Outputs:**
- `docs/project/ui-design.md` — UI design document
- `docs/project/design-assets/` — screenshots, links to design tool outputs
- Optional: UI component code (must be verified by Developer)

**Collaboration:**
- Direct communication with: Developer
- Cross-domain requests go through PM

**Design tool workflow:**
1. Designer generates a design prompt/description
2. Human executes it in Stitch (or other tool)
3. Human pastes back the result (link/screenshot)
4. Designer incorporates into design documentation

---

### Developer

**Responsibilities:**
- Scaffold project code structure (based on Architect's document)
- Implement features (based on design docs and PRD)
- Write API/interface documentation
- Verify Designer-provided UI code (compare against design screenshots, modify as needed)
- Fix bugs reported by Tester
- Follow conventional commits (feat/fix/refactor/etc.)
- Handle basic build config when DevOps is not activated (per Architect's standards)

**Tools & Capabilities:**
- File read/write/edit
- Bash (build, run, debug)
- Git operations

**Outputs:**
- Source code
- `docs/project/api.md` — interface documentation
- Git commits following conventional commits format

**Collaboration:**
- Direct communication with: Architect, Tester, DevOps, Designer
- Escalation path: contact relevant role first → unresolved → escalate to PM

---

### Tester

**Responsibilities:**
- Write automated tests (unit, integration, widget/UI tests)
- Execute tests and report results
- Submit defect reports to Developer
- Verify Developer's fixes pass
- Detailed test strategy (based on Architect's high-level direction)

**Tools & Capabilities:**
- File read/write
- Bash (run test suites)

**Outputs:**
- Test code (in project's test directory)
- `docs/project/test-plan.md` — test strategy and plan
- Defect reports (as tasks in tasks.yaml, assigned to Developer)

**Collaboration:**
- Direct communication with: Developer

---

### DevOps (Optional)

**Activation:** PM decides at project kickoff whether DevOps is needed. Can be activated later.

**Responsibilities:**
- CI/CD pipeline setup and maintenance
- Build configuration (dual-platform: iOS + Android)
- Code repository management (branch strategy, protection rules)
- Monitoring and alerting (if the app has backend services)
- Release process management
- Build and release documentation

**Tools & Capabilities:**
- Bash
- Git operations
- File read/write
- CI/CD platform config

**Outputs:**
- CI/CD configuration files
- `docs/project/devops.md` — build, release, and repo management documentation

**Collaboration:**
- Direct communication with: Architect, Developer

**When not activated:** Architect defines build standards in architecture doc, Developer executes.

---

## Task Data Structure

**tasks.yaml** — single source of truth:

```yaml
project: ""                    # filled at project init
autonomy: supervised           # supervised | advisory | autonomous

stages:
  - name: "Requirements & Architecture"
    status: pending            # pending | in_progress | completed
    tasks:
      - id: T001
        title: ""
        assignee: ""           # pm | architect | designer | developer | tester | devops
        status: pending        # pending | in_progress | completed | blocked
        depends_on: []         # list of task IDs
        output: ""             # path to output file/artifact
        created: ""            # ISO date
        updated: ""            # ISO date

  - name: "Design"
    status: pending
    tasks: []

  - name: "Development"
    status: pending
    tasks: []

  - name: "Testing"
    status: pending
    tasks: []

  - name: "Release"
    status: pending
    tasks: []
```

---

## Project Lifecycle

### Startup

```
Human: "I want to build [idea]..."
  → PM activates (project-init workflow)
  → PM records idea in brief.md
  → PM decomposes into stages and tasks
  → PM generates initial board
  → PM asks human for approval (supervised mode)
```

### Execution Loop

```
PM assigns tasks to roles via SendMessage
  → Role picks up task, marks in_progress
  → Role works (may SendMessage other roles for technical discussion)
  → Role completes task, updates tasks.yaml, marks completed
  → PM detects completion, regenerates board
  → If stage complete → PM triggers stage-gate
  → Human approves → PM starts next stage
```

### Mid-Flight Human Input

The human can provide new information or feedback to PM at any time, even while tasks are in progress. PM handles this as follows:

1. **Assess impact** — does the new input affect any in-progress tasks?
2. **Low impact** (e.g., minor detail, future-stage info) — PM records it in brief.md, current tasks continue unaffected
3. **Affects in-progress tasks** (e.g., requirement clarification that changes current work) — PM notifies affected roles via SendMessage to pause or adjust
4. **Direction change** (e.g., "actually, drop feature X" or "pivot to a different approach") — PM halts affected tasks, re-plans, updates tasks.yaml and board, seeks human confirmation before resuming

---

### Autonomy Switch

```
Human: "switch to advisory"
  → PM updates autonomy field in tasks.yaml
  → All agents adjust behavior:
      supervised → seek approval at every gate
      advisory   → only escalate major decisions/risks
      autonomous → operate independently
```
