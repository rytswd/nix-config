---
name: my-workflow
description: >-
  The user's `jj`/`git`/PR/deploy rules on this machine. ALWAYS load
  before running any `jj` or `git` command — in particular `commit`,
  `describe`, `desc`, `new`, `split`, `squash`, `push`, `rebase`,
  `merge`, `tag`, force-push — before opening or reviewing a PR, and
  before any deploy. Encodes invariants the agent will violate by
  default — e.g. `jj describe` and `jj split` leave `@` parked on the
  described commit and the next edit silently rewrites it; trunk-based
  `main`; no PRs / tags / releases unless explicitly asked.
---

# My Workflow

## Tripwires (read first)

These are the rules the agent gets wrong by default. If you're about
to run a `jj`/`git` command and haven't checked this list, stop.

- **Never leave `@` on a described commit.** Use `jj commit -m "…"`
  (which both describes and creates a fresh empty `@`), or follow
  `jj describe` / `jj split` with `jj new`. Editing while parked on a
  described commit silently rewrites it and changes its hash.
- **Don't create PRs unless explicitly asked.** Even after pushing
  a topic branch.
- **Never force-push `main` or any shared branch.** Force-push on
  own topic branches is OK only before a reviewer has loaded the diff.
- **Don't manage tags or releases unless asked.** No `git tag`,
  no version bumps, no release commits without an explicit request.
- **Prefer many small, logically-grouped commits** over one large
  catch-all commit. Split when the working copy spans concerns.

## Branching / commits
- Trunk-based: `main` is the integration branch.
- `jj` (Jujutsu) is used alongside `git` in many repos. If a `.jj/`
  directory is present, prefer `jj` commands and avoid mutating the
  git refs directly.
- When necessary, a branch can be created; but in a `jj` repo, 
  changes will branch out automatically without creating a dedicated
  bookmark, which will require extra clean up process.
- With `jj`, make sure to use `jj commit` or equivalent (such as
  `jj new`) so that the next code change will land in a new change. 
  If `jj desc` is used to add a commit message, this change will 
  still receive further code edits, merging with the existing code
  changes.
- Small, logically-grouped commits. It's better to have many commits
  than big large commits, do make many small commits often, which
  could possibly be squashed when commits were only temporary or
  experimental. No "WIP" / "fixup" commits left on the branch before
  completing a task, squash or amend them first.

## PR opening / review
- Do NOT create a PR unless explicitly requested.
- Open as **Draft** initially; mark Ready for review after CI passes
  and self-review is done.
- Self-review the diff before tagging anyone — leave comments on
  decisions / open questions inline so the human reviewer has context.
- Don't push more changes once review starts unless asked; push a
  follow-up commit instead of force-pushing into a review-in-progress.

## Merging / rebasing / force-push
- Prefer keeping history as much as possible.
- Force-push is allowed on **own** topic branches before review
  starts; not allowed once a reviewer has loaded the diff.
- Never force-push `main` or any shared branch.

## Releases / deploys
- Do NOT manage releases including tags unless explicitly requested.
- Tag releases with `vX.Y.Z` (semver where it makes sense).
- Releases are usually triggered from a tagged commit on `main`;
  no manual editing of production state.
- Don't propose deploy commands unless the repo has a documented
  release process (look for `RELEASING.md`, a `release` task in
  `flake.nix`, or a CI workflow).
