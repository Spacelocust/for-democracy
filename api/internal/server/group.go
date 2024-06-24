package server

import (
	"net/http"
	"strconv"
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterGroupRoutes(r *gin.Engine) {
	route := r.Group("/groups")
	route.Use(s.OAuthMiddleware)

	route.POST("/", s.CreateGroup)
	route.GET("/", s.GetGroups)
	route.GET("/:id", s.GetGroup)
	route.POST("/:id/join", s.JoinGroup)
	route.POST("/join", s.JoinGroupWithCode)
	route.POST("/:id/leave", s.LeaveGroup)
}

// @Summary Create a new group
// @Description Create a new group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param data body validators.Group true "Group object that needs to be created"
// @Success 201 {object} validators.Group
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
	var group validators.Group

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&group); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(group); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: err.Error()})
		return
	}

	// Generate random code
	code, err := utils.GenerateRandomString(10)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something went wrong creating group, please try again later"})
		return
	}

	startAt, err := time.Parse(time.DateTime, group.StartAt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: "invalid date time format"})
		return
	}

	// Create new group
	newGroup := model.Group{
		Code:        code,
		Name:        group.Name,
		Description: group.Description,
		Public:      group.Public,
		Difficulty:  group.Difficulty,
		PlanetID:    group.PlanetID,
		StartAt:     startAt,
	}

	if err := db.First(&model.Planet{}, newGroup.PlanetID).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "planet not found"})
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

// @Summary			 Get all public groups
// @Description  Get all public groups
// @Tags         groups
// @Produce      json
// @Success      200  {array}  model.Group
// @Failure      500  {object}  server.ErrorResponse
// @Router       /groups [get]
func (s *Server) GetGroups(c *gin.Context) {
	db := s.db.GetDB()

	var groups []model.Group

	if err := db.Where("public = ?", true).Find(&groups).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "error when fetching groups"})
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

	groupID := c.Param("id")

	var group model.Group

	if err := db.First(&group, groupID).Error; err != nil {
		if err.Error() == "record not found" {
			c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "error when fetching group"})
		return
	}

	c.JSON(http.StatusOK, group)
}

// func (s *Server) UpdateGroup(c *gin.Context) {

// }

// func (s *Server) DeleteGroup(c *gin.Context) {

// }

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

	var count int64
	if err := db.Model(&model.GroupUser{}).Where("group_id = ?", groupID).Count(&count).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

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
		GroupID uint
		Count   int
	}

	// Check if group exists and get the count of users in the group
	err := db.Model(&model.GroupUser{}).
		Select("groups.id as group_id, COUNT(group_users.id) as count").
		Joins("inner join groups on groups.id = group_users.group_id").
		Where("groups.code = ?", groupCode).
		Group("groups.id, groups.code").First(&result).Error

	if err != nil {
		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

	if result.Count > 3 {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "group is full"})
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: result.GroupID,
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not join group"})
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

	var groupUser model.GroupUser

	if err := db.Where("user_id = ? AND group_id = ?", user.ID, groupID).First(&groupUser).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

	if err := db.Delete(&groupUser).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not leave group"})
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "left group"})
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
		c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: "group not found"})
		return
	}

	var groupUser model.GroupUser
	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not a member of this group"})
		return
	}

	if !groupUser.Owner {
		c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: "you are not the owner of this group"})
		return
	}

	if err := db.Delete(&group).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "could not delete group"})
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "group deleted"})
}
