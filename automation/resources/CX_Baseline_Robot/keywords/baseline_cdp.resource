*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_cdp.yaml
#
#
#     Keywords in this file
#
# baseline cdp validate correct cdp neighbors are up as per defined baseline
#
#
#
################################################################################


*** Variables ***
## maybe add show cdp protocol check

*** Keywords ***
######################  CDP neighbor checks #######################

baseline cdp validate correct cdp neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_CDP_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_CDP_NEIGHBORS:
    ...                ROUTER_A:
    ...                  NEIGHBOR_X:
    ...                    - INTERFACE_1
    ...                    - INTERFACE_2
    ...
    ...              baseline cdp validate correct cdp neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct cdp neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_CDP_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for CDP neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline cdp iosxr validate correct cdp neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline cdp iosxe validate correct cdp neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] CDP neighbors check: ${device} : Skip check, CDP neighbors checks are currently not available on IOSXE devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline cdp nxos validate correct cdp neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] CDP neighbors check: ${device} : Skip check, CDP neighbors checks are currently not available on NXOS devices
      END
    END

baseline cdp iosxr validate correct cdp neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline cdp validate correct cdp neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_CDP_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] CDP neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show cdp neighbors"
    IF  "${status}" == "FAIL"
      baseline set test fail  [FAIL] CDP neighbors check: ${device} : No CDP neighbors are up.
      Return From Keyword
    END
    ${output}=  Evaluate  json.dumps($output)
    ${output}=  Evaluate  json.loads($output)
    ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
    ${neighbor_list}=  Get Dictionary Keys  ${BASELINE_CDP_NEIGHBORS['${device}']}
    FOR  ${neighbor}  IN  @{neighbor_list}
      ${expected_interfaces}=  Set Variable  ${BASELINE_CDP_NEIGHBORS['${device}']['${neighbor}']}
      ${actual_interfaces}=  Run Keyword And Ignore Error  YamlPath Parse New  query=[device_id='${neighbor}'].local_interface  data=${output}
      FOR  ${expected_interface}  IN  @{expected_interfaces}
        ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_interfaces[1]}  ${expected_interface}
        IF  ${status}
          baseline set test pass  [PASS] CDP neighbors check: ${device} : Expected CDP neighbor is: neighbor: ${neighbor} , interface: ${expected_interface} : CDP neighbor is up.
        ELSE
          baseline set test fail  [FAIL] CDP neighbors check: ${device} : Expected CDP neighbor is: neighbor: ${neighbor} , interface: ${expected_interface} : CDP neighbor is down.
        END
      END
    END
