*** Settings ***
Documentation       Apply backup config to target lab.

Resource            ${EXECDIR}/automation/resources/settings.robot

Suite Setup    Setup

*** Variables ***
${out}=    """address            ref clock         st      when    poll   reach   delay   offset    disp 
...        ~172.31.32.2       172.31.32.1       5       29      1024   377     4.2     -8.59     1.6 
...        +~192.168.13.33    192.168.1.111     3       69      128    377     4.1     3.48      2.3 
...        *~192.168.13.57    192.168.1.111     3       32      128    377     7.9     11.18     3.6 
...        * master (synced), # master (unsynced), + selected, - candidate, ~ configured"""

*** Test Cases ***
Test Regex
    # ${pattern}=    Set Variable    (?P<state>[*#~+\\- ]*)\\s*(?P<address>[0-9a-fA-F:.]+)
    # @{matches}=    Get Regexp Matches    ${out}    ${pattern}    -1    flags=MULTILINE
    ${pattern_1}=    Set Variable    \\S+\\b(\\d{1,3}(\\.\\d{1,3}){3}|(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})\\b
    ${pattern_2}=    Set Variable    (\\S+\\b\\d{1,3}(\\.\\d{1,3}){3}|(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})\\b
    @{matches_1}=    Get Regexp Matches    ${out}    ${pattern_1}    1    flags=MULTILINE
    @{matches_2}=    Get Regexp Matches    ${out}    ${pattern_2}    1    flags=MULTILINE
    Log    Matches: ${matches_1}  console=yes
    Log    Matches: ${matches_2}  console=yes

