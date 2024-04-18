*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#
#
#     Keywords in this file
#
# baseline memory collect memory commands
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  Memory  #######################

baseline memory collect memory commands
    [Documentation]  Run the 'show memory' type commands. No automated checks performed on these.
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate memory usage (automated checks only on XR)
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline memory cxr collect memory commands  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline memory exr collect memory commands  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        baseline memory iosxe collect memory commands  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        baseline memory ios collect memory commands  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] Collect memory commands: ${device} : Skip, memory checks are currently not available on NXOS devices
      END
    END

baseline memory cxr collect memory commands
    [Documentation]  Child keyword for 'baseline memory collect memory commands'.
    [Arguments]  ${device}
    baseline set test comment  [INFO] Memory commands collected on device: ${device} :
    ${output}=  run parsed "admin show platform"
    FOR  ${item}  IN  @{output}
      Continue For Loop If  "RUN" not in "${item}[SWState]"
      Continue For Loop If  "/CPU0" not in "${item}[Node]"
      run "show memory summary location ${item}[Node]"
      run "show watchdog memory-state location ${item}[Node]"
      ${memory_state}=  extract pattern "Memory State\\s+:\\s+(\\S+)"
      IF  "${memory_state}" == "Normal"
        baseline set test pass  [PASS] Watchdog memory state is Normal: ${device} , ${item}[Node]
      ELSE
        baseline set test fail  [FAIL] Watchdog memory state is not Normal: ${device} , ${item}[Node]
      END
    END



baseline memory exr collect memory commands
    [Documentation]  Child keyword for 'baseline memory collect memory commands'.
    [Arguments]  ${device}
    baseline set test comment  [INFO] Memory commands collected on device: ${device} :
    ${output}=  run parsed "show platform"
    FOR  ${item}  IN  @{output}
      Continue For Loop If  "RUN" not in "${item}[node_state]"
      run "show memory summary location ${item}[node]"
      run "show watchdog memory-state location ${item}[node]"
      ${memory_state}=  extract pattern "Memory State\\s+:\\s+(\\S+)"
      IF  "${memory_state}" == "Normal"
        baseline set test pass  [PASS] Watchdog memory state is Normal: ${device} , ${item}[node]
      ELSE
        baseline set test fail  [FAIL] Watchdog memory state is not Normal: ${device} , ${item}[node]
      END
    END


baseline memory iosxe collect memory commands
    [Documentation]  Child keyword for 'baseline memory collect memory commands'.
    [Arguments]  ${device}
    baseline set test comment  [INFO] Memory commands collected on device: ${device} :
    run "show platform software status control-processor brief"
    run "show memory statistics"


baseline memory ios collect memory commands
    [Documentation]  Child keyword for 'baseline memory collect memory commands'.
    [Arguments]  ${device}
    baseline set test comment  [INFO] Memory commands collected on device: ${device} :
    run "show memory statistics"
