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
2 - Add it to the [`/api/db/loader/main.go`](/api/db/loader/main.go) file in the loader directory
```go
	models := []interface{}{
    // Add your models here
		&model.User{},
	}
``` 

## How to create enum
1 - Create your enum into the package `enum` in the [`/api/db/enum/enum.go`](/api/db/enum/enum.go) file.
You need to add Scan and Value methods for Gorm to be able to use the enum
```go
package enum

type Role string

const (
  User  Role = "user"
  Admin Role = "admin"
)

func (r *Role) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value.(string) {
		case string(Admin), string(User):
			*r = Role(b)
		default:
			return fmt.Errorf("invalid value for Role: %v", value)
		}
	}
	return nil
}

func (r Role) Value() (driver.Value, error) {
	return string(r), nil
}
```
2 - You need to create a type with the values you want to use as enum, in the [`/api/db/loader/main.go`](/api/db/loader/main.go) file in the loader directory
```sql
CREATE TYPE role AS ENUM ('user', 'admin');
```
3 - You need to create a column with the type
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
> You can also use an array of enums, but you will need to use the `datatype.EnumArray` type
```go
type User struct {
  gorm.Model
  SteamId    *string `gorm:"unique"`
  Username   string  `gorm:"unique;not null"`
  Password   *string
  Role       datatype.EnumArray[enum.Role] `gorm:"not null;type:text[]"`
}
```

