# Observable API contract

**Status:** routes were captured from the booted application in [`runtime-routes.txt`](runtime-routes.txt); backend regression specs pass. This source-derived contract is the handoff to the Angular owner, who owns client adaptation and frontend fixtures. Do not treat Apipie examples as complete truth: `config/initializers/apipie.rb` sets `validate = false`, and some examples are stale or syntactically illustrative.

## Compatibility rules

- Keep existing paths, methods, token header names, response envelope, property spelling, nullability and status codes unless a reviewed change explicitly approves otherwise.
- Preserve Devise Token Auth header rotation setting (`config.change_headers_on_each_request = false`) until frontend coordination and tests prove a safe change.
- Keep Jbuilder as the serialization boundary while internal models/columns evolve.
- Do not turn accidental access to another tenant into a compatibility requirement. Fix authorization while preserving legitimate successful calls.
- Mark behavior as unverified where source does not determine the serialized type, route precedence, or authentication behavior.
- OpenAPI in `openapi.yaml` is deliberately partial. Add an operation only after checking route, controller, serializer and auth evidence.

## Application routes

| Method | Path | Action/response evidence | Auth/contract notes |
|---|---|---|---|
| GET | `/` | Redirects to `/apipie` | Documentation root |
| GET | `/apipie` and documentation routes | Apipie mount | Runtime routes are recorded in `runtime-routes.txt` |
| GET/POST/PUT/PATCH/DELETE | `/transaction_inputs` and `/:id` | Root `TransactionInputsController` has no actions | Declared route only; likely not functional |
| GET/POST/PUT/PATCH/DELETE | `/transaction_outputs` and `/:id` | Root `TransactionOutputsController` is empty | Declared route only; do not infer API behavior |

## JSON API routes declared in `config/routes.rb`

Unless noted, `namespace :api` supplies JSON defaults. “Auth” below reflects controller callbacks in source, not every inherited Devise middleware detail.

