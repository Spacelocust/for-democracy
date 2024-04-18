package router

import (
	"fmt"

	"github.com/gofiber/fiber/v2"
	"github.com/shareed2k/goth_fiber"
)

// authRoutes sets up the authentication routes
func authRoutes(app *fiber.App) {

	app.Get("/auth/:provider/callback", func(c *fiber.Ctx) error {
		user, err := goth_fiber.CompleteUserAuth(c, goth_fiber.CompleteUserAuthOptions{ShouldLogout: false})
		if err != nil {
			return err
		}
		c.JSON(user)
		return nil
	})

	app.Get("/logout/:provider", func(c *fiber.Ctx) error {
		goth_fiber.Logout(c)
		c.Redirect("/")
		return nil
	})

	app.Get("/auth/:provider", func(c *fiber.Ctx) error {
		session, err := goth_fiber.SessionStore.Get(c)
		if err != nil {
			return err
		}
		fmt.Println(session.Get("steam"))
		if gothUser, err := goth_fiber.CompleteUserAuth(c); err == nil {
			c.JSON(gothUser)
		} else {
			goth_fiber.BeginAuthHandler(c)
		}
		return nil
	})

	app.Get("/auth", func(c *fiber.Ctx) error {
		c.Format("<p><a href='/auth/steam'>steam</a></p>")
		return nil
	})
}
