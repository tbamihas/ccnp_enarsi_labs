*** Settings ***

# Copy this jobfile to your project to run

# Run the jobfile like this:
#    cxta path/to/file/Utility_Baseline_Create_Data.robot -n

Metadata    Version     1.0
Metadata    Author      Solution Validation Services Cisco

# Add your project resouce file. This file should link to all your project keyword files, yaml files
Resource    ${EXECDIR}/resources/project.resource

################################################################################
#
# Add any project variables yaml file (if not already linked in above project.resource file)
# Variables   ${EXECDIR}/data/common.yaml
#
# IMPORTANT, this jobfile uses keywords from the following git repo's, they will need to be added into your project for this to work.
# Only need to include here if not already included in above project.resource file
# You will also need to create the baseline data (see the readme file in git repo for more info)
# CX_Baseline_Robot  - https://wwwin-github.cisco.com/SVS-DELIVERY/CX_Baseline_Robot.git
#Resource    ${EXECDIR}/resources/CX_Baseline_Robot/cx_baseline_robot.resource
#
################################################################################

Test Setup       baseline setup with no checks
Test Teardown    Run Keywords
...              baseline create data yaml file
...              AND
...              baseline teardown with no checks

*** Variables ***
################################################################################
#
# These variables should be defined in a global yaml variables file somehwere in your project files
#
# TB_YAML: path/to/topology.yaml                     # this is the location of your topology yaml file. This is the relative path from the EXECDIR. Used in keyword like this: load testbed "${EXECDIR}/${TB_YAML}"
#
# These variables are needed if you include baseline setup/teardown checks (for comparing current configs with the master configs)
# FTP_SERVER: LINUX_HOSTNAME                         # this is the server hostname (as seen in topology yaml file) where you keep config backups and master config
# FTP_FOLDER_BACKUPS: /root/config_backups/          # this is the folder where config backups are kept on the FTP server
# FTP_FOLDER_MASTER:  /root/config_master/           # this is the folder where master configs are kept on the FTP server
#
################################################################################

${TEST_ID}=  Utility_Baseline_Create_Data
${TEXT_REPORT_TITLE}=  Create baseline data for Selected Devices
${TEXT_REPORT_DESCRIPTION}=  Run commands on the devices and extract relevant data. Create baseline yaml file to be used in baseline checks from CX_Baseline_Robot.\n
...                          Yaml file will be created as an artifact called 'baseline_data.yaml' in the output directory.

# !!!!  UPDATE THIS VARIABLE with the devices you want to run baseline checks on
@{DEVICES}=   R1
# If you have the variable 'NODES_ALL' defined in your global yaml variables file, then you can choose to uncomment the line below, and comment out the lines above
#@{DEVICES}=  @{NODES_ALL}

################################################################################
# These are needed to define the device types (valid types are cXR, eXR, iosxe, ios, nxos)
# This should be defined in a global yaml variables file somehwere in your project files
# NODES_TYPE:
#  DEVICE_A: cXR
#  DEVICE_B: eXR
#  DEVICE_C: iosxe
#  DEVICE_D: ios
#  DEVICE_E: nxos
#
################################################################################

*** Test Cases ***
${TEXT_REPORT_TITLE}
    [Tags]    DUT=N/A    Test_type=Utility    Disruptive=No    Traffic=No    Platform=N/A    Technology=N/A    Test_ID=${TEST_ID}
    baseline verify node types are valid
    # Comment in/out what is relevant for your project
    baseline create data for software version
    baseline create data for software packages
    baseline create data for hardware platform
    # baseline create data for hardware modules
    # baseline create data for hardware inventory
    # baseline create data for bfd ipv4 scale
    # baseline create data for bfd ipv6 scale
    # baseline create data for bgp neighbors
    # baseline create data for bgp route scale
    # baseline create data for interfaces up
    #baseline create data for interfaces down
    # baseline create data for isis neighbors
    # baseline create data for isis lsp scale
    # baseline create data for l2vpn xc scale
    # baseline create data for l2vpn bd scale
    # baseline create data for l2vpn bd pw scale
    # baseline create data for l2vpn bd ac scale
    # baseline create data for ldp neighbors
    # baseline create data for ldp local bindings scale
    # baseline create data for ldp remote bindings scale
    # baseline create data for mpls traffic-eng scale
    # baseline create data for ospf neighbors
    # baseline create data for ospfv3 neighbors
    # baseline create data for srte scale
    # baseline create data for srte pce ipv4 peers
    # baseline create data for srte pcc ipv4 peers
    # baseline create data for routing table scale
    # baseline create data for routing table scale ipv6
