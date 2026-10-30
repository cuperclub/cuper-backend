# Backend modernization decisions

**Status:** recommendations for human review, not implemented. Wallet and product expansions are excluded.

| Topic | Recommended decision | Reason | Alternative rejected / trade-off |
|---|---|---|---|
| Application architecture | Keep the Rails monolith and existing domain models; refactor only where needed for a transaction or security invariant | Current product/domain fits one application; preserves Git history and reduces deployment risk | Rewrite/microservices add migration and operational complexity without evidence of need |
| Framework target | Ruby 3.4.12 / Rails 8.0.5.1 are the approved target for this modernization; Rails 8.1/Ruby 4 are deferred optional upgrades | These are the versions currently locked and validated with the app's dependency set | Chasing newer versions now adds compatibility work without being required for this plan |
| Ruby manager | Use installed `mise` with exact versions per stage; use `mise install`, not global mutation | Already present on Omarchy; supports parallel runtimes and exact verification | System Ruby or `mise use -g` changes unrelated projects; old runtimes may require isolated containers |
| Ruby target | Keep Ruby 3.4.12 for this plan; revisit Ruby 4 only as separate work | Matches the currently tested runtime | Ruby 4 remains an option, not a completion gate |
| API serialization | Keep Jbuilder and existing JSON shape; add contract/request tests and partial OpenAPI | Existing API uses many explicit partials and irregular response envelopes | Replacing serializer/introducing JSON:API would create needless frontend breaking changes |
| Authentication | Retain maintained Devise + Devise Token Auth protocol while upgrading the gem set and testing header behavior | Existing clients depend on token headers and auth response shape | Custom authentication/token code would be a critical security risk; session/JWT redesign needs separate need and migration |
| Authorization | Apply Pundit at every protected action and scope lookup by tenant membership; correct predicates | Source currently allows missing admin checks and trusts selected company context | Global role checks alone do not prevent IDOR/cross-company access |
| Tenant context | Keep `current_company` UX but validate against user's active company memberships each time; never use it as proof of authorization by itself | Minimizes API change while enforcing ownership at server boundary | Remove context abruptly or make client-provided company ID authoritative |
| Points scope | Preserve existing global balance until product owners decide how to handle it; do not split or copy balances automatically | `users.points` has no company key and existing transactions are global | Creating one balance per business would multiply or invent customer value |
| Numeric points | Move to exact integer units only after historical profile and explicit fractional-point decision | Points may be indivisible, but stored input/output values are Float | Blind Float→Integer conversion can erase fractions and change balances |
| Money | Replace `plans.price` Float with integer USD cents if cents are the actual business precision; otherwise use decimal/BigDecimal | Prevents binary floating-point monetary errors | Convert all Float columns to integer, including coordinates |
| Migration strategy | Expand/backfill/validate/contract with dual-read/write as needed, batch backfills, constraints after cleanup | Supports rolling deploys, reconciliation and rollback | In-place type conversion or destructive data rewrite |
| Point accounting | Add immutable movement ledger and a materialized exact balance updated in one DB transaction | Ledger supports audit/reconciliation; projection keeps reads inexpensive | Recomputing every balance from an unbounded ledger on each request; mutable historical rows |
| Corrections | Append compensating reversal/adjustment, never edit posted movements | Preserves traceability | Editing/deleting a historical movement loses audit trail |
| Idempotency | Add an optional request idempotency key plus database uniqueness; document limitation for old callers | Safe retries require stable client intent and DB enforcement | Deduplicate heuristically by amount/time; guarantees are impossible for clients without a key |
| Redemption concurrency | Lock the balance account and promotion rows in consistent order in one DB transaction; validate all resources belong to same business | Prevents double-spend and oversold stock under concurrent requests | Model validation or process-local mutex does not protect multiple Puma processes |
| Search | Replace Searchlight's single use with a small parameterized Active Record query | Removes an explicitly unmaintained dependency without adding a replacement gem | Add Ransack/search framework for one query |
| Background jobs | Do not add Redis or worker infrastructure now; first keep existing behavior while testing mail/Pusher failures | No application jobs currently exist and few-business scale does not justify new operations | Adopt Redis/Sidekiq solely because modern Rails supports it |
| Future jobs (if justified) | Evaluate Active Job with Solid Queue on PostgreSQL after durable async work is required | Reuses existing DB/operations and avoids Redis | Premature queue migration changes delivery semantics and deployment topology |
| Uploads | Keep CarrierWave 3.1.4 with the approved Rails 8.0.5.1 target; evaluate Rails 8.1 compatibility separately if proposed | Existing columns, URLs, staging config and files are production-sensitive | Simultaneous uploader and Rails rewrite compounds rollback risk |
| Secrets | Move runtime secrets to Rails encrypted credentials or deployment environment/secret store; rotate real exposed values | Current config contains literal keys and old secrets API usage | Commit credentials or leak secret values into audit docs |
| CORS | Allow only confirmed frontend origins; maintain token headers exposed to Angular | Current wildcard is broader than needed | Remove CORS without confirming deployment origin; use wildcard indefinitely |
| Database | Retain PostgreSQL; separately move unsupported CI/runtime majors to a supported release after inventory | Existing extensions/query use and Rails adapter match PostgreSQL | Change DB engine during Rails modernization |
| PostgreSQL target | Prefer a currently supported major chosen with hosting compatibility; PostgreSQL 17.11 is conservative in the audit snapshot | Supported through Nov 2029; PostgreSQL 18.6 is also supported | Keep CI PostgreSQL 9.5 (EOL), or assume hosted DB version without checking |
| CI/security | Pin Ruby/PostgreSQL images; run focused/full tests, Brakeman and bundle advisory scan on exact lock | Current CI is legacy and does not run configured split list effectively | Treat dependency age or an untriaged scanner warning as proof of exploit |
| OpenAPI | Backend owns source-derived contract until repos connect; keep specification partial and fixture-backed | Prevents frontend/backend drift and avoids invented endpoints | Document only aspirational APIs or generate an incomplete contract without review |
| Wallet / future products | Excluded from this modernization plan | User requested deferral | Wallet endpoints, provider credentials, marketplace, payments or mobile SDKs now |

## Security boundaries that are not negotiable

- Authorization must happen server-side at every read/write boundary; IDs and selected-company state are not authorization.
- Password reset, password hashing, token issuance and cryptographic signing remain in maintained security libraries.
- No QR/barcode/static token should be accepted as sufficient authorization for a replayable redemption.
- Posted accounting movements remain immutable; a correction is a compensating movement.
- No production data/migrations or destructive seed/test commands as part of this planning work.
