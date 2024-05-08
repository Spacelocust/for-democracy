# How to use Gorm with Atlas

## Table of Contents
- [Introduction](#introduction)
- [How to create table](#how-to-create-table)
- [How to create enum](#how-to-create-enum)

## Introduction
This document will guide you on how to use Gorm with Atlas.


## How to create table
1 - Create a struct that represents the table
```go
type User struct {
  gorm.Model
  SteamId    *string `gorm:"unique"`
  Username   string  `gorm:"unique;not null"`
  Password   *string
}
```
2 - Add it to the [`main.go`](/api/database/loader/main.go) file in the loader directory
```go
	models := []interface{}{
    // Add your models here
		&model.User{},
	}
``` 

## How to create enum

1 - You need to create a type with the values you want to use as enum, in the [`main.go`](/api/database/loader/main.go) file in the loader directory
```sql
CREATE TYPE role AS ENUM ('user', 'admin');
```
2 - You need to create a column with the type
```go
type User struct {
	gorm.Model
	SteamId    *string `gorm:"unique"`
	Username   string  `gorm:"unique;not null"`
	Password   *string
	Role       enum.Role `gorm:"not null;type:role"`
}
```

> [!NOTE]
> You can also use an array of enums, for example: 
```go
type User struct {
  gorm.Model
  SteamId    *string `gorm:"unique"`
  Username   string  `gorm:"unique;not null"`
  Password   *string
  Role       []enum.Role `gorm:"not null;type:role[]"`
}
```

