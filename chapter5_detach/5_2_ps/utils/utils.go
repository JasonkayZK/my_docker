package utils

import (
	"math/rand"
	"os"
	"time"
)

const (
	DateFormat = "2006-01-02 15:04:05"
)

// NewPipe 创建进程间的一个无名管道
func NewPipe() (*os.File, *os.File, error) {
	read, write, err := os.Pipe()
	if err != nil {
		return nil, nil, err
	}
	return read, write, nil
}

// PathExists 检查文件路径是否存在
func PathExists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

// RandStringBytes 生成n位随机字符串
func RandStringBytes(n int) string {
	letterBytes := "1234567890abcdefghijklmnopqrstuvwxyz"
	rand.Seed(time.Now().UnixNano())
	b := make([]byte, n)
	for i := range b {
		b[i] = letterBytes[rand.Intn(len(letterBytes))]
	}
	return string(b)
}
