package firebase

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
)

// Constants for the different types of notifications
const (
	GROUP_JOINED    = "group_joined"
	GROUP_LEFT      = "group_left"
	GROUP_UPDATED   = "group_updated"
	MISSION_JOINED  = "mission_joined"
	MISSION_LEFT    = "mission_left"
	MISSION_UPDATED = "mission_updated"
	MISSION_CREATED = "mission_created"
)

type Service interface {
	// GetApp returns the firebase client
	GetApp() *firebase.App

	// GetMessaging returns the messaging client
	GetMessaging() *messaging.Client
}

type service struct {
	app       *firebase.App
	messaging *messaging.Client
}

// New returns a new firebase service
func New() Service {
	app, err := firebase.NewApp(context.Background(), nil)
	if err != nil {
		log.Fatalf("error initializing firebase client: %v\n", err)
	}

	messaging, err := app.Messaging(context.Background())
	if err != nil {
		log.Fatalf("error getting Messaging client: %v\n", err)
	}

	return &service{
		app:       app,
		messaging: messaging,
	}
}

// GetApp returns the firebase app
func (s *service) GetApp() *firebase.App {
	return s.app
}

// GetMessaging returns the messaging client
func (s *service) GetMessaging() *messaging.Client {
	return s.messaging
}
