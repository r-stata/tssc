*! version 1.3  08jan2016
*! version 1.2  26oct2015
*! version 1.1  24jun2015
*! version 1.0  18nov2014

*-------------------------------------------------------------------------------
*
*  Copyright (C) 2016  Joss Roßmann & Tobias Gummer
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details <http://www.gnu.org/licenses/>.          
*
*  Recommended citation (APA Style, 6th ed.): 
*  Roßmann, J., & Gummer, T. (2016): PARSEUAS: Stata module to extract detailed 
*  information from user agent strings (Version: 1.3) [Computer Software]. 
*  Chestnut Hill, MA: Boston College.
*
*-------------------------------------------------------------------------------

program parseuas
version 12.1
syntax varname(string) [if] [in], [BROwser(string)] [BROWSERVersion(string)] ///
[OS(string)] [DEVice(string)] [SMARTphone(string)] [TABlet(string)] ///
[NUMeric] [Noisily]

*--- Check input ---*
if "`device'"=="" & "`smartphone'"=="" & "`tablet'"=="" & "`browser'"=="" ///
& "`browserversion'"=="" &"`os'"=="" & "`numeric'"=="" & "`noisily'"=="" {
	dis as error "too few options specified"
	exit
}

if "`device'"=="" & "`smartphone'"=="" & "`tablet'"=="" & "`browser'"=="" ///
& "`browserversion'"=="" &"`os'"=="" & "`numeric'"!="" {
	dis as error "option numeric requires specification of browser, browserversion, os, device, smartphone, or tablet"
	exit
}

*--- Sample to use ---*
marksample touse, novarlist

*--- Temporary variables ---*
tempvar tempdevice tempsmartphone temptablet tempmobile tempbrowser tempbrowserversion tempos 

