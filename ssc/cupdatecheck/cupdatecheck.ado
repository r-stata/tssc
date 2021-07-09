*! cupdateCheck
*! version 0.0.0.9000
*! TidyFriday
*! 功能：Stata更新检查
prog drop _all
prog define cupdatecheck
	qui{
		update
		local cdatenum = `r(inst_ado)'
		local cdate = string(20989, "%tdCY-N-D")
		local version = int(c(stata_version))
		tempfile tempcsvfile
		copy "https://www.stata.com/support/updates/stata`version'.html" `tempcsvfile', replace
		cap unicode encoding set gb18030
		cap unicode translate `tempcsvfile'
		cap unicode erasebackups, badidea
		infix strL v 1-20000 using `tempcsvfile', clear
		keep if index(v, "date earlier than")
		replace v = ustrregexs(1) if ustrregexm(v, `"\"(.*)\""')
		local date = v[1]
		local datenum = `=date("`date'", "DMY")'
		if `datenum' > `cdatenum' {
			local des = "你的 Stata 需要升级。"
		}
		if `datenum' <= `cdatenum' {
			local des = "你的 Stata 暂时需要升级。"
		}
	}
	local date `=string(`=date("`date'", "DMY")', "%tdCY-N-D")'
	di as text `"欢迎使用 Stata 版本检查器，任何使用问题欢迎关注微信公众号 {bf: RStata} 获取解决方案。"'
	di as text `"{bf: 1.} 该 Stata 的版本为: {bf: `cdate'}"'
	di as text `"{bf: 2.} 最近版本更新发布时间为: {bf: `date'}，`des'"'
	di as yellow `"{bf: 3.} 你可以从{bf:{browse "https://www.stata.com/support/updates/stata`version'.html": Stata 官网}}上下载离线更新版解压后运行{stata db update:db update}然后选择解压后的文件夹进行更新。"'
	clear
end
