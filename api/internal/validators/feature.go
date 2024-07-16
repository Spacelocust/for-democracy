package validators

type Feature struct {
	Code    string `json:"code" validate:"required"`
	Enabled *bool   `json:"enabled" validate:"required,boolean"`
}

type FeatureEnabled struct {
	Enabled *bool   `json:"enabled" validate:"required,boolean"`
}
