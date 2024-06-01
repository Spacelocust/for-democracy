package helldivers

import (
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/model"
)

type Position struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type PlanetInfo struct {
	Index    int      `json:"index"`
	Position Position `json:"position"`
	// Waypoints are the indexes of the planets that are connected to the current planet
	Waypoints []int `json:"waypoints"`
}

type WarInfoPosition struct {
	PlanetInfos []PlanetInfo `json:"planetInfos"`
}

var errorWaypoint = err.NewError("[waypoint]")

// Retrieve waypoints for each planet
func FetchWaypointsPerPlanet(waypointsPerPlanet *map[int][]model.Waypoint, errpch chan<- error, wg *sync.WaitGroup) {
	waypointsWar, err := fetchWar[WarInfoPosition]("/WarSeason/801/WarInfo")
	if err != nil {
		errpch <- errorWaypoint.Error(err, "error getting waypoints")
		wg.Done()
		return
	}

	var positionPlanets = map[int]model.Waypoint{}

	// Format each planet's position and store it in a map by the planet's index
	for _, planetInfo := range waypointsWar.PlanetInfos {
		positionPlanets[planetInfo.Index] = model.Waypoint{
			Y: planetInfo.Position.Y,
			X: planetInfo.Position.X,
		}
	}

	for _, planetInfo := range waypointsWar.PlanetInfos {
		if _, ok := (*waypointsPerPlanet)[planetInfo.Index]; !ok {
			(*waypointsPerPlanet)[planetInfo.Index] = []model.Waypoint{}

			// Add waypoints to the current planet
			for _, waypointIndex := range planetInfo.Waypoints {
				(*waypointsPerPlanet)[planetInfo.Index] = append((*waypointsPerPlanet)[planetInfo.Index], positionPlanets[waypointIndex])
			}
		} else {
			(*waypointsPerPlanet)[planetInfo.Index] = append((*waypointsPerPlanet)[planetInfo.Index], model.Waypoint{
				Y: planetInfo.Position.Y,
				X: planetInfo.Position.X,
			})
		}
	}

	errpch <- nil
	wg.Done()
}
