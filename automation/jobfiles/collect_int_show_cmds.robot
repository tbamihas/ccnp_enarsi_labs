*** Settings ***
Documentation       Collect generic Interface show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect Interface Show CMDs
    [Tags]    interface-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect Interface Configurations    ${device}
    END