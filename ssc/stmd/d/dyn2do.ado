*! version 2.1
*! Doug Hemken
*! 4 Feb 2019

program define dyn2do, rclass
	syntax anything(name=docfile), [SAVing(string) replace]
	
	version 15
	
	local docfile = ustrtrim(usubinstr(`"`docfile'"', `"""', "", .))
	//confirm file `"`docfile'"'
	
	if ("`saving'" == "" ) {
		di "  {text:No output file specified.}"
		_replaceext using "`docfile'", new("do")
		local saving "`r(newfile)'"
		}
	capture confirm file "`saving'"
	if (_rc==0 & "`replace'"=="") {
		display "    {error: File `saving' already exists, specify replace}
		error
		}
		
	mata: dyn2do("`docfile'", "`saving'")
	
	display "  {text:Output saved as {it:`saving'}}"
	return local outfile "`saving'"
	
end

mata:
void function dyn2do (string scalar filename1, string scalar filename2) {
	X=docread(filename1)
	di_cnt = (ustrlen(X) :- ustrlen(ustrregexra(X, "<<dd_display:", ""))):/ustrlen("<<dd_display:")
	X=expand_display_rows(X,di_cnt)
	line_rep = strtoreal(X[.,2])
	X=X[.,1]
	do_blocks = mark_text_blocks(X, "<<dd_do", "<</dd_do>>", 0)
	ignore_blocks = mark_text_blocks(X, "<<dd_ignore", "<</dd_ignore>>", 0)
	display_lines = ustrpos(X,"<<dd_display:") :> 0
	D = select(X, display_lines)
	D_rep = select(line_rep, display_lines)
	for (i=1;i<=rows(D);i++) {
		if (D_rep[i] > 1) {
			D[i] = usubinstr(D[i], usubstr(D[i], 1, ustrpos(D[i], "<<dd_display:"):+12), "", D_rep[i]-1)
			}
		}
	D = usubinstr(D, usubstr(D, 1, ustrpos(D, "<<dd_display:"):+12), "display ", 1)
	D = usubinstr(D, usubstr(D, ustrpos(D, ">>"), .), "", 1)
	X[selectindex(display_lines)] = D
	unlink(filename2)
	docwrite(filename2, select(X, (do_blocks :| display_lines) :& !ignore_blocks))
}

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
	fh = fopen(filename, "w")
	for (i=1; i<=length(document); i++) {
		fput(fh, document[i])
	}
	fclose(fh)
	}
	
string matrix function expand_display_rows(string colvector X, ///
		real colvector count) {
	string matrix Y
	Y=J(0,2,"")

	for(i=1;i<=rows(X);i++) {
		if (count[i,1] !=0) {
		for(j=1;j<=count[i];j++) {
			Y = Y\(X[i,.],strofreal(j))
			}
		}
		else {
			Y = Y\(X[i,.],"1")
			}
		}
	return(Y)
	}
	
real colvector mark_text_blocks(string colvector doc, ///
		string scalar st_tag, string scalar end_tag, ///
		real scalar include_tags) {
	real colvector blocks, starts, stops
	blocks=.; starts=.; stops=.
	starts=(ustrpos(doc, st_tag):==1)
	stops=(ustrpos(doc, end_tag):==1)
	if (include_tags) {
		blocks=runningsum(starts-stops)+stops
		}
		else {
		// just what is inside the blocks
		blocks=runningsum(starts-stops)-starts
		}
	return(blocks)
	}
end

program define _replaceext, rclass
	syntax using/, new(string)
	version 15
	
	_fileext using "`using'"
	if "`r(extension)'" ~= "" {
		local newfile: subinstr local using "`r(extension)'" "`new'"
		}
		else {
		local newfile "`using'.`new'"
		}
	
	return local newfile "`newfile'"

end

program define _fileext, rclass
	syntax using/
	version 15
	local check: subinstr local using "." "", all
	local dots = length("`using'") - length("`check'")
	if `dots' {
		local undot: subinstr local using "." " ", all
		local wc : word count `undot'
		local extension: word `wc' of `undot'
	} 
	else {
		local extension
		}
	return local extension "`extension'"
end
