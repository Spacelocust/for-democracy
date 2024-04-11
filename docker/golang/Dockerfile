FROM golang:1.22-alpine

WORKDIR /usr/src/app

COPY ./api/go.mod ./api/go.sum ./

RUN go mod download && \
    go mod verify && \
    go install github.com/bokwoon95/wgo@latest

EXPOSE 5000
