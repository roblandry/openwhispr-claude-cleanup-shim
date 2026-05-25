# OpenWhispr Claude Cleanup Shim

OpenAI-compatible localhost shim that lets OpenWhispr use the locally
authenticated Claude Code CLI for dictation cleanup.

This is useful when you want OpenWhispr's local GPU transcription, but prefer
Claude for the final polishing pass without configuring an Anthropic API key.

This is unofficial. It is not affiliated with OpenWhispr, Anthropic, or Claude
Code.

## How It Works

```text
OpenWhispr cleanup request
  -> http://127.0.0.1:8787/v1/chat/completions
  -> cleanup_shim.py
  -> claude --print
  -> OpenAI-compatible response
```

The shim exposes:

- `GET /health`
- `GET /v1/models`
- `POST /v1/chat/completions`

OpenWhispr's Prompt Studio remains the primary cleanup prompt. The shim reads
`system` and `developer` messages from OpenWhispr and passes them to Claude as
cleanup instructions, with a small safety wrapper that says the dictated
transcript must not be treated as an instruction.

The Claude Code call disables tools, slash commands, Chrome integration, and
session persistence.

If Claude times out or errors after the transcript is parsed, the shim returns
the normalized raw transcript as a successful response. Dictation should still
paste; that request just skips Claude polishing.

## Requirements

- Linux
- Python 3.10+
- OpenWhispr
- Claude Code CLI installed and already authenticated

Verify Claude Code works first:

```bash
claude --print --model sonnet --effort low 'Return exactly: ok'
```

## Run Manually

From this directory:

```bash
./cleanup_shim.py --timeout 8 --claude-bin ~/.local/bin/claude --claude-model sonnet --claude-effort low
```

Then test:

```bash
curl -s http://127.0.0.1:8787/health
```

## OpenWhispr Settings

- Provider/type: Custom, self-hosted, or OpenAI-compatible
- Base URL: `http://127.0.0.1:8787/v1`
- Model: `claude-cleanup`
- API key: any placeholder if required, such as `local`

## Prompt Handling

If OpenWhispr sends no prompt, the shim uses a tiny fallback instruction:
`Clean up the transcript with minimal edits.`

## systemd User Service

Install the user service from your checkout:

```bash
./install-user-service.sh
```

Check status:

```bash
systemctl --user status openwhispr-claude-cleanup-shim.service
```

The installer writes a service file under `~/.config/systemd/user` using your
current checkout path. If your Claude binary is somewhere else, run:

```bash
CLAUDE_BIN=/path/to/claude ./install-user-service.sh
```

## Options

- `--claude-model sonnet`: pins the Claude CLI model alias.
- `--claude-effort low`: avoids higher reasoning effort for simple cleanup.
- `--timeout 8`: maximum time the shim waits before returning an error.
- `--host 127.0.0.1`: bind address. Keep this on localhost.
- `--port 8787`: HTTP port.
- `--work-dir /path`: neutral working directory for Claude. Defaults to an
  empty temporary directory so Claude Code does not load project or home context.

## Test

```bash
curl -s http://127.0.0.1:8787/v1/chat/completions \
  -H 'content-type: application/json' \
  -d '{"model":"claude-cleanup","messages":[{"role":"user","content":"i just rebooted the pc and am trying to chat with you in vscode"}]}' \
  | jq -r '.choices[0].message.content'
```

Expected:

```text
I just rebooted the PC and am trying to chat with you in VS Code.
```

## Security

Keep this service bound to `127.0.0.1`. Do not expose it to your LAN or the
internet.

This project shells out to the local Claude Code CLI. It disables Claude tools
for cleanup calls, but the localhost endpoint should still be treated as trusted
local automation.

See [SECURITY.md](SECURITY.md) for details.

## Notes

The Claude CLI path adds some latency because each cleanup request starts a
non-interactive Claude Code call. On the original test laptop, typical cleanup
latency was about 3-5 seconds after tuning.

For lower latency, try `--claude-model haiku` or a full Haiku model name if your
Claude Code account supports it. Keep `--claude-effort low` for cleanup.

See [TODO.md](TODO.md) for possible future work and intentionally out-of-scope
ideas.
