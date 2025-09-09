package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

var (
	ctx    = context.Background()
	client *redis.ClusterClient
	id     uuid.UUID
)

func main() {
	id = uuid.New()
	addrs := strings.Split(os.Getenv("REDIS_ADDRS"), ",")
	client = redis.NewClusterClient(&redis.ClusterOptions{
		Addrs:        addrs,
		Password:     os.Getenv("REDIS_PASSWORD"),
		DialTimeout:  3 * time.Second,
		ReadTimeout:  3 * time.Second,
		WriteTimeout: 3 * time.Second,
	})
	http.HandleFunc("/", handler)
	fmt.Println("HTTP server running on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	key := fmt.Sprintf("%s-last-access", id.String())
	value := time.Now().Format(time.RFC3339)
	if err := client.Set(ctx, key, value, 0).Err(); err != nil {
		es := fmt.Sprintf("failed to set last access time: %s", err)
		http.Error(w, es, http.StatusInternalServerError)
		return
	}
	_, _ = fmt.Fprintf(w, "Hello from %s\n", id.String())
	_, _ = fmt.Fprintf(w, "Set key=%s value=%s in Redis\n", key, value)
}
