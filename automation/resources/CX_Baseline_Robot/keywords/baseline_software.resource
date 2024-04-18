*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Baseline data for your topology needs to be defined:
#     See examples here: EXAMPLE_Data/baseline_software.yaml
#
#
#     Keywords in this file
#
# baseline software validate correct software version is installed as per defined baseline
# baseline software validate correct software packages are installed as per defined baseline
#
#
#
################################################################################

*** Variables ***


*** Keywords ***
######################  Software  #######################

baseline software validate correct software version is installed as per defined baseline
    [Documentation]  Create the variable BASELINE_SW_VERSION in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_SW_VERSION:
    ...                ROUTER_A: 15.2(1)SY5
    ...                ROUTER_B: 6.7.3
    ...
    ...              baseline software validate correct software version is installed as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct software version is installed as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_SW_VERSION}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for software version check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline software cxr validate correct software version is installed as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline software exr validate correct software version is installed as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        baseline software iosxe validate correct software version is installed as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline software nxos validate correct software version is installed as per defined baseline  ${device}
      END
    END

baseline software cxr validate correct software version is installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software version is installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_VERSION.keys()}"
      baseline set test comment  [SKIP] Software version check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show version brief"
    ${expected_value}=  Set Variable  ${BASELINE_SW_VERSION['${device}']}
    ${actual_value}=  extract patterns "Version ([\\d\\.]+)"
    IF  "${expected_value}" == "${actual_value[0]}"
      baseline set test pass  [PASS] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    ELSE
      baseline set test fail  [FAIL] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    END

baseline software exr validate correct software version is installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software version is installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_VERSION.keys()}"
      baseline set test comment  [SKIP] Software version check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show version"
    ${expected_value}=  Set Variable  ${BASELINE_SW_VERSION['${device}']}
    ${actual_value}=  extract pattern "Version +: ([\\d\\.A-Z]+)"
    IF  "${expected_value}" == "${actual_value}"
      baseline set test pass  [PASS] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value}
    ELSE
      baseline set test fail  [FAIL] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value}
    END

baseline software iosxe validate correct software version is installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software version is installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_VERSION.keys()}"
      baseline set test comment  [SKIP] Software version check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show version"
    ${expected_value}=  Set Variable  ${BASELINE_SW_VERSION['${device}']}
    ${actual_value}=  extract patterns "Version ([\\d\\.A-Za-z\\(\\)]+)"
    IF  "${expected_value}" == "${actual_value[0]}"
      baseline set test pass  [PASS] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    ELSE
      baseline set test fail  [FAIL] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    END

baseline software nxos validate correct software version is installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software version is installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_VERSION.keys()}"
      baseline set test comment  [SKIP] Software version check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show version"
    ${expected_value}=  Set Variable  ${BASELINE_SW_VERSION['${device}']}
    ${status}  ${actual_value}=  Run Keyword And Ignore Error  extract patterns "NXOS: version (\\\\S+)"
    IF  "${status}" == "FAIL"
      ${actual_value}=  extract patterns "system: +version (\\S+)"
    END
    IF  "${expected_value}" == "${actual_value[0]}"
      baseline set test pass  [PASS] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    ELSE
      baseline set test fail  [FAIL] Software version check: ${device} : Expected software version is: ${expected_value} : Detected software version is: ${actual_value[0]}
    END






baseline software validate correct software packages are installed as per defined baseline
    [Documentation]  Create the variable BASELINE_SW_PACKAGES in a yaml file before calling this keyword.
    ...              Example:
    ...
    ...              BASELINE_SW_PACKAGES:
    ...                ROUTER_A:
    ...                  - asr9k-mini-px-6.7.3
    ...                  - asr9k-doc-px-6.7.3
    ...                  - asr9k-k9sec-px-6.7.3
    ...
    ...              baseline software validate correct software packages are installed as per defined baseline
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Validate correct software packages are installed as per defined baseline
    ${baseline_data_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_SW_PACKAGES}
    IF  not ${baseline_data_exists}
      baseline set test comment  [SKIP] No baseline defined for software packages check.
      Return From Keyword
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR"
        baseline software cxr validate correct software packages are installed as per defined baseline  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline software exr validate correct software packages are installed as per defined baseline  ${device}
      END
    END


baseline software cxr validate correct software packages are installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software packages are installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_PACKAGES.keys()}"
      baseline set test comment  [SKIP] Software packages check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show install active summary"
    ${expected_packages}=  Set Variable  ${BASELINE_SW_PACKAGES['${device}']}
    ${actual_packages}=  extract patterns "(?:(?:disk0:)|(?:mem:))(\\S+)"
    FOR  ${expected_package}  IN  @{expected_packages}
        IF  "${expected_package}" in "${actual_packages}"
          baseline set test pass  [PASS] Software package check: ${device} : Expected software package is: ${expected_package} : Package is installed.
        ELSE
          baseline set test fail  [FAIL] Software package check: ${device} : Expected software version is: ${expected_package} : Package is NOT installed.
        END
    END
    FOR  ${actual_package}  IN  @{actual_packages}
        IF  "${actual_package}" not in "${expected_packages}"
          baseline set test fail  [FAIL] Software package check: ${device} : Detected software package: ${actual_package} : Package should NOT be installed.
        END
    END


baseline software exr validate correct software packages are installed as per defined baseline
    [Documentation]  Child keyword for 'baseline software validate correct software packages are installed as per defined baseline'.
    [Arguments]  ${device}
    IF  "${device}" not in "${BASELINE_SW_PACKAGES.keys()}"
      baseline set test comment  [SKIP] Software packages check: ${device} : Skip check, no baseline defined
      Return From Keyword
    END

    run "show install active summary"
    ${IS_NCS}=  Run Keyword And Return Status  output contains "Optional Packages"
    ${expected_packages}=  Set Variable  ${BASELINE_SW_PACKAGES['${device}']}
    IF  ${IS_NCS}
      ${actual_packages}=  extract patterns "(xr-\\S+)"
    ELSE
      ${actual_packages}=  extract patterns "${SPACE * 8}(\\S+)"
    END
    FOR  ${expected_package}  IN  @{expected_packages}
        IF  "${expected_package}" in "${actual_packages}"
          baseline set test pass  [PASS] Software package check: ${device} : Expected software package is: ${expected_package} : Package is installed.
        ELSE
          baseline set test fail  [FAIL] Software package check: ${device} : Expected software version is: ${expected_package} : Package is NOT installed.
        END
    END
    FOR  ${actual_package}  IN  @{actual_packages}
        IF  "${actual_package}" not in "${expected_packages}"
          baseline set test fail  [FAIL] Software package check: ${device} : Detected software package: ${actual_package} : Package should NOT be installed.
        END
    END
