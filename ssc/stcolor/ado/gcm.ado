*! Version 0.0.0.9000 谷歌配色地图
cap program drop gcm
program define gcm, rclass
  syntax [, Quietly Color(string)]
  cap preserve
  set more off
  set scheme plotplain
  qui drop _all
  if "`color'" == "" local color = "1"
  if "`color'" == "5"{
    clear all
    local lista =  `" "255 204 128" "255 183 77" "255 167 38" "255 152 0" "251 140 0" "245 124 0" "239 108 0" "230 81 0" "255 209 128" "255 171 64" "255 145 0" "255 101 0" "251 233 231" "255 204 188" "255 171 145" "255 138 101" "255 112 67" "255 87 34" "244 81 30" "230 74 25" "216 67 21" "191 54 12" "255 158 128" "255 110 64" "255 61 0" "221 44 0" "239 235 233" "215 204 200" "188 170 164" "161 136 127" "141 110 99" "121 85 72" "109 76 65" "93 64 55" "78 52 46" "62 39 35" "250 250 250" "245 245 245" "224 224 224" "189 189 189" "158 158 158" "117 117 117" "97 97 97" "66 66 66" "33 33 33" "236 239 241" "207 216 220" "176 190 197" "144 164 174" "120 144 156" "96 125 139" "84 110 122" "69 90 100" "55 71 79" "'
    local lista1 porange200 porange300 porange400 porange500 porange600 porange700 porange800 porange900 porangea100 porangea200 porangea400 porangea700 pdorange50 pdorange100 pdorange200 pdorange300 pdorange400 pdorange500 pdorange600 pdorange700 pdorange800 pdorange900 pdorangea100 pdorangea200 pdorangea400 pdorangea700 pbrown50 pbrown100 pbrown200 pbrown300 pbrown400 pbrown500 pbrown600 pbrown700 pbrown800 pbrown900 pgrey50 pgrey100 pgrey300 pgrey400 pgrey500 pgrey600 pgrey700 pgrey800 pgrey900 pbluegrey50 pbluegrey100 pbluegrey200 pbluegrey300 pbluegrey400 pbluegrey500 pbluegrey600 pbluegrey700 pbluegrey800
    ret local porange200  = "255 204 128"
    ret local porange300  = "255 183 77"
    ret local porange400  = "255 167 38"
    ret local porange500  = "255 152 0"
    ret local porange600  = "251 140 0"
    ret local porange700  = "245 124 0"
    ret local porange800  = "239 108 0"
    ret local porange900  = "230 81 0"
    ret local porangea100 = "255 209 128"
    ret local porangea200 = "255 171 64"
    ret local porangea400 = "255 145 0"
    ret local porangea700 = "255 101 0"
    ret local pdorange50  = "251 233 231"
    ret local pdorange100 = "255 204 188"
    ret local pdorange200 = "255 171 145"
    ret local pdorange300 = "255 138 101"
    ret local pdorange400 = "255 112 67"
    ret local pdorange500 = "255 87 34"
    ret local pdorange600 = "244 81 30"
    ret local pdorange700 = "230 74 25"
    ret local pdorange800 = "216 67 21"
    ret local pdorange900 = "191 54 12"
    ret local pdorangea100  = "255 158 128"
    ret local pdorangea200  = "255 110 64"
    ret local pdorangea400  = "255 61 0"
    ret local pdorangea700  = "221 44 0"
    ret local pbrown50  = "239 235 233"
    ret local pbrown100 = "215 204 200"
    ret local pbrown200 = "188 170 164"
    ret local pbrown300 = "161 136 127"
    ret local pbrown400 = "141 110 99"
    ret local pbrown500 = "121 85 72"
    ret local pbrown600 = "109 76 65"
    ret local pbrown700 = "93 64 55"
    ret local pbrown800 = "78 52 46"
    ret local pbrown900 = "62 39 35"
    ret local pgrey50 = "250 250 250"
    ret local pgrey100  = "245 245 245"
    ret local pgrey300  = "224 224 224"
    ret local pgrey400  = "189 189 189"
    ret local pgrey500  = "158 158 158"
    ret local pgrey600  = "117 117 117"
    ret local pgrey700  = "97 97 97"
    ret local pgrey800  = "66 66 66"
    ret local pgrey900  = "33 33 33"
    ret local pbluegrey50  = "236 239 241"
    ret local pbluegrey100 = "207 216 220"
    ret local pbluegrey200 = "176 190 197"
    ret local pbluegrey300 = "144 164 174"
    ret local pbluegrey400 = "120 144 156"
    ret local pbluegrey500 = "96 125 139"
    ret local pbluegrey600 = "84 110 122"
    ret local pbluegrey700 = "69 90 100"
    ret local pbluegrey800 = "55 71 79"
    local xmax = 6
    local targname mcolor
    local title "谷歌配色——色板5"
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
    capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))  ///
      xlab(none) ylab(none) ysca(reverse)     ///
      xtitle("") ytitle("") title("`title'")      ///
      legend(nodraw) aspect(0.6) 
  }
  if "`color'" == "4"{
    clear all
    local lista =  `" "174 213 129" "156 204 101" "139 195 74" "124 179 66" "104 159 56" "85 139 47" "51 105 30" "204 255 144" "178 255 89" "118 255 3" "100 221 23" "249 251 231" "240 244 195" "230 238 156" "220 231 117" "212 225 87" "205 220 57" "192 202 51" "175 180 43" "158 157 36" "130 119 23" "244 255 129" "238 255 65" "198 255 0" "174 234 0" "255 253 231" "255 249 196" "255 245 157" "255 241 118" "255 238 88" "255 235 59" "253 216 53" "251 192 45" "249 168 37" "245 127 23" "255 255 141" "255 234 0" "255 214 0" "255 248 225" "255 236 179" "255 224 130" "255 213 79" "255 202 40" "255 193 7" "255 179 0" "255 160 0" "255 143 0" "255 111 0" "255 229 127" "255 215 64" "255 196 0" "255 171 0" "255 243 224" "255 224 178" "'
    local lista1 plgreen300 plgreen400 plgreen500 plgreen600 plgreen700 plgreen800 plgreen900 plgreena100 plgreena200 plgreena400 plgreena700 plime50 plime100 plime200 plime300 plime400 plime500 plime600 plime700 plime800 plime900 plimea100 plimea200 plimea400 plimea700 pyellow50 pyellow100 pyellow200 pyellow300 pyellow400 pyellow500 pyellow600 pyellow700 pyellow800 pyellow900 pyellowa100 pyellowa400 pyellowa700 pamber50 pamber100 pamber200 pamber300 pamber400 pamber500 pamber600 pamber700 pamber800 pamber900 pambera100 pambera200 pambera400 pambera700 porange50 porange100
    ret local plgreen300 = "174 213 129"
    ret local plgreen400 = "156 204 101"
    ret local plgreen500 = "139 195 74"
    ret local plgreen600 = "124 179 66"
    ret local plgreen700 = "104 159 56"
    ret local plgreen800 = "85 139 47"
    ret local plgreen900 = "51 105 30"
    ret local plgreena100  = "204 255 144"
    ret local plgreena200  = "178 255 89"
    ret local plgreena400  = "118 255 3"
    ret local plgreena700  = "100 221 23"
    ret local plime50 = "249 251 231"
    ret local plime100  = "240 244 195"
    ret local plime200  = "230 238 156"
    ret local plime300  = "220 231 117"
    ret local plime400  = "212 225 87"
    ret local plime500  = "205 220 57"
    ret local plime600  = "192 202 51"
    ret local plime700  = "175 180 43"
    ret local plime800  = "158 157 36"
    ret local plime900  = "130 119 23"
    ret local plimea100 = "244 255 129"
    ret local plimea200 = "238 255 65"
    ret local plimea400 = "198 255 0"
    ret local plimea700 = "174 234 0"
    ret local pyellow50 = "255 253 231"
    ret local pyellow100  = "255 249 196"
    ret local pyellow200  = "255 245 157"
    ret local pyellow300  = "255 241 118"
    ret local pyellow400  = "255 238 88"
    ret local pyellow500  = "255 235 59"
    ret local pyellow600  = "253 216 53"
    ret local pyellow700  = "251 192 45"
    ret local pyellow800  = "249 168 37"
    ret local pyellow900  = "245 127 23"
    ret local pyellowa100 = "255 255 141"
    ret local pyellowa400 = "255 234 0"
    ret local pyellowa700 = "255 214 0"
    ret local pamber50  = "255 248 225"
    ret local pamber100 = "255 236 179"
    ret local pamber200 = "255 224 130"
    ret local pamber300 = "255 213 79"
    ret local pamber400 = "255 202 40"
    ret local pamber500 = "255 193 7"
    ret local pamber600 = "255 179 0"
    ret local pamber700 = "255 160 0"
    ret local pamber800 = "255 143 0"
    ret local pamber900 = "255 111 0"
    ret local pambera100  = "255 229 127"
    ret local pambera200  = "255 215 64"
    ret local pambera400  = "255 196 0"
    ret local pambera700  = "255 171 0"
    ret local porange50 = "255 243 224"
    ret local porange100  = "255 224 178"
    local xmax = 6
    local targname mcolor
    local title "谷歌配色——色板4"
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
    capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))  ///
      xlab(none) ylab(none) ysca(reverse)     ///
      xtitle("") ytitle("") title("`title'")      ///
      legend(nodraw) aspect(0.6) 
  }
  if "`color'" == "3"{
    clear all
    local lista =  `" "3 169 244" "3 155 229" "2 136 209" "2 119 189" "1 87 155" "128 216 255" "64 196 255" "0 176 255" "0 145 234" "224 247 250" "178 235 242" "128 222 234" "77 208 225" "38 198 218" "0 188 212" "0 172 193" "0 151 167" "0 131 143" "0 96 100" "132 255 255" "24 255 255" "0 229 255" "0 184 212" "224 242 241" "178 223 219" "128 203 196" "77 182 172" "38 166 154" "0 150 136" "0 137 123" "0 121 107" "0 105 92" "0 77 64" "167 255 235" "100 255 218" "29 233 182" "0 191 165" "232 245 233" "200 230 201" "165 214 167" "129 199 132" "102 187 106" "76 175 80" "67 160 71" "56 142 60" "46 125 50" "27 94 32" "185 246 202" "105 240 174" "0 230 118" "0 200 83" "241 248 233" "220 237 200" "197 225 165" "'
    local lista1 plblue500 plblue600 plblue700 plblue800 plblue900 plbluea100 plbluea200 plbluea400 plbluea700 pcyan50 pcyan100 pcyan200 pcyan300 pcyan400 pcyan500 pcyan600 pcyan700 pcyan800 pcyan900 pcyana100 pcyana200 pcyana400 pcyana700 pteal50 pteal100 pteal200 pteal300 pteal400 pteal500 pteal600 pteal700 pteal800 pteal900 pteala100 pteala200 pteala400 pteala700 pgreen50 pgreen100 pgreen200 pgreen300 pgreen400 pgreen500 pgreen600 pgreen700 pgreen800 pgreen900 pgreena100 pgreena200 pgreena400 pgreena700 plgreen50 plgreen100 plgreen200
    ret local plblue500  = "3 169 244"
    ret local plblue600  = "3 155 229"
    ret local plblue700  = "2 136 209"
    ret local plblue800  = "2 119 189"
    ret local plblue900  = "1 87 155"
    ret local plbluea100 = "128 216 255"
    ret local plbluea200 = "64 196 255"
    ret local plbluea400 = "0 176 255"
    ret local plbluea700 = "0 145 234"
    ret local pcyan50 = "224 247 250"
    ret local pcyan100  = "178 235 242"
    ret local pcyan200  = "128 222 234"
    ret local pcyan300  = "77 208 225"
    ret local pcyan400  = "38 198 218"
    ret local pcyan500  = "0 188 212"
    ret local pcyan600  = "0 172 193"
    ret local pcyan700  = "0 151 167"
    ret local pcyan800  = "0 131 143"
    ret local pcyan900  = "0 96 100"
    ret local pcyana100 = "132 255 255"
    ret local pcyana200 = "24 255 255"
    ret local pcyana400 = "0 229 255"
    ret local pcyana700 = "0 184 212"
    ret local pteal50 = "224 242 241"
    ret local pteal100  = "178 223 219"
    ret local pteal200  = "128 203 196"
    ret local pteal300  = "77 182 172"
    ret local pteal400  = "38 166 154"
    ret local pteal500  = "0 150 136"
    ret local pteal600  = "0 137 123"
    ret local pteal700  = "0 121 107"
    ret local pteal800  = "0 105 92"
    ret local pteal900  = "0 77 64"
    ret local pteala100 = "167 255 235"
    ret local pteala200 = "100 255 218"
    ret local pteala400 = "29 233 182"
    ret local pteala700 = "0 191 165"
    ret local pgreen50  = "232 245 233"
    ret local pgreen100 = "200 230 201"
    ret local pgreen200 = "165 214 167"
    ret local pgreen300 = "129 199 132"
    ret local pgreen400 = "102 187 106"
    ret local pgreen500 = "76 175 80"
    ret local pgreen600 = "67 160 71"
    ret local pgreen700 = "56 142 60"
    ret local pgreen800 = "46 125 50"
    ret local pgreen900 = "27 94 32"
    ret local pgreena100  = "185 246 202"
    ret local pgreena200  = "105 240 174"
    ret local pgreena400  = "0 230 118"
    ret local pgreena700  = "0 200 83"
    ret local plgreen50  = "241 248 233"
    ret local plgreen100 = "220 237 200"
    ret local plgreen200 = "197 225 165"
    local xmax = 6
    local targname mcolor
    local title "谷歌配色——色板3"
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
    capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))  ///
      xlab(none) ylab(none) ysca(reverse)     ///
      xtitle("") ytitle("") title("`title'")      ///
      legend(nodraw) aspect(0.6) 
  }
  if "`color'" == "2"{
    clear all
    local lista =  `" "142 36 170" "123 31 162" "106 27 154" "74 20 140" "234 128 252" "224 64 251" "213 0 249" "237 231 246" "209 196 233" "179 157 219" "149 117 205" "126 87 194" "103 58 183" "94 53 177" "81 45 168" "69 39 160" "49 27 146" "179 136 255" "124 77 255" "101 31 255" "98 0 234" "232 234 246" "197 202 233" "159 168 218" "121 134 203" "92 107 192" "63 81 181" "57 73 171" "48 63 159" "40 53 147" "26 35 126" "140 158 255" "83 109 254" "61 90 254" "48 79 254" "227 242 253" "187 222 251" "144 202 249" "100 181 246" "66 165 245" "33 150 243" "30 136 229" "25 118 210" "21 101 192" "13 71 161" "130 177 255" "68 138 255" "41 121 255" "41 98 255" "225 245 254" "179 229 252" "129 212 250" "79 195 247" "41 182 246" "'
    local lista1 ppurple600 ppurple700 ppurple800 ppurple900 ppurplea100 ppurplea200 ppurplea400 pdpurple50 pdpurple100 pdpurple200 pdpurple300 pdpurple400 pdpurple500 pdpurple600 pdpurple700 pdpurple800 pdpurple900 pdpurplea100 pdpurplea200 pdpurplea400 pdpurplea700 pindigo50 pindigo100 pindigo200 pindigo300 pindigo400 pindigo500 pindigo600 pindigo700 pindigo800 pindigo900 pindigoa100 pindigoa200 pindigoa400 pindigoa700 pblue50 pblue100 pblue200 pblue300 pblue400 pblue500 pblue600 pblue700 pblue800 pblue900 pbluea100 pbluea200 pbluea400 pbluea700 plblue50 plblue100 plblue200 plblue300 plblue400
    ret local ppurple600  = "142 36 170"
    ret local ppurple700  = "123 31 162"
    ret local ppurple800  = "106 27 154"
    ret local ppurple900  = "74 20 140"
    ret local ppurplea100 = "234 128 252"
    ret local ppurplea200 = "224 64 251"
    ret local ppurplea400 = "213 0 249"
    ret local pdpurple50  = "237 231 246"
    ret local pdpurple100 = "209 196 233"
    ret local pdpurple200 = "179 157 219"
    ret local pdpurple300 = "149 117 205"
    ret local pdpurple400 = "126 87 194"
    ret local pdpurple500 = "103 58 183"
    ret local pdpurple600 = "94 53 177"
    ret local pdpurple700 = "81 45 168"
    ret local pdpurple800 = "69 39 160"
    ret local pdpurple900 = "49 27 146"
    ret local pdpurplea100  = "179 136 255"
    ret local pdpurplea200  = "124 77 255"
    ret local pdpurplea400  = "101 31 255"
    ret local pdpurplea700  = "98 0 234"
    ret local pindigo50 = "232 234 246"
    ret local pindigo100  = "197 202 233"
    ret local pindigo200  = "159 168 218"
    ret local pindigo300  = "121 134 203"
    ret local pindigo400  = "92 107 192"
    ret local pindigo500  = "63 81 181"
    ret local pindigo600  = "57 73 171"
    ret local pindigo700  = "48 63 159"
    ret local pindigo800  = "40 53 147"
    ret local pindigo900  = "26 35 126"
    ret local pindigoa100 = "140 158 255"
    ret local pindigoa200 = "83 109 254"
    ret local pindigoa400 = "61 90 254"
    ret local pindigoa700 = "48 79 254"
    ret local pblue50 = "227 242 253"
    ret local pblue100  = "187 222 251"
    ret local pblue200  = "144 202 249"
    ret local pblue300  = "100 181 246"
    ret local pblue400  = "66 165 245"
    ret local pblue500  = "33 150 243"
    ret local pblue600  = "30 136 229"
    ret local pblue700  = "25 118 210"
    ret local pblue800  = "21 101 192"
    ret local pblue900  = "13 71 161"
    ret local pbluea100 = "130 177 255"
    ret local pbluea200 = "68 138 255"
    ret local pbluea400 = "41 121 255"
    ret local pbluea700 = "41 98 255"
    ret local plblue50 = "225 245 254"
    ret local plblue100  = "179 229 252"
    ret local plblue200  = "129 212 250"
    ret local plblue300  = "79 195 247"
    ret local plblue400  = "41 182 246"
    local xmax = 6
    local targname mcolor
    local title "谷歌配色——色板2"
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
    capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))  ///
      xlab(none) ylab(none) ysca(reverse)     ///
      xtitle("") ytitle("") title("`title'")      ///
      legend(nodraw) aspect(0.6) 
  }
  if "`color'" == "1"{
    clear all
    local lista =  `" "244 199 195" "230 124 115" "219 68 55" "197 57 41" "198 218 252" "123 170 247" "66 133 244" "51 103 214" "183 225 205" "87 187 138" "15 157 88" "11 128 67" "252 232 178" "247 203 77" "244 180 0" "240 147 0" "245 245 245" "224 224 224" "158 158 158" "97 97 97" "255 235 238" "255 205 210" "239 154 154" "229 115 115" "239 83 80" "244 67 54" "229 57 53" "211 47 47" "198 40 40" "183 28 28" "255 138 128" "255 82 82" "255 23 68" "213 0 0" "252 228 236" "248 187 208" "244 143 177" "240 98 146" "236 64 122" "233 30 99" "216 27 96" "194 24 91" "173 20 87" "136 14 79" "255 128 171" "255 64 129" "245 0 87" "197 17 98" "243 229 245" "225 190 231" "206 147 216" "186 104 200" "171 71 188" "156 39 176" "'
    local lista1 red100 red300 red500 red700 blue100 blue300 blue500 blue700 green100 green300 green500 green700 yellow100 yellow300 yellow500 yellow700 grey100 grey300 grey500 grey700 pred50 pred100 pred200 pred300 pred400 pred500 pred600 pred700 pred800 pred900 preda100 preda200 preda400 preda700 ppink50 ppink100 ppink200 ppink300 ppink400 ppink500 ppink600 ppink700 ppink800 ppink900 ppinka100 ppinka200 ppinka400 ppinka700 ppurple50 ppurple100 ppurple200 ppurple300 ppurple400 ppurple500
      ret local red100  = "244 199 195"
      ret local red300  = "230 124 115"
      ret local red500  = "219 68 55"
      ret local red700  = "197 57 41"
      ret local blue100 = "198 218 252"
      ret local blue300 = "123 170 247"
      ret local blue500 = "66 133 244"
      ret local blue700 = "51 103 214"
      ret local green100  = "183 225 205"
      ret local green300  = "87 187 138"
      ret local green500  = "15 157 88"
      ret local green700  = "11 128 67"
      ret local yellow100 = "252 232 178"
      ret local yellow300 = "247 203 77"
      ret local yellow500 = "244 180 0"
      ret local yellow700 = "240 147 0"
      ret local grey100 = "245 245 245"
      ret local grey300 = "224 224 224"
      ret local grey500 = "158 158 158"
      ret local grey700 = "97 97 97"
      ret local pred50  = "255 235 238"
      ret local pred100 = "255 205 210"
      ret local pred200 = "239 154 154"
      ret local pred300 = "229 115 115"
      ret local pred400 = "239 83 80"
      ret local pred500 = "244 67 54"
      ret local pred600 = "229 57 53"
      ret local pred700 = "211 47 47"
      ret local pred800 = "198 40 40"
      ret local pred900 = "183 28 28"
      ret local preda100  = "255 138 128"
      ret local preda200  = "255 82 82"
      ret local preda400  = "255 23 68"
      ret local preda700  = "213 0 0"
      ret local ppink50 = "252 228 236"
      ret local ppink100  = "248 187 208"
      ret local ppink200  = "244 143 177"
      ret local ppink300  = "240 98 146"
      ret local ppink400  = "236 64 122"
      ret local ppink500  = "233 30 99"
      ret local ppink600  = "216 27 96"
      ret local ppink700  = "194 24 91"
      ret local ppink800  = "173 20 87"
      ret local ppink900  = "136 14 79"
      ret local ppinka100 = "255 128 171"
      ret local ppinka200 = "255 64 129"
      ret local ppinka400 = "245 0 87"
      ret local ppinka700 = "197 17 98"
      ret local ppurple50 = "243 229 245"
      ret local ppurple100  = "225 190 231"
      ret local ppurple200  = "206 147 216"
      ret local ppurple300  = "186 104 200"
      ret local ppurple400  = "171 71 188"
      ret local ppurple500  = "156 39 176"
    local xmax = 6
    local targname mcolor
    local title "谷歌配色——色板1"
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
    capture twoway `cmd', ysca(r(0 `topy')) xsca(r(.8 `topx'))  ///
      xlab(none) ylab(none) ysca(reverse)     ///
      xtitle("") ytitle("") title("`title'")      ///
      legend(nodraw) aspect(0.6)
  }
  di in yellow "注意：使用该色板上的颜色绘图时，需在颜色名称前加上“谷歌”，例如“谷歌pindigo700”"
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

gcm, c(2)
