# Backend modernization plan

**Recommendation:** modernize the existing Rails monolith in small, reversible PRs. First establish a safe baseline and API regression suite, then repair urgent authorization and redemption defects before releasing the framework upgrade. Wallet and other product expansions are explicitly out of scope.

**Execution checkpoint (2026-10-29):** runtime is Ruby 3.4.12 / Rails 8.0.5.1 with CarrierWave 3.1.4 and Cloudinary 2.4.5; Rails 8.1 remains gated on stable CarrierWave 4.0. The current suite has 85 examples, 0 failures and 2 pending. Direct model specs now cover category/company requirements and company RUC uniqueness, plan-company and user-setting associations, employee role/status constraints, accrual/redemption invariants, duplicate pending employee requests, and office/promotion required fields. User deactivation now clears existing tokens, rejects tokens from legacy inactive accounts, and prevents new sign-ins. Pusher delivery logs omit notification bodies and provider error details. Request logging filters email, national ID, password-like, token, and other common credential parameters. CORS permits http://localhost:4200 locally; staging/production require explicit CORS_ALLOWED_ORIGINS and reject wildcard configuration. CircleCI now targets Ruby 3.4.12 and PostgreSQL 17.11, pins Bundler from the lockfile, and runs the full RSpec suite. The remaining AppSetting and Plan placeholders have no model-level behavior or validation to test, so no rules were invented. This checkpoint fixes approved-membership checks for company selection and partner routes, office ownership, notification ownership, admin reads/mutations, password recovery, and server-derived redemption price/company plus stock checks. Partner company applications now save the company, partner membership, optional plan and current view atomically; registration email is sent only after commit. Employee request responses now accept only approved/decline, require the requesting partner to remain approved, and lock/recheck the request before creating membership, preventing replayed approvals. Existing memberships block new invitations and approval checks recheck under the recipient lock, preventing duplicate company memberships across different partners. Cashier applications are unique per user/company and serialized under the user lock. Partner employee status updates are company-scoped; role changes in submitted parameters are ignored, and pending partners cannot manage employees. Partner status-change email is sent after commit, so rolled-back changes do not send stale email. Accrual input safely parses numeric strings, rejects missing/malformed/non-finite inputs, and rejects non-integer legacy category multipliers or products that overflow; nil legacy balances accrue from zero and cannot redeem without sufficient points. No multiplier bounds or rounding policy were changed because those business rules remain undecided. Pending employee requests are serialized per sender to prevent concurrent duplicates. Rails cookie sessions now use ActionDispatch middleware; the old `rack.session` cookie is no longer read, so browser/Warden sessions may need reauthentication (token headers remain the API contract). Threaded database tests cover accrual, redemption, duplicate requests, and approval replays; simultaneous authenticated curl requests confirmed one concurrent redemption, one duplicate employee request, and one duplicate cashier application succeeds. Concurrent approval curls from different partners returned 201/409 and left one membership. Curl requests also confirmed valid partner application (201), invalid-plan rollback (422), unsupported employee response (422), stale-partner approval rejection (403), partner employee status update (202), numeric-string accrual (201), malformed/missing points (422), nil-balance accrual/redemption (201/422), and overflow accrual (422). Temporary curl records were removed; all requests were confined to the local test database. These changes do not complete phases 0, 1, 1-S or 2. Update phase checkboxes only when each phase's acceptance criteria pass.

**Version-scope clarification (2026-10-29):** the execution checkpoint's note that Rails 8.1 awaits CarrierWave support is informational only; Rails 8.1 and Ruby 4 are not required by the approved target above.

**Phase 0 evidence (2026-10-29):** clean temporary bundle install and `bundle check` pass with Ruby 3.4.12/Bundler 2.6.9; Rails boot captured 73 API routes in `docs/migration/runtime-routes.txt`; schema loaded and the full 85-example suite passed against a newly created disposable PostgreSQL database, then that database was removed. Two existing pending specs remain. Angular endpoint/fixture collection is still external and unverified.

## Goals and non-goals

- Preserve legitimate business rules and existing JSON/header contracts.
- Keep old Angular working against the upgraded backend.
- Use supported Ruby/Rails/PostgreSQL and maintained dependencies.
- Keep one Rails application and PostgreSQL; add no Redis or services without a demonstrated requirement.
- Never use production data for upgrade/test runs; never run destructive seeds on existing data.
- Wallet, marketplace, transferable points, payments and native apps are not part of this plan.

## Version and rollout strategy

