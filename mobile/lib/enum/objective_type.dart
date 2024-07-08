import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ObjectiveType {
  @JsonValue('terminate_illegal_broadcast')
  terminateIllegalBroadcast(
    'TerminateIllegalBroadcast',
  ),

  @JsonValue('pump_fuel_to_icbm')
  pumpFuelToICBM(
    'PumpFuelToICBM',
  ),

  @JsonValue('upload_escape_pod_data')
  uploadEscapePodData(
    'UploadEscapePodData',
  ),

  @JsonValue('conduct_geological_survey')
  conductGeologicalSurvey(
    'ConductGeologicalSurvey',
  ),

  @JsonValue('launch_icbm')
  launchICBM(
    'LaunchICBM',
  ),

  @JsonValue('retrieve_valuable_data')
  retrieveValuableData(
    'RetrieveValuableData',
  ),

  @JsonValue('emergency_evacuation')
  emergencyEvacuation(
    'EmergencyEvacuation',
  ),

  @JsonValue('spread_democracy')
  spreadDemocracy(
    'SpreadDemocracy',
  ),

  @JsonValue('eliminate_brood_commanders')
  eliminateBroodCommanders(
    'EliminateBroodCommanders',
  ),

  @JsonValue('purge_hatcheries')
  purgeHatcheries(
    'PurgeHatcheries',
  ),

  @JsonValue('activate_e710_pumps')
  activateE710Pumps(
    'ActivateE710Pumps',
  ),

  @JsonValue('nuke_nursery')
  nukeNursery(
    'NukeNursery',
  ),

  @JsonValue('activate_terminid_control_system')
  activateTerminidControlSystem(
    'ActivateTerminidControlSystem',
  ),

  @JsonValue('blitz_search_and_destroy_terminids')
  blitzSearchAndDestroyTerminids(
    'BlitzSearchAndDestroyTerminids',
  ),

  @JsonValue('eliminate_chargers')
  eliminateChargers(
    'EliminateChargers',
  ),

  @JsonValue('eradicate_terminid_swarm')
  eradicateTerminidSwarm(
    'EradicateTerminidSwarm',
  ),

  @JsonValue('eliminate_bile_titans')
  eliminateBileTitans(
    'EliminateBileTitans',
  ),

  @JsonValue('enable_e710_extraction')
  enableE710Extraction(
    'EnableE710Extraction',
  ),

  @JsonValue('eliminate_devastators')
  eliminateDevastators(
    'EliminateDevastators',
  ),

  @JsonValue('eliminate_automaton_hulks')
  eliminateAutomatonHulks(
    'EliminateAutomatonHulks',
  ),

  @JsonValue('sabotage_supply_bases')
  sabotageSupplyBases(
    'SabotageSupplyBases',
  ),

  @JsonValue('destroy_transmission_network')
  destroyTransmissionNetwork(
    'DestroyTransmissionNetwork',
  ),

  @JsonValue('eradicate_automaton_forces')
  eradicateAutomatonForces(
    'EradicateAutomatonForces',
  ),

  @JsonValue('blitz_search_and_destroy_automatons')
  blitzSearchAndDestroyAutomatons(
    'BlitzSearchAndDestroyAutomatons',
  ),

  @JsonValue('sabotage_air_base')
  sabotageAirBase(
    'SabotageAirBase',
  ),

  @JsonValue('eliminate_automaton_factory_strider')
  eliminateAutomatonFactoryStrider(
    'EliminateAutomatonFactoryStrider',
  ),

  @JsonValue('destroy_command_bunkers')
  destroyCommandBunkers(
    'DestroyCommandBunkers',
  );

  const ObjectiveType(
    this.name,
  );

  /// The untranslated name of the difficulty. Use [translatedName] to get the translated name.
  final String name;

  String get logo => 'assets/images/objective_types/${name.toLowerCase()}.png';

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
}
