*** Keywords ***
Setup
    ${TESTBED}=    Set Variable    ${EXECDIR}/automation/resources/testbed.yaml
    Load Testbed "${TESTBED}"
    Call home set customer pid to "1"

Apply Baseline Config on Device
    [Arguments]    ${device}    ${type}
    [Documentation]    Get baseline config from Git repo, save to disko:git_min.cfg, and load it.
    ...                Valid input for ${type}: v4 | v6 | mixed
    Log    Uploading cfg file on ${device} at: flash:/git_min.cfg    console=True

    # upload baseling config to device
    Connect to device "${device}"
    ${min_cfg_file}=    Set Variable
    ...    ${EXECDIR}/labs/${type}/min_cfgs/${device}_min_cfg_${type}.txt
    ${ip}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    ip
    ${username}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    username
    ${password}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    password
    ${scp_command}=    Set Variable    sshpass -p ${password} scp ${min_cfg_file} ${username}@${ip}:flash:/git_min.cfg
    Run    ${scp_command}

    # Copy file "${min_cfg_file}" to device "${device}" as "/flash/git_min.cfg" using ftp
    Log  Baseline config uploaded    console=yes
    ${min_cfg}=    run "more flash:/git_min.cfg"
    Log    Applying 'more flash:/git_min.cfg' on ${device}:\n${min_cfg}    console=yes

    # check cfg file exists and replace running-cfg
    ${out}=    Run "dir flash:/git_min.cfg"
    IF    "(File not found)" in """${out}"""
        FAIL    Could not find file flash:/git_min.cfg on device ${device}
    END
    run "terminal monitor"
    run "terminal length 0"
    run "configure replace flash:/git_min.cfg force"
    run "copy run start" and sendline "startup-config" to prompt matching pattern "Destination filename"
    Log  Running and startup configs replaced, baseline deployment finished on ${device}.    console=yes

Apply Backup Config on Device
    [Arguments]    ${device}
    [Documentation]    Get baseline config from backup dir in Git repo, save to disko:git_min.cfg, and load it.

    Log    Uploading cfg file on ${device} at: flash:/git_min.cfg    console=True

    # get backup dir name from env var
    ${backup_dir}=    Get Environment Variable    BACKUP_DIR

    ${backup_dir_path}=    Set Variable    ${EXECDIR}/labs/backup_configs/${backup_dir}
    # upload baseling config to device
    Connect to device "${device}"
    ${min_cfg_file}=    Set Variable
    ...    ${backup_dir_path}/${device}_cfg.txt
    ${ip}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    ip
    ${username}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    username
    ${password}=    Get From Dictionary    ${devices['${device}']['connections']['vty']}    password
    ${scp_command}=    Set Variable    sshpass -p ${password} scp ${min_cfg_file} ${username}@${ip}:flash:/git_min.cfg
    Run    ${scp_command}

    # Copy file "${min_cfg_file}" to device "${device}" as "/flash/git_min.cfg" using ftp
    Log  Backup config uploaded    console=yes
    ${min_cfg}=    run "more flash:/git_min.cfg"
    Log    Applying 'more flash:/git_min.cfg' on ${device}:\n${min_cfg}    console=yes

    # check cfg file exists and replace running-cfg
    ${out}=    Run "dir flash:/git_min.cfg"
    IF    "(File not found)" in """${out}"""
        FAIL    Could not find file flash:/git_min.cfg on device ${device}
    END
    run "terminal monitor"
    run "terminal length 0"
    run "configure replace flash:/git_min.cfg force"
    run "copy run start" and sendline "startup-config" to prompt matching pattern "Destination filename"
    Log  Running and startup configs replaced, backup deployment finished on ${device}.    console=yes

