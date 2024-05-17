package helldivers

import (
	"sync"
)

func GetData() error {
	// Channel to send errors from the goroutines
	errpch := make(chan error, 2)
	wg := &sync.WaitGroup{}

	wg.Add(2)

	// Using go routines to fetch data concurrently
	go storeDefences(errpch, wg)
	go storeLiberations(errpch, wg)

	wg.Wait()
	close(errpch)

	for err := range errpch {
		if err != nil {
			return err
		}
	}

	return nil
}
