package main

import (
	"fmt"

	"github.com/yosssi/gmq/mqtt"
	"github.com/yosssi/gmq/mqtt/client"
)

const MQTT_CLIENT_NAME = "mumbid"

type MqttMessage struct {
	Topic   string
	Message string
}

type MqttHandler struct {
	done          chan struct{}
	brokerAddress string
	client        *client.Client
	in            chan MqttMessage
	out           chan MqttMessage
	err           chan error
}

func NewMqttHandler(brokerAddress string, in chan MqttMessage) *MqttHandler {
	return &MqttHandler{
		done:          make(chan struct{}),
		brokerAddress: brokerAddress,
		in:            in,
		out:           make(chan MqttMessage),
		err:           make(chan error),
	}
}

func (h *MqttHandler) Connect() error {
	h.client = client.New(&client.Options{
		ErrorHandler: func(err error) {
			fmt.Printf("The MQTT client has returned an error: %v\n", err)
			h.err <- err
		},
	})

	defer h.client.Terminate()

	fmt.Printf("Connecting to the broker")
	return h.client.Connect(&client.ConnectOptions{
		Network:  "tcp",
		Address:  h.brokerAddress,
		ClientID: []byte(MQTT_CLIENT_NAME),
	})
}

func (h *MqttHandler) Subscribe(topicList []string) error {
	topicSuscriptions := make([]*client.SubReq, len(topicList))
	for k, topicName := range topicList {
		topicSuscriptions[k] = &client.SubReq{
			TopicFilter: []byte(topicName),
			QoS:         mqtt.QoS1,
			Handler:     h.messageHandler,
		}
	}

	fmt.Println("Subscribing to topics")
	return h.client.Subscribe(&client.SubscribeOptions{
		SubReqs: topicSuscriptions,
	})
}

func (h *MqttHandler) Run() error {
	fmt.Println("Mqtt Handler running")
	for {
		select {
		case c := <-h.out:
			fmt.Printf("Sending MqttMessage to '%s': '%s'\n", c.Topic, c.Message)
			err := h.client.Publish(&client.PublishOptions{
				QoS:       mqtt.QoS0,
				TopicName: []byte(c.Topic),
				Message:   []byte(c.Message),
				Retain:    true,
			})
			if err != nil {
				fmt.Printf("An error has happened during the publication: %v\n", err)
				return err
			}
		case e := <-h.err:
			fmt.Println("Exiting MqttHandler loop because of an error")
			return e
		case <-h.done:
			fmt.Println("Exiting MqttHandler loop")
		}
	}
	return nil
}

func (h *MqttHandler) Stop() error {
	fmt.Println("Stopping MqttHandler")
	h.done <- struct{}{}
	// // Unsubscribe from topics.
	// err = cli.Unsubscribe(&client.UnsubscribeOptions{
	// 	TopicFilters: [][]byte{
	// 		[]byte("foo"),
	// 	},
	// })
	// if err != nil {
	// 	panic(err)
	// }
	return h.client.Disconnect()
}

func (h *MqttHandler) Send(message *MqttMessage) {
	h.out <- *message
}

func (h *MqttHandler) messageHandler(topicName []byte, message []byte) {
	h.in <- MqttMessage{
		Topic:   string(topicName),
		Message: string(message),
	}
}
