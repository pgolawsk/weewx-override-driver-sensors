#################
#* Override broken sensors from the driver
#################
# install.py
# Pawelo, 20251223, created

from weecfg.extension import ExtensionInstaller

def loader():
    return OverrideDriverSensorsInstaller()

class OverrideDriverSensorsInstaller(ExtensionInstaller):
    def __init__(self):
        super().__init__(
            version="0.1.0",
            name="override-driver-sensors",
            description="Override driver-provided sensors with values from MQTT or other sources",
            author="Pawel Golawski",
            author_email="pawel.golawski@2com.com",
            files=[
                ('bin/user', ['bin/user/OverrideDriverSensors.py']),
            ],
            config={
                'OverrideDriverSensors': {
                    'inTemp': 'inTempEntrance, inTempSalon',
                    'inHumidity': 'inHumidEntrance, inHumidSalon',
                }
            }
        )

