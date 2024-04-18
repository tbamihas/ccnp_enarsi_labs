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
#     Baseline data and other common for your topology needs to be defined in: Data/common.yaml
#     Certificate specific data needs to be defined in: Data/Baseline/baseline_certificates.yaml
#
#     Keywords in this file
#
# sdwan baseline validate root certificate is installed
# sdwan baseline validate signed certificate is installed
# sdwan baseline validate root certificate validity
# sdwan baseline validate signed certificate validity
#
################################################################################

*** Keywords ***
######################    #######################

sdwan baseline validate root certificate is installed
    [Documentation]   This keyword validates if the root ceritificate is installed.
    ...               Create the required variables in common.yaml and Data/Baeline/baseline_certificates.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate root certificate is installed  NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate root certificate is installed
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      Continue For Loop IF  '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vmanage' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vsmart' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vbond' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'edge'
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate root certificate is installed on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate root certificate is installed on viptelaOS  ${device}
      END
    END


sdwan baseline validate root certificate is installed on iosxe
    [Arguments]  ${device}
    run "show sdwan control local-properties"
    ${expected_value}=  Set Variable  ${BASELINE_ROOT_CA_CERTIFICATE_ORGANIZATION_UNIT_NAME}
    ${status}=  Run Keyword And Return Status    output matches pattern "root-ca-chain-status\\\\s+Installed"
    IF  ${status} == ${True}
        run "show sdwan certificate root-ca-cert"
        ${status}=  Run Keyword And Return Status  output matches pattern "OU\\\\s*=\\\\s*${expected_value}"
        IF  ${status} == ${True}
            baseline set test pass  [PASS] Root Certificate check: Device ${device} : Root Certificate is installed : Expected Organization name (${expected_value}) is found
        ELSE
            baseline set test fail  [FAIL] Root Certificate check: Device ${device} : Root Certificate is installed : Expected Organization name (${expected_value}) is not found
        END
    ELSE
        baseline set test fail  [FAIL] Root Certificate check: Device ${device} : Root Certificate is not installed
    END

sdwan baseline validate root certificate is installed on viptelaOS
    [Arguments]  ${device}
    run "show control local-properties"
    ${expected_value}=  Set Variable  ${BASELINE_ROOT_CA_CERTIFICATE_ORGANIZATION_UNIT_NAME}
    ${status}=  Run Keyword And Return Status    output matches pattern "root-ca-chain-status\\\\s+Installed"
    IF  ${status} == ${True}
        run "show certificate root-ca-cert"
        ${status}=  Run Keyword And Return Status  output matches pattern "OU\\\\s*=\\\\s*${expected_value}"
        IF  ${status} == ${True}
            baseline set test pass  [PASS] Root Certificate check: Device ${device} : Root Certificate is installed : Expected Organization name (${expected_value}) is found
        ELSE
            baseline set test fail  [FAIL] Root Certificate check: Device ${device} : Root Certificate is installed : Expected Organization name (${expected_value}) is not found
        END
    ELSE
        baseline set test fail  [FAIL] Root Certificate check: Device ${device} : Root Certificate is not installed
    END


sdwan baseline validate signed certificate is installed
    [Documentation]   This keyword validates if the signed ceritificate is installed.
    ...               Create the required variables in common.yaml and Data/Baeline/baseline_certificates.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate signed certificate is installed  NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate signed certificate is installed
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      Continue For Loop IF  '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vmanage' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vsmart' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vbond' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'edge'
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate signed certificate is installed on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate signed certificate is installed on viptelaOS  ${device}
      END
    END


sdwan baseline validate signed certificate is installed on iosxe
    [Arguments]  ${device}
    run "show sdwan control local-properties"
    ${status}=  Run Keyword And Return Status    output matches pattern "certificate-status\\\\s+Installed"
    IF  ${status} == ${True}
        run "show sdwan certificate installed"
        IF  '${NODES_SDWAN_DETAILS['${device}']['flavor']}' == 'software'
            ${expected_value_software}=  Set Variable  ${BASELINE_SOFTWARE_EDGE_DEVICE_SIGNED_CERTIFICATE_ORGANIZATION_UNIT_NAME}
            ${status}=  Run Keyword And Return Status  output matches pattern "Subject:.+OU\\\\s*=\\\\s*${expected_value_software}"
            IF  ${status} == ${True}
                baseline set test pass  [PASS] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_software}) is found
            ELSE
                baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_software}) is not found
            END
        ELSE IF  '${NODES_SDWAN_DETAILS['${device}']['flavor']}' == 'hardware'
            ${expected_value_hardware}=  Set Variable  ${BASELINE_HARDWARE_EDGE_DEVICE_SIGNED_CERTIFICATE_ORGANIZATION_UNIT_NAME['${device}']}
            ${status}=  Run Keyword And Return Status  output matches pattern "Subject:.+OU\\\\s*=\\\\s*${expected_value_hardware}"
            IF  ${status} == ${True}
                baseline set test pass  [PASS] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_hardware}) is found
            ELSE
                baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_hardware}) is not found
            END
        END

    ELSE
        baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is not installed
    END


