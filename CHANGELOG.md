# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-18

### Added

- `Sendio::Transactional` (`/transactional`): `create` (with `options: { idempotency_key: }`), `list` (`search`, `template_id`, pagination), `get` (with the published version's `variables`), `update` (`expected_updated_at` for a 409 on a stale save), `remove`, `send_test` and `stats`. `track_opens` and `track_clicks` are off by default.
- `Sendio::Emails.send` and `Sendio::Batch.send` documented for `transactional_id`, `variables`, `track_opens` and `track_clicks`; email objects carry `transactional_id`.
- Broadcasts documented for `template_id` and `template_version_id` (create and update), `template_id: nil` to detach, and `unfillable_variables` on `Sendio::Broadcasts.get`.
- Documented the automation template categories `appointments`, `events`, `education`, `account` and `nonprofit`.

## [1.0.0] - 2026-11-11

First public release.

### Removed

- `Sendio::Domains::Claims` (`.create`, `.get`, `.verify`): the API has no domain-claim routes, so every call failed with a 404. Claim a domain by deleting it from the team that owns it, then adding it to yours.

### Added

- `Sendio::Automations::Templates.list` (optional `category:` filter) and `.get(slug)` to browse the automation template catalog, and `Sendio::Automations.create_from_template(params, options: { idempotency_key: })` to create a disabled automation from a template.
- `Sendio::Mailboxes` with `.list`, `.create`, `.update`, `.reset_password` and `.remove`, to manage mailboxes (email accounts with an IMAP/SMTP login).
- `Sendio::Broadcasts.estimate`, `.test`, `.stats`, `.list_versions`, `.get_version`, `.update_version` and `.restore_version`.
- Documented `capabilities: { receiving: "enabled" | "disabled" }` on `Sendio::Domains.create` and `Sendio::Domains.update` to turn email receiving on or off for a domain (turning it on asks for the domain's MX record, publish it to start receiving email; sending can't be disabled).
- Documented the full set of broadcast create/update fields (`segment_ids`, `exclude_segment_ids`, `audience`, `unsubscribe_scope`, `tracking`, `template_engine`, `topic_id`, `preview_text`) and the `status`, `segment_id` and `search` list filters.

### Fixed

- `Sendio::Broadcasts.update` and `.send` no longer send `broadcast_id` in the JSON body; it goes only in the path (the API rejects any key but `name` when updating a sent broadcast).

### Added

- First release of the official send.io Ruby SDK (`sendio` gem).
- Default API base URL `https://api.send.io`, overridable with `SENDIO_BASE_URL` or `Sendio.base_url = "..."` at runtime (trailing slash optional).
