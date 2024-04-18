*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined in: Data/Baseline/baseline_bfd.yaml
#     See examples here: EXAMPLE_Data/baseline_bfd.yaml
#
#     Keywords in this file
#
# baseline bfd validate minimum bfd ipv4 scale as per defined baseline
# baseline bfd validate minimum bfd ipv6 scale as per defined baseline
#
################################################################################

*** Keywords ***
######################  BFD IPv4 scale #######################

baseline bfd validate minimum bfd ipv4 scale as per defined baseline
    [Documentation]  Check the current BFD IPv4 scale meets your defined baseline.
    ...
    ...              *Example baseline definition:* <add_link_here>
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | baseline bfd validate minimum bfd ipv4 scale as per defined baseline | NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum bfd ipv4 scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_BFD_IPV4_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for BFD IPv4 scale checks.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline bfd iosxr validate minimum bfd ipv4 scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline bfd iosxe validate minimum bfd ipv4 scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] BFD IPv4 scale check: ${device} : Skip check, IPv4 BFD checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline bfd nxos validate minimum bfd ipv4 scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] BFD IPv4 scale check: ${device} : Skip check, IPv4 BFD checks are currently not available on NXOS devices
      END
    END

baseline bfd iosxr validate minimum bfd ipv4 scale as per defined baseline
    [Documentation]  Child keyword for ``baseline bfd validate minimum bfd ipv4 scale as per defined baseline``
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_BFD_IPV4_SCALE.keys()}"
      baseline set test comment  [SKIP] BFD IPv4 scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END
    run "show bfd ipv4"
    ${expected_value}=  Set Variable  ${BASELINE_BFD_IPV4_SCALE['${device}']}
    ${actual_value}=  extract pattern "IPV4 Sessions Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] BFD IPv4 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] BFD IPv4 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END

baseline bfd iosxe validate minimum bfd ipv4 scale as per defined baseline
    [Documentation]  Child keyword for ``baseline bfd validate minimum bfd ipv4 scale as per defined baseline``
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_BFD_IPV4_SCALE.keys()}"
      baseline set test comment  [SKIP] BFD IPv4 scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END
    run "show bfd summary session"
    ${expected_value}=  Set Variable  ${BASELINE_BFD_IPV4_SCALE['${device}']}
    ${actual_value}=  extract pattern "IPV4\\s+\\d+\\s+(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] BFD IPv4 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] BFD IPv4 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END

######################  BFD IPv6 scale #######################

baseline bfd validate minimum bfd ipv6 scale as per defined baseline
    [Documentation]  Create the variable BASELINE_BFD_IPV6_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_BFD_IPV6_SCALE:
    ...                ROUTER_A: 50
    ...                ROUTER_B: 50
    ...
    ...              baseline bfd validate minimum bfd ipv6 scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum bfd ipv6 scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_BFD_IPV6_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for BFD IPv6 scale checks.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline bfd iosxr validate minimum bfd ipv6 scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline bfd iosxe validate minimum bfd ipv6 scale as per defined baseline  ${device}
        #baseline set test comment  [SKIP] BFD IPv6 scale check: ${device} : IPv6 BFD checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline bfd nxos validate minimum bfd ipv6 scale as per defined baseline  ${device}
        baseline set test comment  [SKIP] BFD IPv6 scale check: ${device} : IPv6 BFD checks are currently not available on NXOS devices
      END
    END


baseline bfd iosxr validate minimum bfd ipv6 scale as per defined baseline
    [Documentation]  Child keyword for ``baseline bfd validate minimum bfd ipv6 scale as per defined baseline``
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_BFD_IPV6_SCALE.keys()}"
      baseline set test comment  [SKIP] BFD IPv6 scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END
    run "show bfd ipv6"
    ${expected_value}=  Set Variable  ${BASELINE_BFD_IPV6_SCALE['${device}']}
    ${actual_value}=  extract pattern "IPV6 Sessions Up: (\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] BFD IPv6 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] BFD IPv6 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END

baseline bfd iosxe validate minimum bfd ipv6 scale as per defined baseline
    [Documentation]  Child keyword for ``baseline bfd validate minimum bfd ipv6 scale as per defined baseline``
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_BFD_IPV6_SCALE.keys()}"
      baseline set test comment  [SKIP] BFD IPv6 scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END
    run "show bfd summary session"
    ${expected_value}=  Set Variable  ${BASELINE_BFD_IPV6_SCALE['${device}']}
    ${actual_value}=  extract pattern "IPV6\\s+\\d+\\s+(\\d+)"
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] BFD IPv6 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] BFD IPv6 scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END