sdwan baseline validate signed certificate is installed on viptelaOS
    [Arguments]  ${device}
    run "show control local-properties"
    ${status}=  Run Keyword And Return Status    output matches pattern "certificate-status\\\\s+Installed"
    IF  ${status} == ${True}
        run "show certificate installed"
        IF  '${NODES_SDWAN_DETAILS['${device}']['flavor']}' == 'software'
            ${expected_value_software}=  Set Variable  ${BASELINE_SOFTWARE_EDGE_DEVICE_SIGNED_CERTIFICATE_ORGANIZATION_UNIT_NAME}
            ${status}=  Run Keyword And Return Status  output matches pattern "Subject:.+OU\\\\s*=\\\\s*${expected_value_software}"
            IF  ${status} == ${True}
                baseline set test pass  [PASS] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_software}) is found
            ELSE
                baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_software}) is not found
            END
        ELSE IF  '${NODES_SDWAN_DETAILS['${device}']['flavor']}' == 'hardware'
            ${expected_value_hardware}=  Set Variable  ${BASELINE_HARDWARE_EDGE_DEVICE_SIGNED_CERTIFICATE_ORGANIZATION_UNIT_NAME['${device}']}
            ${status}=  Run Keyword And Return Status  output matches pattern "Subject:.+OU\\\\s*=\\\\s*${expected_value_hardware}"
            IF  ${status} == ${True}
                baseline set test pass  [PASS] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_hardware}) is found
            ELSE
                baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is installed : Expected Organization name (${expected_value_hardware}) is not found
            END
        END

    ELSE
        baseline set test fail  [FAIL] Signed Certificate check: Device ${device} : Signed Certificate is not installed
    END



sdwan baseline validate root certificate validity
    [Documentation]   This keyword validates the validity of root ceritificate
    ...               Create the required variables in common.yaml and Data/Baeline/baseline_certificates.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate root certificate validity  NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate root certificate validity
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      Continue For Loop IF  '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vmanage' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vsmart' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vbond' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'edge'
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate root certificate validity on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate root certificate validity on viptelaOS  ${device}
      END
    END


