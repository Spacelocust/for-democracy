package hellhub

import (
	"fmt"
	"io"
	"math"
	"net/http"
	"regexp"
	"strings"
	"sync"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/datatype"
	"github.com/Spacelocust/for-democracy/db/enum"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Stratagem struct {
	CodeName   *string              `json:"codename"`
	Name       string               `json:"name"`
	Keys       []enum.StratagemKeys `json:"keys"`
	Uses       string               `json:"uses"`
	Cooldown   int                  `json:"cooldown"`
	Activation int                  `json:"activation"`
	ImageURL   string               `json:"imageUrl"`
	GroupId    int                  `json:"groupId"`
}

var colors = map[string]enum.StratagemType{
	"#5dbcd6": enum.Supply,
	"#49adc9": enum.Supply,
	"#679552": enum.Defensive,
	"#de7b6c": enum.Offensive,
	"#c9b269": enum.Mission,
}

var errorStratagem = err.NewError("[stratagem]")

func storeStratagems(merrch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()

	stratagems, err := fetch[Stratagem]("/stratagems?limit=70")
	if err != nil {
		merrch <- errorStratagem.Error(err, "error getting stratagems")
		wg.Done()
		return
	}

	if len(stratagems) == 0 {
		merrch <- errorStratagem.Error(nil, "no stratagems found")
		wg.Done()
		return
	}

	// Split the stratagems into 3 parts to be processed concurrently
	splitStratagems := utils.SplitSlice(stratagems, int(math.Round(float64(len(stratagems))/3)))

	// Create a new stratagem slice to store the stratagems
	stratagemUseType := enum.Self

	// Channel to send errors from the goroutines
	errch := make(chan error, len(splitStratagems))
	swg := &sync.WaitGroup{}

	// Add the number of goroutines to the wait group
	swg.Add(len(splitStratagems))

	for _, splitStratagem := range splitStratagems {
		go func() {
			if err := db.Transaction(func(tx *gorm.DB) error {
				for _, stratagem := range splitStratagem {
					// Convert the string keys to enum keys
					keys := datatype.EnumArray[enum.StratagemKeys](stratagem.Keys)

					// Get the stratagem type based on the SVG image link
					stratagemType, err := getStratagemTypeFromLink(stratagem.ImageURL)
					if err != nil {
						return errorStratagem.Error(err, "error getting stratagem type")
					}

					// Set the stratagem use type based on the stratagem type
					if stratagemType == enum.Mission {
						stratagemUseType = enum.Team
						if strings.Contains(stratagem.Name, "Reinforce") {
							stratagemUseType = enum.Shared
						}
					}

					err = db.Clauses(clause.OnConflict{
						Columns:   []clause.Column{{Name: "name"}},
						DoUpdates: clause.AssignmentColumns([]string{"code_name", "use_count", "use_type", "cooldown", "activation", "image_url", "type", "keys"}),
					}).Create(&model.Stratagem{
						CodeName:   stratagem.CodeName,
						Name:       stratagem.Name,
						UseCount:   getUseCount(stratagem.Uses),
						UseType:    stratagemUseType,
						Cooldown:   stratagem.Cooldown,
						Activation: stratagem.Activation,
						ImageURL:   stratagem.ImageURL,
						Type:       stratagemType,
						Keys:       keys,
					}).Error

					if err != nil {
						return errorStratagem.Error(err, "error creating stratagem")
					}
				}

				return nil
			}); err != nil {
				errch <- err
				swg.Done()
				return
			}

			errch <- nil
			swg.Done()
		}()
	}

	// Wait for all the goroutines to finish
	swg.Wait()
	close(errch)

	// Check if there was an error fetching any of the pages
	for err := range errch {
		if err != nil {
			merrch <- err
			wg.Done()
			return
		}
	}

	// Send nil to the channel to indicate that there was no error
	merrch <- nil
	wg.Done()
}

// Get the stratagem type based on the SVG image link
func getStratagemTypeFromLink(link string) (enum.StratagemType, error) {
	resp, err := http.Get(link)
	if err != nil {
		return "", fmt.Errorf("no response from request: %w", err)
	}
	defer resp.Body.Close()

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("error reading response body: %w", err)
	}

	fillValue, err := extractFillValue(string(data))
	if err != nil {
		return "", fmt.Errorf("error extracting fill value: %w", err)
	}

	stratagemType, err := getStratagemTypeByHexColor(fillValue)
	if err != nil {
		return "", fmt.Errorf("error getting stratagem type: %w", err)
	}

	return stratagemType, nil
}

// Extract the fill value from the SVG image
func extractFillValue(data string) (string, error) {
	// Find the fill value in the SVG style attribute
	fill, err := getFill(data, regexp.MustCompile(`fill:(.*?);`))
	if err == nil {
		return fill, nil
	}

	// Find the fill value in the SVG fill attribute
	fill, err = getFill(data, regexp.MustCompile(`fill="(.*?)"`))
	if err == nil {
		return fill, nil
	}

	return "", err
}

// Get the fill value that match the regular expression
func getFill(data string, re *regexp.Regexp) (string, error) {
	matches := re.FindAllStringSubmatch(data, -1)

	if len(matches) > 0 {
		// Get the fill value that is not white
		for _, match := range matches {
			if !strings.Contains(match[1], "#fff") {
				return strings.TrimSpace(match[1]), nil
			}
		}
	}

	return "", fmt.Errorf("no fill value found")
}

// Get the stratagem type based on the hex color
func getStratagemTypeByHexColor(hexColor string) (enum.StratagemType, error) {
	if st, ok := colors[hexColor]; ok {
		return st, nil
	}

	return "", fmt.Errorf("invalid color: %s", hexColor)
}

// Get the use count of the stratagem based on the string value
func getUseCount(useCount string) *int {
	count := 0

	switch useCount {
	case "Unlimited", "":
		return nil
	case "Single use":
		count = 1
		return &count
	default:
		fmt.Sscanf(useCount, "%d uses", &count)
		return &count
	}
}
