package collector

import "fmt"

type Statistic struct {
}

func getStatistics() (statistics []Statistic) {
	statistics, err := getData[Statistic]("/statistics")

	if err != nil {
		fmt.Println("Error getting statistics")
	}

	return statistics
}
