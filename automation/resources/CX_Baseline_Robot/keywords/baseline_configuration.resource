*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#     Keywords in this file
#
# baseline configuration validate config of devices is same as the master configuration
#
#
################################################################################

*** Variables ***

#${FTP_FOLDER_MASTER}=  /root/config_master/



# The variable ${FTP_SERVER} needs to be defined somewhere in your data files.
# The FTP server should have a folder here ${FTP_FOLDER_MASTER}
# Which should contain config files named like this config_master_${device}.txt
# FOR EXAMPLE:
#  cisco@vftrubuntu:~/config_master$ pwd
#  /home/cisco/config_master
#  cisco@vftrubuntu:~/config_master$ ls -lrt
#  total 1512
#  -rwxr-xr-x 1 cisco cisco  20362 Aug  3 10:07 config_master_P1.txt
#  -rwxr-xr-x 1 cisco cisco  17353 Aug  3 10:07 config_master_P2.txt
#  -rwxr-xr-x 1 cisco cisco 383413 Aug  3 10:07 config_master_PE4.txt
#  cisco@vftrubuntu:~/config_master$

*** Keywords ***
######################  Configuration  #######################

baseline configuration validate config of devices is same as the master configuration
    [Documentation]  This keyword will copy the master configuration files for your devices from a FTP server, then compare the master config to the current config on the device and report any differences as a warning.
    ...              You need to create the global/suite variable 'FTP_SERVER' before calling this keyword.
    [Arguments]  ${NODES_TO_CHECK}  ${CHECKS_REPORT}=${CHECKS_REPORT}
    activate report "${CHECKS_REPORT}"
    ${BASELINE_CONFIG_INCLUDE_CHECK_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_CONFIG_INCLUDE_CHECK}
    IF  ${BASELINE_CONFIG_INCLUDE_CHECK_exists}
      IF  not ${BASELINE_CONFIG_INCLUDE_CHECK}
        baseline set test title  Validate configuration of devices is the same as the master configuration - SKIPPED
        Return From Keyword
      END
    END
    ${BASELINE_CONFIG_STRICT_CHECK_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_CONFIG_STRICT_CHECK}
    IF  not ${BASELINE_CONFIG_STRICT_CHECK_exists}
      ${BASELINE_CONFIG_STRICT_CHECK}=  Set Variable  ${TRUE}
    END

    ${date}=    Get Current Date    result_format=%d%b%Y_%H%M
    baseline set test title  Validate configuration of devices is the same as the master configuration
    baseline set test comment  Configuration of all devices are saved in the following files attached to the results
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      baseline set test comment  config_${date}_${device}.txt
    END
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      disable report logging
      connect to device "${device}"
      ${output}=  run "show run"
      Create File    ${OUTPUTDIR}/config_${date}_${device}.txt    ${output}

      activate report "${CHECKS_REPORT}"

      baseline set test title  Device: ${device} | Running Configuration Comparison
      baseline set test comment  Comparing the current running configuration of device "${device}" to the master template configuration
      copy file "${FTP_FOLDER_MASTER}config_master_${device}.txt" from device "${FTP_SERVER}" using scp
      ${from_config}=  Get File  ${OUTPUTDIR}/config_master_${device}.txt
      ${to_config}=    Get File  ${OUTPUTDIR}/config_${date}_${device}.txt
      log  ${from_config}
      log  ${to_config}

      ${from_config}=  baseline configuration remove misc lines from config for comparison purpose  ${from_config}
      ${to_config}=    baseline configuration remove misc lines from config for comparison purpose  ${to_config}
      log  ${from_config}
      log  ${to_config}


      ${config_diffs}=  diff config "${to_config}" to "${from_config}"
      Log  ${config_diffs[0]}
      Log  ${config_diffs[1]}

      IF  """${config_diffs[0]}""" == "${EMPTY}" and """${config_diffs[1]}""" == "${EMPTY}"
        baseline set test pass  [PASS] ${device} : Config is same between the current configuration and the master template configuration
      END

      IF  """${config_diffs[1]}""" != "${EMPTY}"
        IF  ${BASELINE_CONFIG_STRICT_CHECK}
          baseline set test fail  [FAIL] ${device} : Config in the current configuration has some additions compared to the master template configuration :
        ELSE
          baseline set test warn  [WARN] ${device} : Config in the current configuration has some additions compared to the master template configuration :
        END
      END
      baseline set test comment  ${config_diffs[1]}

      IF  """${config_diffs[0]}""" != "${EMPTY}"
        IF  ${BASELINE_CONFIG_STRICT_CHECK}
          baseline set test fail  [FAIL] ${device} : Config in the current configuration has some deletions compared to the master template configuration :
        ELSE
          baseline set test warn  [WARN] ${device} : Config in the current configuration has some deletions compared to the master template configuration :
        END
      END
      baseline set test comment  ${config_diffs[0]}

      use ciscoconfdiff to compare configs "${to_config}" and "${from_config}"

    END
    activate report "${CHECKS_REPORT}"



baseline configuration remove misc lines from config for comparison purpose
    [Arguments]  ${config}
    # remove misc lines from iosxr config
    ${config}=  Remove String Using Regexp  ${config}  [a-zA-Z]+ [a-zA-Z]+ +\\d+ \\d+:\\d+:\\d+\\.\\d+ \\S+
    ${config}=  Remove String Using Regexp  ${config}  !! Last configuration change at \\w+ \\w+ +\\d+ \\d+:\\d+:\\d+ \\d+ by \\w+
    ${config}=  Remove String Using Regexp  ${config}  Building configuration...
    ${config}=  Remove String Using Regexp  ${config}  interface preconfigure PTP0\\S+[\\r\\n]+ shutdown[\\r\\n]+!
    ${config}=  Remove String Using Regexp  ${config}  interface PTP0\\S+[\\r\\n]+ shutdown[\\r\\n]+!
    ${config}=  Remove String Using Regexp  ${config}  ntp clock\\-period \\d+

    # remove misc lines from nxos config
    ${config}=  Remove String Using Regexp  ${config}  !Time: \\w+ \\w+ \\d+ \\d+:\\d+:\\d+ \\d+

    # remove misc lines from ios config
    ${config}=  Remove String Using Regexp  ${config}  [a-zA-Z]+ [a-zA-Z]+ +\\d+ \\d+:\\d+:\\d+\\.\\d+ [a-zA-Z]+
    ${config}=  Remove String Using Regexp  ${config}  ! Last configuration change at \\d+:\\d+:\\d+ \\w+ \\w+ \\w+ +\\d+ \\d+ by \\w+
    ${config}=  Remove String Using Regexp  ${config}  ! NVRAM config last updated at \\d+:\\d+:\\d+ \\w+ \\w+ \\w+ +\\d+ \\d+ by \\w+
    ${config}=  Remove String Using Regexp  ${config}  Building configuration...
    ${config}=  Remove String Using Regexp  ${config}  Current configuration : \\d+ bytes
    ${config}=  Remove String Using Regexp  ${config}  Time source \\w+ \\w+, \\d+:\\d+:\\d+.\\d+ \\w+ \\w+ \\w+ \\d+ \\d+
    ${config}=  Remove String Using Regexp  ${config}  Load for five secs: \\d+%\\/\\d+%; one minute: \\d+%; five minutes: \\d+%


    [Return]  ${config}
