*** Settings ***
Library             CXTA
Library             OperatingSystem
Library             Collections
Library             String
Library             DateTime
Resource            cxta.robot
Resource            ${EXECDIR}/automation/resources/keywords.resource
Variables           ${EXECDIR}/automation/resources/testbed.yaml
Variables           ${EXECDIR}/automation/resources/variables.yaml
