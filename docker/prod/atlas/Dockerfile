FROM arigaio/atlas:latest

COPY migrations /migrations

CMD atlas migrate apply --dir file://migrations --url $DATABASE_URL 
