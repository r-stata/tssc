
*! v 1.02 
*! Update: 20210519
*! www.lianxh.cn, StataChina@163.com
*! Codes from -bcuse.ado- by Prof. C.F. Baum have been incorporated

*cap prog drop lxhuse
prog define lxhuse
	version 11
	syntax [anything(name = FileName)]  ///
	       [, CLEAR noDesc Save REPLACE Url(string) ]
	

	if "`FileName'" == ""{  // browse dataset list
        br_datalist
		exit
	}
	
	if "`url'" == ""{
	    local DataURL "https://file.lianxh.cn/data"  // 连享会数据存放网址
	}
	else{
	    local DataURL "`url'"
	}
	* Note: If you input
	*   . global net "http://fmwww.bc.edu/ec-p/data/wooldridge"
	*   . lxhuse xxx, url($net)
	* -lxhuse- will be same as -lxhuse-
	* so, you can specify any URL you want
	* http://fmwww.bc.edu/ec-p/data/wooldridge  // lxhuse.ado
	
	if regexm("`FileName'", ".+.zip$") {
		capt copy "`DataURL'/`FileName'" ., replace
		if _rc != 0 {
			di as err _n "Error: `FileName' not found."
			di as text _col(3) `"o  To view the filelist, {browse "https://gitee.com/lianxh/data/tree/master/data01":Click here}"'			
			exit 
		}
		qui unzipfile "`FileName'", replace
		loc fn = reverse(substr(reverse("`FileName'"), 5, .))
		capt use `fn', `clear'
	}
	else {
		capt use "`DataURL'/`FileName'", `clear'
		local fn "`FileName'"  // for option -save-		
	}
	if _rc != 0 {
 		if _rc == 4 {
 			di as err _n "Error: data in memory would be lost. Use" as text " lxhuse `FileName', clear" as error " to discard changes."
 		} 
 		else{ 
	       	if strpos("`FileName'","."){
			   local suffix ""
			}
			else{
			   local suffix ".suffix - (do not omit suffix)"
			}	
		    di as err _n "Error: file `FileName' not found or the extracted file is not in Stata format. "
			di as text _col(3) `"o  Use - {stata "help lxhget":lxhget} `FileName'`suffix' to download .xlsx, .do, .rar, .txt, .csv, etc files."' 
		    di as text _col(3) `"o  To view the filelist, {browse "https://gitee.com/lianxh/data/tree/master/data01":Click here}"'			
		}
		exit
	}
	
	if "`desc'" != "nodesc" { 
		describe
	}
	
	capt tsset
	if _rc==0 {
		tsset
	}
	
	if "`save'" != ""{
	    cap save "`fn'"   // need a -replace- option?
	    if _rc == 602{
		  if "`replace'"==""{
	        dis as err _n "Warning: file `fn' already exists, no file saved. You can specify -replace- option"
		  }
		  else{
		    save "`fn'", replace
		  }
	    }
	}
	
end


program define br_datalist
version 11

	  dis _col(5) "View: " `"{browse "https://gitee.com/lianxh/data/tree/master/data01": dataset list}"' ///
	      _skip(4) `"{browse "https://www.lianxh.cn": blog list}"'

end



/* 如下三条命令等价：
. use "https://file.lianxh.cn/data/auto_test.dta"
. lxhuse auto_test
. lxhuse auto_test.dta
*/
