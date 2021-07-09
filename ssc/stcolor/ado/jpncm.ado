*! Version 0.0.0.9000 日本传统色地图
cap program drop jpncm
program define jpncm, rclass
	syntax [, Quietly Color(string)]
	cap preserve
	qui drop _all
	if "`color'" == "" local color = "red"
	if "`color'" == "red"{
		clear all
		local lista =  `"red "220 159 180" "225 107 140" "142 53 74" "248 195 205" "244 167 185" "100 54 60" "245 150 170" "181 73 91" "232 122 144" "208 90 110" "219 77 109" "254 223 225" "158 122 122" "208 16 76" "159 53 58" "203 27 69" "238 169 169" "191 103 102" "134 71 63" "177 150 147" "235 122 119" "149 74 69" "169 99 96" "203 64 66" "171 59 58" "215 196 187" "144 72 64" "115 67 56" "199 62 58" "85 66 54" "153 70 57" "241 148 131" "181 68 52" "185 136 125" "241 124 103" "136 76 58" "232 48 21" "215 84 85" "204 84 58" "247 92 46" "240 94 28" "'
		local lista1 Stata标准红 抚子 红梅 苏芳 退红 一斥染 桑染 桃 莓 薄红 令样 中红 浅红 梅鼠 韩红花 燕脂 红 粉红 长春 深绯 楼鼠 甚三红 小豆 苏芳香 赤红 真朱 灰楼 栗梅 海老茶 银朱 里鸢 红鸢 曙 红桦 水棕 珊瑚朱 红桧皮 猩猩绯 铅丹 绯 红绯 黄丹
		ret local 抚子 = "220 159 180" 
		ret local 红梅 = "225 107 140"
		ret local 苏芳 = "142 53 74" 
		ret local 退红 = "248 195 205" 
		ret local 一斥染 = "244 167 185" 
		ret local 桑染 = "100 54 60" 
		ret local 桃 = "245 150 170" 
		ret local 莓 = "181 73 91" 
		ret local 薄红 = "232 122 144" 
		ret local 令样 = "208 90 110" 
		ret local 中红 = "219 77 109" 
		ret local 浅红 = "254 223 225" 
		ret local 梅鼠 = "158 122 122" 
		ret local 韩红花 = "208 16 76" 
		ret local 燕脂 = "159 53 58" 
		ret local 红 = "203 27 69" 
		ret local 粉红 = "238 169 169"
		ret local 长春 = "191 103 102" 
		ret local 深绯 = "134 71 63" 
		ret local 楼鼠 = "177 150 147" 
		ret local 甚三红 = "235 122 119" 
		ret local 小豆 = "149 74 69" 
		ret local 苏芳香 = "169 99 96" 
		ret local 赤红 = "203 64 66" 
		ret local 真朱 = "171 59 58" 
		ret local 灰楼 = "215 196 187" 
		ret local 栗梅 = "144 72 64" 
		ret local 海老茶 = "115 67 56" 
		ret local 银朱 = "199 62 58" 
		ret local 里鸢 = "85 66 54" 
		ret local 红鸢 = "153 70 57" 
		ret local 曙 = "241 148 131" 
		ret local 红桦 = "181 68 52" 
		ret local 水棕 = "185 136 125" 
		ret local 珊瑚朱 = "241 124 103" 
		ret local 红桧皮 = "136 76 58" 
		ret local 猩猩绯 = "232 48 21"
		ret local 铅丹 = "215 84 85" 
		ret local 绯 = "204 84 58" 
		ret local 红绯 = "247 92 46" 
		ret local 黄丹 = "240 94 28"
		local xmax = 6
		local targname mcolor
		local title "日本传统色——红色系"
		local cmd
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela in `lista' {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mcolor("`mcolor'") mlabpos(3) msize(vhuge) msymbol(S)"'
			local cmd `"`cmd' (`c')"'
		}
		clear
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela of local lista1 {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mlabel(s) mlabpos(3) msize(vhuge) msymbol(i)"'
			local cmd `"`cmd' (`c')"'
		}
		* di "`cmd'"
		local topx = `xmax' + .6
		local topy = `y' + 1
		`quietly' di as text "正在排列颜色，请稍后···" 
		capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))	///
			xlab(none) ylab(none) ysca(reverse)			///
			xtitle("") ytitle("") title("`title'")			///
			legend(nodraw)
	}
	if "`color'" == "brown"{
		clear all
		local lista =  `" brown "181 93 76" "133 72 54" "163 94 71" "114 72 50" "106 64 40" "154 80 52" "196 98 67" "175 95 60" "251 150 110" "114 73 56" "180 113 87" "219 142 113" "237 120 74" "202 120 83" "179 92 55" "86 63 46" "227 145 110" "143 90 60" "240 169 134" "160 103 75" "193 105 60" "251 153 102" "148 122 109" "163 99 54" "231 148 96" "125 83 44" "199 133 80" "152 95 42" "225 166 121" "133 91 50" "252 159 77" "255 186 132" "233 139 42" "233 163 104" "177 120 68" "150 99 46" "67 52 27" "202 122 44" "236 184 138" "120 85 43" "176 119 54" "150 114 73" "226 148 59" "199 128 45" "155 110 35" "110 85 47" "235 180 113" "215 185 142" "130 102 58" "182 142 85" "188 159 119" "135 102 51" "193 138 38" "'
		local lista1 Stata标准棕 芝茶 桧皮 柿 鸢 栗皮茶 柄 照柿 江户茶 洗朱 百茶 唐茶 棕茶 薰 远州茶 桦茶 焦茶 赤香 雀茶 宋 宗传唐茶 桦 深支子 胡桃 代赭 洗柿 黄染 赤朽 万茶 赤白象 煎茶 萱草 洒落柿 红金 梅染 枇杷茶 丁子茶 法染 琥珀 薄柿 伽罗 丁子染 紫染 朽 金茶 狐 煤竹 薄香 砥粉 银煤竹 黄土 白茶 媚茶 黄糖茶
		ret local 芝茶 = "181 93 76" 
		ret local 桧皮 = "133 72 54" 
		ret local 柿 = "163 94 71" 
		ret local 鸢 = "114 72 50" 
		ret local 栗皮茶 = "106 64 40" 
		ret local 柄 = "154 80 52" 
		ret local 照柿 = "196 98 67" 
		ret local 江户茶 = "175 95 60" 
		ret local 洗朱 = "251 150 110" 
		ret local 百茶 = "114 73 56" 
		ret local 唐茶 = "180 113 87" 
		ret local 棕茶 = "219 142 113" 
		ret local 薰 = "237 120 74" 
		ret local 远州茶 = "202 120 83" 
		ret local 桦茶 = "179 92 55" 
		ret local 焦茶 = "86 63 46" 
		ret local 赤香 = "227 145 110" 
		ret local 雀茶 = "143 90 60" 
		ret local 宋 = "240 169 134" 
		ret local 宗传唐茶 = "160 103 75" 
		ret local 桦 = "193 105 60" 
		ret local 深支子 = "251 153 102" 
		ret local 胡桃 = "148 122 109" 
		ret local 代赭 = "163 99 54" 
		ret local 洗柿 = "231 148 96" 
		ret local 黄染 = "125 83 44" 
		ret local 赤朽 = "199 133 80" 
		ret local 万茶 = "152 95 42" 
		ret local 赤白象 = "225 166 121" 
		ret local 煎茶 = "133 91 50" 
		ret local 萱草 = "252 159 77" 
		ret local 洒落柿 = "255 186 132" 
		ret local 红金 = "233 139 42" 
		ret local 梅染 = "233 163 104" 
		ret local 枇杷茶 = "177 120 68" 
		ret local 丁子茶 = "150 99 46" 
		ret local 法染 = "67 52 27" 
		ret local 琥珀 = "202 122 44" 
		ret local 薄柿 = "236 184 138" 
		ret local 伽罗 = "120 85 43" 
		ret local 丁子染 = "176 119 54"
		ret local 紫染 = "150 114 73"
		ret local 朽 = "226 148 59" 
		ret local 金茶 = "199 128 45" 
		ret local 狐 = "155 110 35" 
		ret local 煤竹 = "110 85 47" 
		ret local 薄香 = "235 180 113" 
		ret local 砥粉 = "215 185 142" 
		ret local 银煤竹 = "130 102 58" 
		ret local 黄土 = "182 142 85" 
		ret local 白茶 = "188 159 119" 
		ret local 媚茶 = "135 102 51" 
		ret local 黄糖茶 = "193 138 38"
		local xmax = 6
		local targname mcolor
		local title "日本传统色——棕色系"
		local cmd ""
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela in `lista' {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mcolor("`mcolor'") mlabpos(3) msize(vhuge) msymbol(S)"'
			local cmd `"`cmd' (`c')"'
		}
		clear
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela of local lista1 {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mlabel(s) mlabpos(3) msize(vhuge) msymbol(i)"'
			local cmd `"`cmd' (`c')"'
		}
		* di "`cmd'"
		local topx = `xmax' + .6
		local topy = `y' + 1
		`quietly' di as text "正在排列颜色，请稍后···" 
		capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))	///
			xlab(none) ylab(none) ysca(reverse)			///
			xtitle("") ytitle("") title("`title'")			///
			legend(nodraw)
	}
	if "`color'" == "yellow"{
		clear all
		local lista =  `" yellow "255 177 27" "209 152 38" "221 165 45" "201 152 51" "249 191 69" "220 184 121" "186 145 50" "232 182 71" "247 194 66" "125 108 70" "218 201 166" "250 214 137" "217 171 66" "246 197 85" "255 196 8" "239 187 36" "202 173 75" "141 116 42" "180 165 130" "135 127 108" "137 125 85" "116 103 62" "162 140 55" "108 96 36" "134 120 53" "98 89 44" "233 205 76" "247 217 76" "251 226 81" "'
		local lista1 Stata标准黄 山吹 山吹茶 栌染 桑茶 玉子 白橡 黄橡 玉蜀黍 黄花 生壁 乌子 浅黄 黄朽 栀子 藤黄 鹿金 芥子 肥后煤竹 利休白茶 灰汁 利休茶 路考茶 菜籽油 鸳茶 黄海松茶 海松茶 刈安 菜花 黄蘖 
		ret local 山吹 = "255 177 27" 
		ret local 山吹茶 = "209 152 38" 
		ret local 栌染 = "221 165 45" 
		ret local 桑茶 = "201 152 51" 
		ret local 玉子 = "249 191 69" 
		ret local 白橡 = "220 184 121" 
		ret local 黄橡 = "186 145 50" 
		ret local 玉蜀黍 = "232 182 71" 
		ret local 黄花 = "247 194 66" 
		ret local 生壁 = "125 108 70" 
		ret local 乌子 = "218 201 166" 
		ret local 浅黄 = "250 214 137" 
		ret local 黄朽 = "217 171 66" 
		ret local 栀子 = "246 197 85" 
		ret local 藤黄 = "255 196 8" 
		ret local 鹿金 = "239 187 36" 
		ret local 芥子 = "202 173 75" 
		ret local 肥后煤竹 = "141 116 42" 
		ret local 利休白茶 = "180 165 130" 
		ret local 灰汁 = "135 127 108" 
		ret local 利休茶 = "137 125 85" 
		ret local 路考茶 = "116 103 62" 
		ret local 菜籽油 = "162 140 55" 
		ret local 鸳茶 = "108 96 36" 
		ret local 黄海松茶 = "134 120 53" 
		ret local 海松茶 = "98 89 44" 
		ret local 刈安 = "233 205 76" 
		ret local 菜花 = "247 217 76" 
		ret local 黄蘖 = "251 226 81"
		local xmax = 6
		local targname mcolor
		local title "日本传统色——黄色系"
		local cmd ""
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela in `lista' {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mcolor("`mcolor'") mlabpos(3) msize(vhuge) msymbol(S)"'
			local cmd `"`cmd' (`c')"'
		}
		clear
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela of local lista1 {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mlabel(s) mlabpos(3) msize(vhuge) msymbol(i)"'
			local cmd `"`cmd' (`c')"'
		}
		* di "`cmd'"
		local topx = `xmax' + .6
		local topy = `y' + 1
		`quietly' di as text "正在排列颜色，请稍后···" 
		capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))	///
			xlab(none) ylab(none) ysca(reverse)			///
			xtitle("") ytitle("") title("`title'")			///
			legend(nodraw)
	}
	if "`color'" == "green"{
		clear all
		local lista =  `" green "217 205 144" "173 161 66" "221 210 59" "165 160 81" "190 194 63" "108 106 45" "147 150 80" "131 138 45" "177 180 121" "97 97 56" "75 78 42" "91 98 46" "77 81 57" "137 145 107" "144 180 75" "145 173 112" "181 202 160" "100 106 88" "123 162 63" "134 193 102" "74 89 61" "66 96 45" "81 110 65" "145 180 147" "128 143 124" "27 129 62" "93 172 129" "54 86 60" "34 125 81" "168 216 185" "106 131 114" "45 109 75" "70 93 76" "36 147 110" "134 166 151" "'
		local lista1 Stata标准绿 蒸栗 青朽 女郎花 鶸茶 鶸 鸳 柳茶 苔 鞠鹿 璃宽茶 蓝媚茶 海松 千岁茶 梅幸茶 鶸萌黄 柳染 裹柳 岩井茶 萌黄 苗 柳煤竹 松 青丹 薄青 柳鼠 常磐 若竹 千岁绿 绿 白绿 老竹 木賊 御纳户茶 绿青 青磁  
		ret local 蒸栗 = "217 205 144" 
		ret local 青朽 = "173 161 66" 
		ret local 女郎花 = "221 210 59" 
		ret local 鶸茶 = "165 160 81" 
		ret local 鶸 = "190 194 63" 
		ret local 鸳 = "108 106 45" 
		ret local 柳茶 = "147 150 80" 
		ret local 苔 = "131 138 45" 
		ret local 鞠鹿 = "177 180 121" 
		ret local 璃宽茶 = "97 97 56" 
		ret local 蓝媚茶 = "75 78 42" 
		ret local 海松 = "91 98 46" 
		ret local 千岁茶 = "77 81 57" 
		ret local 梅幸茶 = "137 145 107" 
		ret local 鶸萌黄 = "144 180 75" 
		ret local 柳染 = "145 173 112" 
		ret local 裹柳 = "181 202 160" 
		ret local 岩井茶 = "100 106 88" 
		ret local 萌黄 = "123 162 63" 
		ret local 苗 = "134 193 102" 
		ret local 柳煤竹 = "74 89 61" 
		ret local 松 = "66 96 45" 
		ret local 青丹 = "81 110 65" 
		ret local 薄青 = "145 180 147" 
		ret local 柳鼠 = "128 143 124" 
		ret local 常磐 = "27 129 62" 
		ret local 若竹 = "93 172 129" 
		ret local 千岁绿 = "54 86 60" 
		ret local 绿 = "34 125 81" 
		ret local 白绿 = "168 216 185" 
		ret local 老竹 = "106 131 114" 
		ret local 木賊  = "45 109 75" 
		ret local 御纳户茶 = "70 93 76" 
		ret local 绿青 = "36 147 110" 
		ret local 青磁 = "134 166 151"
		local xmax = 6
		local targname mcolor
		local title "日本传统色——绿色系"
		local cmd ""
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela in `lista' {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mcolor("`mcolor'") mlabpos(3) msize(vhuge) msymbol(S)"'
			local cmd `"`cmd' (`c')"'
		}
		clear
		qui set obs 0
		qui gen x = .
		qui gen y = .
		qui gen str10 s = ""
		local x = 0
		local y = 1
		foreach ela of local lista1 {
			local `targname' `ela'
			local x = `x'+1
			if `x' > `xmax' {
				local y = `y' + 1
				local x = 1
			}
			local obs = `=_N'+1 
			qui set obs `obs' 
			qui replace y = `y' in l
			qui replace x = `x' in l
			qui replace s = "`ela'" in l
			local c `"sc y x in `=_N', pstyle(p1) mlabel(s) mlabpos(3) msize(vhuge) msymbol(i)"'
			local cmd `"`cmd' (`c')"'
		}
		* di "`cmd'"
		local topx = `xmax' + .6
		local topy = `y' + 1
		`quietly' di as text "正在排列颜色，请稍后···" 
		capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))	///
			xlab(none) ylab(none) ysca(reverse)			///
			xtitle("") ytitle("") title("`title'")			///
			legend(nodraw)
	}
  di as text "更多颜色地图"
  di as text "    {stata cncm, c(1):cncm, c(1)}"
  di as text "    {stata cncm, c(2):cncm, c(2)}"
  di as text "    {stata cncm, c(3):cncm, c(3)}"
  di as text "    {stata gcm, c(1):gcm, c(1)}"
  di as text "    {stata gcm, c(2):gcm, c(2)}"
  di as text "    {stata gcm, c(3):gcm, c(3)}"
  di as text "    {stata gcm, c(4):gcm, c(4)}"
  di as text "    {stata gcm, c(5):gcm, c(5)}"
  di as text "    {stata jpncm, c(red):红色色系颜色地图}"
  di as text "    {stata jpncm, c(brown):棕色色系颜色地图}"
  di as text "    {stata jpncm, c(green):绿色色系颜色地图}"
  di as text "    {stata jpncm, c(yellow):黄色色系颜色地图}"
  di as text "{stata return list:查看返回值}"
end

