# Dependency matrix

**Snapshot date:** 2026-10-29. Locked versions below are reconciled with the current `Gemfile.lock` for direct gems changed during modernization; other rows still show the original audit snapshot and must be refreshed before release. Registry version is the latest stable version returned during inspection, not a tested upgrade target. RubyGems/OSV checks do not prove full compatibility or exploitability. Resolve and test gems as coordinated groups at each Rails checkpoint.

## Direct dependencies

| Gem | Locked | Latest stable checked | Use/evidence | Recommendation and compatibility notes |
|---|---:|---:|---|---|
| rails | 8.0.5.1 | 8.0.5.1 | Framework | Approved and validated target for this modernization; Rails 8.1 is deferred |
| pg | 1.7.0 | 1.7.0 | PostgreSQL adapter | Updated; still verify against deployment PostgreSQL/client |
| puma | 3.12.6 | 8.0.2 | `config/puma.rb` | Still old; update with Rack and verify deployment behavior |
| jbuilder | 2.15.1 | 2.15.1 | API response templates | Updated; retain JSON contract tests |
| bootsnap | 1.26.1 | 1.26.1 | `config/boot.rb` | Updated for target Ruby; verify clean boot/cache invalidation |
| searchlight | 4.1.0 | 4.1.0 | `app/searches/user_search.rb` | Replace one use with parameterized Active Record; upstream says project is done |
| pusher | 1.3.0 | 2.1.1 | `Notification` callback/initializer | Confirm active production use and private channel configuration; then update or remove |
| rspec-rails | 6.1.5 | 8.0.4 | Specs | Updated for Rails 8.0; suite still has pending examples |
| factory_bot_rails | 5.0.2 | 6.5.1 | Factories | Retain; fix empty/incomplete factories |
| byebug | 11.0.1 | 13.0.0 | Dev/test | Optional; `debug` standard gem is an alternative |
| pry-rails | 0.3.9 | 0.3.11 | Dev console | Keep only if developer workflow uses it |
| faker | 1.9.3 | 3.8.0 | Test group | No usage found in source; remove if confirmed unused |
| capybara | 3.17.0 | 3.40.0 | Test group | No browser/system specs found; keep only if planned browser tests need it |
| guard-rspec | 4.7.3 | 4.7.3 | Test group | No Guardfile or use found; remove if confirmed unused |
| launchy | 2.4.3 | 3.1.1 | Test group | No use found; remove if confirmed unused |
| database_cleaner | 1.7.0 | 2.1.0 | `spec/spec_helper.rb` | Prefer supported RSpec transactional fixtures where possible; validate truncation need |
| listen | 3.1.5 | 3.10.1 | Development watcher | Update if watcher remains required |
| spring | 2.0.2 | 4.7.0 | Binstubs | Remove unless measured workflow benefit; Rails 7 needs Spring >= 3 |
| spring-watcher-listen | 2.0.1 | 2.1.0 | Development watcher | Remove with Spring or update compatible pair |
| rb-readline | 0.5.5 | 0.5.5 | Dev | Old, no usage found; remove if confirmed unused |
| rails-erd | 1.5.2 | 2.2.0 | Development ERD | Optional tooling; update only if retained |
| cloudinary | 2.4.5 | 2.4.5 | Staging group and uploader conditional | Updated; adapter loads, but full staging boot needs deployment configuration |
| tzinfo-data | Not resolved as direct lock entry | 1.2026.6 | Non-MRI platform conditional | Keep only where target platform needs bundled zoneinfo |
| omniauth | 1.9.2 | 2.3.1 | OAuth initializer/routes | Not yet migrated; review CSRF/state and provider callback behavior |
| omniauth-facebook | 9.0.0 | 11.0.0 | Facebook provider | Updated; confirm provider requirements/scopes and callback |
| omniauth-google-oauth2 | 0.8.0 | 1.2.3 | Google provider | Still old; update and test scopes, callback and state |
| devise_token_auth | 1.3.0 | 1.3.0 | Auth, token headers, custom controllers | Updated for Rails 8.0; still verify token/header contract end-to-end |
| rack-cors | 1.0.5 | 3.0.0 | CORS initializer | Update with Rack; limit origins after Angular domains are confirmed |
| apipie-rails | 1.5.1 | 1.5.1 | Mounted API docs | Updated; keep for migration period, but do not mistake examples for contract |
| carrierwave | 3.1.4 | 3.1.4 | User/company/promotion uploads | Locked and tested with the approved Rails 8.0.5.1 target; Rails 8.1 compatibility is outside this plan |
| kaminari | 1.1.1 | 1.3.1 | Paginated API queries | Update; bound max `per_page`; test legacy meta shape |
| pundit | 2.0.1 | 2.5.2 | Selected policies | Retain and systematically apply authorization; version is not a substitute for policy tests |

## Relevant locked transitives

“Latest” means registry snapshot only. Upgrade targets must be selected by Bundler constraints and Rails-compatible gemspec/CI matrices, not by independently forcing the latest release.

