mata 
void sp_count_slides(struct strpres scalar pres) {
	real scalar source, snr, regsl
	string rowvector line

	source = sp_fopen(pres,pres.settings.other.source, "r")
	snr   = 0
	regsl = 0
	while ((line=fget(source))!=J(0,0,"")) {
		line = tokens(line)
		if (cols(line) > 0) {
			if (line[1]=="//endslide") {
				snr = snr + 1
				regsl = regsl + 1
			}
			if (line[1]=="//enddigr"  | line[1]=="//endanc" | line[1]== "//endbib") {
				snr = snr + 1
			}
		}
	}
	sp_fclose(pres,source)
	pres.settings.other.regslides = J(1,regsl,.)
	pres.slide=strslide(snr)
}

void sp_find_structure(struct strpres scalar pres) {
	real   scalar source, snr, regsl, titleopen, lnr
	string scalar section, subsection, err 
	string rowvector line

	sp_count_slides(pres)
	
	source = sp_fopen(pres,pres.settings.other.source, "r")
	snr = 1
	regsl= 1
	titleopen = 0
	lnr = 0
	while ((line=fget(source))!=J(0,0,"")) {
		lnr = lnr + 1
		line = tokens(line)
		if (cols(line) > 0) {
			if (line[1] == "//slide") {
				pres.slide[snr].type       = "regular"
				pres.slide[snr].section    = section
				pres.slide[snr].subsection = subsection
				pres.settings.other.regslides[regsl] = snr
				if (regsl > 1) {
					pres.slide[snr].prev    = pres.settings.other.regslides[regsl-1]
				}
				else if (pres.settings.other.titlepage) {
					pres.slide[snr].prev    = 0
				}
			}
			if (line[1]=="//endslide") {
				if (pres.slide[snr].title == "" ) {
					err = "{p}{err}slide was closed on line {res}" + strofreal(lnr) + 
					       " {err}but no title was specified for that slide{p_end}"
					printf(err)
					exit(198)
				}
				snr = snr + 1
				regsl = regsl + 1
			}
			if (line[1]=="//digr") {
				pres.slide[snr].type       = "digression"
				if (regsl > 1) {
					pres.slide[snr].prev    = pres.settings.other.regslides[regsl-1]
				}
			}
			if (line[1]=="//enddigr") {
				snr = snr + 1
			}
			if (line[1]=="//anc") {
				pres.slide[snr].type       = "ancillary"
			}
			if (line[1]=="//endanc") {
				snr = snr + 1
			}
			if (line[1] == "//titlepage") {
				titleopen = 1
			}
			if (line[1] == "//endtitlepage") {
				titleopen = 0
			}
			if (line[1] == "//bib") {
				pres.slide[snr].type      = "bibliography"
				pres.bib.bibslide         = snr
			}
			if (line[1] == "//endbib") {
				snr = snr + 1
			}
			
			if (line[1]=="//section") {
				section = invtokens(line[|2 \ .|])
				subsection = ""
			}
			if (line[1]=="//subsection") {
				subsection = invtokens(line[|2 \ .|])
			}
			if (line[1]=="//title") {
				if (titleopen) {
					pres.titleslide.title = invtokens(line[|2 \ .|])
				}
				else {
					pres.slide[snr].title = invtokens(line[|2 \ .|])
				}
			}
			if (line[1]=="//label") {
				if (titleopen) {
					pres.titleslide.label = invtokens(line[|2 \ .|])
				}
				else {
					pres.slide[snr].label = invtokens(line[|2 \ .|])
				}
			}
		}
	}
	sp_fclose(pres,source)
	
	regsl = 1
	for (snr=1 ; snr <=cols(pres.slide) ; snr++) {
		if (pres.slide[snr].type == "regular") {
			regsl = regsl + 1
			if (regsl <= cols(pres.settings.other.regslides)) {
				pres.slide[snr].forw = pres.settings.other.regslides[regsl]
			}
		}
	}
	
	pres.tocslide.forw = pres.settings.other.regslides[1]
	if (pres.settings.other.titlepage) {
		pres.tocslide.prev = 0
		pres.settings.other.index = "index.smcl"
	}
	else {
		pres.settings.other.index = pres.settings.other.stub + ".smcl"
	}
	pres.titleslide.forw = pres.settings.other.regslides[1]
}

