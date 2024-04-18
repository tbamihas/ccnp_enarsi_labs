*** Settings ***
Documentation       Swap default-route on devices to point towards the dirty gateway.

Resource            ${EXECDIR}/automation/resources/settings.robot
Variables           ${EXECDIR}/automation/resources/variables.yaml

Suite Setup    Setup Clean

*** Test Cases ***
Swap default-route To Dirty
    [Tags]    clean-mgmt

    FOR    ${device}    IN    @{lab_devices}
        Deploy Dirty Mgmt    ${device}
    END