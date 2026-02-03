*** Settings ***
Library    SeleniumLibrary
Library    Collections

*** Variables ***
${URL}        https://docs.google.com/spreadsheets/d/1NZTPJDai0Qs_oU9KHIFEt8SHC0fpZWKJLjJ4pwLUTkg/edit?gid=1783020223
${START_ROW}  2
${END_ROW}    10

*** Test Cases ***
Ambil BA2 Sampai BA10 Dan Download
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Sleep    8s

    # WAJIB: scroll ke kanan supaya kolom BA dirender
    Execute Javascript
    ...    document.querySelector("div[role='grid']").scrollLeft = 10000;
    Sleep    2s

    ${end_plus}=    Evaluate    ${END_ROW} + 1

    FOR    ${row}    IN RANGE    ${START_ROW}    ${end_plus}
        ${link}=    Execute Javascript
        ...    const cells = [...document.querySelectorAll("div[role='gridcell']")];
        ...    const cell = cells.find(c => c.getAttribute("aria-label")?.startsWith("BA${row} "));
        ...    return cell
        ...        ? cell.getAttribute("aria-label").replace(/^BA${row}\\s*/, "")
        ...        : null;

        Log To Console    BA${row}: ${link}

        Run Keyword If    '${link}' == 'None'    Continue For Loop

        ${file_id}=    Replace String    ${link}
        ...    https://drive.google.com/open?id=    ${EMPTY}

        ${download_url}=    Set Variable
        ...    https://drive.google.com/uc?export=download&id=${file_id}

        Go To    ${download_url}
        Sleep    6s
    END

    Close Browser
