package validators

import (
	"time"

	"github.com/go-playground/validator/v10"
)

// DateTime is a custom validator to check if a field is a valid date time
func DateTime(fl validator.FieldLevel) bool {
	_, err := time.Parse(time.DateTime, fl.Field().String())
	return err == nil
}

// GteDateTime is a custom validator to check if a field is a date time greater than or equal to a fixed date time
func GteDateTime(fl validator.FieldLevel) bool {
	dateParam := fl.Param()

	if dateParam == "now" {
		dateParam = time.Now().Format(time.DateTime)
	}

	dateField, err := time.Parse(time.DateTime, fl.Field().String())
	if err != nil {
		return false
	}

	// Parse the fixed date string
	fixedDateParam, err := time.Parse(time.DateTime, dateParam)
	if err != nil {
		return false
	}

	// Perform the comparison
	return dateField.After(fixedDateParam) || dateField.Equal(fixedDateParam)
}
