*! version 1.0.0 MLB 25Sep2018
program define htmlcb
	version 9.2
	syntax , saving(string) [replace] *
	
	tempname book
	file open `book' using `saving', write `replace'
	
	preserve
	local olddir : pwd
	
	capture noisily : htmlcb_main `0' book(`book')
	
	local rc = _rc
	capture file close `book'
	restore
	qui cd `"`olddir'"'
	exit `rc'
end

program define htmlcb_main
	syntax , saving(string) book(string) ///
	        [replace title(passthru) Files(passthru) DIR(passthru) ///
			fast SELFcontained]
	
	parsefiles, `files' `dir'
	local fn `"`r(fn)'"'
	local ffn `"`r(ffn)'"'
	local k : word count `fn'
	
	preamble, book(`book') `selfcontained'
	
	sidebar, book(`book') fn(`fn')
	title, book(`book') `title' fn(`fn')
	
	local fnr = 0
	foreach file of local ffn {
		local fnr = `fnr' + 1
		if `"`files'`dir'"' != "" {
			qui use "`file'", clear
		}
		filedesc, book(`book') fnr(`fnr') fn(`: word `fnr' of `fn'') k(`k')
		varsdesc, book(`book') fnr(`fnr') `fast' k(`k')
	}
	closing, book(`book')

	di as txt "{p}Output written to " `"{browse "`saving'"}{p_end}"'		
end

program define parsefiles, rclass
	syntax , [files(string) dir(string)]
	
	if `"`files'"' != "" & `"`dir'"' != "" {
		di as err "{p}options files() and dir() are mutually exclusive{p_end}"
		exit 198
	}
	if `"`files'`dir'"' == "" {
		local ffn `""`c(filename)'""'
		if `"`ffn'"' == "" {
			di as err "{p}No dataset open, open a dataset or specify either the files() or dir() option{p_end}"
			exit 198
		}
		_getfilename `"`c(filename)'"'
		local fn = "`r(filename)'"
	}
	if `"`dir'"' != "" {
		qui cd `"`dir'"'
		local files : dir "." files "*.dta" 
		if `"`files'"' == "" {
			di as err "{p}directory `dir' contains no .dta files{p_end}"
			exit 198
		}
	}
	if `"`files'"' != "" {
		local k : word count `files'
		tokenize `"`files'"'
		forvalues i = 1/`k' {
			qui use ``i'', clear
			local ffn `"`ffn' "`c(filename)'""'
			_getfilename `"`c(filename)'"'
			local fn `fn' `r(filename)'
		}
	}
	return local fn `"`fn'"'
	return local ffn `"`ffn'"'
	
end

program define preamble
	syntax, book(string) [selfcontained]
	file write `book' `"<!DOCTYPE html>"'_n
	file write `book' `"<html>"'_n
	file write `book' `"<title>Codebook</title>"'_n
	file write `book' `"<meta name="viewport" content="width=device-width, initial-scale=1">"'_n
	if "`selfcontained'" == "" {
		file write `book' `"<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3.css">"'_n
	}
	file write `book' `"<style>"'_n
	if "`selfcontained'"  != "" {
		w3css, book(`book')
	}
	file write `book' `".line-wrap {"'_n
	file write `book' `"    white-space: normal;"'_n
	file write `book' `"    word-wrap: break-word;"'_n
	file write `book' `"}"'_n
	file write `book' `"body {"'_n
 	file write `book' `"    max-width:1200px;"'_n
	file write `book' `"    margin:auto;"'_n
	file write `book' `"}"'_n
	file write `book' `"</style>"'_n
	file write `book' `"<body class="w3-white">"'_n
end

program define sidebar
	syntax , book(string) fn(string)
	
	local k : word count `fn'
	if `k' > 1 {
		file write `book' `"<div class="w3-sidebar w3-bar-block w3-white w3-collapse" style="width:200px" id="mySidebar">"'_n
		file write `book' `"<div class="w3-container w3-hide-large"><br><br><br></div>"'_n
		file write `book' `"<button class="w3-bar-item w3-button w3-large w3-hide-large" onclick="w3_close()">Close &times;</button>"'_n
		file write `book' `"<div class="w3-container w3-green">"' _n
		file write `book' `"<strong>files</strong>"'_n
		file write `book' `"</div>"' _n
		forvalues i = 1/`k' {
			file write `book' `"<a href="#file`i'" class="w3-bar-item w3-button w3-white w3-leftbar w3-border-green w3-border w3-hover-green line-wrap" >`:word `i' of `fn''</a>"'_n
		}
		file write `book' "</div>"_n
	}
end

program define title
	syntax, book(string) [title(string) fn(string) dir(string)]
	local k : word count `fn'
	if `k' > 1 {
		file write `book' `"<div class="w3-main" style="margin-left:200px">"'_n	
		file write `book' `"<div class="w3-top" style="max-width:1000px">"'_n
	}
	else {
		file write `book' `"<div class="w3-main">"'_n	
		file write `book' `"<div class="w3-top" style="max-width:1200px">"'_n
	}
	
	file write `book' `"<div class="w3-container w3-green">"'_n
	if `k' > 1 {
		file write `book' `"<button class="w3-button w3-green w3-hover-light-green w3-xlarge w3-hide-large w3-right" onclick="w3_open()">&#9776;</button>"'
	}
	if `"`title'"' != "" {
		file write `book' `"<h1>`title'</h1>"'_n
	}
	else {
		file write `book' "<h1>Codebook</h1>"_n
	}
	file write `book' `"</div>"'_n	
	file write `book' `"</div><br><br><br>"'_n
end

program define filedesc 
	syntax, book(string) fn(string) fnr(integer) k(integer)

	file write `book' `"<div id="file`fnr'" class="w3-container w3-light-grey w3-border-right w3-border-left w3-border-green line-wrap">"'_n
	file write `book' `"<h3><strong>`fn'</strong>"'
	if `"`: data label'"' != "" {
		file write `book' `": `:data label'"' 
	}
	file write `book' "</h3>"_n
	file write `book' `"</div>"'_n
	
	if `k' > 1 {
		file write `book' `"<div class="w3-bar w3-light-grey w3-border-right w3-border-left w3-border-bottom w3-border-green ">"'_n
		file write `book' `"<button onclick="acc("' _char(39)`"desc`fnr'"' _char(39) `")" class="line-wrap w3-bar-item w3-padding-small w3-button w3-block w3-left-align w3-white w3-leftbar w3-border-top w3-border-green w3-hover-green">"'_n	
		file write `book' `"<strong>Descriptives</strong>"'_n
		file write `book' `"</button>"'_n	
		
		file write `book' `"<button onclick="acc("' _char(39)`"vars`fnr'"' _char(39) `")" class="line-wrap w3-bar-item w3-padding-small w3-button w3-block w3-left-align w3-white w3-leftbar w3-border-top w3-border-green w3-border-right  w3-hover-green">"'_n	
		file write `book' `"<strong>Variables</strong>"'_n
		file write `book' `"</button>"'_n	
		file write `book' `"</div>"'_n
		
		local w3hide "w3-hide"
	}
	
	file write `book' `"<div id="desc`fnr'" class="w3-container w3-border `w3hide' w3-pale-green">"'_n
	file write `book' `"<p><strong>Descriptives</strong></p>"'_n
	file write `book' `"<table class="w3-table w3-card w3-hoverable w3-bordered w3-border w3-small w3-white">"'_n
	file write `book' `"<tr><th>Observations</th>"'_n
	file write `book' `"<td>`: display %14.0gc `c(N)''</td></tr>"'_n
	file write `book' `"<tr><th>variables</th>"'_n
	file write `book' `"<td>`: display %14.0gc `c(k)''</td></tr>"'_n
	file write `book' `"<tr><th>Last saved</th>"'_n
	file write `book' `"<td>"'_n
	if `"`c(filedate)'"' == "" {
		file write `book' "-"
	}
	else {
		file write `book' `"`c(filedate)'"'
		if c(changed) {
			file write `book' `" (changed)"'
		}
	}
	file write `book' `"</td></tr>"'_n
	file write `book' `"<tr><th>data signature</th>"'_n
	file write `book' `"<td>"'_n
	capture datasignature confirm
	if _rc {
		file write `book' `"-"'_n
	}
	else {
		file write `book' `"`r(datasignature)'"'_n
	}
	file write `book' `"</td></tr>"'_n	
	
	if "`: char _dta[note0]'" != "" {
		forvalues i = 1/`: char _dta[note0]' {
			file write `book' `"<tr><th>note `i'</th>"'
			file write `book' `"<td>`: char _dta[note`i']'</td></tr>"' _n
		}
	}	
	file write `book' `"</table>"'_n
	file write `book' "<br>"_n
	file write `book' `"</div>"'_n
end

program define varsdesc
	syntax, book(string) fnr(integer) [fast] k(integer)
	if `k' > 1 local w3hide "w3-hide"
	file write `book' `"<div id="vars`fnr'" class="w3-container w3-border `w3hide' w3-pale-green">"'_n
	file write `book' `"<p><strong>Variables</strong></p>"'_n
	foreach var of varlist * {
		file write `book' `"<button onclick="acc("' _char(39)`"`var'_`fnr'"' _char(39) `")" class="line-wrap w3-container w3-button w3-block w3-border w3-left-align w3-white w3-leftbar w3-border-green w3-hover-green">"'_n
		file write `book' `"<strong>`var'</strong>"' 
		if `"`: var label `var''"' != "" {
			file write `book' `": `: var label `var''"'
		}
		file write `book' _n
		file write `book' `"</button>"'_n
		file write `book' `"<div id="`var'_`fnr'" class="w3-container w3-border w3-hide w3-white">"' _n
		vardesc `var', book(`book') fnr(`fnr') `fast'
		file write `book' "<br>" _n
		file write `book' `"</div>"' _n		
	}
	file write `book' `"<br>"'_n
	file write `book' `"</div>"'_n
end

program define vardesc
	syntax varname, book(string) fnr(integer) [fast]
	local var `varlist'
	qui {
		capture confirm numeric variable `var'
		local numeric = _rc == 0

		if "`fast'" == "" {
			tempname freq vals
			capture tab `var', matcell(`freq') matrow(`vals') missing
			if !_rc {
				local tab = 1
			}
			else {
				tempvar v_mark v_freq 
				sort `var'
				by `var' : gen `v_mark' = ( _n == 1 )
				by `var' : gen `v_freq' = _N
				local tab=0
			}
			
			noi mata: create_table("`var'", `numeric')
		}
		else {
			local mktab = 0
		}
			
		file write `book' "<p><strong>summary</strong></p>"_n
		file write `book' `"<table class="w3-table w3-hoverable w3-card w3-bordered w3-border w3-small w3-white">"' _n
		if `numeric' {
			local type "numeric"
		}
		else {
			local type "string"
		}
		local type `"`type' (`:type `var'')"'
		file write `book' `"<tr><th>type</th><td>`type'</td></tr>"'_n
		qui count if missing(`var')
		file write `book' `"<tr><th>missing values</th><td>`: display %14.0gc `r(N)''</td></tr>"'_n
		qui count if !missing(`var')
		file write `book' `"<tr><th>non-missing values</th><td>`: display %14.0gc `r(N)''</td></tr>"'_n
		if "`fast'" == "" {
			file write `book' `"<tr><th>distinct non-missing values</th><td>`: display %14.0gc `nvals''</td></tr>"'_n
		}
		if !`mktab' & `numeric' {
			if "`fast'" == "" {
				qui sum `var', detail
				file write `book' `"<tr><th>minimum</th><td>`: display `: format `var'' `r(min)''</td></tr>"'_n
				file write `book' `"<tr><th>1st quartile</th><td>`: display `: format `var'' `r(p25)''</td></tr>"'_n
				file write `book' `"<tr><th>median</th><td>`: display `: format `var'' `r(p50)''</td></tr>"'_n
				file write `book' `"<tr><th>3rd quartile</th><td>`: display `: format `var'' `r(p75)''</td></tr>"'_n
				file write `book' `"<tr><th>maximum</th><td>`: display `: format `var'' `r(max)''</td></tr>"'_n
			}
			else {
				qui sum `var', meanonly
				file write `book' `"<tr><th>minimum</th><td>`: display `: format `var'' `r(min)''</td></tr>"'_n
				file write `book' `"<tr><th>mean</th><td>`: display `: format `var'' `r(mean)''</td></tr>"'_n
				file write `book' `"<tr><th>maximum</th><td>`: display `: format `var'' `r(max)''</td></tr>"'_n			
			}
		}
		if "`: char `var'[note0]'" != "" {
			forvalues i = 1/`: char `var'[note0]' {
				file write `book' `"<tr><th>note `i'</th> "'
				file write `book' `"<td>`: char `var'[note`i']'</td></tr>"' _n
			}
		}
		file write `book' "</table>"_n
		
		if `mktab' {
			file write `book' "<p><strong>table</strong></p>"_n
			file write `book' `"<table class="w3-table w3-card w3-hoverable w3-bordered w3-border w3-small w3-white">"'_n
			file write `book' "<tr><th>value</th><th>label</th><th>frequency</th></tr>"_n
			forvalues i = 1/`k' {
				file write `book' `"`out`i''"'_n
			}
			file write `book' `"</table>"'_n
		}
		else { 
			if !`numeric' & "`fast'" == "" {
				file write `book' "<p><strong>example values</strong></p>"_n
				file write `book' `"<table class="w3-table w3-card w3-hoverable w3-bordered w3-border w3-small w3-white">"'_n
				forvalues i = 1/10 {
					file write `book' `"`out`i''"'_n
				}
				file write `book' `"</table>"'_n			
			}

		}
	}
