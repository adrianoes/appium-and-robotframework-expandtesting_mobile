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
${TIMEOUT}            60

*** Test Cases ***
    
Creates a new note
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
    ${note_category}    FakerLibrary.Random Element    elements=('Home', 'Work', 'Personal')
    ${note_description}    FakerLibrary.Sentence    nb_words=4
    ${note_title}    FakerLibrary.Sentence    nb_words=3

    # select post
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="POST"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/notes
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    title
    Input Text    android=new UiSelector().text("Value")    ${note_title}
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    description
    Input Text    android=new UiSelector().text("Value")    ${note_description}                         
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    category
    Input Text    android=new UiSelector().text("Value")    ${note_category}    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000
    
    # send request
    Click Element    id=com.ab.apiclient:id/btnSend

    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    ${response_cn_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cn_string}
    ${response_cn_json}    Convert String To Json    ${response_cn_string}
 
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cn_json}    $.success
    ${status} =     Get Value From Json    ${response_cn_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cn_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${note_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.id
    ${note_id_value}=    Get From List    ${note_id_resp}    0
    ${note_id} =    Convert To String    ${note_id_value}
    ${note_title_resp} =  Get Value From Json    ${response_cn_json}    $.data.title
    ${note_title_value}=    Get From List    ${note_title_resp}    0
    ${note_title_str} =    Convert To String    ${note_title_value}
    ${note_description_resp} =  Get Value From Json    ${response_cn_json}    $.data.description
    ${note_description_value}=    Get From List    ${note_description_resp}    0
    ${note_description_str} =    Convert To String    ${note_description_value}
    ${note_category_resp} =  Get Value From Json    ${response_cn_json}    $.data.category
    ${note_category_value}=    Get From List    ${note_category_resp}    0
    ${note_category_str} =    Convert To String    ${note_category_value}
    ${note_completed_resp} =    Get Value From Json    ${response_cn_json}    $.data.completed
    ${note_completed_value}=    Get From List    ${note_completed_resp}    0
    ${note_completed} =    Convert To String    ${note_completed_value}
    ${note_created_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.created_at
    ${note_created_at_value}=    Get From List    ${note_created_at_resp}    0
    ${note_created_at} =    Convert To String    ${note_created_at_value}
    ${note_updated_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.updated_at
    ${note_updated_at_value}=    Get From List    ${note_updated_at_resp}    0
    ${note_updated_at} =    Convert To String    ${note_updated_at_value}
    ${user_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.user_id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Note successfully created    
    Should Be Equal    ${note_title_str}    ${note_title}
    Should Be Equal    ${note_description_str}    ${note_description}
    Should Be Equal    ${note_category_str}    ${note_category}
    Should Not Be True    ${note_completed}    False
    Should Be Equal    ${user_id_str}    ${user_id}

    Create File    tests/fixtures/testdata-${randomNumber}.json	{"note_category":"${note_category}","note_description":"${note_description}","note_id":"${note_id}","note_title":"${note_title}","note_created_at":"${note_created_at}","note_updated_at":"${note_updated_at}","user_id":"${user_id}","user_token":"${user_token}"}

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

Get note by ID
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    createANewNote(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${note_category_data}    Get Value From Json    ${data}    $.note_category
    ${note_category_str}    Convert JSON To String	 ${note_category_data}
    ${note_category}    Remove String    ${note_category_str}    [    ]    '    " 
    ${note_description_data}    Get Value From Json    ${data}    $.note_description
    ${note_description_str}    Convert JSON To String	 ${note_description_data}
    ${note_description}    Remove String    ${note_description_str}    [    ]    '    " 
    ${note_id_data}    Get Value From Json    ${data}    $.note_id
    ${note_id_str}    Convert JSON To String	 ${note_id_data}
    ${note_id}    Remove String    ${note_id_str}    [    ]    '    " 
    ${note_title_data}    Get Value From Json    ${data}    $.note_title
    ${note_title_str}    Convert JSON To String	 ${note_title_data}
    ${note_title}    Remove String    ${note_title_str}    [    ]    '    " 
    ${note_created_at_data}    Get Value From Json    ${data}    $.note_created_at
    ${note_created_at_str}    Convert JSON To String	 ${note_created_at_data}
    ${note_created_at}    Remove String    ${note_created_at_str}    [    ]    '    " 
    ${note_updated_at_data}    Get Value From Json    ${data}    $.note_updated_at
    ${note_updated_at_str}    Convert JSON To String	 ${note_updated_at_data}
    ${note_updated_at}    Remove String    ${note_updated_at_str}    [    ]    '    "
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
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
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/notes/${note_id}
    
    # add Acceptand Token headers
    addAcceptHeader()    
    addTokenHeader(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend

    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    ${response_cn_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cn_string}
    ${response_cn_json}    Convert String To Json    ${response_cn_string}
 
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cn_json}    $.success
    ${status} =     Get Value From Json    ${response_cn_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cn_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${note_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.id
    ${note_id_value}=    Get From List    ${note_id_resp}    0
    ${note_id_str} =    Convert To String    ${note_id_value}
    ${note_title_resp} =  Get Value From Json    ${response_cn_json}    $.data.title
    ${note_title_value}=    Get From List    ${note_title_resp}    0
    ${note_title_str} =    Convert To String    ${note_title_value}
    ${note_description_resp} =  Get Value From Json    ${response_cn_json}    $.data.description
    ${note_description_value}=    Get From List    ${note_description_resp}    0
    ${note_description_str} =    Convert To String    ${note_description_value}
    ${note_category_resp} =  Get Value From Json    ${response_cn_json}    $.data.category
    ${note_category_value}=    Get From List    ${note_category_resp}    0
    ${note_category_str} =    Convert To String    ${note_category_value}
    ${note_completed_resp} =    Get Value From Json    ${response_cn_json}    $.data.completed
    ${note_completed_value}=    Get From List    ${note_completed_resp}    0
    ${note_completed} =    Convert To String    ${note_completed_value}
    ${note_created_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.created_at
    ${note_created_at_value}=    Get From List    ${note_created_at_resp}    0
    ${note_created_at_str} =    Convert To String    ${note_created_at_value}
    ${note_updated_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.updated_at
    ${note_updated_at_value}=    Get From List    ${note_updated_at_resp}    0
    ${note_updated_at_str} =    Convert To String    ${note_updated_at_value}
    ${user_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.user_id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Note successfully retrieved    
    Should Be Equal    ${note_title_str}    ${note_title}
    Should Be Equal    ${note_description_str}    ${note_description}
    Should Be Equal    ${note_category_str}    ${note_category}
    Should Be Equal    ${note_created_at_str}    ${note_created_at}
    Should Be Equal    ${note_updated_at_str}    ${note_updated_at}
    Should Not Be True    ${note_completed}    False
    Should Be Equal    ${user_id_str}    ${user_id}
    Should Be Equal    ${note_id_str}    ${note_id}

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

# Update an existing note
#     #this test case presents error in the apk. Apk is not handling PUT to this endpoint 
#     ${randomNumber}    FakerLibrary.creditCardNumber
#     createUser(${randomNumber})
#     logInUser(${randomNumber})
#     createANewNote(${randomNumber})
#     ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
#     ${note_category_data}    Get Value From Json    ${data}    $.note_category
#     ${note_category_str}    Convert JSON To String	 ${note_category_data}
#     ${note_category}    Remove String    ${note_category_str}    [    ]    '    " 
#     ${note_description_data}    Get Value From Json    ${data}    $.note_description
#     ${note_description_str}    Convert JSON To String	 ${note_description_data}
#     ${note_description}    Remove String    ${note_description_str}    [    ]    '    " 
#     ${note_id_data}    Get Value From Json    ${data}    $.note_id
#     ${note_id_str}    Convert JSON To String	 ${note_id_data}
#     ${note_id}    Remove String    ${note_id_str}    [    ]    '    " 
#     ${note_title_data}    Get Value From Json    ${data}    $.note_title
#     ${note_title_str}    Convert JSON To String	 ${note_title_data}
#     ${note_title}    Remove String    ${note_title_str}    [    ]    '    " 
#     ${note_created_at_data}    Get Value From Json    ${data}    $.note_created_at
#     ${note_created_at_str}    Convert JSON To String	 ${note_created_at_data}
#     ${note_created_at}    Remove String    ${note_created_at_str}    [    ]    '    " 
#     ${note_updated_at_data}    Get Value From Json    ${data}    $.note_updated_at
#     ${note_updated_at_str}    Convert JSON To String	 ${note_updated_at_data}
#     ${note_updated_at}    Remove String    ${note_updated_at_str}    [    ]    '    "
#     ${user_id_data}    Get Value From Json    ${data}    $.user_id
#     ${user_id_str}    Convert JSON To String	 ${user_id_data}
#     ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
#     ${user_token_data}    Get Value From Json    ${data}    $.user_token
#     ${user_token_str}    Convert JSON To String	 ${user_token_data}
#     ${user_token}    Remove String    ${user_token_str}    [    ]    '    "
#     ${updated_note_description}    FakerLibrary.Sentence    nb_words=4
#     ${updated_note_title}    FakerLibrary.Sentence    nb_words=3

#     # select PUT
#     Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
#     Click Element    id=com.ab.apiclient:id/spHttpMethod
#     Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PUT"]    ${TIMEOUT}
#     Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PUT"]
    
#     # input base url and endpoint
#     Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
#     Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/notes/${note_id}
    
#     # add Accept, Content Type and Token headers
#     addAcceptHeader()    
#     addContentTypeHeader()
#     addTokenHeader(${randomNumber})

#     # select body format
#     Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
#     Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

#     # fill body
#     Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
#     Input Text    android=new UiSelector().text("Key")    title
#     Input Text    android=new UiSelector().text("Value")    ${updated_note_title}
#     Swipe By Percent    50    80    50    20    1000
#     Click Element    id=com.ab.apiclient:id/btnAdd
#     Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
#     Input Text    android=new UiSelector().text("Key")    description
#     Input Text    android=new UiSelector().text("Value")    ${updated_note_description}                         
#     Swipe By Percent    50    80    50    20    1000
#     Click Element    id=com.ab.apiclient:id/btnAdd
#     Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
#     Input Text    android=new UiSelector().text("Key")    category
#     Input Text    android=new UiSelector().text("Value")    ${note_category}    
#     Swipe By Percent    50    80    50    20    1000
#     Click Element    id=com.ab.apiclient:id/btnAdd
#     Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
#     Input Text    android=new UiSelector().text("Key")    completed
#     Input Text    android=new UiSelector().text("Value")    true    
#     Swipe By Percent    50    80    50    20    1000
#     Click Element    id=com.ab.apiclient:id/btnAdd
#     Swipe By Percent    50    80    50    20    1000    

#     # send request
#     Click Element    id=com.ab.apiclient:id/btnSend

#     #save response
#     Wait Until Element Is Visible    accessibility_id=Raw    ${TIMEOUT}
#     Click Element    accessibility_id=Raw
#     Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
#     ${response_cn_string}=    Get Text    id=com.ab.apiclient:id/tvResult
#     Log    string response is: ${response_cn_string}
#     ${response_cn_json}    Convert String To Json    ${response_cn_string}
 
#     # Capturing variable values for assertions
#     ${success} =    Get Value From Json    ${response_cn_json}    $.success
#     ${status} =     Get Value From Json    ${response_cn_json}    $.status
#     ${status_value}=    Get From List    ${status}    0
#     ${status_str} =    Convert To String    ${status_value}
#     ${message} =    Get Value From Json    ${response_cn_json}    $.message
#     ${message_value}=    Get From List    ${message}    0
#     ${message_str} =    Convert To String    ${message_value}
#     ${note_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.id
#     ${note_id_value}=    Get From List    ${note_id_resp}    0
#     ${note_id_str} =    Convert To String    ${note_id_value}
#     ${note_title_resp} =  Get Value From Json    ${response_cn_json}    $.data.title
#     ${note_title_value}=    Get From List    ${note_title_resp}    0
#     ${note_title_str} =    Convert To String    ${note_title_value}
#     ${note_description_resp} =  Get Value From Json    ${response_cn_json}    $.data.description
#     ${note_description_value}=    Get From List    ${note_description_resp}    0
#     ${note_description_str} =    Convert To String    ${note_description_value}
#     ${note_category_resp} =  Get Value From Json    ${response_cn_json}    $.data.category
#     ${note_category_value}=    Get From List    ${note_category_resp}    0
#     ${note_category_str} =    Convert To String    ${note_category_value}
#     ${note_completed_resp} =    Get Value From Json    ${response_cn_json}    $.data.completed
#     ${note_completed_value}=    Get From List    ${note_completed_resp}    0
#     ${note_completed} =    Convert To String    ${note_completed_value}
#     ${note_created_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.created_at
#     ${note_created_at_value}=    Get From List    ${note_created_at_resp}    0
#     ${note_created_at_str} =    Convert To String    ${note_created_at_value}
#     ${note_updated_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.updated_at
#     ${note_updated_at_value}=    Get From List    ${note_updated_at_resp}    0
#     ${note_updated_at_str} =    Convert To String    ${note_updated_at_value}
#     ${user_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.user_id
#     ${user_id_value}=    Get From List    ${user_id_resp}    0
#     ${user_id_str} =    Convert To String    ${user_id_value}

#     # assertions
#     Should Be True    ${success}    True
#     Should Be Equal    ${status_str}    200
#     Should Be Equal    ${message_str}    Note successfully Updated    
#     Should Be Equal    ${note_title_str}    ${updated_note_title}
#     Should Be Equal    ${note_description_str}    ${updated_note_description}
#     Should Be Equal    ${note_category_str}    ${note_category}
#     Should Be Equal    ${note_created_at_str}    ${note_created_at}
#     Should Be Equal    ${note_updated_at_str}    ${note_updated_at}
#     Should Not Be True    ${note_completed}    True
#     Should Be Equal    ${user_id_str}    ${user_id}
#     Should Be Equal    ${note_id_str}    ${note_id}

#     # press back key and create a new request
#     Press Keycode             4
#     Wait Until Element Is Visible    xpath=//android.widget.ImageButton    ${TIMEOUT}
#     Click Element    xpath=//android.widget.ImageButton
#     Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]    ${TIMEOUT}
#     Click Element    xpath=//android.widget.CheckedTextView[@resource-id="com.ab.apiclient:id/design_menu_item_text" and @text="New Request"]

#     deleteUser(${randomNumber})
    
#     Sleep  5
#     [Teardown]    Close Application
    
#     deleteJsonFile(${randomNumber})

Update the completed status of a note
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    createANewNote(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${note_category_data}    Get Value From Json    ${data}    $.note_category
    ${note_category_str}    Convert JSON To String	 ${note_category_data}
    ${note_category}    Remove String    ${note_category_str}    [    ]    '    " 
    ${note_description_data}    Get Value From Json    ${data}    $.note_description
    ${note_description_str}    Convert JSON To String	 ${note_description_data}
    ${note_description}    Remove String    ${note_description_str}    [    ]    '    " 
    ${note_id_data}    Get Value From Json    ${data}    $.note_id
    ${note_id_str}    Convert JSON To String	 ${note_id_data}
    ${note_id}    Remove String    ${note_id_str}    [    ]    '    " 
    ${note_title_data}    Get Value From Json    ${data}    $.note_title
    ${note_title_str}    Convert JSON To String	 ${note_title_data}
    ${note_title}    Remove String    ${note_title_str}    [    ]    '    " 
    ${note_created_at_data}    Get Value From Json    ${data}    $.note_created_at
    ${note_created_at_str}    Convert JSON To String	 ${note_created_at_data}
    ${note_created_at}    Remove String    ${note_created_at_str}    [    ]    '    " 
    ${note_updated_at_data}    Get Value From Json    ${data}    $.note_updated_at
    ${note_updated_at_str}    Convert JSON To String	 ${note_updated_at_data}
    ${note_updated_at}    Remove String    ${note_updated_at_str}    [    ]    '    "
    ${user_id_data}    Get Value From Json    ${data}    $.user_id
    ${user_id_str}    Convert JSON To String	 ${user_id_data}
    ${user_id}    Remove String    ${user_id_str}    [    ]    '    " 
    ${user_token_data}    Get Value From Json    ${data}    $.user_token
    ${user_token_str}    Convert JSON To String	 ${user_token_data}
    ${user_token}    Remove String    ${user_token_str}    [    ]    '    "

    # select PATCH
    Wait Until Element Is Visible    id=com.ab.apiclient:id/spHttpMethod    ${TIMEOUT}
    Click Element    id=com.ab.apiclient:id/spHttpMethod
    Wait Until Element Is Visible    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.CheckedTextView[@resource-id="android:id/text1" and @text="PATCH"]
    
    # input base url and endpoint
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    ${TIMEOUT}
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/notes/${note_id}
    
    # add Accept, Content Type and Token headers
    addAcceptHeader()    
    addContentTypeHeader()
    addTokenHeader(${randomNumber})

    # select body format
    Wait Until Element Is Visible    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]    ${TIMEOUT}
    Click Element    xpath=//android.widget.RadioButton[@resource-id="com.ab.apiclient:id/rbFormUrlEncode"]

    # fill body
    Wait Until Element Is Visible    android=new UiSelector().text("Key")    ${TIMEOUT}
    Input Text    android=new UiSelector().text("Key")    completed
    Input Text    android=new UiSelector().text("Value")    true    
    Swipe By Percent    50    80    50    20    1000
    Click Element    id=com.ab.apiclient:id/btnAdd
    Swipe By Percent    50    80    50    20    1000    

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend

    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    ${response_cn_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_cn_string}
    ${response_cn_json}    Convert String To Json    ${response_cn_string}
 
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_cn_json}    $.success
    ${status} =     Get Value From Json    ${response_cn_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_cn_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}
    ${note_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.id
    ${note_id_value}=    Get From List    ${note_id_resp}    0
    ${note_id_str} =    Convert To String    ${note_id_value}
    ${note_title_resp} =  Get Value From Json    ${response_cn_json}    $.data.title
    ${note_title_value}=    Get From List    ${note_title_resp}    0
    ${note_title_str} =    Convert To String    ${note_title_value}
    ${note_description_resp} =  Get Value From Json    ${response_cn_json}    $.data.description
    ${note_description_value}=    Get From List    ${note_description_resp}    0
    ${note_description_str} =    Convert To String    ${note_description_value}
    ${note_category_resp} =  Get Value From Json    ${response_cn_json}    $.data.category
    ${note_category_value}=    Get From List    ${note_category_resp}    0
    ${note_category_str} =    Convert To String    ${note_category_value}
    ${note_completed_resp} =    Get Value From Json    ${response_cn_json}    $.data.completed
    ${note_completed_value}=    Get From List    ${note_completed_resp}    0
    ${note_completed} =    Convert To String    ${note_completed_value}
    ${note_created_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.created_at
    ${note_created_at_value}=    Get From List    ${note_created_at_resp}    0
    ${note_created_at_str} =    Convert To String    ${note_created_at_value}
    ${note_updated_at_resp} =  Get Value From Json    ${response_cn_json}    $.data.updated_at
    ${note_updated_at_value}=    Get From List    ${note_updated_at_resp}    0
    ${note_updated_at_str} =    Convert To String    ${note_updated_at_value}
    ${user_id_resp}=    Get Value From Json    ${response_cn_json}    $.data.user_id
    ${user_id_value}=    Get From List    ${user_id_resp}    0
    ${user_id_str} =    Convert To String    ${user_id_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Note successfully Updated    
    Should Be Equal    ${note_title_str}    ${note_title}
    Should Be Equal    ${note_description_str}    ${note_description}
    Should Be Equal    ${note_category_str}    ${note_category}
    Should Be Equal    ${note_created_at_str}    ${note_created_at}
    Should Not Be Equal    ${note_updated_at_str}    ${note_updated_at}
    Should Be True    ${note_completed}    True
    Should Be Equal    ${user_id_str}    ${user_id}
    Should Be Equal    ${note_id_str}    ${note_id}

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

Delete a note by ID
    ${randomNumber}    FakerLibrary.creditCardNumber
    createUser(${randomNumber})
    logInUser(${randomNumber})
    createANewNote(${randomNumber})
    ${data}    Load Json From File    tests/fixtures/testdata-${randomNumber}.json
    ${note_id_data}    Get Value From Json    ${data}    $.note_id
    ${note_id_str}    Convert JSON To String	 ${note_id_data}
    ${note_id}    Remove String    ${note_id_str}    [    ]    '    " 
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
    Input Text    xpath=//android.widget.EditText[@resource-id="com.ab.apiclient:id/etUrl"]    https://practice.expandtesting.com/notes/api/notes/${note_id}
    
    # add Accept and Token headers
    addAcceptHeader()
    addTokenHeader(${randomNumber})

    # send request
    Click Element    id=com.ab.apiclient:id/btnSend

    #save response
    Wait Until Element Is Visible    android=new UiSelector().text("Raw")    ${TIMEOUT}
    Click Element    android=new UiSelector().text("Raw")
    Wait Until Element Is Visible    id=com.ab.apiclient:id/tvResult    ${TIMEOUT}
    ${response_dn_string}=    Get Text    id=com.ab.apiclient:id/tvResult
    Log    string response is: ${response_dn_string}
    ${response_dn_json}    Convert String To Json    ${response_dn_string}
 
    # Capturing variable values for assertions
    ${success} =    Get Value From Json    ${response_dn_json}    $.success
    ${status} =     Get Value From Json    ${response_dn_json}    $.status
    ${status_value}=    Get From List    ${status}    0
    ${status_str} =    Convert To String    ${status_value}
    ${message} =    Get Value From Json    ${response_dn_json}    $.message
    ${message_value}=    Get From List    ${message}    0
    ${message_str} =    Convert To String    ${message_value}

    # assertions
    Should Be True    ${success}    True
    Should Be Equal    ${status_str}    200
    Should Be Equal    ${message_str}    Note successfully deleted

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










    