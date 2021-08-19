*! Verion: 1.0
*! Update: 2021/5/30 12:32

cap program drop sbldo
program define sbldo, rclass
version 14

syntax anything(name = pkgname)[,REPLACE NO PROFILE]
    
    if "`profile'"!=""{
        cap confirm file "`c(sysdir_stata)'profile.do"
        if _rc==0 & "`replace'"==""{
            di as err "`c(sysdir_stata)'profile.do already exist"
            dis as text  `"You can click the following command to replace it：{stata "sbldo ,replace profile":{bf:sbldo ,replace profile}}"'
            exit
        }
        else{
            copy  "https://songbl-1304948727.cos.ap-guangzhou.myqcloud.com/do/profile.do" "`c(sysdir_stata)'",replace 
        }
        
        exit
    }
    
    local original_pkgname="`pkgname'"
	if strmatch("`pkgname'","*/*")==1 | strmatch("`pkgname'","*\*")==1{
        cap splitpath "`pkgname'"
        if _rc!=0{
            qui ssc install docd
            splitpath "`pkgname'"
        }
        local pkgname=r(filename)
    } 
    if  usubstr("`pkgname'",-3,3) ==".do" {
        local pkgname =plural(2, "`pkgname'","-.do") 
    }
    
    
	if strpos("`original_pkgname'","http")==0{
	  local URL "https://songbl-1304948727.cos.ap-guangzhou.myqcloud.com/do/"
	}
	else{
      local all_pkgname="`pkgname'"+".do"
      local URL =regexr("`original_pkgname'","`all_pkgname'","") 
	}    
    
    local PATH     `"`c(sysdir_plus)'"'        
    local path      =substr("`pkgname'",1,1) 
    local PATH     `PATH'\`path'\ 
    cap mkdir `"`PATH'"'        
	local PATH =subinstr("`PATH'","/","\",.) 
    
    cap confirm file "`PATH'\`pkgname'.do" 
    local rc_confirm =_rc     
    cap qui checksum `"`PATH'\`pkgname'.do"'
    local rc_path =_rc 
    local pathcheck =r(filelen) 
    cap qui checksum  "`URL'`pkgname'.do"
    local rc_url =_rc 
    local urlcheck =r(filelen)         

    
    if `rc_url' == 679 {
        di as err   `"web error 403"'                    
        di as err _col(5)  `"该数据与文档已经被加密。获取密钥，请联系微信：{browse "https://note.youdao.com/ynoteshare1/index.html?id=720635d3824de83e0e764a60eb34e54c&type=note":{bf:songbl_stata}}"'
        exit 679
    } 					
    
    if `rc_url'!=679 & `rc_url'!=0{              
        di as err  `"sbldo copy: "`pkgname'.do" not found. Please check the dofile link carefully."'
        exit 601
    }        
    
    dis as text `"checking {bf:`pkgname'.do} consistency and verifying not already installed..."'
    
    if `rc_confirm'==0 & "`replace'"==""{
                                  
        if `pathcheck'- `urlcheck'!=0{
            dis ""
            dis as text "the following files already exist and are different:"
            dis as text _col(5) `"{stata `"doedit "`PATH'\`pkgname'.do""':{bf:`PATH'\`pkgname'.do}}"'
            dis ""
            dis as err "no files installed or copied"
            dis as err "(no action taken)"
            
            if "`no'"==""{
                doedit `"`PATH'\`pkgname'.do"'
            }
        
            return local  adofile   `"`PATH'\`pkgname'.do"'             
            exit 602
        }
        
        else{
            dis as text _col(5) `"{stata `"doedit "`PATH'\`pkgname'.do""':{bf:`PATH'\`pkgname'.do}} already exist and are up to date."'
            
            if "`no'"==""{
                doedit `"`PATH'\`pkgname'.do"'
            }
        
            return local  adofile   `"`PATH'\`pkgname'.do"'   
            exit
        }              
        

    } 
    
    dis ""
	dis as text "the following files will be replaced:"
	dis as text _col(5)  `"{stata "doedit `PATH'\`pkgname'.do":{bf:`PATH'\`pkgname'.do}}"' 	 _n
    dis as text "installing into `PATH'..."
    
    cap copy  "`URL'`pkgname'.do"   "`PATH'\`pkgname'.do" ,replace                     
    
    if "`no'"==""{
        doedit `"`PATH'\`pkgname'.do"'
    }
    return local adofile   `"`PATH'\`pkgname'.do"'  
       
end
