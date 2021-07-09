*! TidyFriday 
*! 2020-05-04
*! 用法（以 winsor2 命令为例）：
*! 1. 构建本地安装包：cssc winsor2
*! 2. 构建并安装：cssc winsor2, i
*! 如果运行中有提示下载失败，可以在运行结束之后在的工作目录下面找到一个名为 *_failed.do 的文件，打开之后逐个运行里面的代码即可完成安装。
cap prog drop cssc
prog def cssc
	version 7.0
	syntax anything(name = cmd) [, Install]
	cap preserve
	local prefix = substr("`cmd'", 1, 1)
	local url = "http://fmwww.bc.edu/repec/bocode"
	* 创建两个 do 文件，一个是所有的代码，一个是执行失败的代码
	local date = string(date(c(current_date), "DMY"), "%tdCY-N-D")
	cap file close myfile
	cap file close myfile_failed
	file open myfile_failed using `cmd'_failed.do, write replace
	file write myfile_failed "* 运行失败的语句 *" _n ///
		"* TidyFriday *" _n ///
		"* 创建日期: `date' *" _n ///
		"* 如果你有任何使用问题，可以添加我的微信询问： 18200993720" _n ///
		"*===================================================*" _n ///
		"* 在上次的下载安装过程中下面的代码运行失败了，你可以手动运行这些代码，直到所有的代码都运行成功。" _n
	file open myfile using `cmd'.do, write replace
	file write myfile "* 从 SSC 下载并组建一个本地的 Stata 命令包 *" _n ///
		"* TidyFriday *" _n ///
		"* 创建日期: `date' *" _n ///
		"* 如果你有任何使用问题，可以添加我的微信询问： 18200993720" _n ///
		"*===================================================*" _n ///
		"* 1. 下载 pkg 文件:" _n ///
		"clear all" _n ///
		`"cap mkdir `cmd'"' _n ///
		`"copy "`url'/`prefix'/`cmd'.pkg" "`c(pwd)'/`cmd'/`cmd'.pkg", replace"' _n ///
		"* 2. 处理 pkg 文件:" _n ///
		`"infix strL v 1-2000 using `cmd'/`cmd'.pkg, clear"' _n ///
		`"replace v = subinstr(v, "../", "./", .)"' _n ///
		`"export delimited using `cmd'/`cmd'.pkg, replace novarnames"' _n ///
		`"replace v = subinstr(v, "./", "", .)"' _n ///
		`"replace v = subinstr(v, "F ", "f ", .)"' _n ///
		`"keep if index(v, "f ") & !index(v, "d ") & !index(v, "p ")"' _n ///
		`"replace v = subinstr(v, "f ", "", .)"' _n ///
		`"* 3. 下载该命令相关的文件:"' _n
	qui{
		cap mkdir `cmd'
		* 下载 pkg 文件
		cap copy "`url'/`prefix'/`cmd'.pkg" "`c(pwd)'/`cmd'/`cmd'.pkg", replace
		if _rc != 0{
			file close myfile_failed
			file close myfile
			cap erase `cmd'_failed.do
			cap erase `cmd'.do
			di as error "网络链接失败，请重试！"
			exit 601
		}
		* 处理 pkg 文件
		cap {
			infix strL v 1-2000 using `cmd'/`cmd'.pkg, clear
			replace v = subinstr(v, "../", "./", .)
			export delimited using `cmd'/`cmd'.pkg, replace novarnames
			replace v = subinstr(v, "./", "", .)
			replace v = subinstr(v, "F ", "f ", .)
			keep if index(v, "f ") & !index(v, "d ") & !index(v, "p ")
			replace v = subinstr(v, "f ", "", .)
		}
	}
	forval i = 1/`=_N'{
		cap local p = substr("`=v[`i']'", 1, 1)
		if substr("`=v[`i']'", 1, 1) != "`prefix'"{
			cap qui mkdir "`cmd'/`p'"
			file write myfile `"cap qui mkdir "`cmd'/`p'""' _n
		}
		di in green "下载 `=v[`i']' ..."
		if !index("`=v[`i']'", "/"){
			qui cap copy "`url'/`prefix'/`=v[`i']'" "`cmd'/`=v[`i']'", replace
			if _rc != 0{
				di as yellow `"下载 "`=v[`i']'" 失败!"'
				file write myfile_failed `"copy "`url'/`prefix'/`=v[`i']'" "`cmd'/`=v[`i']'", replace"' _n
			}
			file write myfile `"copy "`url'/`prefix'/`=v[`i']'" "`cmd'/`=v[`i']'", replace"' _n
		}
		if index("`=v[`i']'", "/"){
			qui cap copy "`url'/`=v[`i']'" "`cmd'/`=v[`i']'", replace
			if _rc != 0{
				di as yellow "下载 `=v[`i']' 失败!"
				file write myfile_failed `"copy "`url'/`=v[`i']'" "`cmd'/`=v[`i']'", replace"' _n
			}
			file write myfile `"copy "`url'/`=v[`i']'" "`cmd'/`=v[`i']'", replace"' _n
		}
	}
	qui cap copy "http://fmwww.bc.edu/repec/bocode/`prefix'/stata.toc" "`cmd'/stata.toc", replace
	if _rc != 0{
		di as yellow "下载 stata.toc 失败!"
		file write myfile_failed `"copy "http://fmwww.bc.edu/repec/bocode/`prefix'/stata.toc" "`cmd'/stata.toc", replace"' _n
	}
	file write myfile "* 4. 下载 stata.toc 文件:" _n /// 
		`"copy "http://fmwww.bc.edu/repec/bocode/`prefix'/stata.toc" "`cmd'/stata.toc", replace"' _n
	* Installing ...
	di in green "下载完成!"
	if "`install'" != ""{
		di in green "安装中 ..."
		file write myfile_failed _n `"net install `cmd'.pkg, from("`c(pwd)'/`cmd'") replace force"' _n _n
		cap net install `cmd'.pkg, from("`c(pwd)'/`cmd'") replace force
		if _rc != 0{
			di as yellow "安装失败！请重试！"
		}
		if _rc == 0{
			di as green "安装成功！"
			cap erase `cmd'_failed.do
		}
		file write myfile "* 5. 安装该命令包: " _n ///
			`"net install `cmd'.pkg, from("`c(pwd)'/`cmd'") replace force"' _n
	}
	file close myfile
	file close myfile_failed
end
