*** Settings ***
Documentation   Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Dialogs
Library    RPA.Robocorp.Vault

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order/    
Get Orders
    [Arguments]    ${url}
    ${secret}=    Get Secret    secrets
    Download    ${secret}[url]    overwrite=True
    ${table}=    Read table from csv    orders.csv    header=True
    [Return]    ${table}
Close the annoying modal
    Click Element If Visible    //button[@class="btn btn-dark"]
Fill the form
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:.form-control    ${order}[Legs]
    Input Text    id:address    ${order}[Address]
Preview the robot
    Click Button    Preview
Submit the order
    Wait Until Keyword Succeeds    3x    0.2s    Send order
send order
    Click Button    Order
    Wait Until Page Contains Element    id:receipt
Store the receipt as a PDF file
    [Arguments]    ${order number}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}receipts${/}${order number}.pdf
Take a screenshot of the robot
    [Arguments]    ${order number}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}images${/}${order number}.png       
Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${number}
    Add Watermark Image To Pdf    image_path=${CURDIR}/output/images/${number}.png    source_path=${CURDIR}/output/receipts/${number}.pdf    output_path=${CURDIR}/output/receipts/${number}.pdf
Go to order another robot
    Click Button    Order another robot
Create a ZIP file of the receipts
    Archive Folder With Zip    ${CURDIR}${/}output${/}receipts    receipts.zip


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Add text input    url    placeholder=Enter orders url
    ${result}=    Run dialog 
    ${orders}=    Get orders    ${result.url}
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Preview the robot
        Submit the order
        Store the receipt as a PDF file    ${order}[Order number]
        Take a screenshot of the robot    ${order}[Order number]  
        Embed the robot screenshot to the receipt PDF file    ${order}[Order number]
        Go to order another robot
    END
    Create a ZIP file of the receipts
