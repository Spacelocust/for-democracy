package utils

import (
	"os"
	"reflect"
)

// FileExists checks if a file exists
func FileExists(filename string) bool {
	info, err := os.Stat(filename)
	if os.IsNotExist(err) {
		return false
	}
	return !info.IsDir()
}

// Reduce a slice of elements to a new slice of elements
func Reduce[T, M any | *any](s []T, f func(M, T) M, initValue M) M {
	acc := initValue
	for _, v := range s {
		acc = f(acc, v)
	}
	return acc
}

// Get the values of a field in a slice of structs
func GetValues[T any](s []T, field string) []interface{} {
	values := make([]interface{}, len(s))
	for i, v := range s {
		value := reflect.ValueOf(v)
		fieldValue := value.FieldByName(field).Interface()
		values[i] = fieldValue
	}
	return values
}

// Splits a slice into smaller slices of size n
func SplitSlice[T any](slice []T, n int) [][]T {
	var divided [][]T
	l := len(slice)
	for i := 0; i < l; i += n {
		end := i + n
		if end > l {
			end = l
		}
		divided = append(divided, slice[i:end])
	}
	return divided
}
