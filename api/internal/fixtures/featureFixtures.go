package fixtures

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm/clause"
)

type FeatureFixture struct {
	Db database.Service
}

func (a *FeatureFixture) LoadFixtures() {
	db := a.Db.GetDB()

	features := []model.Feature{
		{
			Code: "map",
		},
		{
			Code: "planet_list",
		},
	}

	for _, feature := range features {
		err := db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "code"}},
			DoNothing: true,
		}).Create(&feature).Error

		if err != nil {
			fmt.Println(err)
		}
	}
}

func NewFeatureFixture(db database.Service) *FeatureFixture {
	return &FeatureFixture{
		Db: db,
	}
}