quietly {
*--- Browser version ---*
	gen str `tempbrowserversion'=""
	lab var `tempbrowserversion' "Browser version"
	*Firefox
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Firefox") & `touse'
	replace `tempbrowserversion' = "Firefox "+regexs(1) if regexm(`varlist', "Firefox/"+"([0-9\.]+)") & `touse'
	*Internet Explorer
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "MSIE") & `touse'
	replace `tempbrowserversion' = "Internet Explorer "+regexs(1) if regexm(`varlist', "MSIE "+"([0-9\.]+)") & `touse'
	replace `tempbrowserversion' = "Internet Explorer 8.0" if regexm(`varlist', "MSIE.*Trident/4.0") & `touse'
	replace `tempbrowserversion' = "Internet Explorer 9.0" if regexm(`varlist', "MSIE.*Trident/5.0") & `touse'
	replace `tempbrowserversion' = "Internet Explorer 10.0" if regexm(`varlist', "MSIE.*Trident/6.0") & `touse'
	replace `tempbrowserversion' = "Internet Explorer 11.0" if regexm(`varlist', "Trident/7.0.*rv:11.0") & `touse'
	*Safari
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Safari") & `touse'
	replace `tempbrowserversion' = "Safari "+regexs(1) if regexm(`varlist', "Version/"+"([0-9\.]+).*Safari") & `touse'
	*Chrome
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Chrome") & `touse'
	replace `tempbrowserversion' = "Chrome "+regexs(1) if regexm(`varlist', "Chrome/"+"([0-9\.]+)") & `touse'
	replace `tempbrowserversion' = "Chrome "+regexs(1) if regexm(`varlist', "CriOS/"+"([0-9\.]+)") & `touse'
	*Opera
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Opera") & `touse'
	replace `tempbrowserversion' = "Opera "+regexs(1) if regexm(`varlist', "Opera/"+"([0-9\.]+)") & `touse'
	replace `tempbrowserversion' = "Opera "+regexs(1) if regexm(`varlist', "Opera/.*Version/"+"([0-9\.]+)") & `touse'
	*Android Webkit
	replace `tempbrowserversion' = "Android Webkit (other)" if regexm(`varlist', "Android.*Version*Safari") & `touse'
	replace `tempbrowserversion' = "Android Webkit "+regexs(1) if regexm(`varlist', "Android.*Version/"+"([0-9\.]+).*Safari") & `touse'
	*Edge
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Edge") & `touse'
	replace `tempbrowserversion' = "Edge "+regexs(1) if regexm(`varlist', "Edge/"+"([0-9\.]+)") & `touse'
	*SeaMonkey
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "SeaMonkey") & `touse'
	replace `tempbrowserversion' = "SeaMonkey "+regexs(1) if regexm(`varlist', "SeaMonkey/"+"([0-9\.]+)") & `touse'
	*Silk
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Silk") & `touse'
	replace `tempbrowserversion' = "Silk "+regexs(1) if regexm(`varlist', "Silk/"+"([0-9\.]+)") & `touse'
	*K-Meleon
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "K-Meleon") & `touse'
	replace `tempbrowserversion' = "K-Meleon "+regexs(1) if regexm(`varlist', "K-Meleon/"+"([0-9\.]+)") & `touse'
	*Iceweasel
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Iceweasel") & `touse'
	replace `tempbrowserversion' = "Iceweasel "+regexs(1) if regexm(`varlist', "Iceweasel/"+"([0-9\.]+)") & `touse'
	*Netscape
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Netscape") & `touse'
	replace `tempbrowserversion' = "Netscape "+regexs(1) if regexm(`varlist', "Netscape/"+"([0-9\.]+)") & `touse'
	*Iron
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Iron") & `touse'
	replace `tempbrowserversion' = "Iron "+regexs(1) if regexm(`varlist', "Iron/"+"([0-9\.]+)") & `touse'
	*Iron
	replace `tempbrowserversion' = regexs(0)+" (other)" if regexm(`varlist', "Maxthon") & `touse'
	replace `tempbrowserversion' = "Maxthon "+regexs(1) if regexm(`varlist', "Maxthon/"+"([0-9\.]+)") & `touse'
	*Browser (other)
	replace `tempbrowserversion' = "Browser (other)" if `tempbrowserversion'=="" & `varlist'!="" & `touse'

*--- Browser ---*
	gen str `tempbrowser'="" 
	lab var `tempbrowser' "Browser name"
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Firefox") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Internet Explorer") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Edge") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Safari") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Chrome") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Opera") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Android Webkit") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "SeaMonkey") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Silk") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "K-Meleon") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Iceweasel") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Netscape") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Iron") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Maxthon") & `touse'
	replace `tempbrowser' = regexs(0) if regexm(`tempbrowserversion', "Browser \(other\)") & `touse'
		
