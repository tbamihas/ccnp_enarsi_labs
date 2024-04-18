*** Settings ***
Documentation       Apply baseline config to target lab.

Resource            ${EXECDIR}/automation/resources/settings.robot
Variables           ${EXECDIR}/automation/resources/variables.yaml

Suite Setup    Setup Dirty

*** Test Cases ***
Apply Baseline Configuration To Lab
    [Tags]    apply-baseline-v6

    Apply Baseline Config on Device    ${device}    v6