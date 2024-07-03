package server

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterGroupRoutes(r *gin.Engine) {
	route := r.Group("/groups")
	route.Use(s.OAuthMiddleware)

	route.GET("/", s.GetGroups)
	route.POST("/", s.CreateGroup)
	route.POST("/join", s.JoinGroupWithCode)
	route.GET("/:id", s.GetGroup)
	route.PUT("/:id", s.UpdateGroup)
	route.DELETE("/:id", s.DeleteGroup)
	route.POST("/:id/join", s.JoinGroup)
	route.POST("/:id/leave", s.LeaveGroup)
}

// @Summary Create a new group
// @Description Create a new group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param data body validators.Group true "Group object that needs to be created"
// @Success 201 {object} model.Group
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /groups [post]
func (s *Server) CreateGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	// Get data from request body and validate
	var groupData validators.Group

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&groupData); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(groupData); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Generate random code
	code, err := utils.GenerateRandomString(10)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	startAt, err := time.Parse(time.DateTime, groupData.StartAt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: "invalid date time format"})
		return
	}

	// Create new group
	newGroup := model.Group{
		Code:        code,
		Name:        groupData.Name,
		Description: groupData.Description,
		Public:      *groupData.Public,
		Difficulty:  groupData.Difficulty,
		PlanetID:    groupData.PlanetID,
		StartAt:     startAt,
	}

	if err := db.First(&model.Planet{}, newGroup.PlanetID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "planet not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	if err := db.Create(&newGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not create group"})
		return
	}

	// Create new user group
	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: newGroup.ID,
		Owner:   true,
	}

	if err := db.Create(&newUserGroup); err.Error != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not add user to group"})
		return
	}

	c.JSON(http.StatusCreated, newGroup)
}

// @Summary			 Get groups
// @Description  Get groups
// @Tags         groups
// @Produce      json
// @Success      200  {array}  model.Group
// @Failure      500  {object}  server.ErrorResponse
// @Router       /groups [get]
func (s *Server) GetGroups(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	var groups []model.Group

	// Get groups that the user is a member of and public groups
	if err := db.Joins("LEFT JOIN group_users ON groups.id = group_users.group_id").Where("group_users.user_id = ? OR groups.public = ?", user.ID, true).Preload("Missions").Find(&groups).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "Something went wrong, please try again later"})
	}

	c.JSON(http.StatusOK, groups)
}

// @Summary			 Get a group by ID
// @Description  Get a group by ID
// @Tags         groups
// @Produce      json
// @Param id path int true "Group ID"
// @Success      200  {object}  model.Group
// @Failure      404  {object}  server.ErrorResponse
// @Failure      500  {object}  server.ErrorResponse
// @Router       /groups/{id} [get]
func (s *Server) GetGroup(c *gin.Context) {
	db := s.db.GetDB()

	if _, ok := c.MustGet("user").(model.User); !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	groupID := c.Param("id")

	var group model.Group

	if err := db.First(&group, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "Something went wrong, please try again later"})
		return
	}

	c.JSON(http.StatusOK, group)
}

// @Summary Update a group
// @Description Update a group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param id path int true "Group ID"
// @Param data body validators.Group true "Properties to update"
// @Success 200 {object} model.Group
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Router /groups/{id} [put]
func (s *Server) UpdateGroup(c *gin.Context) {
	db := s.db.GetDB()

	// Check if the user is authenticated
	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	groupID := c.Param("id")

	// Get data from request body and validate
	var groupData validators.Group

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&groupData); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(groupData); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Check if the group exists
	var group model.Group
	if err := db.First(&group, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
	}

	// Check if the user is the owner of the group
	var groupUser model.GroupUser
	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not a member of this group"})
			return
		}

		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	if !groupUser.Owner {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not the owner of this group"})
		return
	}

	startAt, err := time.Parse(time.DateTime, groupData.StartAt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: "invalid date time format"})
		return
	}

	updatedGroup := model.Group{
		ID:          group.ID,
		Code:        group.Code,
		Name:        groupData.Name,
		Description: groupData.Description,
		Public:      *groupData.Public,
		Difficulty:  groupData.Difficulty,
		PlanetID:    groupData.PlanetID,
		StartAt:     startAt,
	}

	// Update group
	if err := db.Save(&updatedGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not update group"})
		return
	}

	c.JSON(http.StatusOK, updatedGroup)
}