void sp_write_toc(struct strpres scalar pres) {
	real scalar err, dest
	string scalar errmsg, destfile
	
	if (pres.settings.other.titlepage) {
		destfile = pres.settings.other.destdir + "/index.smcl"
	}
	else {
		destfile = pres.settings.other.destdir + "/" + pres.settings.other.stub + ".smcl"	
	}
	if (pres.settings.other.replace == "replace") {
		err = _unlink(destfile)
		if ( err < 0 ) {
			errmsg = "{p}{err}tried replacing file {res}" + destfile + 
			         " {err}but it is read-only{p_end}"
			printf(errmsg)
			exit(608)
		}
	} 
	dest = sp__fopen(pres,destfile,"w")
	if (dest < 0) {
		errmsg = "{p}{err}tried making file {res}" + destfile +
		         " {err}but it already exists{p_end}"
		printf(errmsg)
		exit(602)
	}

	sp_write_toc_top(pres, dest)
	if (pres.settings.tocfiles.on == "on") {
		sp_write_toc_subtitle(pres,"slides", dest)	
	}
	sp_write_toc_slides(pres, dest)
	if (pres.settings.tocfiles.on=="on") {
		sp_write_toc_subtitle(pres, "files", dest)
		sp_write_toc_files(pres, dest)
	}
	if (pres.settings.bottombar.toc == "toc") {
		sp_write_bottombar(pres,dest,0,"toc")
	}
	if (pres.settings.other.titlepage == 0) {
		sp_write_pres_settings(pres,dest)
	}
	sp_fclose(pres,dest)
}

void sp_write_toc_top(struct strpres scalar pres, real scalar dest) {
	real   scalar    source, titleopen, textopen
	string rowvector line
	
	titleopen = 0
	textopen  = 0
	source = sp_fopen(pres,pres.settings.other.source, "r")
	fput(dest, "{smcl}")
    while ((line=fget(source))!=J(0,0,"")) {
        line = tokens(line)
		if (cols(line) > 0) {
			if (line[1] == "//toctitle") {
				sp_write_title(pres,line, dest, 0)
			}
			else if (line[1] == "/*toctitle") {
				titleopen = 1
				if (pres.settings.title.thline == "hline") {
					fput(dest, "{hline}")
				}
			}
			else if (line[1] == "toctitle*/") {
				titleopen = 0
				if (pres.settings.title.bhline == "hline") {
					fput(dest, "{hline}")
				}
			}
			else if (titleopen) {
				sp_write_title(pres,line,dest,1)
			}
			else if (line[1] == "/*toctxt") {
				textopen = 1
			}
			else if (line[1] == "toctxt*/") {
				textopen = 0
			}
			else if (textopen) {
				fput(dest, invtokens(line))
			}
		}
		else {
			if ( textopen ) {
				fput(dest, " ")
			}
			if (titleopen) {
				fput(dest, " ")
			}
		}
    }

	sp_fclose(pres,source)
}


void sp_write_toc_subtitle(struct strpres scalar pres, string scalar which, real scalar dest) {
	string scalar temp
	
	fput(dest,"")
	fput(dest,"")
	fput(dest,"")
	if (pres.settings.toc.subtitlethline == "hline"){
		fput(dest, "{hline}")
	}
	if (which == "slides") {
		temp = pres.settings.toc.subtitle
	}
	if (which == "files" ) {
		temp = pres.settings.tocfiles.name
	}
	if (pres.settings.toc.subtitlebf == "bold") {
		temp = "{bf:" + temp + "}"
	}
	if (pres.settings.toc.subtitleit == "italic") {
		temp = "{it:" + temp + "}"
	}
	if (pres.settings.toc.subtitlepos == "center") {
		temp = "{center:" + temp + "}"
	}
	else {
		temp = "{p}" + temp + "{p_end}"
	}
	fput(dest, temp)
	if (pres.settings.toc.subtitlebhline == "hline"){
		fput(dest, "{hline}")
	}	
}

