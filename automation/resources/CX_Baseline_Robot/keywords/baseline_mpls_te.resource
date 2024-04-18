*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_mpls_te.yaml
#
#
#     Keywords in this file
#
# baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  MPLS-TE  #######################

baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline
    [Documentation]  Create the variable BASELINE_MPLS_TE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_MPLS_TE_SCALE:
    ...                ROUTER_A:
    ...                  head: 11
    ...                  midpoint: 1
    ...                  tail: 5
    ...
    ...              baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum mpls traffic-eng scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_MPLS_TE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for MPLS Traffic-Eng scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline mpls_te iosxr validate minimum mpls traffic-eng scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline mpls_te iosxe validate minimum mpls traffic-eng scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] MPLS Traffic-Eng scale checks: ${device} : Skip, MPLS Traffic-Eng scale checks are currently not available on IOS XE or IOS or NXOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] MPLS Traffic-Eng scale checks: ${device} : Skip, MPLS Traffic-Eng scale checks are currently not available on NXOS devices
      END
    END

baseline mpls_te iosxr validate minimum mpls traffic-eng scale as per defined baseline
    [Documentation]  Child keyword for 'baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_MPLS_TE_SCALE.keys()}"
      baseline set test comment  [SKIP] MPLS Traffic-Eng scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show mpls traffic-eng tunnels up brief | utility tail count 2"
    ${actual_values}=  extract pattern "Displayed \\d+ \\(of \\d+\\) heads, \\d+ \\(of \\d+\\) midpoints, \\d+ \\(of \\d+\\) tails"
    ${actual_values}=  Get Regexp Matches  ${actual_values}  \\d+
    ${actual_value}=  Set Variable  ${actual_values[0]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['head']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, head tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, head tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
    ${actual_value}=  Set Variable  ${actual_values[2]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['midpoint']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, midpoint tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, midpoint tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
    ${actual_value}=  Set Variable  ${actual_values[4]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['tail']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, tail tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, tail tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END

baseline mpls_te iosxe validate minimum mpls traffic-eng scale as per defined baseline
    [Documentation]  Child keyword for 'baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_MPLS_TE_SCALE.keys()}"
      baseline set test comment  [SKIP] MPLS Traffic-Eng scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show mpls traffic-eng tunnels up brief"
    ${actual_values}=  extract pattern "Displayed \\d+ \\(of \\d+\\) heads, \\d+ \\(of \\d+\\) midpoints, \\d+ \\(of \\d+\\) tails"
    ${actual_values}=  Get Regexp Matches  ${actual_values}  \\d+
    ${actual_value}=  Set Variable  ${actual_values[0]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['head']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, head tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, head tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
    ${actual_value}=  Set Variable  ${actual_values[2]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['midpoint']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, midpoint tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, midpoint tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
    ${actual_value}=  Set Variable  ${actual_values[4]}
    ${expected_value}=  Set Variable  ${BASELINE_MPLS_TE_SCALE['${device}']['tail']}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] MPLS Traffic-Eng scale, tail tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] MPLS Traffic-Eng scale, tail tunnels, check: ${device} : Expected minimum value: ${expected_value} : Actual value: ${actual_value}
    END
