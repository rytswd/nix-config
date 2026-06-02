---
name: my-workflow
description: >-
  The user's `jj`/`git`/PR/deploy rules on this machine. ALWAYS load
  before running any `jj` or `git` command -- in particular `commit`,
  `describe`, `desc`, `new`, `split`, `squash`, `push`, `rebase`,
  `merge`, `tag`, force-push -- before opening or reviewing a PR, and
  before any deploy. Encodes invariants the agent will violate by
  default -- e.g. `jj describe` and `jj split` leave `@` parked on the
  described commit and the next edit silently rewrites it; trunk-based
  `main`; no PRs / tags / releases unless explicitly asked.
---

# My Workflow

This file covers both `jj` (Jujutsu) and `git` repos. Sections marked
**[jj]** apply only when `.jj/` is present in the repo; sections
marked **[git]** apply only to plain git repos. Unmarked sections
apply to both.

If a repo has both `.jj/` and `.git/`, prefer `jj` commands and treat
the `[jj]` rules as authoritative -- do not mutate git refs directly
in a `jj`-managed repo.

## Tripwires (read first)

These are the rules the agent gets wrong by default. If you're about
to run a `jj`/`git` command and haven't checked this list, stop.

- **[jj] Never leave `@` on a described commit.** Use
  `jj commit -m "…"` (which both describes and creates a fresh empty
  `@`), or follow `jj describe` / `jj split` with `jj new`. Editing
  while parked on a described commit silently rewrites it and changes
  its hash. No equivalent trap exists in git -- `git commit` advances
  `HEAD` and the next edit lands in the working tree.
- **Don't create PRs unless explicitly asked.** Even after pushing
  a topic branch.
- **Never force-push `main` or any shared branch.** Force-push on
  own topic branches is OK only before a reviewer has loaded the diff.
- **Don't manage tags or releases unless asked.** No `git tag`,
  no version bumps, no release commits without an explicit request.
- **Prefer many small, logically-grouped commits** over one large
  catch-all commit. Split when the working copy spans concerns.

## Branching and commits -- shared

- Trunk-based: `main` is the integration branch.
- Small, logically-grouped commits beat one large catch-all commit.
  Make many small commits often; squash later only if they were
  temporary or experimental.
- No "WIP" / "fixup" commits left on the branch before completing a
  task -- squash or amend them first.
- **Delegating to a sub-agent? Give them their own working copy.**
  Pointing two agents -- or an agent and yourself -- at the same
  working copy is the fastest way to make a worker's diff
  unreviewable. Use the VCS-specific isolation primitive below
  (`jj workspace add` or `git worktree add`).

## Branching and commits -- [jj]

- Use `jj commit` (or follow `jj describe` / `jj split` with
  `jj new`) so the next code change lands in a fresh change. Bare
  `jj describe` / `jj desc` does NOT -- the next edit silently
  rewrites the just-described commit and changes its hash.
- `jj` branches out automatically without creating a dedicated
  bookmark. When you need a stable ref to push, create the bookmark
  explicitly; otherwise expect cleanup work later.
- **Sub-agent isolation:** `jj workspace add ../<repo>-<worker>`
  gives the agent its own working directory sharing the underlying
  repo. Its commits show up in your `jj log` but its edits never
  collide with your dirty `@`. Tear down with `jj workspace forget`
  when done.
- **Integration:** `jj rebase` / `jj squash` to fold the worker's
  change into your stack.

### Mandatory verification after any `jj` commit-like command

After running ANY of `jj commit`, `jj describe`, `jj desc`,
`jj split`, `jj squash`, `jj new`:

1. Run `jj log -r @ --no-graph -T 'description ++ "\n"'` (or just
   `jj st`) and confirm the working copy is on a fresh commit --
   either `(empty)` with no description, or a commit you intend to
   keep editing.
2. If `@` is parked on a just-described commit (non-empty, has a
   message you don't want to keep mutating), run `jj new` immediately
   before doing anything else.
3. Only after step 2 should the next file edit happen.

This check is non-negotiable. The single most common failure mode is
running `jj describe "…"` and then continuing to edit, which silently
rewrites the just-described commit and produces a hash that differs
from what was reported.

## Branching and commits -- [git]

- `git commit` and `git commit --amend` advance `HEAD` normally. The
  next edit lands in the working tree, not back into the just-made
  commit -- there is no `jj`-style `@`-parking trap.
- **Sub-agent isolation:**
  `git worktree add ../<repo>-<worker> -b agent/<worker>` gives the
  agent its own working directory on its own branch, sharing the
  same `.git`. Tear down with `git worktree remove` and
  `git branch -D agent/<worker>` when done.
- **Integration:** `git merge --ff-only` for clean fast-forwards;
  `git rebase` to linearise. Avoid `git merge` without `--ff-only` on
  short-lived topic branches -- it produces noisy merge commits.

## PR opening / review

Applies to both `jj` and `git` repos.

- Do NOT create a PR unless explicitly requested.
- Open as **Draft** initially; mark Ready for review after CI passes
  and self-review is done.
- Self-review the diff before tagging anyone -- leave comments on
  decisions / open questions inline so the human reviewer has context.
- Don't push more changes once review starts unless asked; push a
  follow-up commit instead of force-pushing into a review-in-progress.

## Merging, rebasing, force-push

Applies to both `jj` and `git` repos.

- Prefer keeping history as much as possible.
- Force-push is allowed on **own** topic branches before review
  starts; not allowed once a reviewer has loaded the diff.
- Never force-push `main` or any shared branch.
- See the `[jj]` and `[git]` sections above for the actual integration
  commands.

## Releases / deploys
- Do NOT manage releases including tags unless explicitly requested.
- Tag releases with `vX.Y.Z` (semver where it makes sense).
- Releases are usually triggered from a tagged commit on `main`;
  no manual editing of production state.
- Don't propose deploy commands unless the repo has a documented
  release process (look for `RELEASING.md`, a `release` task in
  `flake.nix`, or a CI workflow).
