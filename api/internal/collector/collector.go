package collector

import (
	"fmt"
	"time"

	"github.com/Spacelocust/for-democracy/internal/collector/helldivers"
	"github.com/Spacelocust/for-democracy/internal/collector/hellhub"
	"github.com/Spacelocust/for-democracy/internal/database"
)

type Collector struct {
	Db database.Service
}

func (c *Collector) CollectData() {
	db := c.Db.GetDB()

	hellhubStart := time.Now()
	if err := hellhub.GetData(db); err != nil {
		fmt.Println(err)
	}
	hellhubEnd := time.Since(hellhubStart)

	helldiversStart := time.Now()
	if err := helldivers.GetData(db); err != nil {
		fmt.Println(err)
	}
	helldiversEnd := time.Since(helldiversStart)

	fmt.Printf("HellHub data collection took %v\n", hellhubEnd)
	fmt.Printf("Helldivers data collection took %v\n", helldiversEnd)
}

func (c *Collector) CollectEvents() {
	db := c.Db.GetDB()

	helldiversStart := time.Now()
	if err := helldivers.GetData(db); err != nil {
		fmt.Println(err)
	}
	helldiversEnd := time.Since(helldiversStart)

	fmt.Printf("Helldivers event collection took %v\n", helldiversEnd)
}

func NewCollector(db database.Service) *Collector {
	return &Collector{
		Db: db,
	}
}
