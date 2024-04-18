*** Settings ***
Documentation       Apply baseline config to target lab.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Apply Baseline Configuration To Lab
    [Tags]    apply-baseline-mixed

    FOR    ${device}    IN    @{lab_devices}
        Apply Baseline Config on Device    ${device}    mixed
    END