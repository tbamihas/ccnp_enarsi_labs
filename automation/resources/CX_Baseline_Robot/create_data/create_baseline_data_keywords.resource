*** Settings ***

################################################################################
#
#     Keywords in this file
#
# baseline verify node types are valid
# baseline create data yaml file
#
# baseline create data for software version
# baseline create data for software packages
# baseline create data for hardware platform
# baseline create data for hardware modules
# baseline create data for hardware inventory
# baseline create data for bfd ipv4 scale
# baseline create data for bfd ipv6 scale
# baseline create data for bgp neighbors
# baseline create data for bgp route scale
# baseline create data for interfaces up
# baseline create data for interfaces down
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
#
################################################################################

Resource    ../cx_baseline_robot.resource

Library    YamlDumpWithLineBreaks.py

*** Variables ***
&{BASELINE}

@{global_afi_safi}=
...  ipv4 unicast
...  ipv4 flowspec
...  ipv4 labeled-unicast
...  ipv4 mdt
...  ipv4 multicast
...  ipv4 mvpn
...  ipv4 rt-filter
...  ipv4 sr-policy
...  ipv4 tunnel
...  vpnv4 unicast
...  vpnv4 multicast
...  vpnv4 flowspec
...  ipv6 unicast
...  ipv6 flowspec
...  ipv6 labeled-unicast
...  ipv6 multicast
...  ipv6 mvpn
...  ipv6 sr-policy
...  vpnv6 unicast
...  vpnv6 multicast
...  vpnv6 flowspec
...  l2vpn evpn
...  l2vpn mspw
...  l2vpn vpls
...  l2vpn vpws
...  link-state link-state

@{vrf_afi_safi}=
...  ipv4 unicast
...  ipv4 mvpn
...  ipv4 multicast
...  ipv4 labeled-unicast
...  ipv4 flowspec
...  ipv6 unicast
...  ipv6 mvpn
...  ipv6 multicast
...  ipv6 flowspec

*** keywords ***
baseline verify node types are valid
    FOR  ${device}  IN  @{DEVICES}
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" != "cXR" and "${node_type}" != "eXR" and "${node_type}" != "LNTXR" and "${node_type}" != "iosxe" and "${node_type}" != "ios" and "${node_type}" != "nxos"
        baseline set test warn  [WARN] Create Baseline Data for device '${device}'. Warning, NODE_TYPE '${node_type}' is not valid. Please check your code and update. Valid NODE_TYPE is: cXR, eXR, LNTXR, iosxe, ios, nxos
      END
    END

baseline create data yaml file
    baseline set test title  create baseline yaml file
    ${BASELINE}=  yaml dump with line breaks  data=${BASELINE}
    Create File  ${OUTPUTDIR}/baseline_data.yaml  ${BASELINE}
    baseline set test title  Baseline data saved in file: baseline_data.yaml

