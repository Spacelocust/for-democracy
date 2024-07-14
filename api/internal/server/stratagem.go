package server

import (
	"context"
	"errors"
	"fmt"
	"net/http"

	"firebase.google.com/go/v4/messaging"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterStratagemRoutes(r *gin.Engine) {
	route := r.Group("/stratagems")

	route.GET("", s.GetStratagems)
	route.GET("/:id", s.GetStratagem)
}

// @Summary Get all stratagems
// @Description Get all stratagems
// @Tags    stratagems
// @Produce  json
// @Success 200 {array} model.Stratagem
// @Failure      500  {object}  server.ErrorResponse
// @Router /stratagems [get]
func (s *Server) GetStratagems(c *gin.Context) {
	db := s.db.GetDB()

	var stratagems []model.Stratagem

	if err := db.Find(&stratagems).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	client := s.firebase.GetMessaging()

	// TODO - replace with actual token from the database
	response, err := client.Send(context.Background(), &messaging.Message{
		Token: "dzMbcc3RSY2MC-d1qeI2s2:APA91bEhgCXS6l_LLy6ZvYNk3sJgCUgcrKfOZMsbDh-0ymParNYY0Y_PCr7LCV-JfX_PKVa6QwzMZ_GEtxhwnuGxLuOHMlaaupo3liLtb77eXgGauv02v0Q1XMfFdQIubs_tHpRlSxIb",
		Notification: &messaging.Notification{
			Title: "Hello",
			Body:  "Hello, World!",
		},
	})

	if err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	s.logger.Info(fmt.Sprintf("Successfully sent message: %v", response))

	c.JSON(http.StatusOK, stratagems)
}

// @Summary Get a stratagem
// @Description Get a stratagem
// @Tags    stratagems
// @Produce  json
// @Param id path string true "Stratagem ID"
// @Success 200 {object} model.Stratagem
// @Failure      404  {object}  server.ErrorResponse
// @Failure      500  {object}  server.ErrorResponse
// @Router /stratagems/{id} [get]
func (s *Server) GetStratagem(c *gin.Context) {
	db := s.db.GetDB()

	id := c.Param("id")

	var stratagem model.Stratagem

	if err := db.First(&stratagem, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "stratagem")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, stratagem)
}
