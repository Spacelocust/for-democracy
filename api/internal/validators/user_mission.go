package validators

type UserMission struct {
	Stratagems []uint `json:"stratagems" validate:"required,dive,required"`
}
