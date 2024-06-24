package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterMissionRoutes(r *gin.Engine) {
	route := r.Group("/missions")

	route.GET("/", s.GetMissions)
	route.GET("/:id", s.GetMission)
	route.POST("/", s.CreateMission)
	route.PUT("/:id", s.EditMission)
	route.DELETE("/:id", s.DeleteMission)
	route.POST("/:id/join", s.JoinMision)
	route.POST("/:id/leave", s.LeaveMission)
}

func (s *Server) GetMissions(c *gin.Context) {
}

func (s *Server) GetMission(c *gin.Context) {
}

// @Summary Create a mission
// @Description Create a mission
// @Tags    missions
// @Produce  json
// @Param data body validators.Mission true "Mission object that needs to be created"
// @Success 201 {object} validators.Mission
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
func (s *Server) CreateMission(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	var mission validators.Mission
	if err := c.ShouldBindJSON(&mission); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Validate the mission
	if err := s.validator.Validate(mission); err != nil {
		c.JSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Check if the group exists
	if err := db.First(&model.Group{}, "id = ?", mission.GroupID).Error; err != nil {
		c.JSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

	// Check if the user is in a group
	var groupUser model.GroupUser
	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, mission.GroupID).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not a member of this group"})
		return
	}

	if !groupUser.Owner {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are the owner of this group"})
		return
	}

	// Create the mission
	newMission := model.Mission{
		Name:           mission.Name,
		Instructions:   mission.Instructions,
		ObjectiveTypes: mission.ObjectiveTypes,
		GroupID:        mission.GroupID,
	}

	if err := db.Create(&newMission).Error; err != nil {
		c.JSON(http.StatusInternalServerError, ErrorResponse{Error: "could not create mission"})
		return
	}

	c.JSON(http.StatusCreated, newMission)
}

func (s *Server) EditMission(c *gin.Context) {
}

func (s *Server) DeleteMission(c *gin.Context) {
}

func (s *Server) JoinMision(c *gin.Context) {
}

func (s *Server) LeaveMission(c *gin.Context) {
}
