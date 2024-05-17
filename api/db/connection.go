package db

import (
	"fmt"
	"log"
	"os"

	"github.com/Spacelocust/for-democracy/logger/zapper"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

// ConnectDb opens a connection to the database
func ConnectDb() {
	// Create the connection string
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=5432 sslmode=disable TimeZone=Europe/Paris",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)

	// Connect to the database
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: zapper.Zlogger,
	})

	if err != nil {
		log.Fatal("Failed to connect to database. \n", err)
		os.Exit(2)
	}

	log.Println("connected")

	DB = db
}

func GetDB() *gorm.DB {
	return DB
}
