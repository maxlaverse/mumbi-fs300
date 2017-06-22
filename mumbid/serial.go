package main

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/tarm/serial"
)

const DELAY_BETWEEN_TRANSMISSION_MS = 200

type SerialHandler struct {
	done   chan struct{}
	device string
	in     chan []byte
	out    chan []byte
	port   *serial.Port
}

func NewSerialHandler(device string, in chan []byte) *SerialHandler {
	return &SerialHandler{
		done:   make(chan struct{}),
		device: device,
		in:     in,
		out:    make(chan []byte),
	}
}

func (s *SerialHandler) watchSerial() {
	fmt.Println("Waiting for serial")
	buf := make([]byte, 128)
	buffer := ""
	for {
		n, err := s.port.Read(buf)
		if err != nil {
			panic(err)
		}
		if n > 0 {
			buffer = buffer + string(buf[0:n])
			if strings.HasSuffix(buffer, "\n") {
				s.in <- []byte(buffer)
				buffer = ""
			}
		}
	}
}

func (s *SerialHandler) Open() error {
	c := &serial.Config{Name: s.device, Baud: 9600}
	p, err := serial.OpenPort(c)
	s.port = p
	return err
}

func (s *SerialHandler) Start() {
	go s.watchSerial()

	fmt.Println("Main serial loop ready")
	for {
		select {
		case c := <-s.out:
			fmt.Printf("Writing to serial: %v\n", c)
			_, err2 := s.port.Write(c)
			if err2 != nil {
				log.Fatal(err2)
			}
			time.Sleep(DELAY_BETWEEN_TRANSMISSION_MS * time.Millisecond)
		case <-s.done:
			fmt.Println("Closing serial")
			return
		}
	}
	fmt.Println("End of serial loop")
}

func (s *SerialHandler) Write(message []byte) {
	s.out <- message
}

func (s *SerialHandler) Stop() {
	s.done <- struct{}{}
}
