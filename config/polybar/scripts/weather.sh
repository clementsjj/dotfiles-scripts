#!/bin/sh

curl "https://api.open-meteo.com/v1/forecast?latitude=38.89&longitude=-77.01&current_weather=true&temperature_unit=fahrenheit" | jq .current_weather.temperature