sdwan baseline validate root certificate validity on iosxe
    [Arguments]  ${device}
    ${parsed_output}=  run parsed "show sdwan certificate root-ca-cert" with template "${XE_SDWAN_SHOW_SDWAN_CERTIFICATE_ROOT_CA_CERT_TEMPLATE}"
    Log  ${parsed_output}  formatter=repr  console=True
    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['organization_name']}' == '${BASELINE_ROOT_CA_CERTIFICATE_ORGANIZATION_NAME}'
            ${rootca_expiry_date}=  Set Variable    ${output['not_after_date']}
            ## Root CA expiry date details
            ## Jul 16 23:59:59 2036 GMT
            ${matches}=  Get Regexp Matches    ${rootca_expiry_date}    (\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)\\s+(\\d+)  1  2  3  4
            ${root_ca_expiry_month}=  Set Variable    ${matches[0][0]}
            IF  '${root_ca_expiry_month}' == 'Jan'
                ${root_ca_expiry_month}=  Set Variable    1
            ELSE IF  '${root_ca_expiry_month}' == 'Feb'
                ${root_ca_expiry_month}=  Set Variable    2
            ELSE IF  '${root_ca_expiry_month}' == 'Mar'
                ${root_ca_expiry_month}=  Set Variable    3
            ELSE IF  '${root_ca_expiry_month}' == 'Apr'
                ${root_ca_expiry_month}=  Set Variable    4
            ELSE IF  '${root_ca_expiry_month}' == 'May'
                ${root_ca_expiry_month}=  Set Variable    5
            ELSE IF  '${root_ca_expiry_month}' == 'Jun'
                ${root_ca_expiry_month}=  Set Variable    6
            ELSE IF  '${root_ca_expiry_month}' == 'Jul'
                ${root_ca_expiry_month}=  Set Variable    7
            ELSE IF  '${root_ca_expiry_month}' == 'Aug'
                ${root_ca_expiry_month}=  Set Variable    8
            ELSE IF  '${root_ca_expiry_month}' == 'Sep'
                ${root_ca_expiry_month}=  Set Variable    9
            ELSE IF  '${root_ca_expiry_month}' == 'Oct'
                ${root_ca_expiry_month}=  Set Variable    10
            ELSE IF  '${root_ca_expiry_month}' == 'Nov'
                ${root_ca_expiry_month}=  Set Variable    11
            ELSE IF  '${root_ca_expiry_month}' == 'Dec'
                ${root_ca_expiry_month}=  Set Variable    12
            END
            ${root_ca_expiry_month}=  Convert To Integer    ${root_ca_expiry_month}
            ${root_ca_expiry_day}=  Set Variable    ${matches[0][1]}
            ${root_ca_expiry_day}=  Convert To Integer    ${root_ca_expiry_day}
            ${root_ca_expiry_time}=  Set Variable    ${matches[0][2]}
            ${root_ca_expiry_year}=  Set Variable    ${matches[0][3]}
            ${root_ca_expiry_year}=  Convert To Integer    ${root_ca_expiry_year}
            ${matches}=  Get Regexp Matches    ${root_ca_expiry_time}    (\\d+):(\\d+):\\d+    1  2
            ${root_ca_expiry_hour}=  Set Variable    ${matches[0][0]}
            ${root_ca_expiry_hour}=  Convert To Integer    ${root_ca_expiry_hour}
            ${root_ca_expiry_minute}=  Set Variable    ${matches[0][1]}
            ${root_ca_expiry_minute}=  Convert To Integer    ${root_ca_expiry_minute}

            ## Current Date details
            ${current_date}=  run "show clock"
            ## 05:50:48.576 UTC Tue Jun 28 2022
            ${matches}=  Get Regexp Matches    ${current_date}    (\\d+:\\d+:\\d+)(\\.\\d+)?\\s*(\\S+)\\s*\\S+\\s+(\\S+)\\s+(\\d+)\\s+(\\d+)    1  3  4  5  6
            ${current_time}=  Set Variable    ${matches[0][0]}
            ${current_timezone}=  Set Variable    ${matches[0][1]}
            ${current_month}=  Set Variable    ${matches[0][2]}
            ${current_day}=  Set Variable    ${matches[0][3]}
            ${current_day}=  Convert To Integer    ${current_day}
            ${current_year}=  Set Variable    ${matches[0][4]}
            ${current_year}=  Convert To Integer    ${current_year}
            IF  '${current_month}' == 'Jan'
                ${current_month}=  Set Variable    1
            ELSE IF  '${current_month}' == 'Feb'
                ${current_month}=  Set Variable    2
            ELSE IF  '${current_month}' == 'Mar'
                ${current_month}=  Set Variable    3
            ELSE IF  '${current_month}' == 'Apr'
                ${current_month}=  Set Variable    4
            ELSE IF  '${current_month}' == 'May'
                ${current_month}=  Set Variable    5
            ELSE IF  '${current_month}' == 'Jun'
                ${current_month}=  Set Variable    6
            ELSE IF  '${current_month}' == 'Jul'
                ${current_month}=  Set Variable    7
            ELSE IF  '${current_month}' == 'Aug'
                ${current_month}=  Set Variable    8
            ELSE IF  '${current_month}' == 'Sep'
                ${current_month}=  Set Variable    9
            ELSE IF  '${current_month}' == 'Oct'
                ${current_month}=  Set Variable    10
            ELSE IF  '${current_month}' == 'Nov'
                ${current_month}=  Set Variable    11
            ELSE IF  '${current_month}' == 'Dec'
                ${current_month}=  Set Variable    12
            END
            ${current_month}=  Convert To Integer    ${current_month}
            ${matches}=  Get Regexp Matches    ${current_time}    (\\d+):(\\d+):\\d+    1  2
            ${current_hour}=  Set Variable    ${matches[0][0]}
            ${current_hour}=  Convert To Integer    ${current_hour}
            ${current_minute}=  Set Variable    ${matches[0][1]}
            ${current_minute}=  Convert To Integer    ${current_minute}


            ## Validate the expiry
            ${expected_validity_date}=  Catenate    Date(DD-MM-YYYY): ${root_ca_expiry_day}-${root_ca_expiry_month}-${root_ca_expiry_year}; Time: ${root_ca_expiry_time}
            ${current_date}=  Catenate    Date(DD-MM-YYYY): ${current_day}-${current_month}-${current_year}; Time: ${current_time}
            IF  ${current_year} < ${root_ca_expiry_year}
                baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${expected_validity_date} : Current Date is ${current_date}
            ELSE IF  ${current_year} == ${root_ca_expiry_year}
                IF  ${current_month} < ${root_ca_expiry_month}
                    baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                ELSE IF  ${current_month} == ${root_ca_expiry_month}
                    IF  ${current_day} < ${root_ca_expiry_day}
                        baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                        baseline set test warn  [Warning] The Root Certificate will expire in few days
                    ELSE IF   ${current_day} == ${root_ca_expiry_day}
                          IF  ${current_hour} < ${root_ca_expiry_hour}
                              baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                              baseline set test warn  [Warning] The Root Certificate will expire in few hours
                          ELSE IF  ${current_hour} == ${root_ca_expiry_hour}
                              IF  ${current_minute} < ${root_ca_expiry_minute}
                                  baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                                  baseline set test warn  [Warning] The Root Certificate will expire in few minutes
                              ELSE
                                  baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                              END
                          ELSE
                              baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                          END
                    ELSE
                        baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                    END
                ELSE
                    baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                END
            ELSE
                baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
            END
            Exit For Loop
        END
    END


