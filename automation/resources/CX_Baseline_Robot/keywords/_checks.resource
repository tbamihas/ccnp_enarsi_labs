*** Settings ***
Resource    ../cx_baseline_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# baseline checks start of test
# baseline checks end of test
# baseline cpu memory log checks end of test
#
################################################################################

baseline checks start of test
    [Arguments]  ${NODES_TO_CHECK}  ${REPORT}=${REPORT}
    Set Suite Variable  ${TEST_STATUS}  ${TRUE}
    activate report "${REPORT}"
    baseline set test title  Baseline Checks at Start of Test - Validate the network meets the defined baseline
    baseline set test comment  See file baseline_checks_start_of_test.txt for full list of checks performed
    baseline checks start of test create text report

    baseline configuration validate config of devices is same as the master configuration  ${NODES_TO_CHECK}
    baseline software validate correct software version is installed as per defined baseline  ${NODES_TO_CHECK}
    baseline software validate correct software packages are installed as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct hardware platform as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct hardware modules are up as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct inventory output as per defined baseline  ${NODES_TO_CHECK}
    baseline interfaces validate interfaces are up as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate correct isis neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate minimum isis neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate minimum isis lsp scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ospf validate correct ospf neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline ospf validate correct ospfv3 neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum routing table scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate correct ldp neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum tldp neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp local bindings scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp remote bindings scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bgp validate correct bgp neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline bgp validate minimum bgp route scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bfd validate minimum bfd ipv4 scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bfd validate minimum bfd ipv6 scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN XC scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate minimum SRTE scale as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate pce ipv4 peers are up as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline  ${NODES_TO_CHECK}
    baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline  ${NODES_TO_CHECK}
    baseline multicast validate correct pim neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline multicast validate minimum pim neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum mrib route scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline cpu validate recent cpu usage is reasonable  ${NODES_TO_CHECK}
    baseline memory collect memory commands  ${NODES_TO_CHECK}
    baseline logs get start time for use in post test checks  ${NODES_TO_CHECK}
    baseline logs check last 100 logs for any unusual logs  ${NODES_TO_CHECK}

    baseline set test title  End of Baseline Checks at Start of Test
    activate report "${REPORT}"
    IF  ${TEST_STATUS}
      baseline set test pass  [PASS] Baseline Checks at Start of Test have passed, the network meets the defined baseline criteria. Test case execution will continue. See file baseline_checks_start_of_test.txt for more details.
    ELSE
      baseline set test fail  [FAIL] Baseline Checks at Start of Test have failed, the network does NOT meet the defined baseline criteria. Test case execution will be halted. See file baseline_checks_start_of_test.txt for more details.
    END


