package zapper

import (
	"context"
	"fmt"
	"time"

	log "github.com/Spacelocust/for-democracy/logger"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gorm.io/gorm/logger"
)

type Zapper struct {
	logger *zap.Logger
}

var Zlogger *Zapper

func init() {
	if Zlogger == nil {
		Zlogger = NewZapper()
	}
}

func NewZapper() *Zapper {
	config := zap.NewDevelopmentConfig()
	config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder

	logger, _ := config.Build()
	defer func() {
		if err := logger.Sync(); err != nil {
			fmt.Println("Failed to sync logger", err)
		}
	}()

	return &Zapper{logger: logger}
}

func (l *Zapper) LogMode(level logger.LogLevel) logger.Interface {
	l.logger.Info("LogMode", zap.Int("level", int(level)))
	return l
}

func (l *Zapper) Info(ctx context.Context, msg string, args ...interface{}) {
	l.logger.Info(msg, zap.Any("args", args))
}

func (l *Zapper) Warn(ctx context.Context, msg string, args ...interface{}) {
	l.logger.Warn(msg, zap.Any("args", args))
}

func (l *Zapper) Error(ctx context.Context, msg string, args ...interface{}) {
	l.logger.Error(msg, zap.Any("args", args))
}

func (l *Zapper) Trace(ctx context.Context, begin time.Time, fc func() (sql string, rowsAffected int64), err error) {
	sql, rowsAffected := fc()

	if err != nil {
		l.logger.Error("Trace [rows:%v] ", zap.String("sql", sql), zap.Int64("rowsAffected", rowsAffected), zap.Error(err))
	} else {
		l.logger.Sugar().Infof("Trace [rows:%v] %s\n", rowsAffected, log.Yellow(sql))
	}
}
