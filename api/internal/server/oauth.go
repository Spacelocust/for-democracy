package server

import (
	"fmt"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/oauth"
	"github.com/gin-gonic/gin"
	"github.com/markbates/goth/gothic"
)

func (s *Server) RegisterOauthRoutes(r *gin.Engine) {
	r.GET("/steam", s.Steam)
	r.GET("/oauth/:provider/callback", s.OAuthCallback)
	r.GET("/oauth/logout/:provider", s.OAuthLogout)
	r.GET("/oauth/:provider", s.OAuth)
}

func (s *Server) Steam(c *gin.Context) {
	htmlFormat := `<html><body>%v</body></html>`
	html := fmt.Sprintf(htmlFormat, `<a href="/oauth/steam">Login through steamapp</a>`)
	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(html))
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

	c.JSON(http.StatusOK, user)
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

	c.Redirect(http.StatusFound, "/")
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
	user, err := oauth.CompleteUserAuth(c)

	if err == nil {
		c.JSON(http.StatusOK, user)
	} else {
		oauth.BeginAuthHandler(c)
	}
}
