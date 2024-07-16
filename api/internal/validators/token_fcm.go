package validators

type TokenFcm struct {
	Token string `json:"token" validate:"required"`
}
