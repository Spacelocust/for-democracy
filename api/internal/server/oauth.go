package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/oauth"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"github.com/markbates/goth/gothic"
	"gorm.io/gorm/clause"
)

func (s *Server) RegisterOauthRoutes(r *gin.Engine) {
	r.GET("/oauth/:provider/callback", s.OAuthCallback)
	r.GET("/oauth/logout/:provider", s.OAuthLogout)
	r.GET("/oauth/:provider", s.OAuth)
}

// @Summary			 Get the user after authentication is complete from the provider
// @Description  Route used by the provide to send the user back after authentication
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200  {object}  goth.User
// @Failure      401  {object}  gin.Error
// @Failure      500  {object}  gin.Error
// @Router       /oauth/{provider}/callback [get]
func (s *Server) OAuthCallback(c *gin.Context) {
	user, err := oauth.CompleteUserAuth(c)

	if err != nil {
		if err := c.AbortWithError(http.StatusInternalServerError, err); err != nil {
			return
		}
	}

	newUser := model.User{
		Username:  user.NickName,
		AvatarUrl: &user.AvatarURL,
		SteamId:   &user.UserID,
		Role:      enum.User,
	}

	err = s.db.GetDB().Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "steam_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"username", "avatar_url"}),
	}).Create(&newUser).Error

	if err != nil {
		if err := c.AbortWithError(http.StatusInternalServerError, err); err != nil {
			return
		}
	}

	tokenString, err := utils.CreateToken(newUser)
	if err != nil {
		c.String(http.StatusInternalServerError, "Error creating token")
		return
	}

	c.SetCookie("token", tokenString, 3600, "/", "", false, true)

	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(pageLoading))
}

// @Summary			 Log the user out
// @Description  Route used to log the user out
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200
// @Failure      401  {object}  gin.Error
// @Failure      500  {object}  gin.Error
// @Router       /oauth/logout/{provider} [get]
func (s *Server) OAuthLogout(c *gin.Context) {
	q := c.Request.URL.Query()
	c.Request.URL.RawQuery = q.Encode()
	if err := gothic.Logout(c.Writer, c.Request); err != nil {
		if err := c.AbortWithError(http.StatusInternalServerError, err); err != nil {
			return
		}
	}

	c.JSON(http.StatusOK, nil)
}

// @Summary			 Authenticate the user
// @Description  Route used to authenticate the user
// @Tags         authentication
// @Produce      json
// @Success      200  {object}  goth.User
// @Failure      401  {object}  gin.Error
// @Failure      500  {object}  gin.Error
// @Router       /oauth/{provider} [get]
func (s *Server) OAuth(c *gin.Context) {
	oauth.BeginAuthHandler(c)
}

const pageLoading = `<!DOCTYPE html>
<html lang="en">
<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>Centered Image</title>
		<style>
				body {
						display: flex;
						justify-content: center;
						flex-direction: column;
						align-items: center;
						height: 50vh;
						margin: 0;
						overflow: hidden;
						color: #dcdedf;
				}
				img {
						max-width: 75%;
						height: auto;
				}
		</style>
</head>
<body>
		<img src="https://www.pngmart.com/files/22/Steam-Logo-PNG.png" alt="Steam Logo">
		<p>You will be redirected shortly...</p>
</body>
</html>
`