void sp_write_toc_slides(struct strpres scalar pres, real scalar dest) {
	real   scalar snr
	string scalar section, subsection
	
	if (pres.settings.toc.itemize   == "itemize" &
	    pres.settings.toc.secthline == "nohline" &
		pres.settings.toc.secbhline == "nohline" ) {
		pres.settings.other.l1 = "{p  4  6 2}o "
		pres.settings.other.l2 = "{p  8 10 2}- "
		pres.settings.other.l3 = "{p 12 14 2}. "
		pres.settings.other.l4 = "{p 16 16 2}"
	}
	else if (pres.settings.toc.itemize   == "itemize" & (
	         pres.settings.toc.secthline == "hline" |
		     pres.settings.toc.secbhline == "hline" ) ) {
		pres.settings.other.l1 = "{p  4  4 2}"
		pres.settings.other.l2 = "{p  8 10 2}o "
		pres.settings.other.l3 = "{p 12 14 2}- "
		pres.settings.other.l4 = "{p 16 18 2}. "				 
	}
	else {
		pres.settings.other.l1 = "{p  4  4 2}"
		pres.settings.other.l2 = "{p  8  8 2}"
		pres.settings.other.l3 = "{p 12 12 2}"
		pres.settings.other.l4 = "{p 16 16 2}"
	}
	
	section    = ""
	subsection = ""
	
	for (snr=1; snr <= cols(pres.slide); snr++ ) {
		if (pres.slide[snr].section != section & pres.slide[snr].type=="regular") {
			section = pres.slide[snr].section
			sp_write_toc_section(pres, snr, dest)
			
		}
		if (pres.slide[snr].subsection != subsection & pres.slide[snr].type=="regular" & 
		    pres.slide[snr].subsection != "") {
			subsection = pres.slide[snr].subsection
			sp_write_toc_subsection(pres, snr, dest)
		}
		sp_write_toc_title(pres, snr, dest)
	}
}

void sp_write_toc_section(struct strpres scalar pres, real scalar snr, real scalar dest) {
	string scalar section

	fput(dest, " ")
	
	if (pres.settings.toc.secthline == "hline") {
		fput(dest, "{hline}")
	}
	
	section = pres.slide[snr].section
	if (pres.settings.toc.secbf=="bold") {
		section = "{bf:"+section+"}"
	}
	if (pres.settings.toc.secit=="italic") {
		section = "{it:"+section+"}"
	}
	if (pres.settings.toc.link == "section") {
		section = "{view slide" + strofreal(snr) + ".smcl : " + section + "}"
	}
	section = "{* tocline }" + pres.settings.other.l1 + section + "{p_end}"
	fput(dest, section)
	
	if (pres.settings.toc.secbhline == "hline") {
		fput(dest, "{hline}")
	}
}

void sp_write_toc_subsection(struct strpres scalar pres, real scalar snr, real scalar dest) {
	string scalar subsection
	
	if (pres.settings.toc.title != "subsection") {
		subsection = pres.slide[snr].subsection
		if (pres.settings.toc.subsecbf=="bold") {
			subsection = "{bf:" + subsection + "}"
		}
		if (pres.settings.toc.subsecit=="italic") {
			subsection = "{it:" + subsection + "}"
		}
		if (pres.settings.toc.link == "subsection") {
			subsection = "{view slide" + strofreal(snr) + ".smcl : " + subsection + "}"
		}
		subsection = "{* tocline }" + pres.settings.other.l2 + subsection + "{p_end}"
		fput(dest, subsection)
	}
}

