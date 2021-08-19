cap program drop giteedlg

program define giteedlg

version 14

syntax [anything], url(string) [REPLACE FORCE]


mata: st_local("isurl",strofreal(pathisurl(`"`url'"')))

if("`isurl'"=="0"){
  di as error "input is NOT a url"
  error 198
}


if(!regexm(`"`url'"',"^( )*(https://gitee.com)(.*)")){
	di as error "url is NOT directed to gitee.com"
	error 198

}

	    di _n(1) "{title:Executing the gitee command}" _n
		di as txt `"gitee install `anything', from(`url') `replace' `force' "'   _n 
		gitee install `"`anything'"', from(`url') `replace' `force'   



end
