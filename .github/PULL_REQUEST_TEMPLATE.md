## Linked issue

Closes #<approved-issue-number>

The linked issue must have the `status:approved` label.

## PR type

Select exactly one and apply the matching repository label:

- [ ] `type:bug`
- [ ] `type:feature`
- [ ] `type:docs`
- [ ] `type:refactor`
- [ ] `type:chore`
- [ ] `type:breaking-change`

## Summary

-

## Changes

| Area / files | Summary |
|---|---|
| | |

## Test plan

- [ ] `bundle exec rspec`
- [ ] `bundle exec rails zeitwerk:check`
- [ ] `bundle check`
- [ ] `git diff --check`
- [ ] Manual/runtime checks, if applicable: describe below.

Results and deferred checks:

-

## Scope and risks

- Out of scope:
- Known limitations / follow-up work:
- Rollback:

## Contributor checklist

- [ ] Linked an approved issue using `Closes #N` or `Refs #N`.
- [ ] Exactly one matching `type:*` label is applied.
- [ ] If the diff exceeds 400 changed lines, the maintainer-approved `size:exception` label is applied with rationale.
- [ ] Tests and docs relevant to this change are included.
- [ ] I reviewed the complete diff and take responsibility for the submission.
- [ ] AI assistance: select one — [ ] none, [ ] used and reviewed. If used, describe the contribution:
- [ ] No `Co-Authored-By` trailer is included.
