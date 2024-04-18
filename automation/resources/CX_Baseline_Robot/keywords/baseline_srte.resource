*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_srte.yaml
#
#
#     Keywords in this file
#
# baseline srte validate minimum SRTE scale as per defined baseline
# baseline srte validate pce ipv4 peers are up as per defined baseline
# baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  SRTE  #######################

baseline srte validate minimum SRTE scale as per defined baseline
    [Documentation]  Create the variable BASELINE_SRTE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_SRTE_SCALE:
    ...                ROUTER_A: 265
    ...                ROUTER_B: 265
    ...
    ...              baseline srte validate minimum SRTE scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum SRTE scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_SRTE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for SRTE scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline srte iosxr validate minimum SRTE scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] SRTE scale checks: ${device} : Skip, SRTE scale checks are currently not available on IOS XE or IOS or NXOS devices
      END
    END

baseline srte iosxr validate minimum SRTE scale as per defined baseline
    [Documentation]  Child keyword for 'baseline srte validate minimum SRTE scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SRTE_SCALE.keys()}"
      baseline set test comment  [SKIP] SRTE scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show segment-routing traffic-eng policy summary"
    ${expected_value}=  Set Variable  ${BASELINE_SRTE_SCALE['${device}']}
    ${actual_value}=  extract patterns "Operational: up (\\d+)"
    IF  ${actual_value}[0] >= ${expected_value}
      baseline set test pass  [PASS] SRTE scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0]
    ELSE
      baseline set test fail  [FAIL] SRTE scale check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}[0]
    END

################################################################################

baseline srte validate pce ipv4 peers are up as per defined baseline
    [Documentation]  Create the variable BASELINE_PCE_PEERS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_PCE_PEERS:
    ...                ROUTER_A:
    ...                  - 10.135.0.1
    ...                  - 10.135.0.2
    ...                  - 10.135.0.22
    ...
    ...              baseline srte validate pce ipv4 peers are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate pce ipv4 peers are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_PCE_PEERS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for PCE IPv4 Peers check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline srte iosxr validate pce ipv4 peers are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] PCE IPv4 Peers checks: ${device} : Skip, PCE IPv4 Peers checks are currently not available on IOS XE or IOS or NXOS devices
      END
    END

baseline srte iosxr validate pce ipv4 peers are up as per defined baseline
    [Documentation]  Child keyword for 'baseline srte validate pce ipv4 peers are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_PCE_PEERS.keys()}"
      baseline set test comment  [SKIP] PCE IPv4 Peers check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    FOR  ${expected_peer}  IN  @{BASELINE_PCE_PEERS['${device}']}
      run "show pce ipv4 peer ${expected_peer}"
      ${status}=  Run Keyword And Return Status  values "State:" and "Up" exist on same line
      IF  ${status}
        baseline set test pass  [PASS] PCE IPv4 Peers check: ${device} : Check peer '${expected_peer}' is up : Check passed, peer is shown as up in 'show pce ipv4 peer ${expected_peer}'
      ELSE
        baseline set test fail  [FAIL] PCE IPv4 Peers check: ${device} : Check peer '${expected_peer}' is up : Check failed, peer is not shown as up in 'show pce ipv4 peer ${expected_peer}'
      END
    END

################################################################################

baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline
    [Documentation]  Create the variable BASELINE_PCC_PEERS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_PCC_PEERS:
    ...                ROUTER_A:
    ...                  - 10.135.0.1
    ...                  - 10.135.0.2
    ...                  - 10.135.0.22
    ...
    ...              baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate segment routing pcc ipv4 peers are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_PCC_PEERS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for PCC IPv4 Peers check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline srte iosxr validate segment routing pcc ipv4 peers are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] PCC IPv4 Peers checks: ${device} : Skip, PCC IPv4 Peers checks are currently not available on IOS XE or IOS or NXOS devices
      END
    END

baseline srte iosxr validate segment routing pcc ipv4 peers are up as per defined baseline
    [Documentation]  Child keyword for 'baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_PCC_PEERS.keys()}"
      baseline set test comment  [SKIP] SR PCC IPv4 Peers check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show segment-routing traffic-eng pcc ipv4 peer brief"
    FOR  ${expected_peer}  IN  @{BASELINE_PCC_PEERS['${device}']}
      ${status}=  Run Keyword And Return Status  extract pattern "${expected_peer} +\\\\S+ +up"
      IF  ${status}
        baseline set test pass  [PASS] SR PCC IPv4 Peers check: ${device} : Check peer '${expected_peer}' is up : Check passed, peer is shown as up in 'show segment-routing traffic-eng pcc ipv4 peer brief'
      ELSE
        baseline set test fail  [FAIL] SR PCC IPv4 Peers check: ${device} : Check peer '${expected_peer}' is up : Check failed, peer is not shown as up in 'show segment-routing traffic-eng pcc ipv4 peer brief'
      END
    END
