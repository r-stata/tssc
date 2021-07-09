*! version 3.1.0 MLB 29May2019
*  change <p> to <br> for output of -log html-
*  add the dir() option
version 14

program define pres2html
	local olddir = c(pwd)
	capture noisily pres2html_main `0'
	if _rc {
		qui cd `"`olddir'"'
		file close _all
		exit _rc
	}
end

program define pres2html_main
	syntax using/ , [replace dir(passthru)]

	Parsedirs using `using' , `dir'

	local olddir    = s(odir)
	local sourcedir = s(sdir)
	local stub      = s(stub)
	local ddir      = s(ddir)

	qui cd "`sourcedir'"
	
	// initialize the html file
	tempname tofill appendix
	tempfile appfile
	file open `tofill' using `"`ddir'/`stub'.html"', write `replace'
	Htmlinit, file(`tofill')

	file open `appendix'  using `appfile', write replace
	
	// find the slides
	tempname base
	file open `base' using `stub'.smcl, read
	
	file read `base' line
	while r(eof) == 0 {
		gettoken first rest : line
		gettoken second rest : rest
		if `"`first'"' == "{*" & `"`second'"' == "slides" {
			gettoken slides rest: rest, parse("}")
		}
		if `"`first'"' == "{*" & `"`second'"' == "bottomstyle" {
			gettoken bottomstyle rest : rest, parse("}")
		}
		file read `base' line
	}
	file close `base'
	if `"`slides'"' == "" {
		di as err "{p}`using' does not contain a list of slides{p_end}"
		exit 198
	}
	
	local appnumber = 0
	foreach slide of local slides {
		Slide2html using `slide', tofill(`tofill') bottomstyle(`bottomstyle') ///
		     app(`appendix') appnumber(`appnumber') ddir(`ddir') `replace'
	}
	
	file close `appendix'
	if `appnumber' {
		Fileappend, file(`appfile') appendto(`tofill')	
	}
	file write `tofill' "</body>" _n "</html>" _n
	file close `tofill'
	qui cd "`olddir'"

	display as txt `"To see the handout click {browse "`ddir'`c(dirsep)'`stub'.html":here}"'
end

program define Slide2html	
	syntax using/, tofill(string) bottomstyle(string) app(string) appnumber(integer) ddir(string) [replace]
	
	file write `tofill' `"<div class="slide" id="`using'">"' _n
	file write `tofill' `"<div class="txt">"'
	
	tempname base temp
	tempfile tempsmcl temphtml temphtml2
	
	file open `base' using `using', read
	file open `temp' using `tempsmcl', write

	
	local ignore = 0
	local ignorel = 0
	
	file read `base' line
	while r(eof) == 0 {
		gettoken first rest : line
		gettoken second rest : rest
		if `"`first'"' == "{*"  & `"`second'"' == "ex" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			file write `tofill' "</div>"
			gettoken rest : rest, parse("}")
			Dohtml using `rest', gen(`temphtml') replace
			Fileappend, file(`temphtml') appendto(`tofill')
			local ignore = 1
		}
		if `"`first'"' == "{*"  & `"`second'"' == "dofile" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			file write `tofill' `"</div>"'
			gettoken rest : rest, parse("}")
			Dohtml using `rest', gen(`temphtml') replace
			Fileappend, file(`temphtml') appendto(`tofill')
			file write `tofill' `"<div class="txt">"'
			file open `temp' using `tempsmcl', write replace
			local ignorel = 1
		}
		if `"`first'"' == "{*"  & `"`second'"' == "apdofile" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			gettoken rest : rest, parse("}")
			gettoken dofilesource rest : rest
			file write `tofill' `"<pre><a href="#app`appnumber'">`rest'</a></pre>"'_n
			Dohtml using `dofilesource', gen(`temphtml') replace
			file write `app' `"<div class="slide" id="app`appnumber'">"'_n
			file write `app' `"<pre><p align="center"><b>`rest'</b></p></pre><br><br>"'_n
			Fileappend, file(`temphtml') appendto(`app')
			local hline : display _dup(79) "-"
			file write `app' `"<div class="txt">"'
			file write `app' "</p><pre>`hline'</pre>"_n
			file write `app' `"<pre><p align=center><a href="#`using'">&lt;&lt;</a></p></pre>"'_n
			file write `app' "<pre>`hline'</pre>"_n
			file write `app' "</div>"
			file write `app' "</div>"
			c_local appnumber = `appnumber' + 1
			file open `temp' using `tempsmcl', write replace
		}
		if `"`first'"' == "{*"  & `"`second'"' == "codefile" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			file write `tofill' `"</div>"'
			gettoken rest : rest, parse("}")
			file write `tofill' `"<pre class="code">"'_n
			tempname codefile
			file open `codefile' using `rest', read
			file read `codefile' cline
			while r(eof) == 0 {
				local cline : subinstr local cline ">" "&gt;", all
				local cline : subinstr local cline "<" "&lt;", all
				file write `tofill' `"<code>`macval(cline)'</code>"'_n
				file read `codefile' cline
			}
			file close `codefile'
			file write `tofill' "</pre>"_n
			file write `tofill' `"<div class="txt">"'
			file open `temp' using `tempsmcl', write replace
			local ignorel = 1
		}		
		if `"`first'"' == "{*"  & `"`second'"' == "apcodefile" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			gettoken rest : rest, parse("}")
			gettoken codefilesource rest : rest
			file write `tofill' `"<pre><a href="#app`appnumber'">`rest'</a></pre>"'_n
			file write `app' `"<div class="slide" id="app`appnumber'">"'_n
			file write `app' `"<pre><p align="center"><b>`rest'</b></p></pre><br><br>"'_n
			file write `app' `"<pre class="code">"'_n
			tempname codefile
			file open `codefile' using `codefilesource', read
			file read `codefile' cline
			while r(eof) == 0 {
				local cline : subinstr local cline ">" "&gt;", all
				local cline : subinstr local cline "<" "&lt;", all
				file write `app' `"<code>`macval(cline)'</code>"'_n
				file read `codefile' cline
			}
			file close `codefile'
			file write `app' "</pre>"_n
			local hline : display _dup(79) "-"
			file write `app' `"<div class="txt">"'
			file write `app' "</p><pre>`hline'</pre>"_n
			file write `app' `"<pre><p align=center><a href="#`using'">&lt;&lt;</a></p></pre>"'_n
			file write `app' "<pre>`hline'</pre>"_n
			file write `app' "</div>"
			file write `app' "</div>"			
			c_local appnumber = `appnumber' + 1
			file open `temp' using `tempsmcl', write replace
		}		
		else if `"`first'"' == "{*" & `"`second'"' == "ho_ignore" {
			// do nothing
		}
		else if `"`first'"' == "{*" & `"`second'"' == "endex" {
			local ignore = 0
			file write `tofill' `"<div class="txt">"'
			file open `temp' using `tempsmcl', write replace
		}
		else if `"`first'"' == "{*" & `"`second'"' == "graph" {
			gettoken graphs : rest, parse("}")
			foreach graph of local graphs {
				graph export `"`ddir'/`graph'.png"', name(`graph') width(630) `replace'
				file write `tofill' `"<img src="`graph'.png" width="630">"' _n
			}
		}
		else if `"`first'"' == "{*" & `"`second'"' == "bottombar" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			Parsebottom , line(`line') tofill(`tofill') bottomstyle(`bottomstyle')
			file open `temp' using `tempsmcl', write replace
		}
		else if `"`first'"' == "{*" & `"`second'"' == "/p" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			local hline : display _dup(79) "-"
			file write `tofill' "</p><pre>`hline'</pre>"_n
			file open `temp' using `tempsmcl', write replace
		}
		else if ustrpos(`"`macval(line)'"', "{* digr") {
			local k = ustrpos(`"`macval(line)'"', "{* digr")
			Matchingclose, line(`"`macval(line)'"') startnum(`k')
			local i = r(close)
			local j = ustrpos(`"`macval(line)'"', "{* /digr")
			local towrite   usubstr(`"`macval(line)'"',1,`=`k'-1') + ///
			                "*digrlink*" + ///
			                usubstr(`"`macval(line)'"',`=`j'+10',.)
			local towrite = `towrite'
			file write `temp' `"`macval(towrite)'"' _n
			local digrlink = usubstr(`"`macval(line)'"', `=`k' + 8', `=`i'-`k'-8') 
		}
		else if `"`first'"' == "{*" & `"`second'"' == "tocline" {
			file close `temp'
			qui log html `tempsmcl' `temphtml', replace yebf whbf
			qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
			qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
			Fileappend, file(`temphtml') appendto(`tofill')
			Parsetoc, line(`"`macval(line)'"') tofill("`tofill'")
			file open `temp' using `tempsmcl', write replace
		}
		else if !`ignore' & !`ignorel' {
			file write `temp' `"`macval(line)'"' _n
		}
		else {
			local ignorel = 0
		}

		file read `base' line
	}
	file close `temp'
	qui log html `tempsmcl' `temphtml', replace yebf whbf
	qui filefilter `temphtml' `temphtml2', from("*digrlink*") to(`"`digrlink'"') replace
	qui filefilter `temphtml2' `temphtml', from("<p>") to("<br>") replace
	Fileappend, file(`temphtml') appendto(`tofill')	

	file close `base'
	
	file write `tofill' `"</div>"' _n
	file write `tofill' `"</div>"' _n
end

program define Dohtml
	syntax using/, [replace] gen(string)

	// this will also be the name of the .html file that will be created
	capture confirm new file `gen'
	if _rc & "`replace'" == "" {
		di as err "file `gen' already exists"
		exit 602 
	}

	tempfile log html1 html2
	tempname logname
	
	// do the example and store the output in a log file	
	local ls = c(linesize)
	set linesize 79
	qui log using `log', replace name(`logname')
	do `using' , nostop
	qui log close `logname'
	set linesize `ls'
	
	// turn the log file in an .html file
	qui log html `log' `html1', replace yebf whbf

	// remove the "end of do-file" message
	qui filefilter `html1' `html2',              /// 
		from("<b>. </b>\nend of do-file\n")      ///
		to(`""')

	// remove log close message
	qui filefilter `html2' `html1',              ///
		from("- qui log close")              ///
		to("") replace
		
	// remove the "do foo.do" message (where "foo" is the file name stored in `file')
	qui filefilter `html1' `html2',              ///
		from("<p>\n<b>. do `using'</b>\n<p>\n")  ///
            to("") replace
	
	// change <p> to <br>
	qui filefilter `html2' `html1', from("<p>") to("<br>") replace
	
	// change to output class of <pre>
	qui filefilter `html1' `gen' ,               ///  
		from("<pre>")                            ///
		to(`"<pre class="output">"') `replace'
end

program define Fileappend
	syntax, file(string) appendto(string)
	tempname toappend 
	file open `toappend' using `file', read
	file read `toappend' line 
	while r(eof) == 0 {
		file write `appendto' `"`macval(line)'"' _n	
		file read `toappend' line
	}
end

program define Htmlinit
	syntax, file(string)
	file write `file' "<!DOCTYPE html>" _n
	file write `file' "<html>" _n
	file write `file' "<head>" _n
	file write `file' "<style>" _n
	file write `file' "body {" _n
	file write `file' "	   background-color: white;" _n
	file write `file' "}" _n
	file write `file' "pre.output {" _n
   	file write `file' "    border-left-style: solid;" _n
	file write `file' "    width: 650px;" _n	
	file write `file' "    max-height: 500px;" _n		
	file write `file' "    overflow: auto;" _n		
	file write `file' "    border-left-color:grey;" _n
	file write `file' "    border-width: 5px;" _n
	file write `file' "    background-color: #f0f0f0;" _n
	file write `file' "    padding: 0px 5px 0px 10px;" _n
	file write `file' "    margin: 0px auto 0px auto;" _n
	file write `file' "}" _n
	file write `file' "pre.code {" _n
   	file write `file' "    border-left-style: solid;" _n
	file write `file' "    width: 650px;" _n	
	file write `file' "    max-height: 500px;" _n	
	file write `file' "    overflow: auto;" _n	
	file write `file' "    border-left-color:grey;" _n
	file write `file' "    border-width: 5px;" _n
	file write `file' "    background-color: #f0f0f0;" _n
	file write `file' "    padding: 0px 5px 0px 10px;" _n
	file write `file' "    margin: 0px auto 0px auto;" _n
	file write `file' "}" _n
	file write `file' "pre.code:before {" _n
	file write `file' "    counter-reset: listing;" _n
	file write `file' "}" _n
	file write `file' "pre.code code {" _n
	file write `file' "  counter-increment: listing;" _n
	file write `file' "}" _n
	file write `file' "pre.code code::before {" _n
	file write `file' `"  content: counter(listing) ". ";"' _n
	file write `file' "  display: inline-block;" _n
	file write `file' "  width: 35px;" _n         
	file write `file' "  padding-left: auto;" _n 
	file write `file' "  margin-left: auto;" _n  
	file write `file' "  text-align: right;" _n  
	file write `file' "}" _n
	file write `file' "pre {" _n
    file write `file' "    margin: 0px;" _n
    file write `file' "}" _n
	file write `file' "div.slide { "_n
	file write `file' "    max-width: 680px;" _n	
    file write `file' "    display: block;" _n
	file write `file' "    padding: 5px;"_n
	file write `file' "    margin: 10px auto 10px auto;" _n
	file write `file' "    border-style: solid;" _n
	file write `file' "    border-width: 1px;" _n
	file write `file' "    background-color: white ;" _n
	file write `file' "}"_n
	file write `file' "div.txt { " _n
	file write `file' "    margin: 0px auto 0px auto;" _n
	file write `file' "    max-width: 650px;" _n
	file write `file' "}"_n
	file write `file' "div.flex-container {"_n
	file write `file' "    display: flex;"_n
	file write `file' "    justify-content: space-around;"_n
	file write `file' "}"_n
	file write `file' "p.bottom {"_n
    file write `file' "    display: block;"_n
    file write `file' "    margin: 0px;"_n
    file write `file' "    text-align:center;"_n
    file write `file' "}"_n
	file write `file' "</style>" _n
	file write `file' "</head>" _n
	file write `file' "<body>" _n
end

program define Parsebottom 
	syntax, line(string) tofill(string) bottomstyle(string)
	
	if "`bottomstyle'" == "arrow" {
		local line = usubinstr(`"`line'"',"{* bottombar }", "", 1)
		local line = usubinstr(`"`line'"',"{center:", `"<p class="bottom">"', 1)
		local line = usubinstr(`"`line'"', "{view ", `"<a href="#"', 3)
		local line = usubinstr(`"`line'"', ":", `"">"',3)
		local line = usubinstr(`"`line'"', "<<", "&lt;&lt;", 1)
		local line = usubinstr(`"`line'"', ">>>", ">&gt;&gt;", 1)
		local k= 1
		local i = 1
		local j = 0
		while `i' != 0 {
			local i = ustrpos(`"`line'"', "}", `k') 
			local k = `i' + (`i' != 0)
			local j = `j' + (`i'!= 0)
		}
		local line = usubinstr(`"`line'"', "}", "</a>", `j')
		local line `"<pre>`line'</pre>"'
	}
	else {
		local line = usubinstr(`"`line'"', "{* bottombar }", `"<div class="flex-container">"', 1)
		local line = usubinstr(`"`line'"', "{view ", `"<div><a href="#"', 2)
		local line = usubinstr(`"`line'"', "{right:", "", 1)
		local line = usubinstr(`"`line'"', ":", `"">"',2)
		local line = usubinstr(`"`line'"', "}}", `"</a></div>"',1)
		local line = usubinstr(`"`line'"', "}", `"</a></div>"',1)
		local line = `"`line'"' + "</div>"
	}
	file write `tofill' `"`line'"' _n
end

program define Parsetoc
syntax, line(string) tofill(string)
	local i = ustrpos(`"`macval(line)'"', "{view ")
	if `i' == 0 {
		Smcl2html, line(`"`macval(line)'"') tofill(`"`tofill'"')
	}
	else {
		local t = usubstr(`"`macval(line)'"', `i', .)
		gettoken view t : t
		gettoken link : t
		Matchingclose, line(`"`macval(line)'"') startnum(`i')
		local t = usubstr(`"`macval(line)'"', 1, `=`i'-1') + " ***a " + ///
				  usubstr(`"`macval(line)'"', `i', `=`r(close)'-`i'') + " ***/a " + ///
				  usubstr(`"`macval(line)'"', `r(close)', .)
		Smcl2html, line(`"`macval(t)'"') link(`"`link'"') tofill(`"`tofill'"')
	}
end

program define Smcl2html,
	syntax, line(string) [link(string)] tofill(string)
	tempfile smcl html html2
	tempname file
	file open `file' using `smcl', write
	file write `file' `"`line'"' _n
	file close `file'
	qui log html `smcl' `html', replace yebf whbf
	qui filefilter `html' `html2', from("<p>") to("<br>") replace
	file open `file' using `html2', read
	file read `file' line 
	while r(eof) == 0 {
		if "`link'" != "" {
			local line : subinstr local line " ***a " `"<a href="#`link'">"'
			local line : subinstr local line " ***/a " "</a>"
			local line : subinstr local line " ***/a" "</a>"
			local line : subinstr local line "***/a " "</a>"
			local line : subinstr local line "***/a" "</a>"
		}
		file write `tofill' `"`macval(line)'"' _n
		file read `file' line
	}
	file close `file'
end
		
program define Matchingclose, rclass
	syntax, line(string) startnum(integer)
	local i = `startnum'+1 // startnum is the position of the open brace, 
	                       // so you start looking at the next postion
	local open = 0
	local continue = 1
	while `continue' {
		local j = ustrpos(`"`macval(line)'"', "}", `i')
		local k = ustrpos(`"`macval(line)'"', "{", `i')
		if `k' < `j' & `k' > 0  & `j' > 0{
			local open = `open' + 1
			local i = `k'+1
		}
		else if (`j' < `k' | `k' == 0 & `open' == 0) & `j' > 0 {
			if `open' > 0 {
				local open = `open' - 1
				local i = `j' + 1
			}
			else {
				local continue = 0
			}
		}
		else {
			 di as err "no matching brace found"
			 exit 198
		}
	} 	
	return scalar close = `j'
end

program define Parsedirs, sclass
	syntax using/, [dir(string)]
	local stub : subinstr local using "\" "/", all
	while `"`stub'"' != "" {
		local path `path'`path2'
		gettoken path2 stub : stub, parse("/\:")
	}
	local stub `path2'
	gettoken stub suffix : stub, parse(".")
	local odir = c(pwd)
	quietly {
		cd `path'
		local sdir = c(pwd)
		if `"`dir'"' != "" {
			cd `"`odir'"'
			cd `"`dir'"'
			local ddir = c(pwd)
		}
		if ("`odir'" != "`sdir'") & (`"ddir"' == "") {
			local ddir = `"`odir'"'
		}
		cd `"`odir'"'
	}
	sreturn local stub `"`stub'"'
	sreturn local odir `"`odir'"'
	sreturn local sdir `"`sdir'"'
	sreturn local ddir `"`ddir'"'
end
