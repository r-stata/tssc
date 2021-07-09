mata

void sp_write_topbar(struct strpres scalar pres, real scalar dest,
                  real scalar snr) {
	string scalar line, temp
	
	line = ""
	if (!(pres.slide[snr].section == "" &  ( 
	   pres.slide[snr].subsection == "" | 
	   pres.settings.topbar.subsec=="nosubsec")) & 
	   pres.slide[snr].type == "regular") {
		
		line = "{p}"
		temp = pres.slide[snr].section
		if (pres.settings.topbar.secbf == "bold") {
			temp = "{bf:" + temp + "}"
		}
		if (pres.settings.topbar.secit == "italic") {
			temp = "{it:" + temp + "}"
		}
		line = line + temp
		if (pres.slide[snr].subsection != "" & 
		    pres.settings.topbar.subsec=="subsec") {
			temp = pres.slide[snr].subsection
			if (pres.settings.topbar.subsecbf == "bold") {
				temp = "{bf:" + temp + "}"
			}
			if (pres.settings.topbar.subsecit == "italic") {
				temp = "{it:" + temp + "}"
			}	
			line = line + pres.settings.topbar.sep + temp
		}
		line = line + "{p_end}"

	}
	else if (pres.slide[snr].type == "ancillary") {
		line = pres.settings.toc.anc
		if (pres.settings.topbar.secbf == "bold") {
			line = "{bf:" + line + "}"
		}
		if (pres.settings.topbar.secit == "italic") {
			line = "{it:" + line + "}"
		}
		line = "{p}" + line + "{p_end}"
	}
	else if (pres.slide[snr].type == "digression") {
		line = pres.settings.digress.name
		if (pres.settings.topbar.secbf == "bold") {
			line = "{bf:" + line + "}"
		}
		if (pres.settings.topbar.secit == "italic") {
			line = "{it:" + line + "}"
		}
		line = "{p}" + line + "{p_end}"
	}
	if (line != "") {
		if (pres.settings.topbar.thline=="hline") {
			fput(dest, "{hline}")
		}
		fput(dest,line)
		if (pres.settings.topbar.bhline=="hline") {
			fput(dest, "{hline}")
		}	
	}
}

void sp_write_bottombar(struct strpres scalar pres, real scalar dest, 
                     real scalar snr, string scalar special) {
	string scalar line, forw, back, forwl
	
	if (special == "title" ) {
		forw = "slide" + strofreal(pres.titleslide.forw) + ".smcl"
		forwl = pres.slide[pres.titleslide.forw].label
		if (forwl == "") {
			forwl = pres.settings.bottombar.nextname
		}
	}
	else if (special == "toc") {
		if (pres.settings.other.titlepage) {
			back = pres.settings.other.stub + ".smcl"
		}
		forw = "slide" + strofreal(pres.tocslide.forw) + ".smcl"
		forwl = pres.slide[pres.tocslide.forw].label
		if (forwl == "") {
			forwl = pres.settings.bottombar.nextname
		}
	}
	else {
		if (pres.slide[snr].prev==0) {
			back = pres.settings.other.stub + ".smcl"
		}
		else if (pres.slide[snr].prev != .){
			back = "slide" + strofreal(pres.slide[snr].prev) + ".smcl"
		}
		if (pres.slide[snr].forw != .) {
			forw = "slide" + strofreal(pres.slide[snr].forw) + ".smcl"
			forwl = pres.slide[pres.slide[snr].forw].label
			if (forwl == "") {
				forwl = pres.settings.bottombar.nextname
			}
		}
	}
	
	fput(dest, " ")
	fput(dest, " ")
	if (pres.settings.bottombar.thline == "hline") {
		fput(dest,"{* /p}{hline}")
	}
	line = "{* bottombar }"
	if (pres.settings.bottombar.arrow == "arrow") {
		line = line + "{center:"
		if (back == "") {
			line = line + "     "
		}
		else {
			line = line + "{view " + back + ":<<}   "
		}
		line = line + "{view " + pres.settings.other.index + ":" + 
		       pres.settings.bottombar.index + "}"
		if (forw == "") {
			line = line + "     "
		}
		else {
			line = line + "   {view " + forw + ":>>}"
		}
		line = line + "}"
	}
	else {
		if (pres.settings.bottombar.next == "right") {
			line = line + "{view " + pres.settings.other.index + ":" +
			       pres.settings.bottombar.index + "}"
			if (forw != "") {
				line = line + "{right:{view " + forw + ":" + forwl + "}}"
			}
		}
		else {
			if (forw != "") {
				line = line + "{view " + forw + ":" + forwl + "}"
			}
			line = line + "{right:{view " + pres.settings.other.index + ":" +
			       pres.settings.bottombar.index + "}}"
		}
	}
	fput(dest, line)
	if (pres.settings.bottombar.bhline == "hline") {
		fput(dest,"{hline}")
	}	
}

void sp_write_title(struct strpres scalar pres, string rowvector line, 
                 real scalar dest, real scalar multiline) {
	
	if (multiline) {
		line = invtokens(line)
	}
	else {
		line = invtokens(line[|2 \ .|])
	}
	fput(dest,"")	
	if (pres.settings.title.thline == "hline" & multiline==0) {
		fput(dest, "{hline}")
	}
	if (pres.settings.title.bold == "bold") {
		line = "{bf:" + line + "}"
	}
	if (pres.settings.title.italic == "italic" ) {
		line = "{it:" + line + "}"
	}
	if (pres.settings.title.pos == "center") {
		line = "{center:" + line + "}"
	}
	else {
		line = "{p}" + line + "{p_end}"
	}
	fput(dest, line)
	if (pres.settings.title.bhline == "hline" & multiline==0) {
		fput(dest, "{hline}")
	}
	fput(dest,"")
}

void sp_write_pres_settings(struct strpres scalar pres, real scalar dest) {
	real scalar snr
	string scalar app, strslides
	
	app = ""
	strslides = pres.settings.other.stub + ".smcl "
	if (pres.settings.other.titlepage) {
		strslides = strslides + "index.smcl "
	}
	for (snr=1 ; snr <= cols(pres.slide) ; snr++) {
		if (pres.slide[snr].type=="regular") {
			strslides = strslides + "slide" + strofreal(snr) + ".smcl "
		}
		else {
			app = app + "slide" + strofreal(snr) + ".smcl "
		}
	}
	strslides = strslides + app

	fput(dest, "{* slides " + strslides + "}{...}" )
	fput(dest, "{* bottomstyle " + pres.settings.bottombar.arrow + " }{...}")
}

end