baseline create data for software version
    baseline set test title  create baseline data for software version
    ${BASELINE_SW_VERSION}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for software version: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR"
        run "show version brief"
        ${value}=  extract patterns "Version ([\\d\\.]+)"
        ${value}=  Set Variable  ${value[0]}
      ELSE IF  "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show version"
        ${value}=  extract pattern "Version +: ([\\d\\.A-Z]+)"
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show version"
        ${value}=  extract patterns "Version ([\\d\\.A-Za-z\\(\\)]+)"
        ${value}=  Set Variable  ${value[0]}
      ELSE IF  "${node_type}" == "nxos"
        run "show version"
        ${status}  ${value}=  Run Keyword And Ignore Error  extract patterns "NXOS: version (\\\\S+)"
        IF  "${status}" == "FAIL"
          ${value}=  extract patterns "system: +version (\\S+)"
        END
        ${value}=  Set Variable  ${value[0]}
      END
      Set To Dictionary  ${BASELINE_SW_VERSION}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_SW_VERSION}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_SW_VERSION  ${BASELINE_SW_VERSION}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for software version: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for software version: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for software packages
    baseline set test title  create baseline data for software packages
    ${BASELINE_SW_PACKAGES}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for software packages: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR"
        run "show install active summary"
        ${value}=  extract patterns "(?:(?:disk0:)|(?:mem:))(\\S+)"
      ELSE IF  "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show install active summary"
        ${IS_NCS}=  Run Keyword And Return Status  output contains "Optional Packages"
        IF  ${IS_NCS}
          ${value}=  extract patterns "(xr-\\S+)"
        ELSE
          ${value}=  extract patterns "${SPACE * 8}(\\S+)"
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. create baseline data for software packages only required on cXR and eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_SW_PACKAGES}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_SW_PACKAGES}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_SW_PACKAGES  ${BASELINE_SW_PACKAGES}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for software packages: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for software packages: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for hardware platform
    baseline set test title  create baseline data for hardware platform
    ${BASELINE_HW_PLATFORM}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for hardware platform: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "admin show inventory chassis"
        ${IS_NCS}=  Run Keyword And Return Status  output contains "Admin mode has been deprecated"
        IF  ${IS_NCS}
          run "show inventory chassis"
        END
        ${value}=  extract patterns "PID: ([\\w\\-]+)"
        ${value}=  Set Variable  ${value[0]}
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        run "show inventory"
        ${value}=  extract patterns "PID: ([\\w\\-]+)"
        ${value}=  Set Variable  ${value[0]}
      END
      Set To Dictionary  ${BASELINE_HW_PLATFORM}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_HW_PLATFORM}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_HW_PLATFORM  ${BASELINE_HW_PLATFORM}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for hardware platform: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for hardware platform: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for hardware modules
    baseline set test title  create baseline data for hardware modules
    ${BASELINE_HW_MODULES}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for hardware modules: ${device}
      ${device_dictionary}=  Create Dictionary
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR"
        ${output}=  run parsed "admin show platform"
        ${node_list}=  get parsed  Node  return_all=True
        FOR  ${node}  IN  @{node_list}
          ${type}=  get parsed "Type" where "Node" is "${node}"
          Set To Dictionary  ${device_dictionary}  ${node}  ${type.replace("(Active)", "").replace("(Standby)", "")}
        END
      ELSE IF  "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run parsed "show platform"
        ${node_list}=  get parsed  node  return_all=True
        FOR  ${node}  IN  @{node_list}
          ${type}=  get parsed "node_type" where "node" is "${node}"
          Set To Dictionary  ${device_dictionary}  ${node}  ${type.replace("(Active)", "").replace("(Standby)", "")}
        END
      ELSE IF  "${node_type}" == "iosxe"
        ${output}=  run parsed "show platform"
        ${slot_list}=  get parsed  slot  return_all=True
        FOR  ${slot}  IN  @{slot_list}
          ${type}=  YamlPath Parse  query=[slot=${slot}].type  data=${output}
          Set To Dictionary  ${device_dictionary}  ${slot}  ${type[0]}
        END
      ELSE IF  "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for hardware modules not currently available on ios or nxos. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_HW_MODULES}  ${device}  ${device_dictionary}
    END
    ${length}=  Get Length  ${BASELINE_HW_MODULES}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_HW_MODULES  ${BASELINE_HW_MODULES}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for hardware modules: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for hardware modules: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for hardware inventory
    baseline set test title  create baseline data for hardware inventory
    ${BASELINE_HW_INVENTORY}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for hardware inventory: ${device}
      ${device_dictionary}=  Create Dictionary
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR"
        ${output}=  run parsed "admin show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
      ELSE IF  "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run parsed "show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
      ELSE IF  "${node_type}" == "ios" or "${node_type}" == "iosxe" or "${node_type}" == "nxos"
        ${output}=  run parsed "show inventory" with template "${SHOW_INVENTORY_TEMPLATE}"
      END
      ${name_list}=  get parsed  name  return_all=True
      FOR  ${name}  IN  @{name_list}
        ${name_dictionary}=  Create Dictionary
        ${descr}=  get parsed "descr" where "name" is "${name}"
        ${pid}=    get parsed "pid" where "name" is "${name}"
        ${vid}=    get parsed "vid" where "name" is "${name}"
        ${sn}=     get parsed "sn" where "name" is "${name}"
        Set To Dictionary  ${name_dictionary}
        ...                descr  ${descr}
        ...                pid    ${pid}
        ...                vid    ${vid}
        ...                sn     ${sn}
        Set To Dictionary  ${device_dictionary}  ${name}  ${name_dictionary}
      END
      Set To Dictionary  ${BASELINE_HW_INVENTORY}  ${device}  ${device_dictionary}
    END
    ${length}=  Get Length  ${BASELINE_HW_INVENTORY}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_HW_INVENTORY  ${BASELINE_HW_INVENTORY}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for hardware inventory: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for hardware inventory: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for bfd ipv4 scale
    baseline set test title  baseline create data for bfd ipv4 scale
    ${BASELINE_BFD_IPV4_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for bfd ipv4 scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show bfd ipv4"
        ${value}=  extract pattern "IPV4 Sessions Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. create baseline data for bfd ipv4 scale for device '${device}'. BFD IPv4 scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show bfd summary session"
        ${status}=  Run Keyword And Return Status  output contains "IPV4"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for bfd ipv4 scale for device '${device}'. No BFD IPv4 configured on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "IPV4\\s+\\d+\\s+(\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. create baseline data for bfd ipv4 scale for device '${device}'. BFD IPv4 scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for bfd ipv4 scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_BFD_IPV4_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_BFD_IPV4_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_BFD_IPV4_SCALE  ${BASELINE_BFD_IPV4_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for bfd ipv4 scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for bfd ipv4 scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for bfd ipv6 scale
    baseline set test title  baseline create data for bfd ipv6 scale
    ${BASELINE_BFD_IPV6_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for bfd ipv6 scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show bfd ipv6"
        ${value}=  extract pattern "IPV6 Sessions Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. create baseline data for bfd ipv6 scale for device '${device}'. BFD IPv6 scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show bfd summary session"
        ${status}=  Run Keyword And Return Status  output contains "IPV6"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for bfd ipv6 scale for device '${device}'. No BFD IPv6 configured on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "IPV6\\s+\\d+\\s+(\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. create baseline data for bfd ipv6 scale for device '${device}'. BFD IPv6 scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for bfd ipv6 scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_BFD_IPV6_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_BFD_IPV6_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_BFD_IPV6_SCALE  ${BASELINE_BFD_IPV6_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for bfd ipv6 scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for bfd ipv6 scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for bgp neighbors
    [Arguments]  ${include_vrf_list}=${EMPTY}
    baseline set test title  baseline create data for bgp neighbors
    ${BASELINE_BGP_NEIGHBORS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for bgp neighbors: ${device}
      connect to device "${device}"
      ${device_dictionary}=  Create Dictionary
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${status}=  Run Keyword And Return Status  run "show run router bgp"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for bgp neighbors for device '${device}'. No BGP neighbors configured on this device.
          Continue For Loop
        ELSE
          ${status}=  Run Keyword And Return Status  output contains "router bgp"
          IF  not ${status}
            baseline set test comment  Skipping. baseline create data for bgp neighbors for device '${device}'. No BGP neighbors configured on this device.
            Continue For Loop
          END
          FOR  ${afi_safi}  IN  @{global_afi_safi}
            ${afi}=  Set Variable  ${afi_safi.split(' ')[0]}
            ${safi}=  Set Variable  ${afi_safi.split(' ')[1]}
            ${output}=  Run Keyword And Ignore Error  run parsed "show bgp ${afi} ${safi} summary" with template "${XR_SHOW_BGP_SUMMARY_TEMPLATE}"
            IF  "${output[0]}" == "PASS"
              ${up_neighbors}=  Run Keyword And Ignore Error  YamlPath Parse  query=.[state_prefix=~/\\d+/].neighbor  data=${output[1]}
              IF  "${up_neighbors[0]}" == "PASS"
                ${vrf}=  Set Variable  global
                ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
                IF  not ${vrf_exists}
                  ${empty_dictionary}=  Create Dictionary
                  Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
                END
                ${afi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']}  ${afi}
                IF  not ${afi_exists}
                  ${empty_dictionary}=  Create Dictionary
                  Set To Dictionary  ${device_dictionary['${vrf}']}  ${afi}  ${empty_dictionary}
                END
                Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${up_neighbors[1]}
              END
            END
          END
          FOR  ${afi_safi}  IN  @{vrf_afi_safi}
            ${afi}=  Set Variable  ${afi_safi.split(' ')[0]}
            ${safi}=  Set Variable  ${afi_safi.split(' ')[1]}
            ${output}=  Run Keyword And Ignore Error  run parsed "show bgp vrf all ${afi} ${safi} summary" with template "${XR_SHOW_BGP_VRF_SUMMARY_TEMPLATE}"
            IF  "${output[0]}" == "PASS"
              ${status}  ${up_neighbors}=  Run Keyword And Ignore Error  YamlPath Parse  query=.[state_prefix=~/\\d+/]  data=${output[1]}
              ${up_neighbors}=  Evaluate  json.dumps($up_neighbors)
              ${up_neighbors}=  Evaluate  json.loads($up_neighbors)
              ${up_neighbors}=  Evaluate  yaml.load(str($up_neighbors), Loader=yaml.FullLoader)
              IF  "${status}" == "PASS"
                ${vrf_list}=  YamlPath Parse New  query=.vrf  data=${up_neighbors}
                ${vrf_list}=  Remove Duplicates  ${vrf_list}
                FOR  ${vrf}  IN  @{vrf_list}
                  IF  "${include_vrf_list}" != "${EMPTY}"
                    ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${include_vrf_list}  ${vrf}
                    Continue For Loop If  not ${include_vrf}
                  END
                  ${neighbor_vrf_list}=  YamlPath Parse New  query=.[vrf=${vrf}].neighbor  data=${up_neighbors}
                  ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
                  IF  not ${vrf_exists}
                    ${empty_dictionary}=  Create Dictionary
                    Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
                  END
                  ${afi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']}  ${afi}
                  IF  not ${afi_exists}
                    ${empty_dictionary}=  Create Dictionary
                    Set To Dictionary  ${device_dictionary['${vrf}']}  ${afi}  ${empty_dictionary}
                  END
                  Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${neighbor_vrf_list}
                END
              END
            END
          END
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${BGP_CONFIG_EXISTS}  ${output}=  Run Keyword And Ignore Error  run parsed "show run | section router bgp" with template "${XE_SHOW_RUN_ROUTER_BGP_TEMPLATE}"
        IF  "${BGP_CONFIG_EXISTS}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for bgp neighbors for device '${device}'. No BGP neighbors configured on this device.
          Continue For Loop
        ELSE
          ###### UPDATE
          FOR  ${neighbor}  IN  @{output}
            ${neighbor_ip}=  Set Variable  ${neighbor['neighbor']}
            ${afi}=  Set Variable If  " " in "${neighbor['afi']}"  ${neighbor['afi'].split(" ")[0]}  ${neighbor['afi']}
            ${safi}=  Set Variable If  " " in "${neighbor['afi']}"  ${neighbor['afi'].split(" ")[1]}  unicast
            ${vrf}=  Set Variable If  "${neighbor['vrf']}" == ""  global  ${neighbor['vrf']}
            IF  "${include_vrf_list}" != "${EMPTY}"
              ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${include_vrf_list}  ${vrf}
              Continue For Loop If  not ${include_vrf}
            END
            ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
            IF  not ${vrf_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
            END
            ${afi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']}  ${afi}
            IF  not ${afi_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary['${vrf}']}  ${afi}  ${empty_dictionary}
            END
            ${safi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']['${afi}']}  ${safi}
            IF  not ${safi_exists}
              ${empty_list}=  Create List
              Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${empty_list}
            END
            ${safi_list}=  Set Variable  ${device_dictionary['${vrf}']['${afi}']['${safi}']}
            Append To List  ${safi_list}  ${neighbor_ip}
            Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${safi_list}
          END
          ############
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for bgp neighbors currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      ${length}=  Get Length  ${device_dictionary}
      IF  ${length} != 0
        Set To Dictionary  ${BASELINE_BGP_NEIGHBORS}  ${device}  ${device_dictionary}
      END
    END
    ${length}=  Get Length  ${BASELINE_BGP_NEIGHBORS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_BGP_NEIGHBORS  ${BASELINE_BGP_NEIGHBORS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for bgp neighbors: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for bgp neighbors: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for bgp route scale
    [Arguments]  ${include_vrf_list}=${EMPTY}
    baseline set test title  baseline create data for bgp route scale
    ${BASELINE_BGP_ROUTE_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for bgp route scale: ${device}
      connect to device "${device}"
      ${device_dictionary}=  Create Dictionary
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${BGP_SCALE_GLOBAL_EXISTS}  ${output}=  Run Keyword And Ignore Error  run parsed "show bgp vrf default scale" with template "${XR_SHOW_BGP_SCALE_TEMPLATE}"
        IF  "${BGP_SCALE_GLOBAL_EXISTS}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for bgp route scale (global) for device '${device}'. No BGP routes in global (default) found on this device.
        ELSE
          FOR  ${item}  IN  @{output}
            ${afi}=  Set Variable  ${item['afi']}
            ${safi}=  Set Variable  ${item['safi']}
            ${prefixes}=  Set Variable  ${item['prefixes']}
            ${vrf}=  Set Variable  global
            ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
            IF  not ${vrf_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
            END
            ${afi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']}  ${afi}
            IF  not ${afi_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary['${vrf}']}  ${afi}  ${empty_dictionary}
            END
            ${prefixes}=  Evaluate  int(${prefixes})
            Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${prefixes}
          END
        END
        ${BGP_SCALE_VRF_EXISTS}  ${output}=  Run Keyword And Ignore Error  run parsed "show bgp vrf all scale" with template "${XR_SHOW_BGP_SCALE_TEMPLATE}"
        IF  "${BGP_SCALE_VRF_EXISTS}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for bgp route scale (vrf) for device '${device}'. No BGP routes in VRFs found on this device.
        ELSE
          FOR  ${item}  IN  @{output}
            ${afi}=  Set Variable  ${item['afi']}
            ${safi}=  Set Variable  ${item['safi']}
            ${prefixes}=  Set Variable  ${item['prefixes']}
            ${vrf}=  Set Variable  ${item['vrf']}
            IF  "${include_vrf_list}" != "${EMPTY}"
              ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${include_vrf_list}  ${vrf}
              Continue For Loop If  not ${include_vrf}
            END
            ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
            IF  not ${vrf_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
            END
            ${afi_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${vrf}']}  ${afi}
            IF  not ${afi_exists}
              ${empty_dictionary}=  Create Dictionary
              Set To Dictionary  ${device_dictionary['${vrf}']}  ${afi}  ${empty_dictionary}
            END
            ${prefixes}=  Evaluate  int(${prefixes})
            Set To Dictionary  ${device_dictionary['${vrf}']['${afi}']}  ${safi}  ${prefixes}
          END
        END
        Continue For Loop If  "${BGP_SCALE_GLOBAL_EXISTS}" == "FAIL" and "${BGP_SCALE_VRF_EXISTS}" == "FAIL"
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for bgp route scale currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_BGP_ROUTE_SCALE}  ${device}  ${device_dictionary}
    END
    ${length}=  Get Length  ${BASELINE_BGP_ROUTE_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_BGP_ROUTE_SCALE  ${BASELINE_BGP_ROUTE_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for bgp route scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for bgp route scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for interfaces up
    baseline set test title  create baseline data for interfaces up
    ${BASELINE_INTERFACES_UP}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for interfaces up: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show ipv4 interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+Up"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces up for device '${device}'. No Up interfaces found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show ip interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+up"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces up for device '${device}'. No up interfaces found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        run "show interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+up"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces up for device '${device}'. No up interfaces found on this device.
          Continue For Loop
        END
      END
      Set To Dictionary  ${BASELINE_INTERFACES_UP}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_INTERFACES_UP}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_INTERFACES_UP  ${BASELINE_INTERFACES_UP}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for interfaces up: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for interfaces up: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for interfaces down
    baseline set test title  create baseline data for interfaces down
    ${BASELINE_INTERFACES_DOWN}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for interfaces down: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show ipv4 interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+Down"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces down for device '${device}'. No Up interfaces found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show ip interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+down"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces down for device '${device}'. No up interfaces found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        run "show interface brief"
        ${status}  ${value}=  Run keyword And Ignore Error  extract patterns "(\\\\S+) +[\\\\S ]+down"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for interfaces down for device '${device}'. No up interfaces found on this device.
          Continue For Loop
        END
      END
      Set To Dictionary  ${BASELINE_INTERFACES_DOWN}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_INTERFACES_DOWN}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_INTERFACES_DOWN  ${BASELINE_INTERFACES_DOWN}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for interfaces down: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for interfaces down: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for isis neighbors
    baseline set test title  create baseline data for isis neighbors
    ${BASELINE_ISIS_NEIGHBORS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for isis neighbors: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show isis neighbors"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for isis neighbors for device '${device}'. No ISIS neighbors found on this device.
          Continue For Loop
        END
        ${status}  ${value}=  Run Keyword And Ignore Error  YamlPath Parse  query=[state=Up]  data=${output}
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for isis neighbors for device '${device}'. No ISIS neighbors Up found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show isis neighbors" with template "${XE_SHOW_ISIS_NEIGHBORS_TEXTFSM}"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for isis neighbors for device '${device}'. No ISIS neighbors found on this device.
          Continue For Loop
        END
        ${status}  ${value}=  Run Keyword And Ignore Error  YamlPath Parse  query=[state=UP]  data=${output}
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. baseline create data for isis neighbors for device '${device}'. No ISIS neighbors UP found on this device.
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for isis neighbors currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      ${device_dictionary}=  Create Dictionary
      FOR  ${neighbor}  IN  @{value}
        ${instance}=  Set Variable  ${neighbor['isisname']}
        ${neighbor_id}=  Set Variable  ${neighbor['sys_id']}
        ${interface}=  Set Variable  ${neighbor['intf']}
        ${instance_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${instance}
        IF  not ${instance_exists}
          ${empty_dictionary}=  Create Dictionary
          Set To Dictionary  ${device_dictionary}  ${instance}  ${empty_dictionary}
        END
        ${neighbor_id_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary['${instance}']}  ${neighbor_id}
        IF  not ${neighbor_id_exists}
          ${empty_list}=  Create List
          Set To Dictionary  ${device_dictionary['${instance}']}  ${neighbor_id}  ${empty_list}
        END
        ${new_list}=  Set Variable  ${device_dictionary['${instance}']['${neighbor_id}']}
        Append To List  ${new_list}  ${interface}
        Set To Dictionary  ${device_dictionary['${instance}']}  ${neighbor_id}  ${new_list}
      END
      Set To Dictionary  ${BASELINE_ISIS_NEIGHBORS}  ${device}  ${device_dictionary}
    END
    ${length}=  Get Length  ${BASELINE_ISIS_NEIGHBORS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_ISIS_NEIGHBORS  ${BASELINE_ISIS_NEIGHBORS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for isis neighbors: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for isis neighbors: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for isis lsp scale
    baseline set test title  create baseline data for isis lsp scale
    ${BASELINE_ISIS_LSP_COUNT}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for isis lsp scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run "show isis database summary"
        ${status}=  Run Keyword And Return Status  output does not contain "No IS-IS instances found"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for isis lsp scale for device '${device}'. No ISIS found on this device.
          Continue For Loop
        END
        ${value}=  Get Regexp Matches  ${output}  All Fragment Counts[\\s\\S]+All LSPs: +\\d+ +\\d+ +(\\d+)  1
        ${value}=  Evaluate  int(${value[0]})
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${output}=  run "show isis database"
        ${status}=  Run Keyword And Return Status  output contains "LSPID"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for isis lsp scale for device '${device}'. No ISIS LSPs found on this device.
          Continue For Loop
        END
        ${value}=  Get Regexp Matches  ${output}  \\S+\\.[\\d\\w][\\d\\w]\\-[\\d\\w][\\d\\w]
        ${value}=  Get Length  ${value}
        ${value}=  Evaluate  int(${value})
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for isis lsp scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_ISIS_LSP_COUNT}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_ISIS_LSP_COUNT}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_ISIS_LSP_COUNT  ${BASELINE_ISIS_LSP_COUNT}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for isis lsp scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for isis lsp scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for l2vpn xc scale
    baseline set test title  create baseline data for l2vpn xc scale
    ${BASELINE_L2VPN_XC_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for l2vpn xc scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show l2vpn xconnect summary"
        ${value}=  extract pattern "Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn xc scale for device '${device}'. l2vpn xc scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show l2vpn service xconnect all"
        run "show l2vpn service xconnect all | count State: UP"
        ${value}=  extract pattern "\\d+"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn xc scale for device '${device}'. l2vpn xc scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for l2vpn xc scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_L2VPN_XC_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_L2VPN_XC_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_L2VPN_XC_SCALE  ${BASELINE_L2VPN_XC_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for l2vpn xc scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for l2vpn xc scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for l2vpn bd scale
    baseline set test title  create baseline data for l2vpn bd scale
    ${BASELINE_L2VPN_BD_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for l2vpn bd scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show l2vpn bridge-domain summary"
        ${status}=  Run Keyword And Return Status  output contains "Number of bridge-domains"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for l2vpn bd scale for device '${device}'. No l2vpn bridge-domains found on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "Number of bridge\\-domains: \\d+, Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn bd scale for device '${device}'. l2vpn bd scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show l2vpn service vfi all"
        run "show l2vpn service vfi all | count State: UP"
        ${value}=  extract pattern "\\d+"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn bd scale for device '${device}'. l2vpn bd scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for l2vpn bd scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_L2VPN_BD_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_L2VPN_BD_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_L2VPN_BD_SCALE  ${BASELINE_L2VPN_BD_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for l2vpn bd scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for l2vpn bd scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for l2vpn bd pw scale
    baseline set test title  create baseline data for l2vpn bd pw scale
    ${BASELINE_L2VPN_BD_PW_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for l2vpn bd pw scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show l2vpn bridge-domain summary"
        ${value}=  extract pattern "Number of PWs: \\d+ Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn bd pw scale for device '${device}'. l2vpn bd pw scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show l2vpn service vfi all"
        run "show mpls l2transport vc | i vfi"
        ${status}=  Run Keyword And Return Status  output contains "UP"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for l2vpn bd pw scale for device '${device}'. l2vpn bd pw scale is 0
          Continue For Loop
        END
        ${values}=  extract patterns "UP"
        ${value}=  Get Length  ${values}
        ${value}=  Evaluate  int(${value})
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for l2vpn bd pw scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_L2VPN_BD_PW_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_L2VPN_BD_PW_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_L2VPN_BD_PW_SCALE  ${BASELINE_L2VPN_BD_PW_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for l2vpn bd pw scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for l2vpn bd pw scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for l2vpn bd ac scale
    baseline set test title  create baseline data for l2vpn bd ac scale
    ${BASELINE_L2VPN_BD_AC_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for l2vpn bd ac scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show l2vpn bridge-domain summary"
        ${value}=  extract pattern "Number of ACs: \\d+ Up: (\\d+)"
        ${value}=  Evaluate  int(${value})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for l2vpn bd ac scale for device '${device}'. l2vpn bd ac scale is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for l2vpn bd ac scale currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_L2VPN_BD_AC_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_L2VPN_BD_AC_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_L2VPN_BD_AC_SCALE  ${BASELINE_L2VPN_BD_AC_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for l2vpn bd ac scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for l2vpn bd ac scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for ldp neighbors
    baseline set test title  create baseline data for ldp neighbors
    ${BASELINE_LDP_NEIGHBORS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for ldp neighbors: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show mpls ldp neighbor brief"
        ${status}=  Run Keyword And Return Status  output contains "Peer"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ldp neighbors for device '${device}'. No LDP neighbors found on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+"
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show mpls ldp neighbor"
        ${status}=  Run Keyword And Return Status  output contains "Peer LDP Ident"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ldp neighbors for device '${device}'. No LDP neighbors found on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "Peer LDP Ident: ([\\d\\.]+:\\d+)"
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for ldp neighbors currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_LDP_NEIGHBORS}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_LDP_NEIGHBORS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_LDP_NEIGHBORS  ${BASELINE_LDP_NEIGHBORS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for ldp neighbors: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for ldp neighbors: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for ldp local bindings scale
    baseline set test title  create baseline data for ldp local bindings scale
    ${BASELINE_LDP_LOCAL_BINDINGS_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for ldp local bindings scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show mpls ldp bindings summary"
        ${status}=  Run Keyword And Return Status  output contains "LIB Summary"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ldp local bindings scale for device '${device}'. No LDP labels found on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "Local Bindings : +(\\d+)"
        ${value}=  Evaluate  int(${value})
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run "show mpls ldp bindings summary"
        ${status}=  Run Keyword And Return Status  output contains "prefixes"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ldp local bindings scale for device '${device}'. No LDP labels found on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "Total number of prefixes: +(\\d+)"
        ${value}=  Evaluate  int(${value})
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for ldp local bindings scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_LDP_LOCAL_BINDINGS_SCALE  ${BASELINE_LDP_LOCAL_BINDINGS_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for ldp local bindings scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for ldp local bindings scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for ldp remote bindings scale
    baseline set test title  create baseline data for ldp remote bindings scale
    ${BASELINE_LDP_REMOTE_BINDINGS_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for ldp remote bindings scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run "show mpls ldp bindings summary"
        ${status}=  Run Keyword And Return Status  output contains "LIB Summary"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ldp remote bindings scale for device '${device}'. No LDP labels found on this device.
          Continue For Loop
        END
        ${value}=  extract pattern "Remote Bindings: +(\\d+)"
        ${value}=  Evaluate  int(${value})
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for ldp remote bindings scale currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_LDP_REMOTE_BINDINGS_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_LDP_REMOTE_BINDINGS_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_LDP_REMOTE_BINDINGS_SCALE  ${BASELINE_LDP_REMOTE_BINDINGS_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for ldp remote bindings scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for ldp remote bindings scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for mpls traffic-eng scale
    baseline set test title  create baseline data for mpls traffic-eng scale
    ${BASELINE_MPLS_TE_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for mpls traffic-eng scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      ${device_dictionary}=  Create Dictionary
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run "show mpls traffic-eng tunnels up brief | utility tail count 2"
        ${status}=  Run Keyword And Return Status  output contains "Displayed"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for mpls traffic-eng scale for device '${device}'. MPLS-TE not configured on this device.
          Continue For Loop
        END
        ${values}=  extract pattern "Displayed \\d+ \\(of \\d+\\) heads, \\d+ \\(of \\d+\\) midpoints, \\d+ \\(of \\d+\\) tails"
        ${values}=  Get Regexp Matches  ${values}  \\d+
        ${heads}=      Evaluate  int(${values[0]})
        ${midpoints}=  Evaluate  int(${values[2]})
        ${tails}=      Evaluate  int(${values[4]})
        IF  ${heads} == 0 and ${midpoints} == 0 and ${tails} == 0
          baseline set test comment  Skipping. baseline create data for mpls traffic-eng scale for device '${device}'. total tunnels is 0
          Continue For Loop
        END
        Set To Dictionary  ${device_dictionary}
        ...   head      ${heads}
        ...   midpoint  ${midpoints}
        ...   tail      ${tails}
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${output}=  run "show mpls traffic-eng tunnels up brief"
        ${status}=  Run Keyword And Return Status  output contains "Displayed"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for mpls traffic-eng scale for device '${device}'. MPLS-TE not configured on this device.
          Continue For Loop
        END
        ${values}=  extract pattern "Displayed \\d+ \\(of \\d+\\) heads, \\d+ \\(of \\d+\\) midpoints, \\d+ \\(of \\d+\\) tails"
        ${values}=  Get Regexp Matches  ${values}  \\d+
        ${heads}=      Evaluate  int(${values[0]})
        ${midpoints}=  Evaluate  int(${values[2]})
        ${tails}=      Evaluate  int(${values[4]})
        IF  ${heads} == 0 and ${midpoints} == 0 and ${tails} == 0
          baseline set test comment  Skipping. baseline create data for mpls traffic-eng scale for device '${device}'. total tunnels is 0
          Continue For Loop
        END
        Set To Dictionary  ${device_dictionary}
        ...   head      ${heads}
        ...   midpoint  ${midpoints}
        ...   tail      ${tails}
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for mpls traffic-eng scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_MPLS_TE_SCALE}  ${device}  ${device_dictionary}
    END
    ${length}=  Get Length  ${BASELINE_MPLS_TE_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_MPLS_TE_SCALE  ${BASELINE_MPLS_TE_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for mpls traffic-eng scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for mpls traffic-eng scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for ospf neighbors
    baseline set test title  create baseline data for ospf neighbors
    ${BASELINE_OSPF_NEIGHBORS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for ospf neighbors: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run "show ospf vrf all neighbor"
        ${status}=  Run Keyword And Return Status  output contains "Neighbor ID"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ospf neighbors for device '${device}'. No OSPF neighbors or OSPF not configured on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "FULL[\\S ]+ (\\S+)"
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${output}=  run "show ip ospf neighbor"
        ${status}=  Run Keyword And Return Status  output contains "Neighbor ID"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ospf neighbors for device '${device}'. No OSPF neighbors or OSPF not configured on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "FULL[\\S ]+ (\\S+)"
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for ospf neighbors currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_OSPF_NEIGHBORS}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_OSPF_NEIGHBORS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_OSPF_NEIGHBORS  ${BASELINE_OSPF_NEIGHBORS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for ospf neighbors: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for ospf neighbors: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for ospfv3 neighbors
    baseline set test title  create baseline data for ospfv3 neighbors
    ${BASELINE_OSPFV3_NEIGHBORS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for ospfv3 neighbors: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${output}=  run "show ospfv3 vrf all neighbor"
        ${status}=  Run Keyword And Return Status  output contains "Neighbor ID"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ospf neighbors for device '${device}'. No OSPFv3 neighbors or OSPFv3 not configured on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "FULL[\\S ]+ (\\S+)"
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        ${output}=  run "show ospfv3 neighbor"
        ${status}=  Run Keyword And Return Status  output contains "Neighbor ID"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for ospf neighbors for device '${device}'. No OSPFv3 neighbors or OSPFv3 not configured on this device.
          Continue For Loop
        END
        ${value}=  extract patterns "FULL[\\S ]+ (\\S+)"
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for ospfv3 neighbors currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_OSPFV3_NEIGHBORS}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_OSPFV3_NEIGHBORS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_OSPFV3_NEIGHBORS  ${BASELINE_OSPFV3_NEIGHBORS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for ospfv3 neighbors: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for ospfv3 neighbors: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for srte scale
    baseline set test title  create baseline data for srte scale
    ${BASELINE_SRTE_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for srte scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${status}=  Run Keyword And Return Status  run "show segment-routing traffic-eng policy summary"
        IF  not ${status}
          baseline set test comment  Skipping. baseline create data for srte scale for device '${device}'. srte command failed
          Continue For Loop
        END
        ${value}=  extract patterns "Operational: up (\\d+)"
        ${value}=  Evaluate  int(${value[0]})
        IF  ${value} == 0
          baseline set test comment  Skipping. baseline create data for srte scale for device '${device}'. srte up policies is 0
          Continue For Loop
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for srte scale currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_SRTE_SCALE}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_SRTE_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_SRTE_SCALE  ${BASELINE_SRTE_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for srte scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for srte scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for srte pce ipv4 peers
    baseline set test title  create baseline data for srte pce ipv4 peers
    ${BASELINE_PCE_PEERS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for srte pce ipv4 peers: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${status}  ${output}=  Run Keyword And Ignore Error  run "show pce ipv4 peer"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. create baseline data for srte pce ipv4 peers for device '${device}'. show pce ipv4 peer command failed.
          Continue For Loop
        END
        ${status}=  Run Keyword And Return Status  output contains "State: Up"
        IF  not ${status}
          baseline set test comment  Skipping. create baseline data for srte pce ipv4 peers for device '${device}'. No PCE IPv4 peers Up found on this device.
          Continue For Loop
        END
        ${value}=  Get Regexp Matches  ${output}  Peer address: ([\\d\\.])+\\s+State: Up\\s+Capabilities:  1
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for srte pce ipv4 peers currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_PCE_PEERS}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_PCE_PEERS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_PCE_PEERS  ${BASELINE_PCE_PEERS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for srte pce ipv4 peers: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for srte pce ipv4 peers: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for srte pcc ipv4 peers
    baseline set test title  create baseline data for srte pcc ipv4 peers
    ${BASELINE_PCC_PEERS}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for srte pcc ipv4 peers: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        ${status}  ${output}=  Run Keyword And Ignore Error  run "show segment-routing traffic-eng pcc ipv4 peer brief"
        IF  "${status}" == "FAIL"
          baseline set test comment  Skipping. create baseline data for srte pcc ipv4 peers for device '${device}'. show segment-routing traffic-eng pcc ipv4 peer brief command failed.
          Continue For Loop
        END
        ${status}=  Run Keyword And Return Status  output contains "up"
        IF  not ${status}
          baseline set test comment  Skipping. create baseline data for srte pcc ipv4 peers for device '${device}'. No PCC IPv4 peers up found on this device.
          Continue For Loop
        END
        ${value}=  Get Regexp Matches  ${output}  ([\\d\\.])+ +\\S+ +up  1
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios" or "${node_type}" == "nxos"
        baseline set test comment  Skipping. baseline create data for srte pcc ipv4 peers currently available only for cXR, eXR. This device is type '${node_type}'
        Continue For Loop
      END
      Set To Dictionary  ${BASELINE_PCC_PEERS}  ${device}  ${value}
    END
    ${length}=  Get Length  ${BASELINE_PCC_PEERS}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_PCC_PEERS  ${BASELINE_PCC_PEERS}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for srte pcc ipv4 peers: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for srte pcc ipv4 peers: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for routing table scale
    [Arguments]  ${routing_table_vrf_list}=${EMPTY}
    baseline set test title  create baseline data for routing table scale
    ${BASELINE_ROUTE_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for routing table scale: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      ${device_dictionary}=  Create Dictionary
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run parsed "show route summary"
        ${global_dictionary}=  Create Dictionary
        ${routesource_list}=  Get Parsed  routesource  return_all=True
        FOR  ${routesource}  IN  @{routesource_list}
          ${value}=  get parsed "routes" where "routesource" is "${routesource}"
          ${value}=  Evaluate  int(${value})
          IF  ${value} == 0
            #baseline set test comment  Skipping routesource '${routesource}' , routing table scale for device '${device}'. routes is 0
            Continue For Loop
          END
          Set To Dictionary  ${global_dictionary}  ${routesource}  ${value}
        END
        ${length}=  Get Length  ${global_dictionary}
        IF  ${length} != 0
          Set To Dictionary  ${device_dictionary}  global  ${global_dictionary}
        ELSE
          baseline set test comment  Skipping vrf 'global' , routing table scale for device '${device}'. total routes from all routesource is 0
        END
        ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show route vrf all summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        IF  "${status}" != "FAIL"
          ${status}  ${output}=  Run Keyword And Ignore Error  YamlPath Parse  data=${output}  query=[routes!=0]
          IF  "${status}" != "FAIL"
            FOR  ${item}  IN  @{output}
              ${vrf}=  Set Variable  ${item['vrf']}
              IF  "${routing_table_vrf_list}" != "${EMPTY}"
                ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${routing_table_vrf_list}  ${vrf}
                Continue For Loop If  not ${include_vrf}
              END
              ${routesource}=  Set Variable  ${item['routesource']}
              ${routes}=  Evaluate  int(${item['routes']})
              ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
              IF  not ${vrf_exists}
                ${empty_dictionary}=  Create Dictionary
                Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
              END
              Set To Dictionary  ${device_dictionary['${vrf}']}  ${routesource}  ${routes}
            END
          END
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run parsed "show ip route summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
        ${global_dictionary}=  Create Dictionary
        ${route_source_list}=  Get Parsed  route_source  return_all=True
        FOR  ${route_source}  IN  @{route_source_list}
          ${value}=  get parsed "subnets" where "route_source" is "${route_source}"
          ${value}=  Evaluate  int(${value})
          IF  ${value} == 0
            #baseline set test comment  Skipping route_source '${route_source}' , routing table scale for device '${device}'. subnets is 0
            Continue For Loop
          END
          Set To Dictionary  ${global_dictionary}  ${route_source}  ${value}
        END
        ${length}=  Get Length  ${global_dictionary}
        IF  ${length} != 0
          Set To Dictionary  ${device_dictionary}  global  ${global_dictionary}
        ELSE
          baseline set test comment  Skipping global , routing table scale for device '${device}'. total subnets from all route_source is 0
        END
        ${output}=  run "show ip vrf"
        ${status}=  Run Keyword And Return Status  output contains "Name"
        IF  ${status}
          ${vrf_list}=  Get Regexp Matches  [\r\n] +(\\S+)  1
          FOR  ${vrf}  IN  @{vrf_list[1:]}
            IF  "${routing_table_vrf_list}" != "${EMPTY}"
              ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${routing_table_vrf_list}  ${vrf}
              Continue For Loop If  not ${include_vrf}
            END
            run parsed "show ip route vrf ${vrf} summary" with template "${XE_SHOW_IP_ROUTE_SUMMARY_TEMPLATE}"
            ${vrf_dictionary}=  Create Dictionary
            ${route_source_list}=  Get Parsed  route_source  return_all=True
            FOR  ${route_source}  IN  @{route_source_list}
              ${value}=  get parsed "subnets" where "route_source" is "${route_source}"
              ${value}=  Evaluate  int(${value})
              IF  ${value} == 0
                #baseline set test comment  Skipping route_source '${route_source}' vrf '${vrf}' , routing table scale for device '${device}'. subnets is 0
                Continue For Loop
              END
              Set To Dictionary  ${vrf_dictionary}  ${route_source}  ${value}
            END
            ${length}=  Get Length  ${vrf_dictionary}
            IF  ${length} != 0
              Set To Dictionary  ${device_dictionary}  ${vrf}  ${vrf_dictionary}
            ELSE
              baseline set test comment  Skipping vrf '${vrf}' , routing table scale for device '${device}'. total subnets from all route_source is 0
            END
          END
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. create baseline data for routing table scale currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      ${length}=  Get Length  ${device_dictionary}
      IF  ${length} != 0
        Set To Dictionary  ${BASELINE_ROUTE_SCALE}  ${device}  ${device_dictionary}
      ELSE
        baseline set test comment  Skipping. create baseline data for routing table scale for device '${device}': total routes found in all route tables is 0
      END
    END
    ${length}=  Get Length  ${BASELINE_ROUTE_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_ROUTE_SCALE  ${BASELINE_ROUTE_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for routing table scale: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for routing table scale: Warning, no data collected, nothing added to BASELINE
    END

baseline create data for routing table scale ipv6
    [Arguments]  ${routing_table_vrf_list}=${EMPTY}
    baseline set test title  create baseline data for routing table scale ipv6
    ${BASELINE_IPV6_ROUTE_SCALE}=  Create Dictionary
    FOR  ${device}  IN  @{DEVICES}
      baseline set test title  create baseline data for routing table scale ipv6: ${device}
      connect to device "${device}"
      ${node_type}=  Set Variable  ${NODES_TYPE['${device}']}
      ${device_dictionary}=  Create Dictionary
      IF  "${node_type}" == "cXR" or "${node_type}" == "eXR" or "${node_type}" == "LNTXR"
        run parsed "show route ipv6 summary"
        ${global_dictionary}=  Create Dictionary
        ${routesource_list}=  Get Parsed  routesource  return_all=True
        FOR  ${routesource}  IN  @{routesource_list}
          ${value}=  get parsed "routes" where "routesource" is "${routesource}"
          ${value}=  Evaluate  int(${value})
          IF  ${value} == 0
            #baseline set test comment  Skipping routesource '${routesource}' , routing table scale for device ipv6 '${device}'. routes is 0
            Continue For Loop
          END
          Set To Dictionary  ${global_dictionary}  ${routesource}  ${value}
        END
        ${length}=  Get Length  ${global_dictionary}
        IF  ${length} != 0
          Set To Dictionary  ${device_dictionary}  global  ${global_dictionary}
        ELSE
          baseline set test comment  Skipping vrf 'global' , routing table scale ipv6 for device '${device}'. total routes from all routesource is 0
        END
        ${status}  ${output}=  Run Keyword And Ignore Error  run parsed "show route vrf all ipv6 summary" with template "${XR_SHOW_ROUTE_VRF_SUMMARY_TEXTFSM}"
        IF  "${status}" != "FAIL"
          ${status}  ${output}=  Run Keyword And Ignore Error  YamlPath Parse  data=${output}  query=[routes!=0]
          IF  "${status}" != "FAIL"
            FOR  ${item}  IN  @{output}
              ${vrf}=  Set Variable  ${item['vrf']}
              IF  "${routing_table_vrf_list}" != "${EMPTY}"
                ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${routing_table_vrf_list}  ${vrf}
                Continue For Loop If  not ${include_vrf}
              END
              ${routesource}=  Set Variable  ${item['routesource']}
              ${routes}=  Evaluate  int(${item['routes']})
              ${vrf_exists}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${device_dictionary}  ${vrf}
              IF  not ${vrf_exists}
                ${empty_dictionary}=  Create Dictionary
                Set To Dictionary  ${device_dictionary}  ${vrf}  ${empty_dictionary}
              END
              Set To Dictionary  ${device_dictionary['${vrf}']}  ${routesource}  ${routes}
            END
          END
        END
      ELSE IF  "${node_type}" == "iosxe" or "${node_type}" == "ios"
        run parsed "show ipv6 route summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
        ${global_dictionary}=  Create Dictionary
        ${route_source_list}=  Get Parsed  route_source  return_all=True
        FOR  ${route_source}  IN  @{route_source_list}
          ${value}=  get parsed "networks" where "route_source" is "${route_source}"
          ${value}=  Evaluate  int(${value})
          IF  ${value} == 0
            #baseline set test comment  Skipping route_source '${route_source}' , routing table scale ipv6 for device '${device}'. subnets is 0
            Continue For Loop
          END
          Set To Dictionary  ${global_dictionary}  ${route_source}  ${value}
        END
        ${length}=  Get Length  ${global_dictionary}
        IF  ${length} != 0
          Set To Dictionary  ${device_dictionary}  global  ${global_dictionary}
        ELSE
          baseline set test comment  Skipping global , routing table ipv6 scale for device '${device}'. total subnets from all route_source is 0
        END
        ${output}=  run "show ip vrf"
        ${status}=  Run Keyword And Return Status  output contains "Name"
        IF  ${status}
          ${vrf_list}=  Get Regexp Matches  [\r\n] +(\\S+)  1
          FOR  ${vrf}  IN  @{vrf_list[1:]}
            IF  "${routing_table_vrf_list}" != "${EMPTY}"
              ${include_vrf}=  Run Keyword And Return Status  List Should Contain Value  ${routing_table_vrf_list}  ${vrf}
              Continue For Loop If  not ${include_vrf}
            END
            run parsed "show ipv6 route vrf ${vrf} summary" with template "${XE_SHOW_IPV6_ROUTE_SUMMARY_TEMPLATE}"
            ${vrf_dictionary}=  Create Dictionary
            ${route_source_list}=  Get Parsed  route_source  return_all=True
            FOR  ${route_source}  IN  @{route_source_list}
              ${value}=  get parsed "networks" where "route_source" is "${route_source}"
              ${value}=  Evaluate  int(${value})
              IF  ${value} == 0
                #baseline set test comment  Skipping route_source '${route_source}' vrf '${vrf}' , routing table scale ipv6 for device '${device}'. subnets is 0
                Continue For Loop
              END
              Set To Dictionary  ${vrf_dictionary}  ${route_source}  ${value}
            END
            ${length}=  Get Length  ${vrf_dictionary}
            IF  ${length} != 0
              Set To Dictionary  ${device_dictionary}  ${vrf}  ${vrf_dictionary}
            ELSE
              baseline set test comment  Skipping vrf '${vrf}' , routing table scale ipv6 for device '${device}'. total subnets from all route_source is 0
            END
          END
        END
      ELSE IF  "${node_type}" == "nxos"
        baseline set test comment  Skipping. create baseline data for routing table scale ipv6 currently available only for cXR, eXR, iosxe, ios. This device is type '${node_type}'
        Continue For Loop
      END
      ${length}=  Get Length  ${device_dictionary}
      IF  ${length} != 0
        Set To Dictionary  ${BASELINE_IPV6_ROUTE_SCALE}  ${device}  ${device_dictionary}
      ELSE
        baseline set test comment  Skipping. create baseline data for routing table scale ipv6 for device '${device}': total routes found in all route tables is 0
      END
    END
    ${length}=  Get Length  ${BASELINE_IPV6_ROUTE_SCALE}
    IF  ${length} != 0
      Set To Dictionary  ${BASELINE}  BASELINE_IPV6_ROUTE_SCALE  ${BASELINE_IPV6_ROUTE_SCALE}
      Set Test Variable  ${BASELINE}
      baseline set test pass  [PASS] create baseline data for routing table scale ipv6: Pass, collected data is added to BASELINE
    ELSE
      baseline set test warn  [WARN] create baseline data for routing table scale ipv6: Warning, no data collected, nothing added to BASELINE
    END
