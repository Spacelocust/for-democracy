package handler

import (
	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm/clause"
)

type Event struct {
	Defence    []model.Defence
	Liberation []model.Liberation
}

// @Summary			 Get all events
// @Description  Get all events
// @Tags         events
// @Produce      json
// @Success      200  {object}  handler.Event
// @Failure      500  {object}  fiber.Error
// @Router       /events [get]
func GetEvents(c *fiber.Ctx) error {
	db := db.GetDB()

	// Get all events
	defences := []model.Defence{}
	liberations := []model.Liberation{}

	if err := db.Preload(clause.Associations).Find(&defences).Error; err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get defences")
	}

	if err := db.Preload(clause.Associations).Find(&liberations).Error; err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get liberations")
	}

	return c.JSON(fiber.Map{
		"defences":    defences,
		"liberations": liberations,
	})
}
