# Claude Crew

A reusable, project-agnostic multi-agent team system for Claude Code. Six specialized agent roles collaborate through a task-based coordination bus, with persistent state and a visual project board. You provide ideas and feedback at key checkpoints; agents handle everything else.

## Installation

**Via Claude Code plugin system** (when published to a marketplace):

```
/plugin install claude-crew
```

**From source** (current method):

```bash
git clone https://github.com/lvxiaoxin/Claude-Crew.git
cd Claude-Crew
./dev/install.sh
```

The install script checks for conflicts before copying, and deploys skills to `~/.claude/skills/`.

## Usage

Start a project with the `/crew` slash command:

```
/crew I want to build a cross-platform photo organizer app that helps users
delete similar photos, remove unwanted photos, and sort photos into albums
```

Or just `/crew` and describe your idea when prompted.

**What happens next:**

```
/crew your idea...
  → Preflight check: verify all required tools are available
  → PM captures your idea, creates a project brief
  → PM decomposes into stages: Requirements → Design → Development → Testing → Release
  → PM assigns first-stage tasks to Architect and itself
  → Team executes, you approve at each stage gate
  → Visual board (docs/project/board.html) keeps you informed at all times
```

## Architecture

| Layer | Mechanism | Purpose |
|---|---|---|
| Role definition | `skills/agents/*.md` | Who each agent is and what they can do |
| Role instance | `TeamCreate` | Persistent, named agents with memory across tasks |
| Task coordination | Task system | Task state, dependencies, assignment |
| Agent communication | `SendMessage` | Direct inter-agent dialogue |
| Persistence | `docs/project/` files | Board, tasks, documents — survives across sessions |
| Human interface | Stage-gate approval | PM notifies you at key checkpoints |

## Team Roles

### PM (Project Manager)

The central coordinator. Translates your ideas into actionable plans, assigns tasks, tracks progress, and keeps you informed.

- **Outputs**: Project brief, PRD, tasks.yaml, visual board (board.html)
- **Key behavior**: Only agent that talks to you; maintains the single source of truth for project state
- **Board auto-update**: Regenerates the visual board whenever any task completes
- **Session persistence**: PM stays active for the entire session — all your input goes through PM until you end the project
- **Background dispatch**: Agents run in background so PM remains responsive to you

### Architect

Makes foundational technical decisions: tech stack, system structure, module boundaries.

- **Outputs**: Architecture doc, tech selection rationale, POC code (only when uncertain)
- **Key behavior**: Researches via web, writes POC only when needed (skips when confident), documents only — no production code

### Designer

Creates UI/UX design: layouts, interaction flows, visual style, component specifications.

- **Outputs**: UI design doc, design assets (screenshots/links), optional UI component code
- **Key behavior**: Generates design prompts for external tools (e.g., Google Stitch) — you execute the prompt and paste back the result. Can provide UI code when confident, but Developer must verify.

### Developer

Turns architecture and design into working code. The primary code producer.

- **Outputs**: Source code, API documentation, conventional commits
- **Key behavior**: Scaffolds project structure, implements features, verifies Designer's UI code against screenshots, fixes Tester's defect reports

### Tester

Ensures quality through automated testing.

- **Outputs**: Test code, test plan, defect reports
- **Key behavior**: Writes automated tests only (unit, integration, widget/UI). Refines Architect's high-level testing strategy into detailed test plans.

### DevOps (Optional)

Handles CI/CD, builds, repository management, monitoring, and releases.

- **Activation**: PM decides at project kickoff whether DevOps is needed. Can be activated later.
- **When not activated**: Architect defines build standards, Developer executes.

## Autonomy Levels

A single global parameter controlling how all agents interact with you:

| Level | Behavior | When to use |
|---|---|---|
| **advisory** | PM only escalates major decisions, risks, or ambiguity | Default — balanced oversight |
| **supervised** | PM seeks your approval at every stage gate | When you want full control |
| **autonomous** | Agents operate independently; you check the board when you want | When you want maximum speed and minimal interruption |

Switch anytime by telling PM: *"switch to advisory"*

## Communication Rules

```
         PM  Arch  Design  Dev  Test  DevOps  Human
PM        -   ✓     ✓      ✓    ✓     ✓       ✓
Arch      ✓   -     ✗      ✓    ✗     ✓       ✗
Design    ✓   ✗     -      ✓    ✗     ✗       ✗
Dev       ✓   ✓     ✓      -    ✓     ✓       ✗
Test      ✓   ✗     ✗      ✓    -     ✗       ✗
DevOps    ✓   ✓     ✗      ✓    ✗     -       ✗
```

