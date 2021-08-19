*! version 3.0
* 27 Feb 2020
* addeing curl version
* Stata 16 is blocked by Gitee.com
* curl is used when the stata version is higher than 15.

*version 2.0
* 25 Feb 2020
* Kerry Du, kerrydu@xmu.edu.cn
cap program drop gitee
program define gitee
	version 14 
	syntax [anything], [replace force from(string)]
 
	if `c(stata_version)'>15{
	    di "Stata 16 is blocked by Gitee.com"
		di "curl is used to download the packages"
		di "make sure that curl has been installed and added to the system path "
		
		gitee_curl `0'
		exit
		
	} 

	
	
	tokenize `"`0'"', p(",")
	local rnew `3'
	
	gettoken subc 0:0, p(" ,")
	tokenize `"`0'"', p(",")

if !(`"`subc'"'=="install" |`"`subc'"'=="uninstall" ){
		  di as red "gitee should be followed by install or uninstall."
	      error 198
}



if (`"`subc'"'=="install" &`"`from'"'==""){
 
 	if (`"`1'"'==""|`"`1'"'==","){

		di as error "username/repository[/subfolder] should be specified when from() is not specified."
		exit 198
	}
	local reps `1'
	local reps=subinstr(`"`reps'"',"\","/",.) 

	tokenize `"`reps'"', p("/")
	local usr `1'`2'`3'
	local pth=subinstr(`"`reps'"',`"`usr'"',"",1)
 
		if `"`pth'"'!=""{
		  local pth /tree/master`pth'/
	    }

        tempname N
        mata: files=cat(`"https://gitee.com/`usr'`pth'"')
		mata: flag=select(1::length(files),strmatch(files,`"<i class="iconfont icon-file"></i>"'))
		mata: mata: st_numscalar("`N'",length(flag))
		
		if `=`N''==0{
			di as red "No Stata files found in the repository."
			exit
		}			
		
		mata: files=files[flag:+1,.]
		mata: files=select(files,!strpos(files,`"<span class='simplified-path'>"'))
		mata: files=subinstr(files,`"<a href=""',"https://gitee.com/",1)
		mata: files=subinstr(files,"</a>","",.)
		mata: urls=substr(files,1,strpos(files,`"""'):-1)
        mata: filenames=substr(files,strpos(files,`">"'):+1,.)
		mata: st_local("url",urls[1])
		local url=subinstr(`"`url'"',"/blob/","/raw/",1)
		local url=regexr(`"`url'"',"/[^/]+$","") // remove the filename
		
		mata: flag=(filenames:=="stata.toc")+(filenames:=="Stata.toc")
		mata: st_numscalar("`N'",sum(flag))
	
		if `=`N''==0{
			di as red "stata.toc is not found."
			di as red "There are not installable packages in the repository."
			exit
		}
 

		mata: filenames=select(filenames,regexm(filenames,"^.*(\.pkg)$"))
		mata: filenames=regexr(filenames,"(\.pkg)$","")
		mata: st_local("spkg",strconcat(filenames))
		
		if(`"`spkg'"'!=""){
		   di _n
		   di "trying to install package(s): `spkg'"
		   di  _n
		   
			foreach pkgi of local spkg{
				net install `pkgi', from(`url') `rnew'	
			}			   

        }
        else{
			di as red "*.pkg files not found."
			di as red "There are not installable packages in the repository."
        }
		
		




}
if (`"`subc'"'	=="install" &`"`from'"'!=""){

	if(`"`1'"'!=""&`"`1'"'!=","){
		local pkgs `1'
		} 

	local rnew=subinstr("`rnew'",`"from(`from')"',"",.)	

        tempname N
        mata: files=cat(`"`from'"')
		mata: flag=select(1::length(files),strmatch(files,`"<i class="iconfont icon-file"></i>"'))
		mata: mata: st_numscalar("`N'",length(flag))
		
		if `=`N''==0{
			di as red "No Stata files found in the repository."
			exit
		}			
		
		mata: files=files[flag:+1,.]
		mata: files=select(files,!strpos(files,`"<span class='simplified-path'>"'))
		mata: files=subinstr(files,`"<a href=""',"https://gitee.com/",1)
		mata: files=subinstr(files,"</a>","",.)
		mata: urls=substr(files,1,strpos(files,`"""'):-1)
        mata: filenames=substr(files,strpos(files,`">"'):+1,.)
		mata: st_local("url",urls[1])
		local url=subinstr(`"`url'"',"/blob/","/raw/",1)
		local url=regexr(`"`url'"',"/[^/]+$","") // remove the filename
		
		mata: flag=(filenames:=="stata.toc")+(filenames:=="Stata.toc")
		mata: st_numscalar("`N'",sum(flag))
	
		if `=`N''==0{
			di as red "stata.toc is not found."
			di as red "There are not installable packages in the repository."
			exit
		}			
	
	foreach pkgi of local pkgs{

		mata: flag=strmatch(filenames,"`pkgi'.pkg")
		mata: st_numscalar("`N'",sum(flag))		
		if `=`N''==0{
			di as red "`pkgi'.pkg is not found."
			di as red "Check the name of the installed package in the repository."
			mata: notation(filenames)
			exit
		}
		net install `pkgi', from(`url') `rnew'			
	}

	if `"`pkgs'"'==""{

		mata: filenames=select(filenames,regexm(filenames,"^.*(\.pkg)$"))
		mata: filenames=regexr(filenames,"(\.pkg)$","")
		mata: st_local("spkg",strconcat(filenames))

		if(`"`spkg'"'==""){
			di as red "*.pkg files not found."
			di as red "There are not installable packages in the repository."
		}
		else{
		   di _n
		   di "trying to install package(s): `spkg'"
		   di  _n
		}

		foreach pkgi of local spkg{
			net install `pkgi', from(`url') `rnew'	
		}

	}
	
}
	
	
	
if (`"`subc'"'=="uninstall" ){
   if (`"`1'"'==""|`"`1'"'==","){
   	 di as error "package name should be specified to uninstall."
   	 error 198
   }
   foreach pk in `1'{
   	  ado uninstall `pk', `rnew' 
   }
   
   exit


}	

end



*-version 1.0
* 27 Feb 2020
* Kerry Du, kerrydu@xmu.edu.cn
cap program drop gitee_curl
program define gitee_curl
	version 14 
	syntax [anything], [replace force from(string)]
	
	tokenize `"`0'"', p(",")
	local rnew `3'
	local rnew=subinstr(`"`rnew'"',`"from(`from')"',"",.)
	
	gettoken subc 0:0, p(" ,")
	
	tokenize `"`0'"', p(",")


	if !(`"`subc'"'=="install" |`"`subc'"'=="uninstall" ){
			  di as red "gitee should be followed by install or uninstall."
			  error 198
	}


	if (`"`subc'"'=="uninstall" ){
	   if (`"`1'"'==""|`"`1'"'==","){
		 di as error "package name should be specified to uninstall."
		 error 198
	   }
	   foreach pk in `1'{
		  ado uninstall `pk', `rnew'
	   }
	   
	   exit


	}



	if (`"`subc'"'=="install" &`"`from'"'==""){
	 
		if (`"`1'"'==""|`"`1'"'==","){

			di as error "username/repository[/subfolder] should be specified when from() is not specified."
			exit 198
		}
	}


	if (`"`subc'"'=="install" &`"`from'"'!=""){
	 
		if (`"`1'"'!=""&`"`1'"'!=","){

			local pkg0 `"`1'"'
		}
	}



*** parsing the website

		if (`"`from'"'!=""){
		    local website `"`from'"'
		} 
		else{
		    
			local reps `1'
			local reps=subinstr(`"`reps'"',"\","/",.) 

			tokenize `"`reps'"', p("/")
			local usr `1'`2'`3'
			local pth=subinstr(`"`reps'"',`"`usr'"',"",1)
		 
				if `"`pth'"'!=""{
				  local pth /tree/master`pth'/
				}
				
			local website "https://gitee.com/`usr'`pth'"
				
				
		}



*** download the source code of the speicified website

	cap mkdir _gitee_tempfiles_
	local dirfolder `c(pwd)'/_gitee_tempfiles_
	 
	!curl "`website'" -o  "`dirfolder'/temp.txt"
	 
	cap findfile  temp.txt,path(`dirfolder')

	if _rc!=0{
		
		di as error "curl fails to copy `website'"
		exit
	}
 
*** extract the urls of the stata files included in the website 

        tempname N
        mata: files=cat("`dirfolder'/temp.txt")
		mata: flag=select(1::length(files),strmatch(files,`"<i class="iconfont icon-file"></i>"'))
		mata: mata: st_numscalar("`N'",length(flag))
		
		if `=`N''==0{
			di as red "No Stata files found in the repository."
			exit
		}			
		
		mata: files=files[flag:+1,.]
		mata: files=select(files,!strpos(files,`"<span class='simplified-path'>"'))
		mata: files=subinstr(files,`"<a href=""',"https://gitee.com/",1)
		mata: files=subinstr(files,"</a>","",.)
		mata: urls=substr(files,1,strpos(files,`"""'):-1)
        mata: filenames=substr(files,strpos(files,`">"'):+1,.)
		
		mata: st_local("url",urls[1])
		if (`"`from'"'!="") local url=subinstr(`"`url'"',"/blob/","/raw/",1)
		local url=regexr(`"`url'"',"/[^/]+$","") // remove the filename


*** check the existence of stata.toc

		mata: flag=(filenames:=="stata.toc")+(filenames:=="Stata.toc")
		mata: st_numscalar("`N'",sum(flag))
	
		if `=`N''==0{
			di as red "stata.toc is not found."
			di as red "There are not installable packages in the repository."
			exit
		}	
		
		
		mata: st_local("toc",select(filenames,flag))
		cap !curl  "`url'/`toc'" -o  "`dirfolder'/stata.toc"
		

*** find pkgs to be installed

	mata: filenames=select(filenames,regexm(filenames,"^.*(\.pkg)$"))
	mata: filenames=regexr(filenames,"(\.pkg)$","")

	mata: st_local("pkgs",strconcat(filenames))

	if (`"`pkg0'"'!=""){
		local pkfound: list pkg0 & pkgs
		local pkgs `pkfound'
		if (`"`pkfound'"'!=""){
		  di `"`pkfound' package(s) found"'  
		}
		else{
			di as red `"`pkg0' package(s) NOT found in the repository"' 
			exit
		}
		
		local pknotfond: list pkg0 - pkgs
		if (`"`pknotfound'"'!=""){
		  di as red `"`pknotfound' package(s) NOT found in the repository"'  
		  di "check the package name(s) specified to be installed"  
		  di _n
		}	
	}
	di _n

	di `"trying to install package(s): `pkgs'"'
	di _n

	//mata: filename=tokens("`pkgs'")
	//mata: _dfpkgfiles(filenames',`"`url'"',`"`dirfolder'"')

	foreach pkg of local pkgs{
		!curl "`url'/`pkg'.pkg" -o  "`dirfolder'/`pkg'.pkg"
	
/*
	foreach pj of local pkgs{
		!curl "`url'/`pj'.pkg" -o  "`dirfolder'/`pj'.pkg"
	}



	*** download stata files specified in *.pkg and install the packages
	foreach pkg of local pkgs{
*/		
		 mata: _dfstatafiles("`pkg'.pkg",`"`url'"',`"`dirfolder'"')
		
		 net install `pkg', from(`dirfolder') `rnew'
		 
		 erase "`dirfolder'/`pkg'.pkg"
		 foreach fi of local dfstata{ 
			 cap erase  "`dirfolder'/`fi'" 
		 }
		
	}



	erase "`dirfolder'/temp.txt"
	erase "`dirfolder'/stata.toc"
	cap erase "`dirfolder'"


end




		
cap mata mata drop notation()
cap mata mata drop strconcat()	
cap mata mata drop _dfstatafiles()	
mata:

void function notation(string colvector filenames)

{
			//flag=strpos(filenames,".pkg")
			   flag=regexm(filenames,"^.*(\.pkg)$")
			   //flag
				if(sum(flag)>0){
				  printf("note: the specified repository includes %s \n",strconcat(select(filenames,flag)))
				}
			


}

string function strconcat(string vector s)
{
   ss=""
   for(i=1;i<=length(s);i++){
   
	ss=ss+" " + s[i]
   
   }
   return(ss)


}



void function _dfstatafiles(string scalar pkg,string scalar url,string scalar dirfolder)
{
    pkg=dirfolder+"/"+pkg
	pkgfile=cat(pkg)	
	pathfile=select(pkgfile,regexm(pkgfile,"^(f|F)()"))
	pathfile=regexr(pathfile,"^(f|F)( )","")
	pathfile=subinstr(pathfile," ","",.)
	pathfile=select(pathfile,pathfile:!="")
	pathfilename=regexr(pathfile,"^(.+)\/","")  
    st_local("dfstata",strconcat(pathfilename))
	for(j=1;j<=rows(pathfile);j++){
		
		p1="!curl "+ url + "/" + pathfile[j] +"  -o  "
		p2=dirfolder+"/"+pathfilename[j]
		stataexc=sprintf(`" %s  "%s" "',p1,p2)
		stata(stataexc)
	}


	pathfilename="F ":+ pathfilename

	pkgfile=select(pkgfile,!regexm(pkgfile,"^(f|F)()")) \ pathfilename

	writefile = fopen(pkg, "rw")

	for(j=1;j<=rows(pkgfile);j++){
		
		fwrite(writefile, sprintf("%s\r\n", pkgfile[j]))
	}

	fclose(writefile)	
	
}
		
end
		


