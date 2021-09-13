package utils

import (
	"os"
)

// NewPipe 创建进程间的一个无名管道
func NewPipe() (*os.File, *os.File, error) {
	read, write, err := os.Pipe()
	if err != nil {
		return nil, nil, err
	}
	return read, write, nil
}
