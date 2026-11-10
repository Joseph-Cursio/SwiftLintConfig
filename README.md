# SwiftLintConfig

One SwiftLint configuration for every Swift project: one decision per rule,
with no per-project rule settings.

## Adopting it

A project's `.swiftlint.yml` contains only the parent link and its paths:

```yaml
parent_config: ../SwiftLintConfig/.swiftlint.yml
included:
  - Sources
  - Tests
excluded:
  - .build
```

Paths stay local because which folders hold code is a fact about the project.
Everything else (opt-in rules, analyzer rules, settings) comes from here.

The path is relative, so this repo must be checked out next to the project:

```sh
git clone https://github.com/Joseph-Cursio/SwiftLintConfig.git ../SwiftLintConfig
```

If it's missing, SwiftLint only warns ("A local configuration … was not
found") and lints with its own defaults, which contradict some of these rules
(e.g. `trailing_comma`). Lint with `--strict` in CI so that fails.

### In CI (GitHub Actions)

Check out the project and this repo side by side, and lint from the project:

```yaml
lint:
  runs-on: ubuntu-latest
  container: ghcr.io/realm/swiftlint:0.65.1
  defaults:
    run:
      working-directory: MyProject
  steps:
    - uses: actions/checkout@v4
      with:
        path: MyProject
    - uses: actions/checkout@v4
      with:
        repository: Joseph-Cursio/SwiftLintConfig
        path: SwiftLintConfig
    - run: swiftlint lint --strict --reporter github-actions-logging
```

An Xcode build phase that lints should skip, with a warning, when
`${SRCROOT}/../SwiftLintConfig/.swiftlint.yml` doesn't exist, rather than fail
the build on the default rules.

## Commands, from a project's root

```sh
swiftlint lint
../SwiftLintConfig/scripts/swiftlint-analyze.sh
swiftlint --fix --config .swiftlint.yml --config ../SwiftLintConfig/.swiftlint.nofix.yml
```

- **`swiftlint-analyze.sh`** runs the analyzer rules, which `swiftlint lint`
  never runs. It builds with a compiler log, then runs each rule separately
  to avoid a SwiftLint 0.65.1 crash.
- **`.swiftlint.nofix.yml`** keeps rules with broken correctors out of `--fix`.
  They're still reported by `lint`.

## Changing a rule

A rule that doesn't fit a project is a decision for every project. Change it
here, and record why in the SwiftLint Rule Notes (Desirable, Exclusions,
Adjustments, Never Autofix). The ground rule: never turn a rule off, or loosen
it, because it has many violations. Change the code instead.
