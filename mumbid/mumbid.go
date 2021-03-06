package main

import (
	"fmt"
	"reflect"
	"strings"
	"time"
)

const TOPIC_PREFIX = "home/"
const SWITCH_ALL = "_all"
const SET_COMMAND = "set"
const STATE_ON = "ON"
const STATE_OFF = "OFF"

type MumbiDaemon struct {
	done          chan struct{}
	configuration GlobalConfiguration
	serial        *SerialHandler
	mqtt          *MqttHandler
	mqttIn        chan MqttMessage
	serialIn      chan []byte
}

func NewMumbiDaemon(configuration GlobalConfiguration) *MumbiDaemon {
	return &MumbiDaemon{
		done:          make(chan struct{}),
		mqttIn:        make(chan MqttMessage),
		serialIn:      make(chan []byte),
		configuration: configuration,
	}
}

func (m *MumbiDaemon) switchNameList() []string {
	keys := reflect.ValueOf(m.configuration.Switches).MapKeys()
	strkeys := make([]string, len(keys))
	for i := 0; i < len(keys); i++ {
		strkeys[i] = keys[i].String()
	}
	return strkeys
}

func (m *MumbiDaemon) Start() error {
	m.serial = NewSerialHandler(m.configuration.Device, m.serialIn)
	go func() {
		for {
			err := m.serial.Open()
			if err != nil {
				fmt.Printf("Cound not open the serial connection: %v\n", err)
				time.Sleep(10 * time.Second)
				continue
			}
			err = m.serial.Run()
			if err == nil {
				break
			}
			fmt.Printf("Serial handler exited: %v\n", err)
			time.Sleep(10 * time.Second)
		}
	}()

	m.mqtt = NewMqttHandler(m.configuration.Broker, m.mqttIn)
	go func() {
		for {
			err := m.mqtt.Connect()
			if err != nil {
				fmt.Printf("Cound not open the connect to the broker: %v\n", err)
				time.Sleep(10 * time.Second)
				continue
			}

			switchKeys := reflect.ValueOf(m.configuration.Switches).MapKeys()
			topicList := make([]string, len(switchKeys))
			for i := 0; i < len(switchKeys); i++ {
				topicList[i] = TOPIC_PREFIX + switchKeys[i].String() + "/" + SET_COMMAND
			}

			m.mqtt.Subscribe(topicList)
			err = m.mqtt.Run()
			if err == nil {
				break
			}
			fmt.Printf("Mqtt handler exited: %v\n", err)
			time.Sleep(10 * time.Second)
		}
	}()

	go m.loop()
	return nil
}

func switchFromTopic(topicName string) string {
	return strings.TrimSuffix(topicName[len(TOPIC_PREFIX):], "/"+SET_COMMAND)
}

func (m *MumbiDaemon) findSwitches(serialMessage string) (string, []string) {
	var switchList []string
	state := ""
	for name, switche := range m.configuration.Switches {
		if switche.On == serialMessage {
			state = STATE_ON
			if strings.HasSuffix(name, SWITCH_ALL) {
				switchList = append(switchList, m.switchNameList()...)
			} else {
				switchList = append(switchList, name)
			}
		} else if switche.Off == serialMessage {
			state = STATE_OFF
			if strings.HasSuffix(name, SWITCH_ALL) {
				switchList = append(switchList, m.switchNameList()...)
			} else {
				switchList = append(switchList, name)
			}
		}
	}
	return state, switchList
}

func (m *MumbiDaemon) loop() {
	fmt.Println("MumbiDaemon loop ready")
	for {
		select {
		case c := <-m.mqttIn:
			fmt.Printf("Received a MQTT message for: %s, %s\n", c.Topic, c.Message)
			theSwitch := m.configuration.Switches[switchFromTopic(c.Topic)]

			if c.Message == STATE_ON {
				m.serial.Write([]byte("<" + string(theSwitch.On) + ">"))
			} else {
				m.serial.Write([]byte("<" + string(theSwitch.Off) + ">"))
			}

			if m.configuration.EchoState {
				m.mqtt.Send(&MqttMessage{
					Topic:   strings.TrimSuffix(c.Topic, "/"+SET_COMMAND),
					Message: c.Message,
				})
			}

		case c := <-m.serialIn:
			serialMessage := strings.TrimSpace(string(c))
			fmt.Printf("Received a SERIAL message: %s (%d)\n", serialMessage, len(serialMessage))
			serialMessage = strings.TrimPrefix(serialMessage, "<")
			serialMessage = strings.TrimSuffix(serialMessage, ">")

			state, switchList := m.findSwitches(serialMessage)
			fmt.Printf("Found %d matching switch for state %s\n", len(switchList), state)

			for _, switchName := range switchList {
				m.mqtt.Send(&MqttMessage{
					Topic:   TOPIC_PREFIX + switchName,
					Message: state,
				})
			}

		case <-m.done:
			fmt.Println("Exiting loop")
			return
		}
	}
}

func (m *MumbiDaemon) Stop() {
	m.done <- struct{}{}
	m.mqtt.Stop()
	m.serial.Stop()
}
