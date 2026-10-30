# Observable API contract

**Status:** routes were captured from the booted application in [`runtime-routes.txt`](runtime-routes.txt); the full RSpec suite passes on a fresh disposable PostgreSQL database. Payloads and legacy Angular usage have not been comprehensively validated because the frontend repository/fixtures are unavailable. Do not treat Apipie examples as complete truth: `config/initializers/apipie.rb` sets `validate = false`, and some examples are stale or syntactically illustrative.

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
| PUT | `/api/users/current_view` | `#current_view` | Authenticated; body currently reads `company_id`; response `{company_id,expired_plan}` |
| GET | `/api/users/my_transactions` | `#my_transactions` | Authenticated; `{transactions:[...],meta:{total_count}}`; page/per_page defaults 1/5 |
| GET/POST | `/api/admin/categories` | Admin categories index/create | Index/create callbacks exclude auth in source; list `{categories:[...]}`, create 201 |
| GET/PUT/PATCH/DELETE | `/api/admin/categories/:id` | Admin categories show/update/destroy | Show/update auth; update uses `{category:{...}}`, success 202; destroy action is not defined |
| GET/POST | `/api/admin/plans` | Admin plans index/create | Index/create callbacks exclude auth in source; `{plans:[...]}` plus promotional plan on index; create 201 |
| GET/PUT/PATCH/DELETE | `/api/admin/plans/:id` | Admin plans show/update/destroy | Show/update auth; update success 202; destroy action is not defined |
| GET/PUT | `/api/admin/app_settings/settings` | `#settings` | Authenticated; app setting and plans from Jbuilder; success 202 |
| PUT | `/api/admin/app_settings/update_settings` | `#update_settings` | Authenticated; requires `app_setting` keys; success 202 |
| GET | `/api/admin/app_settings` | Default singular-resource show | Route is declared but controller `show` is not evident; verify runtime |
| PUT/PATCH | `/api/admin/app_settings` | Default singular-resource update | Route is declared but controller action differs (`update_settings`); verify runtime |
| GET | `/api/admin/companies` | `#index` | `authenticate_user!`; `{companies:[...]}`; admin-only policy not evident |
| GET | `/api/admin/companies/:id` | `#show` | Authenticated; success 202 |
| PUT | `/api/admin/companies/:id/change_status` | `#change_status` | Authenticated; `status`, `feedback`; authorization role not evident |
| GET | `/api/admin/users` | `#index` | Authenticated; `{users:[...],meta:{total_count}}`; page/per_page defaults 1/5 and Pundit policy invoked |
| GET | `/api/admin/users/:role` | `#index` through custom collection route | Role filtering only for `Employee::ROLES`; route precedence requires runtime confirmation |
| PUT | `/api/admin/users/:id/toggle_status` | `#toggle_status` | Authenticated; `{active:boolean}`; admin authorization not evident |
| PUT | `/api/admin/users/:id/update_password` | `#update_password` | Authenticated; password action has no evident admin authorization; currently sends password via email |
| POST | `/api/partner/companies` | `Api::Partner::CompaniesController#create` | Authenticated; company fields and optional `plan_id`; returns company (201) |
| GET | `/api/partner/companies` | `#show` | Authenticated; uses selected company context |
| PUT/PATCH | `/api/partner/companies` | `#update` | Authenticated; returns company (202) |
| POST | `/api/partner/companies/request_employee` | `#request_employee` | Authenticated; requires `user_id` in query/params; serializer response needs fixture |
| GET | `/api/partner/companies/pending_requests_employee` | `#pending_requests_employee` | Authenticated; array serializer |
| GET | `/api/partner/companies/promotions` | Partner promotions index | Authenticated; `{promotions:[...],meta:{total_count}}`, page/per_page defaults 1/5 |
| GET | `/api/partner/companies/promotions/:id` | Partner promotions show | Authenticated; selected company-scoped lookup |
| GET | `/api/partner/companies/promotions/:id/transaction_outputs` | `#transaction_outputs` | Authenticated; transaction output envelope; total_count hard-coded 0 |
| GET | `/api/partner/companies/offices` | Partner offices index | Authenticated; `{offices:[...]}` |
| POST | `/api/partner/companies/offices` | `#create` | Authenticated; request permits `company_id`; ownership must be corrected, JSON office partial, success 201 |
| GET | `/api/partner/companies/offices/:id` | `#show` | Authenticated; lookup scoped to selected company |
| PUT/PATCH | `/api/partner/companies/offices/:id` | `#update` | Authenticated; permits `company_id`; success 202 |
| PUT | `/api/partner/companies/offices/:id/toggle_status` | `#toggle_status` | Authenticated; `{active:boolean}`; policy uses `is_employee` |
| POST | `/api/partner/companies/offices/:office_id/promotions` | Partner promotions create | Authenticated; server resolves office under selected company; 201 |
| PUT/PATCH | `/api/partner/companies/offices/:office_id/promotions/:id` | Partner promotions update | Authenticated; scoped through office; success 202 |
| GET | `/api/partner/companies/employees` | Partner employees index | Authenticated; `{employees:[...]}` |
| GET | `/api/partner/companies/employees/:id` | Partner employees show | Authenticated; scoped through selected company |
| PUT | `/api/partner/companies/employees/:id/update_state` | `#update_state` | Authenticated; nested `employee.status`, `employee.feedback`; success 202 |
| POST | `/api/cashier/profile` | Cashier profile create | Authenticated; `company_id`; `{status:"accepted"}`, HTTP 202 |
| GET | `/api/transaction_inputs` | Transaction inputs index | Authenticated; employee context; `{transaction_inputs:[...],meta:{total_count}}`, page/per_page 1/5 |
| POST | `/api/transaction_inputs` | Transaction inputs create | Authenticated; nested `transaction_input.user_id` (or legacy `national_id` fallback), `.points`, `.invoice_number`; 201 or 422 |
| GET | `/api/transaction_outputs` | Transaction outputs index | Authenticated; employee context; `{transaction_outputs:[...],meta:{total_count}}`, page/per_page 1/5 |
| POST | `/api/transaction_outputs` | Transaction outputs create | Authenticated; nested `transaction_output.user_id` (or legacy `national_id` fallback), `.promotion_id`, `.invoice_number`; client `.points` is ignored, cost comes from the company-scoped promotion, employee cannot redeem their own promotion; 201 or 422 |