sdwan baseline validate root certificate validity on viptelaOS
    [Arguments]  ${device}
    ${parsed_output}=  run parsed "show certificate root-ca-cert" with template "${VIPTELA_SDWAN_SHOW_CERTIFICATE_ROOT_CA_CERT_TEMPLATE}"
    Log  ${parsed_output}  formatter=repr  console=True
    FOR  ${output}  IN  @{parsed_output}
        IF  '${output['organization_name']}' == '${BASELINE_ROOT_CA_CERTIFICATE_ORGANIZATION_NAME}'
            ${rootca_expiry_date}=  Set Variable    ${output['not_after_date']}
            ## Root CA expiry date details
            ## Jul 16 23:59:59 2036 GMT
            ${matches}=  Get Regexp Matches    ${rootca_expiry_date}    (\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)\\s+(\\d+)  1  2  3  4
            ${root_ca_expiry_month}=  Set Variable    ${matches[0][0]}
            IF  '${root_ca_expiry_month}' == 'Jan'
                ${root_ca_expiry_month}=  Set Variable    1
            ELSE IF  '${root_ca_expiry_month}' == 'Feb'
                ${root_ca_expiry_month}=  Set Variable    2
            ELSE IF  '${root_ca_expiry_month}' == 'Mar'
                ${root_ca_expiry_month}=  Set Variable    3
            ELSE IF  '${root_ca_expiry_month}' == 'Apr'
                ${root_ca_expiry_month}=  Set Variable    4
            ELSE IF  '${root_ca_expiry_month}' == 'May'
                ${root_ca_expiry_month}=  Set Variable    5
            ELSE IF  '${root_ca_expiry_month}' == 'Jun'
                ${root_ca_expiry_month}=  Set Variable    6
            ELSE IF  '${root_ca_expiry_month}' == 'Jul'
                ${root_ca_expiry_month}=  Set Variable    7
            ELSE IF  '${root_ca_expiry_month}' == 'Aug'
                ${root_ca_expiry_month}=  Set Variable    8
            ELSE IF  '${root_ca_expiry_month}' == 'Sep'
                ${root_ca_expiry_month}=  Set Variable    9
            ELSE IF  '${root_ca_expiry_month}' == 'Oct'
                ${root_ca_expiry_month}=  Set Variable    10
            ELSE IF  '${root_ca_expiry_month}' == 'Nov'
                ${root_ca_expiry_month}=  Set Variable    11
            ELSE IF  '${root_ca_expiry_month}' == 'Dec'
                ${root_ca_expiry_month}=  Set Variable    12
            END
            ${root_ca_expiry_month}=  Convert To Integer    ${root_ca_expiry_month}
            ${root_ca_expiry_day}=  Set Variable    ${matches[0][1]}
            ${root_ca_expiry_day}=  Convert To Integer    ${root_ca_expiry_day}
            ${root_ca_expiry_time}=  Set Variable    ${matches[0][2]}
            ${root_ca_expiry_year}=  Set Variable    ${matches[0][3]}
            ${root_ca_expiry_year}=  Convert To Integer    ${root_ca_expiry_year}
            ${matches}=  Get Regexp Matches    ${root_ca_expiry_time}    (\\d+):(\\d+):\\d+    1  2
            ${root_ca_expiry_hour}=  Set Variable    ${matches[0][0]}
            ${root_ca_expiry_hour}=  Convert To Integer    ${root_ca_expiry_hour}
            ${root_ca_expiry_minute}=  Set Variable    ${matches[0][1]}
            ${root_ca_expiry_minute}=  Convert To Integer    ${root_ca_expiry_minute}

            ## Current Date details
            ${current_date}=  run "show clock"
            ## Tue Jun 28 11:50:39 UTC 2022
            ${matches}=  Get Regexp Matches    ${current_date}    \\S+\\s+(\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)(\\.\\d+)?\\s*(\\S+)\\s+(\\d+)    1  2  3  5  6
            ${current_month}=  Set Variable    ${matches[0][0]}
            ${current_day}=  Set Variable    ${matches[0][1]}
            ${current_day}=  Convert To Integer    ${current_day}
            ${current_time}=  Set Variable    ${matches[0][2]}
            ${current_timezone}=  Set Variable    ${matches[0][3]}
            ${current_year}=  Set Variable    ${matches[0][4]}
            ${current_year}=  Convert To Integer    ${current_year}
            IF  '${current_month}' == 'Jan'
                ${current_month}=  Set Variable    1
            ELSE IF  '${current_month}' == 'Feb'
                ${current_month}=  Set Variable    2
            ELSE IF  '${current_month}' == 'Mar'
                ${current_month}=  Set Variable    3
            ELSE IF  '${current_month}' == 'Apr'
                ${current_month}=  Set Variable    4
            ELSE IF  '${current_month}' == 'May'
                ${current_month}=  Set Variable    5
            ELSE IF  '${current_month}' == 'Jun'
                ${current_month}=  Set Variable    6
            ELSE IF  '${current_month}' == 'Jul'
                ${current_month}=  Set Variable    7
            ELSE IF  '${current_month}' == 'Aug'
                ${current_month}=  Set Variable    8
            ELSE IF  '${current_month}' == 'Sep'
                ${current_month}=  Set Variable    9
            ELSE IF  '${current_month}' == 'Oct'
                ${current_month}=  Set Variable    10
            ELSE IF  '${current_month}' == 'Nov'
                ${current_month}=  Set Variable    11
            ELSE IF  '${current_month}' == 'Dec'
                ${current_month}=  Set Variable    12
            END
            ${current_month}=  Convert To Integer    ${current_month}
            ${matches}=  Get Regexp Matches    ${current_time}    (\\d+):(\\d+):\\d+    1  2
            ${current_hour}=  Set Variable    ${matches[0][0]}
            ${current_hour}=  Convert To Integer    ${current_hour}
            ${current_minute}=  Set Variable    ${matches[0][1]}
            ${current_minute}=  Convert To Integer    ${current_minute}


            ## Validate the expiry
            ${expected_validity_date}=  Catenate    Date(DD-MM-YYYY): ${root_ca_expiry_day}-${root_ca_expiry_month}-${root_ca_expiry_year}; Time: ${root_ca_expiry_time}
            ${current_date}=  Catenate    Date(DD-MM-YYYY): ${current_day}-${current_month}-${current_year}; Time: ${current_time}
            IF  ${current_year} < ${root_ca_expiry_year}
                baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${expected_validity_date} : Current Date is ${current_date}
            ELSE IF  ${current_year} == ${root_ca_expiry_year}
                IF  ${current_month} < ${root_ca_expiry_month}
                    baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                ELSE IF  ${current_month} == ${root_ca_expiry_month}
                    IF  ${current_day} < ${root_ca_expiry_day}
                        baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                        baseline set test warn  [Warning] The Root Certificate will expire in few days
                    ELSE IF   ${current_day} == ${root_ca_expiry_day}
                          IF  ${current_hour} < ${root_ca_expiry_hour}
                              baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                              baseline set test warn  [Warning] The Root Certificate will expire in few hours
                          ELSE IF  ${current_hour} == ${root_ca_expiry_hour}
                              IF  ${current_minute} < ${root_ca_expiry_minute}
                                  baseline set test pass  [PASS] Root Certificate Validity Check: Device ${device} : Root Certificate is Valid : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                                  baseline set test warn  [Warning] The Root Certificate will expire in few minutes
                              ELSE
                                  baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                              END
                          ELSE
                              baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                          END
                    ELSE
                        baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                    END
                ELSE
                    baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
                END
            ELSE
                baseline set test fail  [FAIL] Root Certificate Validity Check: Device ${device} : Root Certificate is invalid/expired : Expected Validity Date is ${rootca_expiry_date}) : Current Date is ${current_date}
            END
            Exit For Loop
        END
    END



