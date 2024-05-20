package hellhub

import (
	"sync"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
	"gorm.io/gorm/clause"
)

type Sector struct {
	HelldiversID int    `json:"index"`
	Name         string `json:"name"`
}

var errorSector = err.NewError("[sector]")

// Get all sectors from the HellHub API and store them in the database
func storeSectors(sectors *[]model.Sector, respch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()
	parsedSectors, err := fetch[Sector]("/sectors?limit=100")

	if err != nil {
		respch <- errorSector.Error(err, "error getting sectors")
		wg.Done()
		return
	}

	if len(parsedSectors) < 1 {
		respch <- errorSector.Error(nil, "no sectors found")
		wg.Done()
		return
	}

	*sectors = make([]model.Sector, len(parsedSectors))

	for i, sector := range parsedSectors {
		(*sectors)[i] = model.Sector{
			HelldiversID: sector.HelldiversID,
			Name:         sector.Name,
		}
	}

	err = db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "helldivers_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"name"}),
	}).Create(&sectors).Error

	if err != nil {
		respch <- errorSector.Error(err, "error creating sectors")
		wg.Done()
		return
	}

	respch <- nil
	wg.Done()
}
