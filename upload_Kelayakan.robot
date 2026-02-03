*** Settings ***
Library    SeleniumLibrary
Suite Setup    Open Browser KJP
Library    OperatingSystem
Suite Teardown    Close Browser

*** Variables ***
${URL}          https://edu.jakarta.go.id/kjp/login
${BROWSER}      chrome
${USERNAME}     20105562
${PASSWORD}     444444
${ROWS}       xpath=//table//tr[td]
${TIMEOUT}        20s
${UPLOAD_BTN}    //tbody[@id='data']//button[@title='Unggah Berkas']
${TOTAL_ROWS}    Get Element Count    xpath=//tbody[@id='data']//tr


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

Upload All BA
    #Klik select option show 500 data
    Click Element    xpath=//select[@id='size']
    Click Element    xpath=//option[@value='500']
    Press Keys    None    ESC
    Sleep    5s
    
   ${total}=    Get Element Count    xpath=//tbody[@id='data']//tr

    FOR    ${i}    IN RANGE    1    ${total}+1
    ${row}=    Set Variable    xpath=(//tbody[@id='data']//tr)[${i}]

        ${row_html}=    Get Element Attribute
        ...    xpath=(//tbody[@id='data']//tr)[${i}]
        ...    outerHTML
        
        # Scroll ke baris ke-i dulu (WAJIB)
        Scroll Element Into View
        ...    xpath=(//tbody[@id='data']//tr)[${i}]

        # Baru ambil nama siswa
        ${nama_siswa}=    Get Text
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//td[3][normalize-space()]

        Log    Upload untuk siswa: ${nama_siswa}


        # ================= CEK DATA DIBATALKAN =================
        ${skip}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//span[contains(text(),'Data Dibatalkan')]

        IF    ${skip}
            Log    ${nama_siswa} - Data Dibatalkan, SKIP
            Continue For Loop
        END

        # ================= CEK KELAS 6 =================
        ${is_kelas}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//td[4][contains(normalize-space(.), 'Kelas 2')]

        IF    not ${is_kelas}
            Log    ${nama_siswa} - Bukan Kelas 1, SKIP
            Continue For Loop
        END

        # ================= LANJUT PROSES =================
       ${btn}=    Set Variable
            ...    xpath=(//tbody[@id='data']//tr)[${i}]//button[@title='Unggah Berkas']

            Scroll Element Into View    ${btn}
            Click Element              ${btn}

        # --- Wait Show Modal ---
        Wait Until Element Is Visible
        ...    xpath=//div[contains(@class,'modal')]//h5[normalize-space(.)='Data Unggahan Dokumen']
        ...    1000s
        Log    Siswa ${nama_siswa}

        # --- Kelayakan ---
        ${file_kelayakan}=    Set Variable    C:/Users/sdnte/Downloads/KJP/${nama_siswa}_1.pdf

        ${file_ada}=    Run Keyword And Return Status
        ...    File Should Exist    ${file_kelayakan}

        IF    not ${file_ada}
            Log    File tidak ditemukan → SKIP ${nama_siswa}
            Press Keys    xpath=//body    ESC
            Wait Until Element Is Not Visible
            ...    xpath=//div[@id='jakedu-modal-xl']
            ...    30s
            Continue For Loop
        END

        Choose File    xpath=//input[@placeholder='File Instrumen Kelayakan']    ${file_kelayakan}
        Sleep    1s
        Click Element    xpath=//span[@id='instrumen-kelayakan-btn']
        Wait Until Element Does Not Contain
        ...    xpath=//div[contains(@class,'notify-alert')]
        ...    Upload Sukses
        ...    10s

        # Tutup modal
        Press Keys    xpath=//body    ESC
        Wait Until Element Is Not Visible
        ...    xpath=//div[@id='jakedu-modal-xl']
        ...    30s
        Wait Until Element Is Visible    xpath=(//tbody[@id='data']//tr)[${i}]//td[3]    10s

    END

    Sleep  10s
