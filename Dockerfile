# Debian 13 (trixie), the current stable. The image keeps its "bookworm" name
# because every site's compose file pulls it by that name.
FROM php:apache-trixie

# Require the emergency PHP fixes even while upstream images are still rebuilding.
COPY update-php-security.sh /usr/local/sbin/update-php-security
RUN sh /usr/local/sbin/update-php-security 8.5.12 08bc2eba2a588654ade1357174aa646b761556c862dda0678345ee29ed481209
ENV PHP_SECURITY_MIN_VERSION=8.5.12

ENV MSMTP_MAILHOST=mailserver
ENV MSMTP_TLS=off
ENV MSMTP_STARTTLS=off
ENV MSMTP_TLS_CERTCHECK=off
ENV MSMTP_AUTH=off
ENV MSMTP_FROM=mailer
ENV MSMTP_PORT=25
ENV MSMTP_LOGFILE=/var/log/msmtp.log

RUN --mount=type=cache,target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get dist-upgrade -y && apt-get install msmtp rsync gettext-base --no-install-recommends -y
   
COPY tree/ /
ENTRYPOINT ["entrypoint-override.sh"]
CMD ["apache2-foreground"]
