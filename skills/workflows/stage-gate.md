---
name: stage-gate
description: Stage transition workflow — handles stage completion, summary, approval, and next-stage kickoff
type: workflow
---

# Stage Gate Workflow

This workflow is triggered by PM when all tasks in a stage are completed. It handles the transition to the next stage based on the current autonomy level.

## Trigger

PM detects that every task in the current stage has status `completed`.

## Steps

### Step 1: Generate Stage Summary

Compile a summary of the completed stage:

```markdown
## Stage Complete: [Stage Name]

### Completed Tasks
| ID | Title | Assignee | Output |
|---|---|---|---|
| T001 | ... | ... | docs/project/... |

### Key Decisions Made
- [List any significant technical or design decisions]

### Outputs Produced
- [List all documents and artifacts created]

### Risks or Concerns
- [Any issues flagged during this stage]
- [Any assumptions that should be validated]

### Next Stage: [Next Stage Name]
- [Brief description of what the next stage will cover]
```

### Step 2: Autonomy-Based Action

**If supervised:**
1. Present the stage summary to the human in the main conversation
2. Ask: "Stage [name] is complete. Approve to proceed to [next stage]?"
3. Wait for human response
4. If human requests changes: adjust tasks, re-assign, re-run affected work
5. If human approves: proceed to Step 3

**If advisory:**
1. Check: are there any flagged risks or open decisions?
   - Yes: present them to the human, ask for input
   - No: proceed to Step 3 automatically
2. Log the stage transition in tasks.yaml

**If autonomous:**
1. Log the stage transition in tasks.yaml
2. Proceed to Step 3 automatically
3. The human can see the transition on the board

### Step 3: Transition to Next Stage

1. Update current stage status to `completed` in tasks.yaml
2. Set next stage status to `in_progress`
3. Decompose next stage into specific tasks (based on PRD, architecture, and previous stage outputs)
4. Assign tasks to appropriate roles via SendMessage
5. Update board (board-update workflow)

### Step 4: Handle Final Stage

If the completed stage is the last one ("Release"):
1. Generate a project completion summary
2. Present to human regardless of autonomy level
3. Ask if there are follow-up tasks or if the project is done

## Edge Cases

- **Human rejects stage completion**: PM identifies what needs to be redone, creates new tasks in the current stage, re-assigns
- **Stage has blocked tasks**: PM should resolve blockers before triggering stage-gate. If a task is blocked and cannot be resolved, escalate to human.
- **Human changes autonomy mid-gate**: Apply the new level immediately for the current decision
