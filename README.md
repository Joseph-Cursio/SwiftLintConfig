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

The path is relative, so this repo must be checked out next to the project.

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
