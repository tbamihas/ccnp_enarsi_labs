*** Settings ***
Resource    ../../cx_baseline_robot.resource
Library     CXTA
Resource    cxta.robot
Library     OperatingSystem
Library     DateTime
Library     String
Library     Collections


################################################################################
#
#     Baseline data for your topology needs to be defined in: Data/common.yaml
#
#     Keywords in this file
#
# sdwan baseline validate control connections are up as per defined baseline
#
################################################################################

*** Keywords ***
######################  BGP  #######################

sdwan baseline validate control connections are up as per defined baseline
    [Documentation]   This keyword validates if the control connections are up towards all the peer devices.
    ...               Create the required variables in common.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate control connections are up as per defined baseline NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate correct control connections are up as per defined baseline
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate control connections are up as per defined baseline on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate control connections are up as per defined baseline on viptelaOS  ${device}
      END
    END


sdwan baseline validate control connections are up as per defined baseline on iosxe
    [Arguments]  ${device}
    # IF  "${device}" not in "${BASELINE_CONTROL_CONNECTIONS.keys()}"
    #   utility set test comment  [SKIP] Control connections check: ${device} : Skip check, no baseline defined
    #   Return From Keyword
    # END

    ## Fetch the number of vsmarts
    ${vsmart_count}=  Set Variable    0
    FOR  ${i}  IN  @{NODES_SDWAN_DETAILS.keys()}
        IF  '${NODES_SDWAN_DETAILS['${i}']['role']}' == 'vsmart'
            ${vsmart_count}=  Evaluate    ${vsmart_count}+1
        END
    END
    ${parsed_output}=  run parsed "show sdwan control connections" with template "${XE_SDWAN_SHOW_SDWAN_CONTROL_CONNECTIONS_TEMPLATE}"
    ${device_type_to_be_tested}=  Set Variable    ${NODES_SDWAN_DETAILS['${device}']['role']}
    FOR  ${dev}  IN  @{NODES_SDWAN_DETAILS.keys()}
        Continue For Loop If    '${NODES_SDWAN_DETAILS['${dev}']['role']}' == '${device_type_to_be_tested}'
        ##Testing on edge
        IF  '${device_type_to_be_tested}' == 'edge'
            IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vmanage'
                FOR  ${output}  IN  @{parsed_output}
                    IF  '${output['peer_type']}' == 'vmanage'
                        IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${dev}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${dev}']['site_id']}'
                            baseline set test pass  [PASS] Control connections to vManage check: Device ${device} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to vManage(${output['peer_system_ip']}) is up
                        ELSE
                            baseline set test fail  [FAIL] Control connections to vManage check: Device ${device} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to vManage(${output['peer_system_ip']}) is either down or site-id or system-ip is incorrect, actual state: ${output['state']}
                        END
                    END
                END
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vsmart'
                FOR  ${count}  IN RANGE  ${vsmart_count}
                    ${vsmart_not_present_flag}=  Set Variable    ${False}
                    FOR  ${output}  IN  @{parsed_output}
                        IF  '${output['peer_type']}' == 'vsmart'
                            FOR  ${color}  IN  @{NODES_SDWAN_COLOR['${device}'].keys()}
                              IF  ${NODES_SDWAN_COLOR['${device}']['${color}']['max-control-connections']} != 0
                                  IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${dev}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${dev}']['site_id']}' and '${output['local_color']}' == '${color}'
                                      baseline set test pass  [PASS] Control connections to vSmart check: Device ${device} : Peer Site ID ${output['peer_site_id']} : Color ${color} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${dev}']['system_ip']} : Control connections to vSmart(${output['peer_system_ip']}) is up over the transport ${color}
                                      ${vsmart_not_present_flag}=  Set Variable    ${True}
                                  END
                              ELSE
                                  utility set test comment  [SKIP] Control connection to vSmart(${NODES_SDWAN_DETAILS['${dev}']['system_ip']}) for the transport, ${color}, will be skipped as max-control-connections is set as 0.
                              END
                            END
                        END
                    END
                    IF  ${vsmart_not_present_flag} == ${False}
                        baseline set test fail  [FAIL] Control connections to vSmart check: Device ${device} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${dev}']['system_ip']} : Control connections to vSmart(${output['peer_system_ip']}) is down, actual state: ${output['state']}
                    END
                END
            END
        END
    END


