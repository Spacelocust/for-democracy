package helldivers

import (
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/model"
)

type PlanetStat struct {
	PlanetIndex        int     `json:"planetIndex"`
	MissionsWon        int     `json:"missionsWon"`
	MissionsLost       int     `json:"missionsLost"`
	MissionTime        int     `json:"missionTime"`
	BugKills           int     `json:"bugKills"`
	AutomatonKills     int     `json:"automatonKills"`
	IlluminateKills    int     `json:"illuminateKills"`
	BulletsFired       int     `json:"bulletsFired"`
	BulletsHit         int     `json:"bulletsHit"`
	TimePlayed         int     `json:"timePlayed"`
	Deaths             int     `json:"deaths"`
	Revives            int     `json:"revives"`
	Friendlies         int     `json:"friendlies"`
	MissionSuccessRate float64 `json:"missionSuccessRate"`
	Accuracy           float64 `json:"accuracy"`
}

type Summary struct {
	PlanetStats []PlanetStat `json:"planets_stats"`
}

var errorStatistic = err.NewError("[statistic]")

// Retrieve waypoints for each planet
func FetchStatistics(statistics *map[int]model.Statistic, errpch chan<- error, wg *sync.WaitGroup) {
	summary, err := fetchWar[Summary]("/Stats/war/801/summary")
	if err != nil {
		errpch <- errorStatistic.Error(err, "error getting statistics")
		wg.Done()
		return
	}

	// Format each planet's position and store it in a map by the planet's index
	for _, planetStat := range summary.PlanetStats {
		(*statistics)[planetStat.PlanetIndex] = model.Statistic{
			MissionsWon:        planetStat.MissionsWon,
			MissionsLost:       planetStat.MissionsLost,
			MissionTime:        planetStat.MissionTime,
			BugKills:           planetStat.BugKills,
			AutomatonKills:     planetStat.AutomatonKills,
			IlluminateKills:    planetStat.IlluminateKills,
			BulletsFired:       planetStat.BulletsFired,
			BulletsHit:         planetStat.BulletsHit,
			TimePlayed:         planetStat.TimePlayed,
			Deaths:             planetStat.Deaths,
			Revives:            planetStat.Revives,
			FriendlyKills:      planetStat.Friendlies,
			MissionSuccessRate: planetStat.MissionSuccessRate,
			Accuracy:           planetStat.Accuracy,
			HelldiversID:       planetStat.PlanetIndex,
		}
	}

	errpch <- nil
	wg.Done()
}
