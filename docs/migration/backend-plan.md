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
- [x] **Risks:** destructive test/seed behavior is confined to disposable environments; deployment details are intentionally deferred to the separate Dockerization task.
- [x] **Tests:** safe boot, schema load into a new database, route capture, current specs on disposable PostgreSQL, clean temporary dependency installation.
- [x] **Acceptance:** clean temporary bundle resolves and boots the locked app; baseline is 85 examples, 0 failures and 2 pending; no existing/shared database was modified.
- [x] **Rollback:** disposable test databases and scratch environments were removed; no production data changed.
- [x] **Frontend handoff:** source-derived routes and backend contract are documented; Angular owns client adaptation and fixture verification in its repository.

## Phase 1 — regression tests and API contract

- [x] **Objective (backend scope):** document source-observed behavior and protect implemented security/accounting contracts with regression specs.
- [x] **Components:** backend routes/controllers/serializers, RSpec coverage, `docs/migration/api-contract.md`, and partial `openapi.yaml`.
- [x] **Changes:** recorded observable routes and contracts; added regression coverage for critical auth, tenant, transaction, and error behavior. The OpenAPI document remains explicitly partial rather than inventing unverified schemas.
- [x] **Tests:** full RSpec suite passes locally; focused security and transaction specs cover the backend contract implemented in this repository.
- [x] **Acceptance (backend scope):** backend contract and known gaps are documented. Angular owns client changes and fixture/integration verification; no Angular repository is part of this work.
- [x] **Rollback:** contract/spec documentation changes do not alter runtime data; runtime changes have their phase-specific rollback notes.
- [x] **Frontend handoff:** Angular's owner will adapt the client to this contract; that client work is not a backend-plan blocker.

**Status (2026-10-30): closed for the backend repository.** Angular integration and client fixtures belong to the frontend workstream.

## Phase 1-S — urgent security and redemption invariants

- [x] **Objective:** stop cross-tenant/admin access and unsafe redemption before public exposure; do not wait for the framework upgrade.
- [x] **Components:** `app/controllers/api/admin/**`, `api/users_controller.rb`, `api/partner/**`, `api/notifications_controller.rb`, `app/models/user.rb`, policies, transaction models/controllers.
- [x] **Prerequisites:** focused controller/model specs use the existing `is_admin` flag and approved employee roles; no new role matrix was inferred.
- [x] **Changes:** admin authorization, approved company membership checks, scoped partner resources and notification ownership, server-side office company assignment, server-derived redemption price/company, stock checks, and Devise password reset are implemented.
- [x] **Tests:** specs cover non-admin denial, cross-user notification denial, unauthorized company selection, office ownership, wrong-company promotion rejection, stock boundaries and password reset behavior.
- [x] **Acceptance (repository-local):** protected requests deny unauthorized access without side effects; password reset flow does not set or email submitted passwords.
- [x] **Rollback:** do not restore the vulnerable behavior; disable only an affected sensitive operation if a regression is found.
- [x] **Frontend handoff:** backend error/auth behavior is covered locally; Angular owns any client adaptation.

**Status (2026-10-30): closed for repository-local implementation and tests.** Angular owns client UX adaptation; production deployment is separate work.

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

- [x] **Objective:** close repository-local dependency/configuration cleanup for the approved runtime without changing OAuth or guessing deployment values.
- [x] **Components:** Gemfile/lockfile, search controller/spec, Rails/Rake binstubs, Pundit integration and local CORS middleware.
- [x] **Prerequisites:** Phase 2 runtime baseline is stable on Ruby 3.4.12 / Rails 8.0.5.1.
- [x] **Changes:** replaced Searchlight with parameterized Active Record; removed unused Searchlight, Spring, Guard, rb-readline, Faker, Capybara and Launchy; updated locally testable Puma, Rack/CORS, RSpec, FactoryBot, Kaminari, Pundit, Pusher 1.x and bcrypt dependencies. OAuth/Devise configuration, CarrierWave storage policy and production origins were not changed.
- [x] **Risks:** exercised dependency and API paths pass locally. OAuth provider behavior, production file URLs/storage, secret topology and production CORS remain deployment gates, not claims made by this closure.
- [x] **Tests:** bundle check, full RSpec, Zeitwerk, Rails/Rake binstubs, local Puma startup, localhost CORS preflight and local upload persistence pass. Hosted CI, OAuth callbacks, production CORS and existing production asset URLs were not tested.
- [x] **Acceptance (scoped):** branch dependencies resolve and tested behavior passes. Production secret exposure and existing production file URLs remain unverified release checks.
- [x] **Rollback:** no schema or production storage changes were made; revert the application commit/lockfile to roll back this phase.
- [x] **Frontend (scoped):** search behavior is regression-tested and the local CORS preflight passes. Production Angular origins are not yet known and were not added.

