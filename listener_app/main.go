package main

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/lib/pq" // PostgreSQL driver that supports LISTEN/NOTIFY
)

// Structure to hold connection configuration
type Config struct {
	DatabaseURL   string
	NotifyChannel string
}

func main() {
	// 1. Read environment variables
	cfg := Config{
		DatabaseURL:   os.Getenv("DATABASE_URL"),
		NotifyChannel: os.Getenv("NOTIFY_CHANNEL"),
	}

	if cfg.DatabaseURL == "" || cfg.NotifyChannel == "" {
		log.Fatal("FATAL: DATABASE_URL and NOTIFY_CHANNEL environment variables must be set.")
	}

	log.Printf("INFO: Starting Listener on channel: %s", cfg.NotifyChannel)

	// 2. Start loop to connect and wait for notifications
	// This loop handles reconnection attempts
	for {
		err := listenForEvents(cfg)
		if err != nil {
			log.Printf("ERROR: Listener failed: %v. Retrying in 5 seconds...", err)
			time.Sleep(5 * time.Second)
		}
	}
}

func listenForEvents(cfg Config) error {
	// pq.NewListener is the main structure for managing LISTEN/NOTIFY
	// It automatically manages reconnection and keep-alive
	listener := pq.NewListener(
		cfg.DatabaseURL,
		10*time.Second, // Reconnect timeout
		10*time.Minute, // Keep-alive interval
		func(event pq.ListenerEventType, err error) {
			if err != nil {
				log.Printf("Listener Event ERROR: %v", err)
			}
			if event == pq.ListenerEventConnected {
				log.Println("INFO: Listener successfully reconnected to DB.")
			}
			// You can add additional logic here, such as sending metrics when disconnection occurs
		},
	)

	// 3. Tell the listener to start listening (LISTEN) on the configured channel
	err := listener.Listen(cfg.NotifyChannel)
	if err != nil {
		return fmt.Errorf("failed to listen on channel %s: %w", cfg.NotifyChannel, err)
	}

	log.Printf("INFO: Successfully listening on channel: %s. Waiting for notifications...", cfg.NotifyChannel)

	// 4. Loop to wait for notifications
	for {
		// Wait() waits for notifications from PostgreSQL
		// It will block until an event arrives or a timeout occurs (configured in NewListener)
		notification := <-listener.Notify

		if notification == nil {
			// If notification is nil it means a timeout occurred or the connection was closed
			continue
		}

		// 5. Process the received notification
		fmt.Println("\n✨ Event Received:")
		fmt.Printf("  Channel: %s\n", notification.Channel)
		fmt.Printf("  PID: %d\n", notification.BePid)     // Process ID of PostgreSQL that sent NOTIFY
		fmt.Printf("  Payload: %s\n", notification.Extra) // This is the JSON payload sent from the trigger

		// Event processing point
		// In practice you may deserialize (unmarshal) the JSON payload into a Go struct
		// to use the data for further processing
	}
}
