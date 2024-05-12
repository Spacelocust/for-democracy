package collector

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm/clause"
)

type Statistic struct {
	MissionsWon        int `json:"missionsWon"`
	MissionTime        int `json:"missionTime"`
	BugKills           int `json:"bugKills"`
	AutomatonKills     int `json:"automatonKills"`
	IlluminateKills    int `json:"illuminateKills"`
	BulletsFired       int `json:"bulletsFired"`
	BulletsHit         int `json:"bulletsHit"`
	TimePlayed         int `json:"timePlayed"`
	Deaths             int `json:"deaths"`
	Revives            int `json:"revives"`
	FriendlyKills      int `json:"friendlyKills"`
	MissionSuccessRate int `json:"missionSuccessRate"`
	Accuracy           int `json:"accuracy"`
	Planet             struct {
		ID int `json:"id"`
	} `json:"planet"`
}

func getStatistics() error {
	db := db.GetDB()
	statistics, err := getData[Statistic]("/statistics?include[]=planet")

	if err != nil {
		return fmt.Errorf("error getting statistics: %w", err)
	}

	if len(statistics) > 0 {
		newStatistics := make([]model.Statistic, len(statistics))

		for i, statistic := range statistics {
			newStatistics[i] = model.Statistic{
				PlanetID:           uint(statistic.Planet.ID),
				MissionsWon:        statistic.MissionsWon,
				MissionTime:        statistic.MissionTime,
				BugKills:           statistic.BugKills,
				AutomatonKills:     statistic.AutomatonKills,
				IlluminateKills:    statistic.IlluminateKills,
				BulletsFired:       statistic.BulletsFired,
				BulletsHit:         statistic.BulletsHit,
				TimePlayed:         statistic.TimePlayed,
				Deaths:             statistic.Deaths,
				Revives:            statistic.Revives,
				FriendlyKills:      statistic.FriendlyKills,
				MissionSuccessRate: statistic.MissionSuccessRate,
				Accuracy:           statistic.Accuracy,
			}
		}

		err = db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "planet_id"}},
			DoUpdates: clause.AssignmentColumns([]string{"mission_time", "bug_kills", "automaton_kills", "illuminate_kills", "bullets_fired", "bullets_hit", "time_played", "deaths", "revives", "friendly_kills", "mission_success_rate", "accuracy"}),
		}).Create(&newStatistics).Error

		if err != nil {
			return fmt.Errorf("error creating statistics: %v", err)
		}

	}
	return nil
}
