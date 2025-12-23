# WeeWX Override Driver Sensors

This extension allows overriding driver-provided sensor values
(e.g. inTemp, inHumidity) using values from other sources
such as MQTT sensors.

Typical use cases:

- broken indoor sensors in the weather station
- prefer MQTT / Home Assistant sensors
- mix data sources without modifying drivers

Author Pawel Golawski <pawel.golawski@2com.pl>

---

## Inspiration

I was having an old weather station (TE923) which worked with WeeWx great for years,
however some sensors started to fail (hardware) and I cannot find replacements for those.
Then I thought since I have multiple ESPHome devices which publish sensor states via MQTT
it would be good to pull them into WeeWX. So I did it.

The only difficulty was that WeeWx architecture do not allows natively to override "driver"
sensor values. So just to have continuation of my metrics in WeeWx I made this extension which
allows to override those.

---

## Features

- override values in LOOP and ARCHIVE packets
- configurable priority order
- safe handling of invalid values (`None`, strings, `unavailable`)
- clean integration with WeeWX logging
- no driver modifications required

---

## Installation

```bash
weectl extension install https://github.com/pgolawsk/weewx-override-driver-sensors/archive/refs/heads/main.zip
```

or (older version of WeeWx)

```bash
wee_extension --install https://github.com/pgolawsk/weewx-override-driver-sensors/archive/refs/heads/main.zip
```

---

## Configuration

Add or edit the section in weewx.conf:

```ini
[OverrideDriverSensors]
    inTemp = inTempEntrance, inTempSalon
    inHumidity = inHumidEntrance, inHumidSalon
    extraTemp4 = inTempSalon
    extraHumid4 = inHumidSalon
```

Values are applied in order – first valid numeric value wins.

**Engine** configuration - add the service before **StdConvert**:

```ini
[Engine]
    [[Services]]
        process_services = user.OverrideDriverSensors.OverrideDS, weewx.engine.StdConvert, ...
```

Optional - add in **Logging** section:

```ini
[Logging]
    [[loggers]]
        [[[user.OverrideDriverSensors]]]
            level = WARNING
            # level = INFO
```

> INFO - will display this service configuration to logs

---

## Compatibility

- WeeWX 5.x
- Python 3.9+
