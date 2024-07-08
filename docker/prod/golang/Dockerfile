FROM golang:1.22-alpine as builder

WORKDIR /go/src/app

COPY /api/go.* ./

# Install dependencies
RUN go mod download &&\
  go mod verify

COPY /api .

# Build the binary
RUN go build -o fd-democracy GOOS=linux GOARCH=amd64 main.go

FROM debian:buster-slim as runner

# Copy the binary from the builder stage
COPY --from=builder /go/src/app/fd-democracy /go/bin/fd-democracy

ENV PATH="/go/bin:${PATH}"

EXPOSE 5000

CMD ["fd-democracy"]
