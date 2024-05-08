package model

import (
	"slices"
	"sort"
	"time"

	"github.com/Spacelocust/for-democracy/database/enum"
	"gorm.io/gorm"
)

type Mission struct {
	gorm.Model
	Name              string               `gorm:"not null"`
	Instructions      *string              `gorm:"type:text"`
	ObjectiveTypes    []enum.ObjectiveType `gorm:"not null;type:objective_type[]"`
	Group             Group
	GroupID           uint
	GroupUserMissions []GroupUserMission
}

// Returns the objectives of the mission
func (m *Mission) GetObjectives() (map[enum.ObjectiveType]Objective, error) {
	var objectives = make(map[enum.ObjectiveType]Objective, len(m.ObjectiveTypes))

	for _, objectiveType := range m.ObjectiveTypes {
		objective, err := GetObjective(objectiveType)

		if err != nil {
			return nil, err
		}

		objectives[objectiveType] = objective
	}

	return objectives, nil
}

// Returns the estimated duration of the mission
func (m *Mission) GetEstimatedTime() time.Duration {
	type durationCount struct {
		duration time.Duration
		count    int
	}

	durations := []durationCount{}
	objectives, err := m.GetObjectives()

	if err != nil || len(objectives) == 0 {
		return 0
	}

	for _, objective := range objectives {
		existingDuration := slices.IndexFunc(durations, func(durationCount durationCount) bool {
			return durationCount.duration == objective.MissionTime
		})

		if existingDuration != -1 {
			durations[existingDuration].count++
		} else {
			durations = append(durations, durationCount{duration: objective.MissionTime, count: 1})
		}
	}

	sort.SliceStable(durations, func(i, j int) bool {
		return durations[i].count < durations[j].count
	})

	return durations[0].duration
}
