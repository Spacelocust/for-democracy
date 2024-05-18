package model

import (
	"fmt"
	"time"

	"github.com/Spacelocust/for-democracy/db/enum"
)

type Objective struct {
	ObjectiveType enum.ObjectiveType
	MissionTime   time.Duration
	Factions      []enum.Faction
	Difficulties  []enum.Difficulty
}

func GetObjective(objectiveType enum.ObjectiveType) (Objective, error) {
	switch objectiveType {
	// General Missions
	case enum.TerminateIllegalBroadcast:
		return Objective{
			ObjectiveType: enum.TerminateIllegalBroadcast,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Trivial},
		}, nil
	case enum.PumpFuelToICBM:
		return Objective{
			ObjectiveType: enum.PumpFuelToICBM,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy},
		}, nil
	case enum.UploadEscapePodData:
		return Objective{
			ObjectiveType: enum.UploadEscapePodData,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy},
		}, nil
	case enum.ConductGeologicalSurvey:
		return Objective{
			ObjectiveType: enum.ConductGeologicalSurvey,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Easy, enum.Medium, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible},
		}, nil
	case enum.LaunchICBM:
		return Objective{
			ObjectiveType: enum.LaunchICBM,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.Impossible, enum.Helldive},
		}, nil
	case enum.RetrieveValuableData:
		return Objective{
			ObjectiveType: enum.RetrieveValuableData,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.EmergencyEvacuation:
		return Objective{
			ObjectiveType: enum.EmergencyEvacuation,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids, enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	// Terminid Missions
	case enum.SpreadDemocracy:
		return Objective{
			ObjectiveType: enum.EmergencyEvacuation,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy, enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.EliminateBroodCommanders:
		return Objective{
			ObjectiveType: enum.EliminateBroodCommanders,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy},
		}, nil
	case enum.PurgeHatcheries:
		return Objective{
			ObjectiveType: enum.PurgeHatcheries,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Easy, enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible},
		}, nil
	case enum.ActivateE710Pumps:
		return Objective{
			ObjectiveType: enum.ActivateE710Pumps,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Easy, enum.Medium},
		}, nil
	case enum.BlitzSearchAndDestroyTerminids:
		return Objective{
			ObjectiveType: enum.BlitzSearchAndDestroyTerminids,
			MissionTime:   12 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Helldive},
		}, nil
	case enum.EliminateChargers:
		return Objective{
			ObjectiveType: enum.EliminateChargers,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Medium},
		}, nil
	case enum.EradicateTerminidSwarm:
		return Objective{
			ObjectiveType: enum.EradicateTerminidSwarm,
			MissionTime:   15 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible},
		}, nil
	case enum.EliminateBileTitans:
		return Objective{
			ObjectiveType: enum.EliminateBileTitans,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Challenging},
		}, nil
	case enum.EnableE710Extraction:
		return Objective{
			ObjectiveType: enum.EnableE710Extraction,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Terminids},
			Difficulties:  []enum.Difficulty{enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission},
		}, nil
	// Automaton Missions
	case enum.EliminateDevastators:
		return Objective{
			ObjectiveType: enum.EliminateDevastators,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy},
		}, nil
	case enum.SabotageSupplyBases:
		return Objective{
			ObjectiveType: enum.SabotageSupplyBases,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Trivial, enum.Easy, enum.Medium},
		}, nil
	case enum.DestroyTransmissionNetwork:
		return Objective{
			ObjectiveType: enum.DestroyTransmissionNetwork,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Easy, enum.Medium},
		}, nil
	case enum.EradicateAutomatonForces:
		return Objective{
			ObjectiveType: enum.EradicateAutomatonForces,
			MissionTime:   15 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.BlitzSearchAndDestroyAutomatons:
		return Objective{
			ObjectiveType: enum.BlitzSearchAndDestroyAutomatons,
			MissionTime:   12 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.SabotageAirBase:
		return Objective{
			ObjectiveType: enum.SabotageAirBase,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Medium, enum.Challenging, enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.EliminateAutomatonFactoryStrider:
		return Objective{
			ObjectiveType: enum.EliminateAutomatonFactoryStrider,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.Hard, enum.Extreme, enum.SuicideMission, enum.Impossible, enum.Helldive},
		}, nil
	case enum.DestroyCommandBunkers:
		return Objective{
			ObjectiveType: enum.DestroyCommandBunkers,
			MissionTime:   40 * time.Minute,
			Factions:      []enum.Faction{enum.Automatons},
			Difficulties:  []enum.Difficulty{enum.SuicideMission, enum.Helldive},
		}, nil
	default:
		return Objective{}, fmt.Errorf("invalid objective type: %s", objectiveType)
	}
}
