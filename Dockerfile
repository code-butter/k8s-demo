FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY main.go ./
RUN go build -o demo .

FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/demo .

ENTRYPOINT ["./demo"]