| Method | Path | Controller/action | Auth and observable response |
|---|---|---|---|
| GET | `/api/companies` | `Api::CompaniesController#index` | No auth callback; `{companies:[...]}`; status 201 |
| GET | `/api/promotions` | `Api::PromotionsController#index` | `authenticate_user!`; `{promotions:[...]}` |
| GET | `/api/promotions/:id` | `Api::PromotionsController#show` | Authenticated; promotion partial |
| GET | `/api/notifications` | `Api::NotificationsController#index` | Authenticated; `{notifications:[...],meta:{total_count}}`, page/per_page defaults 1/5 |
| PUT | `/api/notifications/:id/answer_request_employee` | `#answer_request_employee` | Authenticated; result depends on kind/status; not-found/invalid status response needs tests |
| POST | `/api/notifications/read_pending_notifications` | `#read_pending_notifications` | Authenticated; `{status:"ok",total:n}`, 200 |
| GET | `/api/users` | `Api::UsersController#index` | Authenticated; JSON array of public-user partials, no pagination |
| PUT/PATCH | `/api/users` | `#update` | Authenticated; current user fields and status 202 on success |
| PUT/PATCH | `/api/users/:id` | `#update` | Declared ID is not used by action; behavior still updates current user. Confirm legacy dependency before changing. |
| GET | `/api/users/search` | `#search` | Authenticated; public-user array, query `query`, optional page; results capped at 10 |
| PUT | `/api/users/current_view` | `#current_view` | Authenticated; body reads `company_id` and requires approved company membership; response `{company_id,expired_plan}` |
| GET | `/api/users/my_transactions` | `#my_transactions` | Authenticated; `{transactions:[...],meta:{total_count}}`; page/per_page defaults 1/5 |
| GET/POST | `/api/admin/categories` | Admin categories index/create | Authenticated; index is available to authenticated users; create requires `is_admin`; list `{categories:[...]}`, create 201 |
| GET/PUT/PATCH/DELETE | `/api/admin/categories/:id` | Admin categories show/update/destroy | Show requires authentication; update requires `is_admin`, uses `{category:{...}}`, success 202; destroy action is not defined |
| GET/POST | `/api/admin/plans` | Admin plans index/create | Authenticated; index is available to authenticated users with plan filtering; create requires `is_admin`; index `{plans:[...]}` plus promotional plan; create 201 |
| GET/PUT/PATCH/DELETE | `/api/admin/plans/:id` | Admin plans show/update/destroy | Show requires authentication; update requires `is_admin`, success 202; destroy action is not defined |
| GET/PUT | `/api/admin/app_settings/settings` | `#settings` | Authenticated and `is_admin`; app setting and plans from Jbuilder; success 202 |
| PUT | `/api/admin/app_settings/update_settings` | `#update_settings` | Authenticated and `is_admin`; requires `app_setting` keys; success 202 |
| GET | `/api/admin/app_settings` | Default singular-resource show | Route is declared but controller `show` is not evident; verify runtime |
| PUT/PATCH | `/api/admin/app_settings` | Default singular-resource update | Route is declared but controller action differs (`update_settings`); verify runtime |
| GET | `/api/admin/companies` | `#index` | Authenticated and `is_admin`; `{companies:[...]}` |
| GET | `/api/admin/companies/:id` | `#show` | Authenticated and `is_admin`; success 202 |
| PUT | `/api/admin/companies/:id/change_status` | `#change_status` | Authenticated and `is_admin`; `status`, `feedback` |
| GET | `/api/admin/users` | `#index` | Authenticated; `{users:[...],meta:{total_count}}`; page/per_page defaults 1/5 and Pundit admin policy invoked |
| GET | `/api/admin/users/:role` | `#index` through custom collection route | Role filtering only for `Employee::ROLES`; route precedence requires runtime confirmation |
| PUT | `/api/admin/users/:id/toggle_status` | `#toggle_status` | Authenticated and `is_admin`; `{active:boolean}` |
| PUT | `/api/admin/users/:id/update_password` | `#update_password` | Authenticated and `is_admin`; sends Devise reset instructions; does not email a submitted password |
| POST | `/api/partner/companies` | `Api::Partner::CompaniesController#create` | Authenticated; company fields and optional `plan_id`; returns company (201) |
| GET | `/api/partner/companies` | `#show` | Authenticated; uses selected company context |
| PUT/PATCH | `/api/partner/companies` | `#update` | Authenticated; returns company (202) |
| POST | `/api/partner/companies/request_employee` | `#request_employee` | Authenticated; requires `user_id` in query/params; serializer response needs fixture |
| GET | `/api/partner/companies/pending_requests_employee` | `#pending_requests_employee` | Authenticated; array serializer |
| GET | `/api/partner/companies/promotions` | Partner promotions index | Authenticated; `{promotions:[...],meta:{total_count}}`, page/per_page defaults 1/5 |
| GET | `/api/partner/companies/promotions/:id` | Partner promotions show | Authenticated; selected company-scoped lookup |
| GET | `/api/partner/companies/promotions/:id/transaction_outputs` | `#transaction_outputs` | Authenticated; transaction output envelope; total_count hard-coded 0 |
| GET | `/api/partner/companies/offices` | Partner offices index | Authenticated; `{offices:[...]}` |
| POST | `/api/partner/companies/offices` | `#create` | Authenticated approved partner in selected company; office ownership is assigned from authorized context, JSON office partial, success 201 |
| GET | `/api/partner/companies/offices/:id` | `#show` | Authenticated; lookup scoped to selected company |
| PUT/PATCH | `/api/partner/companies/offices/:id` | `#update` | Authenticated approved partner in selected company; submitted company ownership is not trusted; success 202 |
| PUT | `/api/partner/companies/offices/:id/toggle_status` | `#toggle_status` | Authenticated; `{active:boolean}`; policy requires approved partner membership for the office's company |
| POST | `/api/partner/companies/offices/:office_id/promotions` | Partner promotions create | Authenticated; server resolves office under selected company; 201 |
| PUT/PATCH | `/api/partner/companies/offices/:office_id/promotions/:id` | Partner promotions update | Authenticated; scoped through office; success 202 |
| GET | `/api/partner/companies/employees` | Partner employees index | Authenticated; `{employees:[...]}` |
| GET | `/api/partner/companies/employees/:id` | Partner employees show | Authenticated; scoped through selected company |
| PUT | `/api/partner/companies/employees/:id/update_state` | `#update_state` | Authenticated; nested `employee.status`, `employee.feedback`; success 202 |
| POST | `/api/cashier/profile` | Cashier profile create | Authenticated; `company_id`; `{status:"accepted"}`, HTTP 202 |
| GET | `/api/transaction_inputs` | Transaction inputs index | Authenticated; employee context; `{transaction_inputs:[...],meta:{total_count}}`, page/per_page 1/5 |
| POST | `/api/transaction_inputs` | Transaction inputs create | Authenticated approved employee in selected company; nested `transaction_input.user_id` (or legacy `national_id` fallback), `.points` purchase amount, `.invoice_number`; 201, 409 keyed conflict, or 422 |
| GET | `/api/transaction_outputs` | Transaction outputs index | Authenticated; employee context; `{transaction_outputs:[...],meta:{total_count}}`, page/per_page 1/5 |
| POST | `/api/transaction_outputs` | Transaction outputs create | Authenticated approved employee in selected company; nested `transaction_output.user_id` (or legacy `national_id` fallback), `.promotion_id`, `.invoice_number`; client `.points` is ignored, cost comes from the company-scoped promotion, employee cannot redeem their own promotion; 201, 409 keyed conflict, or 422 |

