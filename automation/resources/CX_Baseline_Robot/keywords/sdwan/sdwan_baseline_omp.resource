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
# sdwan baseline validate omp peers are up as per defined baseline
#
################################################################################

*** Keywords ***
######################  BGP  #######################

sdwan baseline validate omp peers are up as per defined baseline
    [Documentation]   This keyword validates if the omp peers are up towards the vsmart devices.
    ...               Create the required variables in common.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate omp peers are up as per defined baseline NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate omp peers are up as per defined baseline
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      Continue For Loop IF  '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'edge' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vsmart'
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate omp peers are up as per defined baseline on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate omp peers are up as per defined baseline on viptelaOS  ${device}
      END
    END


sdwan baseline validate omp peers are up as per defined baseline on iosxe
    [Arguments]  ${device}
    # IF  "${device}" not in "${BASELINE_CONTROL_CONNECTIONS.keys()}"
    #   utility set test comment  [SKIP] Control connections check: ${device} : Skip check, no baseline defined
    #   Return From Keyword
    # END

    # Fetch the device type to be tested on
    ${device_type_to_be_tested}=  Set Variable    ${NODES_SDWAN_DETAILS['${device}']['role']}

    ## Fetch the number of vsmarts in the fabric
    ${total_vsmart_count}=  Set Variable    0
    ${total_vsmart_list}=  Create List
    FOR  ${i}  IN  @{NODES_SDWAN_DETAILS.keys()}
        IF  '${NODES_SDWAN_DETAILS['${i}']['role']}' == 'vsmart'
            ${total_vsmart_count}=  Evaluate    ${total_vsmart_count}+1
            Append To List    ${total_vsmart_list}    ${NODES_SDWAN_DETAILS['${i}']['system_ip']}
        END
    END
    ###
    ## Fetch the "max omp session" value configured from the DUT
    run "show sdwan running-config system"
    ${status}=  Run Keyword And Return Status    output contains "max-omp-sessions"
    IF  ${status} == ${True}
        ${max_omp_sessions}=  extract pattern "max-omp-sessions (\\d+)"
    ELSE
        ${max_omp_sessions}=  Set Variable    2
    END
    ####
    #Fetch the parsed output of show sdwan omp peers d
    ${parsed_output}=  run parsed "show sdwan omp peers" with template "${XE_SDWAN_SHOW_SDWAN_OMP_PEERS_TEMPLATE}"
    ${vsmart_iteration}=  Set Variable    0
    FOR  ${output}  IN  @{parsed_output}
        Exit For Loop IF  ${vsmart_iteration} == ${max_omp_sessions}
        IF  '${output['peer_address']}' in ${total_vsmart_list} and '${output['state']}' == 'up'
            utility set test pass  [PASS] OMP session to vSmart Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : OMP session to vSmart(${output['peer_address']}) is up
        ELSE
            baseline set test fail  [FAIL] OMP session to vSmart Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : Either the OMP session to vSmart(${output['peer_address']}) is down or the vSmart peer is incorrect
        END
        ${vsmart_iteration}=  Evaluate    ${vsmart_iteration}+1
    END
    ${dev_omp_session_count}=  Get Length    ${parsed_output}
    IF  ${dev_omp_session_count} > ${max_omp_sessions}
        baseline set test fail  [FAIL] The Device ${device} has more OMP sessions(${dev_omp_session_count}) than it is expected to have(${max_omp_sessions})
    END


sdwan baseline validate omp peers are up as per defined baseline on viptelaOS
    [Arguments]  ${device}
    # IF  "${device}" not in "${BASELINE_CONTROL_CONNECTIONS.keys()}"
    #   utility set test comment  [SKIP] Control connections check: ${device} : Skip check, no baseline defined
    #   Return From Keyword
    # END

    # Fetch the device type to be tested on
    ${device_type_to_be_tested}=  Set Variable    ${NODES_SDWAN_DETAILS['${device}']['role']}

    ## Fetch the number of vsmarts in the fabric
    ${total_vsmart_count}=  Set Variable    0
    ${total_vsmart_list}=  Create List
    FOR  ${i}  IN  @{NODES_SDWAN_DETAILS.keys()}
        IF  '${NODES_SDWAN_DETAILS['${i}']['role']}' == 'vsmart'
            ${total_vsmart_count}=  Evaluate    ${total_vsmart_count}+1
            Append To List    ${total_vsmart_list}    ${NODES_SDWAN_DETAILS['${i}']['system_ip']}
        END
    END

    ${parsed_output}=  run parsed "show omp peers" with template "${XE_SDWAN_SHOW_SDWAN_OMP_PEERS_TEMPLATE}"
    ###
    IF  '${device_type_to_be_tested}' == 'edge'
        ## Fetch the "max omp session" value configured from the DUT
        run "show sdwan running-config system"
        ${status}=  Run Keyword And Return Status    output contains "max-omp-sessions"
        IF  ${status} == ${True}
            ${max_omp_sessions}=  extract pattern "max-omp-sessions (\\d+)"
        ELSE
            ${max_omp_sessions}=  Set Variable    2
        END
        ####
        #Fetch the parsed output of show omp peers
        ${vsmart_iteration}=  Set Variable    0
        FOR  ${output}  IN  @{parsed_output}
            Exit For Loop IF  ${vsmart_iteration} == ${max_omp_sessions}
            IF  '${output['peer_address']}' in ${total_vsmart_list} and '${output['state']}' == 'up'
                utility set test pass  [PASS] OMP session to vSmart Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : OMP session to vSmart(${output['peer_address']}) is up
            ELSE
                baseline set test fail  [FAIL] OMP session to vSmart Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : Either the OMP session to vSmart(${output['peer_address']}) is down or the vSmart peer is incorrect
            END
            ${vsmart_iteration}=  Evaluate    ${vsmart_iteration}+1
        END
        ${dev_omp_session_count}=  Get Length    ${parsed_output}
        IF  ${dev_omp_session_count} > ${max_omp_sessions}
            baseline set test fail  [FAIL] The Device ${device} has more OMP sessions(${dev_omp_session_count}) than it is expected to have(${max_omp_sessions})
        END
    ELSE IF  '${device_type_to_be_tested}' == 'vsmart'
      ## Fetch total number of edges in the fabric
      ${total_edge_count}=  Set Variable    0
      ${total_edge_list}=  Create List
      FOR  ${i}  IN  @{NODES_SDWAN_DETAILS.keys()}
          IF  '${NODES_SDWAN_DETAILS['${i}']['role']}' == 'edge'
              ${total_edge_count}=  Evaluate    ${total_edge_count}+1
              Append To List    ${total_edge_list}    ${NODES_SDWAN_DETAILS['${i}']['system_ip']}
          END
      END
      FOR  ${output}  IN  @{parsed_output}
          IF  '${output['peer_address']}' in ${total_edge_list} and '${output['state']}' == 'up'
              utility set test pass  [PASS] OMP session to Edge device Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : OMP session to Edge device(${output['peer_address']}) is up
          ELSE
              baseline set test fail  [FAIL] OMP session to Edge Check: Device ${device} : Expected Peer(System IP) ${output['peer_address']} : Either the OMP session to Edge device(${output['peer_address']}) is down or the peer Edge device is incorrect
          END
      END
    END
