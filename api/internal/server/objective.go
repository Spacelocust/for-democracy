package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterObjectiveRoutes(r *gin.Engine) {
	route := r.Group("/objectifs")

	route.GET("/", s.GetObjectifs)
	route.GET("/:name", s.GetObjectif)
}

// @Summary Get all objectifs
// @Description Get all objectifs
// @Tags    objectifs
// @Produce  json
// @Success 200 {array} model.Objective
// @Failure 404  {object}  server.ErrorResponse
// @Router /objectifs [get]
func (s *Server) GetObjectifs(c *gin.Context) {
	var objectifs []model.Objective

	for _, obj := range enum.GetObjectifs() {
		objectif, err := model.GetObjective(obj)
		if err != nil {
			s.NotFoundResponse(c, "objectif")
			return
		}

		objectifs = append(objectifs, objectif)
	}

	c.JSON(http.StatusOK, objectifs)
}

// @Summary Get an objectif
// @Description Get an objectif
// @Tags    objectifs
// @Produce  json
// @Param name path string true "Objectif name"
// @Success 200 {object} model.Objective
// @Failure 404  {object}  server.ErrorResponse
// @Router /objectifs/{name} [get]
func (s *Server) GetObjectif(c *gin.Context) {
	name := c.Param("name")

	objectif, err := model.GetObjective(enum.ObjectiveType(name))
	if err != nil {
		s.NotFoundResponse(c, "objectif")
		return
	}

	c.JSON(http.StatusOK, objectif)
}
