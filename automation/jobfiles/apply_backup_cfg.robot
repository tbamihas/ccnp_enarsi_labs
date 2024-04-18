*** Settings ***
Documentation       Apply backup config to target lab.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Apply Backup Configuration To Lab
    [Tags]    apply-backup-cfg

    FOR    ${device}    IN    @{lab_devices}
        Apply Backup Config on Device    ${device}
    END