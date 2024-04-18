# https://github.com/yaml/pyyaml/issues/127

from robot.api.deco import keyword
from CXTA.robot.Shared import Shared
from CXTA.core.logger import logger
from CXTA.robot.CxtaException import CxtaException

import yaml
import json

class YamlDumpWithLineBreaks(Shared):
    @keyword('yaml dump with line breaks')
    def yaml_dump_with_line_breaks(self, data):
        data = json.dumps(data)
        data = json.loads(data)
        data = yaml.dump(data, Dumper=MyDumper, sort_keys=False)
        return data

class MyDumper(yaml.SafeDumper):
    # HACK: insert blank lines between top-level objects
    # inspired by https://stackoverflow.com/a/44284819/3786245
    def write_line_break(self, data=None):
        super().write_line_break(data)

        if len(self.indents) == 1:
            super().write_line_break()
