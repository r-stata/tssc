*! Version 0.0.0.9000 日本传统色地图
cap program drop cncm
program define cncm, rclass
	syntax [, Quietly Color(string)]
	cap preserve
	set more off
	set scheme s1mono
	qui drop _all
	if "`color'" == "" local color = "1"
	if "`color'" == "3"{
		clear all
		local lista =  `" "48 48 48" "78 24 146" "31 54 150" "39 104 147" "86 149 151" "198 83 6" "37 56 107" "78 95 69" "219 206 84" "117 117 112" "90 92 91" "175 94 83" "123 161 168" "227 239 209" "0 110 95" "67 69 74" "109 115 88" "48 71 88" "215 193 107" "174 196 183" "54 53 50" "27 84 242" "196 71 61" "195 86 85" "228 207 142" "106 104 52" "234 220 214" "100 147 175" "136 174 163" "23 80 125" "79 83 85" "176 183 172" "84 107 131" "235 232 219" "93 130 138" "92 137 135" "'
		local lista1 百草霜 柏坊灰蓝 宝蓝 北京毛蓝 碧玉石 苍黄 藏蓝 苍绿 草黄 承德灰 承德皂 辰砂 春蓝 春绿 翠绿 粗晶皂 大赤金 黛蓝 丹东石 淡灰绿 灯草灰 靛蓝 蕃茄红 妃红 甘草黄 橄榄绿 甘石粉 钴蓝 果灰 海蓝 红皂 黄灰 花青 胡粉 灰蓝 灰绿
		ret local 百草霜 = "48 48 48" 
		ret local 柏坊灰蓝 = "78 24 146" 
		ret local 宝蓝 = "31 54 150" 
		ret local 北京毛蓝 = "39 104 147" 
		ret local 碧玉石 = "86 149 151" 
		ret local 苍黄 = "198 83 6" 
		ret local 藏蓝 = "37 56 107" 
		ret local 苍绿 = "78 95 69" 
		ret local 草黄 = "219 206 84" 
		ret local 承德灰 = "117 117 112" 
		ret local 承德皂 = "90 92 91" 
		ret local 辰砂 = "175 94 83" 
		ret local 春蓝 = "123 161 168" 
		ret local 春绿 = "227 239 209" 
		ret local 翠绿 = "0 110 95" 
		ret local 粗晶皂 = "67 69 74" 
		ret local 大赤金 = "109 115 88" 
		ret local 黛蓝 = "48 71 88" 
		ret local 丹东石 = "215 193 107" 
		ret local 淡灰绿 = "174 196 183" 
		ret local 灯草灰 = "54 53 50" 
		ret local 靛蓝 = "27 84 242" 
		ret local 蕃茄红 = "196 71 61" 
		ret local 妃红 = "195 86 85" 
		ret local 甘草黄 = "228 207 142" 
		ret local 橄榄绿 = "106 104 52" 
		ret local 甘石粉 = "234 220 214" 
		ret local 钴蓝 = "100 147 175" 
		ret local 果灰 = "136 174 163" 
		ret local 海蓝 = "23 80 125" 
		ret local 红皂 = "79 83 85" 
		ret local 黄灰 = "176 183 172" 
		ret local 花青 = "84 107 131" 
		ret local 胡粉 = "235 232 219" 
		ret local 灰蓝 = "93 130 138" 
		ret local 灰绿 = "92 137 135"
		local xmax = 6
		local targname mcolor
		local title "中国传统色——色板3"
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
	if "`color'" == "2"{
		clear all
		local lista =  `" "182 177 150" "180 148 54" "109 97 74" "112 77 78" "231 105 63" "232 133 59" "199 122 58" "202 212 186" "0 65 165" "133 121 79" "183 178 120" "231 229 208" "61 110 83" "213 75 68" "169 176 143" "151 52 68" "121 61 86" "225 189 162" "197 191 173" "245 245 220" "175 200 186" "193 162 153" "233 219 57" "167 19 104" "60 94 145" "222 168 122" "218 149 88" "162 32 118" "171 150 197" "196 195 203" "201 174 140" "234 205 209" "225 219 205" "213 184 132" "100 115 112" "103 73 80" "'
		local lista1 灰米 姜黄 将校呢 绛紫 桔红 桔黄 金黄 军绿 孔雀蓝 库金 枯绿 蜡白 老绿 榴花红 芦灰 玫瑰红 玫瑰灰 米红 米灰 米色 奶绿 奶棕 柠檬黄 品红 浅海昌蓝 浅黄棕 浅桔黄 牵牛紫 浅石英紫 浅藤紫 浅驼色 浅血牙 浅棕灰 卡其黄 卡其绿 茄皮紫
		ret local 灰米 = "182 177 150" 
		ret local 姜黄 = "180 148 54" 
		ret local 将校呢 = "109 97 74" 
		ret local 绛紫 = "112 77 78" 
		ret local 桔红 = "231 105 63" 
		ret local 桔黄 = "232 133 59" 
		ret local 金黄 = "199 122 58" 
		ret local 军绿 = "202 212 186" 
		ret local 孔雀蓝 = "0 65 165" 
		ret local 库金 = "133 121 79" 
		ret local 枯绿 = "183 178 120" 
		ret local 蜡白 = "231 229 208" 
		ret local 老绿 = "61 110 83" 
		ret local 榴花红 = "213 75 68" 
		ret local 芦灰 = "169 176 143" 
		ret local 玫瑰红 = "151 52 68" 
		ret local 玫瑰灰 = "121 61 86" 
		ret local 米红 = "225 189 162" 
		ret local 米灰 = "197 191 173" 
		ret local 米色 = "245 245 220" 
		ret local 奶绿 = "175 200 186" 
		ret local 奶棕 = "193 162 153" 
		ret local 柠檬黄 = "233 219 57" 
		ret local 品红 = "167 19 104" 
		ret local 浅海昌蓝 = "60 94 145" 
		ret local 浅黄棕 = "222 168 122" 
		ret local 浅桔黄 = "218 149 88" 
		ret local 牵牛紫 = "162 32 118" 
		ret local 浅石英紫 = "171 150 197" 
		ret local 浅藤紫 = "196 195 203" 
		ret local 浅驼色 = "201 174 140" 
		ret local 浅血牙 = "234 205 209" 
		ret local 浅棕灰 = "225 219 205" 
		ret local 卡其黄 = "213 184 132" 
		ret local 卡其绿 = "100 115 112" 
		ret local 茄皮紫 = "103 73 80"
		local xmax = 6
		local targname mcolor
		local title "中国传统色——色板2"
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
	if "`color'" == "1"{
		clear all
		local lista =  `" "69 86 103" "49 103 141" "144 202 175" "0 91 90" "43 94 125" "90 76 76" "100 52 65" "37 120 181" "252 177 170" "148 156 151" "190 210 182" "242 222 118" "46 195 231" "55 68 75" "206 147 53" "98 92 82" "160 62 40" "196 55 57" "208 133 61" "228 117 66" "77 25 25" "184 200 183" "121 111 84" "255 250 250" "121 72 90" "209 227 219" "156 102 128" "220 20 60" "204 53 54" "0 142 89" "221 59 68" "69 85 74" "63 63 60" "62 60 61" "192 63 60" "88 90 87" "187 28 51" "80 120 131" "137 48 63" "235 101 45" "147 162 169" "219 199 166" "116 138 141" "188 165 144" "169 152 124" "165 67 88" "195 166 203" "133 126 149" "238 165 209" "184 132 79" "201 120 12" "198 111 53" "201 129 80" "57 32 15" "'
		local lista1 鹊灰 绒蓝 三绿 沙绿 沙青 深烟 深烟红 深竹月 十样锦 水貂灰 水黄 藤黄 天青 铁灰 土黄 相思灰 血红 猩红 雄黄 雄精 锈红 锈绿 选金 雪色 雪紫 鸭蛋青 洋葱紫 洋红 艳红 鹦鹉绿 银朱 油绿 油烟墨 元青 胭脂 银箔 月季红 玉石蓝 枣红 章丹 正灰 枝黄 织锦灰 纸棕 中棕灰 紫粉 紫水晶 紫藤灰 紫薇花 棕茶 琉璃 桂皮 红孤 酱色
		ret local 鹊灰 = "69 86 103" 
		ret local 绒蓝 = "49 103 141" 
		ret local 三绿 = "144 202 175" 
		ret local 沙绿 = "0 91 90" 
		ret local 沙青 = "43 94 125" 
		ret local 深烟 = "90 76 76" 
		ret local 深烟红 = "100 52 65" 
		ret local 深竹月 = "37 120 181" 
		ret local 十样锦 = "252 177 170" 
		ret local 水貂灰 = "148 156 151" 
		ret local 水黄 = "190 210 182" 
		ret local 藤黄 = "242 222 118" 
		ret local 天青 = "46 195 231" 
		ret local 铁灰 = "55 68 75" 
		ret local 土黄 = "206 147 53" 
		ret local 相思灰 = "98 92 82" 
		ret local 血红 = "160 62 40" 
		ret local 猩红 = "196 55 57" 
		ret local 雄黄 = "208 133 61" 
		ret local 雄精 = "228 117 66" 
		ret local 锈红 = "77 25 25" 
		ret local 锈绿 = "184 200 183" 
		ret local 选金 = "121 111 84" 
		ret local 雪色 = "255 250 250" 
		ret local 雪紫 = "121 72 90" 
		ret local 鸭蛋青 = "209 227 219" 
		ret local 洋葱紫 = "156 102 128" 
		ret local 洋红 = "220 20 60" 
		ret local 艳红 = "204 53 54" 
		ret local 鹦鹉绿 = "0 142 89" 
		ret local 银朱 = "221 59 68" 
		ret local 油绿 = "69 85 74" 
		ret local 油烟墨 = "63 63 60" 
		ret local 元青 = "62 60 61" 
		ret local 胭脂 = "192 63 60" 
		ret local 银箔 = "88 90 87" 
		ret local 月季红 = "187 28 51" 
		ret local 玉石蓝 = "80 120 131" 
		ret local 枣红 = "137 48 63" 
		ret local 章丹 = "235 101 45" 
		ret local 正灰 = "147 162 169" 
		ret local 枝黄 = "219 199 166" 
		ret local 织锦灰 = "116 138 141" 
		ret local 纸棕 = "188 165 144" 
		ret local 中棕灰 = "169 152 124" 
		ret local 紫粉 = "165 67 88" 
		ret local 紫水晶 = "195 166 203" 
		ret local 紫藤灰 = "133 126 149" 
		ret local 紫薇花 = "238 165 209" 
		ret local 棕茶 = "184 132 79"
		ret local 琉璃 = "201 120 12" 
		ret local 桂皮 = "198 111 53" 
		ret local 红孤 = "201 129 80" 
		ret local 酱色 = "57 32 15"
		local xmax = 6
		local targname mcolor
		local title "中国传统色——色板1"
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

