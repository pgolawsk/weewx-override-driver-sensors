#################
#* Override broken sensors from the driver
#################
# bin/user/OverrideDriverSensors.py
# Pawelo, 20251221, created
# Pawelo, 20251221, added reading rules from config file OverrideDriverSensors section
# Pawelo, 20251221, added logging of applied overrides
# Pawelo, 20251221, renamed class to OverrideDS
# Pawelo, 20251222, add check if value is number or float before applying override
# Pawelo, 20251224, improved is_valid_number to handle numeric strings and numpy types

import weewx
import logging
from weewx.engine import StdService
import numbers

log = logging.getLogger(__name__)

# helpers
def is_valid_number(v):
    # reject booleans explicitly
    if isinstance(v, bool):
        return False
    # accept Python real numbers and other numbers.Real (e.g., numpy scalars)
    if isinstance(v, numbers.Real):
        return True
    # fallback: try coercing to float (covers numeric strings or numpy types)
    try:
        float(v)
        return True
    except Exception:
        return False

# main service class
class OverrideDS(StdService):

    def __init__(self, engine, config_dict):
        super().__init__(engine, config_dict)

        log.info("initializing...")

        self.cfg = config_dict.get('OverrideDriverSensors', {})
        self.rules = {}

        for target, sources in self.cfg.items():

            # ConfigObj returns lists for multiple entries, or strings for single entries
            if isinstance(sources, (list, tuple)):
                src_list = [s.strip() for s in sources]
            else:
                src_list = [s.strip() for s in str(sources).split(',')]

            self.rules[target] = src_list

            log.info(
                "[config] rule %s <- %s",
                target, src_list
            )

        self.bind(weewx.NEW_LOOP_PACKET, self.handle_loop)
        self.bind(weewx.NEW_ARCHIVE_RECORD, self.handle_archive)

        log.info("bound to LOOP and ARCHIVE")

    def handle_loop(self, event):
        self.apply_rules(event.packet, source="LOOP")

    def handle_archive(self, event):
        self.apply_rules(event.record, source="ARCHIVE")

    def apply_rules(self, data, source):
        for target, sources in self.rules.items():
            for src in sources:
                value = data.get(src)
                if is_valid_number(value):
                    old = data.get(target)
                    data[target] = value

                    if old != value:
                        log.debug(
                            "[%s]: %s <- %s (%s → %s)",
                            source,
                            target,
                            src,
                            old,
                            value
                        )
                    break