void sp_write_toc_title(struct strpres scalar pres, real scalar snr, real scalar dest) {
	string scalar title
	
	title = pres.slide[snr].title
	if (pres.slide[snr].type == "bibliography") fput(dest, " ")
	
	if ( (pres.settings.toc.title == "subsection" |
	     (pres.slide[snr].type=="ancillary" & pres.settings.toc.title == "notitle")) &
		 pres.slide[snr].type != "digression" ) {
		if (pres.settings.toc.subsecbf ==  "bold") {
			title = "{bf:" + title + "}"
		}
		if (pres.settings.toc.subsecit == "italic") {
			title = "{it:" + title + "}"
		}
		if (pres.settings.toc.link == "subsection" | pres.slide[snr].type == "ancillary" | 
		    pres.slide[snr].type == "bibliography") {
			title = "{view slide" + strofreal(snr) + ".smcl : " + title + "}"
		}
		if (pres.slide[snr].type=="ancillary") {
				title = title + " (" + pres.settings.toc.anc +")"
		}
		title = "{* tocline }"+ pres.settings.other.l2 + title + "{p_end}"
		fput(dest,title)
	}
	if (pres.settings.toc.title == "subsubsection" & pres.slide[snr].type != "digression") {
		if (pres.settings.toc.subsubsecbf == "bold") {
			title = "{bf:" + title + "}"
		}
		if (pres.settings.toc.subsubsecit == "italic") {
			title = "{it:" + title + "}"
		}
		if (pres.settings.toc.link == "subsubsection" | pres.slide[snr].type == "ancillary" | 
		    pres.slide[snr].type == "bibliography") {
			title = "{view slide" + strofreal(snr) + ".smcl : " + title + "}"
		}
		if (pres.slide[snr].type == "ancillary") {
			title = title + " (" + pres.settings.toc.anc +")"
		}
		title = "{* tocline }"+ pres.settings.other.l3 + title + "{p_end}"
		fput(dest, title)
	}
	if (pres.settings.toc.title == "subsection" & pres.slide[snr].type=="digression" & 
	    pres.settings.toc.nodigr != "nodigr") {
		if (pres.settings.toc.subsubsecbf == "bold") {
			title = "{bf:" + title + "}"
		}
		if (pres.settings.toc.subsubsecit == "italic") {
			title = "{it:" + title + "}"
		}
		if (pres.settings.toc.link == "subsection") {
			title = "{view slide" + strofreal(snr) + ".smcl : " + title + "}"
		}
		title = "{* tocline }"+ pres.settings.other.l3 + title + "{p_end}"
		fput(dest,title)
	}
	if (pres.settings.toc.title == "subsubsection" & pres.slide[snr].type=="digression" & 
	    pres.settings.toc.nodigr != "nodigr") {
		if (pres.settings.toc.subsubsubsecbf == "bold") {
			title = "{bf:" + title + "}"
		}
		if (pres.settings.toc.subsubsubsecit == "italic") {
			title = "{it:" + title + "}"
		}
		if (pres.settings.toc.link == "subsubsection") {
			title = "{view slide" + strofreal(snr) + ".smcl : " + title + "}"
		}
		title = "{* tocline }"+ pres.settings.other.l4 + title + "{p_end}"
		fput(dest,title)
	}
}



