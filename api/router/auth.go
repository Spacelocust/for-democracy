package router

import (
	"github.com/gofiber/fiber/v2"
	"github.com/shareed2k/goth_fiber"
)

// authRoutes sets up the authentication routes
func authRoutes(app *fiber.App) {

	// Route provider redirect after authentication
	app.Get("/auth/:provider/callback", func(c *fiber.Ctx) error {
		user, err := goth_fiber.CompleteUserAuth(c, goth_fiber.CompleteUserAuthOptions{ShouldLogout: false})
		if err != nil {
			return err
		}

		if err := c.JSON(user); err != nil {
			return err
		}

		return nil
	})

	app.Get("/logout/:provider", func(c *fiber.Ctx) error {
		if err := goth_fiber.Logout(c); err != nil {
			return err
		}

		if err := c.Redirect("/"); err != nil {
			return err
		}

		return nil
	})

	// Route to get the user after authentication or send to the provider
	app.Get("/auth/:provider", func(c *fiber.Ctx) error {
		// try to get the user without re-authenticating
		user, err := goth_fiber.CompleteUserAuth(c)
		if err != nil {
			if err := goth_fiber.BeginAuthHandler(c); err != nil {
				return err
			}
		}

		if err := c.JSON(user); err != nil {
			return err
		}

		return nil
	})

	app.Get("/auth", func(c *fiber.Ctx) error {
		if err := c.Format("<p><a href='/auth/steam'>steam</a></p>"); err != nil {
			return err
		}

		return nil
	})
}
