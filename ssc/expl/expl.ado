*! version 1.0, 17 March2012
*Written by Chamara Anuranga (kcanuranga@gmail.com)
*Program to browse folder and open files and folder
	version 8.0
*Singel ado file do open file, folder, do fiels and stata data
*created by chamara


	

	capture program drop expl
	program define expl

	syntax,[path(string) nfolder(string) action(string)]


if "`c(os)'"=="Windows" {
	
		if "`path'"=="" {
		local path="`c(pwd)'"
			local lenpath=length("`path'")
				if `lenpath'==2 {
					local path="`path1'\"
				}
		local nfolder="."
		local action="bfolder"
		*dis "`path'"
		}
*________________________________________________*
	if "`nfolder'"!="" & "`action'"=="bfolder" {
		display as error  "{bf: {ul: My Computer}}"
		local pathorg="`c(pwd)'"
			local lenpath=length("`path'")
				if `lenpath'==2 {
					local pathorg="`path1'\"
				}
				
		foreach list in `c(ALPHA)' {
		capture cd "`list':\"
		local rc=_rc
		if _rc==0 {
		 dis "{stata expl,path(`list'~) action(bfolder) nfolder(.):`list'}" "{tab}""{ul: {stata expl ,path(`list'~) nfolder(.) action(folder):open}}"
		 }	 
		}	
		qui cd "`pathorg'"
	}
		
		
		
		
*Current path for windows
		local path1=subinstr("`path'","~",":",1)
		local lenpath=length("`path1'")
			if `lenpath'==2 {
					local path1="`path1'\"
			}
		
*Open folder
			if "`nfolder'"!="." & "`action'"=="folder" {
				qui { 
					local cpath="`c(pwd)'"
					local lenpath=length("`cpath'")
						if `lenpath'==2 {
							local cpath="`cpath'\"
						}			
					cd "`path1'"
					cd "`nfolder'"
					shell start .
					cd "`cpath'"
					}
			}
				
			if "`nfolder'"=="." & "`action'"=="folder" {
				qui {
					local cpath="`c(pwd)'"	
					local lenpath=length("`cpath'")
						if `lenpath'==2 {
							local cpath="`cpath'\"
						}					
					
					dis "`path1'"
					cd "`path1'"
					shell start .
					cd "`cpath'"
				}
			}
*Open file
			if "`action'"=="file" {
				local cpath="`c(pwd)'"	
				local lenpath=length("`cpath'")
					if `lenpath'==2 {
						local cpath="`cpath'\"
					}				
				qui cd "`path1'"
				shell  "`nfolder'"
				qui cd "`cpath'"
			}	
*Open do file
			if "`action'"=="dofile" {
				local cpath="`c(pwd)'"	
				local lenpath=length("`cpath'")
					if `lenpath'==2 {
						local cpath="`cpath'\"
					}				
				qui cd "`path1'"
				doedit  "`nfolder'"
				qui cd "`cpath'"
			}	
			
*Open dta
			if "`action'"=="dtafile" {
				local cpath="`c(pwd)'"	
				local lenpath=length("`cpath'")
					if `lenpath'==2 {
						local cpath="`cpath'\"
					}				
				qui cd "`path1'"
				use  "`nfolder'"
				qui cd "`cpath'"
			}			

