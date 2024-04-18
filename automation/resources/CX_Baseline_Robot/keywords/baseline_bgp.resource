*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_bgp.yaml
#
#
#     Keywords in this file
#
# baseline bgp validate correct bgp neighbors are up as per defined baseline
# baseline bgp validate minimum bgp route scale as per defined baseline
#
################################################################################


*** Keywords ***
######################  BGP neighbor check  #######################

baseline bgp validate correct bgp neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_BGP_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_BGP_NEIGHBORS:
    ...                ROUTER_A:
    ...                  global:
    ...                    vpnv4:
    ...                      unicast:
    ...                        - 10.249.0.18
    ...                    vpnv6:
    ...                      unicast:
    ...                        - 10.249.0.18
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...               - ``VRF_LIST`` List of VRFs to run the checks on.
    ...
    ...              *Examples:*
    ...              | baseline bgp validate correct bgp neighbors are up as per defined baseline | NODES_TO_CHECK=${device_list} | VRF_LIST=${vrf_list} |
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}
    baseline set test title  Validate correct bgp neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_BGP_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for BGP neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline bgp iosxr validate correct bgp neighbors are up as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline bgp iosxe validate correct bgp neighbors are up as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline bgp nxos validate correct bgp neighbors are up as per defined baseline on nxos  ${device}
        baseline set test comment  [SKIP] BGP neighbors check: ${device} : Skip check, BGP neighbors checks are currently not available on NXOS devices
      END
    END

