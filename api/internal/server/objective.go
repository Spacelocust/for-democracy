package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterObjectiveRoutes(r *gin.Engine) {
	route := r.Group("/objectives")

	route.GET("", s.GetObjectives)
	route.GET("/:name", s.GetObjectif)
}

// @Summary Get all objectives
// @Description Get all objectives
// @Tags    objectives
// @Produce  json
// @Success 200 {array} model.Objective
// @Failure 404  {object}  server.ErrorResponse
// @Router /objectives [get]
func (s *Server) GetObjectives(c *gin.Context) {
	var objectives []model.Objective

	for _, obj := range enum.GetObjectives() {
		objectif, err := model.GetObjective(obj)
		if err != nil {
			s.NotFoundResponse(c, "objectif")
			return
		}

		objectives = append(objectives, objectif)
	}

	c.JSON(http.StatusOK, objectives)
}

// @Summary Get an objectif
// @Description Get an objectif
// @Tags    objectives
// @Produce  json
// @Param name path string true "Objective name"
// @Success 200 {object} model.Objective
// @Failure 404  {object}  server.ErrorResponse
// @Router /objectives/{name} [get]
func (s *Server) GetObjectif(c *gin.Context) {
	name := c.Param("name")

	objectif, err := model.GetObjective(enum.ObjectiveType(name))
	if err != nil {
		s.NotFoundResponse(c, "objectif")
		return
	}

	c.JSON(http.StatusOK, objectif)
}
