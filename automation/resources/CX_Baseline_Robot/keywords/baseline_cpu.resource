*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#
#
#     Keywords in this file
#
# baseline cpu validate recent cpu usage is reasonable
#
#
#
################################################################################

*** Keywords ***
######################  CPU usage check #######################

baseline cpu validate recent cpu usage is reasonable
    [Documentation]  Checks the recent CPU usage on the device.
    ...              If the CPU usage is above 80%, then a failure is raised.
    ...              If the CPU usage is between 40-80%, then a warning is raised.
    ...              If the CPU usage is less than 40%, then the check is passed.
    ...
    ...              Example:
    ...              baseline cpu validate recent cpu usage is reasonable
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate cpu usage
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline cpu cxr validate recent cpu usage is reasonable  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline cpu exr validate recent cpu usage is reasonable  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline cpu iosxe validate recent cpu usage is reasonable  ${device}
        #baseline set test comment  [SKIP] CPU usage check: ${device} : Skip check, CPU usage checks are currently not available on IOS XE or IOS devices
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline cpu nxos validate recent cpu usage is reasonable  ${device}
        #baseline set test comment  [SKIP] CPU usage check: ${device} : Skip check, CPU usage checks are currently not available on NXOS devices
      END
    END

baseline cpu cxr validate recent cpu usage is reasonable
    [Documentation]  Child keyword for 'baseline cpu validate recent cpu usage is reasonable'.
    [Arguments]  ${device}
    ${output}=  run parsed "admin show platform"
    FOR  ${item}  IN  @{output}
      Continue For Loop If  "RUN" not in "${item}[SWState]"
      Continue For Loop If  "/CPU0" not in "${item}[Node]"
      run "show processes cpu location ${item}[Node] | exclude 0%${SPACE * 6}0%${SPACE * 7}0%"
      ${five_min_cpu}=  extract pattern "five minutes: (\\d+)"
      IF  ${five_min_cpu} < 40
        baseline set test pass  [PASS] Five minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      ELSE IF  ${five_min_cpu} >= 40 and ${five_min_cpu} <= 80
        baseline set test warn  [WARN] Five minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      ELSE
        baseline set test fail  [FAIL] Five minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      END
      ${fifteen_min_cpu}=  extract pattern "fifteen minutes: (\\d+)"
      IF  ${fifteen_min_cpu} < 40
        baseline set test pass  [PASS] Fifteen minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      ELSE IF  ${fifteen_min_cpu} >= 40 and ${fifteen_min_cpu} <= 80
        baseline set test warn  [WARN] Fifteen minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      ELSE
        baseline set test fail  [FAIL] Fifteen minute CPU usage percentage check: ${device} , ${item}[Node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      END
    END



baseline cpu exr validate recent cpu usage is reasonable
    [Documentation]  Child keyword for 'baseline cpu validate recent cpu usage is reasonable'.
    [Arguments]  ${device}
    ${output}=  run parsed "show platform"
    FOR  ${item}  IN  @{output}
      Continue For Loop If  "RUN" not in "${item}[node_state]"
      run "show processes cpu location ${item}[node] | exclude 0%${SPACE * 6}0%${SPACE * 7}0%"
      ${five_min_cpu}=  extract pattern "five minutes: (\\d+)"
      IF  ${five_min_cpu} < 40
        baseline set test pass  [PASS] Five minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      ELSE IF  ${five_min_cpu} >= 40 and ${five_min_cpu} <= 80
        baseline set test warn  [WARN] Five minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      ELSE
        baseline set test fail  [FAIL] Five minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}
      END
      ${fifteen_min_cpu}=  extract pattern "fifteen minutes: (\\d+)"
      IF  ${fifteen_min_cpu} < 40
        baseline set test pass  [PASS] Fifteen minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      ELSE IF  ${fifteen_min_cpu} >= 40 and ${fifteen_min_cpu} <= 80
        baseline set test warn  [WARN] Fifteen minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      ELSE
        baseline set test fail  [FAIL] Fifteen minute CPU usage percentage check: ${device} , ${item}[node] : Expected maximum value 40 (warn if between 40-80) : Actual value: ${fifteen_min_cpu}
      END
    END


baseline cpu iosxe validate recent cpu usage is reasonable
    [Documentation]  Child keyword for 'baseline cpu validate recent cpu usage is reasonable'.
    [Arguments]  ${device}
    run "show processes cpu | exclude 0.00%${SPACE * 2}0.00%${SPACE * 2}0.00%"
    ${one_min_cpu}=  extract patterns "one minute: (\\d+)"
    IF  ${one_min_cpu}[-1] < 40
      baseline set test pass  [PASS] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    ELSE IF  ${one_min_cpu}[-1] >= 40 and ${one_min_cpu}[-1] <= 80
      baseline set test warn  [WARN] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    ELSE
      baseline set test fail  [FAIL] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    END
    ${five_min_cpu}=  extract patterns "five minutes: (\\d+)"
    IF  ${five_min_cpu}[-1] < 40
      baseline set test pass  [PASS] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    ELSE IF  ${five_min_cpu}[-1] >= 40 and ${five_min_cpu}[-1] <= 80
      baseline set test warn  [WARN] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    ELSE
      baseline set test fail  [FAIL] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    END

baseline cpu nxos validate recent cpu usage is reasonable
    [Documentation]  Child keyword for 'baseline cpu validate recent cpu usage is reasonable'.
    [Arguments]  ${device}
    run "show processes cpu sort | exclude 0.00%"
    ${one_min_cpu}=  extract patterns "one minute: (\\d+)"
    IF  ${one_min_cpu}[-1] < 40
      baseline set test pass  [PASS] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    ELSE IF  ${one_min_cpu}[-1] >= 40 and ${one_min_cpu}[-1] <= 80
      baseline set test warn  [WARN] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    ELSE
      baseline set test fail  [FAIL] One minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${one_min_cpu}[-1]
    END
    ${five_min_cpu}=  extract patterns "five minutes: (\\d+)"
    IF  ${five_min_cpu}[-1] < 40
      baseline set test pass  [PASS] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    ELSE IF  ${five_min_cpu}[-1] >= 40 and ${five_min_cpu}[-1] <= 80
      baseline set test warn  [WARN] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    ELSE
      baseline set test fail  [FAIL] Five minute CPU usage percentage check: ${device} : Expected maximum value 40 (warn if between 40-80) : Actual value: ${five_min_cpu}[-1]
    END
