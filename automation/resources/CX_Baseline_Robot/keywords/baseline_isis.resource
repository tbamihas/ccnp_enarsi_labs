*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_isis.yaml
#
#
#     Keywords in this file
#
# baseline isis validate correct isis neighbors are up as per defined baseline
# baseline isis validate minimum isis neighbor scale as per defined baseline
# baseline isis validate minimum isis lsp scale as per defined baseline
#
#
#
################################################################################


*** Variables ***
## maybe add show isis protocol check

*** Keywords ***
######################  ISIS neighbor checks #######################

baseline isis validate correct isis neighbors are up as per defined baseline
    [Documentation]  Create the variable BASELINE_ISIS_NEIGHBORS in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_ISIS_NEIGHBORS:
    ...                ROUTER_A:
    ...                  - ROUTER_B
    ...
    ...              baseline isis validate correct isis neighbors are up as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct isis neighbors are up as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_ISIS_NEIGHBORS}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for ISIS neighbors check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline isis iosxr validate correct isis neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline isis iosxe validate correct isis neighbors are up as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline isis nxos validate correct isis neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS neighbors check: ${device} : Skip check, ISIS neighbors checks are currently not available on NXOS devices
      END
    END

baseline isis iosxr validate correct isis neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate correct isis neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] ISIS neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show isis neighbors"
    IF  "${status}" == "FAIL"
      baseline set test fail  [FAIL] ISIS neighbors check: ${device} : No ISIS neighbors are up.
      Return From Keyword
    END
    ${output}=  Evaluate  json.dumps($output)
    ${output}=  Evaluate  json.loads($output)
    ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
    ${instance_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBORS['${device}']}
    FOR  ${instance}  IN  @{instance_list}
      ${neighbor_id_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBORS['${device}']['${instance}']}
      FOR  ${neighbor_id}  IN  @{neighbor_id_list}
        ${expected_interfaces}=  Set Variable  ${BASELINE_ISIS_NEIGHBORS['${device}']['${instance}']['${neighbor_id}']}
        ${actual_interfaces}=  Run Keyword And Ignore Error  YamlPath Parse New  query=[isisname='${instance}'][sys_id='${neighbor_id}'][parent(1)][state=Up][parent(1)].intf  data=${output}
        FOR  ${expected_interface}  IN  @{expected_interfaces}
          ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_interfaces[1]}  ${expected_interface}
          IF  ${status}
            baseline set test pass  [PASS] ISIS neighbors check: ${device} : Expected ISIS neighbor is: instance: ${instance} , system ID: ${neighbor_id} , interface: ${expected_interface} : ISIS neighbor is up.
          ELSE
            baseline set test fail  [FAIL] ISIS neighbors check: ${device} : Expected ISIS neighbor is: instance: ${instance} , system ID: ${neighbor_id} , interface: ${expected_interface} : ISIS neighbor is down.
          END
        END
      END
    END

baseline isis iosxe validate correct isis neighbors are up as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate correct isis neighbors are up as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_NEIGHBORS.keys()}"
      baseline set test comment  [SKIP] ISIS neighbors check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show isis neighbors" with template "${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}"
    IF  "${status}" == "FAIL"
      baseline set test fail  [FAIL] ISIS neighbors check: ${device} : No ISIS neighbors are up.
      Return From Keyword
    END
    ${output}=  Evaluate  json.dumps($output)
    ${output}=  Evaluate  json.loads($output)
    ${output}=  Evaluate  yaml.load(str($output), Loader=yaml.FullLoader)
    ${instance_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBORS['${device}']}
    FOR  ${instance}  IN  @{instance_list}
      ${neighbor_id_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBORS['${device}']['${instance}']}
      FOR  ${neighbor_id}  IN  @{neighbor_id_list}
        ${expected_interfaces}=  Set Variable  ${BASELINE_ISIS_NEIGHBORS['${device}']['${instance}']['${neighbor_id}']}
        ${actual_interfaces}=  Run Keyword And Ignore Error  YamlPath Parse New  query=[isisname='${instance}'][sys_id='${neighbor_id}'][parent(1)][state=UP][parent(1)].intf  data=${output}
        FOR  ${expected_interface}  IN  @{expected_interfaces}
          ${status}=  Run Keyword And Return Status  List Should Contain Value  ${actual_interfaces[1]}  ${expected_interface}
          IF  ${status}
            baseline set test pass  [PASS] ISIS neighbors check: ${device} : Expected ISIS neighbor is: instance: ${instance} , system ID: ${neighbor_id} , interface ${expected_interface} : ISIS neighbor is up.
          ELSE
            baseline set test fail  [FAIL] ISIS neighbors check: ${device} : Expected ISIS neighbor is: instance: ${instance} , system ID: ${neighbor_id} , interface ${expected_interface} : ISIS neighbor is down.
          END
        END
      END
    END





######################  ISIS Neighbor scale checks #######################



