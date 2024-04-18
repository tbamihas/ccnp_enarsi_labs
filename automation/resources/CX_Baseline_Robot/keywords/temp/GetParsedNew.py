# Copyright (c)  Cisco Systems, Inc. - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential

import operator
import os
import re
import json
import subprocess
import yaml
import pyshark

from typing import Union
from pprint import pformat
from jsonpath_rw import parse
from CXTA.core.decorator import deprecated
from jsonpath_rw_ext import parse as json_path_parse
from genie.parsergen import core as pg_core
from genie.parsergen import oper_fill_tabular
from functools import reduce
from robot.libraries.BuiltIn import BuiltIn
from CXTA.core.util import write_to_csv
from CXTA.robot.Shared import Shared
from robot.api.deco import keyword
from CXTA.core.logger import logger
from CXTA.robot.CxtaException import CxtaException
from CXTA.robot.Compare import read_and_decode_file
from CXTA.robot.parsers.parser import textfsm_parser
from CXTA.robot import parsers  # noqa


class GetParsedNew(Shared):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LIBRARY_DOC_FORMAT = 'reST'

    @keyword(r'get parsed "${desired_attribute:[^"]+}" where "${attribute:[^"]+}" is "${value:[^"]+}" and "${attribute2:[^"]+}" is "${value2:[^"]+}"')
    def get_parsed_attribute_where_attribute_is_value_and_attribute2_is_value_2(self, desired_attribute, attribute, value, attribute2, value2):
        """
        Same as the keyword ``get parsed`` from CXTA library, but this keyword allows you to check for two attribute values
        """

        return self.get_parsed_new(
            attribute=desired_attribute,
            target_value=value,
            target_key=attribute,
            target_value2=value2,
            target_key2=attribute2
        )

    @keyword('get parsed new')
    def get_parsed_new(self, attribute, target_key=None, target_value=None, target_key2=None, target_value2=None, return_all=False):
        parsed = self.shared.last_parsed_output

        # It could be the case that allow_empty_output = True
        # to which we defend against with this since users
        # should not be able to search over an empty textfsm result of []
        # which is possible in some scenarios
        if not parsed:
            raise CxtaException(
                'No parsed data stored in memory. Please execute a run parsed '
                'keyword call that successfully stores parsed data.'
            )

        arguments = {
            'attribute': attribute,
            'target_key': target_key,
            'target_value': target_value,
            'target_key2': target_key2,
            'target_value2': target_value2
        }

        # Validate the user input and make sure that the types are correct
        for k, v in arguments.items():
            if v:
                if not isinstance(v, str):
                    raise CxtaException(f'Expected attribute argument "{k}" to be a string; got {type(v)}')

        if isinstance(parsed, dict):
            return self._get_parsed_json(parsed, attribute, target_key=target_key, target_value=target_value, target_key2=target_key2, target_value2=target_value2, return_all=return_all)
        else:
            return self._get_parsed_textfsm(parsed, attribute, target_key=target_key, target_value=target_value, target_key2=target_key2, target_value2=target_value2, return_all=return_all)

    def _get_parsed_json(self, parsed, attribute, target_key=None, target_value=None, target_key2=None, target_value2=None, return_all=False):
        results = [i for i in self._get_items(
            attribute=attribute,
            dict_var=parsed,
            target_key=target_key,
            target_value=target_value,
            target_key2=target_key2,
            target_value2=target_value2
        )]
        logger.debug(f'Results found: {results}')

        if return_all and results:
            # return raw results as a list, no matter how many were found
            return results

        if len(results) == 1:
            results = results[0]

        # below logic due to backward-compatibility reasons
        elif target_key:
            raise CxtaException('Output from device is not normalized, either the key was not found or there '
                                'are duplicate matches')
        elif not results:
            raise CxtaException(f'{attribute} not found in parsed output.')
        return results

    def _get_parsed_textfsm(self, parsed, attribute, target_key=None, target_value=None, target_key2=None, target_value2=None, return_all=False):
        # Checks that attribute is a possible key
        if attribute not in parsed[0]:
            keys = list(parsed[0].keys())
            raise CxtaException(f'{attribute} is not a valid attribute. Options are: {keys}')

        if target_key and target_key2:
            results = []
            for info in parsed:
                if info.get(target_key, '').lower() == target_value.lower() and info.get(target_key2, '').lower() == target_value2.lower() and attribute in info:
                    results.append(info.get(attribute))
        elif target_key:
            results = []
            for info in parsed:
                if info.get(target_key, '').lower() == target_value.lower() and attribute in info:
                    results.append(info.get(attribute))
        else:
            # gets all values of the given attribute and puts them in a list
            results = [i.get(attribute) for i in parsed]

        logger.debug(f'Results found: {results}')

        if return_all and results:
            # return raw results as a list, no matter how many were found
            return results

        # below logic due to backward-compatibility reasons
        if target_key:
            if results:
                # return only first match as string
                results = results[0]
            else:
                raise CxtaException(
                    f'No information found for value "{attribute}" where "{target_key}" is "{target_value}". ')
        else:
            if len(results) == 1:
                results = results[0]
            elif not results:
                raise CxtaException(f'{attribute} not found in parsed output.')
        return results

    def _get_items(self, attribute, dict_var, target_key=None, target_value=None, target_key2=None, target_value2=None):
        # gets all of the values for attribute in the json
        for k, v in dict_var.items():
            if k == attribute and any([
                not target_key,
                not target_value,
                not target_key2,
                not target_value2,
                (target_key in dict_var and dict_var[target_key] == target_value),
                (target_key2 in dict_var and dict_var[target_key2] == target_value2)
            ]):
                yield v
            elif isinstance(v, dict):
                for id_val in self._get_items(attribute, v, target_key=target_key, target_value=target_value, target_key2=target_key2, target_value2=target_value2):
                    yield id_val
            elif isinstance(v, list):
                for item in v:
                    for item_val in self._get_items(attribute, item, target_key=target_key, target_value=target_value, target_key2=target_key2, target_value2=target_value2):
                        yield item_val
