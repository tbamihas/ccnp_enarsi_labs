*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_multicast.yaml
#
#
#     Keywords in this file
#
# baseline multicast validate correct pim neighbors are up as per defined baseline
# baseline multicast validate minimum pim neighbor scale as per defined baseline
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  PIM neighbor checks #######################

baseline multicast validate correct pim neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_PIM_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_PIM_NEIGHBORS:
    ...                ROUTER_A:
    ...                  global:
    ...                    - IP_ADDRESS
    ...                    - IP_ADDRESS
    ...                  VRF1:
    ...                    - IP_ADDRESS
    ...                    - IP_ADDRESS
    ...
    ...              baseline multicast validate correct pim neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}
    baseline set test title  Validate correct pim neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_PIM_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for PIM neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline multicast iosxr validate correct pim neighbors are up as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline multicast iosxe validate correct pim neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] PIM neighbors check: ${device} : Skip check, PIM neighbors checks are currently not available on IOSXE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline multicast nxos validate correct pim neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] PIM neighbors check: ${device} : Skip check, PIM neighbors checks are currently not available on NXOS devices
      END
    END

baseline multicast iosxr validate correct pim neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline multicast validate correct pim neighbors are up as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_PIM_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] PIM neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_PIM_NEIGHBORS['${device}'].keys()}
        IF  "${vrf}" == "global"
          ${command}=  Set Variable  show pim neighbor | exclude "\\\\*"
          ${output}=  run "${command}"
        ELSE
          ${command}=  Set Variable  show pim vrf ${vrf} neighbor | exclude "\\\\*"
          ${output}=  run "${command}"
        END
        ${expected_neighbors}=  Set Variable  ${BASELINE_PIM_NEIGHBORS['${device}']['${vrf}']}
        ${actual_neighbors}=  extract patterns "\\d+\\.\\d+\\.\\d+\\.\\d+"
        FOR  ${expected_neighbor}  IN  @{expected_neighbors}
          ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
          IF  ${status}
            baseline set test pass  [PASS] PIM neighbors check: ${device} : Expected PIM neighbor is: ${expected_neighbor} : PIM neighbor is up.
          ELSE
            baseline set test fail  [FAIL] PIM neighbors check: ${device} : Expected PIM neighbor is: ${expected_neighbor} : PIM neighbor is down.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_PIM_NEIGHBORS['${device}'].keys()}
          baseline set test comment  [SKIP] PIM neighbors check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          ${command}=  Set Variable  show pim neighbor | exclude "\\\\*"
          ${output}=  run "${command}"
        ELSE
          ${command}=  Set Variable  show pim vrf ${vrf} neighbor | exclude "\\\\*"
          ${output}=  run "${command}"
        END
        ${expected_neighbors}=  Set Variable  ${BASELINE_PIM_NEIGHBORS['${device}']['${vrf}']}
        ${actual_neighbors}=  extract patterns "\\d+\\.\\d+\\.\\d+\\.\\d+"
        FOR  ${expected_neighbor}  IN  @{expected_neighbors}
          ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_neighbors}  ${expected_neighbor}
          IF  ${status}
            baseline set test pass  [PASS] PIM neighbors check: ${device} : Expected PIM neighbor is: ${expected_neighbor} : PIM neighbor is up.
          ELSE
            baseline set test fail  [FAIL] PIM neighbors check: ${device} : Expected PIM neighbor is: ${expected_neighbor} : PIM neighbor is down.
          END
        END
      END
    END


######################  PIM Neighbor scale checks #######################



baseline multicast validate minimum pim neighbor scale as per defined baseline
    [Documentation]  Create the variable BASELINE_PIM_NEIGHBOR_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...             BASELINE_PIM_NEIGHBOR_SCALE:
    ...               ROUTER_A:
    ...                 VRF_A: 100
    ...                 global: 100
    ...
    ...              baseline multicast validate minimum pim neighbor scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}
    baseline set test title  Validate minimum pim neighbor scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_PIM_NEIGHBOR_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for PIM NEIGHBOR scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline multicast iosxr validate minimum pim neighbor scale as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline multicast iosxe validate minimum pim neighbor scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] PIM Neighbor scale check: ${device} : Skip check, PIM Neighbor scale checks are currently not available on IOSXE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline multicast nxos validate minimum pim neighbor scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] PIM Neighbor scale check: ${device} : Skip check, PIM Neighbor scale checks are currently not available on NXOS devices
      END
    END

baseline multicast iosxr validate minimum pim neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline multicast validate minimum pim neighbor scale as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_PIM_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] PIM Neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_PIM_NEIGHBOR_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          ${output}=  run "show pim neighbor count"
        ELSE
          ${output}=  run "show pim vrf ${vrf} neighbor count"
        END
        ${expected_value}=  Set Variable  ${BASELINE_PIM_NEIGHBOR_SCALE['${device}']['${vrf}']}
        ${actual_value}=  extract pattern "Total Nbrs +(\\d+)"
        IF  ${actual_value} >= ${expected_value}
          baseline set test pass  [PASS] PIM Neighbor scale check: ${device} vrf: ${vrf} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
        ELSE
          baseline set test fail  [FAIL] PIM Neighbor scale check: ${device} vrf: ${vrf} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{vrf_list}
        IF  "${vrf}" not in @{BASELINE_PIM_NEIGHBOR_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] PIM Neighbor scale check: ${device} vrf: ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          ${output}=  run "show pim neighbor count"
        ELSE
          ${output}=  run "show pim vrf ${vrf} neighbor count"
        END
        ${expected_value}=  Set Variable  ${BASELINE_PIM_NEIGHBOR_SCALE['${device}']['${vrf}']}
        ${actual_value}=  extract pattern "Total Nbrs +(\\d+)"
        IF  ${actual_value} >= ${expected_value}
          baseline set test pass  [PASS] PIM Neighbor scale check: ${device} vrf: ${vrf} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
        ELSE
          baseline set test fail  [FAIL] PIM Neighbor scale check: ${device} vrf: ${vrf} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
        END
      END
    END