sdwan baseline validate control connections are up as per defined baseline on viptelaOS
    [Arguments]  ${device}
    # IF  "${device}" not in "${BASELINE_CONTROL_CONNECTIONS.keys()}"
    #   utility set test comment  [SKIP] Control connections check: ${device} : Skip check, no baseline defined
    #   Return From Keyword
    # END

    FOR  ${dev}  IN  @{NODES_SDWAN_DETAILS.keys()}
        ${device_type_to_be_tested}=  Set Variable    ${NODES_SDWAN_DETAILS['${device}']['role']}
        ##Testing on edge
        IF  '${device_type_to_be_tested}' == 'edge'
            Continue For Loop If    '${NODES_SDWAN_DETAILS['${dev}']['role']}' == '${device_type_to_be_tested}'
            IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vmanage'
                sdwan baseline validate control connections to vmanage on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vsmart'
                sdwan baseline validate control connections to vsmart on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            END
        ##Testing on vManage
        ELSE IF  '${device_type_to_be_tested}' == 'vmanage'
            Continue For Loop If    '${NODES_SDWAN_DETAILS['${dev}']['role']}' == '${device_type_to_be_tested}'
            IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vsmart'
                sdwan baseline validate control connections to vsmart on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vbond'
                sdwan baseline validate control connections to vbond on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'edge'
                sdwan baseline validate control connections to edge device on viptelaOS    DUT=${device}    device_to_be_checked_in_the_output=${dev}
            END
        ##Testing on vSmart
        ELSE IF  '${device_type_to_be_tested}' == 'vsmart'
            IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vmanage'
                sdwan baseline validate control connections to vmanage on viptelaOS   DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vbond'
                sdwan baseline validate control connections to vbond on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vsmart'
                sdwan baseline validate control connections to vsmart on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'edge'
                sdwan baseline validate control connections to edge device on viptelaOS    DUT=${device}    device_to_be_checked_in_the_output=${dev}
            END
        ##Testing on vBond
        ELSE IF  '${device_type_to_be_tested}' == 'vbond'
            Continue For Loop If    '${NODES_SDWAN_DETAILS['${dev}']['role']}' == '${device_type_to_be_tested}'
            IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vmanage'
                sdwan baseline validate control connections to vmanage on viptelaOS   DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            ELSE IF  '${NODES_SDWAN_DETAILS['${dev}']['role']}' == 'vsmart'
                sdwan baseline validate control connections to vsmart on viptelaOS    DUT=${device}    DUT_device_type=${device_type_to_be_tested}    device_to_be_checked_in_the_output=${dev}
            END
        END
    END


sdwan baseline validate control connections to edge device on viptelaOS
    [Arguments]  ${DUT}  ${device_to_be_checked_in_the_output}

    ${parsed_output}=  run parsed "show control connections" with template "${VIPTELA_SDWAN_SHOW_CONTROL_CONNECTIONS_TEMPLATE}"
    Log  ${parsed_output}  formatter=repr
    # Fetch the System IPs of all the edges from the show sdwan control connections
    ${edge_system_ip_state_dict}=  Create Dictionary
    ${edge_system_ip_lst}=  Create List
    ${edge_device_status_flag}=  Set Variable    ${False}
    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['peer_type']}' == 'vedge'
            Set To Dictionary    ${edge_system_ip_state_dict}   ${output['peer_system_ip']}=${output['state']}
            Append To List    ${edge_system_ip_lst}    ${output['peer_system_ip']}
        END
    END
    Log  ${edge_system_ip_state_dict}  formatter=repr

    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['peer_type']}' == 'vedge'
            IF  '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['role']}' == 'edge'
                IF  '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' == '${output['peer_system_ip']}' and '${output['state']}' == 'up' and '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}' == '${output['peer_site_id']}'
                    ${edge_device_status_flag}=  Set Variable    ${True}
                    Exit For Loop
                END
            END
        END
    END
    IF  ${edge_device_status_flag} == ${True}
        baseline set test pass  [PASS] Control connections to Edge device check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to Edge device(${output['peer_system_ip']}) is up
    ELSE
        baseline set test fail  [FAIL] Control connections to Edge device: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to Edge device(${output['peer_system_ip']}) is either down or the site-id or system-ip is incorrect, actual state: ${output['state']}
    END

