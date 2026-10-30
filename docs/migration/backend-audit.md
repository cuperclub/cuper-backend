# Cuper backend audit

**Original source reviewed:** `db74f13` (2020-02-28). This is a source-based audit, not a production assessment. Execution updates dated 2026-10-29 are recorded below and in `backend-plan.md`; no production systems or data were accessed.

## Executive summary

The repository is a recoverable Rails API, not a candidate for a rewrite. It runs Rails 5.2.3 on Ruby 2.5.0, uses PostgreSQL and Jbuilder, and has a small set of model/controller/request specs. The largest immediate risks are authorization and tenant scoping, manipulable/concurrent point redemptions, unverified secret handling, and a weak regression baseline. Upgrade only in gated, independently deployable steps.

## Runtime and repository inventory

| Area | Observed evidence | Qualification |
|---|---|---|
| Ruby / Bundler | Ruby 2.5.0 in `.ruby-version`, `Gemfile`, `Gemfile.lock`; Bundler 2.0.2 in lockfile | Host Ruby 3.2.2 is not the app runtime |
| Rails | Rails 5.2.3 and framework components in `Gemfile.lock` | Not supported for a current deployment baseline |
| Database | PostgreSQL adapter, `plpgsql`, `unaccent`; `db/schema.rb` version 2020-02-22 | Actual deployed server version and data are unknown |
| CI runtime/database | Ruby 3.4.12 and PostgreSQL 17.11 images in `.circleci/config.yml` | CI now matches the locked Ruby target; production PostgreSQL version is still unknown |
| Persistence | 13 tables, 48 migrations; schema in `db/schema.rb` | No production database inspection performed |
| API | Rails routes in `config/routes.rb`; Jbuilder under `app/views/api`; Apipie enabled | Apipie validation is disabled; runtime API routes captured in `runtime-routes.txt`; response contract remains partial |
| Authentication | Devise Token Auth 0.2.0, Devise, OmniAuth; custom callbacks under `app/controllers/auth` | Preserve header and response contract during upgrade |
| Authorization | Pundit policies under `app/policies`; several controllers do not call `authorize` | See security findings |
| Background work | `ApplicationJob` only; no application jobs found | No durable job adapter configured; avoid adding one without a need |
| Notifications | Pusher gem and initializer; model suppresses Pusher delivery in production | External production behavior/configuration needs owner confirmation |
| Mail | Mailers call `deliver_now`; SMTP settings in development config | Synchronous delivery can fail/slow requests; real provider configuration unknown |
| Uploads | CarrierWave 1.3.1; local storage fallback, Cloudinary gem in `staging` group | Production persistence and historical file locations unknown |
| Secrets/config | `config/credentials.yml.enc`, `config/secrets.yml`, literal secret keys in tracked config, credentials reads in initializers | Never copy secret values into audit artifacts; rotate any exposed live credentials |
| Deployment | Puma and CircleCI config, a provider-neutral restore checklist, and a successful synthetic PostgreSQL 17 restore; owner says Dockerization will be a separate future task, and no deployment/storage-provider config is tracked yet | The local rehearsal did not verify provider encryption, asset storage, or production topology; those are deferred to the deployment task |
| Tests | RSpec suite: 117 examples, 0 failures, 1 pending | Passed in an isolated no-network sandbox on 2026-10-30; one placeholder remains pending |
| Untracked work | `.atl/` was untracked at inspection | Not modified or inspected as project source |

## Data model and behavior

The schema contains users, companies, employees, offices, promotions, transactions, plans, settings, notifications, and categories (`db/schema.rb`). Companies own offices; offices own promotions; employees join users to companies. The loyalty balance is a **single global `users.points` bigint**, not a per-company balance. Input and output history is present in `transaction_inputs` and `transaction_outputs`; it is incomplete as an immutable accounting ledger and lacks idempotency keys.

`TransactionInput` increments `user.points` in an `after_create` callback. `TransactionOutput` decrements points and promotion inventory in callbacks (`app/models/transaction_input.rb`, `app/models/transaction_output.rb`). The output API accepts the caller's `points` value (`app/controllers/api/transaction_outputs_controller.rb`). The output serializer can display the promotion's current points cost rather than the historical transaction amount (`app/views/api/shared/_simple_transaction_output.json.jbuilder`).

## Numeric fields

