*! version 1.0.1 Mehrab Ali 04mar2019


cap program drop meaning
program  meaning 

version 11
	

*  ----------------------------------------------------------------------------
*  1. Define syntax                                                            
*  ----------------------------------------------------------------------------
	
	#d ;
	syntax
	[anything],
	[PROnounce]
	;
	#d cr

local searchitem = regexr("`anything'", " ","+")

! powershell.exe -windowstyle hidden Set-ExecutionPolicy Unrestricted -Scope CurrentUser

tempname handle

file open `handle' using "C:\Windows\Temp\psfile.ps1", text write replace

file write `handle'  _newline  "$" `"IE= new-object -com "InternetExplorer.Application""'
file write `handle'  _newline  "$" `"IE.navigate2("https://www.google.com/search?q=`searchitem'+meaning&num=2")"'
file write `handle'  _newline  "" 
file write `handle'  _newline  "while (" "$" `"IE.busy) {"'
file write `handle'  _newline  " sleep -milliseconds 100" 
file write `handle'  _newline  " }" 
file write `handle'  _newline  ""
file write `handle'  _newline  "$" `"List = New-Object Collections.Generic.List[String]"'
file write `handle'  _newline  "$" "IE.visible=""$""false"
file write `handle'  _newline  "$" "IE.visible=""$""false"
file write `handle'  _newline  "     Select -First 1 |" 
file write `handle'  _newline  "          % { " "$" "_.submit() }"
file write `handle'  _newline  ""
file write `handle'  _newline  "while (" "$" `"IE.busy) {"'
file write `handle'  _newline  " sleep -milliseconds 100" 
file write `handle'  _newline  " }" 
file write `handle'  _newline  ""
file write `handle'  _newline  "foreach(" "$" "sw in " "$" `"IE.document.getElementById("search").getElementsByTagName("span")) {"'
file write `handle'  _newline  "$" "List += " "$" "sw.innerText;" 
file write `handle'  _newline  " }"
file write `handle'  _newline  "foreach(" "$" "sw in " "$" `"IE.document.getElementById("search").getElementsByTagName("iUh30")) {"'
file write `handle'  _newline  "$" "List2 += " "$" "sw.innerText;" 
file write `handle'  _newline  " }" 
file write `handle'  _newline  ""
file write `handle'  _newline  "$" "List2" " + $" `"List | out-file "C:\Windows\Temp\search-out.txt""'
file close `handle'



! powershell -windowstyle hidden "& ""C:\Windows\Temp\\psfile.ps1"""

! start notepad.exe  "C:\Windows\Temp\search-out.txt"


if ("`pronounce'" != "") {
tempname audio

file open `audio' using "C:\Windows\Temp\audio.ps1", text write replace
file write `audio'  _newline  "Add-Type -AssemblyName System.speech" 
file write `audio'  _newline  "$" `"speak = New-Object System.Speech.Synthesis.SpeechSynthesizer"'
file write `audio'  _newline  "$" `"speak.Speak("`searchitem'")"'
file close `audio'


! powershell -windowstyle hidden "& ""C:\Windows\Temp\\audio.ps1"""
}


end

