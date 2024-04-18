*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_hardware.yaml
#
#
#     Keywords in this file
#
# baseline hardware validate correct hardware platform as per defined baseline
# baseline hardware validate correct hardware modules are up as per defined baseline
# baseline hardware validate correct inventory output as per defined baseline
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  Hardware platform checks #######################

baseline hardware validate correct hardware platform as per defined baseline
    [Documentation]  Create the variable BASELINE_HW_PLATFORM in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_HW_PLATFORM:
    ...                ROUTER_A: WS-C6506-E
    ...                ROUTER_B: ASR-9010-AC-V2
    ...
    ...              baseline hardware validate correct hardware platform as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct hardware platform as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_HW_PLATFORM}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for hardware platform check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline hardware iosxr validate correct hardware platform as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline hardware ios validate correct hardware platform as per defined baseline  ${device}
      END
    END

baseline hardware iosxr validate correct hardware platform as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware platform as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_PLATFORM.keys()}"
      baseline set test comment  [SKIP] Hardware platform check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "admin show inventory chassis"
    ${IS_NCS}=  Run Keyword And Return Status  output contains "Admin mode has been deprecated"
    IF  ${IS_NCS}
      run "show inventory chassis"
    END
    ${expected_value}=  Set Variable  ${BASELINE_HW_PLATFORM['${device}']}
    ${actual_value}=  extract patterns "PID: ([\\w\\-]+)"
    IF  "${expected_value}" == "${actual_value[0]}"
      baseline set test pass  [PASS] Hardware platform check: ${device} : Expected value: ${expected_value} : Actual value: ${actual_value[0]}
    ELSE
      baseline set test fail  [FAIL] Hardware platform check: ${device} : Expected value: ${expected_value} : Actual value: ${actual_value[0]}
    END

baseline hardware ios validate correct hardware platform as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware platform as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_PLATFORM.keys()}"
      baseline set test comment  [SKIP] Hardware platform check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show inventory"
    ${expected_value}=  Set Variable  ${BASELINE_HW_PLATFORM['${device}']}
    ${actual_value}=  extract patterns "PID: ([\\w\\-]+)"
    IF  "${expected_value}" == "${actual_value[0]}"
      baseline set test pass  [PASS] Hardware platform check: ${device} : Expected value: ${expected_value} : Actual value: ${actual_value[0]}
    ELSE
      baseline set test fail  [FAIL] Hardware platform check: ${device} : Expected value: ${expected_value} : Actual value: ${actual_value[0]}
    END






######################  Hardware modules checks #######################


baseline hardware validate correct hardware modules are up as per defined baseline
    [Documentation]  Create the variable BASELINE_HW_MODULES in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_HW_MODULES:
    ...                PE4:
    ...                  0/RSP0/CPU0: A9K-RSP880-SE
    ...                  0/RSP1/CPU0: A9K-RSP880-SE
    ...                  0/FT0/SP: ASR-9010-FAN-V2
    ...                  0/FT1/SP: ASR-9010-FAN-V2
    ...                  0/1/CPU0: A9K-8X100GE-TR
    ...
    ...              baseline hardware validate correct hardware modules are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct hardware modules are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_HW_MODULES}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for hardware modules check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline hardware cxr validate correct hardware modules are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline hardware exr validate correct hardware modules are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        baseline hardware iosxe validate correct hardware modules are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline hardware nxos validate correct hardware modules are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, Hardware module checks are currently not available on IOS devices
      END
    END

baseline hardware cxr validate correct hardware modules are up as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware modules are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_MODULES.keys()}"
      baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run parsed "admin show platform"
    ${expected_values}=  Get Dictionary Items  ${BASELINE_HW_MODULES['${device}']}
    ${actual_nodes}=  get parsed "Node"
    FOR  ${expected_node}  ${expected_value}  IN  @{expected_values}
      IF  "${expected_node}" not in "${actual_nodes}"
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Expected hardware module node: ${expected_node} : Not found in output.
        Continue For Loop
      END

      #${actual_value}=  YamlPath Parse  query=.**.[.Node=${expected_node}].Type  data=${output}
      ${actual_value}=  get parsed "Type" where "Node" is "${expected_node}"
      IF  "${expected_value}" == "${actual_value.replace("(Active)", "").replace("(Standby)", "")}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Node ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Node ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
      END

      ${expected_state}=  Run Keyword If  "MPA" in "${expected_value}" or "FC" in "${expected_value}"  Set Variable  OK
      ...  ELSE IF  "FAN" in "${expected_value}" or "PWR" in "${expected_value}" or "AC" in "${expected_value}"  Set Variable  READY
      ...  ELSE  Set Variable  RUN
      #${actual_state}=  YamlPath Parse  query=.**.[.Node=${expected_node}].SWState  data=${output}
      ${actual_state}=  get parsed "SWState" where "Node" is "${expected_node}"
      IF  "${expected_state}" == "${actual_state.strip()}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Node ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state.strip()}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Node ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state.strip()}
      END
    END

