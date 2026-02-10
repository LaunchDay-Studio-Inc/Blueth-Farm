# Branch Protection Recommendations

This document outlines recommended branch protection rules for the Blueth Farm repository to ensure code quality and prevent accidental breaking changes.

## Recommended Settings for `main` Branch

### Protection Rules

**Require a pull request before merging:**
- ✅ Required
- Require approvals: **1 minimum**
- Dismiss stale pull request approvals when new commits are pushed: ✅ Yes
- Require review from Code Owners: Optional (when CODEOWNERS file is added)

**Require status checks to pass before merging:**
- ✅ Required
- Require branches to be up to date before merging: ✅ Yes

**Required status checks:**
- `GDScript Linting`
- `Validate Godot Project`
- `Run Unit Tests (GUT)`
- `Test Linux Export`
- `CI Summary`

**Require conversation resolution before merging:**
- ✅ Yes - All review comments must be resolved

**Require signed commits:**
- Optional (recommended for core maintainers)

**Require linear history:**
- ✅ Yes - Prevent merge commits, require rebase or squash

**Do not allow bypassing the above settings:**
- ✅ Yes - Even administrators must follow these rules

**Restrict who can push to matching branches:**
- ⚠️ Enable if you want to restrict direct pushes to main
- Alternatively, you can allow administrators to bypass temporarily

### Additional Recommendations

**Lock branch:**
- ❌ No - Keep branch active for merges

**Allow force pushes:**
- ❌ No - Prevent history rewriting

**Allow deletions:**
- ❌ No - Prevent accidental branch deletion

## Recommended Settings for `develop` Branch

Apply similar protections but with more relaxed requirements:

**Require a pull request before merging:**
- ✅ Required
- Require approvals: **0-1** (can be 0 for faster iteration)

**Require status checks to pass before merging:**
- ✅ Required
- CI must pass, but doesn't need to be up-to-date

**Required status checks:**
- `GDScript Linting` (can be set to non-blocking/warning)
- `Validate Godot Project`
- `Run Unit Tests (GUT)`

## Feature Branch Workflow

1. **Create feature branch** from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/my-feature
   ```

2. **Make changes** and commit regularly:
   ```bash
   git add .
   git commit -m "feat(scope): description"
   ```

3. **Push branch** and create PR:
   ```bash
   git push origin feature/my-feature
   ```

4. **Wait for CI** to pass:
   - All tests must pass
   - Linting should pass (warnings acceptable initially)
   - Project must validate and export

5. **Request review** from at least one team member

6. **Merge** after approval and CI success

## CI/CD Pipeline Overview

### Continuous Integration (CI)

Runs on every push to `main`/`develop` and all pull requests:

1. **Linting** - GDScript code quality checks
2. **Validation** - Project structure and resource files
3. **Unit Tests** - Automated testing with GUT framework
4. **Build Test** - Verify Linux export works

### Continuous Deployment (CD)

Runs on version tags (`v*`):

1. **Multi-Platform Builds**:
   - Linux (x86_64)
   - Windows (x86_64)
   - macOS (Universal)
   - Web (HTML5)

2. **GitHub Release Creation**:
   - Automated release notes
   - All platform artifacts attached
   - Version metadata

## Setting Up Branch Protection (Repository Maintainers)

### Via GitHub Web Interface

1. Go to repository **Settings**
2. Navigate to **Branches** (left sidebar)
3. Click **Add branch protection rule**
4. Configure as outlined above

### Using GitHub CLI (Optional)

```bash
# Protect main branch
gh api repos/LaunchDay-Studio-Inc/Blueth-Farm/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["GDScript Linting","Validate Godot Project","Run Unit Tests (GUT)","Test Linux Export","CI Summary"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

## Testing CI Locally (Optional)

You can test parts of the CI pipeline locally before pushing:

### Run linting locally:
```bash
cd game
pip install gdtoolkit
gdlint scripts/**/*.gd
gdformat --check scripts/**/*.gd
```

### Run tests locally (requires Godot):
```bash
cd game
godot --headless --script addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json -gexit
```

### Test export locally:
```bash
cd game
godot --headless --export-release "Linux/X11" export/linux/blueth-farm.x86_64
```

## Troubleshooting CI Failures

### Linting Failures
- Run `gdformat scripts/**/*.gd` to auto-format
- Check `.gdlintrc` for configured rules
- Some warnings can be disabled if needed

### Test Failures
- Run tests locally to debug
- Check test output in CI artifacts
- Ensure all autoloads are properly initialized in tests

### Build Failures
- Verify `export_presets.cfg` is committed
- Check that all resources are properly configured
- Ensure templates are compatible with Godot version

### Import Failures
- Validate `project.godot` syntax
- Check for malformed `.tres` or `.tscn` files
- Ensure all referenced resources exist

## Monitoring CI/CD

### GitHub Actions Dashboard

View pipeline status at:
```
https://github.com/LaunchDay-Studio-Inc/Blueth-Farm/actions
```

### Status Badges (for README)

Add to README.md:
```markdown
![CI Status](https://github.com/LaunchDay-Studio-Inc/Blueth-Farm/workflows/CI%20-%20Build%20and%20Test/badge.svg)
[![Release](https://github.com/LaunchDay-Studio-Inc/Blueth-Farm/workflows/Release%20-%20Multi-Platform%20Build/badge.svg)](https://github.com/LaunchDay-Studio-Inc/Blueth-Farm/releases)
```

## Release Process

### Creating a Release

1. **Ensure all tests pass** on `main` branch

2. **Create and push version tag**:
   ```bash
   git checkout main
   git pull origin main
   git tag -a v0.1.0 -m "Release v0.1.0 - Initial prototype"
   git push origin v0.1.0
   ```

3. **CI automatically builds** all platforms

4. **GitHub Release is created** with all artifacts

5. **Update changelog** and announce release

### Version Numbering

Follow semantic versioning: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes or major features
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes and minor improvements

Examples:
- `v0.1.0` - Initial prototype
- `v0.2.0` - New features added
- `v0.2.1` - Bug fixes
- `v1.0.0` - First stable release

## Questions?

If you have questions about CI/CD or branch protection:
- Open a GitHub Discussion
- Ask in development channels
- Review workflow files in `.github/workflows/`

---

**Last Updated:** February 10, 2026
