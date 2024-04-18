*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_route_scale.yaml
#
#
#     Keywords in this file
#
# baseline route_scale validate minimum routing table scale is present as per defined baseline
# baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline
# baseline route_scale validate minimum mrib route scale is present as per defined baseline
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  Routing table Scale  #######################

baseline route_scale validate minimum routing table scale is present as per defined baseline
    [Documentation]  Create the variable BASELINE_ROUTE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_ROUTE_SCALE:
    ...                ROUTER_A:
    ...                  global:
    ...                    connected: 2
    ...                    isis NGN: 40
    ...                    Total: 49
    ...
    ...              baseline route_scale validate minimum routing table scale is present as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    baseline set test title  Validate minimum routing scale is present as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_ROUTE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for Routing table scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline route_scale iosxr validate minimum routing scale is present as per defined baseline  ${device}  ${VRF_LIST}  ${ROUTING_SOURCE}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline route_scale iosxe validate minimum routing scale is present as per defined baseline  ${device}  ${VRF_LIST}  ${ROUTING_SOURCE}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] Routing table scale check: ${device} : Skip, Routing table scale checks are currently not available on NXOS devices
      END
    END

baseline route_scale iosxr validate minimum routing scale is present as per defined baseline
    [Documentation]  Child keyword for 'baseline route_scale validate minimum routing table scale is present as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    IF  "${device}" not in "${BASELINE_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] Routing table scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show route summary"
        ELSE
          run parsed "show route vrf ${vrf} summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show route summary"
        ELSE
          run parsed "show route vrf ${vrf} summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
             baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
             Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show route summary"
        ELSE
          run parsed "show route vrf ${vrf} summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show route summary"
        ELSE
          run parsed "show route vrf ${vrf} summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
            baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
            Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    END


baseline route_scale iosxe validate minimum routing scale is present as per defined baseline
    [Documentation]  Child keyword for 'baseline route_scale validate minimum routing table scale is present as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    IF  "${device}" not in "${BASELINE_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] Routing table scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ip route vrf ${vrf} summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "subnets" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ip route vrf ${vrf} summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
             baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
             Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "subnets" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ip route vrf ${vrf} summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "subnets" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ip route vrf ${vrf} summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_ROUTE_SCALE['${device}']['${vrf}'].keys()}
            baseline set test comment  [SKIP] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
            Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "subnets" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] Routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    END





baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline
    [Documentation]  Create the variable BASELINE_IPV6_ROUTE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_IPV6_ROUTE_SCALE:
    ...                ROUTER_A:
    ...                  global:
    ...                    connected: 2
    ...                    isis NGN: 40
    ...                    Total: 49
    ...
    ...              baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    baseline set test title  Validate minimum ipv6 routing scale is present as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_IPV6_ROUTE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for IPv6 routing table scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline route_scale iosxr validate minimum ipv6 routing scale is present as per defined baseline  ${device}  ${VRF_LIST}  ${ROUTING_SOURCE}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline route_scale iosxe validate minimum ipv6 routing scale is present as per defined baseline  ${device}  ${VRF_LIST}  ${ROUTING_SOURCE}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : Skip, IPv6 routing table scale checks are currently not available on NXOS devices
      END
    END

baseline route_scale iosxr validate minimum ipv6 routing scale is present as per defined baseline
    [Documentation]  Child keyword for 'baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    IF  "${device}" not in "${BASELINE_IPV6_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show route ipv6 summary"
        ELSE
          run parsed "show route vrf ${vrf} ipv6 summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show route ipv6 summary"
        ELSE
          run parsed "show route vrf ${vrf} ipv6 summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
             baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
             Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show route ipv6 summary"
        ELSE
          run parsed "show route vrf ${vrf} ipv6 summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show route ipv6 summary"
        ELSE
          run parsed "show route vrf ${vrf} ipv6 summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
            baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
            Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "routes" where "routesource" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    END



baseline route_scale iosxe validate minimum ipv6 routing scale is present as per defined baseline
    [Documentation]  Child keyword for 'baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}  ${ROUTING_SOURCE}=${EMPTY}
    IF  "${device}" not in "${BASELINE_IPV6_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show ipv6 route summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ipv6 route vrf ${vrf} summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "networks" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" == "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run parsed "show ipv6 route summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ipv6 route vrf ${vrf} summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
             baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
             Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "networks" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show ipv6 route summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ipv6 route vrf ${vrf} summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "networks" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}" and "${ROUTING_SOURCE}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run parsed "show ipv6 route summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        ELSE
          run parsed "show ipv6 route vrf ${vrf} summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        END
        FOR  ${routesource}  IN  @{ROUTING_SOURCE}
          IF  "${routesource}" not in @{BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}'].keys()}
            baseline set test comment  [SKIP] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Skip check, no baseline defined
            Continue For Loop
          END
          ${expected_value}=  Set Variable  ${BASELINE_IPV6_ROUTE_SCALE['${device}']['${vrf}']['${routesource}']}
          ${actual_value}=  get parsed "networks" where "route_source" is "${routesource}"
          IF  ${actual_value} >= ${expected_value}
            baseline set test pass  [PASS] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          ELSE
            baseline set test fail  [FAIL] IPv6 routing table scale check: ${device} : vrf ${vrf} : Route source ${routesource} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
          END
        END
      END
    END




######################  Multicast routing table scale  #######################

