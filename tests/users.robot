*** Settings ***

Resource    ../resources/test.resource
Library    AppiumLibrary
Library    FakerLibrary
Library    JSONLibrary
Library    OperatingSystem
Library    Collections
Library    String
Library    Process

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
${TIMEOUT}            60

*** Test Cases ***
    
Creates a new user account
    ${randomNumber}    FakerLibrary.creditCardNumber
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
    ...                 appActivity=com.ab.apiclient.ui.Splash
    ...                 appWaitActivity=com.ab.apiclient.ui.Splash,com.ab.apiclient.*,com.ab.apiclient.ui.MainActivity
    ...                 appWaitDuration=20000
    ...                 uiautomator2ServerInstallTimeout=60000
    ...                 noReset=true
    ...                 autoDismissAlerts=true
    # ...                 avdArgs=--dns-server=8.8.8.8,8.8.4.4
    # ...                 newCommandTimeout=300
    # ...                 noReset=true
    # ...                 fullReset=false

    Run Process    adb    shell    svc wifi disable

    Sleep  5

    increasingRequestResponseTimeout()

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/register
    
    # add Accept and Content Tyepe headers
    addAcceptHeader()    
    addContentTypeHeader()

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    name
    Input Text    android=new UiSelector().text("Value")    ${user_name}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    email
    Input Text    android=new UiSelector().text("Value")    ${user_email}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    password
    Input Text    android=new UiSelector().text("Value")    ${user_password}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    # xpath=//android.widget.TextView[@text="Raw"]
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_cu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cu_string}
    ${response_cu_json}    Convert String To Json    ${response_cu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cu_json}    $.success
    ${status} =     Get Value From Json    ${response_cu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${user_name_resp} =  Get Value From Json    ${response_cu_json}    $.data.name
    ${user_name_value}=    Get From List    ${user_name_resp}    0
    ${user_name_str} =    Convert To String    ${user_name_value}
    ${user_email_resp}=    Get Value From Json    ${response_cu_json}    $.data.email
    ${user_email_value}=    Get From List    ${user_email_resp}    0
    ${user_email_str} =    Convert To String    ${user_email_value}
    ${user_id_resp}=    Get Value From Json    ${response_cu_json}    $.data.id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id} =    Convert To String    ${user_id_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    201
    Should Be Equal    ${message_str}    User account created successfully
    Should Be Equal    ${user_name_str}  ${user_name}
    Should Be Equal    ${user_email_str}    ${user_email}

    # creating .json file
    Create File    tests/fixtures/testdata-${randomNumber}.json	{"user_email":"${user_email}","user_id":"${user_id}","user_name":"${user_name}","user_password":"${user_password}"}

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    logInUser(${randomNumber})
    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Creates a new user account - Bad request
    ${randomNumber}    FakerLibrary.creditCardNumber
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
    ...                 appActivity=com.ab.apiclient.ui.Splash
    ...                 appWaitActivity=com.ab.apiclient.ui.Splash,com.ab.apiclient.*,com.ab.apiclient.ui.MainActivity
    ...                 appWaitDuration=20000
    ...                 uiautomator2ServerInstallTimeout=60000
    ...                 noReset=true
    ...                 autoDismissAlerts=true
    # ...                 avdArgs=--dns-server=8.8.8.8,8.8.4.4
    # ...                 newCommandTimeout=300
    # ...                 noReset=true
    # ...                 fullReset=false

    Run Process    adb    shell    svc wifi disable

    Sleep  5

    increasingRequestResponseTimeout()

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/register
    
    # add Accept and Content Tyepe headers
    addAcceptHeader()    
    addContentTypeHeader()

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    name
    Input Text    android=new UiSelector().text("Value")    ${user_name}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    email
    Input Text    android=new UiSelector().text("Value")    @${user_email}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    password
    Input Text    android=new UiSelector().text("Value")    ${user_password}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_cu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cu_string}
    ${response_cu_json}    Convert String To Json    ${response_cu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cu_json}    $.success
    ${status} =     Get Value From Json    ${response_cu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    400
    Should Be Equal    ${message_str}    A valid email address is required

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    Sleep  5
    [Teardown]    Close Application

Log in as an existing user
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/login
    
    # add Accept and Content Tyepe headers
    addAcceptHeader()    
    addContentTypeHeader()

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]
    
    # fill body                            
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    email
    Input Text    android=new UiSelector().text("Value")    ${user_email}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    password
    Input Text    android=new UiSelector().text("Value")    ${user_password}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_lu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_lu_string}
    ${response_lu_json}    Convert String To Json    ${response_lu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_lu_json}    $.success
    ${status} =     Get Value From Json    ${response_lu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_lu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${user_name_resp} =  Get Value From Json    ${response_lu_json}    $.data.name
    ${user_name_value}=    Get From List    ${user_name_resp}    0
    ${user_name_str} =    Convert To String    ${user_name_value}
    ${user_email_resp}=    Get Value From Json    ${response_lu_json}    $.data.email
    ${user_email_value}=    Get From List    ${user_email_resp}    0
    ${user_email_str} =    Convert To String    ${user_email_value}
    ${user_id_resp}=    Get Value From Json    ${response_lu_json}    $.data.id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}
    ${user_token_resp}=    Get Value From Json    ${response_lu_json}    $.data.token
    ${user_token_value}=    Get From List    ${user_token_resp}    0
    ${user_token} =    Convert To String    ${user_token_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Login successful
    Should Be Equal    ${user_id_str}    ${user_id}
    Should Be Equal    ${user_name_str}  ${user_name}
    Should Be Equal    ${user_email_str}    ${user_email}

    # creating .json file
    Create File    tests/fixtures/testdata-${randomNumber}.json	{"user_email":"${user_email}","user_id":"${user_id}","user_name":"${user_name}","user_password":"${user_password}","user_token":"${user_token}"}
    
    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Log in as an existing user - Bad request
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/login
    
    # add Accept and Content Tyepe headers
    addAcceptHeader()    
    addContentTypeHeader()

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]
    
    # fill body                            
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    email
    Input Text    android=new UiSelector().text("Value")    @${user_email}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    password
    Input Text    android=new UiSelector().text("Value")    ${user_password}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_lu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_lu_string}
    ${response_lu_json}    Convert String To Json    ${response_lu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_lu_json}    $.success
    ${status} =     Get Value From Json    ${response_lu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_lu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    400
    Should Be Equal    ${message_str}    A valid email address is required
        
    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]
    
    logInUser(${randomNumber})
    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Log in as an existing user - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/login
    
    # add Accept and Content Tyepe headers
    addAcceptHeader()    
    addContentTypeHeader()

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]
    
    # fill body                            
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    email
    Input Text    android=new UiSelector().text("Value")    ${user_email}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    password
    Input Text    android=new UiSelector().text("Value")    @${user_password}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_lu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_lu_string}
    ${response_lu_json}    Convert String To Json    ${response_lu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_lu_json}    $.success
    ${status} =     Get Value From Json    ${response_lu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_lu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Incorrect email address or password

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]
    
    logInUser(${randomNumber})
    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Retrieve user profile information
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    "
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "

    # select GET
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="GET"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="GET"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/profile
    
    # add Accept and Token headers
    addAcceptHeader()    
    addTokenHeader(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_ru_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_ru_string}
    ${response_ru_json}    Convert String To Json    ${response_ru_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_ru_json}    $.success
    ${status} =     Get Value From Json    ${response_ru_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_ru_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${user_name_resp} =  Get Value From Json    ${response_ru_json}    $.data.name
    ${user_name_value}=    Get From List    ${user_name_resp}    0
    ${user_name_str} =    Convert To String    ${user_name_value}
    ${user_email_resp}=    Get Value From Json    ${response_ru_json}    $.data.email
    ${user_email_value}=    Get From List    ${user_email_resp}    0
    ${user_email_str} =    Convert To String    ${user_email_value}
    ${user_id_resp}=    Get Value From Json    ${response_ru_json}    $.data.id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Profile successful
    Should Be Equal    ${user_id_str}    ${user_id}
    Should Be Equal    ${user_name_str}  ${user_name}
    Should Be Equal    ${user_email_str}    ${user_email}

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Retrieve user profile information - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    "
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "

    # select GET
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="GET"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="GET"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/profile
    
    # add Accept and Token headers
    addAcceptHeader()    
    addTokenHeaderUnauthorized(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_ru_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_ru_string}
    ${response_ru_json}    Convert String To Json    ${response_ru_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_ru_json}    $.success
    ${status} =     Get Value From Json    ${response_ru_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_ru_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Access token is not valid or has expired, you will need to login

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Update the user profile information
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
    ${updated_user_company}    FakerLibrary.Company
    ${updated_user_phone_int}    FakerLibrary.Random Int    min=10000000    max=99999999999999999999    step=1  
    ${updated_user_phone}    Convert To String    ${updated_user_phone_int}

    # select patch
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/profile
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    name
    Input Text    android=new UiSelector().text("Value")    ${user_name}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    phone
    Input Text    android=new UiSelector().text("Value")    ${updated_user_phone}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    company
    Input Text    android=new UiSelector().text("Value")    ${updated_user_company}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000
    
    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_uu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_uu_string}
    ${response_uu_json}    Convert String To Json    ${response_uu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_uu_json}    $.success
    ${status} =     Get Value From Json    ${response_uu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_uu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${user_name_resp} =  Get Value From Json    ${response_uu_json}    $.data.name
    ${user_name_value}=    Get From List    ${user_name_resp}    0
    ${user_name_str} =    Convert To String    ${user_name_value}
    ${user_email_resp}=    Get Value From Json    ${response_uu_json}    $.data.email
    ${user_email_value}=    Get From List    ${user_email_resp}    0
    ${user_email_str} =    Convert To String    ${user_email_value}
    ${user_id_resp}=    Get Value From Json    ${response_uu_json}    $.data.id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}
    ${user_company_resp}=    Get Value From Json    ${response_uu_json}    $.data.company
    ${user_company_value}=    Get From List    ${user_company_resp}    0
    ${user_company_str} =    Convert To String    ${user_company_value}
    ${user_phone_resp}=    Get Value From Json    ${response_uu_json}    $.data.phone
    ${user_phone_value}=    Get From List    ${user_phone_resp}    0
    ${user_phone_str} =    Convert To String    ${user_phone_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Profile updated successful
    Should Be Equal    ${user_id_str}    ${user_id}
    Should Be Equal    ${user_name_str}  ${user_name}
    Should Be Equal    ${user_email_str}    ${user_email}
    Should Be Equal    ${user_company_str}  ${updated_user_company}
    Should Be Equal    ${user_phone_str}    ${updated_user_phone}

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Update the user profile information - Bad Request
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
    ${updated_user_company}    FakerLibrary.Company
    ${updated_user_phone_int}    FakerLibrary.Random Int    min=10000000    max=99999999999999999999    step=1  
    ${updated_user_phone}    Convert To String    ${updated_user_phone_int}

    # select patch
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/profile
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    name
    Input Text    android=new UiSelector().text("Value")    a@#
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    phone
    Input Text    android=new UiSelector().text("Value")    ${updated_user_phone}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    company
    Input Text    android=new UiSelector().text("Value")    ${updated_user_company}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000
    
    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_uu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_uu_string}
    ${response_uu_json}    Convert String To Json    ${response_uu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_uu_json}    $.success
    ${status} =     Get Value From Json    ${response_uu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_uu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    400
    Should Be Equal    ${message_str}    User name must be between 4 and 30 characters

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Update the user profile information - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_email_data}    Get Value From Json    ${data}    $.user_email
    ${user_email_str}    Convert JSON To String	 ${user_email_data}
    ${user_email}    Remove String    ${user_email_str}    [    ]    '    " 
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_name_data}    Get Value From Json    ${data}    $.user_name
    ${user_name_str}    Convert JSON To String	 ${user_name_data}
    ${user_name}    Remove String    ${user_name_str}    [    ]    '    " 
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    " 
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
    ${updated_user_company}    FakerLibrary.Company
    ${updated_user_phone_int}    FakerLibrary.Random Int    min=10000000    max=99999999999999999999    step=1  
    ${updated_user_phone}    Convert To String    ${updated_user_phone_int}

    # select patch
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/profile
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeaderUnauthorized(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    name
    Input Text    android=new UiSelector().text("Value")    ${user_name}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    phone
    Input Text    android=new UiSelector().text("Value")    ${updated_user_phone}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    company
    Input Text    android=new UiSelector().text("Value")    ${updated_user_company}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000
    
     # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_uu_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_uu_string}
    ${response_uu_json}    Convert String To Json    ${response_uu_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_uu_json}    $.success
    ${status} =     Get Value From Json    ${response_uu_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_uu_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Access token is not valid or has expired, you will need to login

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Change a user\'s password
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    "
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    " 
    ${updated_user_password}    FakerLibrary.password

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/change-password
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    currentPassword
    Input Text    android=new UiSelector().text("Value")    ${user_password}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    newPassword
    Input Text    android=new UiSelector().text("Value")    ${updated_user_password}     
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_cup_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cup_string}
    ${response_cup_json}    Convert String To Json    ${response_cup_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cup_json}    $.success
    ${status} =     Get Value From Json    ${response_cup_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cup_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    The password was successfully updated

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Change a user\'s password - Bad Request
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    "
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    " 
    ${updated_user_password}    FakerLibrary.password

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/change-password
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    currentPassword
    Input Text    android=new UiSelector().text("Value")    ${user_password}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    newPassword
    Input Text    android=new UiSelector().text("Value")    123     
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_cup_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cup_string}
    ${response_cup_json}    Convert String To Json    ${response_cup_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cup_json}    $.success
    ${status} =     Get Value From Json    ${response_cup_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cup_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    400
    Should Be Equal    ${message_str}    New password must be between 6 and 30 characters

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Change a user\'s password - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_password_data}    Get Value From Json    ${data}    $.user_password
    ${user_password_str}    Convert JSON To String	 ${user_password_data}
    ${user_password}    Remove String    ${user_password_str}    [    ]    '    "
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    " 
    ${updated_user_password}    FakerLibrary.password

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/change-password
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeaderUnauthorized(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    currentPassword
    Input Text    android=new UiSelector().text("Value")    ${user_password}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    newPassword
    Input Text    android=new UiSelector().text("Value")    ${updated_user_password}     
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_cup_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cup_string}
    ${response_cup_json}    Convert String To Json    ${response_cup_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cup_json}    $.success
    ${status} =     Get Value From Json    ${response_cup_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cup_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Access token is not valid or has expired, you will need to login

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Log out a user via API
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    " 

    # select delete
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/logout
    
    # add Accept and Token headers
    addAcceptHeader()
    addTokenHeader(${randomNumber})

     # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_lou_string}=    Get Text    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    Log    string response is: ${response_lou_string}
    ${response_lou_json}    Convert String To Json    ${response_lou_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_lou_json}    $.success
    ${status} =     Get Value From Json    ${response_lou_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_lou_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    User has been successfully logged out

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    logInUser(${randomNumber})
    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Log out a user via API - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    " 

    # select delete
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/logout
    
    # add Accept and Token headers
    addAcceptHeader()
    addTokenHeaderUnauthorized(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_lou_string}=    Get Text    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    Log    string response is: ${response_lou_string}
    ${response_lou_json}    Convert String To Json    ${response_lou_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_lou_json}    $.success
    ${status} =     Get Value From Json    ${response_lou_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_lou_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Access token is not valid or has expired, you will need to login

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    logInUser(${randomNumber})
    deleteUser(${randomNumber})
    
    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Delete user account
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "

    # select delete
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/delete-account
    
    # add Accept and Token headers
    addAcceptHeader()
    addTokenHeader(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_du_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_du_string}
    ${response_du_json}    Convert String To Json    ${response_du_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_du_json}    $.success
    ${status} =     Get Value From Json    ${response_du_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_du_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Account successfully deleted

    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})

Delete user account - Unauthorized
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "

    # select delete
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="DELETE"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/users/delete-account
    
    # add Accept and Token headers
    addAcceptHeader()
    addTokenHeaderUnauthorized(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend
    
    #save response
    ${element_visible}    Run Keyword And Return Status    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=20
    IF    not ${element_visible}
        closeFullScreenAd()
        Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    timeout=10
    END
    ${response_du_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_du_string}
    ${response_du_json}    Convert String To Json    ${response_du_string}
     
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_du_json}    $.success
    ${status} =     Get Value From Json    ${response_du_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_du_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    False
    Should Be Equal    ${status_str}    401
    Should Be Equal    ${message_str}    Access token is not valid or has expired, you will need to login
    
    # press back key and create a new request
    Press Keycode             4
    Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageButton
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

    Sleep  5
    [Teardown]    Close Application
    
    deleteJsonFile(${randomNumber})



    