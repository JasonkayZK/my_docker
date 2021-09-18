package utils

import (
	"fmt"
	"testing"
)

func TestRandStringBytes(t *testing.T) {
	fmt.Println(RandStringBytes(16))
}
