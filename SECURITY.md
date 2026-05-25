# Security

This project is intended to run only on your own machine, bound to localhost.

Do not expose this service to your LAN, the public internet, or an untrusted
machine. It accepts text over HTTP and shells out to the locally installed
Claude Code CLI.

The shim adds a small safety prompt and calls Claude Code with:

- `--tools ""`
- `--disable-slash-commands`
- `--no-chrome`
- `--no-session-persistence`

That keeps the cleanup call focused on text transformation instead of agentic
computer use. This is still not a security boundary. Treat the localhost API as
trusted local automation.

If you find a security issue, open a private advisory or contact the maintainer
directly rather than filing a public issue with exploit details.