baseline hardware exr validate correct hardware modules are up as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware modules are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_MODULES.keys()}"
      baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run parsed "show platform"
    ${expected_values}=  Get Dictionary Items  ${BASELINE_HW_MODULES['${device}']}
    ${actual_nodes}=  get parsed "node"
    FOR  ${expected_node}  ${expected_value}  IN  @{expected_values}
      IF  "${expected_node}" not in "${actual_nodes}"
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Expected hardware module node: ${expected_node} : Not found in output.
        Continue For Loop
      END

      #${actual_value}=  YamlPath Parse  query=.**.[.node=${expected_node}].node_type  data=${output}
      ${actual_value}=  get parsed "node_type" where "node" is "${expected_node}"
      ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
      IF  "${expected_value}" == "${actual_value}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Node ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Node ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value}
      END

      ${expected_state}=  Run Keyword If  "MPA" in "${expected_value}" or "PEC" in "${expected_value}"  Set Variable  OK
      ...                        ELSE IF  "FAN" in "${expected_value}" or "PEM" in "${expected_value}" or "ACFW" in "${expected_value}" or "FC" in "${expected_value}" or "PSU" in "${expected_value}" or "PWR" in "${expected_value}" or "TRAY" in "${expected_value}" or "SC" in "${expected_value}" or "PAC" in "${expected_value}" or "CI" in "${expected_value}"  Set Variable  OPERATIONAL
      ...                        ELSE IF  "NPU" in "${expected_value}" or "Slice" in "${expected_value}"  Set Variable  UP
      ...                        ELSE  Set Variable  IOS XR RUN
      #${actual_state}=  YamlPath Parse  query=.**.[.node=${expected_node}].node_state  data=${output}
      ${actual_state}=  get parsed "node_state" where "node" is "${expected_node}"
      IF  "${expected_state}" == "${actual_state.strip()}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Node ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state.strip()}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Node ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state.strip()}
      END
    END

baseline hardware iosxe validate correct hardware modules are up as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware modules are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_MODULES.keys()}"
      baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run parsed "show platform"
    ${expected_values}=  Get Dictionary Items  ${BASELINE_HW_MODULES['${device}']}
    ${actual_nodes}=  get parsed "slot"
    FOR  ${expected_node}  ${expected_value}  IN  @{expected_values}
      IF  "${expected_node}" not in "${actual_nodes}"
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Expected hardware module slot: ${expected_node} : Not found in output.
        Continue For Loop
      END

      ${actual_value}=  YamlPath Parse  query=[slot=${expected_node}].type  data=${output}
      #${actual_value}=  get parsed "type" where "slot" is "${expected_node}"
      IF  "${expected_value}" == "${actual_value[0]}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Slot ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value[0]}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Slot ${expected_node} : Expected type: ${expected_value} : Actual type: ${actual_value[0]}
      END

      ${expected_state}=  Set Variable  ok
      ${actual_state}=  YamlPath Parse  query=[slot=${expected_node}].state  data=${output}
      #${actual_state}=  get parsed "state" where "slot" is "${expected_node}"
      ${actual_state}=  Set Variable  ${actual_state[0].replace(", active", "").replace(", standby", "")}
      IF  "${expected_state}" == "${actual_state}"
        baseline set test pass  [PASS] Hardware modules check: ${device} : Slot ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state}
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Slot ${expected_node} : Expected state: ${expected_state} : Actual state: ${actual_state}
      END
    END

baseline hardware nxos validate correct hardware modules are up as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct hardware modules are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_MODULES.keys()}"
      baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show module | json"
    ${expected_values}=  Get Dictionary Items  ${BASELINE_HW_MODULES['${device}']}
    #${actual_nodes}=  get parsed "slot"
    FOR  ${expected_node}  ${expected_value}  IN  @{expected_values}
      ${expected_node}=  Convert to String  ${expected_node}
      ${status_1}=  Run Keyword And Return Status  values "${expected_node}" and "${expected_value}" exist on same line
      ${status_2}=  Run Keyword And Return Status  values "active" and "${expected_node}" exist on same line
      IF  ${status_1} and ${status_2}
        baseline set test pass  [PASS] Hardware modules check: ${device} : Slot ${expected_node} : Expected type: ${expected_value}, present and active
      ELSE IF  ${status_1}
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Slot ${expected_node} : Expected type: ${expected_value}, present but not active
      ELSE
        baseline set test fail  [FAIL] Hardware modules check: ${device} : Slot ${expected_node} : Expected type: ${expected_value}, absent
      END
    END



######################  Hardware inventory checks #######################



