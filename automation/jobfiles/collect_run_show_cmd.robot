*** Settings ***
Documentation       Collect running-config show command on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Collect running-config Show CMD
    [Tags]    running-config-show-cmd

    FOR    ${device}    IN    @{lab_devices}
        Collect running-config Configurations    ${device}
    END