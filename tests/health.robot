*** Settings ***

Library    AppiumLibrary

*** Test Cases ***
    
Check api healt
    Open Application    http://localhost:4723
    ...                 platformName=Android  
    ...                 deviceName=Android Emulator
    ...                 automationName=UIAutomator2
    ...                 app=${EXECDIR}/apps/apiClient.apk 
    ...                 adbExecTimeout=60000
    ...                 autoGrantPermissions=true

