This project aims to help automate the control over Mumbi m-FS300 switches.

It provides two software components:
* an Arduino program controlled over a serial connection and emitting/receiving signals from the switches and remote controls
* a Go daemon connected to an MQTT broker that controls the Arduino

## Hardware
* an Arduino (tested on an *nano* model)
* a 433.92 MHz RF emitter and receiver
* a Raspberry Pi (works on any computer)
* an antenna (optional)

## Cabling
The Arduino program expects your RF receiver to be connected on the digital port 2,
and the emitter to the digital port 3. Of course you can modify this by changing the value of the constantes at the top of the code.

```c
const int PIN_RECV=2;
const int PIN_XMIT=3;
```

The reception of signal is done using interrupts. For an Arduino
Nano it means that you can only use port 2 or 3 for this program (see [AttachInterrupt](https://www.arduino.cc/en/Reference/AttachInterrupt)).

I also recommend you to use an antenna as it really improves the reception range.

## Emitting and receiving signals
The Arduino program is very basic [pwm emitter/receiver](https://en.wikipedia.org/wiki/Pulse-width_modulation) for 1200μs long pulses. It reads the serial port for strings composed of `0`, `1` and ending with a return line `\n`.
It then sends a 15μs RF low signal followed by 8 repetition of the data pwm-modulated each separated by a 10μs low signal.

For the reception it uses interrupts and starts analyzing data when the 15μs sync signal is detected.
The program only support signals shorter than 40bits and it will consider a signal as valid
if it was at least detected two times in the same transmission.

Compile and upload [the Arduino program](arduino-pwm/arduino-pwm.ino) on your board.
Then connect to the Arduino using the usb-to-serial port. You should see 34bits long codes when pressing buttons of your remote control.

On Linux:
```
$ cat < /dev/ttyUSB0
1110000110000100000011110001100100
1110000110000100000011100001100000
1110000110000100000011110001100100
```

If you re-emit one of those code ending with a return line, you should see your switches be turned on and off.

```
$ echo "1110000110000100000011110001100100" > /dev/ttyUSB0
$ echo "1110000110000100000011100001100000" > /dev/ttyUSB0
```

## Configuring udev
Everytime to plug your Arduino into your Raspberry, it might or might not end up under the same device name. You can configure your Linux system to symlink the USB device to a fixed name. Have a look at this [Arduino guide](http://playground.arduino.cc/Linux/All) to find out how to do so.


## Installing the daemon

### Compile and install the software
```bash
$ cd mumbid
$ go get
$ go build
$ sudo cp mumbid /usr/local/bin/mumbid
```

### Configuration
This is an example of configuration that you could write to `/etc/mumbid.json`.
```json
{
  "device": "/dev/arduino",
  "broker": "your-broker:1883",
  "switches":{
    "living_room/_all":{
      "on": "1110000110000100000001000001001100",
      "off": "1110000110000100000010000001110100"
    },
    "living_room/corner":{
      "on": "1110000110000100000011010001101000",
      "off": "1110000110000100000011000001101100"
    },
    "living_room/sofa":{
      "on": "1110000110000100000011110001100100",
      "off": "1110000110000100000011100001100000"
    },
    "living_room/table":{
      "on": "1110000110000100000010110001111000",
      "off": "1110000110000100000010100001111100"
    }
  }
}
```

The `_all` device is a special device. When those `on` or `off` signal are received ,it will  update the internal state of all the  switches (nothing surprising).

### systemd
You can configure the daemon to start automatically on boot with `systemd`.
Create a file at `/etc/systemd/system/mumbid.service`:
```ini
[Unit]
Description=Mumbi daemon
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/mumbid -c /etc/mumbid.json

[Install]
WantedBy=multi-user.target`
```
_Note:_ I run the software as root but it doesn't need root privileges at all. Just make sure that the user you use is in the `dialout` group to have access to the serial port.

Make sure your MQTT broker is started. This was tested with `mosquitto` (v1.3.4) but any compatible broker would work.

Enable and start the Mumbi daemon:
```bash
$ systemctl enable mumbid
$ systemctl start mumbid
```

### Testing the daemon
Listen to one of the switches state change and press buttons on the remote control:
```bash
$  mosquitto_sub -t '/home/living_room/corner'
OFF
ON
```

You should see the state change being published on the broker.

Now publish a message to change the state of one of the switches:
```bash
$ mosquitto_pub -t 'home/living_room/corner/set' -m 'OFF'
```

## Home assistant
You have everything in place to control your switches over [Home Assistant](https://home-assistant.io/).

### Configuration
This is an example of configuration to publish and listen to the MQTT broker.
```yaml
mqtt:
  broker: 127.0.0.1

switch:
  - platform: mqtt
    name: "Living room corner"
    state_topic: "home/living_room/corner"
    command_topic: "home/living_room/corner/set"
  - platform: mqtt
    name: "Living room sofa"
    state_topic: "home/living_room/sofa"
    command_topic: "home/living_room/sofa/set"
  - platform: mqtt
    name: "Living room table"
    state_topic: "home/living_room/table"
    command_topic: "home/living_room/table/set"
```

## More about the signal
The m-FS300 switches are controlled using [pwm modulation](https://en.wikipedia.org/wiki/Pulse-width_modulation).
An `on` or `off` command consists of:
* a low sync signal of 15μs
* 8 repetitions of a 34bits pulse signal sent using a cycle of 1200, separated by 10μs low signal

_Example:_

| Channel | Command  | Prefix               | Payload      | Suffix |
| --------| -------- | -------------------- | ------------ | ------ |
| A       | on       | 11100001100001000000 | 111100011001 | 00     |
| A       | off      | 11100001100001000000 | 111000011000 | 00     |
| B       | on       | 11100001100001000000 | 110100011010 | 00     |
| B       | off      | 11100001100001000000 | 110000011011 | 00     |
| C       | on       | 11100001100001000000 | 101100011110 | 00     |
| C       | off      | 11100001100001000000 | 101000011111 | 00     |
| D       | on       | 11100001100001000000 | 011100010001 | 00     |
| D       | off      | 11100001100001000000 | 100001000000 | 00     |
| All     | on       | 11100001100001000000 | 010000010011 | 00     |
| All     | off      | 11100001100001000000 | 100000011101 | 00     |

The algorithm to convert a channel and state to the payload is unknown to me.

You can analyze the signal using a DVB-T RTL2832u key, [Gqrx](http://gqrx.dk/) (or [SDRSharp](http://airspy.com/))
and [Audacity](http://www.audacityteam.org/). There is a good article from Paul King,   ["mimicking-rf-remote-light-signals-with-arduino"](http://nrocy.com/2014/08/02/mimicking-rf-remote-light-signals-with-arduino/),
that explains more in details how to analyze pwm signals.
