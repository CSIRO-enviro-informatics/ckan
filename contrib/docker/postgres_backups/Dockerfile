FROM prodrigestivill/postgres-backup-local
# Add Tini
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD /usr/local/bin/go-cron -s "$SCHEDULE" -p 80 -- /backup.sh