void sp_write_toc_files(struct strpres scalar pres, real scalar dest) {
	real                   scalar    snr, exnr, i, lnr, j, source
	string                 scalar    lab, filename, slidename, row, mark, err, section
	string                 rowvector line
	class AssociativeArray scalar    filetoc
	
	for(i=1; i <= rows(pres.settings.tocfiles.markname); i++) {
			filetoc.put(pres.settings.tocfiles.markname[i,1], J(0,1,""))
	}
	
	fput(dest, "{p2colset " + pres.settings.tocfiles.p2 + "}{...}")
	
	snr    = 0
	exnr   = 0
	lnr    = 0
	source = sp_fopen(pres,pres.settings.other.source, "r")
	while ((line=fget(source))!=J(0,0,"")) {
		lnr = lnr + 1
		line = tokens(line)
		if (cols(line) > 0) {
			if (line[1] == "//slide" | line[1] == "//anc" | line[1] == "digr" ) {
				snr  = snr + 1
				exnr = 1
			}
			if (line[1]=="//ex") {
				if ( cols(line) > 1) {
					lab = invtokens(line[|2 \ .|])
				}
				else {
					lab = pres.settings.tocfiles.exname + " " + strofreal(exnr)
				}
				filename = "slide" + strofreal(snr) + "ex" + strofreal(exnr) + ".do"
				slidename = "slide" + strofreal(snr) + ".smcl"
				row = sp_buildfilerow(pres,filename,lab,slidename)
				filetoc.put("ex", (filetoc.get("ex") \ row))
				exnr = exnr + 1
			}
			if (line[1]=="//tocfile") {
				if (cols(line) < 4) {
					err = "{err}//filetoc command on line {res}" + strofreal(lnr) +
					      " {err}contains an error"
					printf(err)
					exit(198)
				}
				else {
					mark = line[2]
					filename = line[3]
					lab = invtokens(line[|4 \ .|])
				}
				if (filetoc.exists(mark)) {
					slidename = "slide" + strofreal(snr) + ".smcl"
					row = sp_buildfilerow(pres,filename,lab,slidename)
					filetoc.put(mark, (filetoc.get(mark) \ row))
				}
				else {
					err = "{err}mark {res}" + mark + 
					      " {err }in the //filetoc command on line {res}" +
						  strofreal(lnr) + " {err} is not defined"
					printf(err)
					exit(198)
				}
				
			}
		}
	}
	sp_fclose(pres,source)
	
	for (i = 1 ; i <= rows(pres.settings.tocfiles.markname); i++) {
		mark = pres.settings.tocfiles.markname[i,1]
		if (rows(filetoc.get(mark)) > 0 ) {
			fput(dest, " ")
			
			if (pres.settings.toc.secthline == "hline") {
				fput(dest, "{hline}")
			}
			
			section = pres.settings.tocfiles.markname[i,2]
			if (pres.settings.toc.secbf=="bold") {
				section = "{bf:"+section+"}"
			}
			if (pres.settings.toc.secit=="italic") {
				section = "{it:"+section+"}"
			}
			if (pres.settings.toc.link == "section") {
				section = "{view slide" + strofreal(snr) + ".smcl : " + section + "}"
			}
			section = pres.settings.other.l1 + section + "{p_end}"
			fput(dest, section)
			
			if (pres.settings.toc.secbhline == "hline") {
				fput(dest, "{hline}")
			}
			for(j=1; j<=rows(filetoc.get(mark)); j++) {
				fput(dest, filetoc.get(mark)[j])
			}
		}	
	}
}

string scalar sp_buildfilerow(struct strpres scalar pres, string scalar filename,
                           string scalar label, string scalar slide ) {

	string scalar    toreturn
	string rowvector ext
	
	ext = tokens(filename, ".")
	if ( cols(ext) == 3 ) {
		ext = ext[3]
	}
	else {
		ext = ""
	}
	
	toreturn = "{p2col:"
	
	if (rowsum(tokens(pres.settings.tocfiles.doedit):==ext)) {
		toreturn = toreturn + `"{stata "doedit "' + filename + `"":"' + filename + "}"
	}
	else if (rowsum(tokens(pres.settings.tocfiles.view):==ext)) {
		toreturn = toreturn + "{view " + filename + "}"
	}
	else if (rowsum(tokens(pres.settings.tocfiles.gruse):==ext)) {
		toreturn = toreturn + `"{stata "graph use "' + filename + `"":"' + filename + "}"
	}
	else if (rowsum(tokens(pres.settings.tocfiles.euse):==ext)) {
		toreturn = toreturn + `"{stata "est use "' + filename + `"":"' + filename + "}"
	}
	else if (rowsum(tokens(pres.settings.tocfiles.use):==ext)) {
		toreturn = toreturn + `"{stata "use "' + filename + `", clear":"' + filename + "}"
	}
	else {
		toreturn = toreturn + filename
	}
	toreturn = toreturn + "}" +	label + pres.settings.tocfiles.where 
	toreturn = toreturn + "{view " + slide + "}{p_end}"
	return(toreturn)
}

void sp_changemarkname(struct strpres scalar pres, string scalar mark, string scalar name) {
	real colvector i
	
	i = selectindex(pres.settings.tocfiles.markname[.,1] :== mark)
	if (cols(i) > 1) {
		exit(error(198))
	}
	pres.settings.tocfiles.markname[i,2] = name
}

end
