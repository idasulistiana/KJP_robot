*** Settings ***
Library    SeleniumLibrary
Library    String
Library    OperatingSystem
Suite Setup    Open Browser KJP
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
    Wait Until Page Contains   Aplikasi        10s
    Click Link    Aplikasi
    Wait Until Element Is Visible    css=.card-body    10s
    Click Element     css=.card-body
    Wait Until Element Is Visible    xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]    10s
    Scroll Element Into View         xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]
    Click Element                    xpath=//a[.//h4[normalize-space()='Verifikasi Sekolah ( Lanjutan )']]
    Wait Until Page Contains    Verifikasi Lanjutan    60s

Upload All BA
    #Klik select option show 500 data
    Scroll Element Into View        xpath=//select[@id='size']
    Click Element    xpath=//select[@id='size']
    Click Element    xpath=//option[@value='500']
    Click Element    xpath=//body

    Wait Until Element Is Visible    xpath=${UPLOAD_BTN}  1s
    ${total}=    Get Element Count    xpath=${UPLOAD_BTN} 

    FOR    ${i}    IN RANGE    1    ${total}+1
        ${row_html}=    Get Element Attribute
        ...    xpath=(//tbody[@id='data']//tr)[${i}]
        ...    outerHTML

        # Scroll ke baris ke-i
        Scroll Element Into View    xpath=(//tbody[@id='data']//tr)[${i}]

        # Ambil nama siswa
        ${nama_siswa_raw}=    Get Text
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//td[3][normalize-space()]
        ${nama_siswa}=    Convert To Lower Case    ${nama_siswa_raw}

        Log    Upload untuk siswa: ${nama_siswa}

        
        # ================= SKIP CEK STATUS DATA DIBATALKAN =================
        ${skip}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//span[contains(text(),'Data Dibatalkan')]

        IF    ${skip}
            Log    ${nama_siswa} - Data Dibatalkan, SKIP
            Continue For Loop
        END

        # ================= CEK PER KELAS =================
        #${is_kelas}=    Run Keyword And Return Status
        #...    Page Should Contain Element
        #...    xpath=(//tbody[@id='data']//tr)[${i}]//td[4][contains(normalize-space(.), 'Kelas 6')]

        #IF    not ${is_kelas}
        #    Log    ${nama_siswa} - Bukan Kelas 2, SKIP
        #    Continue For Loop
        #END

        # ================= PROSES UPLOAD DI MODALNYA =================

        ${btn}=    Set Variable
        ...    xpath=(//tbody[@id='data']//tr)[${i}]//button[@title='Unggah Berkas']
        Scroll Element Into View    ${btn}
        Click Element              ${btn}
        sleep    1s

        # Tunggu modal muncul
        Wait Until Element Is Visible   xpath=//div[contains(@class,'modal')]//h5[normalize-space(.)='Data Unggahan Dokumen']      2s
        

        # --- SET FILE PATH ---
        ${file_permohonan}=    Set Variable     C:/Users/sdnte/Downloads/KJP/${nama_siswa}_2.pdf
        ${file_ketaatan}=      Set Variable     C:/Users/sdnte/Downloads/KJP/${nama_siswa}_3.pdf
        
        # --- CEK & UPLOAD PERMOHONAN ---
        ${permohonan_ada}=    Run Keyword And Return Status
        ...    OperatingSystem.File Should Exist    ${file_permohonan}

        IF    ${permohonan_ada}
            Choose File    xpath=//input[@placeholder='File Permohonan Bansos']    ${file_permohonan}
            Click Element    xpath=//span[@id='permohonan-bansos-btn']
            sleep   1s
        ELSE
            Log    SKIP ${nama_siswa} - File Permohonan tidak ditemukan
        END

        # --- CEK & UPLOAD KETAATAN ---
        ${ketaatan_ada}=    Run Keyword And Return Status
        ...    OperatingSystem.File Should Exist    ${file_ketaatan}

        IF    ${ketaatan_ada}
            Choose File    xpath=//input[@placeholder='File Ketaatan Pengguna']    ${file_ketaatan}
            Click Element    xpath=//span[@id='ketaatan-pengguna-btn']
           sleep   1s
        ELSE
            Log    SKIP ${nama_siswa} - File Ketaatan tidak ditemukan
        END

        sleep   1s
        
        # Tutup modal setelah upload semua berkas (atau skip)
        Press Keys    css=body    ESC
        Wait Until Element Is Not Visible    xpath=//div[contains(@class,'modal')]    1s
    END