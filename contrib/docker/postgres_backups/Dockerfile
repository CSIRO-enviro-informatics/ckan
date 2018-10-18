FROM prodrigestivill/postgres-backup-local
# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
# Disable the default prodigestivill health check which is just pinging localhost or a parameterizable port and useful for us
HEALTHCHECK NONE 
CMD /usr/local/bin/go-cron -s "$SCHEDULE" -p "$HEALTHCHECK_PORT" -- /backup.sh
