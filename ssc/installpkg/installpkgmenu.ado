*!version 1.1
* 2020-2-29
* add installpkg into Window User Menu

* By Kerry Du
cap program drop installpkgmenu
program define installpkgmenu

addusermenu, subm(InstallPackage) i(Installpkg) c(installpkg) name(installpkgmenu)
addusermenu, subm(InstallPackage) i(Createpkg)  c(createpkg)  name(installpkgmenu)

end


cap program drop addusermenu
program define addusermenu

 version 14 
 
 syntax, SUBMenu(string) Item(string) Cmd(string) [name(string)]

if `"`name'"'=="" local name addusermenu
local dbcmd db `cmd'
local path= subinstr("`c(sysdir_stata)'","\","/",.)
cap findfile profile.do,path(`path')

if _rc!=0{
	mata: _creatprofile("`path'",`"`name'"')
	di `"profile.do created in `path'"'

}


    mata: _addusermenu("`path'",`"`submenu'"',`"`item'"',`"`dbcmd'"',`"`name'"')


end



cap program drop winfresh
program define winfresh

syntax,  Item(string) DBCmd(string) SUBMenu(string) [NEWmenu]

if (`"`newmenu'"'!=""){
	  window menu append submenu "stUser" `"`submenu'"' 
}
	  window menu append item `"`submenu'"' `"`ietm'"' `"`dbcmd'"'
	  
	  window menu refresh

end



cap mata mata drop _creatprofile()
cap mata mata drop _addusermenu()

mata:

void function _creatprofile(string scalar path, string scalar name)
{
	pathfilename=path+"profile.do"
	writefile=fopen(pathfilename,"a")
	fwrite(writefile, sprintf("*created by %s.ado \r\n",name))
	fwrite(writefile, sprintf("  \r\n"))
	fclose(writefile)
	
	
}


