# Claude Crew Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a reusable, project-agnostic multi-agent team system for Claude Code with 6 specialized roles, workflow definitions, and project templates.

**Architecture:** Skills-based agent definitions in markdown, workflow files for coordination patterns, YAML/HTML templates for project state persistence. All files live in `/Users/lvxin/Code/claude-crew/` as source of truth, deployed by copying `skills/` to `~/.claude/skills/`.

**Tech Stack:** Claude Code skills (markdown), YAML (task data), HTML/CSS/JS (board visualization)

---

## File Structure

```
claude-crew/
├── skills/
│   ├── agents/
│   │   ├── pm.md              # PM role definition
│   │   ├── architect.md       # Architect role definition
│   │   ├── designer.md        # Designer role definition
│   │   ├── developer.md       # Developer role definition
│   │   ├── tester.md          # Tester role definition
│   │   └── devops.md          # DevOps role definition
│   └── workflows/
│       ├── project-init.md    # Project kickoff workflow
│       ├── stage-gate.md      # Stage approval workflow
│       └── board-update.md    # Board refresh workflow
├── templates/
│   └── project/
│       ├── tasks.yaml         # Task data template
│       ├── board.json         # Board data template
│       └── board.html         # Board visualization
├── docs/
│   ├── specs/                 # (already exists)
│   └── plans/                 # (this file)
└── README.md
```

---

### Task 1: Project Templates

**Files:**
- Create: `templates/project/tasks.yaml`
- Create: `templates/project/board.json`
- Create: `templates/project/board.html`

- [ ] **Step 1: Create tasks.yaml template**

```yaml
project: ""
autonomy: supervised    # supervised | advisory | autonomous
created: ""             # ISO date
updated: ""             # ISO date

roles:
  - pm
  - architect
  - designer
  - developer
  - tester
  # - devops            # uncomment if needed

stages:
  - name: "Requirements & Architecture"
    status: pending
    tasks: []

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

# Task structure reference:
# - id: T001
#   title: ""
#   assignee: pm | architect | designer | developer | tester | devops
#   status: pending | in_progress | completed | blocked
#   depends_on: []
#   output: ""
#   created: ""
#   updated: ""
```

- [ ] **Step 2: Create board.json template**

```json
{
  "project": "",
  "autonomy": "supervised",
  "updated": "",
  "stages": [
    {
      "name": "Requirements & Architecture",
      "status": "pending",
      "progress": 0,
      "tasks": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 }
    },
    {
      "name": "Design",
      "status": "pending",
      "progress": 0,
      "tasks": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 }
    },
    {
      "name": "Development",
      "status": "pending",
      "progress": 0,
      "tasks": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 }
    },
    {
      "name": "Testing",
      "status": "pending",
      "progress": 0,
      "tasks": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 }
    },
    {
      "name": "Release",
      "status": "pending",
      "progress": 0,
      "tasks": { "total": 0, "completed": 0, "in_progress": 0, "blocked": 0 }
    }
  ],
  "tasksByStatus": {
    "pending": [],
    "in_progress": [],
    "completed": [],
    "blocked": []
  },
  "roleWorkload": {}
}
```

- [ ] **Step 3: Create board.html**

A self-contained HTML file that reads `board.json` (same directory) and renders:
- Stage progress bars with percentage
- Kanban columns (pending / in_progress / completed / blocked) with task cards
- Role workload summary
- Current autonomy level indicator
- Auto-refresh button
- Color coding: pending=gray, in_progress=blue, completed=green, blocked=red

The HTML must work by opening the file directly in a browser (`file://` protocol). Use fetch to load `board.json` from the same directory.

- [ ] **Step 4: Verify templates**

Run: `ls -la templates/project/`
Expected: 3 files (tasks.yaml, board.json, board.html)

Run: Open `templates/project/board.html` in browser
Expected: Empty board with 5 stages, all showing 0% progress

- [ ] **Step 5: Commit**

```bash
git add templates/
git commit -m "feat: add project templates (tasks.yaml, board.json, board.html)"
```

---

### Task 2: PM Agent Skill

**Files:**
- Create: `skills/agents/pm.md`

- [ ] **Step 1: Write PM skill file**

The PM skill must include:
- Frontmatter: name, description, type
- Identity: role description, core mandate
- Autonomy levels: supervised/advisory/autonomous with behavior definitions
- Capabilities: Task system, file read/write, board generation
- Outputs: brief.md, prd.md, tasks.yaml, board.json, board.html
- Collaboration rules: can SendMessage all roles, only agent talking to human
- Board auto-update: procedure for regenerating board on task completion
- Mid-flight input handling: how to process new human input during execution
- Project init procedure: what to do when human provides a new idea
- Stage-gate procedure: how to handle stage transitions
- Task assignment format: standardized message format when delegating to other roles

