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

	db := database.New()

	// add a job to the scheduler
	j, err := s.NewJob(
		gocron.DurationJob(
			1*time.Minute,
		),
		gocron.NewTask(
			func() {
				fmt.Println("Collecting events from the HellHub API")

				NewCollector := collector.NewCollector(db)

				if health := NewCollector.Db.Health(); len(health) < 1 {
					log.Fatal("Database is not healthy")
					return
				}

				NewCollector.CollectEvents()
			},
		),
	)

	if err != nil {
		if err := db.Close(); err != nil {
			log.Fatal(err)
		}
		log.Fatal(err)
		return
	}

	// each job has a unique id
	fmt.Println(j.ID())

	// start the scheduler
	s.Start()

	select {}
}
