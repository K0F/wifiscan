#!/bin/bash
watch -n 1 'sudo iwlist wlan0 scanning > ./data/scan.txt'
