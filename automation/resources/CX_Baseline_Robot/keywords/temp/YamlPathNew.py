# Copyright (c)  Cisco Systems, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential

from robot.api.deco import keyword
from yamlpath.common import Parsers
from yamlpath import YAMLPath
from yamlpath.wrappers import NodeCoords
from yamlpath.wrappers import ConsolePrinter
from yamlpath import Processor


class YamlPathNew():

    """
    Robot keyword for yamlpath library.
    For more info see:
    https://github.com/wwkimball/yamlpath
    **Usage**
    NOTE: Please do not import this library directly, but through the following two keywords
    in the test suite's ``*** Settings ***`` section which imports this library as well as all other
    libraries and resource files:
    ::
        *** Settings ***
        Library      CXTA
        Resource     cxta.robot
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'
    ROBOT_LIBRARY_DOC_FORMAT = 'reST'

    @keyword('YamlPath Parse New')
    def parseDataThroughYamlPathNew(self, **kwargs):
        """
        Same as the keyword ``YamlPath Parse`` from CXTA library, but this keyword removes the line ``yaml_data = yaml.load(self.yaml_str)``

        The reason is to speed up the keyword execution time. You will need to handle the yaml.load action yourself in your jobfile.
        Only use this keyword if you know what you are doing. 
        """
        parser = CustomYamlParseNew(kwargs['query'], kwargs['data'])
        return parser.parse()


class CustomLog():
    def __init__(self):
        self.debug = False
        self.verbose = False
        self.quiet = False


class CustomYamlParseNew():
    def __init__(self, query, yaml_str, pathsep='.'):
        self.query = query
        self.pathsep = pathsep
        self.yaml_str = yaml_str

    def parse(self):
        yaml_path = YAMLPath(self.query, pathsep=self.pathsep)
        yaml = Parsers.get_yaml_editor()
        log = ConsolePrinter(args=CustomLog())

        #yaml_data = yaml.load(self.yaml_str)
        yaml_data = self.yaml_str

        discovered_nodes = []

        processor = Processor(log, yaml_data)
        for node in processor.get_nodes(yaml_path, mustexist=True):
            log.debug('Got node from {}:'.format(yaml_path), data=node,
                      prefix='yaml_get::main:  ')
            discovered_nodes.append(NodeCoords.unwrap_node_coords(node))

        return discovered_nodes