baseline hardware validate correct inventory output as per defined baseline
    [Documentation]  Create the variable BASELINE_HW_INVENTORY in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_HW_INVENTORY:
    ...                ROUTER_A:
    ...                  module 0/RSP0/CPU0:
    ...                    descr: ASR9K Route Switch Processor with 880G/slot Fabric and 32GB
    ...                    pid: A9K-RSP880-SE
    ...                    vid: V05
    ...                    sn: FOC2237NQEA
    ...
    ...              baseline hardware validate correct inventory output as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct inventory output as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_HW_INVENTORY}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for hardware inventory check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline hardware cxr validate correct inventory output as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR" or "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline hardware ios validate correct inventory output as per defined baseline  ${device}
      END
    END

baseline hardware cxr validate correct inventory output as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct inventory output as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_INVENTORY.keys()}"
      baseline set test comment  [SKIP] Hardware modules check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run parsed "admin show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
    ${expected_names}=  Get Dictionary Keys  ${BASELINE_HW_INVENTORY['${device}']}
    ${actual_names}=  get parsed "name"
    FOR  ${expected_name}  IN  @{expected_names}
      IF  "${expected_name}" not in "${actual_names}"
        baseline set test fail  [FAIL] Hardware inventory check: ${device} : Expected hardware inventory name: '${expected_name}' : Not found in output.
        Continue For Loop
      ELSE
        baseline set test pass  [PASS] Hardware inventory check: ${device} : Expected hardware inventory name: '${expected_name}' : Found in output.
      END
      ${keys}=  Get Dictionary Keys  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']}

      IF  "descr" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['descr']}
        ${actual_value}=  get parsed "descr" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected descr: '${expected_value}' : Actual descr: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected descr: '${expected_value}' : Actual descr: '${actual_value}'
        END
      END
      IF  "pid" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['pid']}
        ${actual_value}=  get parsed "pid" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected pid: '${expected_value}' : Actual pid: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected pid: '${expected_value}' : Actual pid: '${actual_value}'
        END
      END
      IF  "vid" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['vid']}
        ${actual_value}=  get parsed "vid" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected vid: '${expected_value}' : Actual vid: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected vid: '${expected_value}' : Actual vid: '${actual_value}'
        END
      END
      IF  "sn" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['sn']}
        ${actual_value}=  get parsed "sn" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected sn: '${expected_value}' : Actual sn: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected sn: '${expected_value}' : Actual sn: '${actual_value}'
        END
      END
    END



baseline hardware ios validate correct inventory output as per defined baseline
    [Documentation]  Child keyword for 'baseline hardware validate correct inventory output as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_HW_INVENTORY.keys()}"
      baseline set test comment  [SKIP] Hardware inventory check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run parsed "show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
    ${expected_names}=  Get Dictionary Keys  ${BASELINE_HW_INVENTORY['${device}']}
    ${actual_names}=  get parsed "name"
    FOR  ${expected_name}  IN  @{expected_names}
      IF  "${expected_name}" not in "${actual_names}"
        baseline set test fail  [FAIL] Hardware inventory check: ${device} : Expected hardware inventory name: '${expected_name}' : Not found in output.
        Continue For Loop
      ELSE
        baseline set test pass  [PASS] Hardware inventory check: ${device} : Expected hardware inventory name: '${expected_name}' : Found in output.
      END
      ${keys}=  Get Dictionary Keys  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']}

      IF  "descr" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['descr']}
        ${actual_value}=  get parsed "descr" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected descr: '${expected_value}' : Actual descr: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected descr: '${expected_value}' : Actual descr: '${actual_value}'
        END
      END
      IF  "pid" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['pid']}
        ${actual_value}=  get parsed "pid" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected pid: '${expected_value}' : Actual pid: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected pid: '${expected_value}' : Actual pid: '${actual_value}'
        END
      END
      IF  "vid" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['vid']}
        ${actual_value}=  get parsed "vid" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected vid: '${expected_value}' : Actual vid: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected vid: '${expected_value}' : Actual vid: '${actual_value}'
        END
      END
      IF  "sn" in "${keys}"
        ${expected_value}=  Set Variable  ${BASELINE_HW_INVENTORY['${device}']['${expected_name}']['sn']}
        ${actual_value}=  get parsed "sn" where "name" is "${expected_name}"
        ${actual_value}=  Set Variable  ${actual_value.replace("(Active)", "").replace("(Standby)", "")}
        IF  "${expected_value}" == "${actual_value}"
          baseline set test pass  [PASS] Hardware inventory check: ${device} : Name '${expected_name}' : Expected sn: '${expected_value}' : Actual sn: '${actual_value}'
        ELSE
          baseline set test fail  [FAIL] Hardware inventory check: ${device} : Name '${expected_name}' : Expected sn: '${expected_value}' : Actual sn: '${actual_value}'
        END
      END
    END
