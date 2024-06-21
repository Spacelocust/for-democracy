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
}

// @Summary Create a new group
// @Description Create a new group
// @Tags    groups
// @Accept  json
// @Produce  json
// @Param data body validators.Group true "Group object that needs to be created"
// @Success 200 {object} validators.Group
// @Router /groups [post]
func (s *Server) CreateGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "not authenticated", "type": "oauth"})
		return
	}

	// Get data from request body and validate
	var group validators.Group

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&group); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(group); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Generate random code
	code, err := utils.GenerateRandomString(10)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "something went wrong creating group, please try again later"})
		return
	}

	startAt, err := time.Parse(time.DateTime, group.StartAt)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid startAt format"})
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
		c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "planet not found"})
		return
	}

	if err := db.Create(&newGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "could not create group"})
		return
	}

	// Create new user group
	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: newGroup.ID,
		Owner:   true,
	}

	if err := db.Create(&newUserGroup); err.Error != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "could not add user to group"})
		return
	}

	c.JSON(http.StatusCreated, newGroup)
}

// @Summary			 Get all public groups
// @Description  Get all public groups
// @Tags         groups
// @Produce      json
// @Success      200  {array}  model.Group
// @Failure      500  {object}  gin.Error
// @Router       /groups [get]
func (s *Server) GetGroups(c *gin.Context) {
	db := s.db.GetDB()

	var groups []model.Group

	if err := db.Where("public = ?", true).Find(&groups).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "error when fetching groups"})
	}

	c.JSON(http.StatusOK, groups)
}

// @Summary			 Get a group by ID
// @Description  Get a group by ID
// @Tags         groups
// @Produce      json
// @Param id path int true "Group ID"
// @Success      200  {object}  model.Group
// @Failure      404  {object}  gin.Error
// @Failure      500  {object}  gin.Error
// @Router       /groups/{id} [get]
func (s *Server) GetGroup(c *gin.Context) {
	db := s.db.GetDB()

	groupID := c.Param("id")

	var group model.Group

	if err := db.First(&group, groupID).Error; err != nil {
		if err.Error() == "record not found" {
			c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "group not found"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "error when fetching group"})
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
// @Success 200 {object} model.GroupUser
// @Failure      500  {object}  gin.Error
// @Router /groups/{id}/join [post]
func (s *Server) JoinGroup(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "not authenticated", "type": "oauth"})
		return
	}

	groupID := c.Param("id")

	var count int64
	if err := db.Model(&model.GroupUser{}).Where("group_id = ?", groupID).Count(&count).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "group not found"})
		return
	}

	if count > 3 {
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "group is full"})
		return
	}

	id, err := strconv.Atoi(groupID)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": "invalid group id"})
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: uint(id),
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "could not join group"})
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
// @Success 200 {object} model.GroupUser
// @Router /groups/join [post]
func (s *Server) JoinGroupWithCode(c *gin.Context) {
	db := s.db.GetDB()

	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "not authenticated", "type": "oauth"})
		return
	}

	// Get data from request body and validate
	var groupCode validators.GroupCode

	// Bind JSON request to GroupCode struct
	if err := c.ShouldBindJSON(&groupCode); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate GroupCode struct
	if err := s.validator.Validate(groupCode); err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
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
		c.AbortWithStatusJSON(http.StatusNotFound, gin.H{"error": "group not found"})
		return
	}

	if result.Count > 3 {
		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "group is full"})
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: result.GroupID,
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		c.AbortWithStatusJSON(http.StatusInternalServerError, gin.H{"error": "could not join group"})
		return
	}

	c.JSON(http.StatusCreated, newUserGroup)
}

// func (s *Server) LeaveGroup(c *gin.Context) {

// }