### Authentication routes

`mount_devise_token_auth_for "User", at: "auth"` in `config/routes.rb` adds Devise Token Auth routes. The locked version is **1.3.0** and `config/initializers/devise_token_auth.rb` sets the OmniAuth prefix to `/api/auth/user` and disables per-request header rotation. Runtime paths and methods are captured in `runtime-routes.txt`.

The source override controllers render the shared Jbuilder login/registration/token-validation response at `app/views/api/auth/sessions/user.json.jbuilder`, shaped as `{success?,data:{...}}`. The mounted auth routes include sign-in, sign-out, registration, token validation, password actions and OmniAuth callbacks according to gem configuration. Exact runtime paths/methods are captured; redirect behavior, error bodies and headers still need request-level coverage.

Headers exposed by CORS initializer: `access-token`, `expiry`, `token-type`, `uid`, `client`. No server-side rotation on every request is configured. Do not migrate these names without explicit client coordination.

## Observed request and response details

| Flow | Request evidence | Response evidence / unknowns |
|---|---|---|
| Accrual | `transaction_input` contains `user_id` (legacy `national_id` fallback), `points`, optional `invoice_number`; `points` is the legacy purchase-amount input, converted by the company's integer `points_per_dollar` rate and rounded to whole points (halves up) | Transaction input partial includes calculated integer points and user; zero-point accruals are recorded; values above the exact JSON integer range are rejected; no currency code is carried |
| Plans | Admin API documents `price` as `Integer`; fractional, negative, non-finite, or out-of-safe-range prices are rejected | Price is serialized as an integer in existing whole API units; currency code and minor unit are not specified |
| Idempotency | `Idempotency-Key` on accrual and redemption; Angular generates one opaque UUID per user intent and reuses it for retries | Same key/same intent replays the original 201 without repeating balance, inventory, or notification effects; same key/different intent returns 409. Header remains optional during legacy transition; no-key retries cannot be distinguished safely from a new identical operation |
| Manual point events | Adjustment, expiry, reversal and opening-balance writes are internal model operations, not public HTTP endpoints; reconciliation is run with `rake points:reconcile` | Each event requires a unique per-user reference and reason; reversal creates an equal-and-opposite event; reconciliation report mode is read-only and `APPLY=1` appends ledger deltas without changing the balance |
| Redemption | `transaction_output` contains `user_id` (legacy `national_id` fallback), `promotion_id`, optional invoice number; client points are ignored | Promotion is scoped to employee company and configured points are charged; response property shape is unchanged |
| Pagination | `page` and `per_page`, default 1 and 5 in controllers | Some list endpoints omit pagination; no max per_page observed |
| Error handling | Model errors rendered as JSON for common validation failures; `RecordNotFound` becomes `{error: message}`, 404; Pundit becomes `{error: message}`, 401 | Error content and status vary; fixture before refactor |
| Timestamps | Several Jbuilder partials turn timestamps into epoch milliseconds; others serialize Rails datetime | Preserve per-field format; verify exact precision and timezone |
| Files | `image_url`, `logo_url`, and raw `logo` appear in different partials | URLs/storage behavior depend on CarrierWave config; not normalized in modernization |
| Nullability | Jbuilder extraction/conditionals produce a mix of omitted keys, nulls and optional nested objects | Capture fixtures with missing associations/settings before declaring schemas |

## OpenAPI completeness and change gate

`openapi.yaml` is an initial source-evidence subset. It intentionally marks unspecified schemas as unverified and excludes generated Devise details pending route capture. Add endpoints in small batches with request specs and fixture-backed response schemas. CI should lint the document and compare operation IDs/method/path to an approved route manifest. A change to an existing endpoint requires a compatibility review and frontend matrix run.

## Angular handoff

- Angular owns confirmation of consumed endpoints, payload/error adaptation, auth-header persistence, and frontend fixtures.
- For every accrual/redemption user intent, generate and persist one UUID before sending; send it as `Idempotency-Key`; reuse it for all retries after timeouts/network errors; generate a new UUID only for a distinct user intent. Do not derive keys from request payload, amount, invoice, or a time window.
- The backend header remains optional until the Angular client adopts it; requests without it keep the legacy API behavior but are not retry-safe.
- Deployment origin/proxy configuration is deferred to the separate Dockerization/deployment task.
