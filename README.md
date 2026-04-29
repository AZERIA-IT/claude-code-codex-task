# claude-code-codex-task

> Stop using Opus as a worker. Delegate execution-heavy Claude Code subtasks to Codex CLI while keeping Claude Code's native subagent completion notifications.

`claude-code-codex-task` installs a `codex-task` subagent for Claude Code.

The parent Claude session keeps the judgment work: orchestration, product decisions, architecture, review.
Codex does the execution work: reading files, editing code, running tests, debugging build errors, and reporting back.

The wrapper stays alive until Codex finishes, so Claude Code still fires the normal task-completion notification in the parent thread.

## Why this exists

Claude Code is excellent as an agentic coding interface.

But expensive models should not spend most of their time doing mechanical repo work:

- reading files
- scanning logs
- running tests
- fixing small build errors
- updating docs
- repeating patch/test loops

The goal is simple:

```text
Opus/Sonnet = orchestration and judgment
Codex CLI   = execution-heavy work
codex-task  = thin lifecycle adapter
```

The missing piece was lifecycle handling.

The existing Codex integration can start background jobs, but if the wrapper exits immediately, the parent Claude Code session may not get a reliable completion event. This repo fixes that by making the wrapper long-lived: it starts the Codex job, waits until the terminal state, fetches the result, then exits normally.

## Architecture

```text
Claude Code parent session

Parent agent: Opus or Sonnet
        │
        │  delegates to subagent_type: codex-task
        ▼
Sonnet wrapper subagent
        │
        │  1. starts Codex in background
        │  2. waits with codex-companion status --wait
        │  3. fetches final result
        ▼
Codex CLI worker
        │
        │  reads files, edits code, runs commands, tests, debugs
        ▼
Wrapper returns ===CODEX_DONE=== + output
        │
        ▼
Claude Code parent receives normal subagent completion notification
```

## Install

```bash
git clone https://github.com/AZERIA-IT/claude-code-codex-task.git
cd claude-code-codex-task
chmod +x install.sh
./install.sh
```

Or one-liner after reviewing the install script:

```bash
curl -sL https://raw.githubusercontent.com/AZERIA-IT/claude-code-codex-task/main/install.sh | bash
```

Review first:

```bash
curl -sL https://raw.githubusercontent.com/AZERIA-IT/claude-code-codex-task/main/install.sh | less
```

## Prerequisites

- Claude Code installed and configured
- Codex CLI available
- OpenAI/Codex access configured
- The OpenAI Codex Claude Code plugin installed, with `codex-companion.mjs` available under `~/.claude/plugins/`

## Usage

From Claude Code:

```text
Use the codex-task subagent to:
Refactor /path/to/project/src/api.py to use async/await throughout.
Run the relevant tests.
Fix any failures you introduce.
Report the final diff and test result.
```

The parent agent gets one completion notification after Codex finishes.

## When to use `codex-task`

Good fits:

- repo search
- implementation tasks
- test writing
- test failures
- build debugging
- dependency cleanup
- documentation updates
- batch refactors
- terminal-heavy investigation

Bad fits:

- product judgment
- architecture decisions
- ambiguous strategy questions
- MCP-only workflows inside Claude Code
- tasks that need Gmail, Calendar, Drive, browser, or other Claude-only tools

Rule of thumb:

> If the task is “go do this in the repo and report back”, use Codex.
> If the task is “think deeply and decide”, keep it in Claude.

## Why not just use Codex directly?

You can.

This repo is useful when you want to keep the Claude Code parent session as your orchestrator and still use Claude Code's subagent workflow.

Without this wrapper, the parent may have to manually track or poll Codex background jobs. With this wrapper, the subagent remains alive until Codex completes, then Claude Code's normal task completion flow handles the notification.

## Cost profile

The wrapper is a small Sonnet subagent job.

Codex performs the expensive execution work under your OpenAI/Codex setup, so the repetitive repo work does not burn Anthropic tokens.

This is especially useful on coding-heavy days where the parent model would otherwise spend tokens on file reads, logs, test loops, and small patches.

## Swarm pattern

You can launch multiple `codex-task` subagents in parallel:

```text
Launch 3 parallel codex-task subagents:

1. Analyze /project/src/auth/ and write findings to /tmp/auth.md
2. Analyze /project/src/billing/ and write findings to /tmp/billing.md
3. Analyze /project/src/notifications/ and write findings to /tmp/notifications.md

After all 3 complete, read the outputs and synthesize the result.
```

Wall-clock time becomes roughly the slowest individual Codex job, not the sum of all jobs.

See:

- [`examples/single-task.md`](examples/single-task.md)
- [`examples/swarm-3-tasks.md`](examples/swarm-3-tasks.md)

## Limitations

- Codex does not get Claude Code MCP tools.
- Codex does not get Claude Code skills or memory.
- The parent waits for the final result, not streamed partial output.
- Very long jobs can hit the wrapper timeout.
- You should still review diffs before committing anything.

## Security

Read `install.sh` before running it.

The installer copies the `codex-task` agent definition into `~/.claude/agents/` and resolves the local `codex-companion.mjs` path.

## License

MIT. See [`LICENSE`](LICENSE).

## About AZERIA-IT

AZERIA-IT builds AI engineering tooling and applied AI products.

- LinkedIn: [Mohamed Abdelouahed](https://www.linkedin.com/in/mohamed-abdelouahed/)
- Website: [AZERIA-IT](https://www.azeria-it.com/)
