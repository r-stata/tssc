*! version 1.6
*! Doug Hemken
*! 4 Feb 2019

// ISSUES
// ======
// put preamble(s) after any initial dynamic tags, like dd_version or dd_include
// better, more extensive preamble, e.g. linesize, other options?
// NOGRaph option

// capture program drop stmd2dyn
// capture mata: mata clear
program define stmd2dyn, rclass
	syntax anything(name=infile), [ ///
		SAVing(string) replace ///
		noGRAPHlinks ///
		]

	version 15
	
	local infile = ustrtrim(usubinstr(`"`infile'"', `"""', "", .))
*display `"infile is `infile'"'	
	confirm file `"`infile'"'
*display "infile confirmed"	
	if ("`saving'" == "" ) {
		mata:(void)pathchangesuffix("`infile'", "dyn", "saving", 0)
		mata: (void)st_local("saving", pathjoin("`c(pwd)'", `"`saving'"'))
		}
	mata: (void)pathresolve("`c(pwd)'", `"`saving'"', "saving")
*display `"saving `saving'"'
	
	local issame = 0
	mata: (void)filesarethesame("`infile'", "`saving'", "issame")
	if ("`issame'" == "1") {
display in error "target file can not be the same as the source file"
		exit 602			
	}
	if ("`replace'"=="") {
		confirm new file "`saving'"
		}

* Read in file
	mata: X=docread("`infile'")
//mata: X	
* Then identify code blocks and tags
	mata: fenceinfo = _fence_info(X) // fences
//mata: fenceinfo
	mata: infotags  = _info_tags(X)  // retrieve infotags
	mata: tagmatchs = _tag_match(infotags) // parse infotags
	mata: dotags = _dd_do(fenceinfo, tagmatchs) // generate <<dd_do>>

* Identify display directives
	mata: X = _inline_code(X, fenceinfo[.,3])
//mata: X
* assemble pieces of a dyndoc
	mata: document = _stitch(X, fenceinfo, dotags)
//mata: document
* Write out the result
	mata: saving = st_local("saving")
	mata: docwrite(saving, document)
	display "  {text:Output saved as {it:`saving'}}"

* Finish up
	return local outfile "`saving'"
end

mata
string colvector docread(string scalar filename) {
	fh = fopen(filename, "r")
	string colvector document
	document= J(0,1,"")
	while ((line=fget(fh))!=J(0,0,"")) {
		document = (document\line)
	}
	fclose(fh)
	return(document)
	}
	
void function docwrite(string scalar filename, ///
		string colvector document) {
	unlink(filename)
	fh = fopen(filename, "w")
	for (i=1; i<=length(document); i++) {
		fput(fh, document[i])
	}
	fclose(fh)
	}
	
real matrix function _fence_info(string colvector X) {

	codefence = "^( ? ? ?)(```+|~~~+)([ ]*)$"
	infofence = "^( ? ? ?)(```+|~~~+)\{?(s|stata)\/?(,.*)?\}?$"

	fence = ustrregexm(X, codefence)
	codebegin = ustrregexm(X, infofence)
	fence = fence + codebegin  // any code fence
	prespace = J(rows(X),1,.)  // possible spaces before code fence
	cbdepth = J(rows(X),1,0)   // depth of code fencing
	fencel = J(rows(X),7,.)    // # of characters used in fence
	doblock = 0                // dynamic code

	for (i=1; i<=rows(X); i++) {
		// find and characterize fences
		if (i>=2) {  //lag fence depth and fence length(s)
			cbdepth[i]=cbdepth[i-1]
			fencel[i,.]=fencel[i-1,.]
			}
		if (ustrregexm(X[i,1], infofence) | ustrregexm(X[i,1], codefence)) {
			if (ustrregexm(X[i,1], infofence)) {
				prespace[i] = ustrlen(ustrregexs(1))
				fl = ustrlen(ustrregexs(2))
			}
			else if (ustrregexm(X[i,1], codefence)) {
				prespace[i] = ustrlen(ustrregexs(1))
				fl = ustrlen(ustrregexs(2))
			}
		// doable?
		if (cbdepth[i]==0 & ustrregexm(X[i,1], infofence)) {
			cbdepth[i]=cbdepth[i]+1
			fencel[i, cbdepth[i]]   = fl
			codebegin[i] = 1 // redundant
			doblock = 1
			}
			// not doable: deeper?
			else if (ustrregexm(X[i,1], infofence) | cbdepth[i]==0) {
				cbdepth[i]=cbdepth[i]+1
				fencel[i, cbdepth[i]]   = fl
				codebegin[i] = 0 // redundant
			}
			// also deeper
			else if (fl < fencel[i, cbdepth[i]]) {
				cbdepth[i]=cbdepth[i]+1
				fencel[i, cbdepth[i]]   = fl
			}
			else {
				fencel[i, cbdepth[i]] = .
				cbdepth[i] = cbdepth[i]-1
			}
			// is this the end of doable?
			if (cbdepth[i]==0 & doblock) {
				codebegin[i] = -1
				doblock=0
			}
		}

	}
	return(fence,codebegin,cbdepth,prespace,fencel)
}

string colvector function _info_tags(string colvector X) {
	infofence = "^( ? ? ?)(```+|~~~+)\{?(s|stata)\/?(,.*)?\}?$"
//infofence
	infotags = J(rows(X),1,"")
	for (i=1; i<=rows(X); i++) {
		if (ustrregexm(X[i,1], infofence)) {
			infotags[i]  = ustrregexs(4)
		}
	}
	return(infotags)
}

real matrix function _tag_match(string colvector infotags) {
	codeopts = ustrregexm(infotags, ",")
	noeval   = ustrregexm(infotags, "eval=FALSE")
	noecho1 = ustrregexm(infotags, "echo=FALSE")
	noecho2 = ustrregexm(infotags, "\/")
	noecho3 = ustrregexm(infotags, "nocommands")
	noecho4 = ustrregexm(infotags, "quietly")
	noecho = noecho1+noecho2+noecho3+noecho4
	noresults1 = ustrregexm(infotags, "results=FALSE")
	noresults2 = ustrregexm(infotags, `"results="hide""')
	noresults3 = ustrregexm(infotags, "nooutput")
	noresults4 = ustrregexm(infotags, "quietly")
	noresults = noresults1+noresults2+noresults3+noresults4
	//noprompt1 = ustrregexm(infotags, "noprompt=TRUE")
	//noprompt2 = ustrregexm(infotags, "noprompt")
	//noprompt = noprompt1+noprompt2
	noprompt = ustrregexm(infotags, "noprompt")
	
	return(codeopts, noeval, noecho, noresults, noprompt)
}

string colvector function _dd_do(real matrix fenceinfo, real matrix tagmatch) {
	dotags = J(rows(fenceinfo),1,"")
	noeval = 0
	for (i=1; i<=rows(fenceinfo); i++) {
		if (fenceinfo[i,2]==1) {
			if (sum(tagmatch[i,.])==0) dotags[i,1]=("<<dd_do>>")
			else if (tagmatch[i,3]==1) {
				if (tagmatch[i,4]==0) dotags[i,1]=("<<dd_do: nocommands>>")
				else if (tagmatch[i,4]==1) dotags[i,1]=("<<dd_do: quietly>>")
				}
			else if (tagmatch[i,3]==0 & tagmatch[i,4]==1) dotags[i,1]=("<<dd_do: nooutput>>")
			else if (tagmatch[i,5]==1) dotags[i,1]=("<<dd_do: noprompt>>")
			else if (tagmatch[i,2]==1) noeval=1
			}
		else if (fenceinfo[i,2]==-1) {
			if (noeval==0) dotags[i,1]=("<</dd_do>>")
			else if (noeval==1) noeval=0
			}
		else dotags[i,1]=("")
		}
	return(dotags)
}

string colvector function _gr_preamble() {
	GR = "<<dd_do: quietly>>"\			
		"capture graph describe Graph"\ 
		"tempname gdate"\				
		`"local \`gdate' = "\`r(command_date)' \`r(command_time)'" "'\ 
		"<</dd_do>>"
	return(GR)	
	}

string colvector function _gr_link() {
	GL = `"<<dd_do: quietly>>"' \
		`"capture _return hold rtemp"' \
		`"capture graph describe Graph"' \
		`"local checkdate = "\`r(command_date)' \`r(command_time)'" "' \
		`"<</dd_do>>"' \
		`"<<dd_skip_if: ="\`\`gdate''"~="" & "\`\`gdate''"=="\`checkdate'">>"' \
		`"<<dd_graph>>"' \
		`"<<dd_skip_end>>"' \
		`"<<dd_do: quietly>>"' \
		`"local \`gdate' = "\`r(command_date)' \`r(command_time)'""' \
		`"capture _return restore rtemp"' \
		`"sleep 500"' \
		`"<</dd_do>>"' 
	return(GL)	
	}
	
string colvector function _stitch(string colvector X,
		real matrix fenceinfo, string colvector dotags) {
	lce = 0     // last code end line
	quiet = 0   // quietly flag
	Y = _gr_preamble()
	for (i=1; i<=rows(X); i++) {
	//X[i,.]
		if (fenceinfo[i,2]==1) {
			if (dotags[i,1]=="<<dd_do: quietly>>") {
	//X[i,.],dotags[i,.]
					Y = Y \ X[(lce+1)..(i-1),.]\dotags[i,.]
					lce = i
					quiet = 1
				}
				else {
					Y = Y \ X[(lce+1)..i,.]\dotags[i,.]
					lce = i
				}
			}
		else if (fenceinfo[i,2]==-1) {
			if (quiet==1) {
				Y= Y \X[(lce+1)..(i-1),.]\dotags[i,.]\_gr_link()
				lce = i
				quiet=0
				}
				else {
					Y= Y \X[(lce+1)..(i-1),.]\dotags[i,.]\X[i,.]\_gr_link()
					lce = i
				}
			}
		else if (i==rows(X)) {
			Y= Y \ X[(lce+1)..i,.]
			}
		}
	return(Y)
	}
	
string colvector function _inline_code(string colvector X, real colvector cbdepth) {
	for (i=1; i<=rows(X); i++) {
		if (cbdepth[i] == 0) {
			dispdir = ustrregexm(X[i,1], "(`|~)\{?(s|stata)\}?( )+(.*)(`)")
			while (dispdir) {
				X[i,1] = ustrregexra(X[i,1], "(`|~)\{?(s|stata)\}?( )+", "<<dd_display: ")
				X[i,1] = ustrregexra(X[i,1], "`", ">>")
				dispdir = ustrregexm(X[i,1], "(`|~)\{?(s|stata)\}?( )+(.*)(`)")
				}
			}
		}
	return(X)
	}

end
