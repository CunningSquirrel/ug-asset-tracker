# Migrate image: applies db/*.sql to Postgres on every start, then exits.
# Built by GitHub Actions → ghcr.io/<owner>/ug-asset-tracker-migrate
FROM postgres:17.2-alpine
COPY db/ /db/
RUN chmod +x /db/migrate.sh
ENTRYPOINT []
CMD ["/db/migrate.sh"]