*Change directory to folder
			if "`nfolder'"!="" & "`action'"=="bfolder" {
				qui cd "`path1'"
				qui cd "`nfolder'"
				local temp="`c(pwd)'"
				local cpath=subinstr("`temp'",":","~",1)
				dis "{center: }{title: Explore the Folders and Files}"
				dis "{center: }{stata expl,path(`cpath') action(folder) nfolder(.) : open}" "{input: current folder}" ":`c(pwd)'"
				dis "{hline `c(linesize)'}"
				dis "_____________________"
				dis "{title:Folders}"	
				dis "_____________________"
				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Folders~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/		
				local flist : dir . dirs "*", respectcase
				foreach list1 of local flist {
				local abname = abbrev("`list1'",20)
				dis "{stata expl,path(`cpath') action(bfolder) nfolder(`list1'):`abname'}" _column(25) "{ul:{stata expl,path(`cpath') action(folder) nfolder(`list1'): open }}"
				}
				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
				dis "_____________________"	
				dis "{title:Files}"
				dis "_____________________"
				
				local flsit : dir . files "*.*" , respectcase	
				foreach f of local flsit{
*Remove do fiels and stata data
				local sub3=substr("`f'",-3,.)
				local sub4=substr("`f'",-4,.)
					if "`sub3'"~=".do" & "`sub4'"~=".dta" {
				 		dis "{stata expl,path(`cpath') action(file) nfolder(`f'): `f'}"
					}
				}								
	/*~~~~~~~~~~~~~~~~~~~~~~~~Dofiles~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
			
				dis "_____________________"
				dis "Do Files"
				dis "_____________________"
				local file1 : dir . files "*.do" , respectcase	
					foreach f of local file1 {	
				 		dis "{stata expl,path(`cpath') action(dofile) nfolder(`f'): `f'}"
					}				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Stata data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
			
				dis "_____________________"
				dis "Stata Data Files"
				dis "_____________________"
				local file1 : dir . files "*.dta" , respectcase	
					foreach f of local file1 {	
				 		dis "{stata expl,path(`cpath') action(dtafile) nfolder(`f'): `f'}"
					}	
				}
			}	

		
*___________________________________________________________________________________
else {	

	
		if "`path'"=="" {
		local path="`c(pwd)'"
		local nfolder="."
		local action="bfolder"
		}
*________________________________________________*
	if "`nfolder'"!="" & "`action'"=="bfolder" {
		display as error  "{bf: {ul: My Computer}}"
		local pathorg="`c(pwd)'"
		cd /volumes/
		local flist : dir . dirs "*", respectcase
		foreach list of local flist {
		 dis "{stata expl,path(/volumes/`list') action(bfolder) nfolder(.):`list'}" _column(25)"{ul: {stata expl ,path(/volumes/`list') nfolder(.) action(folder):open}}"
		 }	 
		
		qui cd "`pathorg'"
	}
		
		
		
		
*Current path
		local path1="`path'"
		
*Open folder
			if "`nfolder'"!="." & "`action'"=="folder" {
				qui { 
					local cpath="`c(pwd)'"
					cd "`path1'"
					cd "`nfolder'"
					shell open .
					cd "`cpath'"
					}
			}
				
			if "`nfolder'"=="." & "`action'"=="folder" {
				qui {
					local cpath="`c(pwd)'"	
					dis "`path1'"
					cd "`path1'"
					shell open .
					cd "`cpath'"
				}
			}
*Open file
			if "`action'"=="file" {
				local cpath="`c(pwd)'"	
				qui cd "`path1'"
				shell  open "`nfolder'"
				qui cd "`cpath'"
			}	
*Open do file
			if "`action'"=="dofile" {
				local cpath="`c(pwd)'"				
				qui cd "`path1'"
				doedit  "`nfolder'"
				qui cd "`cpath'"
			}	
			
*Open dta
			if "`action'"=="dtafile" {
				local cpath="`c(pwd)'"	
				qui cd "`path1'"
				use  "`nfolder'"
				qui cd "`cpath'"
			}			

*Change directory to folder
			if "`nfolder'"!="" & "`action'"=="bfolder" {
				qui cd "`path1'"
				qui cd "`nfolder'"
				local cpath="`c(pwd)'"
				dis "{center: }{title: Explore the Folders and Files}"
				dis "{center: }{stata expl,path(`cpath') action(folder) nfolder(.) : open}" "{input: current folder}" ":`c(pwd)'"
				dis "{hline `c(linesize)'}"
				dis "_____________________"
				dis "{title:Folders}"	
				dis "_____________________"
				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Folders~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/		
				local flist : dir . dirs "*", respectcase
				foreach list1 of local flist {
				local abname = abbrev("`list1'",20)
				dis "{stata expl,path(`cpath') action(bfolder) nfolder(`list1'):`abname'}" _column(25) "{ul:{stata expl,path(`cpath') action(folder) nfolder(`list1'): open }}"
				}
				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
				dis "_____________________"	
				dis "{title:Files}"
				dis "_____________________"
				
				local flsit : dir . files "*.*" , respectcase	
				foreach f of local flsit{
*Remove do fiels and stata data
				local sub3=substr("`f'",-3,.)
				local sub4=substr("`f'",-4,.)
					if "`sub3'"~=".do" & "`sub4'"~=".dta" {
				 		dis "{stata expl,path(`cpath') action(file) nfolder(`f'): `f'}"
					}
				}								
	/*~~~~~~~~~~~~~~~~~~~~~~~~Dofiles~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
			
				dis "_____________________"
				dis "Do Files"
				dis "_____________________"
				local file1 : dir . files "*.do" , respectcase	
					foreach f of local file1 {	
				 		dis "{stata expl,path(`cpath') action(dofile) nfolder(`f'): `f'}"
					}				
	/*~~~~~~~~~~~~~~~~~~~~~~~~Stata data~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/			
			
				dis "_____________________"
				dis "Stata Data Files"
				dis "_____________________"
				local file1 : dir . files "*.dta" , respectcase	
					foreach f of local file1 {	
				 		dis "{stata expl,path(`cpath') action(dtafile) nfolder(`f'): `f'}"
					}	
				}
	}	
				
			end
	