void function _addusermenu(string scalar path,
						   string scalar submenu,
						   string scalar item,
						   string scalar dbcmd,
						   string scalar name  )
{
	pathfilename=path+"profile.do"
	
	file=cat(pathfilename)
	expstr=sprintf(`"^( )*(window)( .*)("%s")( )+("%s")( )+("%s")(.*)"',submenu,item,dbcmd)
	//flag=regexm(file,`"^( )*(window)( .*)("InstallPackage")( )+("installpkg")( )+("db installpkg")(.*)"')
	flag=regexm(file,expstr)
	if(sum(flag)>0){
		printf("%s-%s Menu Information already exists in profile.do. \n",submenu,item)
	}
	else{
			expstr=sprintf(`"^( )*(window)( .*)(submenu)( )+("stUser")( )+("%s")(.*)"',submenu)
		    //flag=regexm(file,`"^( )*(window)( .*)(submenu)( )+("stUser")( )+("InstallPackage")(.*)"')
		    flag=regexm(file,expstr)
			flag=sum(flag)
			writefile=fopen(pathfilename,"a")
			fwrite(writefile, sprintf("  \r\n"))
			fwrite(writefile, sprintf("******** added by %s.ado \r\n",name))
			stataexc=sprintf(`"winfresh, submenu(%s) item(%s) dbcmd(%s)  "',submenu,item,dbcmd) 
            if(!flag){
            	stataexc=stataexc+" newmenu"
			    fwrite(writefile, sprintf(`"window menu append submenu "stUser" "%s"  \r\n"',submenu))
            }
			fwrite(writefile, sprintf(`"window menu append item "%s" "%s" "%s"  \r\n"',submenu,item,dbcmd))
			fwrite(writefile, sprintf("window menu refresh \r\n"))
			fwrite(writefile, sprintf("********  \r\n"))
			fclose(writefile)
			printf("completed writing %s-%s Menu Information in profile.do. \n",submenu,item)
			//stataexc
			stata(stataexc)
	
	
	}
	
}




end


/*

cap program drop installpkgmenu
program define installpkgmenu
 version 14 
 
 syntax

local path= subinstr("`c(sysdir_stata)'","\","/",.)
cap findfile profile.do,path(`path')

if _rc!=0{
	mata: _creatprofile("`path'")
	di `"profile.do created in `path'"'

}


    mata: _installpkgmenu("`path'")


end



cap program drop winfresh
program define winfresh

if (`0'==1){

	  window menu append item "InstallPackage" "Installpkg" "db installpkg"
	  window menu refresh

}
else{

	  window menu append submenu "stUser" "InstallPackage" 
	  window menu append item "InstallPackage" "Installpkg" "db installpkg"
	  window menu refresh

}


end



cap mata mata drop _creatprofile()
cap mata mata drop _installpkgmenu()

mata:

void function _creatprofile(string scalar path)
{
	pathfilename=path+"profile.do"
	writefile=fopen(pathfilename,"a")
	fwrite(writefile, sprintf("*created by installpkgmenu.ado \r\n"))
	fwrite(writefile, sprintf("  \r\n"))
	fclose(writefile)
	
	
}


void function _installpkgmenu(string scalar path)
{
	pathfilename=path+"profile.do"
	
	file=cat(pathfilename)
	flag=regexm(file,`"^( )*(window)( .*)("InstallPackage")( )+("installpkg")( )+("db installpkg")(.*)"')
	if(sum(flag)>0){
		printf("installpkg Menu Information already exists in profile.do. \n")
	}
	else{
		    flag=regexm(file,`"^( )*(window)( .*)(submenu)( )+("stUser")( )+("InstallPackage")(.*)"')
			flag=sum(flag)
			writefile=fopen(pathfilename,"a")
			fwrite(writefile, sprintf("  \r\n"))
			fwrite(writefile, sprintf("******** added by installpkgmenu.ado \r\n"))
            if(!flag){
			    fwrite(writefile, sprintf(`"window menu append submenu "stUser" "InstallPackage"  \r\n"'))
            }
			fwrite(writefile, sprintf(`"window menu append item "InstallPackage" "Installpkg" "db installpkg"  \r\n"'))
			fwrite(writefile, sprintf("window menu refresh \r\n"))
			fwrite(writefile, sprintf("********  \r\n"))
			fclose(writefile)
			printf("completed writing installpkg Menu Information in profile.do. \n")
			stataexc="winfresh " + strofreal(flag)
			stata(stataexc)
	
	
	}
	
}




end


/*
cap program drop installpkgmenu
program define installpkgmenu

 version 14 
 
 syntax

local path= subinstr("`c(sysdir_stata)'","\","/",.)
cap findfile profile.do,path(`path')

if _rc!=0{
	mata: _creatprofile("`path'")
	di `"profile.do created in `path'"'

}

    mata: _installpkgmenu("`path'")
   if("`runit'"=="yes"){
	  window menu append submenu "stUser" "InstallPackage" 
	  window menu append item "InstallPackage" "InstallPackage" "db installpkg"
	  window menu refresh	
   }

end


cap mata mata drop _creatprofile()
cap mata mata drop _installpkgmenu()

mata:

void function _creatprofile(string scalar path)
{
	pathfilename=path+"profile.do"
	writefile=fopen(pathfilename,"a")
	fwrite(writefile, sprintf("*created by installpkgmenu.ado \r\n"))
	fwrite(writefile, sprintf("  \r\n"))
	fclose(writefile)
	
	
}


void function _installpkgmenu(string scalar path)
{
	pathfilename=path+"profile.do"
	
	file=cat(pathfilename)
	flag=regexm(file,`"^( )*(window)(.*)("InstallPackage")( )*("InstallPackage")( )*("db installpkg")(.*)"')
	if(sum(flag)>0){
		printf("InstallPackage Menu Information already exists in profile.do. \n")
		st_local("runit","no")
	}
	else{
			writefile=fopen(pathfilename,"a")
			fwrite(writefile, sprintf("  \r\n"))
			fwrite(writefile, sprintf("******** added by installpkgmenu.ado \r\n"))
			fwrite(writefile, sprintf(`"window menu append submenu "stUser" "InstallPackage"  \r\n"'))
			fwrite(writefile, sprintf(`"window menu append item "InstallPackage" "InstallPackage" "db installpkg"  \r\n"'))
			fwrite(writefile, sprintf("window menu refresh \r\n"))
			fwrite(writefile, sprintf("********  \r\n"))
			fclose(writefile)
			printf("completed writing InstallPackage Menu Information in profile.do. \n")
			st_local("runit","yes")
	
	
	}
	
}


	
end
*/
