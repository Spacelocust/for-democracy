package sse

import (
	"time"

	"github.com/gin-gonic/gin"
)

func (stream *Event) PlanetsStream(r *gin.Engine) {
	// db := (*stream.Db).GetDB()

	go func() {
		for {
			time.Sleep(time.Second * 1)
			// planets := []model.Planet{}

			// if err := db.Preload(clause.Associations).Find(&planets).Error; err != nil {
			// 	stream.Error <- err
			// 	continue
			// }

			// planetsJson, err := json.Marshal(planets)
			// if err != nil {
			// 	stream.Error <- err
			// 	continue
			// }

			// Send current time to clients message channel
			// stream.Message <- string(planetsJson)
			stream.Message <- "event changes"
		}
	}()
	// go func() {
	// 	listener := (*stream.Db).NewListenner()

	// 	err := listener.Listen("event_changes")
	// 	if err != nil {
	// 		log.Fatal(err)
	// 	}
	// 	for {
	// 		select {
	// 		case notification := <-listener.Notify:
	// 			fmt.Println("notification")
	// 			if notification != nil {
	// 				stream.Message <- "event changes"
	// 			}
	// 		case <-time.After(10 * time.Second):
	// 			go listener.Ping()
	// 		}
	// 	}
	// }()

	r.GET("/planets-stream/", HeadersMiddleware(), stream.ServeHTTP(), stream.GetHandler)
}

// func (stream *Event) NotifyHandler(c *gin.Context) {
// listener := (*stream.Db).NewListenner()
// err := listener.Listen("event_changes")
// if err != nil {
// 	log.Fatal(err)
// }

// 	c.Stream(func(w io.Writer) bool {
// 		// Stream message to client from message channel
// 		select {
// 		case notification := <-listener.Notify:
// 			if notification != nil {
// 				c.SSEvent("message", "event changes")
// 			}
// 		case <-time.After(10 * time.Second):
// 			go listener.Ping()
// 			return true
// 		}
// 		return false
// 	})
// }