Key behaviors to encode:
- When receiving a new idea from human: create brief.md, decompose into stages/tasks, generate board, seek approval
- When a role completes a task: read tasks.yaml, update status, regenerate board.json and board.html, check if stage is complete
- When stage completes: summarize stage results, present to human for approval (in supervised mode), proceed if advisory/autonomous
- When human provides mid-flight input: assess impact (low/affects-tasks/direction-change), act accordingly
- When autonomy level changes: update tasks.yaml, notify all active roles

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/pm.md | head -5`
Expected: frontmatter with name: pm

- [ ] **Step 3: Commit**

```bash
git add skills/agents/pm.md
git commit -m "feat: add PM agent skill definition"
```

---

### Task 3: Architect Agent Skill

**Files:**
- Create: `skills/agents/architect.md`

- [ ] **Step 1: Write Architect skill file**

The Architect skill must include:
- Frontmatter: name, description, type
- Identity: technical leadership role
- Capabilities: file read/write, WebSearch/WebFetch, Bash (POC only when uncertain)
- Outputs: architecture.md, tech-selection.md, POC code (optional)
- Collaboration: direct with Developer and DevOps, others through PM
- Key behaviors:
  - Technology selection: research → compare → recommend → document rationale
  - Architecture design: define layers, modules, data flow, interfaces
  - POC policy: only when uncertain, skip when confident
  - Testing strategy: define high-level direction (coverage targets, critical paths) for Tester
  - Build standards: define when DevOps not activated, for Developer to execute
  - Architecture changes: follow global autonomy level
- Boundary: documents only, no code scaffolding (except POC)

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/architect.md | head -5`
Expected: frontmatter with name: architect

- [ ] **Step 3: Commit**

```bash
git add skills/agents/architect.md
git commit -m "feat: add Architect agent skill definition"
```

---

### Task 4: Designer Agent Skill

**Files:**
- Create: `skills/agents/designer.md`

- [ ] **Step 1: Write Designer skill file**

The Designer skill must include:
- Frontmatter: name, description, type
- Identity: UI/UX design role
- Capabilities: file read/write, abstract design tool interface
- Outputs: ui-design.md, design-assets/, optional UI component code
- Collaboration: direct with Developer, others through PM
- Key behaviors:
  - Design tool workflow: generate prompt → human executes in Stitch → human pastes result → Designer incorporates
  - UI code policy: may provide component code when confident, but always mark as "needs Developer verification"
  - Design documentation: layouts, interaction flows, visual style, component specs
- Abstract design tool interface: skill defines a placeholder for external design tools. Currently manual (prompt generation), future MCP integration possible.

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/designer.md | head -5`
Expected: frontmatter with name: designer

- [ ] **Step 3: Commit**

```bash
git add skills/agents/designer.md
git commit -m "feat: add Designer agent skill definition"
```

---

### Task 5: Developer Agent Skill

**Files:**
- Create: `skills/agents/developer.md`

- [ ] **Step 1: Write Developer skill file**

The Developer skill must include:
- Frontmatter: name, description, type
- Identity: implementation role
- Capabilities: file read/write/edit, Bash, Git
- Outputs: source code, api.md, conventional commits
- Collaboration: direct with Architect, Tester, DevOps, Designer
- Key behaviors:
  - Code scaffolding: build project structure based on Architect's document
  - Feature implementation: based on PRD and design docs
  - Designer UI code verification: compare against screenshots, modify as needed
  - Bug fixes: from Tester defect reports
  - Commit discipline: conventional commits (feat/fix/refactor/etc.)
  - Basic build config: handle when DevOps not activated, per Architect's standards
  - Escalation: contact relevant role first → unresolved → escalate to PM

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/developer.md | head -5`
Expected: frontmatter with name: developer

- [ ] **Step 3: Commit**

```bash
git add skills/agents/developer.md
git commit -m "feat: add Developer agent skill definition"
```

---

### Task 6: Tester Agent Skill

**Files:**
- Create: `skills/agents/tester.md`

- [ ] **Step 1: Write Tester skill file**

