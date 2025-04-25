# Ultrasonic Radar Project

## Overview
This project implements a simple ultrasonic radar system using Arduino and Processing. The system uses a servo motor to sweep an ultrasonic sensor across a 150-degree arc, measuring distances to objects in its path. The data is visualized in real-time through a Processing application that displays a radar-like interface.

## Hardware Requirements
- Arduino board (Uno, Nano, or similar)
- Servo motor
- HC-SR04 ultrasonic distance sensor (or compatible)
- Jumper wires
- Breadboard
- USB cable for Arduino

## Pin Configuration
- Servo signal pin: D9
- Ultrasonic trigger pin: D10
- Ultrasonic echo pin: D11

## Software Requirements
- [Arduino IDE](https://www.arduino.cc/en/software)
- [Processing](https://processing.org/download)

## Installation

### Arduino Setup
1. Connect the hardware according to the pin configuration above
2. Open the Arduino IDE
3. Load the `radar-v1.ino` sketch
4. Upload the sketch to your Arduino

### Processing Setup
1. Open Processing
2. Load the `radar_visualization.pde` sketch
3. Run the sketch

### Permissions Setup (Linux)
If you encounter permission issues when accessing the serial port on Linux:

#### Ubuntu/Debian
```bash
sudo usermod -a -G dialout $USER
sudo chmod 666 /dev/ttyUSB0
```

#### Arch Linux
```bash
sudo usermod -a -G uucp,lock $USER
sudo chmod 666 /dev/ttyUSB0
```

Log out and log back in for group changes to take effect.

## How It Works

### Arduino Code
The Arduino sketch controls the servo motor to sweep from 15° to 165° and back. At each position, it triggers the ultrasonic sensor to measure the distance to any object in front of it. The angle and distance data are sent to the serial port in the format `angle,distance.`

### Processing Visualization
The Processing application reads the serial data from Arduino and creates a visual radar display showing:
- A sweeping radar line that matches the servo's movement
- Points representing detected objects
- Range rings showing distance
- Angle markers

Objects detected by the radar remain visible on the screen with a fading effect, creating a persistent map of the surroundings.

## Features
- 150° scanning range
- Real-time distance measurement
- Visual radar display with sweeping line animation
- Object persistence with fading effect for tracking
- Range indicators in meters
- Angle indicators

## Customization
You can modify various parameters in both the Arduino and Processing code:
- Servo sweep range and speed
- Ultrasonic sensor timeout
- Visual elements like colors, sizes, and fade duration
- Range rings and their labeling

## Troubleshooting

### Serial Connection Issues
- Make sure the correct serial port is selected
- Check that the baud rate (9600) matches in both Arduino and Processing code
- For Linux users, ensure proper permissions as described in the installation section

### Hardware Issues
- Check all connections according to the pin configuration
- Ensure the servo is receiving adequate power
- Verify the ultrasonic sensor is working independently

## Acknowledgments
- Inspiration from various radar projects in the Arduino community
- Thanks to the Processing Foundation for their excellent visualization tools
