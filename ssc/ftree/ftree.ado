/*---------------------------
06Feb2010 - version 1.0
01Oct2010 - version 2.0
22Dec2018 - version 3.0

save informations of the current directory into a txt file

Author: Liu Wei, The School of Sociology and Population Studies, Renmin University of China
E-mail: liuv@ruc.edu.cn
---------------------------*/
capture program drop ftree
program define ftree
	version 9
	syntax, Save(string) [Path(string) Dir(string)]
	while "`c(os)'" != "Windows" {	
		di as result _n "Note: " as txt "This program runs only on Windows System!"
		exit
	}
	if "`path'"!=""{
		local mydir="`path'\"
	}
	else {
		local mydir=""
	}
	while "`dir'"!="" & "`dir'"!="dir" & "`dir'"!="tree" & "`dir'"!="catalogue"{
		di as result _n "Syntax Note: " as erro "dir() must be specified as {it:dir}, {it:tree}, {it:catalogue} or keep empty !"
		exit
	}
	if "`dir'"=="dir" | "`dir'"=="" {
		!@dir /s/a >"`path'""`save'"_dir.txt
			if "`path'"!="" {
				di as txt _n "File " as result "`save'_dir.txt " as txt "saved to " as result "`path'"
			}
			else {
				di as txt _n "File " as result "`save'_dir.txt " as txt "saved to " as result"`c(pwd)'`c(dirsep)'"
			}
	}
	if "`dir'"=="tree" | "`dir'"=="" {
		!@tree /f >"`path'""`save'"_tree.txt
			if "`path'"!="" {
				di as txt _n "File " as result "`save'_tree.txt " as txt "saved to " as result "`path'"
			}
			else {
				di as txt _n "File " as result "`save'_tree.txt " as txt "saved to " as result"`c(pwd)'`c(dirsep)'"
			}
	}
	if "`dir'"=="catalogue" | "`dir'"=="" {
		!@tree >"`path'""`save'"_catalogue.txt
			if "`path'"!="" {
				di as txt _n "File " as result "`save'_catalogue.txt " as txt "saved to " as result "`path'"
			}
			else {
				di as txt _n "File " as result "`save'_catalogue.txt " as txt "saved to " as result"`c(pwd)'`c(dirsep)'"
			}
	}	
end