baseline isis validate minimum isis neighbor scale as per defined baseline
    [Documentation]  Create the variable BASELINE_ISIS_NEIGHBOR_SCALE in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...             BASELINE_ISIS_NEIGHBOR_SCALE:
    ...               ROUTER_A:
    ...                 INSTANCE_A: 100
    ...                 INSTANCE_B: 100
    ...               ROUTER_B:
    ...                 INSTANCE_A: 100
    ...                 INSTANCE_B: 100
    ...
    ...              baseline isis validate minimum isis neighbor scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum isis neighbor scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_ISIS_NEIGHBOR_SCALE}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for ISIS NEIGHBOR scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline isis iosxr validate minimum isis neighbor scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline isis iosxe validate minimum isis neighbor scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline isis nxos validate correct isis neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS Neighbor scale check: ${device} : Skip check, ISIS Neighbor scale checks are currently not available on NXOS devices
      END
    END

baseline isis iosxr validate minimum isis neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate minimum isis neighbor scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] ISIS Neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${instance_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBOR_SCALE['${device}']}
    FOR  ${instance}  IN  @{instance_list}
      ${expected_value}=  Set Variable  ${BASELINE_ISIS_NEIGHBOR_SCALE['${device}']['${instance}']}
      ${output}=  run "show isis instance ${instance} neighbors summary"
      ${actual_value_L1}=  Get Regexp Matches  ${output}  Up +(\\d+) +(\\d+) +(\\d+)  1
      ${actual_value_L2}=  Get Regexp Matches  ${output}  Up +(\\d+) +(\\d+) +(\\d+)  2
      ${actual_value_L1L2}=  Get Regexp Matches  ${output}  Up +(\\d+) +(\\d+) +(\\d+)  3
      ${actual_value}=  Evaluate  ${actual_value_L1[0]} + ${actual_value_L2[0]} + ${actual_value_L1L2[0]}
      IF  ${actual_value} >= ${expected_value}
        baseline set test pass  [PASS] ISIS Neighbor scale check: ${device} instance: ${instance} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
      ELSE
        baseline set test fail  [FAIL] ISIS Neighbor scale check: ${device} instance: ${instance} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
      END
    END

baseline isis iosxe validate minimum isis neighbor scale as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate minimum isis neighbor scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_NEIGHBOR_SCALE.keys()}"
      baseline set test comment  [SKIP] ISIS Neighbor scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${instance_list}=  Get Dictionary Keys  ${BASELINE_ISIS_NEIGHBOR_SCALE['${device}']}
    FOR  ${instance}  IN  @{instance_list}
      ${expected_value}=  Set Variable  ${BASELINE_ISIS_NEIGHBOR_SCALE['${device}']['${instance}']}
      run "show isis ${instance} neighbors | include UP"
      ${output}=  run "show isis ${instance} neighbors | count UP"
      ${actual_value}=  Get Regexp Matches  ${output}  \\d+
      IF  ${actual_value[0]} >= ${expected_value}
        baseline set test pass  [PASS] ISIS Neighbor scale check: ${device} instance: ${instance} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
      ELSE
        baseline set test fail  [FAIL] ISIS Neighbor scale check: ${device} instance: ${instance} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
      END
    END


######################  ISIS LSP scale checks #######################



baseline isis validate minimum isis lsp scale as per defined baseline
    [Documentation]  Create the variable BASELINE_ISIS_LSP_COUNT in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...             BASELINE_ISIS_LSP_COUNT:
    ...               ROUTER_A: 220
    ...               ROUTER_B: 220
    ...
    ...              baseline isis validate minimum isis lsp scale as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate minimum isis lsp scale as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_ISIS_LSP_COUNT}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for ISIS LSP scale check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline isis iosxr validate minimum isis lsp scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline isis iosxe validate minimum isis lsp scale as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        #baseline isis nxos validate correct isis neighbors are up as per defined baseline  ${device}
        baseline set test comment  [SKIP] ISIS LSP scale check: ${device} : Skip check, ISIS LSP scale checks are currently not available on NXOS devices
      END
    END

baseline isis iosxr validate minimum isis lsp scale as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate minimum isis lsp scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_LSP_COUNT.keys()}"
      baseline set test comment  [SKIP] ISIS LSP scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show isis database summary"
    ${expected_value}=  Set Variable  ${BASELINE_ISIS_LSP_COUNT['${device}']}
    ${actual_value}=  Get Regexp Matches  ${output}  All Fragment Counts[\\s\\S]+All LSPs: +\\d+ +\\d+ +(\\d+)  1
    IF  ${actual_value[0]} >= ${expected_value}
      baseline set test pass  [PASS] ISIS LSP scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
    ELSE
      baseline set test fail  [FAIL] ISIS LSP scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value[0]}.
    END

baseline isis iosxe validate minimum isis lsp scale as per defined baseline
    [Documentation]  Child keyword for 'baseline isis validate minimum isis lsp scale as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_ISIS_LSP_COUNT.keys()}"
      baseline set test comment  [SKIP] ISIS LSP scale check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    ${output}=  run "show isis database"
    ${expected_value}=  Set Variable  ${BASELINE_ISIS_LSP_COUNT['${device}']}
    ${lsps_found_in_output}=  Get Regexp Matches  ${output}  \\S+\\.[\\d\\w][\\d\\w]\\-[\\d\\w][\\d\\w]
    ${actual_value}=  Get Length  ${lsps_found_in_output}
    IF  ${actual_value} >= ${expected_value}
      baseline set test pass  [PASS] ISIS LSP scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    ELSE
      baseline set test fail  [FAIL] ISIS LSP scale check: ${device} : Expected minumum value: ${expected_value} : Actual value: ${actual_value}.
    END
