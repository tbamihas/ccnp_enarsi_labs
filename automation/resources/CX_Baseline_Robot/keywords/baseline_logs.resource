*** Settings ***
Resource    ../cx_baseline_robot.resource

################################################################################
#
#
#
#     Keywords in this file
#
# baseline logs check for any unusual logs
# baseline logs check last 100 logs for any unusual logs
# baseline logs get start time for use in post test checks
#
#
#
################################################################################


*** Variables ***


*** Keywords ***
######################  Logs  #######################

baseline logs check for any unusual logs
    [Documentation]  Create the global/suite dictionary variable 'times_for_log' if you want to check the logs from a certain time. You can use the keyword 'baseline logs get start time for use in post test checks' to do this for you.
    ...              This keyword will raise a waring if any of the following is found in the logs: traceback, crash, dump, warning, error, fatal, fail
    ...
    ...              Example:
    ...
    ...              baseline logs get start time for use in post test checks
    ...              baseline logs check for any unusual logs
    [Arguments]  ${NODES_TO_CHECK}
    ${BASELINE_LOGS_INCLUDE_CHECK_END_TEST_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LOGS_INCLUDE_CHECK_END_TEST}
    IF  ${BASELINE_LOGS_INCLUDE_CHECK_END_TEST_exists}
      IF  not ${BASELINE_LOGS_INCLUDE_CHECK_END_TEST}
        baseline set test title  Check for any unusual logs - SKIPPED
        Return From Keyword
      END
    END
    ${BASELINE_LOGS_STRICT_CHECK_END_TEST_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LOGS_STRICT_CHECK_END_TEST}
    IF  not ${BASELINE_LOGS_STRICT_CHECK_END_TEST_exists}
      ${BASELINE_LOGS_STRICT_CHECK_END_TEST}=  Set Variable  ${FALSE}
    END

    baseline set test title  Check for any unusual logs
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline logs iosxr check for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_END_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        baseline logs iosxe check for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_END_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline logs nxos check for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_END_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        baseline set test comment  [SKIP] Check for any unusual logs: ${device} : Skip check, log checks are currently not available on IOS devices
      END
    END

baseline logs iosxr check for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    #disable report logging
    #${output}=  run "show logging start ${times_for_log}[${device}]"
    #activate report "${CHECKS_REPORT}"
    #baseline set test comment  run on device '${device}' : show logging start ${times_for_log}[${device}] :\n${output}
    ${output}=  run "show logging start ${times_for_log}[${device}]"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output.split("Log Buffer")[1]}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging start ${times_for_log}[${device}]'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging start ${times_for_log}[${device}]'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging start ${times_for_log}[${device}]'. Recommend test engineer to check.
    END

baseline logs iosxe check for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    #${output}=  run "show logging start ${times_for_log}[${device}]"
    ${output}=  run "show logging last 500"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output.split("Log Buffer")[1]}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging last 500'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging last 500'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging last 500'. Recommend test engineer to check.
    END


baseline logs nxos check for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    #${output}=  run "show logging start ${times_for_log}[${device}]"
    ${output}=  run "show logging last 500"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging last 500'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging last 500'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging last 500'. Recommend test engineer to check.
    END

baseline logs check last 100 logs for any unusual logs
    [Documentation]  This keyword will raise a waring if any of the following is found in the most recent 100 logs: traceback, crash, dump, warning, error, fatal, fail
    ...
    ...              Example:
    ...
    ...              baseline logs check last 100 logs for any unusual logs
    [Arguments]  ${NODES_TO_CHECK}
    ${BASELINE_LOGS_INCLUDE_CHECK_START_TEST_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LOGS_INCLUDE_CHECK_START_TEST}
    IF  ${BASELINE_LOGS_INCLUDE_CHECK_START_TEST_exists}
      IF  not ${BASELINE_LOGS_INCLUDE_CHECK_START_TEST}
        baseline set test title  Check last 100 logs for any unusual logs - SKIPPED
        Return From Keyword
      END
    END
    ${BASELINE_LOGS_STRICT_CHECK_START_TEST_exists}=  Run Keyword And Return Status  Variable Should Exist  ${BASELINE_LOGS_STRICT_CHECK_START_TEST}
    IF  not ${BASELINE_LOGS_STRICT_CHECK_START_TEST_exists}
      ${BASELINE_LOGS_STRICT_CHECK_START_TEST}=  Set Variable  ${FALSE}
    END

    baseline set test title  Check last 100 logs for any unusual logs
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline logs iosxr check last 100 logs for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_START_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe"
        baseline logs iosxe check last 100 logs for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_START_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "nxos"
        baseline logs nxos check last 100 logs for any unusual logs  ${device}  ${BASELINE_LOGS_STRICT_CHECK_START_TEST}
      ELSE IF  "${NODES_TYPE['${device}']}" == "ios"
        baseline set test comment  [SKIP] Check for any unusual logs: ${device} : Skip check, log checks are currently not available on IOS devices
      END
    END

