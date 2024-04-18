*** Settings ***
Documentation       Collect generic OSPF show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect OSPF Show CMDs
    [Tags]    ospf-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect OSPF Show Commands with Interfaces    ${device}
    END