end

program define closing
	syntax, book(string)
	file write `book' `"<div class="w3-container w3-green">"'_n
	file write `book' `"<p>Codebook created on `c(current_date)' `c(current_time)'</p>"'_n
	file write `book' `"</div>"'_n
	
	file write `book' `"</div>"'_n
	file write `book' `"<script>"'_n
	file write `book' `"	function acc(id) {"'_n
	file write `book' `"		var x = document.getElementById(id);"'_n
	file write `book' `"		if (x.className.indexOf("w3-show") == -1) {"'_n
	file write `book' `"			x.className += " w3-show";"'_n
	file write `book' `"		} else {"'_n
	file write `book' `"			x.className = x.className.replace(" w3-show", "");"'_n
	file write `book' `"		}"'_n
	file write `book' `"	}"'_n
	file write `book' `"function w3_open() {"'_n
    file write `book' `"	document.getElementById("mySidebar").style.display = "block";"'_n
	file write `book' `"}"'_n
	file write `book' `"function w3_close() {"'_n
    file write `book' `"	document.getElementById("mySidebar").style.display = "none";"'_n
	file write `book' `"}"'_n
	file write `book' `"	</script>"'_n
	file write `book' `"</body>"'_n
	file write `book' `"</html>"'_n
end

program define w3css
	syntax , book(string)
	file write `book' `"/* W3.CSS 4.10 February 2018 by Jan Egil and Borge Refsnes */                                                                                                                                                                      "'_n 
	file write `book' `"html{box-sizing:border-box}*,*:before,*:after{box-sizing:inherit}                                                                                                                                                                  "'_n 
	file write `book' `"/* Extract from normalize.css by Nicolas Gallagher and Jonathan Neal git.io/normalize */                                                                                                                                           "'_n 
	file write `book' `"html{-ms-text-size-adjust:100%;-webkit-text-size-adjust:100%}body{margin:0}                                                                                                                                                        "'_n 
	file write `book' `"article,aside,details,figcaption,figure,footer,header,main,menu,nav,section,summary{display:block}                                                                                                                                 "'_n 
	file write `book' `"audio,canvas,progress,video{display:inline-block}progress{vertical-align:baseline}                                                                                                                                                 "'_n 
	file write `book' `"audio:not([controls]){display:none;height:0}[hidden],template{display:none}                                                                                                                                                        "'_n 
	file write `book' `"a{background-color:transparent;-webkit-text-decoration-skip:objects}                                                                                                                                                               "'_n 
	file write `book' `"a:active,a:hover{outline-width:0}abbr[title]{border-bottom:none;text-decoration:underline;text-decoration:underline dotted}                                                                                                        "'_n 
	file write `book' `"dfn{font-style:italic}mark{background:#ff0;color:#000}                                                                                                                                                                             "'_n 
	file write `book' `"small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}                                                                                                                                 "'_n 
	file write `book' `"sub{bottom:-0.25em}sup{top:-0.5em}figure{margin:1em 40px}img{border-style:none}svg:not(:root){overflow:hidden}                                                                                                                     "'_n 
	file write `book' `"code,kbd,pre,samp{font-family:monospace,monospace;font-size:1em}hr{box-sizing:content-box;height:0;overflow:visible}                                                                                                               "'_n 
	file write `book' `"button,input,select,textarea{font:inherit;margin:0}optgroup{font-weight:bold}                                                                                                                                                      "'_n 
	file write `book' `"button,input{overflow:visible}button,select{text-transform:none}                                                                                                                                                                   "'_n 
	file write `book' `"button,html [type=button],[type=reset],[type=submit]{-webkit-appearance:button}                                                                                                                                                    "'_n 
	file write `book' `"button::-moz-focus-inner, [type=button]::-moz-focus-inner, [type=reset]::-moz-focus-inner, [type=submit]::-moz-focus-inner{border-style:none;padding:0}                                                                            "'_n 
	file write `book' `"button:-moz-focusring, [type=button]:-moz-focusring, [type=reset]:-moz-focusring, [type=submit]:-moz-focusring{outline:1px dotted ButtonText}                                                                                      "'_n 
	file write `book' `"fieldset{border:1px solid #c0c0c0;margin:0 2px;padding:.35em .625em .75em}                                                                                                                                                         "'_n 
	file write `book' `"legend{color:inherit;display:table;max-width:100%;padding:0;white-space:normal}textarea{overflow:auto}                                                                                                                             "'_n 
	file write `book' `"[type=checkbox],[type=radio]{padding:0}                                                                                                                                                                                            "'_n 
	file write `book' `"[type=number]::-webkit-inner-spin-button,[type=number]::-webkit-outer-spin-button{height:auto}                                                                                                                                     "'_n 
	file write `book' `"[type=search]{-webkit-appearance:textfield;outline-offset:-2px}                                                                                                                                                                    "'_n 
	file write `book' `"[type=search]::-webkit-search-cancel-button,[type=search]::-webkit-search-decoration{-webkit-appearance:none}                                                                                                                      "'_n 
	file write `book' `"::-webkit-input-placeholder{color:inherit;opacity:0.54}                                                                                                                                                                            "'_n 
	file write `book' `"::-webkit-file-upload-button{-webkit-appearance:button;font:inherit}                                                                                                                                                               "'_n 
	file write `book' `"/* End extract */                                                                                                                                                                                                                  "'_n 
	file write `book' `"html,body{font-family:Verdana,sans-serif;font-size:15px;line-height:1.5}html{overflow-x:hidden}                                                                                                                                    "'_n 
	file write `book' `"h1{font-size:36px}h2{font-size:30px}h3{font-size:24px}h4{font-size:20px}h5{font-size:18px}h6{font-size:16px}.w3-serif{font-family:serif}                                                                                           "'_n 
	file write `book' `"h1,h2,h3,h4,h5,h6{font-family:"Segoe UI",Arial,sans-serif;font-weight:400;margin:10px 0}.w3-wide{letter-spacing:4px}                                                                                                               "'_n 
	file write `book' `"hr{border:0;border-top:1px solid #eee;margin:20px 0}                                                                                                                                                                               "'_n 
	file write `book' `".w3-image{max-width:100%;height:auto}img{vertical-align:middle}a{color:inherit}                                                                                                                                                    "'_n 
	file write `book' `".w3-table,.w3-table-all{border-collapse:collapse;border-spacing:0;width:100%;display:table}.w3-table-all{border:1px solid #ccc}                                                                                                    "'_n 
	file write `book' `".w3-bordered tr,.w3-table-all tr{border-bottom:1px solid #ddd}.w3-striped tbody tr:nth-child(even){background-color:#f1f1f1}                                                                                                       "'_n 
	file write `book' `".w3-table-all tr:nth-child(odd){background-color:#fff}.w3-table-all tr:nth-child(even){background-color:#f1f1f1}                                                                                                                   "'_n 
	file write `book' `".w3-hoverable tbody tr:hover,.w3-ul.w3-hoverable li:hover{background-color:#ccc}.w3-centered tr th,.w3-centered tr td{text-align:center}                                                                                           "'_n 
	file write `book' `".w3-table td,.w3-table th,.w3-table-all td,.w3-table-all th{padding:8px 8px;display:table-cell;text-align:left;vertical-align:top}                                                                                                 "'_n 
	file write `book' `".w3-table th:first-child,.w3-table td:first-child,.w3-table-all th:first-child,.w3-table-all td:first-child{padding-left:16px}                                                                                                     "'_n 
	file write `book' `".w3-btn,.w3-button{border:none;display:inline-block;padding:8px 16px;vertical-align:middle;overflow:hidden;text-decoration:none;color:inherit;background-color:inherit;text-align:center;cursor:pointer;white-space:nowrap}        "'_n 
	file write `book' `".w3-btn:hover{box-shadow:0 8px 16px 0 rgba(0,0,0,0.2),0 6px 20px 0 rgba(0,0,0,0.19)}                                                                                                                                               "'_n 
	file write `book' `".w3-btn,.w3-button{-webkit-touch-callout:none;-webkit-user-select:none;-khtml-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none}                                                                        "'_n 
	file write `book' `".w3-disabled,.w3-btn:disabled,.w3-button:disabled{cursor:not-allowed;opacity:0.3}.w3-disabled *,:disabled *{pointer-events:none}                                                                                                   "'_n 
	file write `book' `".w3-btn.w3-disabled:hover,.w3-btn:disabled:hover{box-shadow:none}                                                                                                                                                                  "'_n 
	file write `book' `".w3-badge,.w3-tag{background-color:#000;color:#fff;display:inline-block;padding-left:8px;padding-right:8px;text-align:center}.w3-badge{border-radius:50%}                                                                          "'_n 
	file write `book' `".w3-ul{list-style-type:none;padding:0;margin:0}.w3-ul li{padding:8px 16px;border-bottom:1px solid #ddd}.w3-ul li:last-child{border-bottom:none}                                                                                    "'_n 
	file write `book' `".w3-tooltip,.w3-display-container{position:relative}.w3-tooltip .w3-text{display:none}.w3-tooltip:hover .w3-text{display:inline-block}                                                                                             "'_n 
	file write `book' `".w3-ripple:active{opacity:0.5}.w3-ripple{transition:opacity 0s}                                                                                                                                                                    "'_n 
	file write `book' `".w3-input{padding:8px;display:block;border:none;border-bottom:1px solid #ccc;width:100%}                                                                                                                                           "'_n 
	file write `book' `".w3-select{padding:9px 0;width:100%;border:none;border-bottom:1px solid #ccc}                                                                                                                                                      "'_n 
	file write `book' `".w3-dropdown-click,.w3-dropdown-hover{position:relative;display:inline-block;cursor:pointer}                                                                                                                                       "'_n 
	file write `book' `".w3-dropdown-hover:hover .w3-dropdown-content{display:block}                                                                                                                                                                       "'_n 
	file write `book' `".w3-dropdown-hover:first-child,.w3-dropdown-click:hover{background-color:#ccc;color:#000}                                                                                                                                          "'_n 
	file write `book' `".w3-dropdown-hover:hover > .w3-button:first-child,.w3-dropdown-click:hover > .w3-button:first-child{background-color:#ccc;color:#000}                                                                                              "'_n 
	file write `book' `".w3-dropdown-content{cursor:auto;color:#000;background-color:#fff;display:none;position:absolute;min-width:160px;margin:0;padding:0;z-index:1}                                                                                     "'_n 
	file write `book' `".w3-check,.w3-radio{width:24px;height:24px;position:relative;top:6px}                                                                                                                                                              "'_n 
	file write `book' `".w3-sidebar{height:100%;width:200px;background-color:#fff;position:fixed!important;z-index:1;overflow:auto}                                                                                                                        "'_n 
	file write `book' `".w3-bar-block .w3-dropdown-hover,.w3-bar-block .w3-dropdown-click{width:100%}                                                                                                                                                      "'_n 
	file write `book' `".w3-bar-block .w3-dropdown-hover .w3-dropdown-content,.w3-bar-block .w3-dropdown-click .w3-dropdown-content{min-width:100%}                                                                                                        "'_n 
	file write `book' `".w3-bar-block .w3-dropdown-hover .w3-button,.w3-bar-block .w3-dropdown-click .w3-button{width:100%;text-align:left;padding:8px 16px}                                                                                               "'_n 
	file write `book' `".w3-main,#main{transition:margin-left .4s}                                                                                                                                                                                         "'_n 
	file write `book' `".w3-modal{z-index:3;display:none;padding-top:100px;position:fixed;left:0;top:0;width:100%;height:100%;overflow:auto;background-color:rgb(0,0,0);background-color:rgba(0,0,0,0.4)}                                                  "'_n 
	file write `book' `".w3-modal-content{margin:auto;background-color:#fff;position:relative;padding:0;outline:0;width:600px}                                                                                                                             "'_n 
	file write `book' `".w3-bar{width:100%;overflow:hidden}.w3-center .w3-bar{display:inline-block;width:auto}                                                                                                                                             "'_n 
	file write `book' `".w3-bar .w3-bar-item{padding:8px 16px;float:left;width:auto;border:none;display:block;outline:0}                                                                                                                                   "'_n 
	file write `book' `".w3-bar .w3-dropdown-hover,.w3-bar .w3-dropdown-click{position:static;float:left}                                                                                                                                                  "'_n 
	file write `book' `".w3-bar .w3-button{white-space:normal}                                                                                                                                                                                             "'_n 
	file write `book' `".w3-bar-block .w3-bar-item{width:100%;display:block;padding:8px 16px;text-align:left;border:none;white-space:normal;float:none;outline:0}                                                                                          "'_n 
	file write `book' `".w3-bar-block.w3-center .w3-bar-item{text-align:center}.w3-block{display:block;width:100%}                                                                                                                                         "'_n 
	file write `book' `".w3-responsive{display:block;overflow-x:auto}                                                                                                                                                                                      "'_n 
	file write `book' `".w3-container:after,.w3-container:before,.w3-panel:after,.w3-panel:before,.w3-row:after,.w3-row:before,.w3-row-padding:after,.w3-row-padding:before,                                                                               "'_n 
	file write `book' `".w3-cell-row:before,.w3-cell-row:after,.w3-clear:after,.w3-clear:before,.w3-bar:before,.w3-bar:after{content:"";display:table;clear:both}                                                                                          "'_n 
	file write `book' `".w3-col,.w3-half,.w3-third,.w3-twothird,.w3-threequarter,.w3-quarter{float:left;width:100%}                                                                                                                                        "'_n 
	file write `book' `".w3-col.s1{width:8.33333%}.w3-col.s2{width:16.66666%}.w3-col.s3{width:24.99999%}.w3-col.s4{width:33.33333%}                                                                                                                        "'_n 
	file write `book' `".w3-col.s5{width:41.66666%}.w3-col.s6{width:49.99999%}.w3-col.s7{width:58.33333%}.w3-col.s8{width:66.66666%}                                                                                                                       "'_n 
	file write `book' `".w3-col.s9{width:74.99999%}.w3-col.s10{width:83.33333%}.w3-col.s11{width:91.66666%}.w3-col.s12{width:99.99999%}                                                                                                                    "'_n 
	file write `book' `"@media (min-width:601px){.w3-col.m1{width:8.33333%}.w3-col.m2{width:16.66666%}.w3-col.m3,.w3-quarter{width:24.99999%}.w3-col.m4,.w3-third{width:33.33333%}                                                                         "'_n 
	file write `book' `".w3-col.m5{width:41.66666%}.w3-col.m6,.w3-half{width:49.99999%}.w3-col.m7{width:58.33333%}.w3-col.m8,.w3-twothird{width:66.66666%}                                                                                                 "'_n 
	file write `book' `".w3-col.m9,.w3-threequarter{width:74.99999%}.w3-col.m10{width:83.33333%}.w3-col.m11{width:91.66666%}.w3-col.m12{width:99.99999%}}                                                                                                  "'_n 
	file write `book' `"@media (min-width:993px){.w3-col.l1{width:8.33333%}.w3-col.l2{width:16.66666%}.w3-col.l3{width:24.99999%}.w3-col.l4{width:33.33333%}                                                                                               "'_n 
	file write `book' `".w3-col.l5{width:41.66666%}.w3-col.l6{width:49.99999%}.w3-col.l7{width:58.33333%}.w3-col.l8{width:66.66666%}                                                                                                                       "'_n 
	file write `book' `".w3-col.l9{width:74.99999%}.w3-col.l10{width:83.33333%}.w3-col.l11{width:91.66666%}.w3-col.l12{width:99.99999%}}                                                                                                                   "'_n 
	file write `book' `".w3-content{max-width:980px;margin:auto}.w3-rest{overflow:hidden}                                                                                                                                                                  "'_n 
	file write `book' `".w3-cell-row{display:table;width:100%}.w3-cell{display:table-cell}                                                                                                                                                                 "'_n 
	file write `book' `".w3-cell-top{vertical-align:top}.w3-cell-middle{vertical-align:middle}.w3-cell-bottom{vertical-align:bottom}                                                                                                                       "'_n 
	file write `book' `".w3-hide{display:none!important}.w3-show-block,.w3-show{display:block!important}.w3-show-inline-block{display:inline-block!important}                                                                                              "'_n 
	file write `book' `"@media (max-width:600px){.w3-modal-content{margin:0 10px;width:auto!important}.w3-modal{padding-top:30px}                                                                                                                          "'_n 
	file write `book' `".w3-dropdown-hover.w3-mobile .w3-dropdown-content,.w3-dropdown-click.w3-mobile .w3-dropdown-content{position:relative}	                                                                                                            "'_n 
	file write `book' `".w3-hide-small{display:none!important}.w3-mobile{display:block;width:100%!important}.w3-bar-item.w3-mobile,.w3-dropdown-hover.w3-mobile,.w3-dropdown-click.w3-mobile{text-align:center}                                            "'_n 
	file write `book' `".w3-dropdown-hover.w3-mobile,.w3-dropdown-hover.w3-mobile .w3-btn,.w3-dropdown-hover.w3-mobile .w3-button,.w3-dropdown-click.w3-mobile,.w3-dropdown-click.w3-mobile .w3-btn,.w3-dropdown-click.w3-mobile .w3-button{width:100%}}   "'_n 
	file write `book' `"@media (max-width:768px){.w3-modal-content{width:500px}.w3-modal{padding-top:50px}}                                                                                                                                                "'_n 
	file write `book' `"@media (min-width:993px){.w3-modal-content{width:900px}.w3-hide-large{display:none!important}.w3-sidebar.w3-collapse{display:block!important}}                                                                                     "'_n 
	file write `book' `"@media (max-width:992px) and (min-width:601px){.w3-hide-medium{display:none!important}}                                                                                                                                            "'_n 
	file write `book' `"@media (max-width:992px){.w3-sidebar.w3-collapse{display:none}.w3-main{margin-left:0!important;margin-right:0!important}}                                                                                                          "'_n 
	file write `book' `".w3-top,.w3-bottom{position:fixed;width:100%;z-index:1}.w3-top{top:0}.w3-bottom{bottom:0}                                                                                                                                          "'_n 
	file write `book' `".w3-overlay{position:fixed;display:none;width:100%;height:100%;top:0;left:0;right:0;bottom:0;background-color:rgba(0,0,0,0.5);z-index:2}                                                                                           "'_n 
	file write `book' `".w3-display-topleft{position:absolute;left:0;top:0}.w3-display-topright{position:absolute;right:0;top:0}                                                                                                                           "'_n 
	file write `book' `".w3-display-bottomleft{position:absolute;left:0;bottom:0}.w3-display-bottomright{position:absolute;right:0;bottom:0}                                                                                                               "'_n 
	file write `book' `".w3-display-middle{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%)}                                                                                                           "'_n 
	file write `book' `".w3-display-left{position:absolute;top:50%;left:0%;transform:translate(0%,-50%);-ms-transform:translate(-0%,-50%)}                                                                                                                 "'_n 
	file write `book' `".w3-display-right{position:absolute;top:50%;right:0%;transform:translate(0%,-50%);-ms-transform:translate(0%,-50%)}                                                                                                                "'_n 
	file write `book' `".w3-display-topmiddle{position:absolute;left:50%;top:0;transform:translate(-50%,0%);-ms-transform:translate(-50%,0%)}                                                                                                              "'_n 
	file write `book' `".w3-display-bottommiddle{position:absolute;left:50%;bottom:0;transform:translate(-50%,0%);-ms-transform:translate(-50%,0%)}                                                                                                        "'_n 
	file write `book' `".w3-display-container:hover .w3-display-hover{display:block}.w3-display-container:hover span.w3-display-hover{display:inline-block}.w3-display-hover{display:none}                                                                 "'_n 
	file write `book' `".w3-display-position{position:absolute}                                                                                                                                                                                            "'_n 
	file write `book' `".w3-circle{border-radius:50%}                                                                                                                                                                                                      "'_n 
	file write `book' `".w3-round-small{border-radius:2px}.w3-round,.w3-round-medium{border-radius:4px}.w3-round-large{border-radius:8px}.w3-round-xlarge{border-radius:16px}.w3-round-xxlarge{border-radius:32px}                                         "'_n 
	file write `book' `".w3-row-padding,.w3-row-padding>.w3-half,.w3-row-padding>.w3-third,.w3-row-padding>.w3-twothird,.w3-row-padding>.w3-threequarter,.w3-row-padding>.w3-quarter,.w3-row-padding>.w3-col{padding:0 8px}                                "'_n 
	file write `book' `".w3-container,.w3-panel{padding:0.01em 16px}.w3-panel{margin-top:16px;margin-bottom:16px}                                                                                                                                          "'_n 
	file write `book' `".w3-code,.w3-codespan{font-family:Consolas,"courier new";font-size:16px}                                                                                                                                                           "'_n 
	file write `book' `".w3-code{width:auto;background-color:#fff;padding:8px 12px;border-left:4px solid #4CAF50;word-wrap:break-word}                                                                                                                     "'_n 
	file write `book' `".w3-codespan{color:crimson;background-color:#f1f1f1;padding-left:4px;padding-right:4px;font-size:110%}                                                                                                                             "'_n 
	file write `book' `".w3-card,.w3-card-2{box-shadow:0 2px 5px 0 rgba(0,0,0,0.16),0 2px 10px 0 rgba(0,0,0,0.12)}                                                                                                                                         "'_n 
	file write `book' `".w3-card-4,.w3-hover-shadow:hover{box-shadow:0 4px 10px 0 rgba(0,0,0,0.2),0 4px 20px 0 rgba(0,0,0,0.19)}                                                                                                                           "'_n 
	file write `book' `".w3-spin{animation:w3-spin 2s infinite linear}@keyframes w3-spin{0%{transform:rotate(0deg)}100%{transform:rotate(359deg)}}                                                                                                         "'_n 
	file write `book' `".w3-animate-fading{animation:fading 10s infinite}@keyframes fading{0%{opacity:0}50%{opacity:1}100%{opacity:0}}                                                                                                                     "'_n 
	file write `book' `".w3-animate-opacity{animation:opac 0.8s}@keyframes opac{from{opacity:0} to{opacity:1}}                                                                                                                                             "'_n 
	file write `book' `".w3-animate-top{position:relative;animation:animatetop 0.4s}@keyframes animatetop{from{top:-300px;opacity:0} to{top:0;opacity:1}}                                                                                                  "'_n 
	file write `book' `".w3-animate-left{position:relative;animation:animateleft 0.4s}@keyframes animateleft{from{left:-300px;opacity:0} to{left:0;opacity:1}}                                                                                             "'_n 
	file write `book' `".w3-animate-right{position:relative;animation:animateright 0.4s}@keyframes animateright{from{right:-300px;opacity:0} to{right:0;opacity:1}}                                                                                        "'_n 
	file write `book' `".w3-animate-bottom{position:relative;animation:animatebottom 0.4s}@keyframes animatebottom{from{bottom:-300px;opacity:0} to{bottom:0;opacity:1}}                                                                                   "'_n 
	file write `book' `".w3-animate-zoom {animation:animatezoom 0.6s}@keyframes animatezoom{from{transform:scale(0)} to{transform:scale(1)}}                                                                                                               "'_n 
	file write `book' `".w3-animate-input{transition:width 0.4s ease-in-out}.w3-animate-input:focus{width:100%!important}                                                                                                                                  "'_n 
	file write `book' `".w3-opacity,.w3-hover-opacity:hover{opacity:0.60}.w3-opacity-off,.w3-hover-opacity-off:hover{opacity:1}                                                                                                                            "'_n 
	file write `book' `".w3-opacity-max{opacity:0.25}.w3-opacity-min{opacity:0.75}                                                                                                                                                                         "'_n 
	file write `book' `".w3-greyscale-max,.w3-grayscale-max,.w3-hover-greyscale:hover,.w3-hover-grayscale:hover{filter:grayscale(100%)}                                                                                                                    "'_n 
	file write `book' `".w3-greyscale,.w3-grayscale{filter:grayscale(75%)}.w3-greyscale-min,.w3-grayscale-min{filter:grayscale(50%)}                                                                                                                       "'_n 
	file write `book' `".w3-sepia{filter:sepia(75%)}.w3-sepia-max,.w3-hover-sepia:hover{filter:sepia(100%)}.w3-sepia-min{filter:sepia(50%)}                                                                                                                "'_n 
	file write `book' `".w3-tiny{font-size:10px!important}.w3-small{font-size:12px!important}.w3-medium{font-size:15px!important}.w3-large{font-size:18px!important}                                                                                       "'_n 
	file write `book' `".w3-xlarge{font-size:24px!important}.w3-xxlarge{font-size:36px!important}.w3-xxxlarge{font-size:48px!important}.w3-jumbo{font-size:64px!important}                                                                                 "'_n 
	file write `book' `".w3-left-align{text-align:left!important}.w3-right-align{text-align:right!important}.w3-justify{text-align:justify!important}.w3-center{text-align:center!important}                                                               "'_n 
	file write `book' `".w3-border-0{border:0!important}.w3-border{border:1px solid #ccc!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-top{border-top:1px solid #ccc!important}.w3-border-bottom{border-bottom:1px solid #ccc!important}                                                                                                                       "'_n 
	file write `book' `".w3-border-left{border-left:1px solid #ccc!important}.w3-border-right{border-right:1px solid #ccc!important}                                                                                                                       "'_n 
	file write `book' `".w3-topbar{border-top:6px solid #ccc!important}.w3-bottombar{border-bottom:6px solid #ccc!important}                                                                                                                               "'_n 
	file write `book' `".w3-leftbar{border-left:6px solid #ccc!important}.w3-rightbar{border-right:6px solid #ccc!important}                                                                                                                               "'_n 
	file write `book' `".w3-section,.w3-code{margin-top:16px!important;margin-bottom:16px!important}                                                                                                                                                       "'_n 
	file write `book' `".w3-margin{margin:16px!important}.w3-margin-top{margin-top:16px!important}.w3-margin-bottom{margin-bottom:16px!important}                                                                                                          "'_n 
	file write `book' `".w3-margin-left{margin-left:16px!important}.w3-margin-right{margin-right:16px!important}                                                                                                                                           "'_n 
	file write `book' `".w3-padding-small{padding:4px 8px!important}.w3-padding{padding:8px 16px!important}.w3-padding-large{padding:12px 24px!important}                                                                                                  "'_n 
	file write `book' `".w3-padding-16{padding-top:16px!important;padding-bottom:16px!important}.w3-padding-24{padding-top:24px!important;padding-bottom:24px!important}                                                                                   "'_n 
	file write `book' `".w3-padding-32{padding-top:32px!important;padding-bottom:32px!important}.w3-padding-48{padding-top:48px!important;padding-bottom:48px!important}                                                                                   "'_n 
	file write `book' `".w3-padding-64{padding-top:64px!important;padding-bottom:64px!important}                                                                                                                                                           "'_n 
	file write `book' `".w3-left{float:left!important}.w3-right{float:right!important}                                                                                                                                                                     "'_n 
	file write `book' `".w3-button:hover{color:#000!important;background-color:#ccc!important}                                                                                                                                                             "'_n 
	file write `book' `".w3-transparent,.w3-hover-none:hover{background-color:transparent!important}                                                                                                                                                       "'_n 
	file write `book' `".w3-hover-none:hover{box-shadow:none!important}                                                                                                                                                                                    "'_n 
	file write `book' `"/* Colors */                                                                                                                                                                                                                       "'_n 
	file write `book' `".w3-amber,.w3-hover-amber:hover{color:#000!important;background-color:#ffc107!important}                                                                                                                                           "'_n 
	file write `book' `".w3-aqua,.w3-hover-aqua:hover{color:#000!important;background-color:#00ffff!important}                                                                                                                                             "'_n 
	file write `book' `".w3-blue,.w3-hover-blue:hover{color:#fff!important;background-color:#2196F3!important}                                                                                                                                             "'_n 
	file write `book' `".w3-light-blue,.w3-hover-light-blue:hover{color:#000!important;background-color:#87CEEB!important}                                                                                                                                 "'_n 
	file write `book' `".w3-brown,.w3-hover-brown:hover{color:#fff!important;background-color:#795548!important}                                                                                                                                           "'_n 
	file write `book' `".w3-cyan,.w3-hover-cyan:hover{color:#000!important;background-color:#00bcd4!important}                                                                                                                                             "'_n 
	file write `book' `".w3-blue-grey,.w3-hover-blue-grey:hover,.w3-blue-gray,.w3-hover-blue-gray:hover{color:#fff!important;background-color:#607d8b!important}                                                                                           "'_n 
	file write `book' `".w3-green,.w3-hover-green:hover{color:#fff!important;background-color:#4CAF50!important}                                                                                                                                           "'_n 
	file write `book' `".w3-light-green,.w3-hover-light-green:hover{color:#000!important;background-color:#8bc34a!important}                                                                                                                               "'_n 
	file write `book' `".w3-indigo,.w3-hover-indigo:hover{color:#fff!important;background-color:#3f51b5!important}                                                                                                                                         "'_n 
	file write `book' `".w3-khaki,.w3-hover-khaki:hover{color:#000!important;background-color:#f0e68c!important}                                                                                                                                           "'_n 
	file write `book' `".w3-lime,.w3-hover-lime:hover{color:#000!important;background-color:#cddc39!important}                                                                                                                                             "'_n 
	file write `book' `".w3-orange,.w3-hover-orange:hover{color:#000!important;background-color:#ff9800!important}                                                                                                                                         "'_n 
	file write `book' `".w3-deep-orange,.w3-hover-deep-orange:hover{color:#fff!important;background-color:#ff5722!important}                                                                                                                               "'_n 
	file write `book' `".w3-pink,.w3-hover-pink:hover{color:#fff!important;background-color:#e91e63!important}                                                                                                                                             "'_n 
	file write `book' `".w3-purple,.w3-hover-purple:hover{color:#fff!important;background-color:#9c27b0!important}                                                                                                                                         "'_n 
	file write `book' `".w3-deep-purple,.w3-hover-deep-purple:hover{color:#fff!important;background-color:#673ab7!important}                                                                                                                               "'_n 
	file write `book' `".w3-red,.w3-hover-red:hover{color:#fff!important;background-color:#f44336!important}                                                                                                                                               "'_n 
	file write `book' `".w3-sand,.w3-hover-sand:hover{color:#000!important;background-color:#fdf5e6!important}                                                                                                                                             "'_n 
	file write `book' `".w3-teal,.w3-hover-teal:hover{color:#fff!important;background-color:#009688!important}                                                                                                                                             "'_n 
	file write `book' `".w3-yellow,.w3-hover-yellow:hover{color:#000!important;background-color:#ffeb3b!important}                                                                                                                                         "'_n 
	file write `book' `".w3-white,.w3-hover-white:hover{color:#000!important;background-color:#fff!important}                                                                                                                                              "'_n 
	file write `book' `".w3-black,.w3-hover-black:hover{color:#fff!important;background-color:#000!important}                                                                                                                                              "'_n 
	file write `book' `".w3-grey,.w3-hover-grey:hover,.w3-gray,.w3-hover-gray:hover{color:#000!important;background-color:#9e9e9e!important}                                                                                                               "'_n 
	file write `book' `".w3-light-grey,.w3-hover-light-grey:hover,.w3-light-gray,.w3-hover-light-gray:hover{color:#000!important;background-color:#f1f1f1!important}                                                                                       "'_n 
	file write `book' `".w3-dark-grey,.w3-hover-dark-grey:hover,.w3-dark-gray,.w3-hover-dark-gray:hover{color:#fff!important;background-color:#616161!important}                                                                                           "'_n 
	file write `book' `".w3-pale-red,.w3-hover-pale-red:hover{color:#000!important;background-color:#ffdddd!important}                                                                                                                                     "'_n 
	file write `book' `".w3-pale-green,.w3-hover-pale-green:hover{color:#000!important;background-color:#ddffdd!important}                                                                                                                                 "'_n 
	file write `book' `".w3-pale-yellow,.w3-hover-pale-yellow:hover{color:#000!important;background-color:#ffffcc!important}                                                                                                                               "'_n 
	file write `book' `".w3-pale-blue,.w3-hover-pale-blue:hover{color:#000!important;background-color:#ddffff!important}                                                                                                                                   "'_n 
	file write `book' `".w3-text-amber,.w3-hover-text-amber:hover{color:#ffc107!important}                                                                                                                                                                 "'_n 
	file write `book' `".w3-text-aqua,.w3-hover-text-aqua:hover{color:#00ffff!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-blue,.w3-hover-text-blue:hover{color:#2196F3!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-light-blue,.w3-hover-text-light-blue:hover{color:#87CEEB!important}                                                                                                                                                       "'_n 
	file write `book' `".w3-text-brown,.w3-hover-text-brown:hover{color:#795548!important}                                                                                                                                                                 "'_n 
	file write `book' `".w3-text-cyan,.w3-hover-text-cyan:hover{color:#00bcd4!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-blue-grey,.w3-hover-text-blue-grey:hover,.w3-text-blue-gray,.w3-hover-text-blue-gray:hover{color:#607d8b!important}                                                                                                       "'_n 
	file write `book' `".w3-text-green,.w3-hover-text-green:hover{color:#4CAF50!important}                                                                                                                                                                 "'_n 
	file write `book' `".w3-text-light-green,.w3-hover-text-light-green:hover{color:#8bc34a!important}                                                                                                                                                     "'_n 
	file write `book' `".w3-text-indigo,.w3-hover-text-indigo:hover{color:#3f51b5!important}                                                                                                                                                               "'_n 
	file write `book' `".w3-text-khaki,.w3-hover-text-khaki:hover{color:#b4aa50!important}                                                                                                                                                                 "'_n 
	file write `book' `".w3-text-lime,.w3-hover-text-lime:hover{color:#cddc39!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-orange,.w3-hover-text-orange:hover{color:#ff9800!important}                                                                                                                                                               "'_n 
	file write `book' `".w3-text-deep-orange,.w3-hover-text-deep-orange:hover{color:#ff5722!important}                                                                                                                                                     "'_n 
	file write `book' `".w3-text-pink,.w3-hover-text-pink:hover{color:#e91e63!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-purple,.w3-hover-text-purple:hover{color:#9c27b0!important}                                                                                                                                                               "'_n 
	file write `book' `".w3-text-deep-purple,.w3-hover-text-deep-purple:hover{color:#673ab7!important}                                                                                                                                                     "'_n 
	file write `book' `".w3-text-red,.w3-hover-text-red:hover{color:#f44336!important}                                                                                                                                                                     "'_n 
	file write `book' `".w3-text-sand,.w3-hover-text-sand:hover{color:#fdf5e6!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-teal,.w3-hover-text-teal:hover{color:#009688!important}                                                                                                                                                                   "'_n 
	file write `book' `".w3-text-yellow,.w3-hover-text-yellow:hover{color:#d2be0e!important}                                                                                                                                                               "'_n 
	file write `book' `".w3-text-white,.w3-hover-text-white:hover{color:#fff!important}                                                                                                                                                                    "'_n 
	file write `book' `".w3-text-black,.w3-hover-text-black:hover{color:#000!important}                                                                                                                                                                    "'_n 
	file write `book' `".w3-text-grey,.w3-hover-text-grey:hover,.w3-text-gray,.w3-hover-text-gray:hover{color:#757575!important}                                                                                                                           "'_n 
	file write `book' `".w3-text-light-grey,.w3-hover-text-light-grey:hover,.w3-text-light-gray,.w3-hover-text-light-gray:hover{color:#f1f1f1!important}                                                                                                   "'_n 
	file write `book' `".w3-text-dark-grey,.w3-hover-text-dark-grey:hover,.w3-text-dark-gray,.w3-hover-text-dark-gray:hover{color:#3a3a3a!important}                                                                                                       "'_n 
	file write `book' `".w3-border-amber,.w3-hover-border-amber:hover{border-color:#ffc107!important}                                                                                                                                                      "'_n 
	file write `book' `".w3-border-aqua,.w3-hover-border-aqua:hover{border-color:#00ffff!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-blue,.w3-hover-border-blue:hover{border-color:#2196F3!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-light-blue,.w3-hover-border-light-blue:hover{border-color:#87CEEB!important}                                                                                                                                            "'_n 
	file write `book' `".w3-border-brown,.w3-hover-border-brown:hover{border-color:#795548!important}                                                                                                                                                      "'_n 
	file write `book' `".w3-border-cyan,.w3-hover-border-cyan:hover{border-color:#00bcd4!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-blue-grey,.w3-hover-border-blue-grey:hover,.w3-border-blue-gray,.w3-hover-border-blue-gray:hover{border-color:#607d8b!important}                                                                                        "'_n 
	file write `book' `".w3-border-green,.w3-hover-border-green:hover{border-color:#4CAF50!important}                                                                                                                                                      "'_n 
	file write `book' `".w3-border-light-green,.w3-hover-border-light-green:hover{border-color:#8bc34a!important}                                                                                                                                          "'_n 
	file write `book' `".w3-border-indigo,.w3-hover-border-indigo:hover{border-color:#3f51b5!important}                                                                                                                                                    "'_n 
	file write `book' `".w3-border-khaki,.w3-hover-border-khaki:hover{border-color:#f0e68c!important}                                                                                                                                                      "'_n 
	file write `book' `".w3-border-lime,.w3-hover-border-lime:hover{border-color:#cddc39!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-orange,.w3-hover-border-orange:hover{border-color:#ff9800!important}                                                                                                                                                    "'_n 
	file write `book' `".w3-border-deep-orange,.w3-hover-border-deep-orange:hover{border-color:#ff5722!important}                                                                                                                                          "'_n 
	file write `book' `".w3-border-pink,.w3-hover-border-pink:hover{border-color:#e91e63!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-purple,.w3-hover-border-purple:hover{border-color:#9c27b0!important}                                                                                                                                                    "'_n 
	file write `book' `".w3-border-deep-purple,.w3-hover-border-deep-purple:hover{border-color:#673ab7!important}                                                                                                                                          "'_n 
	file write `book' `".w3-border-red,.w3-hover-border-red:hover{border-color:#f44336!important}                                                                                                                                                          "'_n 
	file write `book' `".w3-border-sand,.w3-hover-border-sand:hover{border-color:#fdf5e6!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-teal,.w3-hover-border-teal:hover{border-color:#009688!important}                                                                                                                                                        "'_n 
	file write `book' `".w3-border-yellow,.w3-hover-border-yellow:hover{border-color:#ffeb3b!important}                                                                                                                                                    "'_n 
	file write `book' `".w3-border-white,.w3-hover-border-white:hover{border-color:#fff!important}                                                                                                                                                         "'_n 
	file write `book' `".w3-border-black,.w3-hover-border-black:hover{border-color:#000!important}                                                                                                                                                         "'_n 
	file write `book' `".w3-border-grey,.w3-hover-border-grey:hover,.w3-border-gray,.w3-hover-border-gray:hover{border-color:#9e9e9e!important}                                                                                                            "'_n 
	file write `book' `".w3-border-light-grey,.w3-hover-border-light-grey:hover,.w3-border-light-gray,.w3-hover-border-light-gray:hover{border-color:#f1f1f1!important}                                                                                    "'_n 
	file write `book' `".w3-border-dark-grey,.w3-hover-border-dark-grey:hover,.w3-border-dark-gray,.w3-hover-border-dark-gray:hover{border-color:#616161!important}                                                                                        "'_n 
	file write `book' `".w3-border-pale-red,.w3-hover-border-pale-red:hover{border-color:#ffe7e7!important}.w3-border-pale-green,.w3-hover-border-pale-green:hover{border-color:#e7ffe7!important}                                                         "'_n 
	file write `book' `".w3-border-pale-yellow,.w3-hover-border-pale-yellow:hover{border-color:#ffffcc!important}.w3-border-pale-blue,.w3-hover-border-pale-blue:hover{border-color:#e7ffff!important}                                                     "'_n 
