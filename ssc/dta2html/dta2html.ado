*! Program to generate HTML code necessary to display a Stata dataset on the web
*! Author P. Wilner Jeanty
*! Date: February 17, 2013
program define dta2html
version 11
syntax [varlist(default=none)] [if] [in], SAVing(str) [css(str) TABTitle(str) PAGEtitle(str) Datalink(str) Todisp(str)]
marksample touse
tokenize "`saving'", parse(",")
args nameof_file secxx sav_opt
local nameof_file `nameof_file'.html
capture confirm new file `nameof_file'
if !_rc & "`sav_opt'" != "" &  "`sav_opt'" != "replace" {
		di as err "The suboption for {bf:saving()} must be {bf:replace}"                      
		exit 198
}
else if _rc & "`sav_opt'"=="" confirm new file `nameof_file'
else if _rc & "`sav_opt'"!="" &  "`sav_opt'" != "replace" {
		di as err "The suboption for {bf:saving()} must be {bf:replace}"
		exit 198
}
if "`imgsrc'"!="" & "`datalink'"=="" {
	di as err "Option {bf:imgsrc()} must be combined with :bf:datalink()}"
	exit 198
}
if "`todisp'"!="" {
	tokenize "`todisp'", parse(",")
	args todisnme secxx todisp_opt
	if !inlist("`todisp_opt'", "txt", "img") {
		di `"{err}The sub-option for {bf:todisp()} must be either "txt" or "img""'
		exit 198
	}
}	
if "`pagetitle'"=="" local pagetitle "Stata Dataset in your Browser" 
if "`tabtitle'"=="" local tabtitle "Stata Dataset"               
              
tempname myhandle               
local wrfile file write `myhandle'
local opfile file open `myhandle'

if "`if'"!="" local ifexp `if'
if "`in'"!="" local inexp `in'
local ifinexp `ifexp' `inexp'
preserve
if "`if'`in'"!="" qui keep `ifinexp'
capture drop `touse'
if "`varlist'"!="" local allvs `varlist' 
else unab allvs: _all

gen Obs=_n
local allvs Obs `allvs'
local nvs : word count `allvs'
local outfile `"`nameof_file'"' 
`opfile' using `"`outfile'"', w text `sav_opt'
set more off
`wrfile'  _n
`wrfile' "<html>" _n "<head>" _n
if `"`pagetitle'"' ~= "" {
		`wrfile' `"<title>`pagetitle'</title>"' _n
}
`wrfile' `"<meta http-equiv="Content-type" content="text/html; charset=windows-1252">"' _newline
`wrfile' `"<meta http-equiv="Content-Style-Type" content="text/css">"' _newline

if "`css'" == "" TableStyle, towr(`wrfile')  
else `wrfile' `"<link rel="stylesheet" href="`css'">"' _newline 

`wrfile' `"</head>"' _n
if "`css'"=="" `wrfile' `"<body onload="startup()" onunload="shutdown()" class="body">"' _n
else `wrfile' `"<body  lang="en-US" dir="LTR">"' _n // You might want to edit from here fit to your CSS need.
`wrfile' `"<script language="javascript" type="text/javascript">"' _n
`wrfile' `"<!--"' 
`wrfile' `"var _info = navigator.userAgent"' _n
`wrfile' `"var _ie = (_info.indexOf("MSIE") > 0"' _n
          `wrfile' `"&& _info.indexOf("Win") > 0"' _n
          `wrfile' `"&& _info.indexOf("Windows 3.1") < 0);"' _n
`wrfile' `"var _ie64 = _info.indexOf("x64") > 0"' _n

`wrfile' `"//-->"' _n
`wrfile' `"</script>"' _n

`wrfile' `"<div class="branch">"' _newline
`wrfile' `"<a name="IDX"></a>"' _newline
`wrfile' `"<table cellspacing="5" cellpadding="3" rules="none" frame="void" align="center" border="0" summary="Page Layout">"' _n
`wrfile' `"<tr>"' _n
if `"`datalink'"'!="" {
	`wrfile' `"<td colspan="3"width="300">&nbsp;&nbsp;&nbsp;</td>"'
	if "`todisp_opt'"=="img" {
		`wrfile' `"<td width="300" vertical-alignment=><a href="`datalink'"><img src="`todisnme'"  alt="" class="NoBorderImage" /></a></td>"' _n
	}	
	else {
		`wrfile' `"<td class="r tfotmat"><a href="`datalink'">`todisnme'</a></td>"' _n 
	}	
}
`wrfile' `"</tr>"' _n
`wrfile' `"<tr>"' _n
if "`tabtitle'"!="" `wrfile' `"<td class="c b tformat">`tabtitle'</td>"' 
`wrfile' `"</tr>"' _n
`wrfile' `"</table><br>"' _n

`wrfile' `"<div>"' _n
`wrfile' `"<div align="center">"'
`wrfile' `"<table class="table" cellspacing="1" cellpadding="5" rules="all" frame="box" bordercolor="#C1C1C1">"' _newline
`wrfile' `"<colgroup>"' _n
`wrfile' `"<col>"' _n
`wrfile' `"</colgroup>"' _n
`wrfile' `"<colgroup>"' _n
local nnvs=`nvs'-1
forv i=1/`nnvs' {
	`wrfile' `"<col>"' _n
}
`wrfile' `"</colgroup>"' _n

// Writing the variable names
`wrfile' `"<thead>"' _n
`wrfile' `"<tr>"' _n
foreach v of local allvs {
	`wrfile' `"<th class="c header" scope="col">`v'</th>"' _n
}
`wrfile' `"</tr>"' _n
`wrfile' `"</thead>"' _n	

// Writing the values of the variables
`wrfile' `"<tbody>"' _n
local N=_N
forv i=1/`N' {
	`wrfile' `"<tr>"' _n
	local j=1
	foreach v of local allvs {
		if `j'==1 {
			`wrfile' `"<th class="r header" scope="row">`=`v'[`i']'</th>"' _n
		}	
		else {
			cap confirm numeric var `v'
			if !_rc `wrfile' `"<td class="r dta">`=`v'[`i']'</td>"' _n
			else `wrfile' `"<td class="l dta">`=`v'[`i']'</td>"' _n
		}	
		local ++j
	}
	`wrfile' `"</tr>"' _n
}
		
`wrfile' `"</tbody>"' _n `"</table>"' _n `"</div>"'	_n `"</div>"' _n
`wrfile' `"<br>"' _n `"</div>"' _n `"</body>"' _n `"</html>"' _n

file close `myhandle'
set more off
restore
di _n `"Dataset written to HTML file {stata type `outfile':`c(pwd)'`c(dirsep)'`outfile'}"' 
di _n `"To open in Internet Explorer, {browse "file:///`c(pwd)'`c(dirsep)'`outfile'":Click here}"'

end

// Defining the table style
program define TableStyle
version 11
syntax, towr(str)
`towr' `"<style type="text/css">"' _n
`towr' `"<!--"' _n 
`towr' `".body"' _n
`towr' `"{"' _n
  `towr' `"background-color: #FAFBFE;"' _n
  `towr' `"color: #000000;"' _n
  `towr' `"font-family: Arial, 'Albany AMT', Helvetica, Helv;"' _n
  `towr' `"font-size: x-small;"' _n
  `towr' `"font-style: normal;"' _n
  `towr' `"font-weight: normal;"' _n
  `towr' `"margin-left: 8px;"' _n
  `towr' `"margin-right: 8px;"' _n
`towr' `"}"' _n
`towr' `"img.NoBorderImage"' _n
`towr' `"{"' _n
`towr' `"border-style: none;"' _n
`towr' `"border-width: 2px;"' _n
`towr' `"}"' _n
`towr' `".table"' _n
`towr' `"{"' _n
  `towr' `"border-bottom-width: 0px;"' _n
  `towr' `"border-collapse: separate;"' _n
  `towr' `"border-color: #C1C1C1;"' _n
  `towr' `"border-left-width: 1px;"' _n
  `towr' `"border-right-width: 0px;"' _n
  `towr' `"border-spacing: 0px;"' _n
  `towr' `"border-style: solid;"' _n
  `towr' `"border-top-width: 1px;"' _n
`towr' `"}"' _n
`towr' `".tformat"' _n
`towr' `"{"' _n
  `towr' `"color: #112277;"' _n
  `towr' `"font-family: Arial, 'Albany AMT', Helvetica, Helv;"' _n
  `towr' `"font-size: small;"' _n
  `towr' `"font-style: normal;"' _n
  `towr' `"font-weight: bold;"' _n
`towr' `"}"' _n
`towr' `".header"' _n
`towr' `"{"' _n
  `towr' `"background-color: #e6e6e6;"' _n
  `towr' `"border-bottom-width: 1px;"' _n
  `towr' `"border-color: #B0B7BB;"' _n
  `towr' `"border-left-width: 0px;"' _n
  `towr' `"border-right-width: 1px;"' _n
  `towr' `"border-style: solid;"' _n
  `towr' `"border-top-width: 0px;"' _n
  `towr' `"color: #112277;"' _n
  `towr' `"font-family: Arial, 'Albany AMT', Helvetica, Helv;"' _n
  `towr' `"font-size: x-small;"' _n
  `towr' `"font-style: normal;"' _n
  `towr' `"font-weight: bold;"' _n
`towr' `"}"' _n
`towr' `".dta"' _n
`towr' `"{"' _n
  `towr' `"background-color: #FFFFFF;"' _n
  `towr' `"border-bottom-width: 1px;"' _n
  `towr' `"border-color: #C1C1C1;"' _n
  `towr' `"border-left-width: 0px;"' _n
  `towr' `"border-right-width: 1px;"' _n
  `towr' `"border-style: solid;"' _n
  `towr' `"border-top-width: 0px;"' _n
  `towr' `"font-family: Arial, 'Albany AMT', Helvetica, Helv;"' _n
  `towr' `"font-size: x-small;"' _n
  `towr' `"font-style: normal;"' _n
  `towr' `"font-weight: normal;"' _n
`towr' `"}"'
`towr' `".l {text-align: left }"' _n
`towr' `".c {text-align: center }"' _n
`towr' `".r {text-align: right }"' _n
`towr' `".d {text-align: right }"' _n
`towr' `".j {text-align: justify }"' _n
`towr' `".t {vertical-align: top }"' _n
`towr' `".m {vertical-align: middle }"' _n
`towr' `".b {vertical-align: bottom }"' _n
`towr' `"TD, TH {vertical-align: top }"' _n
`towr' `"-->"' _n
`towr' `"</style>"' _n
end
