package main

import (
	"fmt"
	"io"
	"os"
	"strings"

	"ariga.io/atlas-provider-gorm/gormschema"
	"github.com/Spacelocust/for-democracy/internal/model"
)

func main() {
	sb := &strings.Builder{}
	loadEnums(sb)
	loadModels(sb)

	if _, err := io.WriteString(os.Stdout, sb.String()); err != nil {
		fmt.Fprintf(os.Stderr, "failed to write to stdout: %v\n", err)
		os.Exit(1)
	}
}

func loadEnums(sb *strings.Builder) {
	enums := []string{
		`CREATE TYPE "role" AS ENUM ('admin', 'user');

		-- Create enum type "objective_type"
		CREATE TYPE "objective_type" AS ENUM ('terminate_illegal_broadcast', 'pump_fuel_to_icbm', 'upload_escape_pod_data', 'conduct_geological_survey', 'launch_icbm', 'retrieve_valuable_data', 'emergency_evacuation', 'spread_democracy', 'eliminate_brood_commanders', 'purge_hatcheries', 'activate_e710_pumps', 'blitz_search_and_destroy_terminids', 'eliminate_chargers', 'eradicate_terminid_swarm', 'eliminate_bile_titans', 'enable_e710_extraction', 'eliminate_devastators', 'sabotage_supply_bases', 'destroy_transmission_network', 'eradicate_automaton_forces', 'blitz_search_and_destroy_automatons', 'sabotage_air_base', 'eliminate_automaton_factory_strider', 'destroy_command_bunkers');
		
		-- Create enum type "stratagem_use_type"
		CREATE TYPE "stratagem_use_type" AS ENUM ('self', 'team', 'shared');
		
		-- Create enum type "stratagem_type"
		CREATE TYPE "stratagem_type" AS ENUM ('supply', 'mission', 'defensive', 'offensive');
		
		-- Create enum type "stratagem_keys"
		CREATE TYPE "stratagem_keys" AS ENUM ('up', 'down', 'left', 'right');
		
		-- Create enum type "faction"
		CREATE TYPE "faction" AS ENUM ('humans', 'terminids', 'automatons', 'illuminates');
		
		-- Create enum type "event_type"
		CREATE TYPE "event_type" AS ENUM ('defence', 'liberation');
		
		-- Create enum type "difficulty"
		CREATE TYPE "difficulty" AS ENUM ('trivial', 'easy', 'medium', 'challenging', 'hard', 'extreme', 'suicide_mission', 'impossible', 'helldive');`,
	}
	for _, enum := range enums {
		sb.WriteString(enum)
		sb.WriteString(";\n")
	}
}

func loadModels(sb *strings.Builder) {
	models := []interface{}{
		&model.Biome{},
		&model.Effect{},
		&model.Feature{},
		&model.Group{},
		&model.GroupUser{},
		&model.GroupUserMission{},
		&model.Mission{},
		&model.Liberation{},
		&model.Defence{},
		&model.Planet{},
		&model.Statistic{},
		&model.Stratagem{},
		&model.User{},
		&model.Token{},
	}
	stmts, err := gormschema.New("postgres").Load(models...)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to load gorm schema: %v\n", err)
		os.Exit(1)
	}
	sb.WriteString(stmts)
	sb.WriteString(";\n")
}
