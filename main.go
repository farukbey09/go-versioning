package main

import (
	"github.com/gofiber/fiber/v2"
)

// CI/CD tarafından -ldflags ile inject edilir.
// Lokal geliştirmede "dev" / "unknown" olarak kalır.
var (
	Version   = "dev"
	Commit    = "unknown"
	BuildTime = "unknown"
)

func main() {
	app := fiber.New(fiber.Config{
		// Fiber'ın startup banner'ını kapat
		DisableStartupMessage: true,
	})

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message": "hello world",
		})
	})

	app.Get("/version", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"version":    Version,
			"commit":     Commit,
			"build_time": BuildTime,
		})
	})

	app.Listen(":8080")
}