baseline bgp iosxr validate correct bgp neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline bgp validate correct bgp neighbors are up as per defined baseline'.
    ...              Checks the expected neighbors from baseline variable 'BASELINE_BGP_NEIGHBORS' are up in the command 'show bgp ___ summary'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_BGP_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] BGP neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      ${vrf_list}=  Get Dictionary Keys  ${BASELINE_BGP_NEIGHBORS['${device}']}
      ${vrf_num}=  Get Length  ${vrf_list}
      # If there are many vrf's, different logic used to reduce execution time
      IF  ${vrf_num} > 10
        ${global_found}=  Run Keyword And Return Status  List Should Contain Value  ${vrf_list}  global
        IF  ${global_found}
          FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['global'].keys()}
            FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['global']['${afi}'].keys()}
              ${output}=  run parsed "show bgp ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
              baseline bgp iosxr check neighbor status  output=${output}  device=${device}  vrf=global  afi=${afi}  safi=${safi}
            END
          END
        END
        ${vrf_dictionary}=  Copy Dictionary  ${BASELINE_BGP_NEIGHBORS['${device}']}
        Run Keyword And Ignore Error  Remove From Dictionary  ${vrf_dictionary}  global
        ${afi_list}=  YamlPath Parse  query=.*.  data=${vrf_dictionary}
        ${afi_list}=  Evaluate  json.dumps($afi_list)
        ${afi_list}=  Evaluate  json.loads($afi_list)
        ${afi_list}=  Get Dictionary Keys  ${afi_list[0]}
        ${afi_list}=  Remove Duplicates  ${afi_list}
        FOR  ${afi}  IN  @{afi_list}
          ${safi_list}=  YamlPath Parse  query=.*.${afi}.  data=${vrf_dictionary}
          ${safi_list}=  Evaluate  json.dumps($safi_list)
          ${safi_list}=  Evaluate  json.loads($safi_list)
          ${safi_list}=  Get Dictionary Keys  ${safi_list[0]}
          ${safi_list}=  Remove Duplicates  ${safi_list}
          FOR  ${safi}  IN  @{safi_list}
            ${output}=  run parsed "show bgp vrf all ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_VRF_SUMMARY_TEMPLATE}"
            ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
            FOR  ${vrf}  IN  @{vrf_list}
              Continue For Loop If  "${vrf}" == "global"
              IF  "${afi}" in "${BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}"
                IF  "${safi}" in "${BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}"
                  baseline bgp iosxr check neighbor status in vrf  output=${output}  device=${device}  vrf=${vrf}  afi=${afi}  safi=${safi}
                END
              END
            END
          END
        END
      ELSE
        FOR  ${vrf}  IN  @{BASELINE_BGP_NEIGHBORS['${device}'].keys()}
          FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}
            FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}
              IF  "${vrf}" == "global"
                ${output}=  run parsed "show bgp ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ELSE
                ${output}=  run parsed "show bgp vrf ${vrf} ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              END
              ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
              baseline bgp iosxr check neighbor status  output=${output}  device=${device}  vrf=${vrf}  afi=${afi}  safi=${safi}
            END
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      ${vrf_num}=  Get Length  ${VRF_LIST}
      # If there are many vrf's, different logic used to reduce execution time
      IF  ${vrf_num} > 10
        ${global_found}=  Run Keyword And Return Status  List Should Contain Value  ${VRF_LIST}  global
        IF  ${global_found}
          FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['global'].keys()}
            FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['global']['${afi}'].keys()}
              ${output}=  run parsed "show bgp ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
              baseline bgp iosxr check neighbor status  output=${output}  device=${device}  vrf=global  afi=${afi}  safi=${safi}
            END
          END
        END
        ${vrf_dictionary}=  Copy Dictionary  ${BASELINE_BGP_NEIGHBORS['${device}']}
        Run Keyword And Ignore Error  Remove From Dictionary  ${vrf_dictionary}  global
        Run Keyword And Ignore Error  Keep In Dictionary  ${vrf_dictionary}  @{VRF_LIST}
        ${afi_list}=  YamlPath Parse  query=.*.  data=${vrf_dictionary}
        ${afi_list}=  Evaluate  json.dumps($afi_list)
        ${afi_list}=  Evaluate  json.loads($afi_list)
        ${afi_list}=  Get Dictionary Keys  ${afi_list[0]}
        ${afi_list}=  Remove Duplicates  ${afi_list}
        FOR  ${afi}  IN  @{afi_list}
          ${safi_list}=  YamlPath Parse  query=.*.${afi}.  data=${vrf_dictionary}
          ${safi_list}=  Evaluate  json.dumps($safi_list)
          ${safi_list}=  Evaluate  json.loads($safi_list)
          ${safi_list}=  Get Dictionary Keys  ${safi_list[0]}
          ${safi_list}=  Remove Duplicates  ${safi_list}
          FOR  ${safi}  IN  @{safi_list}
            ${output}=  run parsed "show bgp vrf all ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_VRF_SUMMARY_TEMPLATE}"
            ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
            FOR  ${vrf}  IN  @{vrf_list}
              Continue For Loop If  "${vrf}" == "global"
              IF  "${afi}" in "${BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}"
                IF  "${safi}" in "${BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}"
                  baseline bgp iosxr check neighbor status in vrf  output=${output}  device=${device}  vrf=${vrf}  afi=${afi}  safi=${safi}
                END
              END
            END
          END
        END
      ELSE
        FOR  ${vrf}  IN  @{VRF_LIST}
          IF  "${vrf}" not in @{BASELINE_BGP_NEIGHBORS['${device}'].keys()}
            baseline set test comment  [SKIP] BGP neighbors check: ${device} : vrf ${vrf} : Skip check, no baseline defined
            Continue For Loop
          END
          FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}
            FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}
              IF  "${vrf}" == "global"
                ${output}=  run parsed "show bgp ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ELSE
                ${output}=  run parsed "show bgp vrf ${vrf} ${afi} ${safi.replace('vpls-vpws', 'vpls')} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              END
              ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
              baseline bgp iosxr check neighbor status  output=${output}  device=${device}  vrf=${vrf}  afi=${afi}  safi=${safi}
            END
          END
        END
      END
    END

baseline bgp iosxr check neighbor status
    [Documentation]  Child keyword for 'baseline bgp iosxr validate correct bgp neighbors are up as per defined baseline'.
    [Arguments]  ${output}  ${device}  ${vrf}  ${afi}  ${safi}
    ${actual_neighbors}=  YamlPath Parse New  query=.neighbor  data=${output}
    FOR  ${expected_neighbor}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}']['${safi}']}
      ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
      IF  ${status} == ${FALSE}
        baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor not found.
        Continue For Loop
      ELSE
        #${actual_state}=  YamlPath Parse  query=[neighbor=${expected_neighbor}].state_prefix  data=${output}
        ${actual_state}=  get parsed "state_prefix" where "neighbor" is "${expected_neighbor}"
        ${status}=  Run Keyword And Return Status  Should Be True  ${actual_state} >= 0
        IF  ${status}
          baseline set test pass  [PASS] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is up, prefixes learnt: ${actual_state}.
        ELSE
          baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is down, actual state: ${actual_state}.
        END
      END
    END

