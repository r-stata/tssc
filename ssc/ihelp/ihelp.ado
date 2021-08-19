
*! v 1.02
*! 2021/6/16 13:32
*! Author: Yujun Lian, Yongli Chen

*cap program drop ihelp
program define ihelp, rclass
version 14.0

	syntax anything(everything) [, Markdown Weixin Clipoff]	

* 1.get full command
	local hlp = subinstr("`anything'", " ", "_", .) //identifiable parameters
	if strmatch("`hlp'", "*()") {
		local hlp = subinstr("`hlp'", "()", "", .)
		local hlp "f_`hlp'"
	}
	cap findfile `hlp'.sthlp // get the full name of the unrecognized parameter
	if _rc != 0 { // ?help_alisa.maint (include "grogramming function")
		ihelp_similar `hlp', sup
		local hlp1 = `"`r(fname)'"'
	}

* 2.get pdf-link
	local pref_text = fileread(`"`r(fn)'"') //open help file (.sthlp)
	if strmatch(`"`pref_text'"', "*mansection*") { //get pdf-link
		local fname = substr(`"`pref_text'"', strpos(`"`pref_text'"', "mansection")+11, 50)
		local fname = lower(substr(`"`fname'"', 1, strpos(`"`fname'"', `""}"')-1))
		local pref = lower(substr(`"`fname'"', 1, strpos(`"`fname'"', " ")-1))
		local fname = subinstr(`"`fname'"', " ", "", .)
	}
	if `"`fname'"'=="" {
		if `"`hlp1'"'!= "" ihelp_ucap `hlp1'
		else ihelp_ucap `hlp'
		if `"`r(url)'"' != "" {
			local url = `"`r(url)'"'
		}
		else {
			dis as error `"You can input the full name of the command, so that it can be unique"' `", see {stata `"help `anything'"'}"' _n
			ihelp_similar `hlp', sim
			exit 0
		}
	}
	else {
		local url "https://www.stata.com/manuals/`fname'.pdf"
	}

* 3.open pdfhelp | markdown-link | wechat-link
	local mtext_m [**[`=upper("`pref'")']** `anything'](`url')
	local mtext_w [`=upper("`pref'")'] `anything' PDF 手册：`url'
	if "`markdown'`weixin'"=="" {
		view browse `url'
	}
	else {
		if "`markdown'"!="" {
			dis in y `"`mtext_m'"'
			if "`clipoff'"=="" {
				!echo `mtext_m' | clip  // auto copy to clipboard
				dis as text "Text is on clipboard. Press Ctrl+V to paste"
			}
		}
		else if "`weixin'"!="" {
			dis in y `"`mtext_w'"'
			if "`clipoff'"=="" {
				!echo `mtext_w' | clip  // auto copy to clipboard
				dis as text "Text is on clipboard. Press Ctrl+V to paste"
			}
		}
	}
	return local link_w `mtext_w'
	return local link_m `mtext_m'
	return local link `url'
end


*cap program drop ihelp_similar
program define ihelp_similar, rclass
	syntax anything(everything)[, SIMilar SUPplement]
* 1. 获取可识别的命令参数
	local hlp = subinstr("`anything'", " ", "_", .)
	preserve
	local s1 = substr("`anything'", 1, 1)
	qui findfile `s1'help_alias.maint
	qui import delimited using "`r(fn)'", clear delimiters("\t ", collapse)
	qui count if strmatch(v1, "`hlp'")
	//Completion command
	if "`supplement'"!="" & `r(N)' == 1 {
		qui keep if strmatch(v1, "`hlp'")
		local hlp = v2[1]
		cap findfile `hlp'.sthlp
		return local fn = `"`r(fn)'"'
		return local fname = `"`hlp'"'
// 		return scalar N = 1
	}
	//Similar commands
	if "`similar'"!=""{
		qui keep if strmatch(v1, "`hlp'*")
		if _N == 0 {
			exit 0
		}
		qui duplicates drop v2, force
		local cnt = _N
		local dis_text ""
		forvalues k = 1/`cnt' {
			local hlp = v2[`k']
			local dis_text `dis_text' {stata `"ihelp `hlp'"': `hlp'} | 
		}
		local dis_text = substr(`"`dis_text'"', 1, strlen(`"`dis_text'"')-2)
		dis in y `"Find `cnt' similar command:"'
		dis in w `"`dis_text'"'
// 		return scalar N = `cnt'
	}
end

*cap program drop ihelp_ucap
program define ihelp_ucap, rclass
	syntax anything(everything)
	local hlp = subinstr("`anything'", " ", "_", .)
	clear
	qui set obs 1
	cap findfile `hlp'.sthlp
	if _rc == 0 {
		local pref_text = fileread(`"`r(fn)'"')
		if strmatch(`"`pref_text'"', "*findalias*") { // `hlp'.sthlp
			local fname = substr(`"`pref_text'"', strpos(`"`pref_text'"', "findalias")+10, 50)
			local fname = lower(substr(`"`fname'"', 1, strpos(`"`fname'"', "}")-1))
// 			dis in y "`fname'"
			if `"`fname'"' !="" { // asmcl_alias.maint
				preserve
				qui findfile asmcl_alias.maint
				qui import delimited using "`r(fn)'", clear delimiters("{vieweralsosee", asstring)
				qui replace v1 = trim(v1)
				qui count if strmatch(v1, `"`fname'"')
				if `r(N)' == 1 {
					qui keep if strmatch(v1, "`fname'")
					qui gen link = substr(v2, strpos(v2, "mansection")+11, strpos(v2, `""}"')-strpos(v2, "mansection")-11)
					qui split link
					qui replace link2 = lower(link1) + link2
					qui replace link1 = substr(link2, 1, strpos(link2, ".")-1)
					return local url "https://www.stata.com/manuals/`=link1[1]'.pdf#`=link2[1]'"
				}
			}
		}
	}
end



/*
 2021/4/27 18:40 (yongli), update: 
	- three options: markdown, weixin, clipoff
	
 2021/4/27 20:39 (Arlionn)
 
 要全面统计一下[docs/Stata_cmd_PDF_online_Items.md] 文件中【anything】不是
 单个单词的情形有哪些？如果特不多，可以用 if 语句解决，否则可以找找规律
   
    - ihelp twoway scatter
	- 
    if wordcount(cmd)>1{
	   cap ihelp cmd
	   if _rc{
	      
	   }
	}

  2021/4/28 00:59 (yongli), update: 
	- handles the case of command abbreviation
	(get abbreviations list from ?help_alisa.maint)

  2021/5/2 00:08 (yongli), update:
	- adjust the order of each module
	- compatible with stata16
	- ihelp_similar modular: list similar commands

  2021/5/3 19:01 (yongli), update: 
	- support function()
	- support situations in which pdf-link is not contained in .sthlp file (e.g. help _variables)
		+ situations in which pdf-link is not directly listed in .sthlp file,
		  but given in the form of SMCL like {findalias asfrvarlists}
		+ the real pdf-link can be indexed from file "asmcl_alias.maint",
		  in which each word corresponds with a ChapterName (pdf-link)
		+ e.g. the word "asfrvarlists" --> ChapterName "[U] 13.4 System variables (_variables)"
		  --> "pdf-link": https://www.stata.com/manuals/u13.pdf#u13.4Systemvariables(_variables)
*/
