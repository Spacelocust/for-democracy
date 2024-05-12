package collector

import (
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/datatype"
	"github.com/Spacelocust/for-democracy/db/enum"
	"github.com/Spacelocust/for-democracy/db/model"
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

func getStratagems() {
	db := db.GetDB()

	stratagems, err := getData[Stratagem]("/stratagems?limit=70")

	if err != nil {
		fmt.Println("Error getting stratagems")
	}

	if len(stratagems) > 0 {
		newStratagems := []model.Stratagem{}
		stratagemUseType := enum.Self

		for _, stratagem := range stratagems {
			keys := datatype.EnumArray[enum.StratagemKeys](stratagem.Keys)

			stratagemType, err := getStratagemTypeFromLink(stratagem.ImageURL)

			if err != nil {
				fmt.Printf("error getting stratagem type: %s", err)
				return
			}

			if stratagemType == enum.Mission {
				stratagemUseType = enum.Team
				if strings.Contains(stratagem.Name, "Reinforce") {
					stratagemUseType = enum.Shared
				}
			}

			newStratagems = append(newStratagems, model.Stratagem{
				CodeName:   stratagem.CodeName,
				Name:       stratagem.Name,
				UseCount:   getUseCount(stratagem.Uses),
				UseType:    stratagemUseType,
				Cooldown:   stratagem.Cooldown,
				Activation: stratagem.Activation,
				ImageURL:   stratagem.ImageURL,
				Type:       stratagemType,
				Keys:       keys,
			})
		}

		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoUpdates: clause.AssignmentColumns([]string{"code_name", "use_count", "use_type", "cooldown", "activation", "image_url", "type", "keys"}),
		}).Create(&newStratagems)
	}
}

// getStratagemTypeFromLink returns the stratagem type based on the color of the SVG image
func getStratagemTypeFromLink(link string) (enum.StratagemType, error) {
	resp, err := http.Get(link)
	if err != nil {
		fmt.Println("No response from request")
	}

	// Close the response body when the function returns
	defer resp.Body.Close()

	// Parse the HTML document
	data, err := io.ReadAll(resp.Body)
	// doc, err := html.Parse(resp.Body)
	if err != nil {
		fmt.Println("Error:", err)
		return "", err
	}

	fillValue, err := extractFillValue(string(data))

	if err != nil {
		fmt.Println("Error:", err)
		return "", err
	}

	// Get the stratagem type based on the fill value
	stratagemType, err := getStratagemTypeByHexColor(fillValue)

	if err != nil {
		fmt.Println("Error:", err)
		return "", err
	}

	return stratagemType, nil
}

func extractFillValue(data string) (string, error) {
	re := regexp.MustCompile(`fill:(.*?);`)
	matches := re.FindAllStringSubmatch(data, -1)

	fillValue := ""

	if len(matches) < 1 {
		re = regexp.MustCompile(`fill="(.*?)"`)
		matches = append([][]string{}, re.FindAllStringSubmatch(data, -1)...)

		if len(matches) < 1 {
			return "", fmt.Errorf("no fill value found")
		}
	}

	for _, match := range matches {
		if strings.Contains(match[1], "#fff") {
			continue
		}

		fillValue = match[1]
	}

	return strings.TrimSpace(fillValue), nil
}

// getStratagemTypeByHexColor returns the stratagem type based on the hexadecimal color
func getStratagemTypeByHexColor(hexColor string) (enum.StratagemType, error) {
	if st, ok := colors[hexColor]; ok {
		return st, nil
	}

	return "", fmt.Errorf("invalid color: %s", hexColor)
}

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