baseline bgp iosxr check neighbor status in vrf
    [Documentation]  Child keyword for 'baseline bgp iosxr validate correct bgp neighbors are up as per defined baseline'.
    [Arguments]  ${output}  ${device}  ${vrf}  ${afi}  ${safi}
    ${actual_neighbors}=  YamlPath Parse New  query=.[vrf='${vrf}'].neighbor  data=${output}
    FOR  ${expected_neighbor}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}']['${safi}']}
      ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
      IF  ${status} == ${FALSE}
        baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor not found.
        Continue For Loop
      ELSE
        #${actual_state}=  YamlPath Parse  query=[neighbor=${expected_neighbor}].state_prefix  data=${output}
        ${actual_state}=  get parsed "state_prefix" where "neighbor" is "${expected_neighbor}" and "vrf" is "${vrf}"
        ${status}=  Run Keyword And Return Status  Should Be True  ${actual_state} >= 0
        IF  ${status}
          baseline set test pass  [PASS] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is up, prefixes learnt: ${actual_state}.
        ELSE
          baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is down, actual state: ${actual_state}.
        END
      END
    END



baseline bgp iosxe validate correct bgp neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline bgp validate correct bgp neighbors are up as per defined baseline'.
    ...              Checks the expected neighbors from baseline variable 'BASELINE_BGP_NEIGHBORS' are up in the command 'show bgp ___ summary'
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_BGP_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] BGP neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_BGP_NEIGHBORS['${device}'].keys()}
        FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}
            IF  "${vrf}" == "global"
              IF  "vpn" in "${afi}" or "rtfilter" in "${afi}" or "mvpn" in "${safi}"
                ${output}=  run parsed "show bgp ${afi} ${safi} all summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ELSE
                ${output}=  run parsed "show bgp ${afi} ${safi} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              END
            ELSE
              ${output}=  run parsed "show bgp ${afi.replace('ip', 'vpn')} ${safi} vrf ${vrf} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
            END
            ${actual_neighbors}=  YamlPath Parse  query=.neighbor  data=${output}
            FOR  ${expected_neighbor}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}']['${safi}']}
              ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
              IF  ${status} == ${FALSE}
                baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor not found.
                Continue For Loop
              ELSE
                #${actual_state}=  YamlPath Parse  query=.**.[.neighbor=${expected_neighbor}].state_prefix  data=${output}
                ${actual_state}=  get parsed "state_prefix" where "neighbor" is "${expected_neighbor}"
                ${status}=  Run Keyword And Return Status  Should Be True  ${actual_state} >= 0
                IF  ${status}
                  baseline set test pass  [PASS] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is up, prefixes learnt: ${actual_state}.
                ELSE
                  baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is down, actual state: ${actual_state}.
                END
              END
            END
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_BGP_NEIGHBORS['${device}'].keys()}
          baseline set test comment  [SKIP] BGP neighbors check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        FOR  ${afi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}'].keys()}
            IF  "${vrf}" == "global"
              IF  "vpn" in "${afi}"
                ${output}=  run parsed "show bgp ${afi} ${safi} all summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              ELSE
                ${output}=  run parsed "show bgp ${afi} ${safi} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
              END
            ELSE
              ${output}=  run parsed "show bgp ${afi.replace('ip', 'vpn')} ${safi} vrf ${vrf} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
            END
            ${actual_neighbors}=  YamlPath Parse  query=.neighbor  data=${output}
            FOR  ${expected_neighbor}  IN  @{BASELINE_BGP_NEIGHBORS['${device}']['${vrf}']['${afi}']['${safi}']}
              ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
              IF  ${status} == ${FALSE}
                baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor not found.
                Continue For Loop
              ELSE
                #${actual_state}=  YamlPath Parse  query=.**.[.neighbor=${expected_neighbor}].state_prefix  data=${output}
                ${actual_state}=  get parsed "state_prefix" where "neighbor" is "${expected_neighbor}"
                ${status}=  Run Keyword And Return Status  Should Be True  ${actual_state} >= 0
                IF  ${status}
                  baseline set test pass  [PASS] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is up, prefixes learnt: ${actual_state}.
                ELSE
                  baseline set test fail  [FAIL] BGP neighbors check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected neighbor ${expected_neighbor} : Neighbor is down, actual state: ${actual_state}.
                END
              END
            END
          END
        END
      END
    END









