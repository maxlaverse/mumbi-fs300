package main

import (
	"fmt"
	"os"
	"os/signal"

	flags "github.com/jessevdk/go-flags"
)

var options struct {
	ConfigFile string `short:"c" long:"config" env:"CONFIG_FILE" description:"Path to config file"`
}

var parser = flags.NewParser(&options, flags.Default)

func main() {
	var parser = flags.NewParser(&options, flags.Default)

	// Parse the parameter
	if _, err := parser.Parse(); err != nil {
		if flagsErr, ok := err.(*flags.Error); ok && flagsErr.Type == flags.ErrHelp {
			os.Exit(0)
		} else {
			os.Exit(1)
		}
	}

	// Read the configuration
	err, configuration := readConfiguration(options.ConfigFile)
	if err != nil {
		panic(err)
	}

	// Setup the interrupt handler
	stopSignal := make(chan os.Signal, 1)
	signal.Notify(stopSignal, os.Interrupt, os.Kill)

	// Instanciate and start the daemon
	mumbid := NewMumbiDaemon(configuration)
	err = mumbid.Start()
	if err != nil {
		panic(err)
	}

	fmt.Println("Running")
	<-stopSignal

	mumbid.Stop()
	fmt.Println("Exit")
}
