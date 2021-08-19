*! version 1.14
*! 2021.5.19, Zheng Jingyi, Lian Yujun (arlionn@163.com)

cap prog drop imusic
prog def  imusic
    version 16
	
	syntax [anything(name=name)][, Platform(string)] [BRowse] [Stop] [Kind(string)] [Link] [Nl] [List(string)] [Markdown] [Autoplay] [NDescription]  
		   
		   
	preserve //保存工作进度
	
    *-Auto install jsonio - user command
	cap which jsonio
	if  _rc!=0 {
	   dis as text "Installing..., ^-^"
       cap net install jsonio, from(http://file.lianxh.cn/StataCMD/jsonio)
       if _rc!=0{
            cap ssc install jsonio
            if _rc{
                dis as error "Cannot install package -jsonio-, please install by hand at https://gitee.com/arlionn/imusic"
                exit
            }
       }
    }
	
/* -sxpose- is incoded as a sub-program 

    *-Auto install sxpose
	cap which sxpose.ado
	if  _rc!=0 {
            cap net install sxpose, from(http://file.lianxh.cn/StataCMD/sxpose)
       if _rc!=0{
            cap ssc install sxpose
            if _rc{
                dis as error "Cannot install package -sxpose-, please istall by hand at https://gitee.com/arlionn/imusic"
                exit
            }
       }
    }	
*/
	
	*停止播放本地音乐的模块
	if "`stop'" == "stop" {
		foreach exe in Music.UI cloudmusic QQMusic{ 
		  !taskkill /f /im `exe'.exe
		}
		exit
	}	

	*默认网易云在线播放
	if "`platform'" == "" {
	    local platform = "N"
	} 
	
	*关于platform选择的模块
	if "`platform'" != "" {	
		if "`platform'" != "n" &  "`platform'" != "t" &  "`platform'" != "l" & "`platform'" != "N" &  "`platform'" != "T" &  "`platform'" != "L"{			
			noi di as error "The {bf:platform} you selected is not available in our package."
			noi di as error "Please choose N for Netease , T for Tencent or L for Local and try again"
			exit
		}	
	}

	*默认只取搜索结果的第一位
	if "`list'" == "" local list=1
	
	*默认搜索单曲
	if "`kind'" != "1" & "`kind'" != "10" & "`kind'" != "1000" & "`kind'" != "1014" & "`kind'" != "1009" {
	    local kind = "1"
	} //1,单曲；10,专辑；1000,歌单；1014,MV；1009,主播电台；
	
	
	*如果不写歌曲名，随机播放歌曲
if "`name'" == "" {
	   //实际上是网易云的飙升榜
	   local platform="Netease"
	   clear
	   jsonio kv, file(http://music.163.com/api/playlist/detail?id=19723756)
	   qui drop if ustrregexm(key, "/creator") == 1
	   
	   Njsonclean anything , kind(`kind')
	   
	   forvalues i = 1/`list'{
	      local num_`i' = int(runiform(1,100))
	      local ID_`i'=valueid[`num_`i'']     //歌曲ID
	      local song_name_`i'=valuename[`num_`i''] //歌曲中文名
	      local singer_`i'=singer[`num_`i''] //歌手名字
	      
	      //构造最终的URL
	      local URL1="https://music.163.com/#/song?id="
	      local URL_`i'="`URL1'`ID_`i''" 
	   }
	
	  //autoplay选项
	  if "`autoplay'" != "" {
	    local U1 = "https://music.163.com/#/outchain/2/"
	    forvalues i = 1/`list' {
	      local UU_`i'="`U1'`ID_`i''"
	      view browse "`UU_`i''"
	    }
	  }
	    
	  if "`list'"=="1"{
	    if "`nl'" == "" {
	      lyrics anything, id(`ID_1')
	    }
	  }
}
else {
	mata:str = urlencode("`name'")
	mata:st_local("songname",str) //中文歌名转码
	
	
	*如果选择播放本地音乐	
	if "`platform'" == "l" | "`platform'" == "L" {
		if "$songpath"==""{
		dis as error "请定义音乐存放路径(global songpath),并以\结尾"
		exit
		}
	local filename = "$songpath"+"`name'"+".mp3"
	!start `filename'
	exit
	}

  else{
	*如果选择网易云	
	if "`platform'" == "n" | "`platform'" == "N"{
	if "`kind'" == "1014" local kind = "1" //不支持MV，转为单曲
	
	local URL1="http://music.163.com/api/search/get/web?csrf_token=hlpretag=&hlposttag=&s="
	local URL2="&type="
	local URL3="&offset=0&total=true&limit="
	local URL="`URL1'`songname'`URL2'`kind'`URL3'`list'" //构造获取歌曲信息的URL
	clear	
	jsonio kv, file(`URL') //用了外部命令jsonio,获取json文件
		
	Njsonclean anything, kind(`kind')
	
	*搜索的是单曲
	if "`kind'" == "1" {
	forvalue i = 1/`list' {
		local ID_`i'=valueid[`i']     //歌曲ID
		local song_name_`i'=valuename[`i'] //歌曲中文名
		local singer_`i'=singer[`i'] //歌手名字
	}
	
	if "`list'"== "1" {
		if "`nl'" == "" {
			lyrics anything, id(`ID_1')
		}
	}
	
	} 
	
	*搜索的是歌单
	if "`kind'" == "1000" {
		forvalue i = 1/`list' {
			local ID_`i'=valueid[`i']	//歌单ID
			local description_`i'=valuedescription[`i']     //简介
			local song_name_`i'=valuename[`i'] //歌单名字
			local singer_`i'=valuecreator[`i'] //创建人名字	
		}
	} 
	
	*搜索的是专辑
	if "`kind'" == "10" {
		forvalue i = 1/`list' {
			local ID_`i'=valueid[`i']	//专辑ID
			local description_`i'=valuedescription[`i']     //简介，常空
			local song_name_`i'=valuename[`i'] //专辑名字
			local singer_`i'=singer[`i'] //歌手名字	
		}	
	} 

	*搜索的是主播电台
	if "`kind'" == "1009" {
		forvalue i = 1/`list' {
			local ID_`i'=valueid[`i']	//专辑ID
			local description_`i'=valuedesc[`i']     //简介，常空
			local song_name_`i'=valuename[`i'] //电台名字
			local singer_`i'=valuedj[`i'] //创建人名字	
		}	
	} 
	
	
	//autoplay选项
	if "`autoplay'" != "" {
		local U1 = "https://music.163.com/#/outchain/"
		if "`kind'" =="1" local ty=2
		if "`kind'" =="10" local ty=1
		if "`kind'" =="1000" local ty=0
		if "`kind'"=="1009" local ty =4
		forvalues i = 1/`list' {
			local UU_`i'="`U1'`ty'/`ID_`i''"
			view browse "`UU_`i''"
		}
	}
	
	
	//构造最终的URL
	local URL1="https://music.163.com/#/"
	local URL2="?id="
	if "`kind'"=="1" local kind = "song"
	if "`kind'"=="10" local kind = "album"
	if "`kind'"=="1000" local kind = "playlist"
	if "`kind'"=="1002" local kind = "user/home"
	if "`kind'"=="1004" local kind = "video"
	if "`kind'"=="1006" local kind = "song"
	if "`kind'"=="1009" local kind = "djradio"
		forvalue i = 1/`list' {
			local URL_`i'="`URL1'`kind'`URL2'`ID_`i''" 
		}
	}

	*如果选择QQ音乐
	if "`platform'" == "t" | "`platform'" == "T"{
	*转换为QQ的代码
	if "`kind'" == "1" | "`kind'" == "1000" | "`kind'" == "1009" local kind=0 //单曲,歌单和电台不支持，转为搜索单曲
	if "`kind'" == "10" local kind=8 //专辑
	if "`kind'" == "1014" local kind=12 //MV
	
	*获取songmid等各种信息
	local URL1="http://c.y.qq.com/soso/fcgi-bin/client_search_cp?p=1&n="
	local URL2="&w="
	local URL3="&format=json&t="
	local URL="`URL1'`list'`URL2'`songname'`URL3'`kind'" //构造获取歌曲信息的URL
	clear	
	jsonio kv, file(`URL')
	
	*搜索的是单曲
	if "`kind'" == "0" {
		qui keep if ustrregexm(key, "/singer/id/name") == 1 | ustrregexm(key, "/songname") == 1 | ustrregexm(key, "/songmid") == 1
		forvalues i = 1/`list' {
		local ID_`i'=value[3+5*(`i'-1)]     //歌曲ID
		local song_name_`i'=value[4+5*(`i'-1)] //歌曲中文名
		local singer_`i'=value[1+5*(`i'-1)] //歌手名字
	}
	
	//获取歌词
	if "`list'" == "1" {
		clear
		local URL1="http://c.y.qq.com/soso/fcgi-bin/client_search_cp?p=1&n=1&w="
		local URL2="&format=json&t=7"
		local URL="`URL1'`songname'`URL2'" //构造获取歌词的URL
		jsonio kv, file(`URL')
		//如果是纯音乐：
		qui keep if ustrregexm(key, "/data/lyric/list_1/content") == 1
		if ustrregexm(value, "没有填词") == 1 {
			dis as txt char(10) "This is a pure music without lyrics, please enjoy."
		}
		//如果不是纯音乐，截取歌词
		else {
			qui drop key
			qui split value, parse("\n")
			qui sxpose_copy, clear // by Prof. Cox
			qui replace _var1=subinstr(_var1,char(10),"",.) //删除换行符
			qui keep if _var1!=" " | _var1!= "" | _var1!= "char(9)"
			qui duplicates tag, generate(dup)
			qui drop if dup==0 | dup==1
			qui duplicates drop
			qui drop dup
			//打印在屏幕上
			if "`nl'" == "" {
				local size = _N
				forvalues i=1/`size'{
					dis as txt _var1[`i']
				}
			}
		}
	}
	}
	
	*搜索的是专辑
	if "`kind'" == "8" {
		qui keep if ustrregexm(key, "/singerName") == 1 | ustrregexm(key, "/albumName") == 1 | ustrregexm(key, "/albumMID") == 1
		forvalues i = 1/`list' {
			local ID_`i'=value[1+5*(`i'-1)]     //专辑ID
			local song_name_`i'=value[2+5*(`i'-1)] //专辑名字
			local singer_`i'=value[4+5*(`i'-1)] //歌手名字
		}
	}

	*搜索的是MV
	if "`kind'" == "12" {
		qui keep if ustrregexm(key, "/singer_name") == 1 | ustrregexm(key, "/mv_name") == 1 | ustrregexm(key, "/v_id") == 1
		forvalues i = 1/`list' {
			local ID_`i'=value[3+3*(`i'-1)]     //专辑ID
			local song_name_`i'=value[1+3*(`i'-1)] //专辑名字
			local singer_`i'=value[2+3*(`i'-1)] //歌手名字
		}
	}
	
	
	*autoplay选项，仅在搜索单曲时生效
	if "`kind'" == "0" {
		if "`autoplay'" != "" {
			*获取播放地址	
			local UURL1="http://u.y.qq.com/cgi-bin/musicu.fcg?format=json&data=%7B%22req_0%22%3A%7B%22module%22%3A%22vkey.GetVkeyServer%22%2C%22method%22%3A%22CgiGetVkey%22%2C%22param%22%3A%7B%22guid%22%3A%22358840384%22%2C%22songmid%22%3A%5B%22"
			local UURL2="%22%5D%2C%22songtype%22%3A%5B0%5D%2C%22uin%22%3A%221443481947%22%2C%22loginflag%22%3A1%2C%22platform%22%3A%2220%22%7D%7D%2C%22comm%22%3A%7B%22uin%22%3A%2218585073516%22%2C%22format%22%3A%22json%22%2C%22ct%22%3A24%2C%22cv%22%3A0%7D%7D"
			forvalues i = 1/`list' {
				local UURL_`i'="`UURL1'`ID_`i''`UURL2'" //构造获取歌曲信息的URL
				clear	
				jsonio kv, file(`UURL_`i'')	
				*构造自动播放地址
				qui keep if ustrregexm(key, "purl") == 1 | ustrregexm(key, "sip") == 1
				local UUURL1=value[2]     //歌曲ID
				local UUURL2=value[1] //歌曲中文名
				local UUURL_`i'="`UUURL1'`UUURL2'"
				view browse "`UUURL_`i''"
			}
		}
	}
	
	*构造最终的URL
	forvalues i = 1/`list' {
	local URL1="https://y.qq.com/n/yqq/"
	if "`kind'"=="0" local kind = "song/"
	if "`kind'"=="8" local kind = "album/"
	if "`kind'"=="12" local kind = "mv/v/"
	local URL2=".html"
	local URL_`i'="`URL1'`kind'`ID_`i''`URL2'"
	}
	
	}	
	
  }	
}
	
//打印在屏幕上：歌曲的信息和链接地址
forvalue i = 1/`list' {
	//有link选项才会显示网址
	if "`link'" != ""{
	    dis as txt  `" {browse "`URL_`i''":`URL_`i''}
	}
	dis as txt  `" {browse "`URL_`i''":{bf: <<`song_name_`i''>>, by `singer_`i''}}
	//markdown选项生成markdown格式
	if "`markdown'" != "" {
	    dis as txt "[`song_name_`i''](`URL_`i'')"
	}
	if "`ndescription'"==""{
	    dis as txt	"`description_`i''"		
	}
	//browse选项自动打开网址
	if "`browse'" != "" {
		view browse "`URL_`i''" //网易云就是网易云音乐的界面，QQ只有一个音频播放页
	}
}
	
	
restore
end



*------------------
*- sub-programs
*------------------

cap prog drop lyrics
prog def lyrics
	syntax anything, ID(string)

	//获取歌词
	local URL1="http://music.163.com/api/song/media?id="
	local URL="`URL1'`id'" //构造获取歌词的URL
	clear
	jsonio kv, file(`URL')
	//如果是纯音乐：
	if ustrregexm(key, "/nolyric_1") == 1 & ustrregexm(value, "true") == 1 {
		dis as txt char(10) "This is a pure music without lyrics, please enjoy."
	}
	//如果不是纯音乐，截取歌词
	else {
		qui keep if ustrregexm(key, "/lyric_1") == 1
		qui drop key
		qui split value, parse("[" "]")
		qui sxpose_copy, clear // sxpose.ado, by Prof. Cox
		qui replace _var1=subinstr(_var1,char(10),"",.) //删除换行符
		qui keep if _var1!=" " | _var1!= "" | _var1!= "char(9)"
		qui duplicates tag, generate(dup)
		qui drop if dup==0
		qui duplicates drop
		qui drop dup
		//打印在屏幕上
		local size = _N
		forvalues i=1/`size'{
			dis as txt _var1[`i']
		}
	}
end

cap prog drop Njsonclean
prog def Njsonclean
syntax anything, kind(string)

qui keep if ustrregexm(key, "\d/name") == 1 | ustrregexm(key, "\d/id") == 1 | ustrregexm(key, "/nickname") == 1 | ustrregexm(key, "/desc") == 1

qui drop if  ustrregexm(key, "Music") == 1
if "`kind'"!= "10" qui drop if ustrregexm(key, "/album")==1

qui split key, parse("/")
drop key key1 key2
qui drop if key5=="id"
qui drop if key4==""
if "`kind'"=="1009"{
    qui drop if key5 == "description"
}
qui drop key5

qui levelsof key4 //r(r)
if "`kind'"=="1"  local num=r(r)-2
if "`kind'"=="10" local num=r(r)-4

qui reshape wide value, i(key3) j(key4) string

if "`kind'"=="1" | "`kind'"=="10" {
	qui gen singer=valueartists_1
	qui drop valueartists_1
	local NN=_N
  if `num' - 1 >0  {
	forvalues i = 2/`num'{
		forvalues n=1/`NN'{
			if valueartists_`i'[`n'] !=""{
				qui replace singer= singer[`n']+"/"+valueartists_`i'[`n'] if _n == `n'
			}
		}
		qui drop valueartists_`i'
	}
  }
}

qui split key3,parse("_")
qui destring key32, replace
sort key32

end




*-Sub prog-------sxpose_copy.ado-----

* copy from  sxpose.ado   
* NJC 1.0.0 14 October 2004 
* Author: Nicholas J. Cox, Durham University
* Support: email N.J.Cox@durham.ac.uk

*cap prog drop sxpose_copy
program sxpose_copy 
	version 8 
	syntax , clear [ force format(string) firstnames destring ] 

	if "`force'" == "" { 
		foreach v of var * { 
			capture confirm string var `v' 
			if _rc { 
				di as err ///
				"{p}dataset contains numeric variables; " ///
				"use {cmd:force} option if desired{p_end}" 
				exit 7 
			} 	
		}
	} 	

	local nobs = _N 
	qui d 
	local nvars = r(k) 

	if `nobs' > `c(max_k_theory)' { 
		di as err "{p}not possible; would exceed present limit on " ///
			  "number of variables{p_end}" 
		exit 498 
	} 	

	forval j = 1/`nobs' { 
		local new "`new' _var`j'" 
	} 	
	
	capture confirm new var `new' 
	
	if _rc { 
		di as err "{p}sxpose would create new variables " ///
		          "_var1-_var`nobs', but names already in use{p_end}" 
		exit 110 
	} 	

	if "`format'" != "" { 
		capture di `format' 1234.56789 
		if _rc { 
			di as err "invalid %format" 
			exit 120 
		}
	}	
	else local format "%12.0g" 
	
	if `nvars' > `nobs' set obs `nvars' 

	unab varlist: * 
	tokenize `varlist' 

	qui forval j = 1/`nobs' { 
		gen _var`j' = "" 
		forval i = 1/`nvars' { 
			cap replace _var`j' = ``i''[`j'] in `i' 
			if _rc { 
				replace _var`j' = ///
				string(``i''[`j'], "`format'") in `i' 
			} 	
		} 	
	} 

	drop `varlist' 
	if `nobs' > `nvars' qui keep in 1/`nvars' 

	qui if "`firstnames'" != "" { 
		forval j = 1/`nobs' { 
			capture rename _var`j' `= _var`j'[1]' 
		}
		drop in 1 
	} 	
		
	if "`destring'" != "" destring, replace 
end 

