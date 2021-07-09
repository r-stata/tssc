*! 功能1: 调用本地仓库数据集
*! 功能2: 调用远端仓库数据集
*! 功能3: 将数据集存入系统文件夹中
cap prog drop cuse
prog define cuse
	version 14.0
	if `"`0'"' == "" {
		error 198
	}
	local 0 `"using `0'"'
	syntax using/ [, Clear Web Savetosystem]
	if "`web'" != ""{
		
	}
	else{
		local url "~/Documents/cuse"
	}
	local prefix = substr("`using'", 1, 1)
	use `"`url'/`prefix'/`using'"', `clear'
	if "`savetosystem'" != ""{
		cap mkdir "`c(sysdir_plus)'/`prefix'"
		local syspath "`c(sysdir_plus)'"
		save "`syspath'`prefix'/`using'", replace
	}
end
