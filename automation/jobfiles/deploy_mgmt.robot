*** Settings ***
Documentation       Swap default-route on devices to point towards the clean gateway.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Swap default-route To Clean
    [Tags]    clean-mgmt

    FOR    ${device}    IN    @{lab_devices}
        Deploy Clean Mgmt    ${device}
    END