The Tester skill must include:
- Frontmatter: name, description, type
- Identity: quality assurance role
- Capabilities: file read/write, Bash (run tests)
- Outputs: test code, test-plan.md, defect reports (as tasks in tasks.yaml)
- Collaboration: direct with Developer only
- Key behaviors:
  - Test strategy: refine Architect's high-level direction into detailed plan
  - Automated tests only: unit, integration, widget/UI tests
  - Defect reporting: create tasks in tasks.yaml assigned to Developer
  - Fix verification: re-run tests after Developer fixes, confirm pass

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/tester.md | head -5`
Expected: frontmatter with name: tester

- [ ] **Step 3: Commit**

```bash
git add skills/agents/tester.md
git commit -m "feat: add Tester agent skill definition"
```

---

### Task 7: DevOps Agent Skill

**Files:**
- Create: `skills/agents/devops.md`

- [ ] **Step 1: Write DevOps skill file**

The DevOps skill must include:
- Frontmatter: name, description, type
- Identity: infrastructure and release role, **optional** — activated by PM when needed
- Capabilities: Bash, Git, file read/write, CI/CD config
- Outputs: CI/CD configs, devops.md
- Collaboration: direct with Architect and Developer
- Key behaviors:
  - CI/CD setup: pipeline for dual-platform builds (iOS + Android)
  - Repo management: branch strategy, protection rules
  - Monitoring: alerting setup if app has backend services
  - Release management: build, sign, publish workflow
- Activation: PM decides at project kickoff; can be activated later
- When not activated: Architect defines build standards, Developer executes

- [ ] **Step 2: Verify skill file**

Run: `cat skills/agents/devops.md | head -5`
Expected: frontmatter with name: devops

- [ ] **Step 3: Commit**

```bash
git add skills/agents/devops.md
git commit -m "feat: add DevOps agent skill definition (optional role)"
```

---

### Task 8: Workflow — Project Init

**Files:**
- Create: `skills/workflows/project-init.md`

- [ ] **Step 1: Write project-init workflow**

This workflow defines what happens when a human provides a new project idea:

1. PM creates `docs/project/` directory in the target project
2. PM copies templates from `templates/project/` to `docs/project/`
3. PM writes `docs/project/brief.md` capturing the human's idea
4. PM decomposes the idea into stages and tasks, populates tasks.yaml
5. PM decides whether to activate DevOps (based on human's input)
6. PM uses TeamCreate to instantiate active roles
7. PM generates initial board (board.json + board.html)
8. PM presents the plan to human for approval (if supervised)
9. On approval, PM assigns first-stage tasks via SendMessage

- [ ] **Step 2: Verify workflow file**

Run: `cat skills/workflows/project-init.md | head -5`
Expected: frontmatter with name: project-init

- [ ] **Step 3: Commit**

```bash
git add skills/workflows/project-init.md
git commit -m "feat: add project-init workflow"
```

---

### Task 9: Workflow — Stage Gate

**Files:**
- Create: `skills/workflows/stage-gate.md`

- [ ] **Step 1: Write stage-gate workflow**

This workflow defines stage transition behavior:

1. PM detects all tasks in current stage are completed
2. PM generates stage summary (what was done, outputs produced, any risks)
3. Behavior based on autonomy level:
   - supervised: present summary to human, wait for approval
   - advisory: proceed unless there are flagged risks/decisions, then ask human
   - autonomous: proceed, log the transition
4. On approval/proceed: PM updates stage status, assigns next-stage tasks
5. If human requests changes: PM adjusts tasks, notifies affected roles

- [ ] **Step 2: Verify workflow file**

Run: `cat skills/workflows/stage-gate.md | head -5`
Expected: frontmatter with name: stage-gate

- [ ] **Step 3: Commit**

```bash
git add skills/workflows/stage-gate.md
git commit -m "feat: add stage-gate workflow"
```

---

### Task 10: Workflow — Board Update

**Files:**
- Create: `skills/workflows/board-update.md`

- [ ] **Step 1: Write board-update workflow**

This workflow defines what PM does when any task status changes:

1. Read current tasks.yaml
2. Recompute stage progress (completed/total per stage)
3. Recompute task-by-status groupings
4. Recompute role workload distribution
5. Write updated board.json
6. Regenerate board.html (or board.html reads board.json dynamically — if so, only board.json needs updating)
7. Git commit the changes

- [ ] **Step 2: Verify workflow file**

Run: `cat skills/workflows/board-update.md | head -5`
Expected: frontmatter with name: board-update

- [ ] **Step 3: Commit**

```bash
git add skills/workflows/board-update.md
git commit -m "feat: add board-update workflow"
```

---

### Task 11: README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README**

Contents:
- What is claude-crew (one paragraph)
- Quick start: how to deploy (copy skills/ to ~/.claude/skills/)
- How to start a project (tell PM your idea)
- Role overview (table)
- Autonomy levels explained
- Directory structure
- Contributing / customization

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with usage instructions"
```

---

### Task 12: Deploy and Verify

- [ ] **Step 1: Check existing skills directory**

```bash
ls -la ~/.claude/skills/
ls -la ~/.claude/skills/agents/ 2>/dev/null
ls -la ~/.claude/skills/workflows/ 2>/dev/null
```

Review the output. Identify any files or directories that would conflict with the ones being deployed (`agents/`, `workflows/`). If conflicts exist, ask the user how to handle them before proceeding.

- [ ] **Step 2: Copy skills (no overwrite)**

Only proceed after confirming no conflicts (or user has approved overwrite for specific files).

```bash
# Create target directories if they don't exist
mkdir -p ~/.claude/skills/agents
mkdir -p ~/.claude/skills/workflows

# Copy individual files (won't overwrite existing unrelated files)
cp /Users/lvxin/Code/claude-crew/skills/agents/*.md ~/.claude/skills/agents/
cp /Users/lvxin/Code/claude-crew/skills/workflows/*.md ~/.claude/skills/workflows/
```

- [ ] **Step 3: Verify deployment**

```bash
ls ~/.claude/skills/agents/
ls ~/.claude/skills/workflows/
```

Expected: 6 agent files in agents/, 3 workflow files in workflows/

- [ ] **Step 4: Commit all remaining changes and verify clean state**

```bash
cd /Users/lvxin/Code/claude-crew
git status
```

Expected: clean working tree
