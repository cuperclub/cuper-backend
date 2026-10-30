# Backup and restore rehearsal

This is a safe, provider-neutral checklist for planning a backup restore. It is not an executable production procedure: the deployment owner must fill in the platform-specific backup, encryption, storage, and recovery details before a rehearsal or production operation.

## Required deployment details

| Detail | Owner confirmation |
|---|---|
| PostgreSQL provider, major version, extensions, and connection method | Required |
| Encrypted backup mechanism, schedule, retention, and encryption-key custody | Required |
| File/object storage provider and how uploaded assets are backed up | Required |
| Isolated restore environment and access controls | Required |
| Recovery point and recovery time objectives | Required |

Do not put credentials, encryption keys, connection strings, or backup contents in this repository. Do not infer any of the values above from local development configuration.

## Rehearsal procedure

1. Obtain explicit approval for a sanitized backup or synthetic dataset. Never connect this procedure to production.
2. Record the source backup timestamp, PostgreSQL version, encryption method, checksum, and matching asset snapshot identifier.
3. Verify the backup artifact using the provider's supported integrity check before restoring it.
4. Restore into a new, isolated database using a compatible PostgreSQL version. Restore matching uploaded assets into isolated storage; do not overwrite existing files.
5. Run schema and application smoke checks against the restored copy. Use dummy identities and do not send real mail, Pusher events, or external callbacks.
6. Verify representative records and point-ledger reconciliation without changing restored balances. Record elapsed restore time and any missing assets.
7. Remove the isolated database and temporary assets after approval; retain only the non-sensitive rehearsal result and checksum.

## Prohibited shortcuts

- Do not run `db:seed`; the current seed file destroys application tables.
- Do not restore over production or a shared database.
- Do not claim recovery readiness until the owner confirms the deployment values above and a rehearsal succeeds.

## Local synthetic check

On 2026-10-30, a disposable PostgreSQL 17 container with networking disabled was initialized from the repository schema. A custom-format `pg_dump` was restored into a separate database, then the Rails models verified a synthetic user's balance and ledger total both restored as 17. The container and scratch data were removed afterward.

This only verifies a local PostgreSQL dump/restore path. It did not test backup encryption/key custody, uploaded-file recovery, provider tooling, production settings, or a sanitized production backup; those remain release gates.
