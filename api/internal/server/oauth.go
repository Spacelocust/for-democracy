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
	route := r.Group("/oauth")

	route.GET("/me", s.OAuthMiddleware, s.OAuthMe)
	route.GET("/logout/:provider", s.OAuthMiddleware, s.OAuthLogout)
	route.GET("/:provider", s.OAuth)
	route.GET("/:provider/callback", s.OAuthCallback)
}

type Me struct {
	Username  string `json:"Username"`
	AvatarUrl string `json:"AvatarUrl"`
	SteamId   string `json:"SteamId"`
}

// @Summary			 Get the user
// @Description  Route used to get the user
// @Tags         authentication
// @Produce      json
// @Success      200  {object}  server.Me
// @Failure      401  {object}  server.ErrorResponse
// @Router       /oauth/me [get]
func (s *Server) OAuthMe(c *gin.Context) {
	user := checkAuth(c)

	c.JSON(http.StatusOK, Me{
		Username:  user.Username,
		AvatarUrl: *user.AvatarUrl,
		SteamId:   *user.SteamId,
	})
}

// @Summary			 Get the user after authentication is complete from the provider
// @Description  Route used by the provide to send the user back after authentication
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200  {object}  goth.User
// @Failure      500  {object}  server.ErrorResponse
// @Router       /oauth/{provider}/callback [get]
func (s *Server) OAuthCallback(c *gin.Context) {
	db := s.db.GetDB()
	user, err := oauth.CompleteUserAuth(c)

	if err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	newUser := model.User{
		Username:  user.NickName,
		AvatarUrl: &user.AvatarURL,
		SteamId:   &user.UserID,
		Role:      enum.User,
	}

	err = db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "steam_id"}},
		DoUpdates: clause.AssignmentColumns([]string{"username", "avatar_url"}),
	}).Create(&newUser).Error

	if err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	tokenString, err := utils.CreateToken(newUser)
	if err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	if err := db.Create(&model.Token{
		Token:  tokenString,
		UserId: newUser.ID,
	}).Error; err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	utils.CreateCookieToken(tokenString, c)

	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(pageLoading))
}

// @Summary			 Log the user out
// @Description  Route used to log the user out
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200
// @Failure      401  {object}  server.ErrorResponse
// @Failure      500  {object}  server.ErrorResponse
// @Router       /oauth/logout/{provider} [get]
func (s *Server) OAuthLogout(c *gin.Context) {
	db := s.db.GetDB()

	token, ok := c.Get("token")
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: NOT_AUTHENTICATED_MESSAGE})
		return
	}

	q := c.Request.URL.Query()
	c.Request.URL.RawQuery = q.Encode()

	if err := gothic.Logout(c.Writer, c.Request); err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while logging out the user"})
		return
	}

	// Delete the token from the database
	if err := db.Unscoped().Delete(&model.Token{}, "token = ?", token).Error; err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while logging out the user"})
		return
	}

	// Delete the cookie
	c.SetCookie("token", "", -1, "/", "", false, true)

	c.JSON(http.StatusOK, SuccessResponse{Message: "you have been logged out"})
}

// @Summary			 Authenticate the user
// @Description  Route used to authenticate the user
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200  {object}  goth.User
// @Router       /oauth/{provider} [get]
func (s *Server) OAuth(c *gin.Context) {
	oauth.BeginAuthHandler(c)
}

const pageLoading = `<!DOCTYPE html>
<html lang="en">
<head>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		
		<title>For Democracy - Login</title>
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
