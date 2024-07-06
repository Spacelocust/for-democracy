package validators

type UserMission struct {
	Stratagems []uint `json:"stratagems" validate:"required,max=4,dive,required"`
}
