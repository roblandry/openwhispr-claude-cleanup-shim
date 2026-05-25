# Agent Notes

This repo is intentionally small.

Its purpose is to expose an OpenAI-compatible localhost cleanup endpoint for
OpenWhispr, backed by the locally authenticated Claude Code CLI. The unique
value is Claude Code OAuth/subscription bridging, not building a general AI
gateway.

## Design Boundaries

- Keep OpenWhispr's Prompt Studio as the source of cleanup behavior.
- The shim may add a small non-negotiable safety wrapper, but should not own
  prompt profiles or dictation modes.
- Keep the default bind address on `127.0.0.1`.
- Do not expose this service to LAN/WAN.
- Keep Claude Code tool use disabled for cleanup calls:
  - `--tools ""`
  - `--disable-slash-commands`
  - `--no-chrome`
  - `--no-session-persistence`
- Run Claude from a neutral working directory so it does not load home/project
  context for dictation cleanup.
- If Claude fails after the transcript has been parsed, return the normalized
  raw transcript as HTTP `200`. Dictation text should not be lost because the
  polishing backend hiccupped.

## Preferred Scope

Good changes:

- Small compatibility fixes for OpenAI-style request/response handling.
- Reliability improvements that preserve dictated text.
- Lightweight tests.
- Structured stderr logging for latency and fallback events.
- Documentation that helps users configure OpenWhispr and systemd.
- Measured latency tuning for Claude model aliases such as `sonnet` vs `haiku`.

Avoid unless real usage proves a need:

- Multi-provider routing.
- Prompt profile systems.
- Context-aware dictation modes.
- OpenAI/OpenRouter/Anthropic API-key providers.
- Browser automation.
- Streaming support unless OpenWhispr actually consumes streamed responses.

Those are reasonable ideas for a larger dictation gateway, but they are probably
not this repo.

## Verification

Run these before committing:

```bash
python3 -m py_compile cleanup_shim.py
bash -n install-user-service.sh
git diff --check
```

Useful manual checks:

```bash
./cleanup_shim.py --port 8788 --claude-bin /bin/false
```

Then POST to `/v1/chat/completions` and confirm the response is HTTP `200` with
the normalized raw transcript plus `cleanup_error`.

For a normal Claude path, test with:

```bash
curl -sS http://127.0.0.1:8787/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{"model":"claude-cleanup","messages":[{"role":"system","content":"Clean lightly and return only the transcript."},{"role":"user","content":"i dont want it to say specifically or to clarify unless i actually said those words"}]}'
```

Expected output content:

```text
I don't want it to say "specifically" or "to clarify" unless I actually said those words.
```

## Local Context

The original local install may still use the older service name
`openwhispr-cleanup-shim.service`. The public repo documents
`openwhispr-claude-cleanup-shim.service`.

Do not assume either service name is wrong without checking the user's current
systemd status.