**Approved target for this modernization:** Ruby **3.4.12**, Rails **8.0.5.1**, Bundler **2.6.9**. Ruby 4.0.9 and Rails 8.1.4 are deferred optional upgrades, not completion gates; this target matches the locked and tested dependency set.

Newer upstream versions checked on 2026-10-29 were Ruby 4.0.9, Rails 8.1.4 and Bundler 4.0.23. The historical hop sequence below is reference material only; do not treat reaching Rails 8.1 or Ruby 4 as required for this plan:

```text
Rails 5.2.3 → 5.2.8.1 → 6.0.6.1 → 6.1.7.10 →
7.0.10 → 7.1.6 → 7.2.4 → 8.0.5.1 → 8.1.4
```

These intermediate releases are migration bridges, not deployment destinations for a long-lived new production environment. Verify the current patched release again when executing each hop.

Ruby is upgraded separately so failures remain attributable. Proposed compatibility checkpoints:

```text
2.5.0 baseline → 2.5.9 → 2.7.8 → 3.1.7 → 3.4.12 → 4.0.9
```

The listed EOL patch releases are compatibility checkpoints only; confirm availability with `mise ls-remote ruby` at execution time. Align them with Rails gates: Ruby 2.5.9 for Rails 5.2/6.0, 2.7.8 before Rails 7.0, 3.1.7 before Rails 7.2, and 3.4.12 before Rails 8.0/8.1. Rails 8.0/8.1 require Ruby >= 3.2. Ruby 4.0.9 is a separate final checkpoint on Rails 8.1. Do not keep Ruby 2.5 or 2.7 in production. If a legacy runtime cannot build safely on the host due to obsolete OpenSSL/toolchain requirements, use an isolated pinned container; never replace system OpenSSL. Ruby 3.4 is a supported target/fallback for a demonstrated Ruby 4 incompatibility, and does not resolve a Rails 8.1 gem incompatibility.

Use `mise install ruby@<exact-version>` to install without changing `.ruby-version` or the global version, and `mise exec ruby@<exact-version> -- ruby -v` to verify each runtime. Commit project version selection only in the PR for that runtime stage. Bundler remains pinned/compatible per lockfile stage; target Bundler 4.0.23 only after confirming RubyGems compatibility and the final lock.

### Framework compatibility points to gate

| Upgrade point | Required checks |
|---|---|
| Rails 5.2 patch | Move to 5.2.8.1 before leaving the line; review security fixes and lock changes |
| Rails 6.0 | Devise Token Auth 0.2.0 requires Rails `< 6`; first upgrade auth dependency or choose a supported compatibility bridge. Enable Zeitwerk checks, host authorization and cookie/session regressions. Review API session middleware and OAuth callbacks. |
| Rails 6.1 | Review Active Storage image processing only if used; preserve prior cookie/cache format while mixed old/new processes coexist |
| Rails 7.0 | Zeitwerk is required; audit constant/file naming, eager load, deprecated dependency APIs, Spring, and explicitly add Sprockets only if an actual asset need exists. Review cookie key-generator digest rotation and cache serialization. |
| Rails 7.1 | Review secret key source, autoload paths removed from `$LOAD_PATH`, logger API, cache format, and test exception configuration. |
| Rails 7.2 | Review Active Job test adapter behavior and any changed Active Record attribute aliases. |
| Rails 8.0/8.1 | Confirm Ruby >= 3.2; test Rack/session middleware, JSON escaping compatibility, `load_defaults` effects, schema dump changes, and adapters. Do not install Solid Queue/Cache/Cable or change queue adapters by default. |
| Ruby 2.7 → 3.x | Fix positional/keyword argument separation, standard-library gem extractions, Psych/YAML behavior and native extensions; rerun authentication, dates and serialization tests. |
| Ruby 3.x → 4.0 | Resolve gemspec/native extension compatibility using the locked bundle; test PostgreSQL, Nokogiri, bcrypt, Bootsnap, CarrierWave, Puma and OAuth libraries. |

`config.load_defaults` currently remains 5.2. Preserve old defaults while upgrading; selectively enable and test generated defaults before changing it. Explicit review is required for cookie serializers and digest, cache format, JSON escaping, Active Job enqueue timing, exception rendering, and autoloading. Do not change all defaults in one PR.

## Migration safety rules

- Every schema/data change is additive first: **expand → backfill → validate → contract**.
- No destructive migration, data rewrite, or seeds against production.
- Profile data on an authorized sanitized copy; obtain explicit business decisions for rounding and points scope.
- Backfills must be idempotent, resumable, observable, bounded and tested on representative volume.
- Add constraints only after measuring and resolving existing invalid records.
- Keep rollback compatibility during the agreed deployment window; do not claim a lossy Float/Integer conversion is reversible.
- Take and verify restorable backups before any production database change; restore rehearsal is a gate.