Create Backup Directory
    [Documentation]    Creates a backup directory to store the device configs.

    # grab user dir id from env var
    ${dir_id}=    Get Environment Variable    DIR_ID    default=Backup_generic

    # create directory name based on date and time
    ${date}=    Get Current Date    result_format=%d-%m-%Y
    ${directory_name}=    Set Variable    lab_backup_${date}_${dir_id}
    ${backup_dir}=    Set Variable    ${EXECDIR}/labs/backup_configs/${directory_name}

    # create directory and set correct persmissions
    Create Directory    ${backup_dir}
    ${command}=    Set Variable    chmod 775 ${backup_dir}
    Run    ${command}

    # log files created
    Log    Created backup directory: ~/labs/backup_configs/${directory_name}    console=True
    RETURN    ${backup_dir}

Take Device Config Backup and Store to Git Repo
    [Arguments]    ${device}    ${backup_dir}
    [Documentation]    Grabs the current configuration from each device and creates a directory
    ...                based on the current date to store it.
    Log    Backing up current configuration on ${device}    console=True

    # create device backup filename
    ${device_backup_filename}=    Set Variable    ${device}_cfg.txt
    ${backup_file_path}=    Set Variable    ${backup_dir}/${device_backup_filename}

    # connect to device and grab running config
    Connect to device "${device}"
    run "terminal length 0"
    ${cfg}=    run "show run"

    # store config to designated file and set correct permissions
    Create File    ${backup_file_path}    content=${cfg}
    ${command}=    Set Variable    chmod 664 ${backup_file_path}
    Run    ${command}

    # log files created
    Log    Created backup cfg file: ${backup_file_path}   console=True

Test Device Connectivity
    [Arguments]    ${device}
    [Documentation]    Connects to a device to test the vty lines.
    Log    Attempting to connect to: ${device}    console=True

    # connect to device and grab running config
    TRY
        Connect to device "${device}"
        ${show_cmd}=  Set Variable  show ip int br
        ${cfg}=    run "${show_cmd}"
        Log    ===========================================================================    console=True
        Log    Show command: ${show_cmd}    console=True
        Log    Captured output on ${device}:\n${cfg}    console=True
        Log    ===========================================================================    console=True

    EXCEPT
        Log    Failed to connect to: ${device}    console=True
        FAIL    Failed to connect to: ${device}
    END

Deploy Clean Mgmt
    [Arguments]    ${device}
    [Documentation]    Swaps the default-route to the clean network.

    # connect to device and change default route
    TRY
        Connect to device "${device}"
        run "conf t"
        run "ip route 10.0.0.0 255.0.0.0 10.53.217.1"
        run "no ip route 10.0.0.0 255.0.0.0 3.1.0.254"
        Log    Changed default route on: ${device}    console=True
    EXCEPT
        Log    Failed to change default route on: ${device}    console=True
    END

Deploy Dirty Mgmt
    [Arguments]    ${device}
    [Documentation]    Swaps the default-route to the dirty network.

    # connect to device and change default route
    TRY
        Connect to device "${device}"
        run "conf t"
        run "ip route 10.0.0.0 255.0.0.0 3.1.0.254"
        run "no ip route 10.0.0.0 255.0.0.0 10.53.217.1"
        Log    Changed default route on: ${device}    console=True
    EXCEPT
        Log    Failed to change default route on: ${device}    console=True
    END

Collect OSPF Show Commands with Interfaces
    [Arguments]    ${device}
    [Documentation]    Collects various OSPF show commands and interface-specific OSPF information for verification and troubleshooting.

    Connect to device "${device}"
    @{interfaces}=    Get From Dictionary    ${device_interfaces}    ${device}

    # General OSPF commands
    @{OSPF_COMMANDS}=    Create List
    ...    show ip protocols
    ...    show ip ospf
    ...    show ip ospf neighbor
    ...    show ip ospf interface
    ...    show ip route ospf
    FOR    ${cmd}    IN    @{OSPF_COMMANDS}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show Command: ${cmd}    console=True
        Log    Captured output on ${device}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

    # Interface-specific OSPF commands
    FOR    ${interface}    IN    @{interfaces}
        ${cmd}=    Set Variable    show ip ospf interface ${interface}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show Command: ${cmd}    console=True
        Log    Captured output on ${device} for ${interface}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

