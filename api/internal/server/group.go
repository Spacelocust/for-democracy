package server

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"firebase.google.com/go/v4/messaging"
	"github.com/Spacelocust/for-democracy/internal/firebase"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterGroupRoutes(r *gin.Engine) {
	route := r.Group("/groups")

	route.GET("", s.OAuthOptionalMiddleware, s.GetGroups)
	route.POST("", s.AuthMiddleware, s.CreateGroup)
	route.POST("/join", s.AuthMiddleware, s.JoinGroupWithCode)
	route.GET("/:id", s.OAuthOptionalMiddleware, s.GetGroup)
	route.PUT("/:id", s.AuthMiddleware, s.UpdateGroup)
	route.DELETE("/:id", s.AuthMiddleware, s.DeleteGroup)
	route.POST("/:id/join", s.AuthMiddleware, s.JoinGroup)
	route.POST("/:id/leave", s.AuthMiddleware, s.LeaveGroup)
}

// GroupFieldsDistinct is a constant that contains the fields that are distinct in the groups table
const GroupFieldsDistinct = "groups.id, groups.created_at, groups.updated_at, groups.code, groups.name, groups.description, groups.public, groups.start_at, groups.difficulty, groups.planet_id"

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

	user := checkAuth(c)

	// Get data from request body and validate
	var groupData validators.Group

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&groupData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(groupData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Generate random code
	code, err := utils.GenerateRandomString(10)
	if err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	startAt, err := time.Parse(time.DateTime, groupData.StartAt)
	if err != nil {
		s.BadRequestResponse(c, "invalid date time format, use YYYY-MM-DD HH:MM:SS")
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
		GroupUsers: []model.GroupUser{
			{
				UserID: user.ID,
				Owner:  true,
			},
		},
	}

	if err := db.
		Preload("Liberation").
		Preload("Defence").
		Joins("LEFT JOIN liberations ON liberations.planet_id = planets.id").
		Joins("LEFT JOIN defences ON defences.planet_id = planets.id").
		Where("liberations.id IS NOT NULL AND liberations.deleted_at IS NULL OR defences.id IS NOT NULL AND defences.deleted_at IS NULL").
		First(&model.Planet{}, "planets.id = ?", newGroup.PlanetID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "planet does not have any events")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if err := db.Create(&newGroup).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// BUG: Need to query the group again to preoload the sub-relations (GroupUsers.User) because the Create method doesn't return the sub-relations
	err = db.
		Preload("Missions.GroupUserMissions.Stratagems").
		Preload("Missions.GroupUserMissions.GroupUser.User").
		Preload("GroupUsers.User").
		Preload("GroupUsers.GroupUserMissions.Stratagems").
		Preload("Planet").
		First(&newGroup, "id = ?", newGroup.ID).Error

	if err != nil {
		s.InternalErrorResponse(c, err)
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

	var groups []model.Group
	// if the user is not authenticated, get public groups
	user, ok := c.MustGet("user").(model.User)

	if !ok {
		// Get public groups
		err := db.
			Preload("Missions.GroupUserMissions.Stratagems").
			Preload("Missions.GroupUserMissions.GroupUser.User").
			Preload("GroupUsers.User").
			Preload("GroupUsers.GroupUserMissions.Stratagems").
			Preload("Planet").
			Order("start_at desc").
			Where("start_at > ?", time.Now()).
			Find(&groups, "public = ?", true).Error

		if err != nil {
			s.InternalErrorResponse(c, err)
			return
		}

		c.JSON(http.StatusOK, groups)
		return
	}

	// Get groups that the user is a member of and public groups
	err := db.
		Joins("LEFT JOIN group_users ON groups.id = group_users.group_id").
		Where("group_users.user_id = ? OR groups.public = ? AND groups.start_at > ?", user.ID, true, time.Now()).
		Preload("Missions.GroupUserMissions.Stratagems").
		Preload("Missions.GroupUserMissions.GroupUser.User").
		Preload("GroupUsers.User").
		Preload("GroupUsers.GroupUserMissions.Stratagems").
		Preload("Planet").
		Distinct(GroupFieldsDistinct).
		Order("groups.start_at desc").
		Find(&groups).Error

	if err != nil {
		s.InternalErrorResponse(c, err)
		return
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

	// if the user is not authenticated, get public group by ID only
	user, ok := c.MustGet("user").(model.User)

	var group model.Group

	if !ok {
		if err := db.
			Preload("Missions.GroupUserMissions.Stratagems").
			Preload("Missions.GroupUserMissions.GroupUser.User").
			Preload("GroupUsers.User").
			Preload("GroupUsers.GroupUserMissions.Stratagems").
			Preload("Planet").
			First(&group, "id = ? AND public = ?", groupID, true).
			Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				s.NotFoundResponse(c, "group")
				return
			}

			s.InternalErrorResponse(c, err)
			return
		}
	}

	// Get private group where the user is a member of or public group by ID
	err := db.
		Joins("LEFT JOIN group_users ON groups.id = group_users.group_id").
		Where("group_users.user_id = ? OR groups.public = ?", user.ID, true).
		Preload("Missions.GroupUserMissions.Stratagems").
		Preload("Missions.GroupUserMissions.GroupUser.User").
		Preload("GroupUsers.User").
		Preload("GroupUsers.GroupUserMissions.Stratagems").
		Preload("Planet").
		Distinct(GroupFieldsDistinct).
		First(&group, "groups.id = ?", groupID).Error

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
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
// @Param data body validators.GroupUpdate true "Properties to update"
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
	user := checkAuth(c)

	groupID := c.Param("id")

	// Get data from request body and validate
	var groupData validators.GroupUpdate

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&groupData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(groupData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Check if the group exists
	var group model.Group
	if err := db.First(&group, "id = ?", groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is the owner of the group
	var groupUser model.GroupUser
	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if !groupUser.Owner {
		s.ForbiddenResponse(c, "you are not the owner of this group")
		return
	}

	startAt, err := time.Parse(time.DateTime, groupData.StartAt)
	if err != nil {
		s.BadRequestResponse(c, "invalid date time format, use YYYY-MM-DD HH:MM:SS")
		return
	}

	updatedGroup := model.Group{
		ID:          group.ID,
		Code:        group.Code,
		Name:        groupData.Name,
		Description: groupData.Description,
		Public:      *groupData.Public,
		Difficulty:  groupData.Difficulty,
		PlanetID:    group.PlanetID,
		StartAt:     startAt,
	}

	// Update group
	if err := db.Save(&updatedGroup).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	err = db.
		Preload("Missions.GroupUserMissions.Stratagems").
		Preload("Missions.GroupUserMissions.GroupUser.User").
		Preload("GroupUsers.User").
		Preload("GroupUsers.User.TokenFcm").
		Preload("GroupUsers.GroupUserMissions.Stratagems").
		Preload("Planet").
		First(&updatedGroup, "id = ?", group.ID).Error

	if err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// Send notification to all users in the group
	var tokenFcms []string

	if len(updatedGroup.GroupUsers) > 1 {
		// Get all token fcm of users in the group except the user that updated the group
		for _, groupUser := range updatedGroup.GroupUsers {
			if groupUser.User.TokenFcm != nil && groupUser.User.ID != user.ID {
				tokenFcms = append(tokenFcms, groupUser.User.TokenFcm.Token)
			}
		}

		client := s.firebase.GetMessaging()
		groupId := strconv.FormatUint(uint64(updatedGroup.ID), 10)

		response, err := client.SendEachForMulticast(context.Background(), &messaging.MulticastMessage{
			Tokens: tokenFcms,
			Data: map[string]string{
				"type":       firebase.GROUP_UPDATED,
				"group_name": updatedGroup.Name,
				"group_id":   groupId,
			},
		})

		if err != nil {
			s.InternalErrorResponse(c, err)
			return
		}

		s.logger.Info(fmt.Sprintf("[%s] Successfully sent message: %v", firebase.GROUP_UPDATED, response))
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

	user := checkAuth(c)

	groupID := c.Param("id")

	// Check if the group exists and get the count of users in the group
	var count int64

	if err := db.Model(&model.GroupUser{}).Where("group_id = ?", groupID).Count(&count).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if user is already in the group
	var groupUser model.GroupUser

	if err := db.Find(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	if groupUser.ID != 0 {
		s.ForbiddenResponse(c, "you are already a member of this group")
		return
	}

	// Check if the group is full
	if count > 3 {
		s.ForbiddenResponse(c, "group is full")
		return
	}

	id, err := strconv.Atoi(groupID)
	if err != nil {
		s.BadRequestResponse(c, "invalid group ID")
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: uint(id),
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// BUG: Need to query the group again to preoload the sub-relations (GroupUsers.User) because the Create method doesn't return the sub-relations
	if err := db.Preload("User").First(&newUserGroup, "id = ?", newUserGroup.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group user")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	var group model.Group

	if err := db.Preload("GroupUsers.User.TokenFcm").First(&group, "id = ?", newUserGroup.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}
	}

	// Send notification to all users in the group
	var tokenFcms []string

	if len(group.GroupUsers) > 1 {

		// Get all token fcm of users in the group except the user that joined the group
		for _, groupUser := range group.GroupUsers {
			if groupUser.User.TokenFcm != nil && groupUser.User.ID != user.ID {
				tokenFcms = append(tokenFcms, groupUser.User.TokenFcm.Token)
			}
		}

		client := s.firebase.GetMessaging()
		groupId := strconv.FormatUint(uint64(group.ID), 10)

		response, err := client.SendEachForMulticast(context.Background(), &messaging.MulticastMessage{
			Tokens: tokenFcms,
			Data: map[string]string{
				"type":       firebase.GROUP_JOINED,
				"username":   user.Username,
				"group_name": group.Name,
				"group_id":   groupId,
			},
		})

		if err != nil {
			s.InternalErrorResponse(c, err)
			return
		}

		s.logger.Info(fmt.Sprintf("[%s] Successfully sent message: %v", firebase.GROUP_JOINED, response))
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

	user := checkAuth(c)

	// Get data from request body and validate
	var groupCode validators.GroupCode

	// Bind JSON request to GroupCode struct
	if err := c.ShouldBindJSON(&groupCode); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate GroupCode struct
	if err := s.validator.Validate(groupCode); err != nil {
		s.BadRequestResponse(c, err.Error())
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
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if user is already in the group
	var userGroup model.GroupUser

	err = db.Find(&userGroup, "user_id = ? AND group_id = ?", user.ID, result.ID).Error
	if err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	if userGroup.ID != 0 {
		s.ForbiddenResponse(c, "you are already a member of this group")
		return
	}

	if result.Count > 3 {
		s.ForbiddenResponse(c, "group is full")
		return
	}

	newUserGroup := model.GroupUser{
		UserID:  user.ID,
		GroupID: result.ID,
		Owner:   false,
	}

	if err := db.Create(&newUserGroup).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// BUG: Need to query the group again to preoload the sub-relations (GroupUsers.User) because the Create method doesn't return the sub-relations
	if err := db.Preload("User").First(&newUserGroup, "id = ?", newUserGroup.ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group user")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Get the group to send notifications
	var group model.Group

	if err := db.Preload("GroupUsers.User.TokenFcm").First(&group, "id = ?", newUserGroup.GroupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}
	}

	// Send notification to all users in the group
	var tokenFcms []string

	if len(group.GroupUsers) > 1 {
		// Get all token fcm of users in the group except the user that joined the group
		for _, groupUser := range group.GroupUsers {
			if groupUser.User.TokenFcm != nil && groupUser.User.ID != user.ID {
				tokenFcms = append(tokenFcms, groupUser.User.TokenFcm.Token)
			}
		}

		client := s.firebase.GetMessaging()
		groupId := strconv.FormatUint(uint64(group.ID), 10)

		response, err := client.SendEachForMulticast(context.Background(), &messaging.MulticastMessage{
			Tokens: tokenFcms,
			Data: map[string]string{
				"type":       firebase.GROUP_JOINED,
				"username":   user.Username,
				"group_name": group.Name,
				"group_id":   groupId,
			},
		})

		if err != nil {
			s.InternalErrorResponse(c, err)
			return
		}

		s.logger.Info(fmt.Sprintf("[%s-code] Successfully sent message: %v", firebase.GROUP_JOINED, response))
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

	user := checkAuth(c)

	groupID := c.Param("id")

	// Check if user is in the group before leaving
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.ForbiddenResponse(c, "you are not a member of this group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Delete the user from the group
	if err := db.Unscoped().Delete(&groupUser).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the group is empty
	var group model.Group
	if err := db.Preload("GroupUsers.User.TokenFcm").First(&group, "id = ?", groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
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
		s.InternalErrorResponse(c, err)
		return
	}

	// Send notification to all users in the group
	var tokenFcms []string

	if len(group.GroupUsers) > 1 {
		// Get all token fcm of users in the group except the user that left the group
		for _, groupUser := range group.GroupUsers {
			if groupUser.User.TokenFcm != nil && groupUser.User.ID != user.ID {
				tokenFcms = append(tokenFcms, groupUser.User.TokenFcm.Token)
			}
		}

		client := s.firebase.GetMessaging()
		groupId := strconv.FormatUint(uint64(group.ID), 10)

		response, err := client.SendEachForMulticast(context.Background(), &messaging.MulticastMessage{
			Tokens: tokenFcms,
			Data: map[string]string{
				"type":       firebase.GROUP_LEFT,
				"username":   groupUser.User.Username,
				"group_name": group.Name,
				"group_id":   groupId,
			},
		})

		if err != nil {
			s.InternalErrorResponse(c, err)
			return
		}

		s.logger.Info(fmt.Sprintf("[%s] Successfully sent message: %v", firebase.GROUP_LEFT, response))
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

	user := checkAuth(c)

	groupID := c.Param("id")

	var group model.Group
	if err := db.First(&group, "id = ?", groupID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Check if the user is a member of the group
	var groupUser model.GroupUser

	if err := db.First(&groupUser, "user_id = ? AND group_id = ?", user.ID, groupID).Error; err != nil {
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

	// Delete the group
	if err := db.Unscoped().Delete(&group).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "group deleted"})
}
