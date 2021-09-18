package main

/*
#include<stdlib.h>
 */
import "C"
import (
	"fmt"
	"time"
)

func Random() int {
	return int(C.random())
}

func Seed(i int) {
	C.srandom(C.uint(i))
}

func main() {
	Seed(time.Now().Second())
	fmt.Println(Random())
}