Collect EIGRP Show Commands with Interfaces
    [Arguments]    ${device}
    [Documentation]    Collects various EIGRP show commands and interface-specific EIGRP information for verification and troubleshooting.

    Connect to device "${device}"
    @{interfaces}=    Get From Dictionary    ${device_interfaces}    ${device}

    # General EIGRP commands
    @{EIGRP_COMMANDS}=    Create List
    ...    show ip protocols
    ...    show ip eigrp neighbors
    ...    show ip eigrp topology
    ...    show ip eigrp interfaces
    ...    show ip route eigrp
    FOR    ${cmd}    IN    @{EIGRP_COMMANDS}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show Command: ${cmd}    console=True
        Log    Captured output on ${device}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

    # Interface-specific EIGRP commands
    FOR    ${interface}    IN    @{interfaces}
        ${cmd}=    Set Variable    show ip eigrp interface ${interface}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show Command: ${cmd}    console=True
        Log    Captured output on ${device} for ${interface}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

Collect BGP Show Commands
    [Arguments]    ${device}
    [Documentation]    Collects various BGP show commands for verification and troubleshooting.

    Connect to device "${device}"
    @{BGP_COMMANDS}=    Create List
    ...    show ip protocols
    ...    show ip bgp summary
    ...    show ip bgp neighbors
    ...    show ip bgp
    FOR    ${cmd}    IN    @{BGP_COMMANDS}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show command: ${cmd}    console=True
        Log    Captured output on ${device}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

Collect BGP Interface Show Commands
    [Arguments]    ${device}
    [Documentation]    Collects BGP-related interface information for verification and troubleshooting.

    Connect to device "${device}"
    @{interfaces}=    Get From Dictionary    ${device_interfaces}    ${device}

    # Check BGP interfaces for any specific BGP-related configurations or states
    FOR    ${interface}    IN    @{interfaces}
        ${cmd}=    Set Variable    show run interface ${interface} | include bgp
        ${output}=    run "${cmd}"
        IF    '${output}' != '${EMPTY}'
            Log    ==================================================================    console=True
            Log    Show Command ${cmd}    console=True
            Log    Captured output on ${device} for ${interface}:\n${output}    console=True
            Log    ==================================================================    console=True
        END
    END

Collect VPN Show Commands
    [Arguments]    ${device}
    [Documentation]    Collects various VPN show commands for verification and troubleshooting.

    Connect to device "${device}"
    @{VPN_COMMANDS}=    Create List
    ...    show crypto isakmp sa
    ...    show crypto ipsec sa
    ...    show dmvpn
    FOR    ${cmd}    IN    @{VPN_COMMANDS}
        ${output}=    run "${cmd}"
        Log    ==================================================================    console=True
        Log    Show command: ${cmd}    console=True
        Log    Captured output on ${device}:\n${output}    console=True
        Log    ==================================================================    console=True
    END

Collect Interface Configurations
    [Arguments]    ${device}
    [Documentation]    Collects the running configuration for specified interfaces on the device.
    Connect to device "${device}"
    @{interfaces}=    Get From Dictionary    ${device_interfaces}    ${device}
    FOR    ${interface}    IN    @{interfaces}
        ${show_cmd}=    Set Variable    show running-config interface ${interface}
        ${cfg}=    run "${show_cmd}"
        Log    ==================================================================    console=True
        Log    Show command: ${show_cmd}    console=True
        Log    Captured output on ${device} for ${interface}:\n${cfg}    console=True
        Log    ==================================================================    console=True
    END

Collect running-config Configurations
    [Arguments]    ${device}
    [Documentation]    Collects the running configuration for specified interfaces on the device.
    Connect to device "${device}"
    ${show_cmd}=    Set Variable    show running-config
    ${cfg}=    run "${show_cmd}"
    Log    ==================================================================    console=True
    Log    Show command: ${show_cmd}    console=True
    Log    Captured output on ${device}:\n${cfg}    console=True
    Log    ==================================================================    console=True
