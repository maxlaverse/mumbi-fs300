package main

import (
	"fmt"
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
	err    chan error
	port   *serial.Port
}

func NewSerialHandler(device string, in chan []byte) *SerialHandler {
	return &SerialHandler{
		done:   make(chan struct{}),
		device: device,
		in:     in,
		err:    make(chan error),
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
			s.err <- err
			return
		}
		if n > 0 {
			buffer = buffer + string(buf[0:n])
			for strings.Contains(buffer, ">") {
				pos := strings.Index(buffer, ">")
				s.in <- []byte(buffer[0:pos])
				buffer = strings.TrimPrefix(buffer, buffer[0:pos+1])
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

func (s *SerialHandler) Run() error {
	fmt.Println("Serial Handler running")
	go s.watchSerial()

	for {
		select {
		case c := <-s.out:
			fmt.Printf("Writing to serial: %v\n", c)
			_, err2 := s.port.Write(c)
			if err2 != nil {
				return err2
			}
			err2 = s.port.Flush()
			if err2 != nil {
				return err2
			}
			time.Sleep(DELAY_BETWEEN_TRANSMISSION_MS * time.Millisecond)
		case e := <-s.err:
			fmt.Println("Exiting MqttHandler loop because of an error")
			return e
		case <-s.done:
			fmt.Println("Closing serial")
		}
	}
	fmt.Println("End of serial loop")
	return nil
}

func (s *SerialHandler) Write(message []byte) {
	s.out <- message
}

func (s *SerialHandler) Stop() {
	s.done <- struct{}{}
}