end

mata
void create_table(string scalar varname, real scalar num) {
	transmorphic matrix    tab
	transmorphic colvector vals  
	real         scalar    i,       mktab,   j
	real         colvector count
	string       matrix    labs
	string       colvector strvals
	string       scalar    labname, outname, output, format
	
	vals    = J(0,1,.)
	labs    = J(0,1,"")
	labname = J(1,1,"")
	
	labname = st_varvaluelabel(varname)

	if (labname != "") {
		st_vlload(labname,vals,labs)
	}
	
	if (strtoreal(st_local("tab"))) {
		tab = st_matrix(st_local("vals")) ,
		      st_matrix(st_local("freq"))
	}
	else {
		if (num) {
			tab = st_data(., varname           , st_local("v_mark")) , 
			      st_data(., st_local("v_freq"), st_local("v_mark"))
		}
		else {
			tab =            st_sdata(., varname           , st_local("v_mark")) ,
			      strofreal(  st_data(., st_local("v_freq"), st_local("v_mark")))
		}
	}
	
	if (labname== "") {
		if (num) {
			mktab = colsum(tab[.,1] :< . ) <= 10
		}
		else {
			mktab = colsum(tab[.,1] :!= "") <= 10
		}
	}
	else {
		if (num) {
			mktab = colsum(vals :< .)>0 | colsum(tab[.,1] :< .) <= 10
		}
		else {
			mktab = colsum(vals :!= "")>0 | colsum(tab[.,1]:!="") <= 10
		}
		
	}
	
	st_local("mktab", strofreal(mktab))
	if (num) {
		st_local("nvals", strofreal(colsum(tab[.,1] :< .)))
	}
	else {
		st_local("nvals", strofreal(colsum(tab[.,1] :!= "")))

	}
	
	if ( rows(vals) != 0 ) {
		vals = vals, J( rows(vals), 1, ( num ? 0 : "0" ) )
		vals = vals \ tab
	}
	else {
		vals = tab
	}
	
	j=0	

	if (mktab) {
		_sort(vals,(1,2))
		if (num) {
			format = st_varformat(varname)
			strvals = strofreal(vals)
			for (i=1 ; i <= rows(vals) ; i++) {
				strvals[i,1] = strtrim(sprintf(format,vals[i,1]))
			}
		}
		else {
			strvals = vals
		}
		count = strtoreal(strvals[.,2])
		for(i=1; i <= rows(strvals); i++) {
			strvals[i,2] = sprintf("%14.0gc",count[i,1])
		}
		for (i=1; i < rows(vals); i++) {
			if(vals[i,1] != vals[i+1,1]) {
				j= j + 1
				outname = "out" + strofreal(j)
				output = "<tr>"+  
						 "<td>" + strvals[i,1] + "</td>" + 
						 "<td>" + (labname=="" ? "" : st_vlmap(labname,vals[i,1])) + "</td>" + 
						 "<td>" + strvals[i,2] + "</td>" + 
						 "</tr>"
				st_local(outname,output)
				
			}
		}
		i = rows(vals)
		j = j + 1
		outname = "out" + strofreal(j)
		output = "<tr>"+  
				 "<td>" + strvals[i,1] + "</td>" + 
				 "<td>" + (labname=="" ? "" : st_vlmap(labname,vals[i,1])) + "</td>" + 
				 "<td>" + strvals[i,2] + "</td>" + 
				 "</tr>"
		st_local(outname,output)
		st_local("k", strofreal(j))
	}
	else {
		if (!num) {
			for(i=1; i<=10 ; i++) {
				outname = "out" + strofreal(i)
				output = "<tr><td>" + tab[i,1] + "</td></tr>"
				st_local(outname,output)
			}
		}
	}
	
}
end
