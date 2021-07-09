program define sheafcoef_ex
	Msg preserve
	preserve
	if "`1'" == "1" {
		Xeq sysuse nlsw88, clear
		Xeq gen byte lower = inlist(occupation, 9, 10, 11, 12, 13) if occupation < .
		Xeq gen byte middle = inlist(occupation, 3, 4, 5, 6, 7, 8) if occupation < .
		Xeq glm wage lower middle married never_married union grade , link(log)
		Xeq sheafcoef, latent(class: lower middle; marital: married never_married) post
		Xeq test [main]_b[class] = [main]_b[marital]
	}
	if "`1'" == "2" {
		Xeq sysuse nlsw88, clear
		Xeq gen byte lower = inlist(occupation, 9, 10, 11, 12, 13) if occupation < .
		Xeq gen byte middle = inlist(occupation, 3, 4, 5, 6, 7, 8) if occupation < .
		Xeq logit union middle lower married never_married
		Xeq sheafcoef, latent(class: lower middle; marital: married never_married)
		Xeq sheafcoef, latent(class: lower middle; marital: married never_married) eform
	}
	if "`1'" == "3" {
		Xeq sysuse nlsw88, clear
		Xeq gen byte lower = inlist(occupation, 9, 10, 11, 12, 13) if occupation < .
		Xeq gen byte middle = inlist(occupation, 3, 4, 5, 6, 7, 8) if occupation < .
		Xeq logit union middle lower married never_married
		Xeq sheafcoef, latent(class: -lower middle; marital: married never_married)
	}
	if "`1'" == "4" {
		Xeq sysuse nlsw88, clear
		Xeq gen ln_w = ln(wage)
		Xeq drop if race == 3
		Xeq gen byte black = race == 2
		Xeq gen byte white = race == 1
		Xeq gen blackXmarried = black*married
		Xeq gen blackXnever_married = black*never_married
		Xeq gen whiteXmarried = white*married
		Xeq gen whiteXnever_married = white*never_married
		Xeq reg ln_w black* white*, nocons
	}
	if "`1'" == "5" {
		qui sysuse nlsw88, clear
		gen ln_w = ln(wage)
		qui drop if race == 3
		gen byte black = race == 2
		gen byte white = race == 1
		gen blackXmarried = black*married
		gen blackXnever_married = black*never_married
		gen whiteXmarried = white*married
		gen whiteXnever_married = white*never_married
		qui reg ln_w black* white*, nocons
		Xeq sheafcoef, latent(black_marst: blackXmarried blackXnever_married if black ; ///
                  white_marst: whiteXmarried whiteXnever_married if white )
	}
	Msg restore 
	restore
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
