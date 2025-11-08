# Automatic Versioning and Release Notes

This project uses automatic semantic versioning and release notes generation based on Angular commit message conventions.

## How It Works

When you push commits to the `main` branch, the GitHub Actions workflow automatically:

1. **Analyzes commit messages** since the last tag to determine the version bump
2. **Creates a new semantic version tag** (e.g., v1.0.0, v1.1.0, v2.0.0)
3. **Generates release notes** from the commit messages
4. **Creates a GitHub release** with the generated notes
5. **Builds and publishes the Docker image** with version tags†

† Note: When triggered by a push to main, the Docker image will be tagged with branch-based tags (e.g., `main`) and commit SHA. The semantic version tags (e.g., `v1.0.0`) will be applied when the workflow is subsequently triggered by the tag push event.

## Commit Message Convention

This project follows the [Angular commit message convention](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit). Your commit messages should be structured as follows:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

- **feat**: A new feature (triggers a **minor** version bump, e.g., 1.0.0 → 1.1.0)
- **fix**: A bug fix (triggers a **patch** version bump, e.g., 1.0.0 → 1.0.1)
- **docs**: Documentation only changes (no version bump)
- **style**: Changes that don't affect the code meaning (formatting, etc.) (no version bump)
- **refactor**: Code change that neither fixes a bug nor adds a feature (no version bump)
- **perf**: Performance improvements (triggers a **patch** version bump)
- **test**: Adding or updating tests (no version bump)
- **chore**: Changes to build process or auxiliary tools (no version bump)
- **ci**: Changes to CI configuration files and scripts (no version bump)

**Note**: Only commits with `feat:`, `fix:`, `perf:`, or breaking changes will trigger version bumps. Other commit types will not create a new version.

### Breaking Changes

To trigger a **major** version bump (e.g., 1.0.0 → 2.0.0), include `BREAKING CHANGE:` in the commit footer or add `!` after the type/scope:

```
feat!: change API endpoint structure

BREAKING CHANGE: The API endpoint structure has been modified to improve consistency.
```

### Examples

#### Minor version bump (new feature):
```
feat: add support for custom WARP settings

Added environment variables to configure WARP settings such as connection timeout.
```

#### Patch version bump (bug fix):
```
fix: resolve connection retry loop issue

Fixed a bug where the connection retry logic would enter an infinite loop
when the WARP daemon was unresponsive.
```

#### Major version bump (breaking change):
```
feat!: change environment variable names for clarity

BREAKING CHANGE: Renamed WARP_TOKEN to CLOUDFLARE_TOKEN and VNET to CLOUDFLARE_VNET
for better consistency with Cloudflare's naming conventions.
```

## Release Notes Format

The automatically generated release notes will include:

- **Version number** (e.g., v1.2.0)
- **Date** of the release
- **Grouped commit messages** by type:
  - 🚀 Features (feat)
  - 🐛 Bug Fixes (fix)
  - 📚 Documentation (docs)
  - ⚡ Performance (perf)
  - And other types as applicable

## Manual Releases

If you need to create a manual release or bypass the automatic versioning:

1. Create a tag manually: `git tag -a v1.0.0 -m "Release v1.0.0"`
2. Push the tag: `git push origin v1.0.0`
3. The workflow will detect the tag and build/publish the Docker image

## First Release

For the very first release when there are no existing tags:

1. The workflow will create `v0.1.0` as the initial version
2. Subsequent commits will bump the version according to the commit types

## Version Defaults

- **No default bump**: If no conventional commits that trigger version bumps are found (feat, fix, perf, or breaking changes), no new version will be created
- **Conventional commits only**: Only commits following the Angular convention with bump-triggering types will create new versions