| Field | Current type | Business meaning / next action |
|---|---|---|
| `users.points` | bigint | Global whole-point balance; do not split across businesses without a business decision |
| `transaction_inputs.points` | bigint | Stored whole-point accrual result; request `points` is multiplied by `points_per_dollar`, but its source unit remains unconfirmed |
| `transaction_outputs.points` | bigint | Whole-point redemption; compare historical transaction amounts with promotion cost |
| `plans.price` | bigint | Plan price in the whole units accepted by the admin API (`Integer`); currency code/minor unit is not represented in the current contract |
| `offices.lat`, `offices.long` | Float | Geographic coordinates; retain floating representation and validate bounds |
| `categories.points_per_dollar` | Integer | Earning rate; confirm whether fractional rates are a real requirement |
| `promotions.points_required` | Integer | Redemption cost; validate nonnegative and within product limits |
| `promotions.total_rewards` | Integer | Inventory; validate nonnegative and check unlimited semantics |
| `app_settings.points_by_register` | Integer | Registration bonus; validate policy and bounds |
| `plans.days` | Integer | Plan duration; validate positivity and bounds |
| ID, count and sign-in integer fields | Integer / bigint | Identifier or counter; do not convert based only on SQL type |

No Decimal columns appear in `db/schema.rb`. Never mass-convert Float fields: coordinates and money/points have different semantics.

## Security and integrity findings

These are source-grounded defects or risks, not production exploit demonstrations.

| Priority | Finding | Evidence | Required validation/fix direction |
|---|---|---|---|
| Resolved locally | Admin status/password actions now require `is_admin`; password recovery sends Devise reset instructions instead of emailing a submitted password. | `app/controllers/api/admin/users_controller.rb`; `spec/controllers/api/admin/users_controller_spec.rb` | Keep production account-recovery UX and mail delivery under release verification |
| Resolved locally | Admin category/plan mutations and other admin management actions require admin authorization. | `app/controllers/api/admin/**`; `spec/controllers/api/admin/authorization_controller_spec.rb` | Confirm the `is_admin` role mapping with the deployment owner before release |
| Resolved locally | `current_view` rejects companies without an approved membership before saving settings. | `app/controllers/api/users_controller.rb`; `spec/controllers/api/users_controller_spec.rb` | Preserve membership checks on any new tenant-scoped action |
| Resolved locally | Office create/update scope through the partner's approved company and ignore submitted `company_id`; status authorization is policy checked. | `app/controllers/api/partner/offices_controller.rb`; `spec/controllers/api/partner/offices_controller_spec.rb` | Maintain the same ownership boundary for future office actions |
| Resolved locally | Notification lookup is scoped to the recipient; employee request approval locks/rechecks notification, partner status and duplicate membership. | `app/controllers/api/notifications_controller.rb`; `spec/controllers/api/notifications_controller_spec.rb` | Confirm client-facing 403/404/409 behavior before release |
| Resolved locally | Employee predicate checks approved membership; office policy specifically requires approved partner membership. | `app/models/user.rb`; `app/policies/api/partner/office_policy.rb`; `spec/policies/api/partner/office_policy_spec.rb` | Revisit only if the product role model changes |
| Resolved locally | Redemption cost is derived from the promotion, and the promotion is looked up under the cashier's company. | `app/controllers/api/transaction_outputs_controller.rb`; `spec/controllers/api/transaction_outputs_security_spec.rb` | Keep cost/company server-derived |
| Resolved locally | Limited stock rejects zero and decrements in the locked transaction; unlimited promotions bypass stock decrement. | `app/models/transaction_output.rb`; `spec/models/transaction_output_redemption_spec.rb`; concurrency specs | Preserve the lock and rollback tests |
| Resolved for backend; Angular handoff | Accrual/redemption replay is safe when a stable `Idempotency-Key` is supplied. Angular must persist one UUID per user intent and reuse it on retries; no-key calls remain compatible during transition and cannot be safely deduplicated. | `app/models/transaction_input.rb`; `app/models/transaction_output.rb`; `app/models/point_movement.rb`; `docs/migration/api-contract.md` | Frontend owner adopts the documented key protocol; do not deduplicate from payload or time windows |
| Medium / confirm use | User and customer search/list paths expose broad personal data to authenticated callers; the intended access policy is not evident. | `app/controllers/api/users_controller.rb`; `app/searches/user_search.rb`; `app/views/api/shared/_public_user.json.jbuilder` | Confirm frontend use and least-privilege policy; retain only fields required by the contract |
| Medium / operational | Local CORS is restricted to Angular at `http://localhost:4200`; staging/production allow no cross-origin browser requests until `CORS_ALLOWED_ORIGINS` is configured. | `config/initializers/cors.rb` | Confirm production Angular origin and set the deployment allowlist; proxy-level CORS and TLS remain unknown |
| Medium / operational | Request parameter filtering now covers credentials and personal identifiers; Pusher logs no longer include notification content or provider error details. Auth headers are outside Rails parameter filtering. | `config/initializers/filter_parameter_logging.rb`; `app/models/notification.rb` | Confirm log access/retention and ensure infrastructure does not log auth headers |
| Medium / operational | CarrierWave now restricts uploaded files to <=10 MB JPEG/PNG/WebP/GIF; storage persistence still depends on deployment configuration. The reverse proxy must also cap request bodies before Rails parses them. | `app/uploaders/application_uploader.rb`; `config/initializers/carrierwave.rb` | Confirm deployed storage and enforce a compatible request-body limit at the edge |

