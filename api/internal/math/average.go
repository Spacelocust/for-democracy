package math

import (
	"fmt"
	"math"
)

// CalculateDifferences calculates the differences between data[t-interval] and data[t] for all t in the interval [interval, len(data))
func CalculateDifferences(data []float64) float64 {
	fmt.Println("current health: ", data[len(data)-1])
	fmt.Println("previous health: ", data[0])
	return (data[len(data)-1] - data[0])
}

// example : CalculateDifferences([1, 2, 3, 4, 5], 2) => [2, 2, 2]

// RunningAverage calculates the running average of data[t-windowSize+1:t+1] for all t in the interval [windowSize-1, len(data))
// func RunningAverage(data []float64, windowSize int) []float64 {
// 	var averages []float64
// 	for t := windowSize - 1; t < len(data); t++ {
// 		sum := 0.0
// 		for i := 0; i < windowSize; i++ {
// 			sum += data[t-i]
// 		}
// 		avg := sum / float64(windowSize)
// 		averages = append(averages, avg)
// 	}
// 	return averages
// }

// example : RunningAverage([1, 2, 3, 4, 5], 3) => [2, 3, 4]

func roundFloat(val float64, precision uint) float64 {
	ratio := math.Pow(10, float64(precision))
	return math.Round(val*ratio) / ratio
}

// Average calculates the average of data
// func Average(data []float64) float64 {
// 	sum := 0.0
// 	for _, avg := range data {
// 		sum += avg
// 	}
// 	return sum / float64(len(data))
// }

func Impact(data []float64, regen float64) {
	fmt.Println(data)
	differences := CalculateDifferences(data)

	// fmt.Println(differences)
	// runningAverage := RunningAverage(differences, 3)

	fmt.Println(differences*3, regen)
	// average := Average(runningAverage)
	// fmt.Println(average * 6)
}
