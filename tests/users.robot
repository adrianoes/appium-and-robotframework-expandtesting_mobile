
*** Settings ***

Library    AppiumLibrary
Library    FakerLibrary

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
${TIMEOUT}            10



*** Test Cases ***
    
Creates a new user account via API
    ${random_letter}    FakerLibrary.Random Lowercase Letter
    ${random_email}    FakerLibrary.Email
    ${user_email}    Catenate    SEPARATOR=    ${random_letter}    ${random_email}
    ${user_name}    FakerLibrary.Name
    ${user_password}    FakerLibrary.password

    Open Application    ${APPIUM_URL}
    ...                 platformName=${PLATFORM_NAME} 
    ...                 platformVersion=${PLATFORM_VERSION}
    ...                 deviceName=${DEVICE_NAME}
    ...                 automationName=${AUTOMATION_NAME}
    ...                 app=${APP_PATH}
    ...                 adbExecTimeout=${ADB_TIMEOUT}
    ...                 autoGrantPermissions=${AUTO_GRANT_PERMISSIONS}

    Sleep  10
    Log Source
    Capture Page Screenshot
    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/register
    
    # add first header
    Wait Until Element Is Visible    xpath=//android.widget.ImageView    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageView    
    Wait Until Element Is Visible    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"]    
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Accept"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Accept"]      
    Wait Until Element Is Visible    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"]
    Click Element    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/xml"]
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/xml"]
    
    # add second header
    Wait Until Element Is Visible    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView    ${TIMEOUT}
    Click Element    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView    
    Wait Until Element Is Visible    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"])[2]    ${TIMEOUT}
    Click Element    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"])[2]   
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Content-Type"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Content-Type"]
    Wait Until Element Is Visible    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"])[2]
    Click Element    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"])[2]   
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/x-www-form-urlencoded"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/x-www-form-urlencoded"]

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    name
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etValue" and @text="Value"]    ${user_name}
    Click Element    xpath=//android.widget.TextView[@resource-id="com.ab.apiclient:id/btnAdd"]
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    email
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etValue" and @text="Value"]    ${user_email}                         
    Click Element    xpath=//android.widget.TextView[@resource-id="com.ab.apiclient:id/btnAdd"]
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    password
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etValue" and @text="Value"]    ${user_password}

    # if click send here, app does not get that password was inuted. need to add a blank field
    Swipe By Percent    50    80    50    20    1000
    Click Element    xpath=//android.widget.TextView[@resource-id="com.ab.apiclient:id/btnAdd"]
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    ${TIMEOUT}

    # send request
    Click Element    xpath=//android.widget.Button[@resource-id="com.ab.apiclient:id/btnSend"]
    
    Sleep  10
    [Teardown]    Close Application
    