baseline logs iosxr check last 100 logs for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check last 100 logs for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    #disable report logging
    #${output}=  run "show logging last 100"
    #activate report "${CHECKS_REPORT}"
    #baseline set test comment  run on device '${device}' : show logging last 100 :\n${output}
    ${output}=  run "show logging last 100"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output.split("Log Buffer")[1]}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging last 100'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    END

baseline logs iosxe check last 100 logs for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check last 100 logs for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    ${output}=  run "show logging last 100"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output.split("Log Buffer")[1]}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging last 100'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    END

baseline logs nxos check last 100 logs for any unusual logs
    [Documentation]  Child keyword for 'baseline logs check last 100 logs for any unusual logs'.
    [Arguments]  ${device}  ${strict_check}=${FALSE}
    ${output}=  run "show logging last 100"
    ${unusual_log_not_found}=  Run Keyword and Return Status  Should Not Match Regexp  ${output}  (?i)traceback|(?i)crash|(?i)dump|(?i)warning|(?i)error|(?i)fatal|(?i)fail
    IF  ${unusual_log_not_found}
      baseline set test pass  [PASS] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Pass, no unusual logs detected in output from 'show logging last 100'
    ELSE IF  ${strict_check}
      baseline set test fail  [FAIL] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Failure, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    ELSE
      baseline set test warn  [WARN] Check for any unusual logs (traceback, crash, dump, warning, error, fatal, fail) : ${device} : Warning, one or more unusual logs detected in output from 'show logging last 100'. Recommend test engineer to check.
    END

baseline logs get start time for use in post test checks
    [Documentation]  This keyword will save the current time from the devices in a suite dictionary variable named 'times_for_log', which can be used in the keyword 'baseline logs check for any unusual logs' in the baseline checks at end of test
    [Arguments]  ${NODES_TO_CHECK}
    baseline set test title  Get start time for use in post test checks
    FOR  ${device}  IN  @{NODES_TO_CHECK}
      connect to device "${device}"
      IF  "${NODES_TYPE['${device}']}" == "cXR" or "${NODES_TYPE['${device}']}" == "eXR" or "${NODES_TYPE['${device}']}" == "LNTXR"
        baseline logs iosxr get start time for use in post test checks  ${device}
      ELSE IF  "${NODES_TYPE['${device}']}" == "iosxe" or "${NODES_TYPE['${device}']}" == "ios" or "${NODES_TYPE['${device}']}" == "nxos"
        baseline set test comment  [SKIP] Get start time for use in post test checks: ${device} : Skip, log checks are currently not available on IOS XE or IOS or NXOS devices
      END
    END

baseline logs iosxr get start time for use in post test checks
    [Documentation]  Child keyword for 'baseline logs get start time for use in post test checks'.
    [Arguments]  ${device}
    run "show clock"
    ${times_for_log_exists}=  Run Keyword And Return Status  Variable Should Exist  ${times_for_log}
    IF  not ${times_for_log_exists}
      ${times_for_log}=  Create Dictionary
    END
    ${show_clock_time}=  extract pattern "\\d+:\\d+:\\d+\\.\\d+ \\S+ \\w+ \\w+ \\d+ \\d+"
    ${time}=  Get Regexp Matches  ${show_clock_time}  (\\+)*\\w+
    ${time}=  Create Dictionary  hour=${time}[0]  minute=${time}[1]  second=${time}[2]  millisecond=${time}[3]  time_zone=${time}[4]  week_day=${time}[5]  month=${time}[6]  day=${time}[7]  year=${time}[8]
    ${time}=  Catenate  ${time}[year]  ${time}[month]  ${time}[day]  ${time}[hour]:${time}[minute]:${time}[second]
    IF  "${device}" not in "${times_for_log}"
      Set To Dictionary  ${times_for_log}  ${device}=${time}
      baseline set test comment  Time saved for use in post test checks (in show logging command) : ${device} : ${time}
    END
    Set Suite Variable  ${times_for_log}
