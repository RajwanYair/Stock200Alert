# Contributing to Stock Alert

Thank you for your interest in contributing!

## Development Setup

1. Follow the [README](README.md) setup instructions
2. Run `dart run build_runner watch --delete-conflicting-outputs` for live code generation
3. Run `flutter test` before submitting any PR

## Code Standards

- Follow Dart/Flutter conventions and the project's `analysis_options.yaml`
- Run `flutter analyze` and `dart format .` before committing
- Domain logic must be pure (no Flutter dependencies)
- Write tests for all domain logic changes (SMA, cross-up, alert state)
- Never commit API keys or secrets

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes with clear, atomic commits
3. Ensure all tests pass and `flutter analyze` is clean
4. Update documentation if your change affects public APIs or behavior
5. Submit a PR with a clear description of what and why

## Reporting Issues

Use GitHub Issues. Include:
- Steps to reproduce
- Expected vs actual behavior
- Platform (Android/Windows) and Flutter version
- Logs if available
