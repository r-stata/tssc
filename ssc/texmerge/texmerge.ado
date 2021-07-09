*! version 1.1 	 23 January 2017	Author: Iain Snoddy, iainsnoddy@gmail.com


program define texmerge
	version 12
	syntax anything(name=location), [Files(string) Newfile(string) ///
			PRe(string) POst(string) PDFlatex Saveto(string) Del]
			
	capture confirm file `location'\\`newfile'
	if _rc==0{
		di as error "The file specified in newfile() must not already exist "
		exit
	}
	if "`saveto'"==""{
		di as error "The saveto() option must be provided"
		exit
	}
	if "`saveto'"=="`location'"{
		di as error "The folder given in saveto() cannot be the same as the location of the original .tex files"
		exit
	}
	if "`pdflatex'"!="" & "`pre'"=="" & "`post'"=="" & "`files'"==""{
		di as error "If pre() and post() are not provided to compile accurately files() must then be provided"
		exit
	}

	if "`newfile'"=="" local newfile "mergedfiles.tex"
	
	if ("`pre'"=="" & "`post'"=="") local locationnew "`saveto'"
	else local locationnew "`location'"	
		
	if "`files'"=="" {
		local files: dir "`location'" files "*.tex"
		local files: list sort files
	}
	
	file open newf using `locationnew'\\`newfile', w replace
	file close newf	
	
	foreach filename of local files{ 
		appendfile `location'\\`filename' `locationnew'\\`newfile'
	}
	
	if  "`pre'"=="" & "`post'"=="" {
		if "`pdflatex'"!="" texcompiler `locationnew', files(`newfile') `pdflatex'
	}
	else{
		texcompiler `locationnew', saveto(`saveto') files(`newfile') ///
							pre(`pre') post(`post') `pdflatex' 
		if "`del'"!="" erase `location'\\`newfile'
	}
							
end
