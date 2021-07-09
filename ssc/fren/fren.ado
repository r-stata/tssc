/*---------------------------
06Oct2010 - version 1.0

Batch File Renamer

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture prog drop fren
prog define fren
	version 9
	syntax anything(name=clist), From(string) [To(string)]
	while "`c(os)'" != "Windows" {	
		di as result _n "Note: " as txt "This program runs only on Windows System!"
		exit
	}
	local list: dir "`r(cmd)'" files"*.`clist'"
	local n=0
	foreach x of local list {
		local temp1=subinstr("`x'",".`clist'","",.)
		if strpos("`temp1'","`from'")!=0{
			local temp2=subinstr("`temp1'","`from'","`to'",.)
			!ren "`x'" "`temp2'.`clist'"
			local n=`n'+1
		}		
	}
	di as result _n "`n' " as txt "files renamed!"
end
