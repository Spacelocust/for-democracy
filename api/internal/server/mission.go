package server

import (
	"errors"
	"fmt"
	"net/http"
	"slices"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterMissionRoutes(r *gin.Engine) {
	route := r.Group("/missions")
	route.Use(s.OAuthMiddleware)

	route.POST("", s.CreateMission)
	route.GET("/:id", s.GetMission)
	route.PUT("/:id", s.UpdateMission)
	route.DELETE("/:id", s.DeleteMission)
	route.POST("/:id/join", s.JoinMission)
	route.POST("/:id/leave", s.LeaveMission)
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
// @Router /missions [post]
func (s *Server) CreateMission(c *gin.Context) {
	db := s.db.GetDB()

	user := checkAuth(c)

	// Parse the mission
	var missionData validators.Mission

	if err := c.ShouldBindJSON(&missionData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate the mission
	if err := s.validator.Validate(missionData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Check if the group exists
	var group model.Group

	if err := db.Preload("Planet").First(&group, "id = ?", missionData.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the objectives are available for the group
	for _, objectifType := range missionData.ObjectiveTypes {
		objectif, err := model.GetObjective(objectifType)
		if err != nil {
			s.BadRequestResponse(c, err.Error())
			return
		}

		if !slices.Contains(objectif.Factions, group.Planet.Owner) {
			s.BadRequestResponse(c, fmt.Sprintf("objective '%s' is not available for this group", objectifType))
			return
		}
	}

	// Check if the user is in a group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, missionData.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if !groupUser.Owner {
		s.ForbiddenResponse(c, "you are not the owner of this group")
		return
	}

	// Create the mission
	newMission := model.Mission{
		Name:           missionData.Name,
		Instructions:   missionData.Instructions,
		ObjectiveTypes: missionData.ObjectiveTypes,
		GroupID:        missionData.GroupID,
	}

	newMission.EstimatedTime = newMission.CalulateEstimatedTime()

	if err := db.Create(&newMission).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	if err := db.Preload("GroupUserMissions.Stratagems").First(&newMission, "id = ?", newMission.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusCreated, newMission)
}

// @Summary Get mission by ID
// @Description Get mission by ID
// @Tags    missions
// @Produce  json
// @Param id path int true "Mission ID"
// @Success 200 {object} model.Mission
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /missions/{id} [get]
func (s *Server) GetMission(c *gin.Context) {
	db := s.db.GetDB()

	missionID := c.Param("id")

	var mission model.Mission

	if err := db.Preload("GroupUserMissions.Stratagems").First(&mission, "id = ?", missionID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, mission)
}

// @Summary Update a mission
// @Description Update a mission
// @Tags    missions
// @Produce  json
// @Param id path int true "Mission ID"
// @Param data body validators.Mission true "Mission properties that needs to be updated"
// @Success 200 {object} validators.Mission
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /missions/{id} [put]
func (s *Server) UpdateMission(c *gin.Context) {
	db := s.db.GetDB()

	missionID := c.Param("id")

	user := checkAuth(c)

	// Parse the mission
	var mission validators.Mission

	if err := c.ShouldBindJSON(&mission); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate the mission
	if err := s.validator.Validate(mission); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Check if the group exists
	if err := db.First(&model.Group{}, "id = ?", mission.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is in a group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, mission.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if !groupUser.Owner {
		s.ForbiddenResponse(c, "you are not the owner of this group")
		return
	}

	// Update the mission
	updatedMission := model.Mission{
		Name:           mission.Name,
		Instructions:   mission.Instructions,
		ObjectiveTypes: mission.ObjectiveTypes,
		GroupID:        mission.GroupID,
	}

	updatedMission.EstimatedTime = updatedMission.CalulateEstimatedTime()

	if err := db.Model(&model.Mission{}).Where("id = ?", missionID).Updates(&updatedMission).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, updatedMission)

}

// @Summary Delete a mission
// @Description Delete a mission
// @Tags    missions
// @Produce  json
// @Param id path int true "Mission ID"
// @Success 200 {object} server.SuccessResponse
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /missions/{id} [delete]
func (s *Server) DeleteMission(c *gin.Context) {
	db := s.db.GetDB()

	missionID := c.Param("id")

	user := checkAuth(c)

	// Check if the mission exists
	var mission model.Mission

	if err := db.First(&mission, "id = ?", missionID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is in a group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, mission.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if !groupUser.Owner {
		s.ForbiddenResponse(c, "you are not the owner of this group")
		return
	}

	// Delete the mission
	if err := db.Unscoped().Delete(&mission).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "mission deleted"})
}

// @Summary Join a mission
// @Description Join a mission
// @Tags    missions
// @Produce  json
// @Param id path int true "Mission ID"
// @Param data body validators.UserMission true "Mission properties that needs to be updated"
// @Success 201 {object} model.GroupUserMission
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /missions/{id}/join [post]
func (s *Server) JoinMission(c *gin.Context) {
	db := s.db.GetDB()

	user := checkAuth(c)

	missionID := c.Param("id")

	// Check if the mission exists
	var mission model.Mission

	if err := db.First(&mission, "id = ?", missionID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	var missionData validators.UserMission

	if err := c.ShouldBindJSON(&missionData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(missionData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Check if the user is in a group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, mission.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is already in the mission
	var groupUserMission model.GroupUserMission

	if err := db.Find(&groupUserMission, "group_user_id = ? AND mission_id = ?", groupUser.ID, missionID).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	if groupUserMission.ID != 0 {
		s.ForbiddenResponse(c, "you are already in this mission")
		return
	}

	var userStratagems []*model.Stratagem

	if err := db.Find(&userStratagems, "id IN (?)", missionData.Stratagems).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// Join the mission
	newGroupUserMission := model.GroupUserMission{
		MissionID:   mission.ID,
		GroupUserID: groupUser.ID,
		Stratagems:  []*model.Stratagem{},
	}

	err := db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Preload("Stratagems").Create(&newGroupUserMission).Error; err != nil {
			return err
		}

		if err := tx.Model(&newGroupUserMission).Association("Stratagems").Replace(userStratagems); err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		s.ForbiddenResponse(c, "could not join mission")
		return
	}

	c.JSON(http.StatusOK, newGroupUserMission)
}

// @Summary Leave a mission
// @Description Leave a mission
// @Tags    missions
// @Produce  json
// @Param id path int true "Mission ID"
// @Success 200 {object} server.SuccessResponse
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /missions/{id}/leave [post]
func (s *Server) LeaveMission(c *gin.Context) {
	db := s.db.GetDB()

	user := checkAuth(c)

	missionID := c.Param("id")

	// Check if the mission exists
	var mission model.Mission

	if err := db.First(&mission, "id = ?", missionID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is in a group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, mission.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is already in the mission
	var groupUserMission model.GroupUserMission

	if err := db.First(&groupUserMission, "group_user_id = ? AND mission_id = ?", groupUser.ID, missionID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not in this mission")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Leave the mission
	if err := db.Delete(&groupUserMission).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "you left the mission"})
}