## Phase 0 — audit and safe baseline

- [x] **Objective:** make current behavior and build reproducible before changing runtime.
- [x] **Components:** `Gemfile*`, `.ruby-version`, `db/schema.rb`, `db/migrate/**`, `spec/**`, `.circleci/config.yml`, configuration and upload integrations.
- [x] **Prerequisites:** none; use only a disposable local/CI database and dummy credentials.
- [x] **Changes:** inventory runtime routes and source behavior; verify locked dependencies install in a clean temporary bundle; pin CI images and avoid unsafe seed setup; build isolated database setup and baseline report.
- [ ] **Risks:** existing tests may depend on destructive truncation; real deployment details are absent from repository.
- [x] **Tests:** safe boot, schema load into a new database, route capture, current specs on disposable PostgreSQL, clean temporary dependency installation.
- [x] **Acceptance:** clean temporary bundle resolves and boots the locked app; baseline is 85 examples, 0 failures and 2 pending; no existing/shared database was modified.
- [ ] **Rollback:** throw away disposable environment only; no app/data changes.
- [ ] **Frontend:** collect actual endpoints and sanitized fixtures consumed by the legacy Angular app; unavailable until the frontend repository/fixtures are provided.

## Phase 1 — regression tests and API contract

- [ ] **Objective:** encode legitimate existing behavior without blessing unauthorized behavior.
- [ ] **Components:** `spec/requests/**` (create), existing `spec/controllers/**`, factories, `app/views/api/**`, `config/routes.rb`, `docs/migration/api-contract.md`, `openapi.yaml`.
- [ ] **Prerequisites:** phase 0 safe test database.
- [ ] **Changes:** add request tests for auth headers, registration/login/token validation, account, tenant selection, partner CRUD, notifications, accumulation, redemption, status codes, JSON types, error bodies and pagination; capture all route methods/paths; compare OpenAPI and sanitized fixtures.
- [ ] **Risks:** old API has inconsistent envelopes and statuses; tests must describe intentional compatibility, not insecure access.
- [ ] **Tests:** all active specs; focused request suite; JSON schema/contract checks and legacy client integration when frontend evidence exists.
- [ ] **Acceptance:** critical existing user flows have active tests; observed and documented contracts agree; unknowns remain marked unverified.
- [ ] **Rollback:** test-only changes can be reverted without changing runtime/data.
- [ ] **Frontend:** review payload fixtures with frontend developer; establish old/new frontend/backend matrix.

## Phase 1-S — urgent security and redemption invariants

- [ ] **Objective:** stop cross-tenant/admin access and unsafe redemption before public exposure; do not wait for the framework upgrade.
- [ ] **Components:** `app/controllers/api/admin/**`, `api/users_controller.rb`, `api/partner/**`, `api/notifications_controller.rb`, `app/models/user.rb`, policies, transaction models/controllers.
- [ ] **Prerequisites:** focused tests from phase 1; define actual admin and partner roles.
- [ ] **Changes:** authorize admin mutations; scope selected company to current membership; scope child resources and notifications to authorized owner; correct `is_employee`; set ownership server-side; derive redemption price and company from server data; fix stock check; replace plaintext password email with Devise reset flow.
- [ ] **Risks:** frontend may rely on previously permissive paths; legitimate account recovery UX will change. Coordinate behavior and communicate expected 401/403/404 responses.
- [ ] **Tests:** unauthorized and cross-business read/write; status and password admin-only; notification recipient only; wrong-company promotion rejected; stock values 0/1/>1/unlimited; exact debit and rollback on failure.
- [ ] **Acceptance:** unauthorized requests have no side effects, legitimate calls retain response contract, password never appears in mail/logs.
- [ ] **Rollback:** never restore the vulnerability; feature-flag or temporarily disable only a broken sensitive operation.
- [ ] **Frontend:** confirm expected errors and account recovery UX; no new JSON fields required.

## Phase 2 — Ruby and Rails upgrades

