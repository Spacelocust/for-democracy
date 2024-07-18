package sse

import (
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/goccy/go-json"
)

// @Summary Get events stream
// @Description Get events stream
// @Tags    stream
// @Produce  json
// @Success 200 {array} model.Planet
// @Router /events-stream/ [get]
func (stream *Event) EventsStream(r *gin.Engine) {
	db := (*stream.Db).GetDB()

	go func() {
		for {
			time.Sleep(time.Second * 10)

			// Get all events
			var defences []model.Defence
			var liberations []model.Liberation

			if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Preload("Planet.Sector").Find(&defences).Error; err != nil {
				stream.Error <- err
			}

			if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Preload("Planet.Sector").Find(&liberations).Error; err != nil {
				stream.Error <- err
			}

			eventsJson, err := json.Marshal(gin.H{
				"defences":    defences,
				"liberations": liberations,
			})

			if err != nil {
				stream.Error <- err
				continue
			}

			stream.Message <- string(eventsJson)
		}
	}()

	r.GET("/events-stream/", HeadersMiddleware(), stream.ServeHTTP(), stream.GetHandler)
}
