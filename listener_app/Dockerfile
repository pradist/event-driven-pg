# 1. Build stage: use an image with the Go compiler to build the application
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum to download dependencies
COPY go.mod .
COPY go.sum .

# Download dependencies
RUN go mod download

# Copy source code
COPY main.go .

# Build the application as a static binary
RUN CGO_ENABLED=0 go build -o listener main.go

# 2. Final stage: use a minimal image to run the binary
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata # add CA certificates for HTTPS and timezone support

WORKDIR /root/

# Copy binary from the build stage
COPY --from=builder /app/listener .

# Set the command to run the built binary
CMD ["./listener"]