*--- Operating system ---*
	gen str `tempos'=""
	lab var `tempos' "Operating system version"
	*Windows
	replace `tempos' = regexs(0)+" (other)" if regexm(`varlist', "Windows") & `touse'
	replace `tempos' = "Windows "+regexs(1) if regexm(`varlist', "Windows NT "+"([0-9\.]+)") & `touse'
	replace `tempos' = "Windows CE" if regexm(`varlist', "Windows CE") & `touse'
	replace `tempos' = "Windows "+regexs(1) if regexm(`varlist', "Windows "+"([0-9][0-9])") & `touse'
	replace `tempos' = "Windows 98" if regexm(`varlist', "Win98") & `touse'
	replace `tempos' = "Windows 98" if regexm(`varlist', "Windows NT 4.10") & `touse'
	replace `tempos' = "Windows ME" if regexm(`varlist', "Win 9x 4.90") & `touse'
	replace `tempos' = "Windows ME" if regexm(`varlist', "Windows ME") & `touse'
	replace `tempos' = "Windows NT 4.0" if regexm(`varlist', "Windows NT 4.0") & `touse'
	replace `tempos' = "Windows NT 4.0" if regexm(`varlist', "WinNT4") & `touse'
	replace `tempos' = "Windows 2000" if regexm(`varlist', "Windows NT 5.0") & `touse'
	replace `tempos' = "Windows XP" if regexm(`varlist', "Windows NT 5.[1-2]") & `touse'
	replace `tempos' = "Windows Vista" if regexm(`varlist', "Windows NT 6.0") & `touse'
	replace `tempos' = "Windows 7" if regexm(`varlist', "Windows NT 6.1") & `touse'
	replace `tempos' = "Windows 8.0" if regexm(`varlist', "Windows NT 6.2") & `touse'
	replace `tempos' = "Windows 8.1" if regexm(`varlist', "Windows NT 6.3") & `touse'
	*Mac OS X
	replace `tempos' = regexs(0)+" (other)" if regexm(`varlist', "Mac OS X") & `touse'
	replace `tempos' = "Mac OS X "+regexs(1) if regexm(`varlist', "Mac OS X "+"([0-9\._]+)") & `touse'
	*Linux
	replace `tempos' = regexs(0)+" (other)" if regexm(`varlist', "Linux") & `touse'
	replace `tempos' = "Linux "+regexs(0)+" (other)" if regexm(`varlist', "Ubuntu") & `touse'
	replace `tempos' = "Linux Ubuntu "+regexs(1) if regexm(`varlist', "Ubuntu/"+"([0-9\.]+)") & `touse'
	replace `tempos' = "Linux "+regexs(0)+" (other)" if regexm(`varlist', "SUSE") & `touse'
	replace `tempos' = "Linux SUSE "+regexs(1) if regexm(`varlist', "SUSE/"+"([0-9\.-]+)") & `touse'
	*Android
	replace `tempos' = regexs(0)+" (other)" if regexm(`varlist', "Android") & `touse'
	replace `tempos' = "Android "+regexs(1) if regexm(`varlist', "Android "+"([0-9\.]+)") & `touse'
	*iOS
	replace `tempos' = "iOS "+regexs(1) if regexm(`varlist', "iPod.*OS "+"([0-9\._]+)") & `touse'
	replace `tempos' = "iOS "+regexs(1) if regexm(`varlist', "iPhone.*OS "+"([0-9\._]+)") & `touse'
	replace `tempos' = "iOS "+regexs(1) if regexm(`varlist', "iPad.*OS "+"([0-9\._]+)") & `touse'
	*Windows Phone
	replace `tempos' = "Windows Phone "+regexs(1) if regexm(`varlist', "Windows Phone "+"([0-9\.]+)") & `touse'
	replace `tempos' = "Windows Phone "+regexs(1) if regexm(`varlist', "Windows Phone OS "+"([0-9\.]+)") & `touse'
	*BlackBerry
	replace `tempos' = regexs(0)+" (other)" if regexm(`varlist', "BlackBerry") & `touse'
	replace `tempos' = "BlackBerry OS "+regexs(1) if regexm(`varlist', "BlackBerry.*Version/"+"([0-9\.]+)") & `touse'
	replace `tempos' = "BlackBerry OS "+regexs(1) if regexm(`varlist', "BB10.*Version/"+"([0-9\.]+)") & `touse'
	*Symbian
	replace `tempos' = "Symbian (other)" if regexm(`varlist', "Symb.*OS") & `touse'
	*OS (other)
	replace `tempos' = "OS (other)" if `tempos'=="" & `varlist'!="" & `touse'
	
	*--- Device type ---*
	gen str `tempdevice'=""
	lab var `tempdevice' "Device type"
	*Tablet (other)
	replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "Tablet") & `touse'
	replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "Kindle") & `touse'
	replace `tempdevice' = "Tablet (other)" if regexm(`varlist', "PlayBook") & `touse'
	*Tablet (Windows)
	replace `tempdevice' = "Tablet (Windows)" if regexm(`varlist', "Windows.*Tablet") & `touse'
	*Tablet (Android)
	replace `tempdevice' = "Tablet (Android)" if regexm(`varlist', "Android") & `touse'
	replace `tempdevice' = "Tablet (Android)" if regexm(`varlist', "GT-P1000") & `touse'
	*Tablet (iPad)
	replace `tempdevice' = "Tablet (iPad)" if regexm(`varlist', "iPad") & `touse'
	*Mobile phone (other)
	replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "Mobile ") & `touse'
	replace `tempdevice' = "Mobile phone (other)" if regexm(`tempos', "BlackBerry") & `touse'
	replace `tempdevice' = "Mobile phone (other)" if regexm(`tempos', "Symbian") & `touse'
	replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "GT-S8600") & `touse'
	replace `tempdevice' = "Mobile phone (other)" if regexm(`varlist', "SAMSUNG-S8000") & `touse'
	*Mobile phone (Android) 
	replace `tempdevice' = "Mobile phone (Android)" if regexm(`varlist', "Android.*Mobi") & `touse'
	*Mobile phone (iPhone)
	replace `tempdevice' = "Mobile phone (iPhone)" if regexm(`varlist', "iPhone") & `touse'
	*Mobile phone (Windows)
	replace `tempdevice' = "Mobile phone (Windows)" if regexm(`varlist', "Windows Phone") & `touse'
	replace `tempdevice' = "Mobile phone (Windows)" if regexm(`varlist', "HTC_HD2_T8585") & `touse'
	*Device: other
	replace `tempdevice' = "Device (other)" if `tempdevice'=="" & `varlist'!="" & `touse'
			
