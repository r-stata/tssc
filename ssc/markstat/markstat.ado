program define markstat
version 14
*! v 2.5 <grodri@princeton.edu> 26oct2016 rev 9dec2019
	capture noisily _markstat `0'
	if _rc > 0 _closeAllFiles
end

program _markstat
	syntax using/ [, pdf docx slides SLIDES2(string) beamer BEAMER2(string) ///
		         markdown mathjax bundle BIBliography strict ///
				 noDO noR keep KEEP2(string) plain ]

	// input script	
	mata splitPath(`"`using'"') // sets macros
	if "`isurl'" != "" {
		display as error "input must be a local file, not a url"
		display as error "consider using {bf}copy{sf} first"
		exit 632
	}
	if "`suffix'" != "" & "`suffix'" != ".stmd" {
		display as error "file suffix must be .stmd or blank"
		exit 198
	}
	mata st_local("filename", pathjoin("`folder'", "`file'"))
	confirm file "`filename'.stmd"	
	
	// output format
	local formats "`pdf' `slides'`slides2' `beamer'`beamer2' `docx' `markdown'"
	local nformats : word count `formats'
	if `nformats' > 1 {
		display as error "specify at most one of pdf, docx, slides, or beamer"
		exit 198
	}
	local format html
	if `nformats' > 0 local format = strtrim("`formats'")
	if "`pdf'" == "pdf" local format latex
	
	// slide themes
	foreach option in slides beamer {
		if "``option''``option'2'" != "" {
			local format `option'
			if "``option'2'" != "" {
				if strpos("``option'2'", "+") > 0 {
					local incremental incremental
					local `option'2 = strtrim(subinstr("``option'2'", "+", "", .))
				}
				if "``option'2'" != "" local theme ``option'2'
			}
		}
	}
	if "`format'" == "slides" local format s5		
		
	// syntax
	if "`strict'" == ""{
		mata: st_local("strict", isStrict("`filename'") ? "strict" : "")
	}	
	
	// tangle	
	mata tangle(`"`filename'"', "`format'", "`strict'" == "strict")
	
	// stata
	if "`do'" != "nodo" {
		do `"`filename'"'
	}
	confirm file "`filename'.smcl"

	// R
	if "`runr'" == "runr" {
		if "`r'" != "nor" {
			di "{bf}Running R{sf}"
			_runr "`filename'"
		}
		confirm file "`filename'.rout"
	}
	
	// pandoc
	local skip = "`format'" == "docx" | "`format'" == "markdown"
	if `skip' {
		quietly copy "`filename'.md" "`filename'.pdx", replace
	}
	else {
		if "`theme'" != "" local optionaltheme theme(`theme')	
		local options format(`format') `optionaltheme' `incremental' `bibliography' `mathjax' `bundle' 
		di "{bf}Running Pandoc{sf}"
		_pandoc using "`filename'", `options'
	}
		
	// weave
	mata weave(`"`filename'"', "`format'", "`plain'" == "plain")
	
	// docx
	if "`format'" == "docx" {
		di "{bf}Running Pandoc{sf}"
		_pandoc using "`filename'", format(docx) `bibliography'
	}
		
	// pdflatex	
	local tex = inlist("`format'", "latex", "beamer")
	if `tex' {
		di "{bf}Running Latex{sf}"
		whereis pdflatex
		local cmd `""`r(pdflatex)'" "`file'.tex""' 
		if "`folder'" != "" {
			mata st_local("folder", usubinstr("`folder'", "\", "/",. ))
			local cmd `"`cmd' -output-directory="`folder'" "'
		}
		shell `cmd'
		confirm file "`filename'.pdf"
	}
	
	// view	
	if "`format'" != "markdown" {
		local outex html
		if `tex' local outex pdf
		if "`format'" == "docx" local outex docx
		view browse "`filename'.`outex'"
	}
	else display `"generated Markdown file "`filename'.md" "'

	// cleanup
	if "`keep'" == "keep" exit
	if "`format'" == "markdown" local keep2 md `keep2'
	mata: cleanup("`filename'", "`keep2'")
end
program _closeAllFiles
	forvalues i = 0(1)12 {
		capture mata: fclose(`i')
	}
end
program _pandoc
* interface to Pandoc to convert Markdown to html, latex or docx
    syntax using/ [, format(string) theme(string) incremental BIBliography mathjax bundle]
	local filename `using'
	whereis pandoc
	local pandoc = r(pandoc)
	if "`bibliography'" == "bibliography" {
		local args --filter "pandoc-citeproc"
		if c(os) == "MacOSX" { // include path in Mac (same as pandoc)
			local args = subinstr(`"`args'"', "pandoc", "`pandoc'", .)
		}
	}
	// format and theme
	local args `args' -f markdown -t `format'
	if "`format'" == "beamer" & "`theme'" != "" {
		local args `args' -V theme=`theme'
	}
	if "`format'" == "s5" {		
	    if "`theme'" == "" local theme default
		mata: unzipS5() // ensure installed
		mata: st_local("s5", getFolder(findFile("s5/`theme'/slides.css")))
		confirm file "`s5'/slides.js"
		local args `args' -V s5-url="`s5'"
	}
	// incremental
	if "`incremental'" == "incremental" {
		local args `args' -i
	}
	// mathjax and bundle
	if "`mathjax'" == "mathjax" local mj --mathjax
	if "`bundle'" == "bundle" & inlist("`format'", "html", "s5") {
		local args `args' --self-contained
		if "`mj'" != "" {
			whereis(mathjax)
			local mj `mj'="`r(mathjax)'"
		}
	}
	local args `args' `mj'

	// docx with custom template
	if "`format'" == "docx" {
		mata: st_local("docx", findFile("markstat.docx"))
		confirm file "`docx'"
		local args `args' --reference-doc="`docx'"	
	}
	
	// pandoc
	local outex pdx
	if "`format'" == "docx" local outex docx
	capture erase "`filename'.`outex'"
	local cmd `""`pandoc'" "`filename'.md" `args' -s -o "`filename'.`outex'""'
	shell `cmd'
	confirm file "`filename'.`outex'"
end
program _runr
* run R
	args filename
	whereis R
	capture erase "`filename'.err"
	local cmd `" "`r(R)'" --vanilla < "`filename'.R" > "`filename'.rout" 2> "`filename'.err" "'		
	shell `cmd'
	mata: checkRout("`filename'")
end

mata:

// ---------------------------------------------------------------------------
//  Tangling
// ----------

void tangle(string scalar filename, string scalar format, real scalar strict) {
 // split stmd file into md, do and R files with strict or relaxed syntax
	real scalar fh, dofile, mdfile, chunk, echo, mata, tex, rfile, rchunk, codefile
	string scalar mode, line, tag, closer, code, placeholder, match, prefix, args, lang
    tex = format == "latex" | format == "beamer"
	
	// open files
	fh = fopen(filename + ".stmd", "r")
	mdfile = fopenwr(filename + ".md")
	dofile = fopenwr(filename + ".do")	
	rfile = -1 // on demand
	
	// start do file with log
	fput(dofile, "capture log close")
	fput(dofile, `"log using ""' + filename + `"", smcl replace"')
	
	// read all lines
	chunk = 0
	rchunk = 0
	mode = "markdown"
	while( (line = fget(fh)) != J(0, 0, "")) {
		line = usubinstr(line, uchar(9), "    ", .)

		// Markdown
		if(mode == "markdown") {
		
			// stata/mata/R code block?
			if(startsStata(line, strict, echo = 1, lang = "")) {
				mode = "stata"
				mata = lang == "m"
				// consolidate some?
				if(lang == "s" | lang == "m") {					
					chunk++				
					// placeholder (as in 1.6.1)
					tag = strofreal(chunk)
					fput(mdfile, "")
					fput(mdfile, "{{" + tag + "}}")
					fput(mdfile, "")
					// start block
					if(echo == 0) tag = tag + "q"
					if(mata) tag = tag + "m"
					fput(dofile, "//_" + tag)
					if(mata) fput(dofile, "mata:")
					if(!strict) fput(dofile, usubstr(line, 5, .))
				} 
				else { // R
					rchunk++
					if(rchunk == 1) rfile = fopenwr(filename + ".R")
					// placeholder (as in 1.6.1)
					tag = strofreal(rchunk)
					fput(mdfile, "")
					fput(mdfile, "{{r" + tag + "}}")
					fput(mdfile, "")
					// start block
					if(echo == 0) tag = tag + "q"					
					fput(rfile, "#_" + tag)
				}
			}

			// verbatim or math block?
			else if(startsBlock(line)) {
				mode = "block"
				closer = blockCloser(line)				
				fput(mdfile, line)
			}
			
			else {			
				// stata/mata/r inline code?
				while(hasInlineCode(line, code = "", prefix = "")) {
					if(prefix == "s" | prefix == "m") {
						chunk++
						tag = strofreal(chunk)
						fput(dofile, "//_" + tag)
						// mata
						if(prefix == "m") {
							if(startsWith(ustrtrim(code), "%")) {
								args = `"""' + usubinstr(code, " ", `"", "', 1)
							}
							else {
								args = `""%f", "' + code
							}
							fput(dofile, "mata: printf(" + args + ")")
						}
						// stata
						else {
							fput(dofile, "display " + code)
						}
						placeholder = "{{." + tag + "}}"
					}
					else { // R
						rchunk++
						if(rchunk == 1) rfile = fopenwr(filename + ".R")
						tag = strofreal(rchunk)
						fput(rfile, "#_" + tag)
						fput(rfile, code)
						placeholder = "{{r." + tag + "}}"
					}
					match = "`" + prefix + " " + code + "`" 
					line = usubinstr(line, match, placeholder, 1)					
				}
				// code extension/underline
				if(tex) tag2tex(line)
				else if (format == "docx") handleUnderline(line)
				// markdown
				fput(mdfile, line)
			}
		}

		// Code Fences or Display Math
		else if (mode == "block") {
			fput(mdfile, line)
			if(endsBlock(line, closer)) {
				mode = "markdown"				
			}
		}
		
		// Stata
		else {			
			if(endsStata(line, strict)) {
				mode = "markdown"
				if(mata) fput(dofile, "end")
				if(!strict) fput(mdfile, line)
			}
			else {
				if(isIndented(line)) line = usubstr(line, 5, .)
				codefile = lang == "r" ? rfile : dofile
				fput(codefile, line)
			}
		}
	}
	// close files
	fclose(fh)	
	fclose(mdfile)		
	fput(dofile, "//_^")	
	fput(dofile, "log close")
	fclose(dofile)
	if (rfile > -1) {		
		fput(rfile, "#_^")
		fclose(rfile)
		st_local("runr", "runr")
	}	
}
real scalar isIndented(string scalar line) {
 // line starts with four spaces after detab
	if(ustrtrim(line) == "") return(0)
	return(startsWith(line, "    "))
}
real scalar startsStata(string scalar line, real scalar strict, 
	real scalar echo, string scalar lang) {
 // line starts Stata code using strict or relaxed syntax, or R code
	string scalar next
	real scalar slash
	echo = 1
	lang = "s"
	if(!strict) {
		return(isIndented(line))
	}
	else { 
		// ```s/ or ```m/ or ```r/ for no echo		
		if(!startsWith(line, "```")) return(0)
		next = ustrtrim(usubstr(line, 4, .))
		if (ustrregexm(next, "^\{(.+)\}$") > 0) next = ustrregexs(1)
		slash = usubstr(next, ustrlen(next), 1) == "/"
		if(slash) next = usubstr(next, 1, ustrlen(next) - 1)
		match = ustrregexm(next,"^[smr]$") | next == "stata" | next == "mata"
		if(!match) return(0)
		if(slash) echo = 0
		lang = usubstr(next, 1, 1)
		return(1)
	}					
}
real scalar endsStata(string scalar line, real scalar strict) {
 // line ends Stata code using relaxed or strict syntax
	if(!strict) {
		return(!isIndented(line))
	}
	else {
		return(startsWith(line, "```"))
	}
}
real scalar startsBlock(string scalar line) {
 // line is a code fence or display math opener
	if(ustrtrim(line) == "$$") return(1)
	return(startsWith(line, "```") || startsWith(line, "~~~"))
}
string scalar blockCloser(string scalar line) {
 // dollars or code fence with at least as many backticks/tildes as opener
	string scalar trimmed, tick
	real scalar n
	trimmed = ustrtrim(line)
	if(usubstr(trimmed, 1, 2) == "$$") return("$$")
	tick = usubstr(trimmed, 1, 1)
	n = indexnot(trimmed, tick) - 1
	if(n < 1) n = ustrlen(trimmed)
	return(n * tick)
}	
real scalar endsBlock(string scalar line, string scalar closer) {
 // line starts with current block closer
	return(startsWith(line, closer))
}
real scalar hasInlineCode(string scalar line, string scalar match, string scalar prefix) {
 // non-greedy regex for inline code
	real scalar r, pos, ns, i
	real vector stack
	string scalar pattern, shorter, here

	// greedy match
	pattern = "`([smr]) (.+)`"
	r = ustrregexm(line, pattern)
	if(r <= 0) return(0)
	prefix = ustrregexs(1)
	match  = ustrregexs(2)
	pos = ustrpos(match, "`")
	if(pos < 1) return(1)
	
	// less greedy
	r = ustrregexm(match, "`[smr] ")
	if(r > 0) {
		pos = ustrpos(match, ustrregexs(0))
		shorter = "`" + prefix + " " + usubstr(match, 1, pos - 1)
		r = ustrregexm(shorter, pattern)
		if (r < 1) return(0)
		match = ustrregexs(2)
		pos = ustrpos(match, "`")
		if(pos < 1) return(1)
	}
	
	// allow pairs
	stack = J(24, 1, 0)
	ns = 0
	for(i = 1; i <= ustrlen(match); i++) {
		here = usubstr(match, i, 1)
		if(here == "`") {				
			stack[++ns] = i // push
		}
		else if (here == "'" && ns > 0) {
			ns-- // pop
		}
	}
	if(ns > 0) {
		pos = stack[1]
		match = substr(match, 1, pos - 1)
	}
	return(1)		
}
void tag2tex(string scalar line) {
 // translate code,  underline and italics tags to LaTeX when non-verbatim
	string vector tags, tex
	string scalar left
	real scalar i, w, pos, bot, ignore	
	tags = "<code>", "</code>", "<u>", "</u>", "<i>", "</i>"
	tex  = "\texttt{", "}", "\underline{", "}", "\emph{", "}"
	for(i = 1; i <= 6; i++) {
		w = ustrlen(tags[i])
		pos = 1
		while( (bot = ustrpos(line, tags[i], pos)) > 0) {	
			ignore = 0
			if (bot > 1 & bot + w < ustrlen(line)) {
				ignore = usubstr(line, bot - 1, 1) == "`" & usubstr(line, bot + w, 1) == "`"
			}
			if(!ignore) {
				left = bot > 1 ? usubstr(line, 1, bot - 1) : ""
				line = left + tex[i] + usubstr(line, bot + w, .)
			}
			pos = bot + w
		}
	}
}
void handleUnderline(string scalar line) {
 // use custom-style for underline
	string scalar regex, cstyle
	regex = "<[uU]>([^<]+)<\/[uU]>"
	while( ustrregexm(line, regex) > 0) {
		cstyle = "[" + ustrregexs(1) + `"]{custom-style="Underline"}"'
		line = usubinstr(line, ustrregexs(0), cstyle, 1)
	}
}
real scalar isStrict(string scalar filename) {
 // scans head of file to see if code fences are used
    real scalar fh, result, n, echo
	string scalar EOF, line, state, closer, lang
	result = 0
	n=0	
	closer = ""
	EOF = J(0, 0, "")	
	fh = fopen(filename + ".stmd", "r")
	state = "looking"
	while( (line = fget(fh)) != EOF & n < 50) {
		if(state == "inblock") {
			if(endsBlock(line, closer)) {
				state = "looking"
			}
		}
		else { 
			if (startsBlock(line)) {
				if(startsStata(line, 1, echo=0, lang="")) {
					result = 1
					break
				}
				else {
					state = "inblock"
					closer = blockCloser(line)
				}
			}
		}
		n++
	}
	fclose(fh)
	return(result)
}

// ---------------------------------------------------------------------------
//  Weaving
// ---------

void weave(string scalar filename, string scalar format, real scalar plain) {
 // weave stata, R and markdown output into html, latex or markdown file

	real scalar outfile, infile, n, tex, md
	real vector markers, rmarkers
	string scalar outext, line, blockhold, inlinehold, logline, includefile, w, prefix 
	string vector lines, rlines, words
 
	// output file
	tex = format == "latex" | format == "beamer"
	md  = format == "docx"  | format == "markdown"
	outext = tex ? ".tex" : (md ? ".md" : ".html")
	outfile = fopenwr(filename + outext)
	
	// get translated smcl
	lines = translateLog(filename, format, plain)
	markers = select(1::length(lines), ustrregexm(lines, "[.|:]\s+//_") :> 0)
	rlines = J(0, 1, "")
	
	// open Pandoc output 
	infile = fopen(filename + ".pdx", "r")	
	if(tex) { 
		while( (line = fget(infile)) != J(0, 0, "")) {
			fput(outfile, line)
			if(startsWith(line, "\usepackage{")) {
				fput(outfile, "\usepackage{stata}")
				break
			}
		}
	}

	// code placeholders and handlers
	blockhold  = "\{\{(r?)([0-9]+)\}\}"
	inlinehold = "\{\{(r?)\.([0-9]+)\}\}"				
	if(tex) {
		blockhold  = usubinstr(blockhold, "\", "\\\", .)
		inlinehold = usubinstr(inlinehold, "\{", "\\\{", .)
		inlinehold = usubinstr(inlinehold, "\}", "\\\}", .)
	}
	else if (!md) {
		blockhold = "<p>" + blockhold + "</p>"
	}
	// process pdx file
	n = 0
	while( (line = fget(infile)) != J(0, 0, "") ) {
		
		// handle code block (number is second capture)
		if(ustrregexm(line, blockhold) > 0) {
			n = strtoreal(ustrregexs(2))
			if(ustrregexs(1) == "") { // stata
				renderLog(outfile, format, lines, markers[n], markers[n + 1] - 1, "stata")
			}
			else { // R
				if(length(rlines) < 1) {
					rlines = cat(filename + ".rout")
					rmarkers = select(1::length(rlines), usubstr(rlines, 1, 4) :== "> #_")
				}
				renderLog(outfile, format, rlines, rmarkers[n], rmarkers[n + 1] - 1, "r")
			}
		}
		// handle includes
		else if (ustrregexm(line,"<p>.include ([^<]+)</p>") > 0) {			
			includefile = addSuffix(ustrregexs(1), outext)
			printf(".include file %s\n", includefile)
			if(!fileexists(includefile)) {
				errprintf("include file %s not found", includefile)
				exit(601)
			}
			fputvec(outfile, cat(includefile))
		}
		// resize LaTeX graphs	
		else if (startsWith(line,"\includegraphics{")) {
			w = format == "beamer" ? "0.60" : "0.75"
			line = usubinstr(line, "{", "[width=" + w + "\linewidth]{", 1)
			fput(outfile, line)
		}
		else {	
			// handle inline code for Stata and R
			while(ustrregexm(line, inlinehold) > 0) {
				prefix = ustrregexs(1)
				if(prefix == "r" & length(rlines) < 1) {
					rlines = cat(filename + ".rout")
					rmarkers = select(1::length(rlines), usubstr(rlines, 1, 4) :== "> #_")
				}
				n = strtoreal(ustrregexs(2))
				logline = prefix == "" ? lines[markers[n] + 2] : rlines[rmarkers[n + 1] - 1]
				logline = ustrtrim(logline)
				if (prefix == "r") { 
					words = tokens(logline)
					if(length(words) > 1) logline =  ustrtrim(words[2])
				}				
				if(!tex & !md) logline = htmlEncode(logline, 1, 1)
				line = usubinstr(line, ustrregexs(0), logline, 1)				
			}				
			// write markdown
			fput(outfile, line)				
			if(format == "html" && n == 0) { 
				if(ustrtrim(line) == "<head>") injectCss(outfile)
			}
		}
		
	}
	fclose(infile)
	fclose(outfile)
}		
string vector translateLog(string scalar filename, string scalar format, real scalar plain) {
 // process rules in smcl log, then translate to plain text or TeX
	real scalar changed, fh, i, tex
	string scalar infile, logfile, cmd, dashes, hrule, width, options
	string vector lines
	
	// get smcl
	infile = filename + ".smcl"
	lines = cat(infile)
	changed = 0
	
	// smart rules using drawing characters
	tex = format == "latex" | format == "beamer"
	if(!tex & !plain) {		
		drawRules(lines)
		changed = 1
	}

	// save copy of log
	if(changed) {
		infile = st_tempfilename()
		fh = fopenwr(infile)
		fputvec(fh, lines)
		fclose(fh)
	}
	
	// translate smcl to TeX or Unicode text
	logfile = st_tempfilename()
	cmd = tex ?   "log texman " : "translate "
	cmd = cmd + `"""' + infile + `"" ""' + logfile + `"""'
	width = strofreal(c("linesize"))
	options = (tex? ", ll(" : ", translator(smcl2log) linesize(") + width + ")"		
	stata("quietly " + cmd + options)
	lines = cat(logfile)
	
	// handle hlines (3 or more -)
	if(!tex) {
		for(i = 1; i <= length(lines); i++) {
			while(ustrregexm(lines[i], "(--[-]+)") > 0) {
				dashes = ustrregexs(1)
				hrule = ustrlen(dashes) * "─"  // 226, 148, 128
				lines[i] = usubinstr(lines[i], dashes, hrule, 1)
			}
		}
	}
	
	// return translated log	
	return(lines)
}
void drawRules(string vector lines) {
 // modifies lines in place using IBM drawing characters for rules <>
	string vector c, d
	string scalar line, capture
	real scalar i, k
	
	c = "-", "|", "+", "TLC", "TT", "TRC", "LT", "RT", "BLC", "BT", "BRC"
	d = "─", "│", "┼", "┌",   "┬",  "┐",   "├",  "┤",  "└",   "┴",  "┘"
	
	for(i = 1; i <= length(lines); i++) {
		line = lines[i]
		capture = "\-|\||\+|TLC|TT|TRC|LT|RT|BLC|BT|BRC"
		// corners and singles
		while(ustrregexm(line, "\{c (" + capture + ")\}") > 0) {
			for(k = 1; k <= length(c); k++) {
				if(ustrregexs(1) == c[k]) break
			}
			line = usubinstr(line, ustrregexs(0), d[k], .)		
		}
		// hlines left for Stata
		lines[i] = line
	}
}
void removeCommands(string vector lines, real scalar bot, real scalar top, 
	string scalar lang, string scalar mark) {
 // blocks with q in marker don't echo commands, with m remove mata rules <>
 // now called only for q and m blocks to blank commands, handles R
	real scalar j, iscmd
	string scalar two, pri, sec, cont
	string vector block
	
	// command and continuation prompts
	pri   = lang == "stata" ? ". " : "> "
	sec   = lang == "stata" ? ": " : "> "
	cont  = lang == "stata" ? "> " : "+ "
	
	// mata rules in m		
	if(ustrpos(mark, "m") > 0) {			
		j = bot \ bot + 1 \ top - 2\ top - 1
		block = lines[j]
		assert(isMataRules(block[1::2]) & isMataRules(block[3::4]))
		lines[j] = J(4, 1, "")
	}
	// commands in q
	if(ustrpos(mark, "q") > 0) {	
		for(j = bot; j <= top; j++) {
			two = usubstr(lines[j], 1, 2)
			iscmd = two == pri || two == sec || two == cont				
			if(iscmd) {					
				// mata rules in q
				if (lang == "stata" & j < top) {
					if(isMataRules(lines[j\j+1]) ) lines[j + 1] = ""
				}
				lines[j] = ""
			}
		}
	}
}
real scalar isMataRules(string vector lines) {
 // check for mata: and end (now working with translated log)
    string scalar cmd, dashes
	real scalar hasRule
	dashes = "─" * 4
	hasRule = startsWith(lines[2], "\HLI{") | 
		startsWith(lines[2], dashes) |  startsWith(lines[2], "---" )
	if(!hasRule) return(0)
	cmd = ustrtrim(lines[1])
	return(cmd == ". mata" | cmd == ". mata:" | cmd == ": end")	
}
void renderLog(real scalar outfile, string scalar format, 
    string vector lines, real scalar bot, real scalar top, string scalar lang) {	
 // Trims log snippet and wraps in appropriate environment, 
 // consolidates old log2html and log2tex and handles R
 
	string vector encoded
	string scalar blank, comment
	real scalar trim, tex, beamer, stata
	stata = lang == "stata"
	tex = format == "latex" | format == "beamer"

	// handle removeCommands	
	comment = lang == "stata" ? "//" : "#"
	trim = ustrregexm(lines[bot], comment + "_[0-9]+([mq]+)") > 0
	bot++
	if(trim) removeCommands(lines, bot, top, lang, ustrregexs(1))	
    // remove excess blank lines	
	blank = (tex & stata) ? "{\smallskip}" : ""
    if(trim) unify(lines, bot, top, blank)
	while(top >= bot) {
		if(ustrtrim(lines[top]) != blank) break
		top--
	}
	// empty
	if(top < bot) {
		fput(outfile, "")
	}
	// html 
	else if (format == "html" | format == "s5") {
		encoded = htmlEncode(lines, bot, top)
		fput(outfile, "<pre class='" + lang + "'>" + encoded[1])
		fputvec(outfile, encoded, 2, length(encoded))
		fput(outfile, "</pre>")
	}	
	// latex stlog
	else if (tex) {
		if(!stata) texify(lines, bot, top)
		if(usubstr(lines[bot], 1, 1) == " ") lines[bot] = "\" + lines[bot]
		beamer = format == "beamer"
		if(beamer) fput(outfile, "{\fontsize{7}{8}\selectfont")
		fput(outfile, "\begin{stlog}" + beamer * "[auto]")
		fputvec(outfile, lines, bot, top)
		fput(outfile, "\end{stlog}" + beamer * "}")		
	}
	// docx or markdown
	else {
		fput(outfile, "```" + lang)
		fputvec(outfile, lines, bot, top)
		fput(outfile, "```")
	}	
}
void unify(string vector lines, real scalar bot, real scalar top, string scalar ws) {
 // unify multiple blank lines in output
	real scalar isws, inws, i, j	
	j = bot - 1
	inws = 1
	for(i = bot; i <= top; i++) {
		line = ustrtrim(lines[i])
		isws = line == ""
		if(!isws & ws != "") isws = line == ws
		if(!isws || (isws && !inws)) {
			j++
			if(j < i) lines[j] = lines[i]
			inws = isws
		}
	}
	top = j
}
void injectCss(real scalar outfile) {
 // inject markstat.css wrapping in style tags
	string scalar path
	string vector css
	path = findfile("markstat.css")
	if(path == "") return
	css = cat(path)
	fput(outfile, "<style>")
	fputvec(outfile, css)
	fput(outfile, "</style>")
}
string vector htmlEncode(string vector lines, real scalar bot, real scalar top) {
 // encode & and < as entities
	real scalar j
	string vector encoded, fixamp
	encoded = J(top - bot + 1, 1, "")
	for(j = bot; j <= top; j++) {
		fixamp = usubinstr(lines[j], "&", "&amp;", .)
		encoded[j - bot + 1] = usubinstr(fixamp, "<", "&lt;", .)
	}
	return(encoded)
}
void texify(string vector lines, real scalar bot, real scalar top) {
 // convert R log to TeX
	string vector escape, code
	string scalar line
	real scalar i, j
	escape = "\", "#", "&", "{", "}", "^", "~", "{\lbr."
	code   = "\\","\#", "\&", "{\lbr.","{\rbr}","{\caret}","{\tytilde}", "{\lbr}"
	for(i = bot; i <= top; i++) {
		line = lines[i]
		if (ustrtrim(line) == "") line = "{\smallskip}"
		else {
			for(j = 1; j <= length(escape); j++) {
				line = usubinstr(line, escape[j], code[j], .)
			}
		}
		lines[i] = line
	}
}

// ---------------------------------------------------------------------------
//  Utilities
// -----------

real scalar startsWith(string scalar line, string scalar stem) {
 // check if beginning of string matches a stem
	real scalar m, r
	m = ustrlen(stem)
	r = usubstr(line, 1, m) == stem
	return(r)
}
string scalar addSuffix(string scalar name, string scalar suffix) {
 // add file extension if not there
	return(pathsuffix(name) == "" ? name + suffix : name)
}
real scalar fopenwr(string scalar filename) {
 // file open write with replace
	if(fileexists(filename)) unlink(filename)
	return(fopen(filename, "w"))
}
void fputvec(real scalar fh, string vector lines, | real scalar bot, real scalar top) {
 // write string array to file
	real scalar i
	if (args() < 4) { 
		bot = 1; 
		top = length(lines);
	}
	for(i = bot; i <= top; i++) {
		fput(fh, lines[i])
	}
}
void splitPath(string scalar filename) {
 // returns folder, file and suffix in locals, sets isurl 
	string scalar path, file
	pathsplit(filename, path = "", file = "")
	if(pathisurl(path)) {
		st_local("isurl", "isurl")
	}
	if (c("os") == "Windows") path = usubinstr(path, "/", "\",.)
	st_local("folder", path)
	st_local("file", pathrmsuffix(file))
	st_local("suffix", pathsuffix(file))	
}	
string scalar findFile(string scalar name) {
 // look for ancillary file in working directory or markstat folder
	string scalar folder, wd
	folder = "."
	if(findfile(name, "./") == "") {
		folder = getFolder(findfile("markstat.ado"))
		if (c("os") == "Windows") folder = usubinstr(folder, "\", "/", .)
		else if(usubstr(folder, 1, 1) == "~") {
			wd = pwd()
			chdir("")
			folder = pathjoin(pwd(), usubstr(folder,2, .))
			chdir(wd)
		}
	}
	return(folder + "/" + name)
}
string scalar getFolder(string path) {
 // extract folder from path
	string scalar r
	pathsplit(path, r = "", J(0,0,""))
	return(r)
}
void unzipS5() {
 // unzip S5 files from archive in ADOPLUS/m
	string scalar home, wd, zip
	home = pathjoin(c("sysdir_plus"), "m")
	zip = pathjoin(home, "markstats5.zip")	
	if(!fileexists(zip)) return
	wd = pwd()
	chdir(home)
	stata("quietly unzipfile markstats5.zip, replace")
	chdir(wd)
	unlink(zip)
}
void checkRout(string scalar filename) {
 // check that R output includes end-of-script marker		
	real scalar fh, ok
	string scalar line
	fh = fopen(filename + ".rout", "r")
	ok = 0
	while((line = fget(fh)) != J(0, 0, "")) {
		if(usubstr(line, 1, 5) == "> #_^") {
			ok = 1
			break;
		}
	}
	fclose(fh)
	if(ok) return
 // inform the user
	errprintf("R run failed\n")
	if(fileexists(filename + ".err")) {
		errprintf("Warning and error messages follow\n")
		stata("type " + filename + ".err")
	}
	exit(197)
}
void cleanup(string scalar filename, string scalar keep) {
 // remove intermediate files in list except for keep
	real scalar i
	real vector ri
	string scalar fullname
	string vector remove, list
	remove = "do",  "R",   "md",  "tex", "pdx", "log", 
	  	     "aux", "nav", "out", "snm", "toc", "vrb", "err"
	list = "stmd"
	if (keep != "") {
		list = list, tokens(ustrlower(keep))
		ri = selectindex(list :== "r")
		if(length(ri) > 0) list[ri] = "R"
	}
	for(i = 1; i <= length(remove); i++) {
		if(length(selectindex(list :== remove[i])) > 0) continue
		fullname = filename + "." + remove[i]
		if(fileexists(fullname)) unlink(fullname)
	}	
}
end
exit
