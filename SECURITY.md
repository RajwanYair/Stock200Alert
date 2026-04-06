# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. Email the maintainers directly (or use GitHub's private vulnerability reporting)
3. Include a description of the vulnerability and steps to reproduce
4. Allow reasonable time for a fix before public disclosure

## Scope

- API key exposure
- Injection vulnerabilities in data parsing
- Insecure storage of credentials
- Any issue that could compromise user data

## Security Best Practices (for contributors)

- Never commit API keys, tokens, or secrets
- Use `flutter_secure_storage` for sensitive data at runtime
- Use `.env` files for local development (listed in `.gitignore`)
- Use GitHub Secrets for CI/CD
- Validate and sanitize all external input (API responses, user input)
