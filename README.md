# claude-code-codex-task

> Reliable Claude Code sub-agent that wraps the Codex CLI with proper async notification handling.

## What it does

`codex-task` is a Claude Code sub-agent (model: Sonnet) that acts as a thin wrapper around the Codex CLI. It launches a Codex job in the background, polls it until completion using `--wait` native blocking, and returns the result to the parent agent with a standardized `===CODEX_DONE===` prefix — giving the parent thread a clean, reliable notification.

## Why it exists

The openai/codex Claude Code plugin ships with a `--background` flag that detaches the job and returns a task ID. But the parent agent receives no notification when the job finishes. The only reliable pattern is to poll `codex-companion status --wait` in a loop from within a sub-agent that stays alive until the terminal state is reached.

This repo packages that polling loop as a drop-in sub-agent definition.

## Architecture

```
Parent Claude Code (Opus/Sonnet)
        │
        │  Agent invocation (subagent_type: codex-task)
        ▼
  Wrapper Sonnet 4.6 sub-agent
  ┌─────────────────────────────────────┐
  │ 1. Launch:  codex-companion task   │
  │             --background --write   │
  │ 2. Poll:    codex-companion status │
  │             <task-id> --wait --json│
  │             (loop until terminal) │
  │ 3. Result:  codex-companion result │
  │             <task-id>             │
  └─────────────────────────────────────┘
        │
        │  ===CODEX_DONE=== + result text
        ▼
  Parent thread (notification via CC task system)
        │
        ▼
  Codex CLI (GPT-4o / full filesystem access)
  - reads/writes files
  - runs shell commands
  - git operations
  - NO access to CC MCPs or CC skills
```

## Install

```bash
git clone https://github.com/AZERIA-IT/claude-code-codex-task.git
cd claude-code-codex-task
chmod +x install.sh && ./install.sh
```

Or one-liner (once the repo is public):

```bash
curl -sL https://raw.githubusercontent.com/AZERIA-IT/claude-code-codex-task/main/install.sh | bash
```

**Prerequisites:**
- Claude Code installed and configured
- Codex CLI plugin installed in Claude Code (`openai-codex` plugin)
- OpenAI or ChatGPT account with Codex access

## Usage

From Claude Code, invoke the sub-agent:

```
Use the codex-task subagent to: refactor /path/to/src/utils.py to use async/await throughout, run the test suite, and report the results.
```

The parent agent gets back a single notification containing the full Codex output once done.

## Cost analysis

- **Wrapper cost**: ~$0.02–0.10 per task on Sonnet 4.6 (the polling wrapper only; very few tokens)
- **Codex job cost**: charged against your OpenAI / ChatGPT subscription quota (not Anthropic quota)
- **Key benefit**: Codex does the heavy lifting (file reads, edits, shell commands) using OpenAI quota, preserving your Anthropic rate limits for reasoning and conversation.

## Swarm pattern

Run multiple Codex tasks in parallel by launching N `codex-task` sub-agents simultaneously:

```
Launch 3 parallel codex-task subagents:
1. Analyze /src/module_a/ and write a summary to /tmp/summary_a.md
2. Analyze /src/module_b/ and write a summary to /tmp/summary_b.md  
3. Analyze /src/module_c/ and write a summary to /tmp/summary_c.md
Then read all three summaries and synthesize.
```

Each sub-agent is independent. The parent resumes once all three complete.

## Limitations

- Codex runs in an isolated sandbox with filesystem and shell access only
- No access to Claude Code MCPs (Gmail, Calendar, Drive, OSINT tools, etc.)
- No access to Claude Code skills or memory systems
- Codex cannot stream back partial results — parent waits for full completion
- Maximum recommended wait: ~40 minutes (10 polling iterations × ~4 min each)

## License

MIT — see [LICENSE](LICENSE)

---

## About AZERIA-IT

AZERIA-IT builds AI-powered tools for urban planning and document analysis.

- LinkedIn: [TODO — add LinkedIn URL]
- Website: [TODO — add website URL]
