*! 爬取沪深两市所有上市公司基本情况数据
*! TidyFriday 2020年8月17日
*! 用法：
*! 		下载两市所有公司：cnstock2
*! 		下载沪市的：cnstock2, m(SH)
*! 		下载深市的：cnstock2, m(SZ)
*! 数据来源：http://stockdata.stock.hexun.com/gszl/
*! 沪市：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=3000&on=2&titType=null&page=1&callback=hxbase_json15
*! 深市：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=2000&on=1&titType=null&page=1&callback=hxbase_json15
*! 全市场：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=5000&titType=null&page=1&callback=hxbase_json15
cap prog drop cnstock3
prog def cnstock3
	version 7.0
	syntax [, Market(string)]
	di in yellow "下载中..."
	di in green "该命令由 TidyFriday 编写，使用中出现的任何问题欢迎关注微信公众号 RStata 咨询～"
	if "`market'" == "SH" {
		local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=3000&on=2&titType=null&page=1&callback=hxbase_json15"
	}
	if "`market'" == "SZ" {
		local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=2000&on=1&titType=null&page=1&callback=hxbase_json15"
	}
	if "`market'" == "" {
		local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=5000&titType=null&page=1&callback=hxbase_json15"
	}
	qui{
		clear
		copy "`url'" "temp.json", replace
		cap erase temp2.json
		mata: file()
		* 处理 json 格式的数据
		* 转码
		unicode encoding set gb18030
		unicode translate "temp2.json"
		unicode erasebackups, badidea
		gen str100 Stockname = ""
		gen str100 Pricelimit = ""
		gen str100 lootchips = ""
		gen str100 shareholders = ""
		gen str100 Institutional = ""
		gen str100 Iratio = ""
		gen str100 district = ""
		gen str100 deviation = ""
		gen str100 Cprice = ""
		gen str200 maincost = ""
		insheetjson Stockname Pricelimit lootchips shareholders Institutional Iratio district deviation Cprice maincost using "temp2.json", table(list) col("Stockname" "Pricelimit" "lootchips" "shareholders" "Institutional" "Iratio" "district" "deviation" "Cprice" "maincost")
		replace district = ustrregexs(1) if ustrregexm(district, ">(.*)<")
		replace maincost = ustrregexs(1) if ustrregexm(maincost, `"'>(.*)</a"')
		replace deviation = ustrregexs(1) if ustrregexm(deviation, ">(.*)<")
		foreach i of varlist _all {
			replace `i' = "" if `i' == "--"
		}
		compress
		destring, replace
		cap erase temp.json
		cap erase temp2.json
		split Stockname, parse("(" ")")
		drop Stockname
		ren Stockname1 name
		label var name "公司名称"
		ren Stockname2 code
		label var code "公司代码"
		order name code
		ren Pricelimit total_stock_num
		label var total_stock_num "总股本（亿股）"
		ren lootchips outstanding_stock_num
		label var outstanding_stock_num "流通股本（亿股）"
		ren shareholders outstanding_stock_value
		label var outstanding_stock_value "流通市值（亿元）"
		ren Institutional registered_capital
		label var registered_capital "注册资本（万元）"
		ren Iratio pe_ratio
		label var pe_ratio "市盈率（倍）"
		ren deviation industry
		label var industry "行业"
		ren Cprice close 
		label var close "收盘价"
		ren maincost concept
		label var concept "所属概念"
		ren district area
		label var area "所属区域"
	}
	di in green "获取成功..."
end

mata:
	void file() {
		fin = fopen("temp.json", "r")
		line = fread(fin, 3000000)
		line = subinstr(line, `"'"', `"""', .)
		line = subinstr(line, `""_blank""', `"'_blank'"', .)
		line = subinstr(line, `"openshowd(this,""', "", .)
		line = subinstr(line, `"","1")"', "", .)
		line = subinstr(line, `""Closed(this)""', "", .)
		line = subinstr(line, `"<img alt="" src=""', "", .)
		line = subinstr(line, `""/>"', "", .)
		line = subinstr(line, "sum", `""sum""', .)
		line = subinstr(line, "list", `""list""', .)
		line = subinstr(line, "Number", `""Number""', .)
		line = subinstr(line, "StockNameLink", `""StockNameLink""', .)
		line = subinstr(line, "Stockname", `""Stockname""', .)
		line = subinstr(line, "Pricelimit", `""Pricelimit""', .)
		line = subinstr(line, "lootchips", `""lootchips""', .)
		line = subinstr(line, "shareholders", `""shareholders""', .)
		line = subinstr(line, "Institutional", `""Institutional""', .)
		line = subinstr(line, "Iratio", `""Iratio""', .)
		line = subinstr(line, "deviation", `""deviation""', .)
		line = subinstr(line, "maincost", `""maincost""', .)
		line = subinstr(line, "district", `""district""', .)
		line = subinstr(line, "Cprice", `""Cprice""', .)
		line = subinstr(line, "Stockoverview", `""Stockoverview""', .)
		line = subinstr(line, "hyLink", `""hyLink""', .)
		line = subinstr(line, "dyLink", `""dyLink""', .)
		line = subinstr(line, "gnLink", `""gnLink""', .)
		line = subinstr(line, "StockLink", `""StockLink""', .)
		line = subinstr(line, "Addoptional", `""Addoptional""', .)
		line = subinstr(line, "hxbase_json15(", "", .)
		line = subinstr(line, "}]})", "}]}", .)
		fclose(fin)
		fout = fopen("temp2.json", "w")
		fwrite(fout, line)
		fclose(fout)
	}
end