sdwan baseline validate control connections to vmanage on viptelaOS
    [Arguments]  ${DUT}  ${DUT_device_type}  ${device_to_be_checked_in_the_output}
    Log  ${device_to_be_checked_in_the_output}
    IF  '${DUT_device_type}' == 'vbond'
        ${parsed_output}=  run parsed "show orchestrator connections" with template "${VIPTELA_SDWAN_SHOW_ORCHESTRATOR_CONNECTIONS_TEMPLATE}"
    ELSE
        ${parsed_output}=  run parsed "show control connections" with template "${VIPTELA_SDWAN_SHOW_CONTROL_CONNECTIONS_TEMPLATE}"
    END
    Log  ${parsed_output}  formatter=repr
    IF  '${DUT_device_type}' == 'vbond'
        Log  ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['role']}
        IF  '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['role']}' == 'vmanage'
            ${cpu_cores}=  Set Variable    ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['cpu_cores']}
        END
        ${vmanage_actual_count}=  Set Variable    0
    END
    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['peer_type']}' == 'vmanage'
            IF  '${DUT_device_type}' == 'vbond'
                IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}'
                    ${vmanage_actual_count}=  Evaluate    ${vmanage_actual_count}+1
                END
            ELSE
                IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}'
                    baseline set test pass  [PASS] Control connections to vManage check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to vManage(${output['peer_system_ip']}) is up
                ELSE
                    baseline set test fail  [FAIL] Control connections to vManage check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${output['peer_system_ip']} : Control connections to vManage(${output['peer_system_ip']}) is either down or site-id or system-ip is incorrect, actual state: ${output['state']}
                END
            END
        END
    END
    IF  '${DUT_device_type}' == 'vbond'
        IF  ${vmanage_actual_count} == ${cpu_cores}
            baseline set test pass  [PASS] Control connections to vManage check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Expected Control connections count to vManage is ${cpu_cores} : ${vmanage_actual_count} control connections to vManage(${output['peer_system_ip']}) are up
        ELSE
            baseline set test fail  [FAIL] Control connections to vManage check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Only ${vmanage_actual_count} control connections to vManage(${output['peer_system_ip']}) are up : Expected Control connections count to vManage is ${cpu_cores}
        END
    END



