*** Settings ***
Resource    ../cx_baseline_robot.resource

*** Keywords ***

################################################################################
#     Keywords in this file
#
# baseline setup with no checks
# baseline setup with checks for selected devices
#
# baseline setup create text report
# baseline setup run call home keywords
#
################################################################################

baseline setup with no checks
    [Documentation]  Run this keyword to start your test in the setup phase. Does not include any baseline checks.
    ...              Includes the 'call home', 'load testbed' and 'create text report' keywords.
    ...              By default will use the path defined in global/suite variable 'TB_YAML'. Otherwise you will need to pass the argument.
    ...
    ...              Examples:
    ...              Set Suite Variable  ${TB_YAML}  data/topology/topology_file.yaml
    ...              baseline setup with no checks
    ...              baseline setup with no checks  TB_YAML=data/topology/topology_file.yaml
    [Arguments]  ${TB_YAML}=automation/resources/testbed_clean.yaml
    baseline setup run call home keywords
    load testbed "${EXECDIR}/${TB_YAML}"
    baseline setup create text report



baseline setup with checks for selected devices
    [Documentation]  Run this keyword to start your test in the setup phase. Includes running baseline checks on the selected devices.
    ...              Can pass the 'devices' argument as either a list variable or a semi-colon ; or comma , separated string variable
    ...              Includes the 'call home', 'load testbed' and 'create text report' keywords.
    ...              By default will use the path defined in global/suite variable 'TB_YAML'. Otherwise you will need to pass the argument.
    ...
    ...              Examples:
    ...              Set Suite Variable  ${TB_YAML}  data/topology/topology_file.yaml
    ...              baseline setup with checks for selected devices  devices=ROUTER_A;ROUTER_B
    ...              baseline setup with checks for selected devices  devices=ROUTER_A;ROUTER_B  TB_YAML=data/topology/topology_file.yaml
    ...              ${device_list}=  Create List  ROUTER_A  ROUTER_B
    ...              baseline setup with checks for selected devices  devices=${device_list}  TB_YAML=data/topology/topology_file.yaml
    [Arguments]  ${devices}  ${TB_YAML}=${TB_YAML}
    baseline setup run call home keywords
    load testbed "${EXECDIR}/${TB_YAML}"
    baseline setup create text report
    ${devices_type}=  Evaluate  type($devices).__name__
    IF  "${devices_type}" != "list"
      ${NODES_TO_CHECK}=  Replace String  ${devices}  ,  ;
      ${NODES_TO_CHECK}=  Split String  ${NODES_TO_CHECK}  ;
    ELSE
      ${NODES_TO_CHECK}=  Set Variable  ${devices}
    END
    baseline checks start of test  NODES_TO_CHECK=${NODES_TO_CHECK}




baseline setup create text report
    [Documentation]  Creates a text file report. This keyword will create for you a suite variable called 'REPORT' which you can refer to in your jobfile if needed.
    ...              If you create the global/suite variable TEST_ID, this will be used for the text file name. Otherwise the filename will be 'report.txt'
    ...              If you create the global/suite variable TEXT_REPORT_TITLE, this will be used as the title (appear at top of page). Otherwise will be 'Text Report'
    ...              If you create the global/suite variable TEXT_REPORT_DESCRIPTION, this will be added to the top of the page, below the title.
    ...
    ...              Examples:
    ...              \# Optionally create the following variables for the text report creation
    ...              Set Suite Variable  ${TEST_ID}  IOSXR_BGP_01
    ...              Set Suite Variable  ${TEXT_REPORT_TITLE}  Testing BGP on IOSXR
    ...              Set Suite Variable  ${TEXT_REPORT_DESCRIPTION}  Testing BGP on IOSXR
    ...              baseline setup create text report
    ${TEST_ID_exists}=  Run Keyword And Return Status  Variable Should Exist  ${TEST_ID}
    IF  ${TEST_ID_exists}
      Set Suite Variable    ${REPORT}    ${TEST_ID}.txt
    ELSE
      Set Suite Variable    ${REPORT}    report.txt
    END
    initialize logging to "${REPORT}"
    activate report "${REPORT}"
    ${TEXT_REPORT_TITLE_exists}=  Run Keyword And Return Status  Variable Should Exist  ${TEXT_REPORT_TITLE}
    IF  ${TEXT_REPORT_TITLE_exists}
      baseline set test title  ${TEXT_REPORT_TITLE}
    ELSE
      baseline set test title  Text Report
    END
    ${TEXT_REPORT_DESCRIPTION_exists}=  Run Keyword And Return Status  Variable Should Exist  ${TEXT_REPORT_DESCRIPTION}
    IF  ${TEXT_REPORT_DESCRIPTION_exists}
      baseline set test comment  ${TEXT_REPORT_DESCRIPTION}
    END


baseline setup run call home keywords
    [Documentation]  Checks if you have the variables 'CUSTOMER_PID' and 'CUSTOMER_NAME' created. If yes, then will run the cxta call home keywords.
    ...
    ...              Examples:
    ...              \# Optionally create the following variables for the text report creation
    ...              Set Suite Variable  ${CUSTOMER_PID}  123456
    ...              Set Suite Variable  ${CUSTOMER_NAME}  My Customer Name
    ...              baseline setup run call home keywords
    ${CUSTOMER_PID_exists}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOMER_PID}
    IF  ${CUSTOMER_PID_exists}
      call home set customer pid to "${CUSTOMER_PID}"
    END
    ${CUSTOMER_NAME_exists}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOMER_NAME}
    IF  ${CUSTOMER_NAME_exists}
      call home set customer name to "${CUSTOMER_NAME}"
    END