## Signed Certificate validity check
sdwan baseline validate signed certificate validity
    [Documentation]   This keyword validates the validity of signed ceritificate
    ...               Create the required variables in common.yaml and Data/Baeline/baseline_certificates.yaml file before calling this keyword.
    ...
    ...
    ...              *Arguments:*
    ...               - ``NODES_TO_CHECK`` List of devices to run the checks on.
    ...
    ...              *Examples:*
    ...              | sdwan baseline validate signed certificate validity  NODES_TO_CHECK=${device_list} |
    [Arguments]  ${NODES_TO_CHECK}
    activate report "${CHECKS_REPORT}"
    utility set test title  Validate signed certificate validity
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      Continue For Loop IF  '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vmanage' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vsmart' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'vbond' and '${NODES_SDWAN_DETAILS['${device}']['role']}' != 'edge'
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios"
        sdwan baseline validate signed certificate validity on iosxe  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "viptelaOS" or "${NODES_TYPE['${device}']}" == "viptelaOS"
        sdwan baseline validate signed certificate validity on viptelaOS  ${device}
      END
    END


sdwan baseline validate signed certificate validity on iosxe
    [Arguments]  ${device}
    ${output}=  run "show sdwan certificate installed"
    Log  ${output}
    ## Signed Certificate expiry date details
    ## Not After : Apr  8 09:14:06 2032 GMT
    ${matches}=  Get Regexp Matches    ${output}    Not After\\s*:\\s*(\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)\\s+(\\d+)\\s+(\\S+)  1  2  3  4
    ${signed_certificate_expiry_month}=  Set Variable    ${matches[0][0]}
    IF  '${signed_certificate_expiry_month}' == 'Jan'
        ${signed_certificate_expiry_month}=  Set Variable    1
    ELSE IF  '${signed_certificate_expiry_month}' == 'Feb'
        ${signed_certificate_expiry_month}=  Set Variable    2
    ELSE IF  '${signed_certificate_expiry_month}' == 'Mar'
        ${signed_certificate_expiry_month}=  Set Variable    3
    ELSE IF  '${signed_certificate_expiry_month}' == 'Apr'
        ${signed_certificate_expiry_month}=  Set Variable    4
    ELSE IF  '${signed_certificate_expiry_month}' == 'May'
        ${signed_certificate_expiry_month}=  Set Variable    5
    ELSE IF  '${signed_certificate_expiry_month}' == 'Jun'
        ${signed_certificate_expiry_month}=  Set Variable    6
    ELSE IF  '${signed_certificate_expiry_month}' == 'Jul'
        ${signed_certificate_expiry_month}=  Set Variable    7
    ELSE IF  '${signed_certificate_expiry_month}' == 'Aug'
        ${signed_certificate_expiry_month}=  Set Variable    8
    ELSE IF  '${signed_certificate_expiry_month}' == 'Sep'
        ${signed_certificate_expiry_month}=  Set Variable    9
    ELSE IF  '${signed_certificate_expiry_month}' == 'Oct'
        ${signed_certificate_expiry_month}=  Set Variable    10
    ELSE IF  '${signed_certificate_expiry_month}' == 'Nov'
        ${signed_certificate_expiry_month}=  Set Variable    11
    ELSE IF  '${signed_certificate_expiry_month}' == 'Dec'
        ${signed_certificate_expiry_month}=  Set Variable    12
    END
    ${signed_certificate_expiry_month}=  Convert To Integer    ${signed_certificate_expiry_month}
    ${signed_certificate_expiry_day}=  Set Variable    ${matches[0][1]}
    ${signed_certificate_expiry_day}=  Convert To Integer    ${signed_certificate_expiry_day}
    ${signed_certificate_expiry_time}=  Set Variable    ${matches[0][2]}
    ${signed_certificate_expiry_year}=  Set Variable    ${matches[0][3]}
    ${signed_certificate_expiry_year}=  Convert To Integer    ${signed_certificate_expiry_year}
    ${matches}=  Get Regexp Matches    ${signed_certificate_expiry_time}    (\\d+):(\\d+):\\d+    1  2
    ${signed_certificate_expiry_hour}=  Set Variable    ${matches[0][0]}
    ${signed_certificate_expiry_hour}=  Convert To Integer    ${signed_certificate_expiry_hour}
    ${signed_certificate_expiry_minute}=  Set Variable    ${matches[0][1]}
    ${signed_certificate_expiry_minute}=  Convert To Integer    ${signed_certificate_expiry_minute}

    ## Current Date details
    ${current_date}=  run "show clock"
    ## 05:50:48.576 UTC Tue Jun 28 2022
    ${matches}=  Get Regexp Matches    ${current_date}    (\\d+:\\d+:\\d+)(\\.\\d+)?\\s*(\\S+)\\s*\\S+\\s+(\\S+)\\s+(\\d+)\\s+(\\d+)    1  3  4  5  6
    ${current_time}=  Set Variable    ${matches[0][0]}
    ${current_timezone}=  Set Variable    ${matches[0][1]}
    ${current_month}=  Set Variable    ${matches[0][2]}
    ${current_day}=  Set Variable    ${matches[0][3]}
    ${current_day}=  Convert To Integer    ${current_day}
    ${current_year}=  Set Variable    ${matches[0][4]}
    ${current_year}=  Convert To Integer    ${current_year}
    IF  '${current_month}' == 'Jan'
        ${current_month}=  Set Variable    1
    ELSE IF  '${current_month}' == 'Feb'
        ${current_month}=  Set Variable    2
    ELSE IF  '${current_month}' == 'Mar'
        ${current_month}=  Set Variable    3
    ELSE IF  '${current_month}' == 'Apr'
        ${current_month}=  Set Variable    4
    ELSE IF  '${current_month}' == 'May'
        ${current_month}=  Set Variable    5
    ELSE IF  '${current_month}' == 'Jun'
        ${current_month}=  Set Variable    6
    ELSE IF  '${current_month}' == 'Jul'
        ${current_month}=  Set Variable    7
    ELSE IF  '${current_month}' == 'Aug'
        ${current_month}=  Set Variable    8
    ELSE IF  '${current_month}' == 'Sep'
        ${current_month}=  Set Variable    9
    ELSE IF  '${current_month}' == 'Oct'
        ${current_month}=  Set Variable    10
    ELSE IF  '${current_month}' == 'Nov'
        ${current_month}=  Set Variable    11
    ELSE IF  '${current_month}' == 'Dec'
        ${current_month}=  Set Variable    12
    END
    ${current_month}=  Convert To Integer    ${current_month}
    ${matches}=  Get Regexp Matches    ${current_time}    (\\d+):(\\d+):\\d+    1  2
    ${current_hour}=  Set Variable    ${matches[0][0]}
    ${current_hour}=  Convert To Integer    ${current_hour}
    ${current_minute}=  Set Variable    ${matches[0][1]}
    ${current_minute}=  Convert To Integer    ${current_minute}


    ## Validate the expiry
    ${expected_validity_date}=  Catenate    Date(DD-MM-YYYY): ${signed_certificate_expiry_day}-${signed_certificate_expiry_month}-${signed_certificate_expiry_year}; Time: ${signed_certificate_expiry_time}
    ${current_date}=  Catenate    Date(DD-MM-YYYY): ${current_day}-${current_month}-${current_year}; Time: ${current_time}
    IF  ${current_year} < ${signed_certificate_expiry_year}
        baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${expected_validity_date} : Current Date is ${current_date}
    ELSE IF  ${current_year} == ${signed_certificate_expiry_year}
        IF  ${current_month} < ${signed_certificate_expiry_month}
            baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
        ELSE IF  ${current_month} == ${signed_certificate_expiry_month}
            IF  ${current_day} < ${signed_certificate_expiry_day}
                baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                baseline set test warn  [Warning] The Signed Certificate will expire in few days
            ELSE IF   ${current_day} == ${signed_certificate_expiry_day}
                  IF  ${current_hour} < ${signed_certificate_expiry_hour}
                      baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                      baseline set test warn  [Warning] The Signed Certificate will expire in few hours
                  ELSE IF  ${current_hour} == ${signed_certificate_expiry_hour}
                      IF  ${current_minute} < ${signed_certificate_expiry_minute}
                          baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                          baseline set test warn  [Warning] The Signed Certificate will expire in few minutes
                      ELSE
                          baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                      END
                  ELSE
                      baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                  END
            ELSE
                baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
            END
        ELSE
            baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
        END
    ELSE
        baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
    END




