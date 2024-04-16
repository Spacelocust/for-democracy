FROM golang:1.22-alpine

WORKDIR /usr/src/app

RUN apk add curl && curl -sSf https://atlasgo.sh | sh &&\
  go install github.com/bokwoon95/wgo@latest

COPY ./api/go.mod ./api/go.sum ./

RUN go mod download &&\
  go mod verify

EXPOSE 5000
