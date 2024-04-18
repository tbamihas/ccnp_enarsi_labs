*** Settings ***

Library     CXTA
Resource    cxta.robot

Library     OperatingSystem
Library     DateTime
Library     String
Library     Collections

Resource   CX_Baseline_Robot/cx_baseline_robot.resource
Resource   textfsm/textfsm.resource
Resource   keywords.resource
Variables  variables.yaml