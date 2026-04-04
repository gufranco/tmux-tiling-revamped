# Security Policy

## Supported Versions

| Version | Supported |
|:--------|:---------:|
| 2.x     | Yes       |
| 1.x     | No        |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly.

**Do not open a public issue.**

Email: security@gufranco.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if you have one)

## Response Timeline

- Acknowledgment: within 48 hours
- Initial assessment: within 7 days
- Fix release: within 30 days for confirmed vulnerabilities

## Scope

Security issues for this project include:
- Command injection via tmux options or user input
- Arbitrary code execution through crafted layout names or preset values
- Information disclosure through log files or tmux options
- Denial of service through resource exhaustion (infinite loops, memory leaks)

Input sanitization issues in `marks.sh`, `presets.sh`, and `scratchpad.sh` are in scope.
