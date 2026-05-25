# TODO / Roadmap

This repo should stay small. Its job is to make Claude Code OAuth look like an
OpenAI-compatible cleanup endpoint for OpenWhispr.

Avoid turning it into a general AI gateway unless real usage proves that is
needed.

## Good Next Steps

- Add lightweight tests for:
  - `/health`
  - `/v1/models`
  - `/v1/chat/completions`
  - system/developer prompt extraction
  - raw-transcript fallback on Claude timeout/error
  - request body size cap
- Add structured stderr logging for:
  - request latency
  - selected Claude model
  - timeout/error fallback events
  - whether OpenWhispr sent a prompt
- Add a short troubleshooting section for:
  - Claude auth failures
  - timeout fallback behavior
  - OpenWhispr custom endpoint settings
  - systemd user service status/logs
- Test `--claude-model haiku` or a full Haiku model name against the real shim
  path and document whether it is faster/reliable enough.
- Decide whether the default timeout should stay at 8 seconds or be slightly
  lower now that raw fallback exists.
- Migrate any local installs from the old service name
  `openwhispr-cleanup-shim.service` to the public repo service name
  `openwhispr-claude-cleanup-shim.service`.

## Maybe Later

- Add a small provider boundary around the Claude CLI call so future providers
  can be added without rewriting the HTTP/OpenAI-compatible layer.
- Add an optional local/offline provider only if a local cleanup model is found
  that preserves wording reliably.
- Add streaming only if OpenWhispr actually requests and consumes streamed
  OpenAI-compatible responses.

## Probably Not This Repo

- Prompt profiles. OpenWhispr Prompt Studio should own cleanup behavior.
- Context-aware cleanup modes. That belongs in OpenWhispr or user prompts, not
  this shim.
- OpenAI, OpenRouter, or Anthropic API-key support. OpenWhispr already supports
  normal API providers; this repo's unique value is Claude Code OAuth bridging.
- Broad multi-provider routing. That is a different project.

