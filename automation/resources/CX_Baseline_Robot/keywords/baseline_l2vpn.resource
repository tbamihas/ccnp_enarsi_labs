*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_l2vpn.yaml
#
#
#     Keywords in this file
#
# baseline L2VPN validate minimum L2VPN XC scale as per defined baseline
# baseline L2VPN validate minimum L2VPN BD scale as per defined baseline
# baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline
# baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline
#
#
#
################################################################################

*** Variables ***


*** Keywords ***
######################  L2VPN XC scale checks  #######################

baseline L2VPN validate minimum L2VPN XC scale as per defined baseline
    [Documentation]  Create the variable BASELINE_L2VPN_XC_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_L2VPN_XC_SCALE:
    ...                ROUTER_A: 50
    ...
    ...              baseline L2VPN validate minimum L2VPN XC scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum L2VPN XC scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_L2VPN_XC_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for L2VPN XC scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline L2VPN iosxr validate minimum L2VPN XC scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline L2VPN iosxe validate minimum L2VPN XC scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] ISIS L2VPN XC scale check: ${device} : Skip check, ISIS L2VPN XC scale checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline L2VPN iosxe validate minimum L2VPN XC scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS L2VPN XC scale check: ${device} : Skip check, ISIS L2VPN XC scale checks are currently not available on NXOS devices
      END
    END

baseline L2VPN iosxr validate minimum L2VPN XC scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN XC scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_XC_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN XC scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn xconnect summary"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_XC_SCALE['${device}']}
    ${actual_value}=  extract pattern "Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN XC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN XC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END

baseline L2VPN iosxe validate minimum L2VPN XC scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN XC scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_XC_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN XC scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn service xconnect all"
    run "show l2vpn service xconnect all | count State: UP"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_XC_SCALE['${device}']}
    ${actual_value}=  extract pattern "\\d+"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN XC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN XC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END


######################  L2VPN BD scale checks  #######################


baseline L2VPN validate minimum L2VPN BD scale as per defined baseline
    [Documentation]  Create the variable BASELINE_L2VPN_BD_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_L2VPN_BD_SCALE:
    ...                ROUTER_A: 50
    ...
    ...              baseline L2VPN validate minimum L2VPN BD scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum L2VPN BD scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_L2VPN_BD_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for L2VPN BD scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline L2VPN iosxr validate minimum L2VPN BD scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline L2VPN iosxe validate minimum L2VPN BD scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] ISIS L2VPN BD scale check: ${device} : Skip check, ISIS L2VPN BD scale checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline L2VPN nxos validate minimum L2VPN BD scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS L2VPN BD scale check: ${device} : Skip check, ISIS L2VPN BD scale checks are currently not available on NXOS devices
      END
    END

baseline L2VPN iosxr validate minimum L2VPN BD scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN BD scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_BD_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN BD scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn bridge-domain summary"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_BD_SCALE['${device}']}
    ${actual_value}=  extract pattern "Number of bridge\\-domains: \\d+, Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN BD scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN BD scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END

baseline L2VPN iosxe validate minimum L2VPN BD scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN BD scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_BD_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN BD scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn service vfi all"
    run "show l2vpn service vfi all | count State: UP"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_BD_SCALE['${device}']}
    ${actual_value}=  extract pattern "\\d+"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN BD scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN BD scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END

######################  L2VPN BD PW scale checks  #######################



baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline
    [Documentation]  Create the variable BASELINE_L2VPN_BD_PW_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_L2VPN_BD_PW_SCALE:
    ...                ROUTER_A: 50
    ...
    ...              baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum L2VPN BD PW scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_L2VPN_BD_PW_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for L2VPN BD PW scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline L2VPN iosxr validate minimum L2VPN BD PW scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline L2VPN iosxe validate minimum L2VPN BD PW scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] ISIS L2VPN BD PW scale check: ${device} : Skip check, ISIS L2VPN BD PW scale checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline L2VPN nxos validate minimum L2VPN BD PW scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS L2VPN BD PW scale check: ${device} : Skip check, ISIS L2VPN BD PW scale checks are currently not available on NXOS devices
      END
    END

baseline L2VPN iosxr validate minimum L2VPN BD PW scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_BD_PW_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN BD PW scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn bridge-domain summary"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_BD_PW_SCALE['${device}']}
    ${actual_value}=  extract pattern "Number of PWs: \\d+ Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN BD PW scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN BD PW scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END

baseline L2VPN iosxe validate minimum L2VPN BD PW scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_BD_PW_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN BD PW scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn service vfi all"
    run "show mpls l2transport vc | i vfi"
    ${actual_values}=  extract patterns "UP"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_BD_PW_SCALE['${device}']}
    ${actual_value}=  Get Length  ${actual_values}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN BD PW scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN BD PW scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END



######################  L2VPN BD AC scale checks  #######################


baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline
    [Documentation]  Create the variable BASELINE_L2VPN_BD_AC_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_L2VPN_BD_AC_SCALE:
    ...                ROUTER_A: 50
    ...
    ...              baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum L2VPN BD AC scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_L2VPN_BD_AC_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for L2VPN BD AC scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline L2VPN iosxr validate minimum L2VPN BD AC scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline L2VPN iosxe validate minimum L2VPN BD AC scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS L2VPN BD AC scale check: ${device} : Skip check, ISIS L2VPN BD AC scale checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline L2VPN nxos validate minimum L2VPN BD AC scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS L2VPN BD AC scale check: ${device} : Skip check, ISIS L2VPN BD AC scale checks are currently not available on NXOS devices
      END
    END

baseline L2VPN iosxr validate minimum L2VPN BD AC scale as per defined baseline
    [Documentation]  Child keyword for 'baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_L2VPN_BD_AC_SCALE.keys()}"
      baseline set test comment  [SKIP] L2VPN BD AC scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show l2vpn bridge-domain summary"
    ${expected_value}=  Set Variable  ${BASELINE_L2VPN_BD_AC_SCALE['${device}']}
    ${actual_value}=  extract pattern "Number of ACs: \\d+ Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] L2VPN BD AC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] L2VPN BD AC scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
