*** Settings ***
Documentation       Collect generic VPN show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect VPN Show CMDs
    [Tags]    vpn-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect VPN Show Commands    ${device}
    END