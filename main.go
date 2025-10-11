package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/google/uuid"
)

var (
	id uuid.UUID
)

func main() {
	id = uuid.New()
	http.HandleFunc("/", handler)
	fmt.Println("HTTP server running on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	_, _ = fmt.Fprintf(w, "Hello from %s\n", id.String())
}
