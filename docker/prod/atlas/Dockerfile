FROM alpine:3.20

COPY --from=arigaio/atlas:latest atlas /usr/bin/atlas

COPY ./api/migrations /migrations

# Use SHELL to explicitly execute the command with shell  (e.g. https://docs.docker.com/reference/build-checks/json-args-recommended/)
SHELL ["/bin/sh", "-c"] 

ENTRYPOINT atlas migrate apply --dir file://migrations --url $DATABASE_URL
