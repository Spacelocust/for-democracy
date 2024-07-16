FROM golang:1.22-alpine AS builder

WORKDIR /go/src/app

COPY /api/go.* ./

# Install dependencies
RUN go mod download &&\
  go mod verify

COPY /api .

# Remove the migrations folder and build the binary
RUN rm -rf /migrations && GOOS=linux GOARCH=amd64 go build -o fd-democracy main.go

FROM debian:buster-slim AS runner

RUN apt-get update && apt-get install -y \
  curl \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /go/src/app/fd-democracy /go/bin/fd-democracy

ENV PATH="/go/bin:${PATH}"

ENTRYPOINT ["fd-democracy", "gin-server"]