######################  BGP route scale check  #######################


baseline bgp validate minimum bgp route scale as per defined baseline
    [Documentation]  Create the variable BASELINE_BGP_ROUTE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_BGP_ROUTE_SCALE:
    ...                ROUTER_A:
    ...                  global:
    ...                    vpnv4:
    ...                      unicast: 500
    ...                    vpnv6:
    ...                      unicast: 100
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...               - ``VRF_LIST`` List of VRFs to run the checks on.
    ...
    ...              *Examples:*
    ...              | baseline bgp validate minimum bgp route scale as per defined baseline | NODES_TO_CHECK=${device_list} | VRF_LIST=${vrf_list} |
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}
    baseline set test title  Validate minimum bgp route scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_BGP_ROUTE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for BGP route scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline bgp iosxr validate minimum bgp route scale as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline bgp iosxe validate minimum bgp route scale as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline bgp nxos validate minimum bgp route scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] BGP route scale check: ${device} : Skip check, BGP route scale checks are currently not available on NXOS devices
      END
    END

baseline bgp iosxr validate minimum bgp route scale as per defined baseline
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_BGP_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] BGP route scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          ${output}=  run "show bgp vrf default scale"
        ELSE
          ${output}=  run "show bgp vrf ${vrf} scale"
        END
        FOR  ${afi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}'].keys()}
            ${actual_value}=  Get Regexp Matches  ${output.lower()}  ${afi.lower()} ${safi.lower()} +(\\d+)  1
            ${actual_value_found}=  Run Keyword And Return Status  Set Variable  ${actual_value}[0]
            ${expected_value}=  Set Variable  ${BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}']['${safi}']}
            IF  ${actual_value_found}
              IF  ${actual_value}[0] >= ${expected_value}
                baseline set test pass  [PASS] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0].
              ELSE
                baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0].
              END
            ELSE
              baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: Value not found in output.
            END
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_BGP_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] BGP route scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          ${output}=  run "show bgp vrf default scale"
        ELSE
          ${output}=  run "show bgp vrf ${vrf} scale"
        END
        FOR  ${afi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}'].keys()}
            ${actual_value}=  Get Regexp Matches  ${output.lower()}  ${afi.lower()} ${safi.lower()} +(\\d+)  1
            ${actual_value_found}=  Run Keyword And Return Status  Set Variable  ${actual_value}[0]
            ${expected_value}=  Set Variable  ${BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}']['${safi}']}
            IF  ${actual_value_found}
              IF  ${actual_value}[0] >= ${expected_value}
                baseline set test pass  [PASS] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0].
              ELSE
                baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0].
              END
            ELSE
              baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: Value not found in output.
            END
          END
        END
      END
    END



baseline bgp iosxe validate minimum bgp route scale as per defined baseline
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_BGP_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] BGP route scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}'].keys()}
        FOR  ${afi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}'].keys()}
            IF  "${vrf}" == "global"
              ${output}=  run "show bgp ${afi} ${safi} all summary"
            ELSE
              ${output}=  run "show bgp ${afi.replace('ip', 'vpn')} ${safi} vrf ${vrf} summary"
            END
            ${actual_value}=  extract pattern "(\\d+) network entries"
            ${expected_value}=  Set Variable  ${BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}']['${safi}']}
            IF  ${actual_value} >= ${expected_value}
              baseline set test pass  [PASS] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}.
            ELSE
              baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}.
            END
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_BGP_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] BGP route scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        FOR  ${afi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          FOR  ${safi}  IN  @{BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}'].keys()}
            IF  "${vrf}" == "global"
              ${output}=  run "show bgp ${afi} ${safi} all summary"
            ELSE
              ${output}=  run "show bgp ${afi.replace('ip', 'vpn')} ${safi} vrf ${vrf} summary"
            END
            ${actual_value}=  extract pattern "(\\d+) network entries"
            ${expected_value}=  Set Variable  ${BASELINE_BGP_ROUTE_SCALE['${device}']['${vrf}']['${afi}']['${safi}']}
            IF  ${actual_value} >= ${expected_value}
              baseline set test pass  [PASS] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}.
            ELSE
              baseline set test fail  [FAIL] BGP route scale check: ${device} : vrf ${vrf} : afi ${afi} : safi ${safi} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}.
            END
          END
        END
      END
    END
