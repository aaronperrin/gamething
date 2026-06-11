# Security Policy

## Supported versions

This project is pre-release. Security fixes apply to the default branch until a release policy exists.

## Reporting a vulnerability

Open a private security advisory if available, or contact the repository owner directly.

Do not disclose vulnerabilities publicly before maintainers have had a chance to investigate.

## Security principles

- Treat browser input as untrusted.
- Treat bot output as untrusted until validated against legal choices.
- Treat plugin output as untrusted until validated.
- Treat persisted state as untrusted until decoded and validated.
- Keep simulation authority on the backend.
- Avoid hidden global mutable state.
- Avoid logging secrets or private bot memory unless explicitly marked as safe debug output.

## Current security posture

The project currently contains scaffolding and documentation only. When executable code is added, security review should focus first on:

- API input validation
- safe quantity parsing
- deterministic replay integrity
- avoiding accidental exposure of hidden state
- dependency review
