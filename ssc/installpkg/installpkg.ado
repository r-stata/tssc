*! version 1.3.1 , 2021-03-22
*! version 1.3
*  2020-03-02
* add some User Interactions
*！version 1.2
* Kerry Du, 2020-03-02
cap prog drop installpkg
program define installpkg
  
  version 14
	syntax, from(string) [replace force]

	tokenize `"`0'"', p(",")
	//local rnew=subinstr(`"`2'"',`"from(`from')"',"",1)
	local rnew=regexr(`"`2'"',"(from)(\()(.+)(\))","")
	//splitfrom `0'
	local pwd=c(pwd)
	if regexm("`from'","(\.pkg)$"){
	   local     from=subinstr("`from'","\","/",.)
       local     path=regexr("`from'","/[^/]+$","")
       local     pkg=regexr("`from'","^(.+)\/","")  
       local     pkg=regexr("`pkg'","(\.pkg)$","")

        mata: st_local("pathisurl",strofreal(pathisurl("`from'") ))
		if("`pathisurl'"=="1"){
       		net install `pkg', from(`path') `rnew' 
            exit
           
		}


       cap findfile stata.toc, path(`path')
       if(_rc!=0){
       	    global file_path_ "`path'"
       	    global file_path_pkgs `pkg'
       	    global file_path_rnew `rnew'
       		db createtoc
       		exit
       }
       else{
       		  net install `pkg', from(`path') `rnew' 
              exit
       }


	}
	if !regexm("`from'","(\.zip)$"){
		mata: st_local("pathisurl",strofreal(pathisurl("`from'") ))
		if("`pathisurl'"=="0"){

		   qui local pkgs: dir "`from'" files "*.pkg"

		   if(`"`pkgs'"'==""){

		   		//di as red ".pkg NOT found"
		   		//di as red `"No installable packages in `from'"'
		   		//global selected_files_: dir "`path'" files "*"
		   		//qui cd 	`path'
		   		db nextcpkg
		   		//qui cd `pwd'
		   		exit	

		   }
		   else{
		   		cap findfile stata.toc, path(`from')
		   		if(_rc!=0){
		   		   global file_path_ "`from'"
		   		   global file_path_pkgs `pkgs'
		   		   global file_path_rnew `rnew'
       		       db createtoc
                 }
                 else{
                 	foreach pkg of local pkgs {
			   			local pkg=regexr(`"`pkg'"',"(\.pkg)$","")
			   			net install `pkg', from(`from') `rnew'
                     }
		   		   }

		   		exit	
		   }
	       		
		}
		else{
			di as error "url is provided, but NOT directed to the .pkg file"
			exit
		}

	}



	local opwd=c(pwd)
	local  d=c(current_date) 
	local d=subinstr("`d'"," ","",.)
	local t=c(current_time)
	local t=subinstr("`t'",":","_",.)

	mkdir _tempfile_`d'_`t'

	qui cd `opwd'\_tempfile_`d'_`t'

	local pwd=c(pwd)

	qui unzipfile `"`from'"',replace

	di `"zipfile is unziped temporarily in "`pwd'" "'

	qui cd `opwd'

	dirlist, fromdir(`pwd') fname(pathpkg) pattern(*.pkg)

	mata: st_local("npkgs",strofreal(length(pathpkg)))
	if("`npkgs'"=="0"){
		global clean_tempfile_pkg "`opwd'\_tempfile_`d'_`t'"
		di as red ".pkg files missing in the unzipped file"
		di _n
		db nextcpkg
		//di as error "No installable Stata packages found"
		*shell rmdir "`opwd'\_tempfile_`d'_`t'" /s /q
		exit
	}

	mata: _installpkg(pathpkg,"`rnew'")

	//qui cd `opwd'

	shell rmdir "`opwd'\_tempfile_`d'_`t'" /s /q

end




 
 cap mata mata function _installpkg()
 
 mata:
 void function _installpkg(string vector pathpkg,string scalar rnew)
 
 {
    paths=regexr(pathpkg,"/[^/]+$","")
    pkgs=regexr(pathpkg,"^(.+)\/","")  
    pkgs=regexr(pkgs,"(\.pkg)$","")
	
	for(i=1;i<=length(pathpkg);i++){
	    statainst="net install  " + pkgs[i] +",from("+paths[i]+")"+" "+rnew	
    	stata(statainst)
	}
	 
 }
 
 end
 

cap program drop splitfrom
program define splitfrom,rclass

	syntax, from(string) *

	return local from `from'
	return local renew `options'

end



**********************************************************
//The following command is from Robert Picard in statalist
// (https://www.stata.com/statalist/archive/2013-10/msg01058.html)
**********************************************************
cap program drop dirlist
program define dirlist
  version 14
  syntax, fromdir(string) fname(string) [pattern(string) APPEND ]

  // get files in "`fromdir'" using pattern
  if "`pattern'" == "" local pattern "*"
  
  local flist: dir "`fromdir'" files "`pattern'"
  if "`append'"=="" mata: `fname'=J(0,1,"")
  
  foreach f of local flist {
      mata: `fname' =  `fname '\ "`fromdir'/`f'" 
    }
 
   local dlist: dir "`fromdir'" dirs "*"
   foreach d of local dlist{
       dirlist, fromdir("`fromdir'/`d'")  pattern("`pattern'") append fname(`fname')
   }

 end
 
 