// @Summary Join a group
// @Description Join a group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param id path int true "Group ID"
// @Success 201 {object} model.GroupUser
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Router /groups/{id}/join [post]
func (s *Server) JoinGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	groupID := c.Param("id")

	// Check if the group exists and get the count of users in the group
	var count int64

	if err := db.Model(&model.GroupUser{}).Where("group_id = ?", groupID).Count(&count).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "Something went wrong, please try again later"})
		return
	}

	// Check if user is already in the group
	var groupUser model.GroupUser

	if err := db.Find(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	if groupUser.ID != 0 {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are already a member of this group"})
		return
	}

	// Check if the group is full
	if count > 3 {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "group is full"})
		return
	}

	id, err := strconv.Atoi(groupID)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: "invalid group ID"})
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: uint(id),
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not join group"})
		return
	}

	c.JSON(http.StatusCreated, newUserGroup)
}

// @Summary Join a group with code
// @Description Join a group with code
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param data body validators.GroupCode true "Code to join"
// @Success 201 {object} model.GroupUser
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Router /groups/join [post]
func (s *Server) JoinGroupWithCode(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	// Get data from request body and validate
	var groupCode validators.GroupCode

	// Bind JSON request to GroupCode struct
	if err := c.ShouldBindJSON(&groupCode); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Validate GroupCode struct
	if err := s.validator.Validate(groupCode); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	var result struct {
		ID    uint
		Count int
	}
	// Get the group ID and count of users in the group
	err := db.Model(&model.Group{}).
		Select("groups.id, COUNT(group_users.id) as count").
		Joins("LEFT JOIN group_users ON groups.id = group_users.group_id").
		Where("groups.code = ?", groupCode.Code).
		Group("groups.id").
		First(&result).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
	}

	// Check if user is already in the group
	var userGroup model.GroupUser

	err = db.Where("user_id = ? AND group_id = ?", user.ID, result.ID).Find(&userGroup).Error
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
	}

	if userGroup.ID != 0 {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are already a member of this group"})
		return
	}

	if result.Count > 3 {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "group is full"})
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: result.ID,
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	c.JSON(http.StatusCreated, newUserGroup)
}

// @Summary Leave a group
// @Description Leave a group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param id path int true "Group ID"
// @Success 200 {object} server.SuccessResponse
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /groups/{id}/leave [post]
func (s *Server) LeaveGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	groupID := c.Param("id")

	// Check if user is in the group before leaving
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "you are not a member of this group"})
			return
		}

		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

	if err := db.Unscoped().Delete(&groupUser).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not leave group"})
		return
	}

	// Check if the group is empty
	var group model.Group
	if err := db.First(&group, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
	}

	// Subquery to know if the group has no users
	countGroupUser := db.Model(&model.Group{}).
		Select("groups.id").
		Joins("LEFT JOIN group_users ON groups.id = group_users.group_id").
		Where("groups.id = ?", groupID).
		Group("groups.id").
		Having("COUNT(group_users.id) = 0")

	// Delete the group if it has no users
	if err := db.Where("id IN (?)", countGroupUser).Unscoped().Delete(&model.Group{}).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not remove group"})
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "you have left the group"})
}

// @Summary Delete a group
// @Description Delete a group
// @Tags    groups
// @Produce  json
// @Param id path int true "Group ID"
// @Success 200 {object} server.SuccessResponse
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Router /groups/{id} [delete]
func (s *Server) DeleteGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "not authenticated"})
		return
	}

	groupID := c.Param("id")

	var group model.Group
	if err := db.First(&group, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	// Check if the user is a member of the group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not a member of this group"})
		return
	}

	if !groupUser.Owner {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not the owner of this group"})
		return
	}

	if err := db.Unscoped().Delete(&group).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong, please try again later"})
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "group deleted"})
}
