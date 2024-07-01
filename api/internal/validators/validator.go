package validators

import (
	"fmt"

	"github.com/go-playground/validator/v10"
)

type Service interface {
	// Validate validates the input struct
	GetValidate() *validator.Validate
	// Validate validates the input struct
	Validate(i interface{}) error
	// RegisterValidations register custom validation rules
	RegisterValidations(rules map[string]validator.Func) error
}

type service struct {
	validate *validator.Validate
}

func New() Service {
	return &service{
		validate: validator.New(validator.WithRequiredStructEnabled()),
	}
}

func (s *service) GetValidate() *validator.Validate {
	return s.validate
}

func (s *service) Validate(i interface{}) error {
	err := s.validate.Struct(i)
	if err != nil {
		if _, ok := err.(*validator.InvalidValidationError); ok {
			fmt.Println(err)
			return err
		}

		if len(err.(validator.ValidationErrors)) > 0 {
			fmt.Println(err.(validator.ValidationErrors).Error())
			return fmt.Errorf(err.(validator.ValidationErrors).Error())
		}
	}

	return nil
}

// RegisterValidations register custom validation rules
func (s *service) RegisterValidations(rules map[string]validator.Func) error {
	for name, function := range rules {
		if err := s.validate.RegisterValidation(name, function); err != nil {
			return err
		}
	}

	return nil
}
