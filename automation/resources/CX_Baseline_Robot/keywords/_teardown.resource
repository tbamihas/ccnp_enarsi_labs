*** Settings ***
Resource    ../cx_baseline_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# baseline teardown with no checks
# baseline teardown with checks for selected devices
# baseline teardown with cpu memory and logs for selected devices
#
################################################################################


baseline teardown with no checks
    [Documentation]  Run this keyword to finish your test in the teardown phase. Does not include any baseline checks.
    ...              Adds a comment to the text file report saying if the test passed or failed (based on built in robot variable 'TEST STATUS' and runs the 'disconnect from all devices' keyword.
    ...
    ...              Examples:
    ...              baseline teardown with no checks
    baseline set test title  End of Test
    IF  "${TEST STATUS}" == "PASS"
      baseline set test comment  [PASS] Test case passed
    ELSE
      baseline set test comment  [FAIL] Test case failed
    END
    disconnect from all devices


baseline teardown with checks for selected devices
    [Documentation]  Run this keyword to finish your test in the teardown phase. Includes running baseline checks on the selected devices.
    ...              Can pass the 'devices' argument as either a list variable or a semi-colon ; or comma , separated string variable
    ...              By default will use the path defined in global/suite variable 'TB_YAML'. Otherwise you will need to pass the argument.
    ...
    ...              Examples:
    ...              Set Suite Variable  ${TB_YAML}  data/topology/topology_file.yaml
    ...              baseline teardown with checks for selected devices  devices=ROUTER_A;ROUTER_B
    ...              baseline teardown with checks for selected devices  devices=ROUTER_A;ROUTER_B
    ...              ${device_list}=  Create List  ROUTER_A  ROUTER_B
    ...              baseline teardown with checks for selected devices  devices=${device_list}
    [Arguments]  ${devices}
    baseline set test title  End of Test
    ${status}=    Set Variable If    "${TEST STATUS}" == "PASS"    ${True}    ${False}
    IF  "${TEST STATUS}" == "PASS"
      baseline set test comment  [PASS] Test case passed
    ELSE
      baseline set test comment  [FAIL] Test case failed
    END
    ${devices_type}=  Evaluate  type($devices).__name__
    IF  "${devices_type}" != "list"
      ${NODES_TO_CHECK}=  Replace String  ${devices}  ,  ;
      ${NODES_TO_CHECK}=  Split String  ${NODES_TO_CHECK}  ;
    ELSE
      ${NODES_TO_CHECK}=  Set Variable  ${devices}
    END
    baseline checks end of test  NODES_TO_CHECK=${NODES_TO_CHECK}
    disconnect from all devices


baseline teardown with cpu memory and logs for selected devices
    [Documentation]  Run this keyword to finish your test in the teardown phase. Includes cpu, memory and logs related checks only on the selected devices.
    ...              Can pass the 'devices' argument as either a list variable or a semi-colon ; or comma , separated string variable
    ...              By default will use the path defined in global/suite variable 'TB_YAML'. Otherwise you will need to pass the argument.
    ...
    ...              Examples:
    ...              Set Suite Variable  ${TB_YAML}  data/topology/topology_file.yaml
    ...              baseline teardown with cpu memory and logs for selected devices  devices=ROUTER_A;ROUTER_B
    ...              baseline teardown with cpu memory and logs for selected devices  devices=ROUTER_A;ROUTER_B
    ...              ${device_list}=  Create List  ROUTER_A  ROUTER_B
    ...              baseline teardown with cpu memory and logs for selected devices  devices=${device_list}
    [Arguments]  ${devices}
    baseline set test title  End of Test
    ${status}=    Set Variable If    "${TEST STATUS}" == "PASS"    ${True}    ${False}
    IF  "${TEST STATUS}" == "PASS"
      baseline set test comment  [PASS] Test case passed
    ELSE
      baseline set test comment  [FAIL] Test case failed
    END
    ${devices_type}=  Evaluate  type($devices).__name__
    IF  "${devices_type}" != "list"
      ${NODES_TO_CHECK}=  Replace String  ${devices}  ,  ;
      ${NODES_TO_CHECK}=  Split String  ${NODES_TO_CHECK}  ;
    ELSE
      ${NODES_TO_CHECK}=  Set Variable  ${devices}
    END
    baseline cpu memory log checks end of test  NODES_TO_CHECK=${NODES_TO_CHECK}
    disconnect from all devices
