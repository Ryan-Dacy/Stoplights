# 🚦 Assembly Stoplights – Embedded Controllers (Spring 2024)

> 📌 Made this repo after graduation to save one of my most important projects from college.

## Overview

This project is a traffic light control system written entirely in **ARM Assembly** for an **STM32 microcontroller**. It was built on a breadboard during my Spring 2024 Embedded Controllers class. The system controls two stoplights and a crosswalk using **timer interrupts**, a **state machine**, and direct **GPIO control**.

## Features

- Controls red, yellow, and green lights for two stoplights
- Crosswalk light with simple pedestrian counter
- Uses Timer 2 for delay timing (no delay loops)
- Fully bare-metal assembly — no C or libraries used
- Startup code and vector table included

## Hardware

- STM32F103 microcontroller ("Blue Pill")
- Breadboard with:
  - LEDs and resistors for Stoplight 1 (Port A)
  - Stoplight 2 (Port B)
  - Crosswalk light (Port A)
  - Debug/status LED (Port C)
- Powered with **3.3V from the STM32 board**

## Files

- `main.s`: All assembly code (startup, delay, GPIO, timers, logic)
- `README.md`: This file

## What I Learned

- How to program in ARM Assembly
- Using timers and interrupts for real-time control
- Configuring GPIO and system clocks manually
- Writing startup code and working with vector tables
