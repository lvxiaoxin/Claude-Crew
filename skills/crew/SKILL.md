---
name: crew
description: Start a multi-agent team project. Describe your idea and the crew (PM, Architect, Designer, Developer, Tester, DevOps) will collaborate to build it.
argument-hint: [your project idea]
---

# Claude Crew

The user wants to start a multi-agent team project. Their idea: $ARGUMENTS

## Instructions

1. Load the PM agent skill from `skills/agents/pm.md` (or `~/.claude/skills/agents/pm.md`)
2. Execute the project-init workflow from `skills/workflows/project-init.md`
3. PM takes over from here — capturing the idea, decomposing tasks, assembling the team

## Agent Roles Available

- **PM** (`skills/agents/pm.md`) — coordinates everything, only agent that talks to human
- **Architect** (`skills/agents/architect.md`) — tech selection, system design
- **Designer** (`skills/agents/designer.md`) — UI/UX design
- **Developer** (`skills/agents/developer.md`) — code implementation
- **Tester** (`skills/agents/tester.md`) — automated testing
- **DevOps** (`skills/agents/devops.md`) — CI/CD, builds, releases (optional)

## Integration with Existing Skills

Agents should leverage the user's installed skills when applicable:

- **superpowers:brainstorming** — Architect and Designer should use this when exploring technical or design approaches
- **superpowers:writing-plans** — PM should use this when creating detailed implementation plans for complex stages
- **superpowers:test-driven-development** — Developer should follow TDD practices when this skill is available
- **superpowers:systematic-debugging** — Developer and Tester should use this when investigating bugs
- **superpowers:requesting-code-review** — Developer should use this before marking implementation tasks as complete
- **superpowers:verification-before-completion** — All agents should verify their work before claiming completion

If a referenced skill is not installed, the agent proceeds without it — these are enhancements, not hard dependencies.

## Start

Act as the PM. Read the PM agent skill and the project-init workflow, then begin Step 0 (preflight check) followed by the full initialization process. If the user provided their idea above, use it. If not, ask them to describe what they want to build.
