*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_ldp.yaml
#
#
#     Keywords in this file
#
# baseline ldp validate correct ldp neighbors are up as per defined baseline
# baseline ldp validate minimum ldp neighbor scale as per defined baseline
# baseline ldp validate minimum tldp neighbor scale as per defined baseline
# baseline ldp validate minimum ldp local bindings scale as per defined baseline
# baseline ldp validate minimum ldp remote bindings scale as per defined baseline
#
#
#
################################################################################

*** Variables ***


*** Keywords ***
######################  LDP neighbors checks  #######################

baseline ldp validate correct ldp neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_LDP_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_LDP_NEIGHBORS:
    ...                ROUTER_A:
    ...                  - 172.16.224.168:0
    ...                  - 172.16.224.29:0
    ...
    ...              baseline ldp validate correct ldp neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct ldp neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LDP_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for LDP neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ldp iosxr validate correct ldp neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline ldp iosxe validate correct ldp neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline ldp nxos validate correct ldp neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP neighbors check: ${device} : Skip check, LDP neighbors checks are currently not available on NXOS devices
      END
    END

baseline ldp iosxr validate correct ldp neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate correct ldp neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] LDP neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp neighbor brief"
    ${expected_neighbors}=  Set Variable  ${BASELINE_LDP_NEIGHBORS['${device}']}
    ${actual_neighbors}=  extract patterns "\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+"
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      IF  "${expected_neighbor}" in "${actual_neighbors}"
        baseline set test pass  [PASS] LDP neighbors check: ${device} : Expected LDP neighbor is: ${expected_neighbor} : LDP neighbor is up.
      ELSE
        baseline set test fail  [FAIL] LDP neighbors check: ${device} : Expected LDP neighbor is: ${expected_neighbor} : LDP neighbor is down.
      END
    END

baseline ldp iosxe validate correct ldp neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate correct ldp neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] LDP neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp neighbor"
    ${expected_neighbors}=  Set Variable  ${BASELINE_LDP_NEIGHBORS['${device}']}
    ${actual_neighbors}=  extract patterns "Peer LDP Ident: ([\\d\\.]+:\\d+)"
    FOR  ${expected_neighbor}  IN  @{expected_neighbors}
      IF  "${expected_neighbor}" in "${actual_neighbors}"
        baseline set test pass  [PASS] LDP neighbors check: ${device} : Expected LDP neighbor is: ${expected_neighbor} : LDP neighbor is up.
      ELSE
        baseline set test fail  [FAIL] LDP neighbors check: ${device} : Expected LDP neighbor is: ${expected_neighbor} : LDP neighbor is down.
      END
    END




######################  LDP neighbor scale checks  #######################




baseline ldp validate minimum ldp neighbor scale as per defined baseline
    [Documentation]  Create the variable BASELINE_LDP_NEIGHBOR_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_LDP_NEIGHBOR_SCALE:
    ...                ROUTER_A: 100
    ...
    ...              baseline ldp validate minimum ldp neighbor scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum ldp neighbor scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LDP_NEIGHBOR_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for LDP neighbor scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ldp iosxr validate minimum ldp neighbor scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline ldp iosxe validate minimum ldp neighbor scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline ldp nxos validate minimum ldp neighbor scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP neighbor scale check: ${device} : Skip check, LDP neighbor scale checks are currently not available on NXOS devices
      END
    END

baseline ldp iosxr validate minimum ldp neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum ldp neighbor scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] LDP neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp summary"
    ${expected_value}=  Set Variable  ${BASELINE_LDP_NEIGHBOR_SCALE['${device}']}
    ${actual_value}=  extract pattern "Neighbors : +(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END

baseline ldp iosxe validate minimum ldp neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum ldp neighbor scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] LDP neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp neighbor | include Peer LDP Ident"
    ${output}=  run "show mpls ldp neighbor | count Peer LDP Ident"
    ${expected_value}=  Set Variable  ${BASELINE_LDP_NEIGHBOR_SCALE['${device}']}
    ${actual_value}=  Get Regexp Matches  ${output}  \\d+
    IF  ${actual_value[0]} >= ${expected_value}
      baseline set test pass  [PASS] LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
    ELSE
      baseline set test fail  [FAIL] LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
    END




######################  LDP targetted neighbor scale checks  #######################