*--- Smartphone ---*
	gen str `tempsmartphone'=""
	lab var `tempsmartphone' "Smartphone"
	replace `tempsmartphone'="Smartphone" if regexm(`tempdevice', "Mobile phone") & `touse'
	replace `tempsmartphone'="Other device" if `tempsmartphone'=="" & `varlist'!="" & `touse'
		
*--- Tablet ---*
	gen str `temptablet'=""
	lab var `temptablet' "Tablet"
	replace `temptablet'="Tablet" if regexm(`tempdevice', "Tablet") & `touse'
	replace `temptablet'="Other device" if `temptablet'=="" & `varlist'!="" & `touse'
}
	
*--- Generate variables (optional) ---*
	if "`browser'"!="" {
		if "`numeric'"=="" {
			quietly gen `browser'=`tempbrowser'
			lab var `browser' "Browser name"
		}
		else if "`numeric'"!="" {
			quietly encode `tempbrowser', gen(`browser')
			lab var `browser' "Browser name"
		}
	}

	if "`browserversion'"!="" {
		if "`numeric'"=="" {
			quietly gen `browserversion'=`tempbrowserversion'
			lab var `browserversion' "Browser version"
		}
		else if "`numeric'"!="" {
			quietly encode `tempbrowserversion', gen(`browserversion')
			lab var `browserversion' "Browser version"
		}
	}
	
	if "`os'"!="" {
		if "`numeric'"=="" {
			quietly gen `os'=`tempos'
			lab var `os' "Operating system"
		}
		else if "`numeric'"!="" {
			quietly encode `tempos', gen(`os')
			lab var `os' "Operating system"
		}
	}
	
	if "`device'"!="" {
		if "`numeric'"=="" {
			quietly gen `device'=`tempdevice'
			lab var `device' "Device type"
		}
		else if "`numeric'"!="" {
			quietly encode `tempdevice', gen(`device')
			lab var `device' "Device type"
		}
	}

	if "`smartphone'"!="" {
		if "`numeric'"=="" {
			quietly gen `smartphone'=`tempsmartphone'
			lab var `smartphone' "Smartphone"
		}
		else if "`numeric'"!="" {
			quietly encode `tempsmartphone', gen(`smartphone')
			lab var `smartphone' "Smartphone"
		}
	}
	
	if "`tablet'"!="" {
		if "`numeric'"=="" {
			quietly gen `tablet'=`temptablet'
			lab var `tablet' "Tablet"
		}
		else if "`numeric'"!="" {
			quietly encode `temptablet', gen(`tablet')
			lab var `tablet' "Tablet"
		}
	}
	
*--- Output ---*
	if "`noisily'"!="" {
		tab `tempbrowser'
		tab `tempbrowserversion'
		tab `tempos'
		tab `tempdevice'
	}
end
exit
