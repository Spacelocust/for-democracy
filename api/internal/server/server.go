package server

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/Spacelocust/for-democracy/docs"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/logger"
	"github.com/Spacelocust/for-democracy/internal/model"
	_ "github.com/Spacelocust/for-democracy/internal/oauth"
	"github.com/Spacelocust/for-democracy/internal/validators"
)

type Server struct {
	port int

	db        database.Service
	validator validators.Service
	logger    logger.Service
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type SuccessResponse struct {
	Message string `json:"message"`
}

const (
	SERVER_ERROR_MESSAGE      = "something went wrong, please try again later"
	ERROR_FETCHING_MESSAGE    = "error while fetching %s"
	ERROR_DELETING_MESSAGE    = "error while deleting %s"
	ERROR_UPDATING_MESSAGE    = "error while updating %s"
	NOT_FOUND_MESSAGE         = "%s not found"
	NOT_AUTHENTICATED_MESSAGE = "you must be authenticated"
)

func NewServer() *http.Server {
	port, _ := strconv.Atoi(os.Getenv("API_PORT"))
	NewServer := &Server{
		port:      port,
		db:        database.New(),
		validator: validators.New(),
		logger:    logger.New(),
	}

	// Register custom validation rules
	err := NewServer.validator.RegisterValidations(map[string]validator.Func{
		"difficulty":    enum.ValidateDifficulty,
		"objectiveType": enum.ValidateObjectiveType,
		"datetime":      validators.DateTime,
		"gte_datetime":  validators.GteDateTime,
	})

	if err != nil {
		log.Fatal(err)
	}

	docs.SwaggerInfo.Host = fmt.Sprintf("%s:%s", os.Getenv("API_DOMAIN"), os.Getenv("API_PORT"))
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

	// Declare Server config
	server := &http.Server{
		Addr:        fmt.Sprintf(":%d", NewServer.port),
		Handler:     NewServer.RegisterRoutes(),
		IdleTimeout: time.Minute,
		ReadTimeout: 10 * time.Second,
	}

	server.RegisterOnShutdown(func() {
		if err := NewServer.db.Close(); err != nil {
			log.Fatal(err)
		}
	})

	return server
}

// checkAuth checks if the user is authenticated and returns the user
func checkAuth(c *gin.Context) model.User {
	user, ok := c.MustGet("user").(model.User)
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: NOT_AUTHENTICATED_MESSAGE})
		return model.User{}
	}

	return user
}

// NotFoundResponse sends a 404 response with a custom message (e.g "'your text' not found")
func (s *Server) NotFoundResponse(c *gin.Context, text string) {
	c.AbortWithStatusJSON(http.StatusNotFound, ErrorResponse{Error: fmt.Sprintf(NOT_FOUND_MESSAGE, text)})
}

// InternalErrorResponse sends a 500 response with a custom message (e.g "something went wrong, please try again later")
func (s *Server) InternalErrorResponse(c *gin.Context, err error) {
	s.logger.Error(err.Error())
	c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: SERVER_ERROR_MESSAGE})
}

// ForbiddenResponse sends a 403 response with a custom message
func (s *Server) ForbiddenResponse(c *gin.Context, text string) {
	s.logger.Info(fmt.Sprintf("Forbidden: %s", text))
	c.AbortWithStatusJSON(http.StatusForbidden, ErrorResponse{Error: text})
}

// BadRequestResponse sends a 400 response with a custom message
func (s *Server) BadRequestResponse(c *gin.Context, text string) {
	s.logger.Info(fmt.Sprintf("Bad request: %s", text))
	c.AbortWithStatusJSON(http.StatusBadRequest, ErrorResponse{Error: text})
}

// UnauthorizedResponse sends a 401 response with a custom message
func (s *Server) UnauthorizedResponse(c *gin.Context, text string) {
	s.logger.Info(fmt.Sprintf("Unauthorized: %s", text))
	c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: text})
}
