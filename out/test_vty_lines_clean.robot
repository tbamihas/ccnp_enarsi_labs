*** Settings ***
Documentation       Test VTY lines on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot
Variables           ${EXECDIR}/automation/resources/variables.yaml

Suite Setup    Setup Clean

*** Test Cases ***
Test VTY Lines On All Devices
    [Tags]    test-vty

    FOR    ${device}    IN    @{lab_devices}
        Test Device Connectivity    ${device}
    END