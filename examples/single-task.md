# Single Task Example

Invoke codex-task for a single focused job.

## From Claude Code chat

```
Use the codex-task subagent to:
Read /path/to/project/src/api.py and /path/to/project/tests/test_api.py.
Identify all functions in api.py that have no corresponding test in test_api.py.
Write a new test file at /path/to/project/tests/test_api_missing.py covering those gaps.
Run pytest tests/test_api_missing.py and report the results.
```

## What happens

1. Parent agent delegates to codex-task sub-agent
2. Wrapper Sonnet launches Codex job in background, gets task-XXXX ID  
3. Wrapper polls status --wait in a loop (each call blocks ~4 min or until done)
4. When Codex completes, wrapper fetches result and returns ===CODEX_DONE=== + output
5. Parent receives notification and can act on the result

## Tips

- Be specific about file paths (absolute paths preferred)
- Include success criteria so Codex knows when it's done
- For large codebases, scope the task to a specific module or directory
