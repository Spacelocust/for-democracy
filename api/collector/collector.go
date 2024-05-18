package collector

import (
	"fmt"
	"time"

	"github.com/Spacelocust/for-democracy/collector/helldivers"
	"github.com/Spacelocust/for-democracy/collector/hellhub"
)

func CollectData() {
	hellhubStart := time.Now()
	if err := hellhub.GetData(); err != nil {
		fmt.Println(err)
	}
	hellhubEnd := time.Since(hellhubStart)

	helldiversStart := time.Now()
	if err := helldivers.GetData(); err != nil {
		fmt.Println(err)
	}
	helldiversEnd := time.Since(helldiversStart)

	fmt.Printf("HellHub data collection took %v\n", hellhubEnd)
	fmt.Printf("Helldivers data collection took %v\n", helldiversEnd)
}
