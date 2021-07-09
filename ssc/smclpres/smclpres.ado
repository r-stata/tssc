*! version 3.3.1 MLB 05Aug2019
*  fixed some missing double quotes in Parsedirs
*  add the //dir option

program define smclpres, rclass
	version 14.2
	syntax using, [debug] *
	
	local olddir = c(pwd)
	
	local pres sp__presentation_struct
	mata: `pres' = sp_presinit()	
	
	capture noisily smclpres_main `using', `options' pres(`pres')
	
	if _rc {
		if `"`olddir'"' != `"`c(pwd)'"' {
			qui cd `olddir'
		}
		mata : sp_fcloseall(`pres')
		if "`debug'" == "" {
			mata: mata drop `pres'
		}
		exit _rc
	}
	if "`debug'" == "" {
		mata: mata drop `pres'
	}
end

program define smclpres_main, rclass
	version 14.2
	syntax using, pres(string) [replace dir(passthru)]
	
	Parsedirs `using', `dir' `replace' pres(`pres')
	
	Findsettings `using', pres(`pres')
	
	mata: sp_find_structure(`pres')
	
	mata: sp_write_toc(`pres')
	
	mata: sp_init_bib(`pres')
	
	mata: sp_write_slides(`pres')
	
	Closingmsg, pres(`pres')
end

program define Parsedirs, sclass
	syntax using/, pres(string) [dir(string) replace]

	local stub : subinstr local using "\" "/", all
	while `"`stub'"' != "" {
		local path `path'`path2'
		gettoken path2 stub : stub, parse("/\:")
	}
	local stub `path2'
	local file "`stub'"
	gettoken stub suffix : stub, parse(".")
	local odir = c(pwd)
	quietly {
		cd `"`path'"'
		local sdir = c(pwd)
		local source `sdir'/`file'
		if `"`dir'"' != "" {
			cd `"`odir'"'
			cd `"`dir'"'
			local ddir = c(pwd)
		}
		else {
			local ddir "`odir'"
		}
		cd `"`odir'"'
	}
	mata `pres'.settings.other.stub      = "`stub'"
	mata `pres'.settings.other.sourcedir = "`sdir'"
	mata `pres'.settings.other.source    = "`source'"
	mata `pres'.settings.other.olddir    = "`odir'"
	mata `pres'.settings.other.destdir   = "`ddir'"
	mata `pres'.settings.other.replace   = "`replace'"
end

program define Findsettings
	syntax using/ , pres(string)
	
	tempname base 
	file open `base' using `"`using'"', read
	local lnr = 1
	local titlepage = 0
	file read `base' line
	while r(eof) == 0 {
		gettoken first rest : line
		if `"`first'"' == "//layout" {
			gettoken second options : rest 
			Parselayout `second', lnr(`lnr') `macval(options)'
		}
		if `"`first'"' == "//titlepage" local titlepage = 1
		local `lnr++'
		file read `base' line
	}
	file close `base'
	mata `pres'.settings.other.titlepage = `titlepage'
end

program define Parselayout 
	syntax [name(name=what)], lnr(integer) [*]
	
	local pres sp__presentation_struct	
	
	if `"`what'"' == "" {
		di as err "{p}Incomplete //layout command on line `lnr'{p_end}"
		exit 198
	}
	local 0 = `", `macval(options)'"'
	if `"`what'"' == "toc" {
		syntax , [link(string) itemize anc(string) title(string) ///
		          secthline secbhline secbold secitalic subsecbold subsecitalic ///
				  subsubsecbold subsubsecitalic subsubsubsecbold subsubsubsecitalic ///
				  subtitlepos(string) nosubtitlebold subtitleitalic nosubtitlethline ///
				  nosubtitlebhline subtitle(string) nodigr *]
		  
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout toc" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if `: word count `link'' > 1 {
			di as err "{p}option " as result "link()" as err ///
                      " in " as result "//layout toc" as err  ///
                      " command on line " as result "`lnr'" as err ///
                      " may contain either section, subsection, or subsubsection{p_end}"
			exit 198
		}
		if `"`link'"' != "" & !inlist(`"`link'"', "section", "subsection", "subsubsection") {
			di as err "{p}option " as result "link()" as err ///
                      "  in " as result "//layout toc" as err ///
                      " command on line " as result "`lnr'" as err ///
                      " may contain either section, subsection, or subsubsection{p_end}"
			exit 198
		}
		if "`link'" == "subsubsection" & "`title'" != "subsubsection" {
			di as err "{p} the option " as result "link(subsubsection)" ///
			   as err "in " as result "//layout toc" as err " on line " ///
			   as result "`lnr'" as err "is only allowed in combination with " ///
			   as result "title(subsubsection){p_end}"
			exit 198
		}
		if `: word count `title'' > 1 {
			di as err "{p}option " as result "title()" as err " in " as result ///
			   "//layout toc" as err " on line " as result "`lnr'" as err ///
			   "may contain either subsection, subsubsection, or notitle{p_end}"
			exit 198
		}
		if "`title'" != "" & !inlist(`"`title'"', "subsection", "subsubsection", "notitle") {
			di as err "{p}option " as result "title()" as err " in " as result ///
			   "//layout toc" as err " on line " as result "`lnr'" as err ///
			   "may contain either subsection, subsubsection, or notitle{p_end}"
			exit 198
		}
		if `: word count `subtitlepos'' > 1 {
			di as err "{p}option " as result "subtitlepos()" as err ///
                      " in " as result "//layout toc" as err  ///
                      " command on line " as result "`lnr'" as err ///
                      " may contain either left or center{p_end}"
			exit 198
		}
		if `"`subtitlepos'"' != "" & !inlist(`"`subtitlepos'"', "left", "center") {
			di as err "{p}option " as result "subtitlepos()" as err ///
                      "  in " as result "//layout toc" as err ///
                      " command on line " as result "`lnr'" as err ///
                      " may contain either left or center{p_end}"
			exit 198
		}
		if "`secbhline'"                  != "" {
			mata : `pres'.settings.toc.secbhline          = "hline"
		}
		if "`secthline'"                   != "" {
			mata : `pres'.settings.toc.secthline          = "hline"
		}
		if "`secbold'"                     != "" {
			mata : `pres'.settings.toc.secbf            = "bold"
		}
		if "`secitalic'"                   != "" {
			mata : `pres'.settings.toc.secit          = "italic"
		}
		if "`subsecbold'"                   != "" {
			mata : `pres'.settings.toc.subsecbf         = "bold"
		}
		if "`subsecitalic'"                 != "" {
			mata : `pres'.settings.toc.subsecit       = "italic"
		}
		if "`subsubsecbold'"                != "" {
			mata : `pres'.settings.toc.subsubsecbf      = "bold"
		}
		if "`subsubsecitalic'"              != "" {
			mata : `pres'.settings.toc.subsubsecit    = "italic"
		}
		if "`subsubsubsecbold'"             != "" {
			mata : `pres'.settings.toc.subsubsubsecbf   = "bold"
		}
		if "`subsubsubsecitalic'"           != "" {
			mata : `pres'.settings.toc.subsubsubsecit = "italic"
		}
		if "`subtitlebold'"                 != "" {
			mata : `pres'.settings.toc.subtitlebf       = "regular"
		}
		if "`subtitleitalic'"               != "" {
			mata : `pres'.settings.toc.subtitleit     = "italic"
		}
		if "`subtitlethline'"               != "" {
			mata : `pres'.settings.toc.subtitlethline     = "nohline"
		}
		if "`subtitlebhline'"               != "" {
			mata : `pres'.settings.toc.subtitlebhline     = "nohline"
		}
		if `"`macval(link)'"'               != "" {
			mata : `pres'.settings.toc.link               = `"`link'"'
		}
		if `"`macval(itemize)'"'            != "" {
			mata : `pres'.settings.toc.itemize            = `"`itemize'"'
		}
		if `"`macval(anc)'"'                != "" {
			mata : `pres'.settings.toc.anc                = `"`macval(anc)'"'
		}
		if `"`macval(title)'"'              != "" {
			mata : `pres'.settings.toc.title              = `"`macval(title)'"'
		}
		if `"`macval(subtitlepos)'"'        != "" {
			mata : `pres'.settings.toc.subtitlepos        = `"`subtitlepos'"'
		}
		if `"`macval(subtitle)'"'           != "" {
			mata : `pres'.settings.toc.subtitle           = `"`macval(subtitle)'"'
		}
		if `"`digr'"'                       != "" {
			mata : `pres'.settings.toc.nodigr             = "nodigr"
		}
	}
	else if `"`what'"' == "tocfiles" {
		syntax , [off on name(string) where(string) exname(string) ///
		doname(string) adoname(string) dataname(string) classname(string) ///
		stylename(string) graphname(string) grecname(string) irfname(string) ///
		mataname(string) bcname(string) stername(string) tracename(string) ///
		semname(string) swmname(string) customname(string) ///
		doedit(string) view(string) gruse(string) euse(string) use(string) ///
		p2(string) *]
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout tocfiles" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if "`off'" != "" & "`on'" != "" {
			di as err "{p}options off and on in the " as result ///
                      "//layout tocfiles" as err " command on line " as result //
                      "`lnr'" as err " cannot both be specified{p_end}"
			exit 198
		}
		if "`p2'" != "" {
			local ok = 1
			if `: word count `p2'' != 4 {
				local ok = 0
			}
			tokenize `p2'
			forvalues i = 1/4 {
				capture confirm integer number ``i''
				if _rc | ``i'' < 0 {
					local ok = 0
				}
			}
			if `1' > `2' {
				local ok = 0
			}
			if !`ok' {
				di as err "{p}there is a problem with the p2() option in " ///
				   as result "//layout tocfiles" as err " on line " as result ///
				   "`lnr'{p_end}"
				exit 198
			}
		}
		local specified `doedit' `view' `gruse' `euse' `use'
		if `"`doedit'"' == "" {
			local doedit "do ado dct class scheme style"
			local doedit : list doedit - specified
		}
		else {
			local doedit : list clean doedit
			local doedit : subinstr local doedit "." "", all
			local doedit : list uniq doedit
		}
		if `"`view'"' != "" {
			local view : list clean view
			local view : subinstr local view "." "", all
			local view : list uniq view
		}
		if `"`gruse'"' == "" {
			local gruse "gph"
			local gruse : list gruse - specified
		}
		else {
			local gruse : list clean gruse
			local gruse : subinstr local gruse "." "", all
			local gruse : list uniq gruse
		}
		if `"`euse'"' == "" {
			local euse "ster"
			local euse : list euse - specified
		}
		else {
			local euse : list clean euse
			local euse : subinstr local euse "." "", all
			local euse : list uniq euse
		}
		if `"`use'"' == "" {
			local use "dta"
			local use : list use - specified
		}
		else {
			local use : list clean use
			local use : subinstr local use "." "", all
			local use : list uniq use
		}
		tokenize doedit view gruse euse use
		local ok = 1
		forvalues i = 1/4 {
			forvalues j = `=`i'+1'/ 5 {
				if "`: list `i' & `j''" != "" local ok = 0
			}
		}
		if !`ok' {
			di as err "{p}the doedit view gruse euse and use options in the " ///
			   as result "//layout tocfiles" as err ///
			   " command may not contain the same extensions{p_end}"
		}
		if `"`on'`off'"'           != "" {
			mata : `pres'.settings.tocfiles.on  = "`on'`off'"
		}
		if `"`macval(name)'"'      != "" {
			mata : `pres'.settings.tocfiles.name = `"`macval(name)'"'
		}
		if `"`macval(where)'"'     != "" {
			mata : `pres'.settings.tocfiles.where = `"`macval(where)'"'
		}
		if `"`macval(exname)'"'    != "" {
			mata : sp_changemarkname(`pres', "ex", `"`macval(exname)'"')
		}
		if `"`macval(doname)'"'    != "" {
			mata : sp_changemarkname(`pres', "do", `"`macval(doname)'"')
		}
		if `"`macval(adoname)'"'   != "" {
			mata : sp_changemarkname(`pres', "ado", `"`macval(adoname)'"')
		}
		if `"`macval(dataname)'"'  != "" {
			mata : sp_changemarkname(`pres', "data", `"`macval(dataname)'"')
		}
		if `"`macval(classname)'"' != "" {
			mata : sp_changemarkname(`pres', "class", `"`macval(classname)'"')
		}
		if `"`macval(stylename)'"' != "" {
			mata : sp_changemarkname(`pres', "style", `"`macval(stylename)'"')
		}
		if `"`macval(graphname)'"' != "" {
			mata : sp_changemarkname(`pres', "graph", `"`macval(graphname)'"')
		}
		if `"`macval(grecname)'"'  != "" {
			mata : sp_changemarkname(`pres', "grec", `"`macval(grecname)'"')
		}
		if `"`macval(irfname)'"'   != "" {
			mata : sp_changemarkname(`pres', "irf", `"`macval(irfname)'"')
		}
		if `"`macval(mataname)'"'  != "" {
			mata : sp_changemarkname(`pres', "mata", `"`macval(mataname)'"')
		}
		if `"`macval(bcname)'"'    != "" {
			mata : sp_changemarkname(`pres', "bc", `"`macval(bcname)'"')
		}
		if `"`macval(stername)'"'  != "" {
			mata : sp_changemarkname(`pres', "ster", `"`macval(stername)'"')
		}
		if `"`macval(tracename)'"' != "" {
			mata : sp_changemarkname(`pres', "trace", `"`macval(tracename)'"')
		}
		if `"`macval(semname)'"'   != "" {
			mata : sp_changemarkname(`pres', "sem", `"`macval(semname)'"')
		}
		if `"`macval(swmname)'"'   != "" {
			mata : sp_changemarkname(`pres', "swm", `"`macval(swmname)'"')
		}
		if `"`macval(doedit)'"'    != "" {
			mata : `pres'.settings.tocfiles.doedit = `"`doedit'"'
		}
		if `"`macval(view)'"'      != "" {
			mata : `pres'.settings.tocfiles.view = "`view'"
		}
		if `"`macval(gruse)'"'     != "" {
			mata : `pres'.settings.tocfiles.gruse = "`gruse'"
		}
		if `"`macval(euse)'"'      != "" {
			mata : `pres'.settings.tocfiles.euse = "`euse'"
		}
		if `"`macval(use)'"'       != "" {
			mata : `pres'.settings.tocfiles.use = "`use'"
		}
		if "`p2'" != "" {
			mata : `pres'.settings.tocfiles.p2 = "`p2'"
		}
		local kcustom = 0
		gettoken left right : customname , parse(;)
		gettoken semicolumn right : right , parse(;)
		while `"`macval(left)'"' != "" {
			gettoken stub label : left
			if `"`macval(label)'"' == "" {
				di as err "{p}the customname() option in the " as result "//tocfiles" ///
				   as err " command on line " as result "`lnr'" as err " is incorrect{p_end}"
				exit 198
			}
			local kcustom = `kcustom' +1
			gettoken left right : right , parse(;)
			gettoken semicolumn right : right , parse(;)
		}
		mata : st_local("i", strofreal(rows(`pres'.settings.tocfiles.markname) + 1))
		mata : `pres'.settings.tocfiles.markname = `pres'.settings.tocfiles.markname \ J(`kcustom',2, "")
		gettoken left right : customname , parse(;)
		gettoken semicolumn right : right , parse(;)
		while `"`macval(left)'"' != "" {
			gettoken stub label : left
			local stub = strtrim(`"`macval(stub)'"')
			local label = strtrim(`"`macval(label)'"')
			mata : `pres'.settings.tocfiles.markname[|`i',1 \ `i',2|] = ("`stub'", `"`macval(label)'"')
			local i = `i' + 1
			gettoken left right : right , parse(;)
			gettoken semicolumn right : right , parse(;)
		}
	}	
	else if `"`what'"' == "digress" {
		syntax, [name(string) prefix(string asis) * ]
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout digress" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if `"`macval(name)'"'         != "" {
			mata : `pres'.settings.digress.name = `"`macval(name)'"'
		}
		if `"`macval(prefix)'"'       != "" {
			mata : `pres'.settings.digress.prefix = `"`macval(prefix)'"'
		}
	}
	else if `"`what'"' == "example" {
		syntax, [name(string) *]
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout example" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if `"`macval(name)'"'        != "" {
			mata : `pres'.settings.example.name = `"`macval(name)'"'
		}
	}
	else if `"`what'"' == "topbar" {
		syntax, [off on nothline nobhline nosubsec nosecbold secitalic ///
		         subsecbold subsecitalic sep(string asis) *]
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout topbar" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if "`off'" != "" & "`on'" != "" {
			di as err "{p}options off and on in the " as result ///
                      "//topbar" as err " command on line " as result //
                      "`lnr'" as err " cannot both be specified{p_end}"
			exit 198
		}
		if "`secbold'"      != "" local secbold "regular"
		if "`secitalic'"    != "" local secitalic "italic"
		if "`subsecbold'"   != "" local subsecbold "bold"
		if "`subsecitalic'" != "" local subsecitalic "italic"
		if `"`on'`off'"'               != "" {
			mata : `pres'.settings.topbar.on = "`on'`off'"
		}
		if `"`macval(thline)'"'        != "" {
			mata : `pres'.settings.topbar.thline = "`thline'"
		}
		if `"`macval(bhline)'"'        != "" {
			mata : `pres'.settings.topbar.bhline = "`bhline'"
		}
		if `"`macval(subsec)'"'        != "" {
			mata : `pres'.settings.topbar.subsec = "`subsec'"
		}
		if `"`macval(secbold)'"'       != "" {
			mata : `pres'.settings.topbar.secbf = "`secbold'"
		}
		if `"`macval(secitalic)'"'     != "" {
			mata : `pres'.settings.topbar.secit = "`secitalic'"
		}
		if `"`macval(subsecbold)'"'    != "" {
			mata : `pres'.settings.topbar.subsecbf = "`subsecbold'"
		}
		if `"`macval(subsecitalic)'"'  != "" {
			mata : `pres'.settings.topbar.subsecit = "`subsecitalic'"
		}
		if `"`macval(sep)'"'           != "" {
			mata : `pres'.settings.topbar.sep = `"`macval(sep)'"'
		}
	}
	else if `"`what'"' == "bottombar" {
		syntax, [nothline nobhline arrow label next(string) index(string) ///
		        nextname(string) toc tpage(string) *]
		if `"`options'"' != "" {
			di as err "{p}options " as result "`options'" as err ///
                      " not allowed in " as result "//layout bottombar" ///
                      as err " command on line " as result "`lnr'{p_end}"			
			exit 198
		}
		if "`arrow'" != "" & "`label'" != "" {
			di as err "{p}options arrow and label may not be combined in the " ///
               as result "//layout bottombar" as err " command on line " ///
               as result "`lnr'{p_end}"
			exit 198
		}
		if `"`next'"' != "" & "`label'" == "" {
				di as err "{p}option next() may not be specified without the label " ///
                          "option in the " as result "//layout botombar" as err ///
                          " command on line " as result "`lnr'{p_end}"
				exit 198
		}
		if `"`next'"' != "" {
			if `: word count `next'' > 1 | !inlist(`"`next'"', "left", "right") {
				di as err "{p}the option next() in the " as result ///
                   "//layout bottombar" as err " command on  line " as result ///
                   "`lnr'" as err " may contain either left or right{p_end}"
				exit 198
			}
			mata : `pres'.settings.bottombar.next = "`next'"
		}
		if `"`nextname'"' != "" & "`label'" == "" {
				di as err "{p}option nextname() may not be specified without the label " ///
                          "option in the " as result "//layout botombar" as err ///
                          " command on line " as result "`lnr'{p_end}"
				exit 198
		}
		if "`label'" != "" {
			if `"`nextname'"' == "" local nextname "next"
			mata : `pres'.settings.bottombar.nextname = `"`nextname'"'
		}
		if `"`macval(thline)'"'         != "" {
			mata : `pres'.settings.bottombar.thline = "`thline'"
		}
		if `"`macval(bhline)'"'         != "" {
			mata : `pres'.settings.bottombar.bhline = "`bhline'"
		}
		if `"`arrow'`label'"'           != "" {
			mata : `pres'.settings.bottombar.arrow  = "`arrow'`label'"
		}
		if `"`macval(index)'"'          != "" {
			mata : `pres'.settings.bottombar.index = `"`macval(index)'"'
		}
		if "`toc'" != "" {
			mata : `pres'.settings.bottombar.toc = "`toc'"
		}
		if `"`macval(tpage)'"' != "" {
			mata : `pres'.settings.bottombar.tpage = `"`macval(tpage)'"'
		}
	}
	else if `"`what'"' == "title" {
		syntax, [thline bhline left center nobold italic *]
		if `"`options'"' != "" {
			di as err "{p}//options " as result "`options'" as err ///
                      " not allowed in " as result "//layout title" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if "`left'" != "" & "`center'" != "" {
			di as err "{p}options left and center may not be combined in the " ///
               as result "//layout title" as err " command on line " ///
               as result "`lnr'"
			exit 198
		}
		if `"`macval(thline)'"'         != "" {
			mata : `pres'.settings.title.thline = "hline"
		}
		if `"`macval(bhline)'"'         != "" {
			mata : `pres'.settings.title.bhline = "hline"
		}
		if `"`center'`left'"'           != "" {
			mata : `pres'.settings.title.pos = "`left'`center'"
		}
		if `"`macval(bold)'"'           != "" {
			mata : `pres'.settings.title.bold = "`bold'"
		}
		if `"`macval(italic)'"'         != "" {
			mata : `pres'.settings.title.italic = "`italic'"
		}
	}
	else if `"`what'"' == "tab" {
		syntax, spaces(numlist min=1 max=1 >0 integer) *
		if `"`options'"' != "" {
			di as err "{p}//options " as result "`options'" as err ///
                      " not allowed in " as result "//layout tab" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		mata: `pres'.settings.other.tab = `spaces'
	}
	else if `"`what'"' == "bib" {
		syntax, [bibfile(string) stylefile(string) and(string) authorstyle(string) write(string) *]
		if `"`options'"' != "" {
			di as err "{p}//options " as result "`options'" as err ///
                      " not allowed in " as result "//layout bib" ///
                      as err " command on line " as result "`lnr'{p_end}"
			exit 198
		}
		if `"`macval(bibfile)'"' != "" {
			mata st_local("sdir",`pres'.settings.other.sourcedir)
			capture confirm file `"`sdir'/`bibfile'"'
			if _rc {
				di as err "{p}file " as result `"`bibfile'"' as err " specified in the " ///
				   as result "bibfile()" as err " option of the " as result "//layout bib" ///
				   as err " command on line " as result "`lnr'" as err " not found{p_end}"
				exit _rc
			}
			mata : `pres'.bib.bibfile = `"`sdir'/`bibfile'"'
		}
		if `"`macval(stylefile)'"' != "" {
			mata st_local("sdir",`pres'.settings.other.sourcedir)
			capture confirm file `"`sdir'/`stylefile'"'
			if _rc {
				di as err "{p}file " as result `"`stylefile'"' as err " specified in the " ///
				   as result "stylefile()" as err " option of the " as result "//layout bib" //
				   as err " command on line " as result "`lnr'" as err " not found{p_end}"
				exit _rc
			}
			mata : `pres'.bib.stylefile = `"`sdir'/`stylefile'"'
		}		
		if `"`macval(and)'"' != "" {
			mata : `pres'.bib.and = `"`macval(and)'"'
		}
		if `"`macval(authorstyle)'"' != "" {
			if !inlist(`"`authorstyle'"', "first last", "last first") {
				di as err "{p}the "as result "authorstyle()" as err " option of the " ///
				   as result "//layout bib" as err " command specified on line " ///
				   as result "`lnr'" as err `" can only contain either "first last" or "last first"{p_end}"' 
				exit 198
			}
			mata : `pres'.bib.authorstyle = "`authorstyle'"
		}
		if `"`write'"' != "" {
			if !inlist(`"`write'"', "cited", "all") {
				di as err "{p}the "as result "write()" as err " option of the " ///
				   as result "//layout bib" as err " command specified on line " ///
				   as result "`lnr'" as err `" can only contain either "cited" or "all"{p_end}"' 
				exit 198			
			}
			mata : `pres'.bib.write = "`write'"
		}
	}
	else {
		di as err "{p}command " as result "//layout `what'" ///
           as err " on line " as result "`lnr'" as err " is unrecognized{p_end}"
		exit 199
	}
end

program define Closingmsg
	syntax, pres(string)
	
	mata st_local("dir", `pres'.settings.other.destdir)
	mata st_local("stub", `pres'.settings.other.stub)
	
	di as txt "{p}to view the presentation:{p_end}"
    di as txt "{p}first change the directory to where the presentation is stored:{p_end}"
    di `"{p}{stata `"cd "`dir'""'}{p_end}"'
	di as txt "{p}Then type:{p_end}"
	di `"{p}{stata "view `stub'.smcl"}{p_end}"'
end