sdwan baseline validate signed certificate validity on viptelaOS
    [Arguments]  ${device}
    ${output}=  run "show certificate installed"
    Log  ${output}
    ## Signed Certificate expiry date details
    ## Not After : Apr  8 09:14:06 2032 GMT
    ${matches}=  Get Regexp Matches    ${output}    Not After\\s*:\\s*(\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)\\s+(\\d+)\\s+(\\S+)  1  2  3  4
    ${signed_certificate_expiry_month}=  Set Variable    ${matches[0][0]}
    IF  '${signed_certificate_expiry_month}' == 'Jan'
        ${signed_certificate_expiry_month}=  Set Variable    1
    ELSE IF  '${signed_certificate_expiry_month}' == 'Feb'
        ${signed_certificate_expiry_month}=  Set Variable    2
    ELSE IF  '${signed_certificate_expiry_month}' == 'Mar'
        ${signed_certificate_expiry_month}=  Set Variable    3
    ELSE IF  '${signed_certificate_expiry_month}' == 'Apr'
        ${signed_certificate_expiry_month}=  Set Variable    4
    ELSE IF  '${signed_certificate_expiry_month}' == 'May'
        ${signed_certificate_expiry_month}=  Set Variable    5
    ELSE IF  '${signed_certificate_expiry_month}' == 'Jun'
        ${signed_certificate_expiry_month}=  Set Variable    6
    ELSE IF  '${signed_certificate_expiry_month}' == 'Jul'
        ${signed_certificate_expiry_month}=  Set Variable    7
    ELSE IF  '${signed_certificate_expiry_month}' == 'Aug'
        ${signed_certificate_expiry_month}=  Set Variable    8
    ELSE IF  '${signed_certificate_expiry_month}' == 'Sep'
        ${signed_certificate_expiry_month}=  Set Variable    9
    ELSE IF  '${signed_certificate_expiry_month}' == 'Oct'
        ${signed_certificate_expiry_month}=  Set Variable    10
    ELSE IF  '${signed_certificate_expiry_month}' == 'Nov'
        ${signed_certificate_expiry_month}=  Set Variable    11
    ELSE IF  '${signed_certificate_expiry_month}' == 'Dec'
        ${signed_certificate_expiry_month}=  Set Variable    12
    END
    ${signed_certificate_expiry_month}=  Convert To Integer    ${signed_certificate_expiry_month}
    ${signed_certificate_expiry_day}=  Set Variable    ${matches[0][1]}
    ${signed_certificate_expiry_day}=  Convert To Integer    ${signed_certificate_expiry_day}
    ${signed_certificate_expiry_time}=  Set Variable    ${matches[0][2]}
    ${signed_certificate_expiry_year}=  Set Variable    ${matches[0][3]}
    ${signed_certificate_expiry_year}=  Convert To Integer    ${signed_certificate_expiry_year}
    ${matches}=  Get Regexp Matches    ${signed_certificate_expiry_time}    (\\d+):(\\d+):\\d+    1  2
    ${signed_certificate_expiry_hour}=  Set Variable    ${matches[0][0]}
    ${signed_certificate_expiry_hour}=  Convert To Integer    ${signed_certificate_expiry_hour}
    ${signed_certificate_expiry_minute}=  Set Variable    ${matches[0][1]}
    ${signed_certificate_expiry_minute}=  Convert To Integer    ${signed_certificate_expiry_minute}

    ## Current Date details
    ${current_date}=  run "show clock"
    ## Tue Jun 28 11:50:39 UTC 2022
    ${matches}=  Get Regexp Matches    ${current_date}    \\S+\\s+(\\S+)\\s+(\\d+)\\s+(\\d+:\\d+:\\d+)(\\.\\d+)?\\s*(\\S+)\\s+(\\d+)    1  2  3  5  6
    ${current_month}=  Set Variable    ${matches[0][0]}
    ${current_day}=  Set Variable    ${matches[0][1]}
    ${current_day}=  Convert To Integer    ${current_day}
    ${current_time}=  Set Variable    ${matches[0][2]}
    ${current_timezone}=  Set Variable    ${matches[0][3]}
    ${current_year}=  Set Variable    ${matches[0][4]}
    ${current_year}=  Convert To Integer    ${current_year}
    IF  '${current_month}' == 'Jan'
        ${current_month}=  Set Variable    1
    ELSE IF  '${current_month}' == 'Feb'
        ${current_month}=  Set Variable    2
    ELSE IF  '${current_month}' == 'Mar'
        ${current_month}=  Set Variable    3
    ELSE IF  '${current_month}' == 'Apr'
        ${current_month}=  Set Variable    4
    ELSE IF  '${current_month}' == 'May'
        ${current_month}=  Set Variable    5
    ELSE IF  '${current_month}' == 'Jun'
        ${current_month}=  Set Variable    6
    ELSE IF  '${current_month}' == 'Jul'
        ${current_month}=  Set Variable    7
    ELSE IF  '${current_month}' == 'Aug'
        ${current_month}=  Set Variable    8
    ELSE IF  '${current_month}' == 'Sep'
        ${current_month}=  Set Variable    9
    ELSE IF  '${current_month}' == 'Oct'
        ${current_month}=  Set Variable    10
    ELSE IF  '${current_month}' == 'Nov'
        ${current_month}=  Set Variable    11
    ELSE IF  '${current_month}' == 'Dec'
        ${current_month}=  Set Variable    12
    END
    ${current_month}=  Convert To Integer    ${current_month}
    ${matches}=  Get Regexp Matches    ${current_time}    (\\d+):(\\d+):\\d+    1  2
    ${current_hour}=  Set Variable    ${matches[0][0]}
    ${current_hour}=  Convert To Integer    ${current_hour}
    ${current_minute}=  Set Variable    ${matches[0][1]}
    ${current_minute}=  Convert To Integer    ${current_minute}


    ## Validate the expiry
    ${expected_validity_date}=  Catenate    Date(DD-MM-YYYY): ${signed_certificate_expiry_day}-${signed_certificate_expiry_month}-${signed_certificate_expiry_year}; Time: ${signed_certificate_expiry_time}
    ${current_date}=  Catenate    Date(DD-MM-YYYY): ${current_day}-${current_month}-${current_year}; Time: ${current_time}
    IF  ${current_year} < ${signed_certificate_expiry_year}
        baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${expected_validity_date} : Current Date is ${current_date}
    ELSE IF  ${current_year} == ${signed_certificate_expiry_year}
        IF  ${current_month} < ${signed_certificate_expiry_month}
            baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
        ELSE IF  ${current_month} == ${signed_certificate_expiry_month}
            IF  ${current_day} < ${signed_certificate_expiry_day}
                baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                baseline set test warn  [Warning] The Signed Certificate will expire in few days
            ELSE IF   ${current_day} == ${signed_certificate_expiry_day}
                  IF  ${current_hour} < ${signed_certificate_expiry_hour}
                      baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                      baseline set test warn  [Warning] The Signed Certificate will expire in few hours
                  ELSE IF  ${current_hour} == ${signed_certificate_expiry_hour}
                      IF  ${current_minute} < ${signed_certificate_expiry_minute}
                          baseline set test pass  [PASS] Signed Certificate Validity Check: Device ${device} : Signed Certificate is Valid : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                          baseline set test warn  [Warning] The Signed Certificate will expire in few minutes
                      ELSE
                          baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                      END
                  ELSE
                      baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
                  END
            ELSE
                baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
            END
        ELSE
            baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
        END
    ELSE
        baseline set test fail  [FAIL] Signed Certificate Validity Check: Device ${device} : Signed Certificate is invalid/expired : Expected Validity Date is ${signed_certificate_expiry_date}) : Current Date is ${current_date}
    END
