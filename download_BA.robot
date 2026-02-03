*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser KJP
Suite Teardown    Close Browser

*** Variables ***
${URL}          https://edu.jakarta.go.id/kjp/login
${BROWSER}      chrome
${USERNAME}     20105562
${PASSWORD}     444444
${ROWS}       xpath=//table//tr[td]
${TIMEOUT}        20s
${DOWNLOAD_BA_XPATH}    //tbody[@id='data']//a[@title='Download BA']

*** Keywords ***
Open Browser KJP
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    2s

*** Test Cases ***
Login Success
    Input Text    name=login   ${USERNAME}
    Input Text    name=password    ${PASSWORD}
    Click Button  id=login-btn
    Sleep    2s

Go to Menu Verifikasi KJP
    Wait Until Page Contains   Aplikasi    10s
    Click Link    Aplikasi
    Wait Until Element Is Visible    css=.card-body    10s
    Click Element     css=.card-body
    Wait Until Element Is Visible    xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]    20s
    Scroll Element Into View         xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]
    Click Element                    xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]
    Wait Until Page Contains    Verifikasi Lanjutan    60s


Download Semua BA
    #Klik select option show 500 data
    Click Element    xpath=//select[@id='size']
    Click Element    xpath=//option[@value='500']
    Press Keys    None    ESC
    Sleep    5s


    Wait Until Element Is Visible    xpath=${DOWNLOAD_BA_XPATH}    20s
    ${total}=    Get Element Count    xpath=${DOWNLOAD_BA_XPATH}
    Log    Total tombol Download BA: ${total}

    FOR    ${i}    IN RANGE    1    ${total}+1
        ${el}=    Set Variable    (${DOWNLOAD_BA_XPATH})[${i}]
        Scroll Element Into View    xpath=${el}
        Wait Until Element Is Visible    xpath=${el}    10s
        Click Element    xpath=${el}
        Sleep    1s
    END