| Gem(s) | Locked | Latest stable checked | Finding / action |
|---|---:|---:|---|
| actioncable, actionmailer, actionpack, actionview, activejob, activemodel, activerecord, activestorage, activesupport, railties | 5.2.3 | 8.1.4 | Move as a Rails release set; multiple advisories affect the old component versions; audit feature/default changes |
| rack | 2.2.2 | 3.2.7 | Old version has numerous OSV advisories; move with Rails/Puma/CORS and session middleware |
| devise | 4.4.3 | 5.0.4 | Auth dependency; latest requires Rails >= 7 and is allowed by DTA 1.3.0; test password/token compatibility |
| responders | 2.4.1 | 3.2.1 | Old line caps Rails below 6; update with Devise/Rails |
| omniauth-oauth2 | 1.6.0 | 1.10.0 | Coordinate with OAuth2, Faraday, provider gems and Rack |
| oauth2 | 1.4.1 | 2.1.0 | Breaking API major; provider compatibility gate |
| faraday | 0.15.4 | 2.15.1 | Breaking API major; update as OAuth/cloud integration set |
| jwt | 2.2.1 | 3.3.0 | Security-sensitive; use maintained library; review OSV fixed ranges and key config |
| bcrypt | 3.1.12 | 3.1.22 | Security-sensitive password hashing; do not replace or implement hashing; verify password compatibility |
| nokogiri | 1.10.8 | 1.19.4 | Many OSV matches; native extension; update with sanitizer/Marcel and supported Ruby |
| loofah, rails-html-sanitizer | 2.3.1, 1.0.4 | 2.25.2, 1.7.1 | Known old-version advisory matches; update as compatible pair |
| CarrierWave dependencies: marcel, mimemagic | Current lock omits mimemagic | Current lock resolves cleanly | Clean temporary bundle install succeeded on Ruby 3.4.12/Bundler 2.6.9; Rails 8.1 compatibility remains a separate gate |
| puma, nio4r, websocket-driver, websocket-extensions | 3.12.2, 2.3.1, 0.7.0, 0.1.3 | 8.0.2, 2.7.5, 0.8.2, 0.1.5 | Multiple known old-version advisory matches; update with runtime and Action Cable requirements |
| kaminari family | 1.1.1 | 1.3.1 | Locked kaminari has CVE-2020-11082 match; advisory fixed in 1.2.1; review whether HTML helper path is reachable |
| rake | 12.3.2 | 13.4.2 | Version match for CVE-2020-8130; upgrade tooling dependency |
| concurrent-ruby | 1.1.5 | 1.3.8 | OSV matches; verify Rails/Ruby constraints and logger load behavior |
| globalid | 0.4.2 | 1.3.0 | OSV match; Rails framework set controls target |
| mail | 2.7.1 | 2.9.1 | OSV match; framework-managed dependency; validate mail rendering/delivery |
| msgpack | 1.2.10 | 1.8.6 | OSV match; Bootsnap dependency/native build |
| addressable, public_suffix | 2.6.0, 3.0.3 | 2.9.0, 7.0.5 | Upgrade constraints through OAuth/Launchy/Capybara; do not force incompatible major |
| i18n, tzinfo, thread_safe | 1.6.0, 1.2.5, 0.3.6 | 1.15.2, 2.0.6, 0.3.6 | Rails-managed; tzinfo old version has OSV advisory match |
| factory_bot | 5.0.2 | 6.6.0 | Align with factory_bot_rails and repair factories |
| rspec, rspec-core, expectations, mocks/support | 3.8.x | 3.13.x | Keep RSpec suite components aligned; use matching rspec-rails support |
| spring watcher chain: listen, rb-inotify, rb-fsevent, ruby_dep | 3.1.5, 0.10.0, 0.10.3, 1.5.0 | 3.10.1, 0.11.1, 0.11.2, 1.5.0 | Remove with Spring if unnecessary; `ruby_dep`/watcher chain is old |
| rest-client, http-cookie, domain_name, unf | 2.0.2, 1.0.3, 0.5.20180417, 0.1.4 | 2.1.0, 1.1.6, 0.7.20261007, 0.2.0 | Cloudinary/transitive HTTP set; inspect reachability and redirect behavior |
| arel, aws_cf_signer, choice, guard-compat, nenv, notiffany, shellany, ruby_dep | see lock | several last released 2014–2019 | Old tooling/transitive gems; remove with unused Guard/legacy dependencies where possible |
| Remaining 80+ locked gems | see `Gemfile.lock` | checked against RubyGems registry | No matching OSV version result is not a safety assertion; resolve as transitive graph at each bundle stage and scan the exact resulting lock |

## Advisory interpretation

Version matches were obtained from OSV on 2026-10-29. Examples include Devise Token Auth CVE-2019-16751, OmniAuth CVE-2015-9284 and CVE-2020-36599, Kaminari CVE-2020-11082, and framework/Rack/Puma/Nokogiri/CarrierWave advisory ranges. Reachability matters: the CarrierWave RMagick advisory does not establish exposure here because the uploader does not include RMagick; Active Record YAML serialization advisory requires a relevant serialized-column path not observed in the schema. The full lock must be rescanned after every resolution.

## Removal rules

- Remove only after repository and runtime usage checks, including CI/deploy scripts and operators' workflows.
- Do not remove Devise, bcrypt, JWT, OAuth or token libraries and replace them with custom security code.
- Do not introduce a new search library for the one simple query; use parameterized Active Record.
- Do not add a background worker, Redis, image processing or wallet SDK without an approved use case.
- Review file storage separately from Rails/gem updates so existing user uploads remain accessible.
