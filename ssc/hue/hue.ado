* Ado file for program hue. version 1.2

capture program drop hue

program define hue
	version 10.1
	
	tempvar var1 var2 var4
	
	quietly {
	
		describe
		
		if r(N)<70 {
			preserve
			set obs 70
		}
		
		generate `var1' = 1 in 1/8
		replace  `var1' = 2 in 9/13
		replace  `var1' = 3 in 14/22
		replace  `var1' = 4 in 23/30
		replace  `var1' = 5 in 31/40
		replace  `var1' = 6 in 41/49
		replace  `var1' = 0.67 in 50
		replace  `var1' = 1 in 51
		replace  `var1' = 1.33 in 52
		replace  `var1' = 1.67 in 53
		replace  `var1' = 2 in 54
		replace  `var1' = 2.33 in 55
		replace  `var1' = 2.67 in 56
		replace  `var1' = 3 in 57
		replace  `var1' = 3.33 in 58
		replace  `var1' = 3.67 in 59
		replace  `var1' = 4 in 60
		replace  `var1' = 4.33 in 61
		replace  `var1' = 4.67 in 62
		replace  `var1' = 5 in 63
		replace  `var1' = 5.33 in 64
		replace  `var1' = 5.67 in 65
		replace  `var1' = 6 in 66
		replace  `var1' = 6.33 in 67
		replace  `var1' = 6.67 in 68
		replace  `var1' = 3.5 in 69
		replace  `var1' = 2 in 70
		
		generate `var2' = _n in 1/8 if `var1'==1
		replace  `var2' = _n-8 in 9/13 if `var1'==2
		replace  `var2' = _n-13 in 14/22 if `var1'==3
		replace  `var2' = _n-22 in 23/30 if `var1'==4
		replace  `var2' = _n-30 in 31/40 if `var1'==5
		replace  `var2' = _n-40 in 41/49 if `var1'==6
		replace  `var2' = 12 in 50/68
		replace  `var2' = 0 in 69
		replace  `var2' = 10.75 in 70
		
		generate str `var4' = "maroon" in 1
		replace `var4' = "cranberry" in 2
		replace `var4' = "red" in 3
		replace `var4' = "pink" in 4
		replace `var4' = "magenta" in 5
		replace `var4' = "purple" in 6
		replace `var4' = "lavender" in 7
		replace `var4' = "erose" in 8
		replace `var4' = "chocolate" in 9
		replace `var4' = "sienna" in 10
		replace `var4' = "dkorange" in 11
		replace `var4' = "orange" in 12
		replace `var4' = "orange_red" in 13
		replace `var4' = "brown" in 14
		replace `var4' = "khaki" in 15
		replace `var4' = "stone" in 16
		replace `var4' = "ltkhaki" in 17
		replace `var4' = "sand" in 18
		replace `var4' = "sandb" in 19
		replace `var4' = "gold" in 20
		replace `var4' = "yellow" in 21
		replace `var4' = "sunflowerlime" in 22
		replace `var4' = "olive" in 23
		replace `var4' = "forest_green" in 24
		replace `var4' = "dkgreen" in 25
		replace `var4' = "green" in 26
		replace `var4' = "midgreen" in 27
		replace `var4' = "lime" in 28
		replace `var4' = "mint" in 29
		replace `var4' = "cyan" in 30
		replace `var4' = "emerald" in 31
		replace `var4' = "teal" in 32
		replace `var4' = "eltgreen" in 33
		replace `var4' = "olive_teal" in 34
		replace `var4' = "ltblue" in 35
		replace `var4' = "ebg" in 36
		replace `var4' = "bluishgray8" in 37
		replace `var4' = "ltbluishgray8" in 38
		replace `var4' = "bluishgray" in 39
		replace `var4' = "ltbluishgray" in 40
		replace `var4' = "dknavy" in 41
		replace `var4' = "navy8" in 42
		replace `var4' = "navy" in 43
		replace `var4' = "edkblue" in 44
		replace `var4' = "emidblue" in 45
		replace `var4' = "eltblue" in 46
		replace `var4' = "ebblue" in 47
		replace `var4' = "midblue" in 48
		replace `var4' = "blue" in 49
		replace `var4' = "black=gs0" in 50
		replace `var4' = "gs1" in 51
		replace `var4' = "gs2" in 52
		replace `var4' = "gs3" in 53
		replace `var4' = "gs4" in 54
		replace `var4' = "gs5" in 55
		replace `var4' = "gs6" in 56
		replace `var4' = "gs7" in 57
		replace `var4' = "gray=gs8" in 58
		replace `var4' = "gs9" in 59
		replace `var4' = "gs10" in 60
		replace `var4' = "gs11" in 61
		replace `var4' = "gs12" in 62
		replace `var4' = "gs13" in 63
		replace `var4' = "gs14" in 64
		replace `var4' = "dimgray" in 65
		replace `var4' = "gs15" in 66
		replace `var4' = "white=gs16" in 67
		replace `var4' = "eggshell" in 68
		replace `var4' = "Colors" in 69
		replace `var4' = "Tones" in 70

	
		local moptions ms(S) msize(6 6) mlcolor(black) mlabel(`var4') mlabcolor(black) mlabgap(1) mlabsize(2.25)
		local moptions2 ms(S) msize(6 6) mlcolor(black) mlabel(`var4') mlabcolor(black) mlabgap(1) mlabsize(2.25) mlabposition(6)
		local moptions3 ms(S) msize(6 6) mlcolor(black) mlabel(`var4') mlabcolor(black) mlabgap(1) mlabsize(2.25) mlabposition(12)
	
		twoway ///
		  (scatter `var2' `var1' if `var4'=="Colors", msize(0) mlabel(`var4') mlabcolor(black) mlabposition(12) mlabsize(8)) ///
		  (scatter `var2' `var1' if `var4'=="Tones", msize(0) mlabel(`var4') mlabcolor(black) mlabposition(12) mlabsize(8)) ///
	        (scatter `var2' `var1' if `var4'=="maroon", mcolor(maroon) `moptions') ///
	        (scatter `var2' `var1' if `var4'=="cranberry", mcolor(cranberry) `moptions') ///
	        (scatter `var2' `var1' if `var4'=="red", mcolor(red) `moptions') ///
			(scatter `var2' `var1' if `var4'=="pink", mcolor(pink) `moptions') ///
			(scatter `var2' `var1' if `var4'=="magenta", mcolor(magenta) `moptions') ///
			(scatter `var2' `var1' if `var4'=="purple", mcolor(purple) `moptions') ///
			(scatter `var2' `var1' if `var4'=="lavender",  mcolor(lavender) `moptions') ///
			(scatter `var2' `var1' if `var4'=="erose", mcolor(erose) `moptions') ///
			(scatter `var2' `var1' if `var4'=="chocolate", mcolor(chocolate) `moptions') ///
			(scatter `var2' `var1' if `var4'=="sienna", mcolor(sienna) `moptions') ///
			(scatter `var2' `var1' if `var4'=="dkorange",  mcolor(dkorange) `moptions') ///
			(scatter `var2' `var1' if `var4'=="orange", mcolor(orange) `moptions') ///
			(scatter `var2' `var1' if `var4'=="orange_red", mcolor(orange_red) `moptions') ///
			(scatter `var2' `var1' if `var4'=="brown",  mcolor(brown) `moptions') ///
			(scatter `var2' `var1' if `var4'=="khaki",  mcolor(khaki) `moptions') ///
			(scatter `var2' `var1' if `var4'=="stone",  mcolor(stone) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ltkhaki",  mcolor(ltkhaki) `moptions') ///
			(scatter `var2' `var1' if `var4'=="sand",  mcolor(sand) `moptions') ///
			(scatter `var2' `var1' if `var4'=="sandb",  mcolor(sandb) `moptions') ///
			(scatter `var2' `var1' if `var4'=="gold",  mcolor(gold) `moptions') ///
			(scatter `var2' `var1' if `var4'=="yellow",  mcolor(yellow) `moptions') ///
			(scatter `var2' `var1' if `var4'=="sunflowerlime",  mcolor(sunflowerlime) `moptions') ///
			(scatter `var2' `var1' if `var4'=="olive",  mcolor(olive) `moptions') ///
			(scatter `var2' `var1' if `var4'=="forest_green",  mcolor(forest_green) `moptions') ///
			(scatter `var2' `var1' if `var4'=="dkgreen",  mcolor(dkgreen) `moptions') ///
			(scatter `var2' `var1' if `var4'=="green",  mcolor(green) `moptions') ///
			(scatter `var2' `var1' if `var4'=="midgreen",  mcolor(midgreen) `moptions') ///
			(scatter `var2' `var1' if `var4'=="lime",  mcolor(lime) `moptions') ///
			(scatter `var2' `var1' if `var4'=="mint",  mcolor(mint) `moptions') ///
			(scatter `var2' `var1' if `var4'=="cyan",  mcolor(cyan) `moptions') ///
			(scatter `var2' `var1' if `var4'=="emerald",  mcolor(emerald) `moptions') ///
			(scatter `var2' `var1' if `var4'=="teal",  mcolor(teal) `moptions') ///
			(scatter `var2' `var1' if `var4'=="eltgreen",  mcolor(eltgreen) `moptions') ///
			(scatter `var2' `var1' if `var4'=="olive_teal",  mcolor(olive_teal) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ltblue",  mcolor(ltblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ebg",  mcolor(ebg) `moptions') ///
			(scatter `var2' `var1' if `var4'=="bluishgray8",  mcolor(bluishgray8) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ltbluishgray8",  mcolor(ltbluishgray8) `moptions') ///
			(scatter `var2' `var1' if `var4'=="bluishgray",  mcolor(bluishgray) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ltbluishgray",  mcolor(ltbluishgray) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ltbluishgray8",  mcolor(ltbluishgray8) `moptions') ///
			(scatter `var2' `var1' if `var4'=="dknavy",  mcolor(dknavy) `moptions') ///
			(scatter `var2' `var1' if `var4'=="navy8",  mcolor(navy8) `moptions') ///
			(scatter `var2' `var1' if `var4'=="navy",  mcolor(navy) `moptions') ///
			(scatter `var2' `var1' if `var4'=="edkblue",  mcolor(edkblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="emidblue",  mcolor(emidblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="eltblue",  mcolor(eltblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="ebblue",  mcolor(ebblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="midblue",  mcolor(midblue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="blue",  mcolor(blue) `moptions') ///
			(scatter `var2' `var1' if `var4'=="black=gs0",  mcolor(black) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs1",  mcolor(gs1) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs2",  mcolor(gs2) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs3",  mcolor(gs3) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs4",  mcolor(gs4) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs5",  mcolor(gs5) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs6",  mcolor(gs6) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs7",  mcolor(gs7) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gray=gs8",  mcolor(gray) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs9",  mcolor(gs9) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs10",  mcolor(gs10) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs11",  mcolor(gs11) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs12",  mcolor(gs12) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="gs13",  mcolor(gs13) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs14",  mcolor(gs14) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="dimgray",  mcolor(dimgray) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="gs15",  mcolor(gs15) `moptions2') ///
			(scatter `var2' `var1' if `var4'=="white=gs16",  mcolor(white) `moptions3') ///
			(scatter `var2' `var1' if `var4'=="eggshell",  mcolor(eggshell) `moptions2') ///
			,yscale(r(-1 14) reverse noline) xscale(r(.5 7) noline) ylab(none) xlab(none) ytitle("") xtitle("") ///
			legend(nodraw) graphregion(margin(zero) fcolor(white) lcolor(white)) plotregion(lcolor(white)) name(hue, replace)

	}
	
end
