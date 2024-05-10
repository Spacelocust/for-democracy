package collector

import "fmt"

type Stratagem struct{}

func getStratagems() (stratagems []Stratagem) {
	stratagems, err := getData[Stratagem]("/stratagems")

	if err != nil {
		fmt.Println("Error getting stratagems")
	}

	return stratagems
}
