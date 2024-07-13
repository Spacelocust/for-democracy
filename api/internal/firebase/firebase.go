package firebase

import (
	"context"
	"log"

	firebase "firebase.google.com/go/v4"
)

type Service interface {
	// GetClient returns the firebase client
	GetCient() *firebase.App
}

type service struct {
	client *firebase.App
}

// New returns a new firebase service
func New() Service {
	client, err := firebase.NewApp(context.Background(), nil)
	if err != nil {
		log.Fatalf("error initializing firebase client: %v\n", err)
	}

	return &service{
		client: client,
	}
}

// GetClient returns the firebase client
func (s *service) GetCient() *firebase.App {
	return s.client
}
