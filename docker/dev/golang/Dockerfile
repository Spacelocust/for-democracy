FROM golang:1.22-alpine

WORKDIR /usr/src/app

RUN apk add curl &&\ 
  ## Package only for development
  curl -sSf https://atlasgo.sh | sh &&\
  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.57.2 &&\
  go install github.com/swaggo/swag/cmd/swag@latest &&\ 
  go install github.com/bokwoon95/wgo@latest

COPY ./api/go.mod ./api/go.sum ./

RUN go mod download &&\
  go mod verify

EXPOSE 5000
