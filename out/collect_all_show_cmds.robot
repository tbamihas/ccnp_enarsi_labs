*** Settings ***
Documentation       Collect generic show commands on all lab devices.

Resource            ${EXECDIR}/automation/resources/settings.robot
Variables           ${EXECDIR}/automation/resources/variables.yaml

Suite Setup    Setup

*** Test Cases ***
1 - Collect running-config Show CMD
    [Tags]    running-config-show-cmd

    FOR    ${device}    IN    @{lab_devices}
        Collect running-config Configurations    ${device}
    END

2 - Collect Interface Show CMDs
    [Tags]    interface-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect Interface Configurations    ${device}
    END

3 - Collect OSPF Show CMDs
    [Tags]    ospf-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect OSPF Show Commands with Interfaces    ${device}
    END

4 - Collect EIGRP Show CMDs
    [Tags]    eigrp-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect EIGRP Show Commands with Interfaces    ${device}
    END

5 - Collect BGP Show CMDs
    [Tags]    bgp-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect BGP Show Commands    ${device}
        Collect BGP Interface Show Commands    ${device}
    END

6 - Collect VPN Show CMDs
    [Tags]    vpn-show-cmds

    FOR    ${device}    IN    @{lab_devices}
        Collect VPN Show Commands    ${device}
    END
