import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile/enum/difficulty.dart';
import 'package:mobile/enum/faction.dart';

enum ObjectiveType {
  @JsonValue('terminate_illegal_broadcast')
  terminateIllegalBroadcast(
    'terminate_illegal_broadcast',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [Difficulty.trivial],
  ),

  @JsonValue('pump_fuel_to_icbm')
  pumpFuelToICBM(
    'pump_fuel_to_icbm',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [Difficulty.trivial, Difficulty.easy],
  ),

  @JsonValue('upload_escape_pod_data')
  uploadEscapePodData(
    'upload_escape_pod_data',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [Difficulty.trivial, Difficulty.easy],
  ),

  @JsonValue('conduct_geological_survey')
  conductGeologicalSurvey(
    'conduct_geological_survey',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
    ],
  ),

  @JsonValue('launch_icbm')
  launchICBM(
    'launch_icbm',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('retrieve_valuable_data')
  retrieveValuableData(
    'retrieve_valuable_data',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('emergency_evacuation')
  emergencyEvacuation(
    'emergency_evacuation',
    Duration(minutes: 40),
    [Faction.terminids, Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('spread_democracy')
  spreadDemocracy(
    'spread_democracy',
    Duration(minutes: 40),
    [Faction.terminids],
    [
      Difficulty.trivial,
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('eliminate_brood_commanders')
  eliminateBroodCommanders(
    'eliminate_brood_commanders',
    Duration(minutes: 40),
    [Faction.terminids],
    [Difficulty.trivial, Difficulty.easy],
  ),

  @JsonValue('purge_hatcheries')
  purgeHatcheries(
    'purge_hatcheries',
    Duration(minutes: 40),
    [Faction.terminids],
    [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
    ],
  ),

  @JsonValue('activate_e710_pumps')
  activateE710Pumps(
    'activate_e710_pumps',
    Duration(minutes: 40),
    [Faction.terminids],
    [Difficulty.easy, Difficulty.medium],
  ),

  @JsonValue('nuke_nursery')
  nukeNursery(
    'nuke_nursery',
    Duration(minutes: 40),
    [Faction.terminids],
    [
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('activate_terminid_control_system')
  activateTerminidControlSystem(
    'activate_terminid_control_system',
    Duration(minutes: 40),
    [Faction.terminids],
    [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('blitz_search_and_destroy_terminids')
  blitzSearchAndDestroyTerminids(
    'blitz_search_and_destroy_terminids',
    Duration(minutes: 12),
    [Faction.terminids],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('eliminate_chargers')
  eliminateChargers(
    'eliminate_chargers',
    Duration(minutes: 40),
    [Faction.terminids],
    [Difficulty.medium],
  ),

  @JsonValue('eradicate_terminid_swarm')
  eradicateTerminidSwarm(
    'eradicate_terminid_swarm',
    Duration(minutes: 15),
    [Faction.terminids],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
    ],
  ),

  @JsonValue('eliminate_bile_titans')
  eliminateBileTitans(
    'eliminate_bile_titans',
    Duration(minutes: 40),
    [Faction.terminids],
    [Difficulty.challenging],
  ),

  @JsonValue('enable_e710_extraction')
  enableE710Extraction(
    'enable_e710_extraction',
    Duration(minutes: 40),
    [Faction.terminids],
    [
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission
    ],
  ),

  @JsonValue('eliminate_devastators')
  eliminateDevastators(
    'eliminate_devastators',
    Duration(minutes: 40),
    [Faction.automatons],
    [Difficulty.trivial, Difficulty.easy],
  ),

  @JsonValue('eliminate_automaton_hulks')
  eliminateAutomatonHulks(
    'eliminate_automaton_hulks',
    Duration(minutes: 40),
    [Faction.automatons],
    [Difficulty.medium],
  ),

  @JsonValue('sabotage_supply_bases')
  sabotageSupplyBases(
    'sabotage_supply_bases',
    Duration(minutes: 40),
    [Faction.automatons],
    [Difficulty.trivial, Difficulty.easy, Difficulty.medium],
  ),

  @JsonValue('destroy_transmission_network')
  destroyTransmissionNetwork(
    'destroy_transmission_network',
    Duration(minutes: 40),
    [Faction.automatons],
    [Difficulty.easy, Difficulty.medium],
  ),

  @JsonValue('eradicate_automaton_forces')
  eradicateAutomatonForces(
    'eradicate_automaton_forces',
    Duration(minutes: 15),
    [Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('blitz_search_and_destroy_automatons')
  blitzSearchAndDestroyAutomatons(
    'blitz_search_and_destroy_automatons',
    Duration(minutes: 12),
    [Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('sabotage_air_base')
  sabotageAirBase(
    'sabotage_air_base',
    Duration(minutes: 40),
    [Faction.automatons],
    [
      Difficulty.medium,
      Difficulty.challenging,
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('eliminate_automaton_factory_strider')
  eliminateAutomatonFactoryStrider(
    'eliminate_automaton_factory_strider',
    Duration(minutes: 40),
    [Faction.automatons],
    [
      Difficulty.hard,
      Difficulty.extreme,
      Difficulty.suicideMission,
      Difficulty.impossible,
      Difficulty.helldive,
    ],
  ),

  @JsonValue('destroy_command_bunkers')
  destroyCommandBunkers(
    'destroy_command_bunkers',
    Duration(minutes: 40),
    [Faction.automatons],
    [Difficulty.suicideMission, Difficulty.helldive],
  );

  const ObjectiveType(
    this.code,
    this.duration,
    this.factions,
    this.difficulties,
  );

  /// The code of the objective type. Use [translatedName] to get the translated name.
  final String code;

  /// The duration of the objective.
  final Duration duration;

  /// The planet owners for which this objective type can appear.
  final List<Faction> factions;

  /// The difficulties in which this objective type can appear.
  final List<Difficulty> difficulties;

  String get logo => 'assets/images/objective_types/${code.toLowerCase()}.png';

  String translatedName(BuildContext context) {
    switch (this) {
      case ObjectiveType.terminateIllegalBroadcast:
        return AppLocalizations.of(context)!
            .objectiveTypeTerminateIllegalBroadcast;
      case ObjectiveType.pumpFuelToICBM:
        return AppLocalizations.of(context)!.objectiveTypePumpFuelToICBM;
      case ObjectiveType.uploadEscapePodData:
        return AppLocalizations.of(context)!.objectiveTypeUploadEscapePodData;
      case ObjectiveType.conductGeologicalSurvey:
        return AppLocalizations.of(context)!
            .objectiveTypeConductGeologicalSurvey;
      case ObjectiveType.launchICBM:
        return AppLocalizations.of(context)!.objectiveTypeLaunchICBM;
      case ObjectiveType.retrieveValuableData:
        return AppLocalizations.of(context)!.objectiveTypeRetrieveValuableData;
      case ObjectiveType.emergencyEvacuation:
        return AppLocalizations.of(context)!.objectiveTypeEmergencyEvacuation;
      case ObjectiveType.spreadDemocracy:
        return AppLocalizations.of(context)!.objectiveTypeSpreadDemocracy;
      case ObjectiveType.eliminateBroodCommanders:
        return AppLocalizations.of(context)!
            .objectiveTypeEliminateBroodCommanders;
      case ObjectiveType.purgeHatcheries:
        return AppLocalizations.of(context)!.objectiveTypePurgeHatcheries;
      case ObjectiveType.activateE710Pumps:
        return AppLocalizations.of(context)!.objectiveTypeActivateE710Pumps;
      case ObjectiveType.nukeNursery:
        return AppLocalizations.of(context)!.objectiveTypeNukeNursery;
      case ObjectiveType.activateTerminidControlSystem:
        return AppLocalizations.of(context)!
            .objectiveTypeActivateTerminidControlSystem;
      case ObjectiveType.blitzSearchAndDestroyTerminids:
        return AppLocalizations.of(context)!
            .objectiveTypeBlitzSearchAndDestroyTerminids;
      case ObjectiveType.eliminateChargers:
        return AppLocalizations.of(context)!.objectiveTypeEliminateChargers;
      case ObjectiveType.eradicateTerminidSwarm:
        return AppLocalizations.of(context)!
            .objectiveTypeEradicateTerminidSwarm;
      case ObjectiveType.eliminateBileTitans:
        return AppLocalizations.of(context)!.objectiveTypeEliminateBileTitans;
      case ObjectiveType.enableE710Extraction:
        return AppLocalizations.of(context)!.objectiveTypeEnableE710Extraction;
      case ObjectiveType.eliminateDevastators:
        return AppLocalizations.of(context)!.objectiveTypeEliminateDevastators;
      case ObjectiveType.eliminateAutomatonHulks:
        return AppLocalizations.of(context)!
            .objectiveTypeEliminateAutomatonHulks;
      case ObjectiveType.sabotageSupplyBases:
        return AppLocalizations.of(context)!.objectiveTypeSabotageSupplyBases;
      case ObjectiveType.destroyTransmissionNetwork:
        return AppLocalizations.of(context)!
            .objectiveTypeDestroyTransmissionNetwork;
      case ObjectiveType.eradicateAutomatonForces:
        return AppLocalizations.of(context)!
            .objectiveTypeEradicateAutomatonForces;
      case ObjectiveType.blitzSearchAndDestroyAutomatons:
        return AppLocalizations.of(context)!
            .objectiveTypeBlitzSearchAndDestroyAutomatons;
      case ObjectiveType.sabotageAirBase:
        return AppLocalizations.of(context)!.objectiveTypeSabotageAirBase;
      case ObjectiveType.eliminateAutomatonFactoryStrider:
        return AppLocalizations.of(context)!
            .objectiveTypeEliminateAutomatonFactoryStrider;
      case ObjectiveType.destroyCommandBunkers:
        return AppLocalizations.of(context)!.objectiveTypeDestroyCommandBunkers;
    }
  }

  /// Returns the objective that can appear for the given faction and difficulty.
  static List<ObjectiveType> getavailableForFactionAndDifficulty(
    Faction faction,
    Difficulty difficulty,
  ) {
    return ObjectiveType.values
        .where((objectiveType) =>
            objectiveType.factions.contains(faction) &&
            objectiveType.difficulties.contains(difficulty))
        .toList();
  }
}