- **PM is the only agent that talks to you.** All others escalate through PM.
- **Technical roles** can discuss directly with connected roles (e.g., Architect ↔ Developer).
- **Cross-domain** communication goes through PM.

**Escalation path**: agent contacts the relevant role directly → if unresolved, escalates to PM → PM decides whether to involve you (based on autonomy level).

## Project Lifecycle

### Startup

1. You run `/crew` with your idea
2. PM runs a **preflight check** — verifies each role's required tools are available. If something is missing (e.g., WebSearch for Architect), PM tells you and asks whether to proceed with reduced capabilities or fix it first.
3. PM creates `docs/project/` with project brief, task breakdown, and visual board
4. PM presents the plan for your approval (in supervised mode)
5. On approval, PM assigns first-stage tasks

### Execution Loop

1. PM assigns tasks to roles via SendMessage
2. Roles execute (may discuss directly for technical details)
3. On task completion: PM updates tasks.yaml, regenerates the board
4. When a stage completes: PM triggers stage-gate (approval/auto-proceed based on autonomy level)
5. Repeat until project is done

### Mid-Flight Input

You can provide new information to PM at any time during execution:

- **Low impact** (minor detail): PM records it, current tasks continue
- **Affects in-progress tasks** (requirement change): PM notifies affected roles to pause/adjust
- **Direction change** (pivot/drop feature): PM halts affected tasks, re-plans, seeks your confirmation

## Task Data

All project state lives in `docs/project/tasks.yaml` — the single source of truth:

```yaml
project: "My App"
autonomy: supervised

stages:
  - name: "Requirements & Architecture"
    status: in_progress
    tasks:
      - id: T001
        title: "Write PRD"
        assignee: pm
        status: completed
        output: docs/project/prd.md
      - id: T002
        title: "Technology selection"
        assignee: architect
        status: in_progress
        depends_on: []
```

The visual board (`docs/project/board.html`) is self-contained HTML with embedded data — open it directly in any browser (no server needed, works with `file://` protocol).

## Superpowers Integration

Agents automatically leverage [superpowers](https://github.com/obra/superpowers) skills when installed. These are enhancements, not hard dependencies — if a skill is not available, the agent proceeds without it.

| Agent | Superpowers Skills Used |
|---|---|
| PM | `writing-plans`, `verification-before-completion` |
| Architect | `brainstorming`, `verification-before-completion` |
| Designer | `brainstorming`, `verification-before-completion` |
| Developer | `test-driven-development`, `systematic-debugging`, `requesting-code-review`, `verification-before-completion` |
| Tester | `systematic-debugging`, `verification-before-completion` |
| DevOps | `verification-before-completion` |

## Dependencies

All required tools are Claude Code built-ins (Read, Write, Edit, Bash, Agent, SendMessage, TeamCreate, Task system, WebSearch, WebFetch). No external dependencies required.

Optional MCP servers can enhance capabilities:
- **Design tools** (e.g., Google Stitch API) — enhances Designer with direct tool integration. Without it, Designer generates prompts for you to execute manually.

The preflight check in `project-init` verifies tool availability before starting.

## Repository Structure

```
claude-crew/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata and dependency declarations
├── skills/
│   ├── crew/                # /crew slash command entry point
│   │   └── SKILL.md
│   ├── agents/              # Role definitions
│   │   ├── pm.md
│   │   ├── architect.md
│   │   ├── designer.md
│   │   ├── developer.md
│   │   ├── tester.md
│   │   └── devops.md
│   └── workflows/           # Coordination workflows
│       ├── project-init.md  # Project kickoff (includes preflight check)
│       ├── stage-gate.md    # Stage approval
│       └── board-update.md  # Board refresh on task change
├── templates/
│   └── project/             # Copied into each new project
│       ├── tasks.yaml
│       └── board.html
└── docs/
    └── specs/               # Design specifications
```

## Customization

All role definitions are markdown files in `skills/agents/`. Edit them to:

- Adjust role responsibilities or boundaries
- Add new tools or MCP integrations
- Change communication rules
- Modify workflow steps

The system is designed to be project-agnostic — the same roles work for any project. Project-specific context is provided by you at startup and maintained by PM in the project files.

## License

MIT