sdwan baseline validate control connections to vsmart on viptelaOS
    [Arguments]  ${DUT}  ${DUT_device_type}  ${device_to_be_checked_in_the_output}
    ## Fetch the number of vsmarts
    ${vsmart_count}=  Set Variable    0
    ${vsmart_nodes}=  Create List
    FOR  ${i}  IN  @{NODES_SDWAN_DETAILS.keys()}
        IF  '${NODES_SDWAN_DETAILS['${i}']['role']}' == 'vsmart'
            ${vsmart_count}=  Evaluate    ${vsmart_count}+1
            Append To List    ${vsmart_nodes}    ${i}
        END
    END
    IF  '${DUT_device_type}' == 'vbond'
        ${parsed_output}=  run parsed "show orchestrator connections" with template "${VIPTELA_SDWAN_SHOW_ORCHESTRATOR_CONNECTIONS_TEMPLATE}"
    ELSE
        ${parsed_output}=  run parsed "show control connections" with template "${VIPTELA_SDWAN_SHOW_CONTROL_CONNECTIONS_TEMPLATE}"
    END
    Log  ${parsed_output}  formatter=repr
    IF  '${DUT_device_type}' == 'vbond'
        Log  ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['role']}
        IF  '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['role']}' == 'vsmart'
            ${cpu_cores}=  Set Variable    ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['cpu_cores']}
        END
        ${vsmart_actual_count}=  Set Variable    0
    END
    IF  '${DUT_device_type}' == 'vsmart'
        ${vsmart_not_present_flag}=  Set Variable    ${False}
        ${vsmart_count_except_this}=  Evaluate    ${vsmart_count}-1
    END
    ${status}=  Run Keyword And Return Status    Variable Should Exist    ${vsmart_count_except_this}
    IF  ${status} == ${True}
        IF  ${vsmart_count_except_this} == 0
            utility set test comment  [SKIP] There is only one vSmart in the overlay fabric, hence skipping this step
        END
    ELSE
        IF  '${DUT_device_type}' == 'vbond'
            FOR  ${output}  IN  @{parsed_output}
                IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}'
                    ${vsmart_actual_count}=  Evaluate    ${vsmart_actual_count}+1
                END
            END
            IF  ${vsmart_actual_count} == ${cpu_cores}
                baseline set test pass  [PASS] Control connections to vSmart check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Expected Control connections count to vSmart is ${cpu_cores} : ${vsmart_actual_count} control connections to vSmart(${output['peer_system_ip']}) are up
            ELSE
                baseline set test fail  [FAIL] Control connections to vSmart check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Only ${vsmart_actual_count} control connections to vSmart(${output['peer_system_ip']}) are up : Expected Control connections count to vSmart is ${cpu_cores}
            END
        ELSE
            FOR  ${count}  IN RANGE  ${vsmart_count}
                ${vsmart_not_present_flag}=  Set Variable    ${False}
                FOR  ${output}  IN  @{parsed_output}
                    IF  '${DUT_device_type}' == 'vsmart'
                        Continue For Loop If    '${device_to_be_checked_in_the_output}' == '${DUT}'
                    END
                    IF  '${output['peer_type']}' == 'vsmart'
                        IF  '${NODES_SDWAN_DETAILS['${DUT}']['role']}' == 'edge'
                            FOR  ${color}  IN  @{NODES_SDWAN_COLOR['${DUT}'].keys()}
                              IF  ${NODES_SDWAN_COLOR['${DUT}']['${color}']['max-control-connections']} != 0
                                  IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}' and '${output['remote_color']}' == '${color}'
                                      baseline set test pass  [PASS] Control connections to vSmart check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Color ${color} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Control connections to vSmart(${output['peer_system_ip']}) is up over the transport ${color}
                                      ${vsmart_not_present_flag}=  Set Variable    ${True}
                                  END
                              ELSE
                                  utility set test comment  [SKIP] Control connection to vSmart(${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}) for the transport, ${color}, will be skipped as max-control-connections is set as 0.
                              END
                            END
                        ELSE
                            IF  '${output['peer_system_ip']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']}' and '${output['state']}' == 'up' and '${output['peer_site_id']}' == '${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['site_id']}'
                                baseline set test pass  [PASS] Control connections to vSmart check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Control connections to vSmart(${output['peer_system_ip']}) is up
                                ${vsmart_not_present_flag}=  Set Variable    ${True}
                            END
                        END
                    END
                END
                IF  ${vsmart_not_present_flag} == ${False}
                    baseline set test fail  [FAIL] Control connections to vSmart check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Control connections to vSmart(${output['peer_system_ip']}) is down is either down or site-id or system-ip is incorrect, actual state: ${output['state']}
                END
            END
        END
    END



sdwan baseline validate control connections to vbond on viptelaOS
    [Arguments]  ${DUT}  ${DUT_device_type}  ${device_to_be_checked_in_the_output}
    IF  '${DUT_device_type}' == 'vbond'
        ${parsed_output}=  run parsed "show orchestrator connections" with template "${VIPTELA_SDWAN_SHOW_ORCHESTRATOR_CONNECTIONS_TEMPLATE}"
    ELSE
        ${parsed_output}=  run parsed "show control connections" with template "${VIPTELA_SDWAN_SHOW_CONTROL_CONNECTIONS_TEMPLATE}"
    END
    Log  ${parsed_output}  formatter=repr
    ${cpu_cores}=  Set Variable    ${NODES_SDWAN_DETAILS['${DUT}']['cpu_cores']}
    ${vbond_actual_count}=  Set Variable  0
    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['peer_type']}' == 'vbond'
            IF  '${output['state']}' == 'up'
                ${vbond_actual_count}=  Evaluate    ${vbond_actual_count}+1
            END
        END
    END

    IF  ${vbond_actual_count} == ${cpu_cores}
        baseline set test pass  [PASS] Control connections to vBond check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Expected Control connections count to vBond is ${cpu_cores} : ${vbond_actual_count} control connections to vBond(${output['peer_system_ip']}) are up
    ELSE
        baseline set test fail  [FAIL] Control connections to vBond check: Device ${DUT} : Peer Site ID ${output['peer_site_id']} : Expected neighbor(System IP) ${NODES_SDWAN_DETAILS['${device_to_be_checked_in_the_output}']['system_ip']} : Only ${vbond_actual_count} control connections to vBond(${output['peer_system_ip']}) are up : Expected Control connections count to vBond is ${cpu_cores}
    END
