package enum

import (
	"database/sql/driver"
	"fmt"
)

type ObjectiveType string

const (
	TerminateIllegalBroadcast        ObjectiveType = "terminate_illegal_broadcast"
	PumpFuelToICBM                   ObjectiveType = "pump_fuel_to_icbm"
	UploadEscapePodData              ObjectiveType = "upload_escape_pod_data"
	ConductGeologicalSurvey          ObjectiveType = "conduct_geological_survey"
	LaunchICBM                       ObjectiveType = "launch_icbm"
	RetrieveValuableData             ObjectiveType = "retrieve_valuable_data"
	EmergencyEvacuation              ObjectiveType = "emergency_evacuation"
	SpreadDemocracy                  ObjectiveType = "spread_democracy"
	EliminateBroodCommanders         ObjectiveType = "eliminate_brood_commanders"
	PurgeHatcheries                  ObjectiveType = "purge_hatcheries"
	ActivateE710Pumps                ObjectiveType = "activate_e710_pumps"
	BlitzSearchAndDestroyTerminids   ObjectiveType = "blitz_search_and_destroy_terminids"
	EliminateChargers                ObjectiveType = "eliminate_chargers"
	EradicateTerminidSwarm           ObjectiveType = "eradicate_terminid_swarm"
	EliminateBileTitans              ObjectiveType = "eliminate_bile_titans"
	EnableE710Extraction             ObjectiveType = "enable_e710_extraction"
	EliminateDevastators             ObjectiveType = "eliminate_devastators"
	SabotageSupplyBases              ObjectiveType = "sabotage_supply_bases"
	DestroyTransmissionNetwork       ObjectiveType = "destroy_transmission_network"
	EradicateAutomatonForces         ObjectiveType = "eradicate_automaton_forces"
	BlitzSearchAndDestroyAutomatons  ObjectiveType = "blitz_search_and_destroy_automatons"
	SabotageAirBase                  ObjectiveType = "sabotage_air_base"
	EliminateAutomatonFactoryStrider ObjectiveType = "eliminate_automaton_factory_strider"
	DestroyCommandBunkers            ObjectiveType = "destroy_command_bunkers"
)

func (ot *ObjectiveType) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case TerminateIllegalBroadcast, PumpFuelToICBM, UploadEscapePodData, ConductGeologicalSurvey, LaunchICBM, RetrieveValuableData, EmergencyEvacuation, SpreadDemocracy, EliminateBroodCommanders, PurgeHatcheries, ActivateE710Pumps, BlitzSearchAndDestroyTerminids, EliminateChargers, EradicateTerminidSwarm, EliminateBileTitans, EnableE710Extraction, EliminateDevastators, SabotageSupplyBases, DestroyTransmissionNetwork, EradicateAutomatonForces, BlitzSearchAndDestroyAutomatons, SabotageAirBase, EliminateAutomatonFactoryStrider, DestroyCommandBunkers:
			*ot = ObjectiveType(b)
		default:
			return fmt.Errorf("invalid value for ObjectiveType: %v", value)
		}
	}
	return nil
}

func (ot ObjectiveType) Value() (driver.Value, error) {
	return string(ot), nil
}
