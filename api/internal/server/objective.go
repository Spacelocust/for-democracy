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
// @Success 200 {array} enum.ObjectiveType
// @Router /objectifs [get]
func (s *Server) GetObjectifs(c *gin.Context) {
	c.JSON(http.StatusOK, enum.GetObjectifs())
}

// @Summary Get an objectif
// @Description Get an objectif
// @Tags    objectifs
// @Produce  json
// @Param name path string true "Objectif name"
// @Success 200 {object} model.Objective
// @Failure      404  {object}  server.ErrorResponse
// @Router /objectifs/{name} [get]
func (s *Server) GetObjectif(c *gin.Context) {
	name := c.Param("name")

	objectif, err := model.GetObjective(enum.ObjectiveType(name))
	if err != nil {
		c.JSON(http.StatusNotFound, ErrorResponse{Error: "Objectif not found"})
		return
	}

	c.JSON(200, objectif)
}
