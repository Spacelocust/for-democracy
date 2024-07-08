// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mission _$MissionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['ID', 'Name', 'ObjectiveTypes', 'GroupUserMissions'],
  );
  return Mission(
    id: (json['ID'] as num).toInt(),
    name: json['Name'] as String,
    instructions: json['Instructions'] as String?,
    objectiveTypes: (json['ObjectiveTypes'] as List<dynamic>)
        .map((e) => $enumDecode(_$ObjectiveTypeEnumMap, e))
        .toList(),
    group: json['Group'] == null
        ? null
        : Group.fromJson(json['Group'] as Map<String, dynamic>),
    groupUserMissions: (json['GroupUserMissions'] as List<dynamic>)
        .map((e) => GroupUserMission.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MissionToJson(Mission instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Instructions': instance.instructions,
      'ObjectiveTypes': instance.objectiveTypes
          .map((e) => _$ObjectiveTypeEnumMap[e]!)
          .toList(),
      'Group': instance.group,
      'GroupUserMissions': instance.groupUserMissions,
    };

const _$ObjectiveTypeEnumMap = {
  ObjectiveType.terminateIllegalBroadcast: 'terminate_illegal_broadcast',
  ObjectiveType.pumpFuelToICBM: 'pump_fuel_to_icbm',
  ObjectiveType.uploadEscapePodData: 'upload_escape_pod_data',
  ObjectiveType.conductGeologicalSurvey: 'conduct_geological_survey',
  ObjectiveType.launchICBM: 'launch_icbm',
  ObjectiveType.retrieveValuableData: 'retrieve_valuable_data',
  ObjectiveType.emergencyEvacuation: 'emergency_evacuation',
  ObjectiveType.spreadDemocracy: 'spread_democracy',
  ObjectiveType.eliminateBroodCommanders: 'eliminate_brood_commanders',
  ObjectiveType.purgeHatcheries: 'purge_hatcheries',
  ObjectiveType.activateE710Pumps: 'activate_e710_pumps',
  ObjectiveType.nukeNursery: 'nuke_nursery',
  ObjectiveType.activateTerminidControlSystem:
      'activate_terminid_control_system',
  ObjectiveType.blitzSearchAndDestroyTerminids:
      'blitz_search_and_destroy_terminids',
  ObjectiveType.eliminateChargers: 'eliminate_chargers',
  ObjectiveType.eradicateTerminidSwarm: 'eradicate_terminid_swarm',
  ObjectiveType.eliminateBileTitans: 'eliminate_bile_titans',
  ObjectiveType.enableE710Extraction: 'enable_e710_extraction',
  ObjectiveType.eliminateDevastators: 'eliminate_devastators',
  ObjectiveType.eliminateAutomatonHulks: 'eliminate_automaton_hulks',
  ObjectiveType.sabotageSupplyBases: 'sabotage_supply_bases',
  ObjectiveType.destroyTransmissionNetwork: 'destroy_transmission_network',
  ObjectiveType.eradicateAutomatonForces: 'eradicate_automaton_forces',
  ObjectiveType.blitzSearchAndDestroyAutomatons:
      'blitz_search_and_destroy_automatons',
  ObjectiveType.sabotageAirBase: 'sabotage_air_base',
  ObjectiveType.eliminateAutomatonFactoryStrider:
      'eliminate_automaton_factory_strider',
  ObjectiveType.destroyCommandBunkers: 'destroy_command_bunkers',
};
