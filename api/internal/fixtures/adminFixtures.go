package fixtures

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm/clause"
)

type AdminFixture struct {
	Db database.Service
}

func (a *AdminFixture) LoadFixtures() {
	db := a.Db.GetDB()

	password := "admin"

	admin := &model.User{
		Username: "admin",
		Password: &password,
		Role: enum.Admin,
	}

	err := db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "username"}},
		DoNothing: true,
	}).Create(&admin).Error

	if err != nil {
		fmt.Println(err)
	}
}

func NewAdminFixture(db database.Service) *AdminFixture {
	return &AdminFixture{
		Db: db,
	}
}