baseline ldp validate minimum tldp neighbor scale as per defined baseline
    [Documentation]  Create the variable BASELINE_TLDP_NEIGHBOR_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_TLDP_NEIGHBOR_SCALE:
    ...                ROUTER_A: 100
    ...
    ...              baseline ldp validate minimum tldp neighbor scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum tldp neighbor scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_TLDP_NEIGHBOR_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for T-LDP neighbor scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ldp iosxr validate minimum tldp neighbor scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline ldp iosxe validate minimum tldp neighbor scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] T-LDP neighbor scale check: ${device} : Skip check, T-LDP neighbor scale checks are currently not available on IOSXE and IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline ldp nxos validate minimum ldp neighbor scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] T-LDP neighbor scale check: ${device} : Skip check, T-LDP neighbor scale checks are currently not available on NXOS devices
      END
    END

baseline ldp iosxr validate minimum tldp neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum tldp neighbor scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_TLDP_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] T-LDP neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp discovery brief | i Tgt | utility wc lines"
    run "show mpls ldp discovery summary"
    ${expected_value}=  Set Variable  ${BASELINE_TLDP_NEIGHBOR_SCALE['${device}']}
    ${actual_value}=  extract patterns "(\\d+) targeted"
    IF  ${actual_value}[-1] >= ${expected_value}
      baseline set test pass  [PASS] T-LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}[-1].
    ELSE
      baseline set test fail  [FAIL] T-LDP neighbor scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}[-1].
    END



######################  LDP local bindings scale checks  #######################




baseline ldp validate minimum ldp local bindings scale as per defined baseline
    [Documentation]  Create the variable BASELINE_LDP_LOCAL_BINDINGS_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_LDP_LOCAL_BINDINGS_SCALE:
    ...                ROUTER_A: 1000
    ...
    ...              baseline ldp validate minimum ldp local bindings scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum ldp local bindings scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for LDP local bindings scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ldp iosxr validate minimum ldp local bindings scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        baseline ldp iosxe validate minimum ldp local bindings scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        #baseline ldp ios validate minimum ldp local bindings scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP local bindings scale check: ${device} : Skip check, LDP local bindings scale checks are currently not available on IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline ldp nxos validate minimum ldp local bindings scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP local bindings scale check: ${device} : Skip check, LDP local bindings scale checks are currently not available on NXOS devices
      END
    END

baseline ldp iosxr validate minimum ldp local bindings scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum ldp local bindings scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_LOCAL_BINDINGS_SCALE.keys()}"
      baseline set test comment  [SKIP] LDP local bindings scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp bindings summary"
    ${expected_value}=  Set Variable  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE['${device}']}
    ${actual_value}=  extract pattern "Local Bindings : +(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] LDP local bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] LDP local bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END

baseline ldp iosxe validate minimum ldp local bindings scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum ldp local bindings scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_LOCAL_BINDINGS_SCALE.keys()}"
      baseline set test comment  [SKIP] LDP local bindings scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp bindings summary"
    ${expected_value}=  Set Variable  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE['${device}']}
    ${actual_value}=  extract pattern "Total number of prefixes: +(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] LDP local bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] LDP local bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END




######################  LDP remote bindings scale checks  #######################



baseline ldp validate minimum ldp remote bindings scale as per defined baseline
    [Documentation]  Create the variable BASELINE_LDP_REMOTE_BINDINGS_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_LDP_REMOTE_BINDINGS_SCALE:
    ...                ROUTER_A: 1000
    ...
    ...              baseline ldp validate minimum ldp remote bindings scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum ldp remote bindings scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LDP_REMOTE_BINDINGS_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for LDP remote bindings scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline ldp iosxr validate minimum ldp remote bindings scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        #baseline ldp iosxe validate minimum ldp remote bindings scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP remote bindings scale check: ${device} : Skip check, LDP remote bindings scale checks are currently not available on IOS XE devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        #baseline ldp ios validate minimum ldp remote bindings scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP remote bindings scale check: ${device} : Skip check, LDP remote bindings scale checks are currently not available on IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline ldp nxos validate minimum ldp remote bindings scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] LDP remote bindings scale check: ${device} : Skip check, LDP remote bindings scale checks are currently not available on NXOS devices
      END
    END

baseline ldp iosxr validate minimum ldp remote bindings scale as per defined baseline
    [Documentation]  Child keyword for 'baseline ldp validate minimum ldp remote bindings scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_LDP_REMOTE_BINDINGS_SCALE.keys()}"
      baseline set test comment  [SKIP] LDP remote bindings scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show mpls ldp bindings summary"
    ${expected_value}=  Set Variable  ${BASELINE_LDP_REMOTE_BINDINGS_SCALE['${device}']}
    ${actual_value}=  extract pattern "Remote Bindings: +(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] LDP remote bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] LDP remote bindings scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END