### Unverified controls

TLS termination, proxy-level CORS, firewall/rate limiting, production `CORS_ALLOWED_ORIGINS`, secret-manager use, PostgreSQL version, backups, Pusher channel authorization, and production upload persistence cannot be determined from tracked application source. Confirm them with the deployment owner. Do not infer they are absent.

## Dependency and CVE assessment method

`Gemfile.lock` locks 124 gems. Registry versions and an OSV version query were checked on 2026-10-29; matches are listed and prioritized in `dependency-matrix.md`. Affected-version metadata is not proof of exploitability: for example, YAML deserialization advisories require a relevant serialized-column path, and CarrierWave RMagick advisories require that processing module to be used. Conversely, no OSV match is not proof that a package is safe. Re-run `bundle audit`/OSV on the exact resolved lock in CI and review each advisory's fixed range and reachable code.

Specific reproducibility and compatibility blockers (CI changes/scans are deferred from the current scope):

- The current `Gemfile.lock` no longer contains `mimemagic`; a clean temporary bundle install succeeded on Ruby 3.4.12 with Bundler 2.6.9.
- `searchlight 4.1.0` is used only by `app/searches/user_search.rb`; upstream README says the maintainer considers the project done and has moved on. Replace its single search with parameterized Active Record query code, after regression tests.
- Devise Token Auth 0.2.0 declares Rails `< 6` and Devise `< 4.5`; it blocks the Rails upgrade. Version 1.3.0 declares Rails `< 8.3` and Devise `< 6`, making it a candidate, not a proven drop-in replacement.
- CarrierWave stable 3.1.4 CI covers Ruby 4.0 with Rails 8.0, not Rails 8.1. Its current README associates Rails 8.1 with CarrierWave 4.0, which was prerelease at audit time. Prove 3.1.4 compatibility or wait for a stable supported release; Ruby 3.4 does not resolve a Rails-version gap.
- `db/migrate/20190707032234_create_plans.rb` declares `information` twice. The schema currently has one such column. Verify migration-history implications in a disposable database; do not edit applied historical migrations casually.

## Baseline and data safety

Do not run `db:seed`: `db/seeds.rb:10–22` calls `destroy_all` on application tables. The test suite was run only against a newly created disposable PostgreSQL database for this checkpoint; `spec/rails_helper.rb` maintains test schema and `spec/spec_helper.rb` configures truncation. CircleCI now uses pinned Ruby/PostgreSQL images and lockfile Bundler. No production database or real customer data was accessed.

## Source map

- Versions/dependencies: `Gemfile`, `Gemfile.lock`, `.ruby-version`
- Routes/contracts: `config/routes.rb`, `app/controllers/api/**`, `app/views/api/**`, `config/initializers/apipie.rb`
- Domain/accounting: `app/models/{user,employee,company,office,promotion,transaction_input,transaction_output}.rb`
- Schema/migrations: `db/schema.rb`, `db/migrate/**`, `db/seeds.rb`
- Auth/config/integrations: `app/controllers/auth/**`, `config/initializers/**`, `config/environments/**`, `app/uploaders/application_uploader.rb`
- Tests/CI: `spec/**`, `.circleci/config.yml`

## Official references checked (2026-10-29)

- Ruby stable releases: <https://www.ruby-lang.org/en/downloads/> (Ruby 4.0.9; Ruby 3.4.12)
- Rails 8.1.4 release: <https://rubygems.org/api/v1/gems/rails.json>
- Rails upgrade guide: <https://guides.rubyonrails.org/upgrading_ruby_on_rails.html>
- PostgreSQL support policy: <https://www.postgresql.org/support/versioning/>
- OSV database: <https://osv.dev/>
