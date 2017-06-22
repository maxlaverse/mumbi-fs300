package main

import (
	"encoding/json"
	"os"
)

type GlobalConfiguration struct {
	Device   string
	Broker   string
	Switches map[string]SwitchConfiguration
}

type SwitchConfiguration struct {
	On  string
	Off string
}

func readConfiguration(filename string) (error, GlobalConfiguration) {
	var configuration GlobalConfiguration

	file, err := os.Open(filename)
	if err != nil {
		return err, configuration
	}
	decoder := json.NewDecoder(file)

	err = decoder.Decode(&configuration)
	return err, configuration
}
