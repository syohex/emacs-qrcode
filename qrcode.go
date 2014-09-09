package main

import (
	"fmt"
	"os"

	"code.google.com/p/rsc/qr"
)

func main() {
	code, err := qr.Encode(os.Args[1], qr.L)
	if err != nil {
		os.Exit(1)
	}

	size := code.Size
	qrcode := make([]string, size)
	for i := 0; i < size; i++ {
		b := make([]byte, size)
		for j := 0; j < size; j++ {
			if code.Black(i, j) {
				b[j] = '1'
			} else {
				b[j] = '0'
			}
		}
		qrcode[i] = string(b)
	}

	for _, s := range qrcode {
		fmt.Println(s)
	}
}