- [x] **Objective:** use the approved Ruby 3.4.12 / Rails 8.0.5.1 runtime target; newer major/minor upgrades are separate work.
- [x] **Components:** `.ruby-version`, `Gemfile`, `Gemfile.lock`, `.circleci/config.yml`, `config/application.rb`, `config/environments/**`, `config/initializers/**`, `bin/**`, relevant native gems.
- [x] **Prerequisites:** phase 0 reproducibility and available phase 1 regression coverage; dependency bundle resolves on the approved target.
- [x] **Changes:** established Ruby 3.4.12/Rails 8.0.5.1, updated legacy Rails config/session/secrets integration, and verified the app boots and eagerly loads. Further Rails/Ruby upgrades are separate work.
- [x] **Risks:** compatibility checks passed for the exercised app/runtime paths. OAuth is assumed acceptable by the user and its keep/remove decision is deferred; Rails 8.1/CarrierWave 4 is outside scope.
- [x] **Tests:** full RSpec, Zeitwerk eager-load, route boot, schema load, local file upload + persisted reload, token lifecycle and representative API response comparison passed. Hosted CircleCI and OAuth callback tests are intentionally excluded by user direction.
- [x] **Acceptance:** approved exact bundle resolves and boots; no deprecation warnings appeared in the checks; local application rollback rehearsal passed with unchanged schema/data and matching API response.
- [x] **Rollback:** rehearsed switching between candidate code and the prior runtime-baseline commit on a disposable PostgreSQL database; no production deployment or data migration was involved.
- [x] **Frontend:** routes and Jbuilder views are unchanged from `master`; the representative successful API response matched after rollback. Full Angular integration was not run, per the agreed response-compatibility scope.

## Phase 3 — gems and configuration

- [ ] **Objective:** maintain only justified, supported dependencies and move configuration to explicit runtime secrets.
- [ ] **Components:** `Gemfile*`, uploaders, mailers, initializers, config environments, CI.
- [ ] **Prerequisites:** address only gems blocking phase 2 at their corresponding hop; stable runtime baseline.
- [ ] **Changes:** update auth/OAuth gems as a compatible set; update Rack, pg, Puma, Jbuilder, RSpec and security-sensitive transitives; replace single-use Searchlight search with Active Record; remove unneeded Spring, Guard, rb-readline, demo/test dependencies only after confirming usage; modernize CarrierWave only after compatibility/asset path test; use credentials/env for secrets; correct CORS origins after frontend origin confirmation.
- [ ] **Risks:** token semantics, OAuth provider configuration, file URL/storage breakage, version-specific keyword/serialization changes.
- [ ] **Tests:** bundle check; auth/provider contract; upload existing/new assets; CORS preflight; app boot per environment; OSV/Bundler audit.
- [ ] **Acceptance:** dependency set is justified, stable and reproducible; no exposed credentials; existing file URLs remain resolvable.
- [ ] **Rollback:** pin previous lock/config and retain old storage read paths until files are verified.
- [ ] **Frontend:** preserve token headers, callback URLs, CORS and image URLs.

## Phase 4 — exact numeric representation

- [ ] **Objective:** remove binary floating-point accounting without corrupting historical values or JSON contract.
- [ ] **Components:** `db/schema.rb`, new additive migrations, user/input/output/plan models, point calculation and serializers.
- [ ] **Prerequisites:** authorized sanitized historical snapshot, contract fixtures, approved units/rounding and point semantics.
- [ ] **Changes:** profile fractional/non-finite/negative/max values; determine whether input `points` actually means spend amount (controller multiplies by `points_per_dollar`); add exact shadow columns; backfill in resumable batches; validate per-row and aggregate equality; dual-write/read; add constraints; contract only after rollback window.
- [ ] **Risks:** historical Float artifacts, non-integral points, money precision and API type coercion.
- [ ] **Tests:** exact migration fixture with integer/fractional/invalid/boundary values; repeated backfill; reconciliation; rollback; API JSON compatibility.
- [ ] **Acceptance:** every conversion has approved deterministic rounding or is rejected for manual resolution; no unexplained balance delta.
- [ ] **Rollback:** keep original columns during transition; reconcile, do not silently cast exact values back to Float.
- [ ] **Frontend:** keep property names and legacy JSON numeric units until a separately versioned contract is approved.

## Phase 5 — ledger and transactional points

