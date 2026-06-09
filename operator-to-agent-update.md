# Operator-to-Agent Update

Date: 2026-06-09
Topic: provenance boundaries for RYZ-related work

Keep original RYZ work separate from externally derived work.

## Categories

- ORIGINAL_RYZ: original compiler, runtime, language, orchestration, and project code.
- WRAPPER_CLI: code that calls an existing command as a separate process.
- BEHAVIOR_CLONE: code written from observed behavior, docs, tests, or man-page behavior.
- BINDING: interface to an existing library or system component.
- SOURCE_DERIVED_PORT: code copied, translated, or closely derived from outside source.
- DISTRO_AGGREGATE: separate components shipped together.
- UNKNOWN_REVIEW_REQUIRED: unclear origin or unclear obligations.

## Rules

1. Do not mix SOURCE_DERIVED_PORT work into ORIGINAL_RYZ paths.
2. Do not label source translation as native work.
3. Do not label a wrapper as a port.
4. Prefer WRAPPER_CLI or BEHAVIOR_CLONE when covering command behavior.
5. Keep BINDING work tagged with origin and license.
6. Keep aggregate metadata separate from original RYZ policy.
7. Escalate UNKNOWN_REVIEW_REQUIRED before merge.
8. Record the compiler or transpiler used for generated artifacts.

## Required ledger fields

- component_name
- origin_project
- origin_package
- origin_license
- conversion_type
- source_copied_yes_no_unknown
- translated_from_source_yes_no_unknown
- links_to_third_party_library_yes_no_unknown
- ships_original_binary_yes_no_unknown
- ships_modified_binary_yes_no_unknown
- public_release_ok_yes_no_review
- required_obligation
- notes

## Suggested files

- PACKAGE_LICENSE_LEDGER.tsv
- THIRD_PARTY_NOTICES.md
- SOURCE_OFFER.md
- licenses/

## Short doctrine

Wrappers and behavior clones are usually the clean path. Source-derived ports and library-linking require explicit tracking and review. Keep original RYZ work separated from source-derived ports.
