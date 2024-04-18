*** Settings ***
Documentation       Collect generic EIGRP show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect EIGRP Show CMDs
    [Tags]    eigrp-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect EIGRP Show Commands with Interfaces    ${device}
    END