- [ ] **Objective:** make point movement auditable, atomic, idempotent where callers provide a key, and concurrency safe.
- [ ] **Components:** additive ledger/account tables and indexes; transaction models/controllers; reconciliation tasks; request specs.
- [ ] **Prerequisites:** phase 4 exact units; phase 1 redemption invariants; business decision on current global balance.
- [ ] **Changes:** ledger events for accrual, redemption, expiry, adjustment, reversal and explicit opening balance; immutable posted records plus compensations; transaction + row locks in stable order; unique idempotency and import references; materialized exact balance updated in same transaction; preserve legacy serializer and dual-run comparison.
- [ ] **Risks:** existing balance is global per user, not per business; never split or duplicate it by inference. Existing history may not explain every balance. Legacy frontend has no idempotency key.
- [ ] **Tests:** duplicate replay, same-key conflict, concurrent accrual/redemption, inventory race, rollback at each write, tenant association, opening balance/reconciliation, immutable history.
- [ ] **Acceptance:** ledger sum matches projection, all legacy movements reconciled or explicitly classified, no negative balance/inventory under concurrent valid requests.
- [ ] **Rollback:** stop new ledger writes behind controlled switch and reconcile; retain ledger records; never delete accounting history.
- [ ] **Frontend:** retain old endpoints/responses; add optional idempotency header only after coordination. Explain that old clients cannot guarantee retry deduplication.

## Phase 6 — security and operational stabilization

- [ ] **Objective:** close remaining access/config gaps and make deploy/recovery observable.
- [ ] **Components:** auth/policies/controllers, logging filters, upload config, CORS/TLS/proxy config, CI, deployment and backup runbooks.
- [ ] **Prerequisites:** security fixes from phase 1-S; production owner confirms topology and secrets.
- [ ] **Changes:** verify token expiry/revocation on account disable; add justified request limits; restrict origins; bound upload size/type; filter tokens/PII; remove raw object logs; add health/readiness endpoint; pin CI; add Brakeman and dependency advisory checks; document encrypted backups and restore; choose supported PostgreSQL separately from Rails upgrade.
- [ ] **Risks:** infrastructure controls may live outside this repository; PostgreSQL major upgrade needs dump/restore or `pg_upgrade` planning.
- [ ] **Tests:** auth/revocation matrix, two-tenant suite, CORS, upload negative cases, health check, CI security jobs, restore rehearsal on isolated environment.
- [ ] **Acceptance:** owners confirm external controls; restore and rollback are demonstrated; no secret values in code/log/artifact.
- [ ] **Rollback:** revert app config where safe; preserve TLS and authorization protections; database rollback follows separate verified procedure.
- [ ] **Frontend:** verify allowed origins, response to limits/auth expiry, and health endpoint is not used as an auth bypass.

## Phase 7 — later product work (not this modernization)

- [ ] **Objective:** no Wallet implementation in this plan.
- [ ] **Components:** future feature proposal only.
- [ ] **Prerequisites:** modernized auth, tenant isolation and reconciled ledger.
- [ ] **Changes:** none in this modernization; create a separate approved plan for customer self-registration, wallet, secure redemption UX, marketplace, payments or mobile apps.
- [ ] **Risks:** expanding scope would delay security and compatibility work.
- [ ] **Tests / acceptance:** not applicable until a separate feature is approved.
- [ ] **Rollback:** not applicable.
- [ ] **Frontend:** frontend work should coordinate only against the stable current contract and separately approved additions.

## Frontend coordination gates

1. Backend owns `api-contract.md`, OpenAPI and response fixtures until repositories are connected; frontend records observed usage separately.
2. Review endpoint/payload/status changes with the Angular developer before merging.
3. Run these combinations in a non-production integration environment:
   - old frontend + old backend (baseline);
   - old frontend + upgraded backend (mandatory compatibility gate);
   - new frontend + old backend for supported features;
   - new frontend + upgraded backend.
4. Any unavoidable breaking change requires additive transition or explicit API version and deprecation window; do not repurpose existing point fields in place.

## Required acceptance before release

- [ ] Current contract tests and auth/tenant negative tests pass.
- [ ] Exact pinned runtime and dependencies resolve in CI.
- [ ] No database migration ran on production without backup, restore rehearsal, review and rollback plan.
- [ ] Old frontend passes against the candidate backend.
- [ ] Open questions below are decided by product/deployment owners.

## Decisions needed before data or deployment work

- [ ] Are loyalty points globally shared or intended to accrue separately per business? Current code is global.
- [ ] Are fractional points allowed? What are the rounding and conversion rules?
- [ ] What is the historical meaning/unit of `transaction_inputs.points`?
- [ ] Is USD price limited to cents, and are taxes/fees represented elsewhere?
- [ ] Which admin/partner/cashier/customer operations should each role access?
- [ ] Which Angular origins, endpoints and error shapes are actually used?
- [ ] What PostgreSQL version, file storage, TLS proxy, backup process and deployment platform are active?

## Work intentionally omitted

Wallet passes, issuer accounts, QR issuance, Apple/Google integrations, marketplace/reward catalog expansion, inter-business transfer, payment processing, microservices and native mobile apps.
