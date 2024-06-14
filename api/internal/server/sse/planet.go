package sse

import (
	"encoding/json"
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm/clause"
)

func (stream *Event) PlanetsStream(r *gin.Engine) {
	db := (*stream.Db).GetDB()

	go func() {
		for {
			time.Sleep(time.Second * 20)
			planets := []model.Planet{}

			if err := db.Preload(clause.Associations).Find(&planets).Error; err != nil {
				stream.Error <- err
				continue
			}

			planetsJson, err := json.Marshal(planets)
			if err != nil {
				stream.Error <- err
				continue
			}

			// Send current time to clients message channel
			stream.Message <- string(planetsJson)
		}
	}()

	r.GET("/planets-stream/", HeadersMiddleware(), stream.ServeHTTP(), stream.GetHandler)
}
