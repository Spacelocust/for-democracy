package server

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterRootRoutes(r *gin.Engine) {
	r.GET("/", s.Root)
}

func (s *Server) Root(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Hello, World!",
	})
}
