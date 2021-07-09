cap prog drop rgb2hex
prog def rgb2hex, rclass
	version 14.0
	syntax anything [, Play]
	tokenize `anything'
	forval m = 1/3{
		if ``m'' > 255 | ``m'' < 0 di as error "RGB参数应在0～255之间！"
	}
	forval m = 1/3{
		local mod`m' = mod(``m'', 16)
		local div`m' = (``m'' - `mod`m'') / 16
	}
	foreach n in "mod1" "mod2" "mod3" "div1" "div2" "div3"{
		if ``n'' > 9{
			cap if ``n'' == 10 local `n' = "A"
			cap if ``n'' == 11 local `n' = "B"
			cap if ``n'' == 12 local `n' = "C"
			cap if ``n'' == 13 local `n' = "D"
			cap if ``n'' == 14 local `n' = "E"
			cap if ``n'' == 15 local `n' = "F"
		}
	}
	di in green "#`div1'`mod1'`div2'`mod2'`div3'`mod3'"
	ret local hex "#`div1'`mod1'`div2'`mod2'`div3'`mod3'"
	forval m = 1/3{
		local k`m' = 255 - ``m''
	}
	if "`play'" != "" tw scatteri 0 0 , ysc(off) xsc(off) ms(i) plotr(fc(rgb(`anything'))) text(0 0 "RGB(`anything')" "#`div1'`mod1'`div2'`mod2'`div3'`mod3'", size(*4) color(rgb(`k1' `k2' `k3')))
end