baseline checks end of test
    [Arguments]  ${NODES_TO_CHECK}  ${REPORT}=${REPORT}
    Set Global Variable  ${TEST_STATUS}  ${TRUE}
    activate report "${REPORT}"
    baseline set test title  Baseline Checks at End of Test - Validate the network meets the defined baseline
    baseline set test comment  See file baseline_checks_end_of_test.txt for full list of checks performed
    baseline checks end of test create text report

    baseline configuration validate config of devices is same as the master configuration  ${NODES_TO_CHECK}
    baseline software validate correct software version is installed as per defined baseline  ${NODES_TO_CHECK}
    baseline software validate correct software packages are installed as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct hardware platform as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct hardware modules are up as per defined baseline  ${NODES_TO_CHECK}
    baseline hardware validate correct inventory output as per defined baseline  ${NODES_TO_CHECK}
    baseline interfaces validate interfaces are up as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate correct isis neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate minimum isis neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline isis validate minimum isis lsp scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ospf validate correct ospf neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline ospf validate correct ospfv3 neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum routing table scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum ipv6 routing table scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate correct ldp neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp local bindings scale as per defined baseline  ${NODES_TO_CHECK}
    baseline ldp validate minimum ldp remote bindings scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bgp validate correct bgp neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline bgp validate minimum bgp route scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bfd validate minimum bfd ipv4 scale as per defined baseline  ${NODES_TO_CHECK}
    baseline bfd validate minimum bfd ipv6 scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN XC scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD PW scale as per defined baseline  ${NODES_TO_CHECK}
    baseline L2VPN validate minimum L2VPN BD AC scale as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate minimum SRTE scale as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate pce ipv4 peers are up as per defined baseline  ${NODES_TO_CHECK}
    baseline srte validate segment routing pcc ipv4 peers are up as per defined baseline  ${NODES_TO_CHECK}
    baseline mpls_te validate minimum mpls traffic-eng scale as per defined baseline  ${NODES_TO_CHECK}
    baseline multicast validate correct pim neighbors are up as per defined baseline  ${NODES_TO_CHECK}
    baseline multicast validate minimum pim neighbor scale as per defined baseline  ${NODES_TO_CHECK}
    baseline route_scale validate minimum mrib route scale is present as per defined baseline  ${NODES_TO_CHECK}
    baseline cpu validate recent cpu usage is reasonable  ${NODES_TO_CHECK}
    baseline memory collect memory commands  ${NODES_TO_CHECK}
    baseline logs check for any unusual logs  ${NODES_TO_CHECK}

    baseline set test title  End of Baseline Checks at End of Test
    activate report "${REPORT}"
    IF  ${TEST_STATUS}
      baseline set test pass  [PASS] Baseline Checks at End of Test have passed, the network meets the defined baseline criteria. See file baseline_checks_end_of_test.txt for more details.
    ELSE
      baseline set test fail  [FAIL] Baseline Checks at End of Test have failed, the network does NOT meet the defined baseline criteria. See file baseline_checks_end_of_test.txt for more details.
    END


baseline cpu memory log checks end of test
    [Arguments]  ${NODES_TO_CHECK}  ${REPORT}=${REPORT}
    Set Global Variable  ${TEST_STATUS}  ${TRUE}
    activate report "${REPORT}"
    baseline set test title  Baseline Checks at End of Test - Validate cpu, memory and local log buffer
    baseline set test comment  See file baseline_checks_end_of_test.txt for full list of checks performed
    baseline checks end of test create text report

    baseline cpu validate recent cpu usage is reasonable  ${NODES_TO_CHECK}
    baseline memory collect memory commands  ${NODES_TO_CHECK}
    baseline logs check for any unusual logs  ${NODES_TO_CHECK}

    baseline set test title  End of Baseline Checks at End of Test
    activate report "${REPORT}"
    IF  ${TEST_STATUS}
      baseline set test pass  [PASS] Baseline Checks at End of Test have passed, the network meets the defined baseline criteria. See file baseline_checks_end_of_test.txt for more details.
    ELSE
      baseline set test fail  [FAIL] Baseline Checks at End of Test have failed, the network does NOT meet the defined baseline criteria. See file baseline_checks_end_of_test.txt for more details.
    END


baseline checks start of test create text report
    Set Suite Variable    ${CHECKS_REPORT}    baseline_checks_start_of_test.txt
    initialize logging to "${CHECKS_REPORT}"
    activate report "${CHECKS_REPORT}"
    baseline set test title  Baseline Checks at Start of Test - Validate the network meets the defined baseline
    baseline set test comment  This file contains the baseline checks run at the start of the test to confirm the network meets the defined baseline before proceeding with the main test case procedure.

baseline checks end of test create text report
    Set Suite Variable    ${CHECKS_REPORT}    baseline_checks_end_of_test.txt
    initialize logging to "${CHECKS_REPORT}"
    activate report "${CHECKS_REPORT}"
    baseline set test title  Post Test Baseline Checks - Validate the network meets the defined baseline
    baseline set test comment  This file contains the baseline checks run at the end of the test to confirm the network still meets the defined baseline after completing the main test case procedure.
