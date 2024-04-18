*** Settings ***
Documentation       Collect generic BGP show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect BGP Show CMDs
    [Tags]    bgp-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect BGP Show Commands    ${device}
        Collect BGP Interface Show Commands    ${device}
    END