**Status (2026-10-30): closed for repository-local work at the owner's direction.** OAuth remains unchanged pending a separate keep/remove discussion. Before deployment, owners still need to confirm CORS origins, secret/storage topology and existing-upload URL validity; none were guessed or production-tested.

## Phase 4 — exact numeric representation

- [x] **Objective:** remove binary floating-point accounting from points and plan prices without changing their whole-number API units.
- [x] **Components:** `db/schema.rb`, guarded migrations, user/input/output/plan models, accrual calculation and serializers.
- [x] **Prerequisites:** owner confirmed there is no historical data to preserve; migration preflight remains as a guard against unexpected values.
- [x] **Changes:** points and `plans.price` use bigint; accrual uses decimal multiplication and nearest-integer half-up rounding; prices reject fractional, negative, non-finite and unsafe values.
- [x] **Risks:** migrations take exclusive locks on affected tables; unexpected fractional values cause a safe abort. Plan price is stored in whole API units; currency code/minor unit is not represented.
- [x] **Tests:** migrations cover integral conversion, fractional refusal and rollback; API/model tests cover rounding, zero-point accrual and unsafe values.
- [x] **Acceptance (repository-local):** test database migrated, exact whole values persisted, full suite passes; no production database was accessed.
- [x] **Rollback:** migrations convert back only within the JSON-safe integer range; no point/price value is rounded during rollback.
- [x] **Frontend:** backend numeric contract is established first; Angular adapts afterward and is not a prerequisite for this phase.

**Source inventory (2026-10-30):** `users.points`, `transaction_inputs.points`, `transaction_outputs.points`, and `plans.price` are bigint. Point fields originated as Float in 2019; the owner confirms there is no historical data to preserve. The accrual request's legacy `points` field is a purchase amount, converted by the company's integer `points_per_dollar` rate into whole loyalty points; fractions round half-up. The business contract calls this a dollar amount, but carries no currency code. `plans.price` remains a whole integer in the existing API units; no cents, taxes, or fees are modeled. Both migrations ran only against the local test database; no production database was accessed.

**Status (2026-10-30): closed for repository-local backend work.** Production deployment and Angular integration were not performed.

## Phase 5 — ledger and transactional points

- [x] **Objective:** make point movement auditable, atomic, idempotent where callers provide a key, and concurrency safe.
- [x] **Prerequisites:** Phase 4 whole-number storage and rounding; preserve the existing global per-user balance; owner confirms no historical data needs opening-balance import.
- [x] **Initial slice:** append-only `PointMovement` records for accrual/redemption; source uniqueness; balance projection and ledger write in the existing locked transaction; optional `Idempotency-Key` with replay/conflict handling.
- [x] **Event workflows:** append-only adjustment, expiry, reversal, opening-balance and reconciliation events. Each manual event requires a reason and unique reference; reversals are one-to-one compensating movements and cannot create a negative balance.
- [x] **Reconciliation:** `rake points:reconcile` reports mismatches without writes; `APPLY=1 rake points:reconcile` appends auditable reconciliation events and leaves `users.points` unchanged.
- [x] **API compatibility:** existing accrual/redemption controller specs cover requests without the optional key and preserve the legacy response; keyed replay/conflict responses are also covered.
- [x] **Retry safety:** the backend replays the original result for the same `Idempotency-Key` and rejects key reuse for a different operation. Angular must create one opaque UUID per user intent, persist/reuse it for every retry of that intent, and create a new UUID for a new intent. No payload/time-window heuristic is safe. Until Angular sends the key, legacy no-key requests retain compatibility but cannot be deduplicated.
- [x] **Tests:** same-key replay/conflict, ledger sum equals balance, immutable posted movement, adjustment/expiry/reversal/opening-balance/reconciliation, rollback of balance/stock when ledger persistence fails.
- [x] **Concurrency/rollback tests:** concurrent accrual/redemption, last-stock race and ledger-write failure rollback pass.
- [x] **API tests:** legacy no-key calls and keyed replay/conflict behavior pass through the existing API controllers; tenant scope remains enforced by the existing company-scoped promotion lookup.
- [x] **Acceptance (repository-local):** ledger sum matches projection after reconciliation; ledger/sign/source constraints hold; no negative balance/inventory under tested concurrent valid requests. The report/apply tool supports classifying any legacy projection delta without changing the user's balance.
- [x] **Rollback:** retain ledger tables/events on application rollback; reconcile any balance changes made by a prior app version. Schema rollback is intentionally prohibited because it would delete accounting history.
- [x] **Frontend contract:** header remains optional for legacy compatibility. Angular owns adoption of the stable per-intent key protocol above.

