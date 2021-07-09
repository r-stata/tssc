mata 

real scalar sp_fopen (struct strpres scalar pres, string scalar file, string scalar mode) {
	real scalar fh
	
	fh = fopen(file, mode)
	asarray(pres.files, fh, "open")
	return(fh)
}

real scalar sp__fopen (struct strpres scalar pres, string scalar file, string scalar mode) {
	real scalar fh
	
	fh = _fopen(file, mode)
	asarray(pres.files, fh, "open")
	return(fh)
}

void sp_fclose (struct strpres scalar pres, real scalar fh) {
    fclose(fh)
	asarray(pres.files, fh, "closed")
}

void sp_fcloseall (struct strpres scalar pres) {
	transmorphic scalar loc
	real         scalar fh
	
	for (loc=asarray_first(pres.files); loc!=NULL; loc=asarray_next(pres.files, loc)) {
		if (asarray_contents(pres.files, loc) == "open" ) {
			fh = asarray_key(pres.files, loc)
			fclose(fh)
			asarray(pres.files, fh, "closed")
		}
    }
}

string scalar sp_remove_tab(struct strpres scalar pres, string scalar str)
{
	return(usubinstr(str, char(9), pres.settings.other.tab*" ", .))
}

real scalar sp_start_slide(struct strpres scalar pres, real scalar snr, string scalar title, real scalar lnr) {
	string scalar destfile, errmsg
	real scalar err, dest
	
	if (title == "titlepage") {
		destfile = pres.settings.other.destdir + "/" + pres.settings.other.stub + ".smcl"
	}
	else {
		destfile = pres.settings.other.destdir + "/slide" + strofreal(snr) + ".smcl"	
	}
	if (pres.settings.other.replace == "replace") {
		err = _unlink(destfile)
		if ( err < 0 ) {
			errmsg = "{p}{err}tried to replace file {res}" + destfile + "{err} on line {res}" + strofreal(lnr) +
			      " {err}but this file is read-only and cannot be removed{p_end}"
			printf(errmsg)
 			exit(608)
		}
	} 
	dest = sp__fopen(pres,destfile,"w")
	if (dest < 0) {
		errmsg = "{p}{err}tried to create file {res}" + destfile + "{err} on line {res}" + strofreal(lnr) +
		      " {err}but this file already exists{p_end}"
		printf(errmsg)
		exit(602)
	}
	fput(dest, "{smcl}")
	fput(dest, "{* " +  st_strscalar("c(current_date)") + "}{...}")
	return(dest)
	
}

real scalar sp_start_ex(struct strpres scalar pres, real scalar snr, real scalar exnr, real scalar lnr) {
	string scalar destfile, errmsg
	real scalar err, dest
	
	destfile = pres.settings.other.destdir + "/slide" + strofreal(snr) + "ex" + strofreal(exnr) + ".do"	

	if (pres.settings.other.replace == "replace") {
		err = _unlink(destfile)
		if ( err < 0 ) {
			errmsg = "{p}{err}tried to replace file " + destfile + " on line {res}" + strofreal(lnr) +
			      " {err}but this file is read-only and cannot be removed{p_end}"
			printf(errmsg)
 			exit(608)
		}
	} 
	dest = sp__fopen(pres,destfile,"w")
	if (dest < 0) {
		errmsg = "{p}{err}tried to create file " + destfile + " on line {res}" + strofreal(lnr) +
		      " {err}but this file already exists{p_end}"
		printf(errmsg)
		exit(602)
	}
	return(dest)
}



