*** Settings ***

*** Variables ***
${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}=  ${CURDIR}/xr_show_route_vrf_summary.textfsm
${XR_SHOW_BGP_SUMMARY_TEMPLATE}=  ${CURDIR}/xr_show_bgp_summary.textfsm
${XR_SHOW_BGP_ALL_SUMMARY_TEMPLATE}=  ${CURDIR}/xr_show_bgp_all_summary.textfsm
${XR_SHOW_BGP_VRF_SUMMARY_TEMPLATE}=  ${CURDIR}/xr_show_bgp_vrf_summary.textfsm
${XR_SHOW_BGP_SCALE_TEMPLATE}=  ${CURDIR}/xr_show_bgp_scale.textfsm
${XR_SHOW_CONFIG_COMMIT_LIST_TEMPLATE}=  ${CURDIR}/xr_show_configuration_commit_list.textfsm
${XR_SHOW_MPLS_LDP_NEIGHBOR_BRIEF_TEMPLATE}=  ${CURDIR}/xr_show_mpls_ldp_neighbor_brief.textfsm

${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}=  ${CURDIR}/xe_show_isis_neighbors.textfsm
${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}=  ${CURDIR}/xe_show_ip_route_summary.textfsm
${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}=  ${CURDIR}/xe_show_ipv6_route_summary.textfsm

${XR_SHOW_RUN_ROUTER_BGP_TEMPLATE}=  ${CURDIR}/xr_show_run_router_bgp.textfsm
${XE_SHOW_RUN_ROUTER_BGP_TEMPLATE}=  ${CURDIR}/xe_show_run_router_bgp.textfsm

${SHOW_INVENTORY_TEMPLATE}=  ${CURDIR}/show_inventory.textfsm

${XE_SDWAN_SHOW_SDWAN_CONTROL_CONNECTIONS_TEMPLATE}=  ${CURDIR}/sdwan/xe_sdwan_show_sdwan_control_connections.textfsm
${VIPTELA_SDWAN_SHOW_CONTROL_CONNECTIONS_TEMPLATE}=  ${CURDIR}/sdwan/viptelaOS_sdwan_show_control_connections.textfsm
${VIPTELA_SDWAN_SHOW_ORCHESTRATOR_CONNECTIONS_TEMPLATE}=  ${CURDIR}/sdwan/viptelaOS_sdwan_show_orchestrator_connections.textfsm
${XE_SDWAN_SHOW_SDWAN_OMP_PEERS_TEMPLATE}=  ${CURDIR}/sdwan/xe_sdwan_show_sdwan_omp_peers.textfsm
${VIPTELA_SDWAN_SHOW_OMP_PEERS_TEMPLATE}=  ${CURDIR}/sdwan/viptelaOS_sdwan_show_omp_peers.textfsm
${XE_SDWAN_SHOW_SDWAN_CERTIFICATE_ROOT_CA_CERT_TEMPLATE}=  ${CURDIR}/sdwan/xe_sdwan_show_sdwan_certificate_root_ca_cert.textfsm
${VIPTELA_SDWAN_SHOW_CERTIFICATE_ROOT_CA_CERT_TEMPLATE}=  ${CURDIR}/sdwan/viptelaOS_sdwan_show_certificate_root_ca_cert.textfsm
*** Keywords ***

################################################################################
#
#     Examples how to use these textfsm templates
#
# ${parsed}=   run parsed "show route vrf xxxx summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
# ${parsed}=   run parsed "show bgp vpnv4 unicast summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
# ${parsed}=   run parsed "show configuration commit list" with template "${XR_SHOW_CONFIG_COMMIT_LIST_TEMPLATE}"
# ${parsed}=   run parsed "show mpls ldp neighbor brief" with template "${XR_SHOW_MPLS_LDP_NEIGHBOR_BRIEF_TEMPLATE}"
#
# ${parsed}=   run parsed "show isis neighbors" with template "${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}"
# ${parsed}=   run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
#
# ${parsed}=   run parsed "show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
# ${parsed}=   run parsed "admin show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
#
################################################################################
