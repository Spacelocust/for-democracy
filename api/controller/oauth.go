package controller

import (
	"github.com/gofiber/fiber/v2"
	"github.com/shareed2k/goth_fiber"
)

// @Summary			 Get the user after authentication is complete from the provider
// @Description  Route used by the provide to send the user back after authentication
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200  {object}  goth.User
// @Failure      401  {object}  fiber.Error
// @Failure      500  {object}  fiber.Error
// @Router       /auth/:provider/callback [get]
func OAuthCallback(c *fiber.Ctx) error {
	user, err := goth_fiber.CompleteUserAuth(c, goth_fiber.CompleteUserAuthOptions{ShouldLogout: false})
	if err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, "Failed to complete user authentication")
	}

	if err := c.JSON(user); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to return user")
	}

	return nil
}

// @Summary			 Log the user out
// @Description  Route used to log the user out
// @Tags         authentication
// @Produce      json
// @Param        provider   path      string  true  "Provider name"
// @Success      200
// @Failure      401  {object}  fiber.Error
// @Failure      500  {object}  fiber.Error
// @Router       /logout/:provider [get]
func OAuthLogout(c *fiber.Ctx) error {
	if err := goth_fiber.Logout(c); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to log out user")
	}

	if err := c.Redirect("/"); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to redirect user")
	}

	return nil
}

// @Summary			 Authenticate the user
// @Description  Route used to authenticate the user
// @Tags         authentication
// @Produce      json
// @Success      200  {object}  goth.User
// @Failure      401  {object}  fiber.Error
// @Failure      500  {object}  fiber.Error
// @Router       /auth/:provider [get]
func OAuth(c *fiber.Ctx) error {
	// try to get the user without re-authenticating
	user, err := goth_fiber.CompleteUserAuth(c)
	if err != nil {
		if err := goth_fiber.BeginAuthHandler(c); err != nil {
			return fiber.NewError(fiber.StatusInternalServerError, "Failed to begin authentication")
		}
	}

	if err := c.JSON(user); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to return user")
	}

	return nil
}

// @Summary			 View to authenticate the user
// @Description  Route used to show the form to authenticate the user
// @Tags         authentication
// @Produce      html
// @Success      200
// @Failure      500  {object}  fiber.Error
func Auth(c *fiber.Ctx) error {
	if err := c.Format("<p><a href='/oauth/steam'>steam</a></p>"); err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, "Failed to show authentication form")
	}

	return nil
}