baseline route_scale validate minimum mrib route scale is present as per defined baseline
    [Documentation]  Create the variable BASELINE_MRIB_ROUTE_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_MRIB_ROUTE_SCALE:
    ...                ROUTER_A:
    ...                  global:
    ...                    SG: 2
    ...                    G: 40
    ...
    ...              baseline route_scale validate minimum mrib route scale is present as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}  ${VRF_LIST}=${EMPTY}
    baseline set test title  Validate minimum multicast routing scale is present as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_MRIB_ROUTE_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for multicast routing table scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline route_scale iosxr validate minimum mrib route scale is present as per defined baseline  ${device}  ${VRF_LIST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        #baseline route_scale iosxe validate minimum mrib route scale is present as per defined baseline  ${device}  ${VRF_LIST}
        baseline set test comment  [SKIP] Multicast routing table scale check: ${device} : Skip, Multicast routing table scale checks are currently not available on IOSXE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline route_scale nxos validate minimum mrib route scale is present as per defined baseline  ${device}  ${VRF_LIST}
        baseline set test comment  [SKIP] Multicast routing table scale check: ${device} : Skip, Multicast routing table scale checks are currently not available on NXOS devices
      END
    END

baseline route_scale iosxr validate minimum mrib route scale is present as per defined baseline
    [Documentation]  Child keyword for 'baseline route_scale validate minimum mrib route scale is present as per defined baseline'.
    [Arguments]  ${device}  ${VRF_LIST}=${EMPTY}
    IF  "${device}" not in "${BASELINE_MRIB_ROUTE_SCALE.keys()}"
      baseline set test comment  [SKIP] Multicast routing table scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    IF  "${VRF_LIST}" == "${EMPTY}"
      FOR  ${vrf}  IN  @{BASELINE_MRIB_ROUTE_SCALE['${device}'].keys()}
        IF  "${vrf}" == "global"
          run "show mrib ipv4 route summary"
        ELSE
          run "show mrib vrf ${vrf} ipv4 route summary"
        END
        ${expected_SG_value}=  Set Variable  ${BASELINE_MRIB_ROUTE_SCALE['${device}']['${vrf}']['SG']}
        ${expected_G_value}=  Set Variable  ${BASELINE_MRIB_ROUTE_SCALE['${device}']['${vrf}']['G']}
        ${actual_SG_value}=  extract pattern "\\(S\\,G\\) routes = (\\d+)"
        ${actual_G_value}=  extract pattern "\\(\\*\\,G\\) routes = (\\d+)"
        IF  ${actual_G_value} >= ${expected_G_value}
          baseline set test pass  [PASS] Multicast routing table scale check: ${device} : vrf ${vrf} : (*,G) : Expected minumum value: ${expected_G_value} : Actual value: ${actual_G_value}.
        ELSE
          baseline set test fail  [FAIL] Multicast routing table scale check: ${device} : vrf ${vrf} : (*,G) : Expected minumum value: ${expected_G_value} : Actual value: ${actual_G_value}.
        END
        IF  ${actual_SG_value} >= ${expected_SG_value}
          baseline set test pass  [PASS] Multicast routing table scale check: ${device} : vrf ${vrf} : (S,G) : Expected minumum value: ${expected_SG_value} : Actual value: ${actual_SG_value}.
        ELSE
          baseline set test fail  [FAIL] Multicast routing table scale check: ${device} : vrf ${vrf} : (S,G) : Expected minumum value: ${expected_SG_value} : Actual value: ${actual_SG_value}.
        END
      END
    ELSE IF  "${VRF_LIST}" != "${EMPTY}"
      FOR  ${vrf}  IN  @{VRF_LIST}
        IF  "${vrf}" not in @{BASELINE_MRIB_ROUTE_SCALE['${device}'].keys()}
          baseline set test comment  [SKIP] Multicast routing table scale check: ${device} : vrf ${vrf} : Skip check, no baseline defined
          Continue For Loop
        END
        IF  "${vrf}" == "global"
          run "show mrib ipv4 route summary"
        ELSE
          run "show mrib vrf ${vrf} ipv4 route summary"
        END
        ${expected_SG_value}=  Set Variable  ${BASELINE_MRIB_ROUTE_SCALE['${device}']['${vrf}']['SG']}
        ${expected_G_value}=  Set Variable  ${BASELINE_MRIB_ROUTE_SCALE['${device}']['${vrf}']['G']}
        ${actual_SG_value}=  extract pattern "\\(S\\,G\\) routes = (\\d+)"
        ${actual_G_value}=  extract pattern "\\(\\*\\,G\\) routes = (\\d+)"
        IF  ${actual_G_value} >= ${expected_G_value}
          baseline set test pass  [PASS] Multicast routing table scale check: ${device} : vrf ${vrf} : (*,G) : Expected minumum value: ${expected_G_value} : Actual value: ${actual_G_value}.
        ELSE
          baseline set test fail  [FAIL] Multicast routing table scale check: ${device} : vrf ${vrf} : (*,G) : Expected minumum value: ${expected_G_value} : Actual value: ${actual_G_value}.
        END
        IF  ${actual_SG_value} >= ${expected_SG_value}
          baseline set test pass  [PASS] Multicast routing table scale check: ${device} : vrf ${vrf} : (S,G) : Expected minumum value: ${expected_SG_value} : Actual value: ${actual_SG_value}.
        ELSE
          baseline set test fail  [FAIL] Multicast routing table scale check: ${device} : vrf ${vrf} : (S,G) : Expected minumum value: ${expected_SG_value} : Actual value: ${actual_SG_value}.
        END
      END
    END
