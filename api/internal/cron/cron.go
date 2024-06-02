package cron

import (
	"fmt"
	"log"
	"time"

	"github.com/Spacelocust/for-democracy/internal/collector"
	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/go-co-op/gocron/v2"
)

// Cron job for developement purposes

// StartCron starts the cron job
func StartCron() {
	// create a scheduler
	s, err := gocron.NewScheduler()
	if err != nil {
		fmt.Println(err)
		return
	}

	// add a job to the scheduler
	j, err := s.NewJob(
		gocron.DurationJob(
			30*time.Second,
		),
		gocron.NewTask(
			func() {
				fmt.Println("Collecting events from the HellHub API")

				NewCollector := collector.NewCollector(database.New())

				if health := NewCollector.Db.Health(); len(health) < 1 {
					log.Fatal("Database is not healthy")
					return
				}

				NewCollector.CollectEvents()
			},
		),
	)
	if err != nil {
		fmt.Println(err)
		return
	}
	// each job has a unique id
	fmt.Println(j.ID())

	// start the scheduler
	s.Start()

	select {}
}
