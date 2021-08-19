*!version 1.0
** do createMenu4Installpkg.do to add installpkg into Window User Menu
cap program drop giteeinstallmenu
program define giteeinstallmenu

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

	  window menu append item "InstallPackage" "giteeinstall" "db gitee"
	  window menu refresh

}
else{

	  window menu append submenu "stUser" "InstallPackage" 
	  window menu append item "InstallPackage" "giteeinstall" "db gitee"
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
	flag=regexm(file,`"^( )*(window)( .*)("InstallPackage")( )+("giteeinstall")( )+("db gitee")(.*)"')
	if(sum(flag)>0){
		printf("giteeinstall Menu Information already exists in profile.do. \n")
	}
	else{
		    flag=regexm(file,`"^( )*(window)( .*)(submenu)( )+("stUser")( )+("InstallPackage")(.*)"')
			flag=sum(flag)
			writefile=fopen(pathfilename,"a")
			fwrite(writefile, sprintf("  \r\n"))
			fwrite(writefile, sprintf("******** added by giteeinstallmenu.ado \r\n"))
            if(!flag){
			    fwrite(writefile, sprintf(`"window menu append submenu "stUser" "InstallPackage"  \r\n"'))
            }
			fwrite(writefile, sprintf(`"window menu append item "InstallPackage" "giteeinstall" "db gitee"  \r\n"'))
			fwrite(writefile, sprintf("window menu refresh \r\n"))
			fwrite(writefile, sprintf("********  \r\n"))
			fclose(writefile)
			printf("completed writing giteeinstall Menu Information in profile.do. \n")
			stataexc="winfresh " + strofreal(flag)
			stata(stataexc)
	
	
	}
	
}


	
end




/***incompleted utility function 2020/02/29
void function _installpkgmenu(string scalar path,string scalar submenu,string scalar item,string scalar dbc)
{
	pathfilename=path+"profile.do"
	
	file=cat(pathfilename)
	expr=sprintf(`"^( )*(window)( .*)("%s")( )+("%s")( )+("%s")(.*)"',submenu,item,dbc)
	//flag=regexm(file,`"^( )*(window)(.*)("InstallPackage")( )*("giteeinstall")( )*("db gitee")(.*)"')
	flag=regexm(file,expr)
	
	if(sum(flag)>0){
		printf("%s-%s Menu Information already exists in profile.do. \n",submenu,item)
	}
	else{
			expr=sprintf(`"^( )*(window)( .*)(submenu)( )+("stUser")( )+("%s")(.*)"',item)
		    //flag=regexm(file,`"^( )*(window)( .*)+(submenu)( )+("stUser")( )+("InstallPackage")(.*)"')
			flag=sum(flag)
			writefile=fopen(pathfilename,"a")
			fwrite(writefile, sprintf("  \r\n"))
			fwrite(writefile, sprintf("******** added by giteeinstallmenu.ado \r\n"))
            if(!flag){
			    fwrite(writefile, sprintf(`"window menu append submenu "stUser" "InstallPackage"  \r\n"'))
            }
			fwrite(writefile, sprintf(`"window menu append item "InstallPackage" "giteeinstall" "db gitee"  \r\n"'))
			fwrite(writefile, sprintf("window menu refresh \r\n"))
			fwrite(writefile, sprintf("********  \r\n"))
			fclose(writefile)
			printf("completed writing giteeinstall Menu Information in profile.do. \n")
			stataexc="winfresh " + strofreal(flag)
			stata(stataexc)
	
	
	}
	
}


	
end
**/
