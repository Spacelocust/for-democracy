package handler

import (
	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm/clause"
)

// @Summary			 Get all planets
// @Description  Get all planets
// @Tags         planets
// @Produce      json
// @Success      200  {array}  model.Planet
// @Failure      500  {object}  fiber.Error
// @Router       /planets [get]
func GetPlanets(c *fiber.Ctx) error {
	db := db.GetDB()

	// Get all planets
	planets := []model.Planet{}

	if err := db.Preload(clause.Associations).Find(&planets).Error; err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get planets")
	}

	return c.JSON(planets)
}

// @Summary			 Get planet by ID
// @Description  Get planet by ID
// @Tags         planets
// @Produce      json
// @Param        id   path      int  true  "Planet ID"
// @Success      200  {object}  model.Planet
// @Failure      500  {object}  fiber.Error
// @Router       /planets/{id} [get]
func GetPlanet(c *fiber.Ctx) error {
	db := db.GetDB()

	planet := model.Planet{}

	if err := db.Preload(clause.Associations).First(&planet, "id = ?", c.Params("id")).Error; err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to get planet")
	}

	return c.JSON(planet)
}
