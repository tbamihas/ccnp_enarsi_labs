*** Settings ***
Resource    textfsm/textfsm.resource
Resource    keywords/_checks.resource
Resource    keywords/_setup.resource
Resource    keywords/_teardown.resource
Resource    keywords/baseline_bfd.resource
Resource    keywords/baseline_bgp.resource
Resource    keywords/baseline_cdp.resource
Resource    keywords/baseline_configuration.resource
Resource    keywords/baseline_cpu.resource
Resource    keywords/baseline_hardware.resource
Resource    keywords/baseline_interfaces.resource
Resource    keywords/baseline_isis.resource
Resource    keywords/baseline_l2vpn.resource
Resource    keywords/baseline_ldp.resource
Resource    keywords/baseline_multicast.resource
Resource    keywords/baseline_logs.resource
Resource    keywords/baseline_memory.resource
Resource    keywords/baseline_mpls_te.resource
Resource    keywords/baseline_ospf.resource
Resource    keywords/baseline_route_scale.resource
Resource    keywords/baseline_software.resource
Resource    keywords/baseline_srte.resource
Resource    create_data/create_baseline_data_keywords.resource
Resource    keywords/sdwan/_sdwan_checks.resource
Resource    keywords/sdwan/_sdwan_setup.resource
Resource    keywords/sdwan/_sdwan_teardown.resource
Resource    keywords/sdwan/sdwan_baseline_configuration.resource
Resource    keywords/sdwan/sdwan_baseline_control_connections.resource
Resource    keywords/sdwan/sdwan_baseline_omp.resource
Resource    keywords/sdwan/sdwan_baseline_certificate.resource

*** Keywords ***
baseline set test pass
    [Arguments]  ${comment}
    Log     ${comment}    console=yes
    Run Keyword And Ignore Error  add report comment "${comment}"

baseline set test fail
    [Arguments]  ${comment}
    Run Keyword And Continue On Failure    Fail    ${comment}
    Run Keyword And Ignore Error  add report comment "${comment}"
    Log     ${comment}    console=yes

baseline set test warn
    [Arguments]  ${comment}
    Log     ${comment}    WARN    console=yes
    Run Keyword And Ignore Error  add report comment "${comment}"

baseline set test comment
    [Arguments]  ${comment}
    Log     ${comment}    console=yes
    Run Keyword And Ignore Error  add report comment "${comment}"

baseline set test title
    [Arguments]  ${title}
    Log     ${title}
    Run Keyword And Ignore Error  add report line break
    Run Keyword And Ignore Error  add report title "${title}"
    Log To Console     \n========== ${title} ==========\n