void sp_write_slides(struct strpres scalar pres) {
	real scalar snr, exnr, lnr, snrp1, i
	real scalar slideopen, titlepageopen, exopen, txtopen
	real scalar source, dest, exdest
	string scalar line, exname, command, err, rep, lab, dofile, dofile2, db, db2, dir
	string rowvector dirs
	string vector tline
	
	snr  = 0
	exnr = 0
	lnr  = 0
	slideopen = 0
	titlepageopen = 0
	exopen = 0
	txtopen = 0
	source = sp_fopen(pres, pres.settings.other.source, "r")
	while ((line=fget(source))!=J(0,0,"")) {
		lnr = lnr + 1
		line = sp_remove_tab(pres,line)
		tline = tokens(line)
		if (cols(tline) > 0 ) {
			if (tline[1] == "//slide" | tline[1] == "//anc" | tline[1] == "//digr" | tline[1] == "//bib" ) {
				snr  = snr + 1
				exnr = 0
				if (slideopen | titlepageopen ) {
					err = "{p}{err}tried to open a new slide on line {res}" + strofreal(lnr) +
					      " {err}when a slide was already open{p_end}"
					printf(err)
					exit(198)
				}
				slideopen = 1
				dest = sp_start_slide(pres,snr, "", lnr)
				sp_write_topbar(pres, dest, snr)
			}
			else if (tline[1] == "//endslide" | tline[1] == "//endanc" | tline[1] == "//enddigr" | tline[1] == "//endbib") {
				if (slideopen == 0) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when none is open{p_end}"
					printf(err)
					exit(198)
				}
				if (exopen) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when an example was still open{p_end}"
					printf(err)
					exit(198)				
				}
				if (txtopen) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when a textblock was still open{p_end}"
					printf(err)
					exit(198)
				}
				sp_write_bottombar(pres, dest, snr, "regular")
				sp_fclose(pres,dest)
				slideopen = 0
			}
			else if (tline[1] == "//title") {
				if (slideopen == 0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a title on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (exopen) {
					err = "{p}{err}tried adding a title on line {res}" + strofreal(lnr) +
					      " {err}when example was open{p_end}"
					printf(err)
					exit(198)
				}
				sp_write_title(pres,tline, dest, 0)
			}
			else if (tline[1] == "//titlepage") {
				if (slideopen | titlepageopen ) {
					err = "{p}{err}tried to open a new slide on line {res}" + strofreal(lnr) +
					      " {err}when a slide was already open{p_end}"
					printf(err)
					exit(198)
				}
				slideopen = 1
				dest = sp_start_slide(pres,snr, "titlepage", lnr)
			}
			else if (tline[1] == "//endtitlepage") {
			if (slideopen == 0) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when none is open{p_end}"
					printf(err)
					exit(198)
				}
				if (exopen) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when an example was still open{p_end}"
					printf(err)
					exit(198)				
				}
				if (txtopen) {
					err = "{p}{err}tried to close a slide on line {res}" + strofreal(lnr) + 
					      " {err}when a textblock was still open{p_end}"
					printf(err)
					exit(198)
				}
				sp_write_bottombar(pres, dest, snr, "title")
				sp_write_pres_settings(pres,dest)
				sp_fclose(pres,dest)
				slideopen = 0
			}
			else if (tline[1] == "/*txt") {
				if (txtopen == 1) {
					err = "{p}{err}tried to open a textblock on line {res}" + strofreal(lnr) +
					    " {err}when one was already open{p_end}"
					printf(err)
					exit(198)
				}
				if (exopen == 1) {
					err = "{p}{err}tried to open a textblock on line {res}" + strofreal(lnr) +
					    " {err}when an example was already open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen == 0 & titlepageopen == 0) {
					err = "{p}{err}tried to open a textblock on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				txtopen = 1
			}
			else if (tline[1] == "txt*/") {
				if (txtopen == 0 ) {
					err = "{p}{err}tried to close a textblock on line {res}" + strofreal(lnr) + 
					      " {err}when no textblock was open{p_end}"
					printf(err)
					exit(198)
				}
				txtopen = 0
			}
			else if (tline[1] == "//txt") {
				if (slideopen == 0 & titlepageopen == 0) {
					err = "{p}{err}tried to open a single line text on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 1) {
					err = "{p}{err}tried adding a single line text on line {res}" + strofreal(lnr) +
					      " {err}when a textblock was already open{p_end}"
					printf(err)
					exit(198)
				}
				if (exopen == 1) {
					err = "{p}{err}tried to open a single line text on line {res}" + strofreal(lnr) +
					    " {err}when an example was already open{p_end}"
					printf(err)
					exit(198)
				}
				line = subinstr(line, "//txt ", "", 1)
				if ( anyof(tline,"/*digr*/") )  {
					snrp1 = snr + 1
					if (pres.slide[snrp1].type != "digression") {
						err = "{p}{err}a link to a digression was included on line {res}" +
						      strofreal(lnr) + " {err}but the next slide is not " + 
							  "a digression{p_end}"
						printf(err)
						exit(198)
					}
					if (pres.slide[snrp1].label == "") {
						lab = pres.settings.digress.name
					}
					else {
						lab = pres.slide[snrp1].label
					}
					rep = (pres.settings.digress.prefix == ">> " ? 
				            "&gt;&gt; ": pres.settings.digress.prefix ) + lab
					rep = "{* digr <a href=" +
					      `""#slide"' + strofreal(snrp1) + `".smcl">"' +
						  rep + "</a>}{view slide" + strofreal(snrp1) +
						  ".smcl:" + pres.settings.digress.prefix +
						  lab + "}{* /digr}"
					line = subinstr(line, "/*digr*/", rep)
				}
				if (anyof(tline, "/*cite")) {
					line = sp_replaceref(pres, line, snr)
				}
				fput(dest, line)
			}
			else if (tline[1] == "//ex") {
				if (exopen) {
					err = "{p}{err}tried to open a new example on line {res}" + strofreal(lnr) +
					      " {err}when one was already open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried to open an example on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				exopen = 1
				exnr = exnr + 1
				exname = "slide" + strofreal(snr) + "ex" + strofreal(exnr)
				fput(dest, " ")
				fput(dest,"{* ex " + exname  + " }{...}")
				fput(dest,"{cmd}")
				exdest = sp_start_ex(pres,snr,exnr,lnr)
			}
			else if (tline[1] == "//endex") {
				if (exopen == 0) {
					err = "{p}{err}tried to close an example on line {res}" + strofreal(lnr) +
					      " {err}when none was open{p_end}"
					printf(err)
					exit(198)
				}
				fput(dest, "{txt}{...}")
				command = `"""'+ "do " + exname + ".do" + `"""'
				fput(dest, "{pstd}({stata " +  command +  ":" + 
				             pres.settings.example.name + "}){p_end}")
				fput(dest,"")
				fput(dest,"")
				fput(dest,"{* endex }{...}")
				sp_fclose(pres,exdest)
				exopen = 0
			}
			else if (tline[1] == "//graph") {
				if (exopen) {
					err = "{p}{err}tried adding a graph comment on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a graph comment on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (cols(tline) == 1) {
					err = "{p}{err}no graph name(s) mentioned after //graph on line {res}" +
					      strofreal(lnr) + "{p_end}"
				}
				line = "{* graph " + invtokens(tline[|2 \ .|]) + " }{...}"
				if (txtopen == 0) {
					fput(dest, line )
				}
			}
			else if (tline[1] == "//file") {
				if (cols(tline)!= 2) {
					err = "{p}{err}1 file must be specified after //file on line {res}" + 
					      strofreal(lnr) + "{p_end}"
					printf(err)
					exit(198)
				}
				dofile = pres.settings.other.sourcedir + "/" + tline[2]
				if (!fileexists(dofile)) {
					err = "{p}{err}file {res}" + dofile + "{err} specified after //file" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 = pres.settings.other.destdir + "/" + tline[2]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				tline = J(1,0, "")
			}
			else if (tline[1] == "//dir") {
				if (cols(tline)!= 2) {
					err = "{p}{err}1 directory must be specified after //dir on line {res}" + 
					      strofreal(lnr) + "{p_end}"
					printf(err)
					exit(198)
				}	
				dirs = usubinstr(tline[2], "\", "/", .)
				dirs = tokens(dirs, "/")
				dir = pres.settings.other.destdir 
				for(i=1; i <= cols(dirs) ; i++) {
					if (dirs[i] != "/") {
						dir = dir + "/" + dirs[i]
						if (!direxists(dir)) mkdir(dir)
					}
				}
				
			}
			else if (tline[1] == "//dofile") {
				if (exopen) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) + 
					    "{err}when no text block was open{p_end}"
				}
				if (cols(tline) == 1 | cols(tline) > 3) {
					err = "{p}{err}the //dofile command on line {res}" + strofreal(lnr) +
					      " {err}must specify 1 file and a label{p_end}"
					printf(err)
					exit(198)
				}
				dofile = pres.settings.other.sourcedir + "/" + tline[2]
				if (!fileexists(dofile)) {
					err = "{p}{err}file {res}" + dofile + "{err} specified after //dofile" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 = pres.settings.other.destdir + "/" + tline[2]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				if (cols(tline) == 2) {
					line = "{* dofile " + tline[2] + " }{...}"
				}
				else {
					line = "{* dofile " + tline[2] + " }" + 
						  "{pstd}{stata " + `"""' + "doedit " + tline[2] + `"""' + 
						  ":" + tline[3] + "}{p_end}"'
				}
			}
			else if (tline[1] == "//apdofile") {
				if (exopen) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a link to a dofile on line {res}" + strofreal(lnr) + 
					    "{err}when no text block was open{p_end}"
				}
				if (cols(tline) == 1 | cols(tline) > 3) {
					err = "{p}{err}the //apdofile command on line {res}" + strofreal(lnr) +
					      " {err}must specify 1 file and a label{p_end}"
					printf(err)
					exit(198)
				}				
				dofile = pres.settings.other.sourcedir + "/" + tline[2]
				if (!fileexists(dofile)) {
					err = "{p}{err}file {res}" + dofile + "{err} specified after //apdofile" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 = pres.settings.other.destdir + "/" + tline[2]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				if (cols(tline) == 2) {
					line = "{* apdofile " + tline[2] + " }{...}"
				}
				else {
					line = "{* apdofile " + tline[2] + " " + tline[3] + " }" + 
						   "{pstd}{stata " + `"""' + "doedit " + tline[2] + `"""' + 
						  ":" + tline[3] + "}{p_end}"'
				}
			}
			else if (tline[1] == "//codefile") {
				if (exopen) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) + 
					    "{err}when no text block was open{p_end}"
				}
				if (cols(tline) == 1 | cols(tline) > 3) {
					err = "{p}{err}the //codefile command on line {res}" + strofreal(lnr) +
					      " {err}must specify 1 file and a label{p_end}"
					printf(err)
					exit(198)
				}				
				dofile = pres.settings.other.sourcedir + "/" + tline[2]
				if (!fileexists(dofile)) {
					err = "{p}{err}file {res}" + dofile + "{err} specified after //codefile" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 = pres.settings.other.destdir + "/" + tline[2]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				if (cols(tline) == 2) {
					line = "{* codefile " + tline[2] + " }{...}"
				}
				else {
					line = "{* codefile " + tline[2] + " }" + 
						   "{pstd}{stata " + `"""' + "doedit " + tline[2] + `"""' + 
						  ":" + tline[3] + "}{p_end}"'	
				}
			}
			else if (tline[1] == "//apcodefile") {
				if (exopen) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a link to a codefile on line {res}" + strofreal(lnr) + 
					    "{err}when no text block was open{p_end}"
				}
				if (cols(tline) == 1 | cols(tline) > 3) {
					err = "{p}{err}the //apcodefile command on line {res}" + strofreal(lnr) +
					      " {err}must specify 1 file and a label{p_end}"
					printf(err)
					exit(198)
				}				
				dofile = pres.settings.other.sourcedir + "/" + tline[2]
				if (!fileexists(dofile)) {
					err = "{p}{err}file {res}" + dofile + "{err} specified after //apcodefile" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 = pres.settings.other.destdir + "/" + tline[2]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				if (cols(tline) == 2) {
					line = "{* apcodefile " + tline[2] + " }{...}"
				}
				else {
					line = "{* apcodefile " + tline[2] + " " + tline[3] + " }" +
						   "{pstd}{stata " + `"""' + "doedit " + tline[2] + `"""' + 
						  ":" + tline[3] + "}{p_end}"'
				}
			}
			else if (tline[1] == "//db") {
				if (exopen) {
					err = "{p}{err}tried adding a link to a dialogbox on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a link to a dialogbox on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a link to a dialogbox on line {res}" + strofreal(lnr) + 
					    "{err}when no text block was open{p_end}"
				}
				if (cols(tline) != 4) {
					err = "{p}{err}the //db command on line {res}" + strofreal(lnr) +
					      " {err}must specify 1 dialog box, 1 do file, and a label{p_end}"
					printf(err)
					exit(198)
				}
				db = pres.settings.other.sourcedir + "/" + tline[2] + ".dlg"
				if (!fileexists(db)) {
					err = "{p}{err}file {res}" + db + "{err} specified after //db" +
					      " on line {res}" + strofreal(lnr) + " {err}does not exist{p_end}"
					printf(err)
					exit(198)
				}
				db2 = pres.settings.other.destdir + "/" + tline[2] + ".dlg"
				if (!fileexists(db2)) {
					command = `"copy ""' + db + `"" ""' + db2 + `"""'
					stata( command, 1)
				}
				dofile =  pres.settings.other.sourcedir + "/" + tline[3]
				if (!fileexists(dofile)){
					err = "{p}{err}file {res}" + dofile + "{err} specified after //db" +
					      "on line {res} " + strofreal(lnr) + "{err} does not exist{p_end}"
					printf(err)
					exit(198)
				}
				dofile2 =  pres.settings.other.destdir + "/" + tline[3]
				if (!fileexists(dofile2)) {
					command = `"copy ""' + dofile + `"" ""' + dofile2 + `"""'
					stata( command, 1)
				}
				line = "{* dofile " + tline[3] + " }" + 
					  "{pstd}{stata " + `"""' + "db " + tline[2] + `"""' + 
					  ":" + tline[4] + "}{p_end}"'

			}			
			else if (tline[1] == "//ho_ignore") {
				if (exopen) {
					err = "{p}{err}tried adding a ho_ignore comment on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 & titlepageopen == 0) {
					err = "{p}{err}tried adding a ho_ignore comment on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 0) {
					err = "{p}{err}tried adding a ho_ignore comment on line {res}" + strofreal(lnr) +
					      " {err}when no textblock was open{p_end}"
					printf(err)
					exit(198)
				}
				line = "{* ho_ignore }" + subinstr(line, "//ho_ignore", "", 1)
			}
			else if (tline[1] == "//bib_here" | tline[1] == "/*bib") {
				if (exopen) {
					err = "{p}{err}tried adding a bibliography on line {res}" + strofreal(lnr) +
					      " {err}when an example was open{p_end}"
					printf(err)
					exit(198)
				}
				if (slideopen==0 ) {
					err = "{p}{err}tried adding a bibliography on line {res}" + strofreal(lnr) +
					      " {err}when no slide was open{p_end}"
					printf(err)
					exit(198)
				}
				if (txtopen == 1) {
					err = "{p}{err}tried adding a bibliography on line {res}" + strofreal(lnr) +
					      " {err}when an textblock was open{p_end}"
					printf(err)
					exit(198)
				}
				if (snr != pres.bib.bibslide) {
					err = "{p}{err}tried adding a bibliography on line {res}" + strofreal(lnr) +
					      " {err}on a non bibliography slide{p_end}"
					printf(err)
					exit(198)
				}
				sp_write_bib(pres, dest)
			}	
		}
		if (txtopen) {
			if (cols(tline) > 0) {
				if (tline[1] != "/*txt") {
					if ( anyof(tline, "/*digr*/") ) {
						snrp1 = snr + 1
						if (pres.slide[snrp1].type != "digression") {
							err = "{p}{err}a link to a digression was included on line {res}" +
							      strofreal(lnr) + " {err}but the next slide is not " + 
								  "a digression{p_end}"
							printf(err)
							exit(198)
						}
						if (pres.slide[snrp1].label == "") {
							lab = pres.settings.digress.name
						}
						else {
							lab = pres.slide[snrp1].label
						}
						rep = (pres.settings.digress.prefix == ">> " ? 
				             "&gt;&gt; ": pres.settings.digress.prefix ) + lab
						rep = "{* digr <a href=" +
						      `""#slide"' + strofreal(snrp1) + `".smcl">"' +
							  rep + "</a>}{view slide" + strofreal(snrp1) +
							  ".smcl:" + pres.settings.digress.prefix +
							  lab + "}{* /digr}"
						line = subinstr(line, "/*digr*/", rep)
					}
					if (anyof(tline, "/*cite")) {
						line = sp_replaceref(pres, line, snr)
					}
					fput(dest, line)
				}
			}
			else {
				fput(dest,line)
			}
		}
		if (exopen) {
			if (cols(tline)>0) {
				if (tline[1] != "//ex") {
					fput(dest, "        " + line)
					fput(exdest, line)
				}
			}
			else {
				fput(dest, line)
				fput(exdest, line)
			}
		}
	}
	sp_fclose(pres,source)
	if (txtopen) {
		err = "{p}{err}reached end of sourcefile, but a textblock is still open{p_end}"
		printf(err)
		exit(198)
	}
	if (exopen) {
		err = "{p}{err}reached end of sourcefile, but an example is still open{p_end}"
		printf(err)
		exit(198)
	}
	if (slideopen | titlepageopen) {
		err = "{p}{err}reached end of sourcefile, but a slide is still open{p_end}"
		printf(err)
		exit(198)
	}	
}

end
