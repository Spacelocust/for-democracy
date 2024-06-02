package main

import (
	"log"
	"time"

	"github.com/lib/pq"
)

// notifier encapsulates the state of the listener connection.
type notifier struct {
	listener *pq.Listener
	failed   chan error
}

// newNotifier creates a new notifier for given PostgreSQL credentials.
func newNotifier(dsn, channelName string) (*notifier, error) {
	n := &notifier{failed: make(chan error, 2)}

	listener := pq.NewListener(
		dsn,
		10*time.Second, time.Minute,
		n.logListener)

	if err := listener.Listen(channelName); err != nil {
		listener.Close()
		log.Println("ERROR!:", err)
		return nil, err
	}

	n.listener = listener
	return n, nil
}

// logListener is the state change callback for the listener.
func (n *notifier) logListener(event pq.ListenerEventType, err error) {
	if err != nil {
		log.Printf("listener error: %s\n", err)
	}
	if event == pq.ListenerEventConnectionAttemptFailed {
		n.failed <- err
	}
}

// fetch is the main loop of the notifier to receive data from
// the database in JSON-FORMAT and send it down the send channel.
func (n *notifier) fetch(data chan []byte) error {
	var fetchCounter uint64
	for {
		select {
		case e := <-n.listener.Notify:
			if e == nil {
				continue
			}
			fetchCounter++
			data <- []byte(e.Extra)
			//log.Println("FETCHED DAta", []byte(e.Extra))
		case err := <-n.failed:
			return err
		case <-time.After(time.Minute):
			go n.listener.Ping()
		}
	}
}

// close closes the notifier.
func (n *notifier) close() error {
	close(n.failed)
	return n.listener.Close()
}