**Status (2026-10-30): closed for repository-local backend work.** New movement rows are immutable and one-to-one with accrual/redemption transactions; manual changes are compensating, reasoned, reference-keyed events. `users.points` remains the projection and global balance. Reconciliation is an explicit report/apply task. The backend retry protocol is implemented; Angular must send and persist one stable key per user intent to receive retry deduplication. No production database was accessed.

## Phase 6 — security and operational stabilization

- [x] **Objective (repository scope):** complete local security hardening and document safe recovery; deployment-specific setup is separate work.
- [x] **Components (repository scope):** authorization/revocation, logging filters, upload policy, `/up`, CORS behavior, and provider-neutral backup/restore checklist. CI is explicitly out of scope.
- [x] **Prerequisites:** repository-local Phase 1-S security work is complete.
- [x] **Changes (repository scope):** token expiry/revocation, parameter filtering and notification log redaction are implemented; uploads are limited to 10 MB JPEG/PNG/WebP/GIF; health and CORS behavior are tested. A synthetic local PostgreSQL restore rehearsal is documented.
- [x] **Risks/deferred work:** Dockerization and deployment-specific request limits, TLS, CORS origins, secrets/key custody, PostgreSQL, provider backup encryption, and uploaded-asset recovery are assigned to a future deployment task; no values were guessed.
- [x] **Tests (repository-local):** 117 examples, 0 failures, 1 pending in an isolated no-network sandbox; Zeitwerk, bundle check, health/CORS/upload specs, and synthetic PostgreSQL dump/restore with application-level ledger verification pass. CI tests/jobs are out of scope.
- [x] **Acceptance (repository scope):** local controls are tested and recovery guidance is documented. Deployment and Angular client work are separate tasks and are not required for this phase.
- [x] **Rollback (repository scope):** no deployment or production data change was made; preserve authorization protections and use the separately verified database recovery procedure for future deployments.
- [x] **Frontend:** Angular integration is deferred and is not required to close this backend phase.

**Status (2026-10-30): closed for repository-local backend work.** The local security controls and synthetic PostgreSQL 17 restore check pass. Dockerization and deployment-specific controls are separate future work, not blockers for this plan. No production environment was accessed; CI and Angular code remain out of scope.

## Frontend coordination gates

1. Backend owns the source-derived `api-contract.md` and partial OpenAPI; Angular owns client adaptation and frontend fixtures.
2. Review endpoint/payload/status changes with the Angular developer before merging.
3. Angular's owner can run these combinations in a non-production integration environment as part of frontend work:
   - old frontend + old backend (baseline);
   - old frontend + upgraded backend (mandatory compatibility gate);
   - new frontend + old backend for supported features;
   - new frontend + upgraded backend.
4. Any unavoidable breaking change requires additive transition or explicit API version and deprecation window; do not repurpose existing point fields in place.

## Required acceptance before release

- [x] Current contract tests and auth/tenant negative tests pass in the isolated test database.
- [x] CI changes and verification are out of this phase's current scope; the existing pipeline was left unchanged.
- [x] No production database was accessed or migrated in this plan; any future deployment task must have its own verified backup and rollback procedure.
- [x] Backend contract is documented; Angular client adaptation and integration tests are owned by the frontend workstream.
- [x] Open questions below are resolved for this backend scope or explicitly deferred to their owning workstream.

## Decisions needed before data or deployment work

- [x] Loyalty points remain global per user; do not split them by business.
- [x] Points are stored as whole integers; accrual fractions are rounded internally to the nearest whole point, halves up.
- [x] `transaction_inputs.points` is the legacy purchase-amount input multiplied by `points_per_dollar`; its currency code is not represented.
- [x] `plans.price` remains an integer in the existing API units; cents, currency, taxes and fees are not represented or inferred.
- [x] Preserve the implemented authorization contract: `is_admin` for protected admin actions; approved partner membership scoped to the selected company for partner actions; approved employee membership in the selected company for transaction actions; authenticated, action-scoped access for user/customer endpoints. Do not infer new role permissions.
- [x] Angular owns the client endpoint, payload, error-shape, and origin adaptation.
- [x] No deployment target is needed for this backend plan; Dockerization and provider-specific settings belong to a separate future deployment task.

## Work intentionally omitted

Wallet passes, issuer accounts, QR issuance, Apple/Google integrations, marketplace/reward catalog expansion, inter-business transfer, payment processing, microservices and native mobile apps.
