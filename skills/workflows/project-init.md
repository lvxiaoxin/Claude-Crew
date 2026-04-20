---
name: project-init
description: Project initialization workflow — transforms a human's idea into a structured project with active agent team
type: workflow
---

# Project Initialization Workflow

This workflow is triggered when the human provides a new project idea. PM executes this workflow to bootstrap the entire project.

## Prerequisites

- The human has described their project idea
- The current working directory is the target project root
- The claude-crew skill files are installed in `~/.claude/skills/`

## Steps

### Step 0: Preflight Check

Before creating anything, verify that the required capabilities are available. For each role that will be activated, check:

| Role | Required Tools | Check Method |
|---|---|---|
| PM | TaskCreate, TaskUpdate, TaskList, Read, Write | Try calling TaskList — if it works, core tools are available |
| Architect | Read, Write, WebSearch, WebFetch, Bash | Try a simple WebSearch — if it works, research capability is available |
| Designer | Read, Write | Always available; MCP design tools are optional |
| Developer | Read, Write, Edit, Bash, Git | Try `git --version` via Bash — if it works, dev tools are available |
| Tester | Read, Write, Bash | Same as Developer baseline |
| DevOps | Bash, Git, Read, Write | Same as Developer baseline |

**If a required tool is unavailable:**
- Report the specific missing capability to the human
- Suggest how to fix it (e.g., "WebSearch is not available — Architect won't be able to research technologies online. Proceed anyway?")
- Let the human decide whether to proceed with reduced capabilities or fix the issue first

**If an optional MCP tool is unavailable:**
- Note it but don't block — the skill file defines the fallback behavior (e.g., Designer generates prompts for human to execute manually)

### Step 1: Create Project Structure

Create the `docs/project/` directory and copy templates from `~/.claude/claude-crew-templates/project/`:

```
docs/project/
├── tasks.yaml       # from ~/.claude/claude-crew-templates/project/tasks.yaml
├── board.html       # from ~/.claude/claude-crew-templates/project/board.html
├── brief.md         # created in step 2
├── doc-index.md     # created in step 3
├── comms-log.md     # audit trail for agent communications
└── design-assets/   # empty directory for Designer
```

### Step 2: Capture the Idea

Write `docs/project/brief.md` with:

```markdown
# Project Brief

## Original Idea
[Human's idea, captured verbatim]

## Structured Summary
- **What**: [one-line description of the product]
- **Who**: [target users]
- **Why**: [problem being solved]
- **Platforms**: [target platforms]
- **Key Features**: [bulleted list]

## Constraints & Preferences
[Any constraints the human mentioned: tech preferences, timeline, etc.]

## Open Questions
[Anything unclear that needs clarification before proceeding]
```

If there are open questions, ask the human before proceeding.

### Step 3: Create Document Index

Write `docs/project/doc-index.md`:

```markdown
# Document Index

| Document | Owner | Status |
|---|---|---|
| [brief.md](brief.md) | PM | Complete |
| [tasks.yaml](tasks.yaml) | PM | Active |
| [board.json](board.json) | PM | Auto-generated |
| [prd.md](prd.md) | PM | Pending |
| [architecture.md](architecture.md) | Architect | Pending |
| [tech-selection.md](tech-selection.md) | Architect | Pending |
| [ui-design.md](ui-design.md) | Designer | Pending |
| [test-plan.md](test-plan.md) | Tester | Pending |
| [api.md](api.md) | Developer | Pending |
```

Update this index as documents are created.

### Step 4: Decompose into Stages and Tasks

Populate `tasks.yaml`:
1. Fill in the `project` name
2. Set `autonomy` to `supervised` (default)
3. Set `created` and `updated` timestamps
4. Decide which roles to activate (always: PM, Architect, Designer, Developer, Tester; optional: DevOps)
5. Create tasks for the first stage ("Requirements & Architecture"):
   - T001: Write PRD (assignee: pm)
   - T002: Technology selection (assignee: architect)
   - T003: System architecture design (assignee: architect, depends_on: T002)
6. Leave subsequent stages with empty task lists (to be filled as the project progresses)

### Step 5: Decide on DevOps

Based on the human's input:
- If they want CI/CD, releases, or deployment → activate DevOps
- If they just want to build locally first → leave DevOps inactive
- If unclear → ask the human

### Step 6: Instantiate Team Agents

Use `TeamCreate` to create named agents for each active role:
- Load each agent's skill file from `~/.claude/skills/agents/[role].md`
- Set each agent's system prompt to the content of their skill file
- Configure each agent's tools based on their Capabilities section

### Step 7: Generate Initial Board

1. Read tasks.yaml
2. Compute stage progress, task-by-status groupings, and role workload
3. Write board.json
4. Board.html will render from board.json automatically

### Step 8: Present Plan to Human

In supervised mode, present to the human:

```
## Project Plan

**Project:** [name]
**Active Roles:** PM, Architect, Designer, Developer, Tester [, DevOps]
**Autonomy:** supervised

### Stage 1: Requirements & Architecture
- [ ] T001: Write PRD (PM)
- [ ] T002: Technology selection (Architect)
- [ ] T003: System architecture design (Architect)

### Stage 2-5: [outlined but not yet detailed]

Board available at: docs/project/board.html

Approve to begin?
```

### Step 9: Begin Execution

On human approval:
1. Set Stage 1 status to `in_progress`
2. Assign tasks via SendMessage:
   - PM starts on T001 (PRD) immediately
   - Architect starts on T002 (tech selection) immediately
   - T003 waits for T002 to complete
3. Update board
