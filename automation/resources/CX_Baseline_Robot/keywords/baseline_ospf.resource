*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_ospf.yaml
#
#
#     Keywords in this file
#
# baseline ospf validate correct ospf neighbors are up as per defined baseline
# baseline ospf validate correct ospfv3 neighbors are up as per defined baseline
#
#
################################################################################

*** Variables ***

*** Keywords ***
######################  OSPF  #######################

baseline ospf validate correct ospf neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_OSPF_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_OSPF_NEIGHBORS:
    ...                ROUTER_A:
    ...                  - GigabitEthernet0/0/0/5.700
    ...
    ...              baseline ospf validate correct ospf neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct ospf neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_OSPF_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for OSPF neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ospf iosxr validate correct ospf neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline ospf iosxe validate correct ospf neighbors are up as per defined baseline  ${device}
        #baseline set test comment  [SKIP] OSPF neighbors checks: ${device} : Skip, OSPF neighbors checks are currently not available on IOS XE or IOS or NXOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] OSPF neighbors checks: ${device} : Skip, OSPF neighbors checks are currently not available on NXOS devices
      END
    END

baseline ospf iosxr validate correct ospf neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ospf validate correct ospf neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_OSPF_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] OSPF neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show ospf vrf all neighbor"
    ${expected_neighbors}=  Set Variable  ${BASELINE_OSPF_NEIGHBORS['${device}']}
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      ${status}=  Run Keyword And Return Status  values "${expected_neighbor}" and "FULL" exist on same line
      IF  ${status}
        baseline set test pass  [PASS] OSPF neighbors check: ${device} : Expected OSPF neighbor is: ${expected_neighbor} : OSPF neighbor is up.
      ELSE
        baseline set test fail  [FAIL] OSPF neighbors check: ${device} : Expected OSPF neighbor is: ${expected_neighbor} : OSPF neighbor is down.
      END
    END

baseline ospf iosxe validate correct ospf neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ospf validate correct ospf neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_OSPF_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] OSPF neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END
    ${output}=  run "show ip ospf neighbor"
    ${expected_neighbors}=  Set Variable  ${BASELINE_OSPF_NEIGHBORS['${device}']}
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      ${status}=  Run Keyword And Return Status  values "${expected_neighbor}" and "FULL" exist on same line
      IF  ${status}
        baseline set test pass  [PASS] OSPF neighbors check: ${device} : Expected OSPF neighbor is: ${expected_neighbor} : OSPF neighbor is up.
      ELSE
        baseline set test fail  [FAIL] OSPF neighbors check: ${device} : Expected OSPF neighbor is: ${expected_neighbor} : OSPF neighbor is down.
      END
    END



baseline ospf validate correct ospfv3 neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_OSPFV3_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_OSPFV3_NEIGHBORS:
    ...                ROUTER_A:
    ...                  - GigabitEthernet0/0/0/5.700
    ...
    ...              baseline ospf validate correct ospfv3 neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct ospfv3 neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_OSPFV3_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for OSPFv3 neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ospf iosxr validate correct ospfv3 neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline ospf iosxe validate correct ospfv3 neighbors are up as per defined baseline  ${device}
        #baseline set test comment  [SKIP] OSPFv3 neighbors checks: ${device} : Skip, OSPFv3 neighbors checks are currently not available on IOS XE or IOS or NXOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] OSPFv3 neighbors checks: ${device} : Skip, OSPFv3 neighbors checks are currently not available on NXOS devices
      END
    END

baseline ospf iosxr validate correct ospfv3 neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ospf validate correct ospfv3 neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_OSPFV3_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] OSPFv3 neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show ospfv3 vrf all neighbor"
    ${expected_neighbors}=  Set Variable  ${BASELINE_OSPFV3_NEIGHBORS['${device}']}
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      ${status}=  Run Keyword And Return Status  values "${expected_neighbor}" and "FULL" exist on same line
      IF  ${status}
        baseline set test pass  [PASS] OSPFv3 neighbors check: ${device} : Expected OSPFv3 neighbor is: ${expected_neighbor} : OSPFv3 neighbor is up.
      ELSE
        baseline set test fail  [FAIL] OSPFv3 neighbors check: ${device} : Expected OSPFv3 neighbor is: ${expected_neighbor} : OSPFv3 neighbor is down.
      END
    END

baseline ospf iosxe validate correct ospfv3 neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ospf validate correct ospfv3 neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_OSPFV3_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] OSPFv3 neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show ospfv3 neighbor"
    ${expected_neighbors}=  Set Variable  ${BASELINE_OSPFV3_NEIGHBORS['${device}']}
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      ${status}=  Run Keyword And Return Status  values "${expected_neighbor}" and "FULL" exist on same line
      IF  ${status}
        baseline set test pass  [PASS] OSPFv3 neighbors check: ${device} : Expected OSPFv3 neighbor is: ${expected_neighbor} : OSPFv3 neighbor is up.
      ELSE
        baseline set test fail  [FAIL] OSPFv3 neighbors check: ${device} : Expected OSPFv3 neighbor is: ${expected_neighbor} : OSPFv3 neighbor is down.
      END
    END
