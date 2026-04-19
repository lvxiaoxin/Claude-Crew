---
name: board-update
description: Board refresh workflow — regenerates board.json from tasks.yaml whenever task state changes
type: workflow
---

# Board Update Workflow

This workflow is triggered by PM whenever any task's status changes. It keeps the visual board in sync with the task data.

## Trigger

Any of the following events:
- A task status changes (pending → in_progress → completed, or → blocked)
- A new task is created
- A task is reassigned
- The autonomy level changes
- A stage status changes

## Steps

### Step 1: Read Current State

Read `docs/project/tasks.yaml` to get the full task data.

### Step 2: Compute Board Data

From tasks.yaml, compute:

**Stage progress:**
For each stage:
- `total`: count of tasks in the stage
- `completed`: count of tasks with status `completed`
- `in_progress`: count of tasks with status `in_progress`
- `blocked`: count of tasks with status `blocked`
- `progress`: `completed / total * 100` (0 if total is 0)

**Tasks by status:**
Group all tasks across all stages into four lists:
- `pending`: all tasks with status `pending`
- `in_progress`: all tasks with status `in_progress`
- `completed`: all tasks with status `completed`
- `blocked`: all tasks with status `blocked`

Each task entry in these lists should include: `id`, `title`, `assignee`, `stage` (which stage it belongs to).

**Role workload:**
Count the number of non-completed tasks assigned to each role. Only include roles that have at least one task.

### Step 3: Write board.json

Write the computed data to `docs/project/board.json`:

```json
{
  "project": "[from tasks.yaml]",
  "autonomy": "[from tasks.yaml]",
  "updated": "[current ISO timestamp]",
  "stages": [
    {
      "name": "...",
      "status": "...",
      "progress": 75,
      "tasks": { "total": 4, "completed": 3, "in_progress": 1, "blocked": 0 }
    }
  ],
  "tasksByStatus": {
    "pending": [{ "id": "T001", "title": "...", "assignee": "...", "stage": "..." }],
    "in_progress": [],
    "completed": [],
    "blocked": []
  },
  "roleWorkload": {
    "developer": 3,
    "tester": 1
  }
}
```

### Step 4: Commit

```bash
git add docs/project/tasks.yaml docs/project/board.json
git commit -m "chore: update project board"
```

## Notes

- `board.html` reads `board.json` dynamically via fetch — it does not need to be regenerated or committed
- Keep commits small and frequent — every board update is its own commit
- The human can open `docs/project/board.html` in a browser at any time to see the latest state (after refreshing)
