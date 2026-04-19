# Claude Crew

A reusable, project-agnostic multi-agent team system for Claude Code. Define agent roles once, use them across any project.

## Quick Start

### Install

Copy the skills into your Claude Code configuration:

```bash
cp -r skills/* ~/.claude/skills/
```

### Start a Project

In a new Claude Code session, in your project directory:

1. Tell Claude your idea: "I want to build a photo organizer app..."
2. PM agent activates and runs the project-init workflow
3. PM creates project structure, decomposes tasks, assembles the team
4. You approve the plan, and the team starts working

## Team Roles

| Role | Responsibility | Optional? |
|---|---|---|
| **PM** | Requirements, task management, progress board, stage approvals | No |
| **Architect** | Tech selection, system design, architecture docs | No |
| **Designer** | UI/UX design, design tool prompts, design docs | No |
| **Developer** | Code scaffolding, feature implementation, bug fixes | No |
| **Tester** | Automated tests, test plans, defect reports | No |
| **DevOps** | CI/CD, builds, repo management, releases | Yes |

## Autonomy Levels

Control how much oversight you want:

| Level | You get involved when... |
|---|---|
| `supervised` | Every stage completes (default) |
| `advisory` | Major decisions, risks, or ambiguity only |
| `autonomous` | You check the board and intervene when you want |

Switch anytime: "switch to advisory"

## Project Structure

When PM initializes a project, it creates:

```
your-project/
└── docs/project/
    ├── brief.md         # Your idea, structured
    ├── prd.md           # Product requirements
    ├── tasks.yaml       # All tasks (single source of truth)
    ├── board.json       # Board data
    ├── board.html       # Visual board (open in browser)
    ├── doc-index.md     # Index of all documents
    ├── architecture.md  # System architecture
    ├── tech-selection.md # Technology choices
    ├── ui-design.md     # UI/UX design
    ├── test-plan.md     # Test strategy
    ├── api.md           # Interface docs
    └── design-assets/   # Screenshots, mockups
```

## Directory Structure (This Repo)

```
claude-crew/
├── skills/
│   ├── agents/          # 6 role definitions
│   └── workflows/       # 3 workflow definitions
├── templates/
│   └── project/         # Templates copied to each new project
├── docs/
│   ├── specs/           # Design specifications
│   └── plans/           # Implementation plans
└── README.md
```

## Communication Rules

- PM is the only agent that talks to you
- Technical roles can discuss directly with each other
- Cross-domain communication goes through PM
- You can provide new input to PM at any time, even during execution

## Customization

The skill files in `skills/agents/` are markdown — edit them to adjust role behavior, add tools, or change workflows.
