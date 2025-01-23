*** Settings ***

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

*** Keywords ***

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
    Click Element    xpath=//android.widget.Button[@resource-id="com.ab.apiclient:id/btnSend"]

    #save response
    Wait Until Element Is Visible    accessibility_id=Raw    ${TIMEOUT}
    Click Element    accessibility_id=Raw
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
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
    Click Element    xpath=//android.widget.Button[@resource-id="com.ab.apiclient:id/btnSend"]

    #save response
    Wait Until Element Is Visible    accessibility_id=Raw    ${TIMEOUT}
    Click Element    accessibility_id=Raw
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
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

deleteJsonFile(${randomNumber})
    Remove File    tests/fixtures/testdata-${randomNumber}.json
    Log To Console    Json file deleted

createUser(${randomNumber})
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
    # ...                 newCommandTimeout=300
    # ...                 noReset=true
    # ...                 fullReset=false

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
    Click Element    xpath=//android.widget.Button[@resource-id="com.ab.apiclient:id/btnSend"]
    
    #save response
    Wait Until Element Is Visible    accessibility_id=Raw    ${TIMEOUT}
    Click Element    accessibility_id=Raw
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
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

addAcceptHeader()
    Wait Until Element Is Visible    xpath=//android.widget.ImageView    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageView    
    Wait Until Element Is Visible    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"]    
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Accept"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Accept"]      
    Wait Until Element Is Visible    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/xml"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/xml"]

addContentTypeHeader()
    Wait Until Element Is Visible    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView    ${TIMEOUT}
    Click Element    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView    
    Wait Until Element Is Visible    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"])[2]    ${TIMEOUT}
    Click Element    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDown"])[2]   
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Content-Type"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="Content-Type"]
    Wait Until Element Is Visible    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"])[2]    ${TIMEOUT}
    Click Element    xpath=(//android.widget.ImageView[@resource-id="com.ab.apiclient:id/iconDownVal"])[2]   
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/x-www-form-urlencoded"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@resource-id="android:id/text1" and @text="application/x-www-form-urlencoded"]

addTokenHeader(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
    Wait Until Element Is Visible    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView    ${TIMEOUT}
    Click Element    xpath=//android.widget.LinearLayout[@resource-id="com.ab.apiclient:id/llAddHeader"]/android.widget.ImageView
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etKey" and @text="Key"]    x-auth-token
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etValue" and @text="Value"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etValue" and @text="Value"]    ${user_token}

increasingRequestResponseTimeout()
    Wait Until Element Is Visible    class=android.widget.ImageButton    ${TIMEOUT}
    Click Element    class=android.widget.ImageButton
    Wait Until Element Is Visible    android=new UiSelector().text("Settings")   ${TIMEOUT}
    Click Element    android=new UiSelector().text("Settings")
    Wait Until Element Is Visible    id=com.ab.apiclient:id/etTimeoutConnection    ${TIMEOUT}
    Clear Text    id=com.ab.apiclient:id/etTimeoutConnection
    Input Text    id=com.ab.apiclient:id/etTimeoutConnection    120
    Wait Until Element Is Visible    id=com.ab.apiclient:id/etTimeoutREAD    ${TIMEOUT}
    Clear Text    id=com.ab.apiclient:id/etTimeoutREAD
    Input Text    id=com.ab.apiclient:id/etTimeoutREAD    120    
    Wait Until Element Is Visible    id=com.ab.apiclient:id/etTimeoutWRITE    ${TIMEOUT}
    Clear Text    id=com.ab.apiclient:id/etTimeoutWRITE
    Input Text    id=com.ab.apiclient:id/etTimeoutWRITE    120
    Wait Until Element Is Visible    class=android.widget.ImageButton    ${TIMEOUT}
    Click Element    class=android.widget.ImageButton
    Wait Until Element Is Visible    android=new UiSelector().text("New Request")
    Click Element    android=new UiSelector().text("New Request")
