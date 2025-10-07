# Contributing to Celo Org Reusable Workflows

Thank you for your interest in contributing to this repository! This document outlines the guidelines for contributing to ensure consistency and quality.

## Commit Message Format

This repository uses [Conventional Commits](https://www.conventionalcommits.org/) for automated semantic versioning. Your commit messages must follow this format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

- **feat**: A new feature (triggers minor version bump)
- **fix**: A bug fix (triggers patch version bump)
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc.)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance (triggers patch version bump)
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Breaking Changes

To trigger a major version bump, add `BREAKING CHANGE:` in the footer or add `!` after the type/scope:

```
feat!: remove support for deprecated workflow parameter
```

or

```
feat: add new required parameter

BREAKING CHANGE: The `old-parameter` has been removed and replaced with `new-parameter`
```

### Examples

```bash
# Feature additions (minor version bump)
feat: add support for multi-arch Docker builds
feat(terraform): add support for Terraform 1.6

# Bug fixes (patch version bump)
fix: correct permission requirements in docker-build workflow
fix(npm): resolve authentication issues with Akeyless

# Documentation updates (no version bump)
docs: update README with new workflow examples
docs(terraform): add troubleshooting section

# Breaking changes (major version bump)
feat!: require Node.js 20+ for all workflows
```

## Development Process

1. **Create a feature branch** from `release` for your changes
2. **Make your changes** following the commit message format above
3. **Test your changes** thoroughly
4. **Create a pull request** to `release`
5. **After merge**, changes will be automatically released when pushed to the `release` branch

## Release Process

This repository uses automated semantic versioning:

- Commits are analyzed to determine the next version number
- Releases are triggered only from the `release` branch
- Tags follow the format `vX.X.X` (e.g., `v3.1.0`)
- Release notes are automatically generated from commit messages

## Questions?

If you have questions about contributing, please open an issue for discussion.