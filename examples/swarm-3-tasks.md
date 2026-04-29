# Swarm Pattern: 3 Parallel Tasks

Launch multiple codex-task sub-agents simultaneously for maximum throughput.

## From Claude Code chat

```
I need to analyze 3 modules in parallel. Launch 3 codex-task subagents simultaneously:

Subagent 1: Read all Python files under /project/src/auth/. 
Count total lines, list all public functions, identify any TODO comments.
Write results to /tmp/swarm_auth.md

Subagent 2: Read all Python files under /project/src/billing/.
Count total lines, list all public functions, identify any TODO comments.  
Write results to /tmp/swarm_billing.md

Subagent 3: Read all Python files under /project/src/notifications/.
Count total lines, list all public functions, identify any TODO comments.
Write results to /tmp/swarm_notifications.md

After all 3 complete, read the 3 output files and produce a combined summary.
```

## What happens

1. Parent launches 3 codex-task sub-agents in parallel (run_in_background: true for each)
2. All 3 Codex jobs run concurrently — total wall time ≈ slowest single job
3. Parent receives 3 notifications (in any order) as each completes
4. After all 3 done, parent synthesizes the results

## Cost

- 3× wrapper cost (~$0.06–0.30 total on Sonnet)
- 3× Codex jobs running in parallel (OpenAI quota, not Anthropic)
- Wall-clock time: same as 1 job (parallel execution)

## When to use swarm

- Independent analysis tasks across multiple modules/files
- Parallel refactoring of unrelated components  
- Running tests in separate environments simultaneously
- Generating multiple variants of a solution for comparison
