#################################################################################################
# riverSpider Tool - PowerShell Version
# PowerShell Script by: Omair Qazi (Spring 2022)
# Based on riverSpider by Dr. Tak Auyeung
# For instructions, updates, or questions related to the PowerShell script please see:
# https://github.com/omque/riverSpider-PowerShell 
#
# Last Updated: 2022-07-06
#################################################################################################

#################################################################################################
# You are likely to have change these settings.
#
# This contains the string that was used to generate the
# hash value of the web script that "authenticates" the 
# web client.
$secretPath='.\secretString.txt'

# this is where the web app URL is located.
$webappUrlPath='.\webapp.url'

# this is where you put the logisim310.jar file.
$logisimPath='.\logisim310.jar'

# this is where you put the processorXXXX.circ file (along with
# alu.circ and regbank.circ).
$processorCircPath='.\processorXXXX.circ'

#################################################################################################
#Modifying file extensions for output based upon TTPASM filename.

#original file, should have an extension of .ttpasm.
$fn=$args[0]

#the object code file, csv format.
$fnCsv = [System.IO.Path]::ChangeExtension($fn, ".csv")

# the trace raw data file, tsv format.
$fnTsv = [System.IO.Path]::ChangeExtension($fn, ".tsv")

#################################################################################################
# check to make sure all the other files exist.

# check the secret string path.
if (-not (Test-Path -Path $secretPath))
{
    Write-Host "'secretPath' must be defined in order to authenticate to the web script."
    exit 1
}

# check that the webappUrl file exists.
if (-not (Test-Path -Path $webappUrlPath))
{
    Write-Host "'webappUrlPath' must be defined in order to specify the URL of the web app."
    exit 1
}

# check that java exists.
$javaCheck = (Get-Command java | Select-Object -ExpandProperty Version).toString()
if (-not ($javaCheck))
{
    Write-Host "Java must be installed in order to run the simulator."
    exit 1
}

# check that Logisim exists.
if (-not (Test-Path -Path $logisimPath))
{
    Write-Host "'LogiSim' (jar version) must be defined in order to run the processor."
    exit 1
}

# check that the processor file exists.
if (-not (Test-Path -Path $processorCircPath))
{
    Write-Host "A processor circuit file is needed for simulation."     
    exit 1
}

# check that test code file exists.
if (-not (Test-Path -Path $fn))
{
    Write-Host "$fn does not exist, cannot proceed any further."
    exit 1
    
}

#################################################################################################
# all prerequisite checked, now actually do it!

#Data file variable for submission to Assembler page.
$DATA = '.\data.txt'

#Clear data, CSV, and TSV files. If no existing file is found will silently continue without error message.
Clear-Content $DATA -ErrorAction SilentlyContinue
Remove-Item $fnCsv -ErrorAction SilentlyContinue
Remove-Item $fnTsv -ErrorAction SilentlyContinue

#Silence Invoke-WebRequest Progress in current PowerShell session
$progressPreference = 'silentlyContinue'

Write-Host "Submitting $fn to assembler..."

#Build data.txt file for TTPASM code submission to assembler.
"ttpasm=" | Add-Content $DATA -NoNewline

#Get file path, encode for upload, and write to data file.
#Note: UrlEncode is used however URLPathEncode can be substituted for maximum compatibility with BASH script equivalent.
[System.Web.HttpUtility]::UrlEncode($(Get-Content -Path $fn -Raw)) | Add-Content $DATA -NoNewline

#Add Assembler authentication to data file. 
"&auth=" | Add-Content $DATA -NoNewline

#Remove any newline characters from secretPath and then URL Encoding for data file.
$authCode = [System.Web.HttpUtility]::UrlEncode(($(Get-Content -Path $secretPath -Raw) -Replace '\n', '')) 

#$authCode variable created for reuse later in script.
$authCode | Add-Content $DATA -NoNewline

#Submit TTPASM code to assembler, export RAM file to CSV.
Invoke-RestMethod -URI (Get-Content $webappUrlPath) -Method 'POST' -Body (Get-Content $DATA) -OutFile $fnCsv

#Check if Invoke-RestMethod succeeded. Failure will usually produce a "not authenticated" result from Assembler.
if( (Get-Content $fnCsv) -like "not authenticated")
{
    Write-Host "Something went wrong, the connection to the assembler (Invoke-RestMethod) failed."  
    exit 1
}

Write-Host "Assembler finished, validating object code..."

#Check to see that RAM code returned properly.
if (-not (Select-String $fnCsv -Pattern "error"))
{
    Write-Host "Object code is good, starting simulator."
    
    #Run Logisim.
    java -jar $logisimPath $processorCircPath -tty table -load $fnCsv > $fnTsv

    #Convert exported TSV file from Windows CRLF to Unix LF Format Assembler to parse correctly.
    ((Get-Content $fnTsv) -join "`n") + "`n" | Set-Content -NoNewline $fnTsv

    #Clear data.txt.
    Clear-Content $DATA

    #Replace new lines.
    $STAGE1 = ((Get-Content -Path $fnTsv -Raw) -Replace "`0"," ")

    #Build data.txt file for trace code submission to assembler.
    "trace=" | Add-Content $DATA -NoNewline

    #Encode TSV for upload.
    [System.Web.HttpUtility]::UrlEncode($STAGE1) | Add-Content $DATA -NoNewline

    #Add authentication for submission to assembler.
    "&auth=" | Add-Content $DATA -NoNewline
    $authCode | Add-Content $DATA -NoNewline

    Write-Host "Simulation finished, submitting trace data..."

    #Create logfile
    $LOGFILE = [System.IO.Path]::ChangeExtension($fn, ".log")
    
    #Post data to Assembler trace sheet.
    Invoke-RestMethod -URI (Get-Content $webappUrlPath) -Method 'POST' -Body (Get-Content $DATA) -OutFile $LOGFILE
    
    Write-Host "Trace data uploaded, check the analysis sheet"
    
    #Restore Invoke-WebRequest Progress in current PowerShell session
    $progressPreference = 'Continue'
}
else 
{
    Write-Host "The source file did not assemble correctly."
    Write-Host "Better fix the source code first."
    
    #Restore Invoke-WebRequest Progress in current PowerShell session
    $progressPreference = 'Continue'
    
    exit 1
}

exit 0