### Authentication routes

`mount_devise_token_auth_for "User", at: "auth"` in `config/routes.rb` adds Devise Token Auth routes. The locked version is **1.3.0** and `config/initializers/devise_token_auth.rb` sets the OmniAuth prefix to `/api/auth/user` and disables per-request header rotation. Runtime paths and methods are captured in `runtime-routes.txt`.

The source override controllers render the shared Jbuilder login/registration/token-validation response at `app/views/api/auth/sessions/user.json.jbuilder`, shaped as `{success?,data:{...}}`. The mounted auth routes include sign-in, sign-out, registration, token validation, password actions and OmniAuth callbacks according to gem configuration. Exact runtime paths/methods are captured; redirect behavior, error bodies and headers still need request-level coverage.

Headers exposed by CORS initializer: `access-token`, `expiry`, `token-type`, `uid`, `client`. No server-side rotation on every request is configured. Do not migrate these names without explicit client coordination.

## Observed request and response details

| Flow | Request evidence | Response evidence / unknowns |
|---|---|---|
| Accrual | `transaction_input` contains `user_id` (legacy `national_id` fallback), `points`, optional `invoice_number`; points are multiplied by company category's integer `points_per_dollar` | Transaction input partial includes points and user; notification is sent separately; validate type coercion and exact unit |
| Redemption | `transaction_output` contains `user_id` (legacy `national_id` fallback), `promotion_id`, optional invoice number; client points are ignored | Promotion is scoped to employee company and configured points are charged; response property shape is unchanged |
| Pagination | `page` and `per_page`, default 1 and 5 in controllers | Some list endpoints omit pagination; no max per_page observed |
| Error handling | Model errors rendered as JSON for common validation failures; `RecordNotFound` becomes `{error: message}`, 404; Pundit becomes `{error: message}`, 401 | Error content and status vary; fixture before refactor |
| Timestamps | Several Jbuilder partials turn timestamps into epoch milliseconds; others serialize Rails datetime | Preserve per-field format; verify exact precision and timezone |
| Files | `image_url`, `logo_url`, and raw `logo` appear in different partials | URLs/storage behavior depend on CarrierWave config; not normalized in modernization |
| Nullability | Jbuilder extraction/conditionals produce a mix of omitted keys, nulls and optional nested objects | Capture fixtures with missing associations/settings before declaring schemas |

## OpenAPI completeness and change gate

`openapi.yaml` is an initial source-evidence subset. It intentionally marks unspecified schemas as unverified and excludes generated Devise details pending route capture. Add endpoints in small batches with request specs and fixture-backed response schemas. CI should lint the document and compare operation IDs/method/path to an approved route manifest. A change to an existing endpoint requires a compatibility review and frontend matrix run.

## Decisions / frontend questions

- Which listed endpoints are actually consumed by the old Angular frontend? No frontend repository is present.
- Does Angular send `user_id` or `national_id` on transaction requests? Existing skipped specs use `national_id`, current controller reads `user_id`.
- Which status codes does the client rely on, especially successful GETs returning 201/202?
- Are token headers updated/persisted by the frontend even though server rotation is disabled?
- Which exact payloads handle login, expired token, Pundit rejection, validation failure and OAuth failure?
- Does the client rely on singular `/api/users/:id` update semantics, raw dates, or current file URLs?
- Is the API same-origin behind a proxy, and what are the actual Angular origins?
