---
name: vellvm-upstream
description: Use when working in this Vellvm fork to add or modify Vellvm functionality, synchronize with official vellvm/vellvm, resolve upstream overlap or merge conflicts, prepare upstream contributions, or update downstream proof projects. Keeps upstream authoritative while preserving local extensions and certified reproducibility.
---

# Vellvm upstream-first development

This is a development fork, not an independent Vellvm implementation. Official `vellvm/vellvm` (`main`) is the authoritative source of Vellvm functionality. The fork must remain a small, tested extension layer, and downstream Rocq proofs must be bound to precise source revisions.

## Invariants

1. **Upstream is the base.** The fork's remote `main` is a clean, fast-forward-only mirror of official upstream `main`. Do not commit local modifications, skills, CI, or thesis code to the mirror branch. Put those on development branches.
2. **Keep proof work moving.** When official Vellvm lacks a necessary parser, semantic, or proof capability, implement a minimal general-purpose local extension and test it. Do not wait for maintainers to accept a PR before proceeding with the thesis.
3. **Prefer upstream's implementation when suitable.** For a capability now present upstream, investigate whether the custom fork patch is redundant. Use the upstream implementation when it satisfies the required semantics, tests, and proof obligations. Never discard a still-needed local capability merely because upstream has a similarly named feature.
4. **No direct upstream pushes.** Never push to `vellvm/vellvm` or change its branches. Upstream contributions require separately scoped branches and an explicitly authorized pull request. No automatic PRs.
5. **No destructive synchronization.** Never force-push, reset away commits, delete branches, rewrite shared history, or overwrite dirty worktrees as part of routine synchronization. Rebase is not the default for a shared, proof-certified integration branch.
6. **Certification is revision-specific.** Record the exact effective Vellvm commit SHA (and downstream pinned dependency revision). A successful merge, build, or upstream PR is not itself a formal proof of correctness.

## Repository topology

Expected roles, not assumed names:

- **Official upstream:** `https://github.com/vellvm/vellvm.git`.
- **Personal fork:** `https://github.com/shikivaahan/vellvm.git`.
- **Fork `main`:** exact upstream mirror; never develop there.
- **Local extension/integration branch:** typically `local/extension` in `~/vellvm-extension`; inspect the actual current branch before modifying anything. Do not assume a remote `extension` branch exists.
- **Downstream:** the Nektar++ verification project and its `prooflib` use a pinned, certified Vellvm revision. They are not a replacement for Vellvm's implementation.

These repositories may be Git worktrees sharing one Git directory. Do not assume it is safe to `git switch main` in the active worktree or that `~/vellvm` and `~/vellvm-extension` are independent clones.

## Before touching Vellvm code or synchronizing

1. Inspect `git status --short --branch`, `git branch -vv`, `git worktree list`, and `git remote -v`. Preserve all uncommitted changes and existing agent work.
2. Verify that the upstream remote actually points to the official Vellvm repository and the fork remote to the personal fork. If an upstream remote is absent, add it only after checking existing names; do not silently repoint a user's remote.
3. Fetch official Vellvm, inspect recent upstream commits and relevant source/tests, and look for existing upstream support before adding a local implementation.
4. Establish the current downstream certified/pinned revision when verification compatibility matters. Determine the actual build/test entry points rather than inventing commands.
5. Work on the existing extension branch or a new scoped feature/integration branch. Keep the clean mirror branch out of all development commits.

## Implementing new Vellvm support

- Search official upstream code, history, tests, issues, and relevant PRs for existing or ongoing solutions.
- Prefer narrow, reusable changes to Vellvm's parser, AST, semantics, memory model, or generic proofs over one-off patches for Nektar++ artifacts.
- Separate parsing support from semantic support and executable validation from formal verification; explicitly identify what remains unsupported or assumed.
- Add a focused regression or minimal reproducible example, plus relevant integration tests. Do not claim a proof based only on a successful parse/build.
- Keep fork-specific changes reviewable, with meaningful commits and an explanation of any deviation from upstream architecture.
- When worth contributing, prepare a separate feature branch and report PR readiness; only open a PR when requested. Never make upstream acceptance block local progress.

## Synchronizing with official upstream

Synchronization is deliberate and test-gated; never automatically replace a certified working tree.

1. In a clean worktree, fetch upstream, e.g. `git fetch upstream main` (using the verified official remote name). Record old and new upstream SHAs.
2. Examine changes since the last integrated base and their impact on parser behaviour, LLVM semantics, event handlers, interpreter execution, Rocq interfaces, and tests.
3. **Mirror:** make sure updating fork `main` would be fast-forward-only. If it has diverged, STOP and investigate; never force-reset it. For a mirror update that has been authorized to push, `git push origin upstream/main:refs/heads/main` is acceptable only after checking the destination and fast-forward relationship.
4. **Integrate:** from a clean extension branch, create a dedicated sync candidate branch (e.g. `sync/upstream-YYYYMMDD`) and merge `upstream/main` into it. Avoid rebasing published or certified extension history. In a multi-worktree arrangement, use a separate worktree if switching branches would disturb an existing checkout.
5. Resolve conflicts by understanding semantics, not by reflexively choosing `ours` or `theirs`. Do not silently weaken undefined-behaviour, memory, poison, alignment, lifetime, or floating-point contracts to make a test pass.
6. Inspect the **effective final diff against upstream**. Determine which custom changes remain necessary. If upstream has incorporated a local feature, retain upstream's version when its behaviour is sufficient; remove duplicate or conflicting code by a reviewed, tested change. Patch identity and semantic equivalence are different.
7. Run the available Vellvm build and relevant regression/semantic tests. Run downstream prooflib and Nektar++ proof-certification checks (including Rocq compilation and independent checking such as `coqchk`) when integration permits. Missing or skipped downstream checks must be reported, not counted as passed.
8. Only promote the candidate into the working extension branch after checks pass and any required human review is complete. A failed integration must leave the prior certified branch and pinned dependency intact.
9. Update downstream pin(s) separately, with the exact promoted SHA and fresh certification evidence. Never silently float a proof dependency to a moving branch.

## When upstream accepts a local contribution

1. Identify the actual upstream commit(s), not just the PR number.
2. Confirm the merged code covers the precise feature and assumptions provided by the fork patch.
3. Merge upstream into a test candidate; inspect final source differences and tests. Git may recognize identical patches, but differently implemented equivalent changes need manual comparison.
4. Remove redundant local divergence without deleting unrelated extensions or rewriting certified published history.
5. Re-run affected build, semantic regressions, and dependent proof checks. Only then adopt the new upstream-based revision in downstream consumers.
6. If upstream's version is insufficient, keep a minimal documented compatibility patch rather than silently reverting upstream or abandoning the proof goal.

## Reporting / handoff

For each significant upstream sync, extension, or upstreamed-patch cleanup, report concisely:

- Official upstream old → new SHA; extension branch and resulting SHA.
- Upstream features gained, local patches retained, replaced, or still divergent.
- Conflicts and significant semantic assumptions or trusted-boundary changes.
- Tests actually run (pass/fail/not run), including independent Rocq checks where applicable.
- Downstream pin/certification status and remaining action, if any.

**Never report a change as fully certified if only a parser, compilation, or runtime smoke test passed.**

## Related agent instructions

When proving or repairing downstream Rocq lemmas, also load that project's `prooflib` skill. Keep the case-sensitive Rocq logical namespace `Prooflib` intact. General reusable theorem additions belong in prooflib; Nektar++-specific component/composition proofs remain downstream.
