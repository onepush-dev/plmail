# plMail on Railway: the official image (pinned by digest) in its all-in-one mode
# (web server, queue workers, scheduler, push listeners and Mercure hub in one
# container, plain HTTP on :80 behind Railway's TLS edge). Everything plMail writes
# (generated secrets, attachments, raw messages, uploads) lives on ONE Railway
# volume mounted at /app/var/data.
FROM ghcr.io/karatektus/pl_mail:0.4.1@sha256:fb0d453584d8e86d34459538b281bbc0aecab947c0d38864d662c549fcd0c9b9
LABEL org.opencontainers.image.source="https://github.com/onepush-dev/plmail" \
      org.opencontainers.image.licenses="AGPL-3.0-only" \
      org.opencontainers.image.description="plMail (karatektus/pl_mail 0.4.1) packaged for Railway"
# Defaults baked into the image because Railway templates drop plain variable values.
# Any of these can still be overridden in the service Variables.
ENV APP_ALL_IN_ONE=1 \
    SERVER_NAME=":80" \
    APP_STORAGE_DIR=/app/var/data \
    APP_SECRETS_DIR=/app/var/data/secrets \
    APP_SECRETS_FILE=/app/var/data/secrets/generated.env \
    TRUSTED_PROXIES="127.0.0.1,10.0.0.0/8,100.64.0.0/10,172.16.0.0/12,192.168.0.0/16,fd00::/8" \
    APP_DEFAULT_TIMEZONE=UTC
EXPOSE 80
