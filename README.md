# plMail on Railway: self-hosted Gmail-style webmail for your IMAP accounts

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/ISpEg3)

[plMail](https://github.com/karatektus/pl_mail) (AGPL-3.0) is a self-hosted webmail client with a Gmail-like UI: several IMAP/SMTP accounts in one inbox, conversation threads, real-time updates, search, contacts, calendar, templates, scheduled send and optional Gmail/Outlook OAuth. This template runs the official image in its **all-in-one mode** (web server, queue workers, scheduler, push listeners and the Mercure live-update hub in one container) next to Postgres 18 (Alpine, the same image upstream's compose uses).

Image: `ghcr.io/onepush-dev/plmail:0.4.1` = official `ghcr.io/karatektus/pl_mail:0.4.1` (pinned by digest) + a small entrypoint wrapper (listens on Railway's `$PORT` for the healthcheck, creates the first admin from `ADMIN_PASSWORD`, then runs upstream's own entrypoint: secrets, migrations, server). Defaults baked into the image: `APP_ALL_IN_ONE=1`, storage + secrets under `/app/var/data`, `TRUSTED_PROXIES` including Railway's edge range, `APP_DEFAULT_TIMEZONE=UTC`.

## Services
| Service | Image | Notes |
|---|---|---|
| plMail | `ghcr.io/onepush-dev/plmail:0.4.1` | public HTTPS domain (port 80), health `/healthz`, restart always, volume `/app/var/data` (generated secrets incl. the encryption key, attachments, raw messages, uploads) |
| Postgres | `postgres:18-alpine` (pinned by digest) | private, volume `/var/lib/postgresql`, `pg_stat_statements` preloaded like upstream |

## First run
Zero inputs. Open your Railway domain and sign in as **admin@plmail.local** with the password in the plMail service's `ADMIN_PASSWORD` variable (the admin is created on first boot, so the public `/install` page is never left open). Change the email and password in Settings, then add your mail accounts (IMAP/SMTP, or Gmail/Outlook via OAuth once you configure the OAuth app variables).

## Notes
- `/app/var/data/secrets/generated.env` holds `APP_SECRET`, `APP_ENCRYPTION_KEY` (protects every stored mail password), the Mercure key and the push/JWT keypairs. It is generated on first boot and lives on the volume; back it up together with the database.
- `APP_PUBLIC_URL` follows your Railway domain (used for OAuth callbacks, push subscriptions and the live-update hub); change it if you add a custom domain.
- Optional: `GOOGLE_OAUTH_CLIENT_ID/SECRET`, `MICROSOFT_OAUTH_CLIENT_ID/SECRET`, `OIDC_*` single sign-on, `APP_DEFAULT_TIMEZONE`. See upstream [configuration reference](https://github.com/karatektus/pl_mail/blob/main/docs/install/configuration.md).
- plMail sends mail through each user's own account; no SMTP relay is needed. ntfy push (optional upstream profile) is not included.

## License
plMail is AGPL-3.0 (source: upstream v0.4.1). This repo only holds Railway packaging.
