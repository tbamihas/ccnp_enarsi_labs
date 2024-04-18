*** Settings ***
Documentation       Apply baseline config to target lab.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Test Cases ***
Backup Lab Configuration
    [Tags]    lab-backup

    ${backup_dir}=    Create Backup Directory
    FOR    ${device}    IN    @{lab_devices}
        Take Device Config Backup and Store to Git Repo    ${device}    ${backup_dir}
    END