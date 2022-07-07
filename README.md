## riverSpider-PowerShell 

A native PowerShell implementation of Tak's riverSpider tool for Windows PCs

## Overview
This project is based off of Dr. Tak Auyeung's riverSpider tool. It is critical that you read the original README included with the Linux version of this project for full context. The below will only include instructions on setup and execution of the PowerShell version. 

Context and background information is at the end of this README. 

## Who wrote this?
I am a former student of Tak's for CISP 310 from Spring 2022. I wrote this program when I noticed classmates were struggling with using riverSpider on their Windows PCs and felt that I could use the Bash version of this script as an opportunity to learn more about PowerShell and help future students use this tool. I have learned...that I am not a big fan of PowerShell 🤷🏽‍♂️.

## Updates and Requests
If you have requested updates or find an error, please open an [issue](https://github.com/omque/riverSpider-PowerShell/issues) and I will attend to it as fast as I can. You may also reach me on [Discord](https://www.discordapp.com/users/481751812236640256).

## What is riverSpider?

*From the original project README:*

riverSpider was originally intended as a far more ambitious project to automate certain tasks using the web interface to certain college resources. 2nd factor authentication makes most of the objectives unattainable. 

Anyway, the project *degenerated* to something that is simple and only works for CISP310. This projects now implements the basic function to submit a program written in TTPASM (Tak's Toy Processor ASseMbly language) to an assembler implemented in Google Sheets, downloads the RAM file back, runs that in LogiSim, then submits the logged trace back to the Google Sheet to have the raw log file interpreted and analyzed to show human readable instruction executions.

## Prerequisites

You will need the following for this project to work:

* [`java` version 8](https://www.java.com/en/download/) or above.
* [`PowerShell 7.x`](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows) or above (Windows Stable Release only).
* A text editor. This is different from Microsoft Word or Notepad. A good text editor will give you more flexibility in your code. You may also choose to use VSCode or a similar IDE though configuring those are beyond the scope of this README.
	* Suggested editors include:
		* [Notepad++](https://notepad-plus-plus.org/) (Free)
		* [Sublime Text](https://www.sublimetext.com/) (Paid)
		* [VSCode](https://code.visualstudio.com/) (Free)
* Requisite files for riverSpider: `alu.circ`, `logisim310.jar`, `processorXXXX.circ`, `regbank.circ`
	* These files are subject to updates and are not included in this repository, but are necessary for the script to function. 
	* Make sure you have the latest versions of these files from Tak.
* [Windows Terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701) 
    * Not required, but strongly recommended. You can execute all of your command through this application. This will allow you to customize the look and feel of your terminal as well as run other terminal programs. 
    * To learn more about how to customize this program, please see [Windows Terminal Tips and Tricks](https://docs.microsoft.com/en-us/windows/terminal/tips-and-tricks). 
    * If you wish you can use the default PowerShell interface.

## Installation
1. Install the necessary prerequisite software following the default installation settings.
2. Download riverSpider - PowerShell and unzip to your preferred directory.
3. Download riverSpider (the Bash version) and copy the following files to your riverSpider-PowerShell directory:
    
    1. `alu.circ`
	2. `logisim310.jar`
	3. `processorXXXX.circ`
	4. `regbank.circ`

	You can remove the Bash version of riverSpider now.

4. It is important to have the processor and related files properly referenced before using this script. Load LogiSim using the GUI (double-click on logisim310.jar).
	
	1. File -> Open -> "processorXXXX.circ".
	2. A dialogue box stating that "alu.circ" must be loaded will show. Click "OK" and select "alu.circ".
	3. A dialogue box stating that "regbank.circ" must be loaded will show. Click "OK" and select "regbank.circ".
	4. File -> Save
	5. Close LogiSim.

5. Clone and Configure the Google Sheet Assembler

	1. Visit the [Assembler](https://docs.google.com/spreadsheets/d/1_BQSqA9nKkeN_hk3_hHnexPN9r6tSHrTB8UaAfUHop8/edit?usp=sharing).
	2. Use `File | Make a copy` to clone the entire Google Sheet to somewhere in your own Google Drive.
	3. Then customize the associated Google Web App as follows:
		1. Use `Extensions | Apps Script` to open the `TTPASMbr` Google Apps Script (GAS) project
		2. In the source code `Code.gs`, navigate to `genDigest()`
    	3. Change the literal string value of `mySecretString` to your own password (and remember it as your "assembler password")
      	4. Using your text editor, overwrite the content of `secretString.txt` with your password. There should be no quotes in this document.	
    	5. Use the drop-down next to `Debug` to select `genDigest`
    	6. Click `Debug`
    	7. In the `Execution log`, copy the entire array into the clipboard, this should start with the first `[` and end with the matching `]`
    	8. In the source code, navigate to the definition of `simpleAuth`
    	9. Select the array to initialize local constant `d`, select from `[` to `]`
    	10. Paste (control-V) the new array that you captured earlier
    	11. Use control-S to save the script
    	12. Click `Deploy`, select `New deployment`
    	13. Specify `Web app` under `Select type`
    	14. Use whatever for `Description`
    	15. Specify `me` in `execute as`
    	16. Specify `Anyone` in `Who has access`
    	17. Click the `Deploy` button
    	18. In the next screen, copy the `Web app URL` and use this to overwrite the content of the file `webapp.url`. Make sure to open the file using your text editor. Save and close the file.
    	19. Click `Done`

6. Customize the settings in the file `submit.ps1` using your text editor.

	1. The default settings assume that all the relevant files are located within the same folder as the script file.
	2. `secretPath` should be the path to the file that stores the password chosen when cloning the assembler Google Sheet.
	3. `logisimPath` should be the path to the file `logisim310.jar`.
	4. `webappUrlPath` should be the path to the file `webapp.url`
	5. `processorCircPath` should be the path to the file `processorXXXXX.circ`

7. After all this configuration, you can now test it. There is a test file `test.ttpasm` in the directory.

	1. Open PowerShell. Make sure you are using "PowerShell 7" from the Start Menu. It is recommended to install and configure "Windows Terminal" to ensure this as Windows allows multiple versions of PowerShell to coexist.
		1. You can check your PowerShell version by using the following command at the prompt `$PSVersionTable`.
	2. Navigate to your riverSpider-PowerShell directory.
		1. You can use `cd` to change directories the same as you would in Bash.
		2. For example, to change to the desktop you can write: `cd Desktop`
		3. PowerShell supports tab completion. You can write partial words and press `Tab` to auto complete filenames and directories.
	3. When in the directory type: `.\submit.ps1 test.ttpasm`
	4. The test code in `test.ttpasm` should be uploaded and the Analysis tab should be populated with diagnostic information.
	
## What is PowerShell?

Much like Unix has "Bash" (Bourne Again Shell) as a shell and scripting language, Microsoft has implemented a similar version for its Windows operating system known as PowerShell. Through specific commands, users are able to execute scripts which can automate several tasks. PowerShell is strongly supported by Microsoft and is used by programmers, system administrators, and network engineers.

By default Windows comes with PowerShell 5.x. This program requires **at least** PowerShell **7.2.5.**

PowerShell has been open sourced and has been written for multiple operating systems. riverSpider-PowerShell is only intended to work on Windows operating systems from a PowerShell 7.x terminal. Linux and macOS versions of PowerShell have not been tested, nor are likely to work due to missing components that were not ported over from Windows. 

If you are on Unix based operating system, please use the original version of riverSpider written in Bash.

## PowerShell vs. "Command Prompt"

PowerShell is NOT the "Windows Command Prompt (CMD)". These are two separate programs. CMD was the original shell program developed by Microsoft in 1987 and lacks many of the modern features offered by PowerShell. As of 2016, PowerShell replaced CMD as the default shell on Windows 10 and further.

Please make sure you are using a PowerShell terminal.

## Why a different version for Windows?

riverSpider was originally written in Bash, for Linux. While Unix based operating systems like Linux and macOS are able to run the program, Windows users must either make use of a virtualized version of Linux in order to access the same tool. This would either be through the Windows Subsystem for Linux (WSL) or a virtual machine. 

Despite this, the setup time is significant and the process is prone to error which I found was off putting to students who are unfamiliar with this tooling. Virtual machines also require significant resources which may not be available on certain hardware. 

riverSpider-PowerShell is a "Windows native" implementation of the original riverSpider. No virtualization, outside "DLL" files, or third party tooling (aside from Java and PowerShell) are required. This makes the process fast and efficient.
