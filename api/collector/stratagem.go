package collector

import (
	"fmt"
	"net/http"
	"strings"

	"github.com/Spacelocust/for-democracy/database/enum"
	"golang.org/x/net/html"
)

type Stratagem struct {
	CodeName   *string  `json:"codename"`
	Name       string   `json:"name"`
	Keys       []string `json:"keys"`
	Uses       string   `json:"uses"`
	Cooldown   *int     `json:"cooldown"`
	Activation *int     `json:"activation"`
	ImageURL   string   `json:"imageUrl"`
	GroupId    int      `json:"groupId"`
}

func getStratagems() {
	// stratagems, err := getData[Stratagem]("/stratagems?limit=70")

	// if err != nil {
	// 	fmt.Println("Error getting stratagems")
	// }

	// if len(stratagems) > 0 {
	// 	// newStratagems := []model.Stratagem{}

	// 	// for _, stratagem := range stratagems {
	// 	// 	// newStratagems = append(newStratagems, model.Stratagem{
	// 	// 	// 	CodeName: stratagem.CodeName,
	// 	// 	// 	Name:     stratagem.Name,
	// 	// 	// 	UseCount: stratagem.Uses,
	// 	// 	// })

	// 	// 	fmt.Println(fmt.Sprintf(`%s : %s`, stratagem.Name, stratagem.ImageURL))
	// 	// }

	// 	// db.Clauses(clause.OnConflict{
	// 	// 	Columns:   []clause.Column{{Name: "name"}},
	// 	// 	DoUpdates: clause.AssignmentColumns([]string{"use_count", "use_type", "cooldown", "activation", "image_url", "type", "keys", "group_user_missions"}),
	// 	// }).Create(newStratagems)
	// }

	if st, err := getStratagemTypeFromLink("https://vxspqnuarwhjjbxzgauv.supabase.co/storage/v1/object/public/stratagems/1/4.svg"); err == nil {
		fmt.Println(st)
	}
}

// getStratagemTypeFromLink returns the stratagem type based on the color of the SVG image
func getStratagemTypeFromLink(l string) (enum.StratagemType, error) {
	resp, err := http.Get(l)
	if err != nil {
		fmt.Println("No response from request")
	}

	defer resp.Body.Close()

	doc, err := html.Parse(resp.Body)
	if err != nil {
		fmt.Println("Error:", err)
		return "", err
	}

	fillValueChan := make(chan string)

	go getColor(doc, fillValueChan)

	fillValue := <-fillValueChan

	stratagemType, err := getStratagemTypeByColor(fillValue)

	if err != nil {
		fmt.Println("Error:", err)
		return "", err
	}

	return stratagemType, nil
}

// extractFillValue extracts the fill value from the SVG data
func extractFillValue(data string) string {
	// Find the index of the fill attribute
	fillIndex := strings.Index(data, "fill:")

	// If the fill attribute is found
	if fillIndex != -1 {
		// Find the index of the closing semicolon
		semicolonIndex := strings.Index(data[fillIndex:], ";")

		// If the closing semicolon is found
		if semicolonIndex != -1 {
			// Extract the fill value
			fillValue := data[fillIndex+5 : fillIndex+semicolonIndex]
			return strings.Trim(fillValue, " ")
		}
	}

	return ""
}

// getColor extracts the fill value from the class .cls-1
func getColor(doc *html.Node, fillValueChan chan string) {
	var class func(*html.Node)
	class = func(n *html.Node) {
		if n.Type == html.ElementNode && n.Data == "style" {
			// Find the .cls-1 class
			if strings.Contains(n.FirstChild.Data, ".cls-1") {
				// Extract the fill value from the class
				fillValue := extractFillValue(n.FirstChild.Data)
				fillValueChan <- fillValue
			}
		}

		// Traverse the HTML of the webpage from the first child node
		for c := n.FirstChild; c != nil; c = c.NextSibling {
			class(c)
		}
	}
	class(doc)
}

// getStratagemTypeByColor returns the stratagem type based on the color
func getStratagemTypeByColor(hexColor string) (enum.StratagemType, error) {
	switch hexColor {
	case "#49adc9":
		return enum.Supply, nil
	case "#679552":
		return enum.Defensive, nil
	case "#de7b6c":
		return enum.Offensive, nil
	case "#c9b269":
		return enum.Mission, nil
	default:
		return "", fmt.Errorf("invalid color: %s", hexColor)
	}
}
