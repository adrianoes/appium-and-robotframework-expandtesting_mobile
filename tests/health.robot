*** Settings ***

Resource    ../resources/test.resource
Library    AppiumLibrary
Library    FakerLibrary
Library    JSONLibrary
Library    OperatingSystem
Library    Collections
Library    String

*** Variables ***

${APPIUM_PORT}    4723
# for local testing, use the URL without "/wd/hub ". When commiting, use the complete one and comment the short one.
${APPIUM_URL}    http://localhost:${APPIUM_PORT}/wd/hub 
# ${APPIUM_URL}    http://localhost:${APPIUM_PORT} 
${PLATFORM_NAME}    android
${AUTOMATION_NAME}    UIAutomator2
${APP_PATH}    ${EXECDIR}/apps/apiClient.apk 
${ADB_TIMEOUT}    60000
${AUTO_GRANT_PERMISSIONS}    true
${PLATFORM_VERSION}    10.0
${DEVICE_NAME}    Pixel_4_API_29
${TIMEOUT}            30

*** Test Cases ***
    
Check api healt
    Open Application    ${APPIUM_URL}
    ...                 platformName=${PLATFORM_NAME} 
    ...                 platformVersion=${PLATFORM_VERSION}
    ...                 deviceName=${DEVICE_NAME}
    ...                 automationName=${AUTOMATION_NAME}
    ...                 app=${APP_PATH}
    ...                 adbExecTimeout=${ADB_TIMEOUT}
    ...                 autoGrantPermissions=${AUTO_GRANT_PERMISSIONS}
    ...                 appActivity=com.ab.apiclient.ui.Splash
    ...                 appWaitActivity=com.ab.apiclient.ui.Splash,com.ab.apiclient.*,com.ab.apiclient.ui.MainActivity
    ...                 appWaitDuration=20000
    ...                 uiautomator2ServerInstallTimeout=60000
    # ...                 newCommandTimeout=300
    # ...                 noReset=true
    # ...                 fullReset=false


    Sleep  5

    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/health-check
    
   # add Accept header
    addAcceptHeader()

     # send request
    Click Element    xpath=//android.widget.Button[@resource-id="com.ab.apiclient:id/btnSend"]
    
    #save response
    Wait Until Element Is Visible    accessibility_id=Raw    ${TIMEOUT}
    Click Element    accessibility_id=Raw
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    ${response_ch_string}=    Get Text    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    Log    string response is: ${response_ch_string}
    ${response_ch_json}    Convert String To Json    ${response_ch_string}
 
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_ch_json}    $.success
    ${status} =     Get Value From Json    ${response_ch_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_ch_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Notes API is Running

    [Teardown]    Close Application




