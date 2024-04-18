*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_interface.yaml
#
#
#     Keywords in this file
#
# baseline interfaces validate interfaces are up as per defined baseline
#
#
#
################################################################################

*** Keywords ***
######################  Interfaces  #######################

baseline interfaces validate interfaces are up as per defined baseline
    [Documentation]  Create the variable BASELINE_INTERFACES_UP and/or BASELINE_INTERFACES_DOWN in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_INTERFACES_UP:
    ...                ROUTER_A:
    ...                  - GigabitEthernet6/1
    ...                  - GigabitEthernet2/1
    ...
    ...              baseline interfaces validate interfaces are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate interfaces are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_INTERFACES_UP}
    ${baseline_data_exists_2}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_INTERFACES_DOWN}
    IF  not ${baseline_data_exists} and not ${baseline_data_exists_2}
      baseline set test comment  [SKIP] No baseline defined for hardware platform check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline interfaces iosxr validate interfaces are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline interfaces iosxe validate interfaces are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #validate interfaces are up as per defined baseline on iosxe  ${device}
        baseline set test comment  [SKIP] Interface UP status check: ${device} : Skip check, Interface UP status checks are currently not available on NXOS devices
      END
    END

baseline interfaces iosxr validate interfaces are up as per defined baseline
    [Documentation]  Child keyword for 'baseline interfaces validate interfaces are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_INTERFACES_UP.keys()}"
      baseline set test comment  [SKIP] Interface UP status check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show ipv4 interface brief"
    ${int_errors}=  Create List
    FOR  ${interface}  IN  @{BASELINE_INTERFACES_UP['${device}']}
      ${int_up}=  Run Keyword And Return Status  output matches pattern "${interface} +[\\\\S ]+Up"
      ${int_down}=  Run Keyword And Return Status  output does not match pattern "${interface} +[\\\\S ]+Down"
      IF  not ${int_up} and not ${int_down}
        Append To List  ${int_errors}  ${interface}
      END
    END
    ${list_length}=  Get Length  ${int_errors}
    IF  ${list_length} == 0
      baseline set test pass  [PASS] Interface UP status check: ${device} : All the expected up interfaces as per defined baseline are correctly up.
    ELSE
      baseline set test fail  [FAIL] Interface UP status check: ${device} : Some of the expected up interfaces as per the defined baseline are down. Interfaces that are incorrectly down are:\n ${int_errors}
    END

    ${int_down_check}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_INTERFACES_DOWN}
    Return From Keyword If  not ${int_down_check}

    IF  "${device}" not in "${BASELINE_INTERFACES_DOWN.keys()}"
      baseline set test comment  [SKIP] Interface DOWN status check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${int_errors}=  Create List
    FOR  ${interface}  IN  @{BASELINE_INTERFACES_DOWN['${device}']}
      ${status}=  Run Keyword And Return Status  output matches pattern "${interface} +[\\\\S ]+Down"
      IF  not ${status}
        Append To List  ${int_errors}  ${interface}
      END
    END
    ${list_length}=  Get Length  ${int_errors}
    IF  ${list_length} == 0
      baseline set test pass  [PASS] Interface DOWN status check: ${device} : All the expected down interfaces as per defined baseline are correctly down.
    ELSE
      baseline set test fail  [FAIL] Interface DOWN status check: ${device} : Some of the expected down interfaces as per the defined baseline are up. Interfaces that are incorrectly up are:\n ${int_errors}
    END


baseline interfaces iosxe validate interfaces are up as per defined baseline
    [Documentation]  Child keyword for 'baseline interfaces validate interfaces are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_INTERFACES_UP.keys()}"
      baseline set test comment  [SKIP] Interface UP status check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show ip interface brief"
    ${int_errors}=  Create List
    FOR  ${interface}  IN  @{BASELINE_INTERFACES_UP['${device}']}
      ${int_up}=  Run Keyword And Return Status  output matches pattern "${interface} +[\\\\S ]+up"
      ${int_down}=  Run Keyword And Return Status  output does not match pattern "${interface} +[\\\\S ]+down"
      IF  not ${int_up} and not ${int_down}
        Append To List  ${int_errors}  ${interface}
      END
    END
    ${list_length}=  Get Length  ${int_errors}
    IF  ${list_length} == 0
      baseline set test pass  [PASS] Interface UP status check: ${device} : All the expected up interfaces as per defined baseline are correctly up.
    ELSE
      baseline set test fail  [FAIL] Interface UP status check: ${device} : Some of the expected up interfaces as per the defined baseline are down. Interfaces that are incorrectly down are:\n ${int_errors}
    END

    ${int_down_check}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_INTERFACES_DOWN}
    Return From Keyword If  not ${int_down_check}

    IF  "${device}" not in "${BASELINE_INTERFACES_DOWN.keys()}"
      baseline set test comment  [SKIP] Interface DOWN status check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${int_errors}=  Create List
    FOR  ${interface}  IN  @{BASELINE_INTERFACES_DOWN['${device}']}
      ${status}=  Run Keyword And Return Status  output matches pattern "${interface} +[\\\\S ]+down"
      IF  not ${status}
        Append To List  ${int_errors}  ${interface}
      END
    END
    ${list_length}=  Get Length  ${int_errors}
    IF  ${list_length} == 0
      baseline set test pass  [PASS] Interface DOWN status check: ${device} : All the expected down interfaces as per defined baseline are correctly down.
    ELSE
      baseline set test fail  [FAIL] Interface DOWN status check: ${device} : Some of the expected down interfaces as per the defined baseline are up. Interfaces that are incorrectly up are:\n ${int_errors}
    END
