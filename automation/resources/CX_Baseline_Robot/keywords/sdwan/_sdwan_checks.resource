*** Settings ***
Resource    ../../cx_baseline_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# sdwan baseline checks start of test
# sdwan baseline checks end of test
# sdwan baseline checks start of test create text report
# sdwan baseline checks end of test create text report
#
################################################################################

sdwan baseline checks start of test
    [Arguments]  ${NODES_TO_CHECK}  ${REPORT}=${REPORT}
    Set Suite Variable  ${TEST_STATUS}  ${TRUE}
    activate report "${REPORT}"
    baseline set test title  SD-WAN Baseline Checks at Start of Test - Validate the network meets the defined baseline
    baseline set test comment  See file sdwan_baseline_checks_start_of_test.txt for full list of checks performed
    sdwan baseline checks start of test create text report

    sdwan baseline configuration validate config of devices is same as the master configuration  ${NODES_TO_CHECK}
    sdwan baseline validate control connections are up as per defined baseline  ${NODES_TO_CHECK}
    sdwan baseline validate root certificate is installed  ${NODES_TO_CHECK}
    sdwan baseline validate signed certificate is installed  ${NODES_TO_CHECK}
    sdwan baseline validate root certificate validity  ${NODES_TO_CHECK}
    sdwan baseline validate signed certificate validity  ${NODES_TO_CHECK}
    sdwan baseline validate omp peers are up as per defined baseline  ${NODES_TO_CHECK}

    baseline set test title  End of SD-WAN Baseline Checks at Start of Test
    activate report "${REPORT}"
    IF  ${TEST_STATUS}
      baseline set test pass  [PASS] SD-WAN Baseline Checks at Start of Test have passed, the network meets the defined baseline criteria. Test case execution will continue. See file sdwan_baseline_checks_start_of_test.txt for more details.
    ELSE
      baseline set test fail  [FAIL] SD-WAN Baseline Checks at Start of Test have failed, the network does NOT meet the defined baseline criteria. Test case execution will be halted. See file sdwan_baseline_checks_start_of_test.txt for more details.
    END


sdwan baseline checks end of test
    [Arguments]  ${NODES_TO_CHECK}  ${REPORT}=${REPORT}
    Set Global Variable  ${TEST_STATUS}  ${TRUE}
    activate report "${REPORT}"
    baseline set test title  SD-WAN Baseline Checks at End of Test - Validate the network meets the defined baseline
    baseline set test comment  See file sdwan_baseline_checks_end_of_test.txt for full list of checks performed
    sdwan baseline checks end of test create text report

    sdwan baseline configuration validate config of devices is same as the master configuration  ${NODES_TO_CHECK}
    sdwan baseline validate control connections are up as per defined baseline  ${NODES_TO_CHECK}
    sdwan baseline validate root certificate is installed  ${NODES_TO_CHECK}
    sdwan baseline validate signed certificate is installed  ${NODES_TO_CHECK}
    sdwan baseline validate root certificate validity  ${NODES_TO_CHECK}
    sdwan baseline validate signed certificate validity  ${NODES_TO_CHECK}
    sdwan baseline validate omp peers are up as per defined baseline  ${NODES_TO_CHECK}

    baseline set test title  End of SD-WAN Baseline Checks at End of Test
    activate report "${REPORT}"
    IF  ${TEST_STATUS}
      baseline set test pass  [PASS] SD-WAN Baseline Checks at End of Test have passed, the network meets the defined baseline criteria. See file sdwan_baseline_checks_end_of_test.txt for more details.
    ELSE
      baseline set test fail  [FAIL] SD-WAN Baseline Checks at End of Test have failed, the network does NOT meet the defined baseline criteria. See file sdwan_baseline_checks_end_of_test.txt for more details.
    END


sdwan baseline checks start of test create text report
    Set Suite Variable    ${CHECKS_REPORT}    sdwan_baseline_checks_start_of_test.txt
    initialize logging to "${CHECKS_REPORT}"
    activate report "${CHECKS_REPORT}"
    baseline set test title  SD-WAN Baseline Checks at Start of Test - Validate the network meets the defined baseline
    baseline set test comment  This file contains the sdwan baseline checks run at the start of the test to confirm the network meets the defined baseline before proceeding with the main test case procedure.

sdwan baseline checks end of test create text report
    Set Suite Variable    ${CHECKS_REPORT}    sdwan_baseline_checks_end_of_test.txt
    initialize logging to "${CHECKS_REPORT}"
    activate report "${CHECKS_REPORT}"
    baseline set test title  SD-WAN Post Test Baseline Checks - Validate the network meets the defined baseline
    baseline set test comment  This file contains the sdwan baseline checks run at the end of the test to confirm the network still meets the defined baseline after completing the main test case procedure.
