FROM arigaio/atlas:latest

COPY ./api/migrations /migrations

CMD atlas migrate apply --dir file://migrations --url $DATABASE_URL 
