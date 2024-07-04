package logger

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/Spacelocust/for-democracy/internal/colorize"
	"github.com/rs/zerolog"
)

type Service interface {
	// GetLogger returns the logger instance
	GetLogger() *zerolog.Logger
	// Info logs an info message
	Info(msg string)
	// Warn logs a warning message
	Error(msg string)
	// Debug logs a debug message
	Debug(msg string)
}

type service struct {
	logger *zerolog.Logger
}

func New() Service {
	output := zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: time.DateTime}

	// Customizing the output format timestamp
	output.FormatTimestamp = func(i interface{}) string {
		// Parsing the time string
		parsedTime, err := time.Parse(time.RFC3339, i.(string))
		if err != nil {
			log.Fatal(err)
		}

		// Layout string for the desired output format
		outputLayout := "2006/01/02 - 15:04:05"

		// Formatting the parsed time to the desired layout
		formattedTime := parsedTime.Format(outputLayout)

		return fmt.Sprintf("[Custom-log] %s", formattedTime)
	}

	// Customizing the output format level
	output.FormatLevel = func(i interface{}) string {
		level := i.(string)

		switch level {
		case "debug":
			level = colorize.Blue.Bg(formatOutput(level, DefaultFormat))
		case "info":
			level = colorize.Cyan.Bg(formatOutput(level, DefaultFormat))
		case "error":
			level = colorize.Red.Bg(formatOutput(level, DefaultFormat))
		}

		return fmt.Sprintf("|%-6s|", level)
	}

	log := zerolog.New(output).With().Timestamp().Logger()

	return &service{
		logger: &log,
	}
}

// GetLogger returns the logger instance
func (s *service) GetLogger() *zerolog.Logger {
	return s.logger
}

// Info logs an info message
func (s *service) Info(msg string) {
	s.logger.Info().Msg(msg)
}

// Error logs a warning message
func (s *service) Error(msg string) {
	s.logger.Error().Msg(msg)
}

// Debug logs a debug message
func (s *service) Debug(msg string) {
	s.logger.Debug().Msg(msg)
}
