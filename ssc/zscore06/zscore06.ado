* Written by Jef L Leroy (j.leroy@cgiar.org)
* v1.1 July 2011
	** changes: 
	** + corrected height correction for recumbent length ("if (`measure'==`recum' & `agetemp'==731)" changed to
	**		"if (`measure'==`recum' & `agetemp'>=731)"
	** + changed creation of temporary sex variables as this could result in problems if e.g. male=0 and female=1 in
	** 		original data
	** + typos and comments 
* v1.0 April 2011 *


program define zscore06
	version 9.0

* read reference tables 
	preserve
	quietly findfile zscore06.ado, path(UPDATES;BASE;SITE;.;PERSONAL;PLUS)
	local pathref=substr(r(fn),1,length(r(fn))-12)

* define temporary names for matrices
	set type double 
	tempname zlen zwei zbmi zwflb zwflg zwfhb zwfhg


*define reference matrices 
	use "`pathref'zscore06.dta", clear 		/* this data set has all who z reference tables */
	mata: `zlen' = st_data((1,3714),("sexlenweibmi","_agedays","llen","mlen","slen"))
	mata: `zwei' = st_data((1,3714),("sexlenweibmi","_agedays","lwei","mwei","swei"))
	mata: `zbmi' = st_data((1,3714),("sexlenweibmi","_agedays","lbmi","mbmi","sbmi"))
	mata: `zwflb' = st_data((1,651),("sexwfl","length","lwfl","mwfl","swfl"))
	mata: `zwflg' = st_data((652,1302),("sexwfl","length","lwfl","mwfl","swfl"))
	mata: `zwfhb' = st_data((1,551),("sexwfh","length","lwfh","mwfh","swfh"))
	mata: `zwfhg' = st_data((552,1102),("sexwfh","length","lwfh","mwfh","swfh"))	
	restore

* read input from user 
	syntax [if] [in], s(varname) a(varname) [h(varname) w(varname) female(integer 2) male(integer 2) measure(varname) recum(integer 2) stand(integer 2) o(varname) oyes(integer 2) ono(integer 2)] 

* check minimal input from user; return error code 
	if "`a'"=="" {
		display as err "a() must be defined"
		exit
	}
	if "`h'"==""&"`w'"=="" {
		display as err "at least one of h() or w() must be defined"
		exit
	}

* check whether not more than two sexes 
	quietly tab `s' `if' `in'
	local no_sexes=`r(r)'
	if `no_sexes'>2 {
		display as err "`s' not a valid sex variable (contains more than 2 different values)"
		exit
	}

* check if female() & male() NOT defined, whether only 2's and 1's 	
	quietly sum `s' `if' `in'
	if index("`0'"," female")==0 & index("`0'"," male")==0 {  /* macro `0' stores full user input; if statement indicates that male/female not defined */
		if `no_sexes'==2 {
			if r(min)~=1 {
				display as err "female() and/or male() must be defined if sex variable contains values other than 1 and 2"
				exit
			}
			if r(max)~=2 {
				display as err "female() and/or male() must be defined if sex variable contains values other than 1 and 2"
				exit
			}
		}
		else  /* in this case no_sexes=1 & r(min)=r(max)*/ {
			if r(min)~=1 & r(min)~=2 {
				display as err "female() and/or male() must be defined if sex variable contains values other than 1 and 2"
				exit
			}
		}
	}

* check IF male() defined, whether male(value) appears 
* check IF male() defined & female() NOT defined, whether other value is 2 OR not existing 
	if index("`0'"," male")>0 {
		if r(min)~=`male' & r(max)~=`male' {
			display as err "value defined in male() does not appear in variable `s'"
			exit
		}
		if index("`0'"," female")==0 {
			if `no_sexes'==2 {
				if r(min)==`male' & r(max)~=2 | r(max)==`male' & r(min)~=2 {
					display as err "female() must be defined if value for females is different from 2"
					exit
				}
			}
		}
	}
			
* check IF female() defined, whether female(value) appears 
* check IF female() defined & male() NOT defined, whether other value is 1 OR not existing 
	if index("`0'"," female")>0 {
		if r(min)~=`female' & r(max)~=`female' {
			display as err "value defined in female() does not appear in variable `s'"
			exit
		}
		if index("`0'"," male")==0 {
			if `no_sexes'==2 {
				if r(min)==`female' & r(max)~=1 | r(max)==`female' & r(min)~=1 {
					display as err "male() must be defined if value for males is different from 2"
					exit
				}
			}
		}
	}

* set values for males and females if not defined
	if index("`0'"," male")==0 & index("`0'"," female")==0 {		/* male() & female () not defined */
		local female=2
		local male=1
	}
	else {										
		if index("`0'"," female")>0 &index("`0'"," male")==0	{	/* only female() defined */
			local male=1
		}
		if index("`0'"," male")>0 &index("`0'"," female")==0	{	/* only male() defined */
			local female=2
		}
	}		


* check measure variable
	if "`measure'"=="" {
		* check whether recum and stand not defined 
		if index("`0'"," recum")~=0 | index("`0'"," stand")~=0 {  /* macro `0' stores full user input */
			display as err "recum() and/or stand() can only be defined if measure variable defined in measure()"
			exit
		}
	}
	else {
		* check whether not more than two types of measure 
		quietly tab `measure' `if' `in'
		local no_measure=`r(r)'
		if `no_measure'>2 {
			display as err "`measure' not a valid measure variable (contains more than 2 different values)"
			exit
		}

		* check if recum() & stand() NOT defined, whether only 2's and 1's 	
		quietly sum `measure' `if' `in'
		if index("`0'"," recum")==0 & index("`0'"," stand")==0 {  /* macro `0' stores full user input */
			if `no_measure'==2 {
				if r(min)~=1 {
					display as err "recum() and/or stand() must be defined if measure variable contains values other than 1 and 2"
					exit
					}
				if r(max)~=2 {
					display as err "recum() and/or stand() must be defined if measure variable contains values other than 1 and 2"
					exit
					}
			}
			else  /* in this case no_measure=1 & r(min)=r(max)*/ {
				if r(min)~=1 & r(min)~=2 {
					display as err "recum() and/or stand() must be defined if measure variable contains values other than 1 and 2"
					exit
				}
			}
		}

		* check IF recum() defined, whether recum(value) exists 
		* check IF recum() defined & stand() NOT defined, whether other value is 2 OR not existing 
		if index("`0'"," recum")>0 {
			if r(min)~=`recum' & r(max)~=`recum' {
				display as err "value defined in recum() does not appear in variable `measure'"
				exit
			}
			if index("`0'"," stand")==0 {
				if `no_measure'==2 {
					if r(min)==`recum' & r(max)~=2 | r(max)==`recum' & r(min)~=2 {
						display as err "stand() must be defined if value for standing is different from 2"
						exit
					}
				}
			}
		}
					
		* check IF stand() defined, whether female(value) appears 
		* check IF stand() defined & recum() NOT defined, whether other value is 1 OR not existing 
		if index("`0'"," stand")>0 {
			if r(min)~=`stand' & r(max)~=`stand' {
				display as err "value defined in stand() does not appear in variable `s'"
				exit
			}
			if index("`0'"," recum")==0 {
				if `no_measures'==2 {
					if r(min)==`stand' & r(max)~=1 | r(max)==`stand' & r(min)~=1 {
						display as err "recum() must be defined if value for recumbent is different from 2"
						exit
					}
				}
			}
		}
		* set values for recumbent and standing if not defined 
		if index("`0'"," recum")==0 & index("`0'"," stand")==0 {		/* recum() & stand() not defined */
			local recum=1
			local stand=2
		}
		else {										
			if index("`0'"," recum")>0 &index("`0'"," stand")==0	{	/* only recum() defined */
				local stand=2
			}
			if index("`0'"," stand")>0 &index("`0'"," recum")==0	{	/* only stand() defined */
				local recum=1
			}
		}		
	}

* check oedema variable
	if "`o'"=="" {
		* check whether recum and stand not defined 
		if index("`0'"," ono")~=0 | index("`0'"," oyes")~=0 {  /* macro `0' stores full user input */
			display as err "ono() and/or oyes() can only be defined if oedema variable defined in o()"
			exit
		}
	}
	else {
		* check whether not more than two values for oedema 
		quietly tab `o' `if' `in'
		local no_oedema=`r(r)'
		if `no_oedema'>2 {
			display as err "`o' not a valid oedema variable (contains more than 2 different values)"
			exit
		}

		* check if oyes() & ono() NOT defined, whether only 2's and 1's 	
		quietly sum `o' `if' `in'
		if index("`0'"," oyes")==0 & index("`0'"," ono")==0 {  /* macro `0' stores full user input */
			if `no_oedema'==2 {
				if r(min)~=1 {
					display as err "oyes() and/or ono() must be defined if oedema variable contains values other than 1 and 2"
					exit
					}
				if r(max)~=2 {
					display as err "oyes() and/or ono() must be defined if oedema variable contains values other than 1 and 2"
					exit
					}
			}
			else  /* in this case no_oedema=1 & r(min)=r(max)*/ {
				if r(min)~=1 & r(min)~=2 {
					display as err "oyes() and/or ono() must be defined if oedema variable contains values other than 1 and 2"
					exit
				}
			}
		}

		* check IF oyes() defined, whether oyes(value) exists 
		* check IF oyes() defined & ono() NOT defined, whether other value is 2 OR not existing 
		if index("`0'"," oyes")>0 {
			if r(min)~=`oyes' & r(max)~=`oyes' {
				display as err "value defined in oyes() does not appear in variable `o'"
				exit
			}
			if index("`0'"," ono")==0 {
				if `no_oedema'==2 {
					if r(min)==`oyes' & r(max)~=2 | r(max)==`oyes' & r(min)~=2 {
						display as err "ono() must be defined if value for ono is different from 2"
						exit
					}
				}
			}
		}
					
		* check IF ono() defined, whether female(value) appears 
		* check IF ono() defined & oyes() NOT defined, whether other value is 1 OR not existing 
		if index("`0'"," ono")>0 {
			if r(min)~=`ono' & r(max)~=`ono' {
				display as err "value defined in ono() does not appear in variable `s'"
				exit
			}
			if index("`0'"," oyes")==0 {
				if `no_oedemas'==2 {
					if r(min)==`ono' & r(max)~=1 | r(max)==`ono' & r(min)~=1 {
						display as err "oyes() must be defined if value for oyes is different from 1"
						exit
					}
				}
			}
		}
		* set values for oyes and ono if not defined 
		if index("`0'"," oyes")==0 & index("`0'"," ono")==0 {		/* oyes() & ono() not defined */
			local oyes=1
			local ono=2
		}
		else {										
			if index("`0'"," oyes")>0 &index("`0'"," ono")==0 {	/* only oyes() defined */
				local ono=2
			}
			if index("`0'"," ono")>0 &index("`0'"," oyes")==0{	/* only ono() defined */
				local oyes=1
			}
		}		
	}


* create temporary sex & age variables (are deleted automatically if program is stopped) 
* check for missing values in data and replace them with 9999 
	tempvar sextemp	
	quietly recode `s' (`male'=1) (`female'=2) (.=9999), gen(`sextemp')
	tempvar agetemp
	quietly gen `agetemp'=round(`a'*30.4375,1)
	quietly replace `agetemp'=9999 if `agetemp'==.


* check which z-scores can be calculated; check whether z-score variables do not exist already 
* store in xx_ok macro's; create temporary height/weight variables 
* check for missing values in data and replace them with 9999 
	local ha_ok=0
	local wh_ok=0
	local wa_ok=0

	if "`h'"~="" {
		capture confirm new variable haz06
		if _rc==110 {
			display as err "Variable haz06 already exists in data set. Rename or drop before running zscore06."
			exit
		}
		local ha_ok=1
		tempvar haz06
		quietly gen `haz06'=.
		tempvar heighttemp
		quietly gen `heighttemp'=round(`h',.01)			/* rounded to precision of .01 to allow for hi/lo values (see below) */
		quietly replace `heighttemp'=9999 if `heighttemp'==.
		if "`measure'"~="" { /* adjust height/length for recumbent/standing */
			quietly replace `heighttemp'= `heighttemp'+.7 if (`measure'==`stand' & `agetemp'<731) 
			quietly replace `heighttemp'= `heighttemp'-.7 if (`measure'==`recum' & `agetemp'>=731)
		}
	}
	if "`w'"~="" {
		capture confirm new variable waz06
		if _rc==110 {
			display as err "Variable waz06 already exists in data set. Rename or drop before running zscore06."
			exit
		}
		capture confirm new variable bmiz06
		if _rc==110 {
			display as err "Variable bmiz06 already exists in data set. Rename or drop before running zscore06."
			exit
		}
		
		local wa_ok=1
		tempvar waz
		quietly gen `waz'=.
		tempvar waz06 bmiz06
		quietly gen `waz06'=.
		quietly gen `bmiz06'=.
		tempvar weighttemp
		quietly gen `weighttemp'=`w'
		quietly replace `weighttemp'=9999 if `weighttemp'==.
		if `ha_ok'==1 {
			capture confirm new variable whz06
			if _rc==110 {
				display as err "Variable whz06 already exists in data set. Rename or drop whz before running zscore06."
				exit
			}
			local wh_ok=1
			tempvar whz06
			quietly gen `whz06'=.
			* calculate height/length high and low for wfh/wfl calculations; 
			* necessary in case more than one decimal in ht/lt measurement 
			tempvar heighttemphi heighttemplo
			quietly gen `heighttemphi'=.
			quietly gen `heighttemplo'=.
			quietly replace `heighttemphi'=ceil(int(round((`heighttemp'*100),1))/10)/10
			quietly replace `heighttemplo'=floor(int(round((`heighttemp'*100),1))/10)/10
			* if hi and lo are the same, there is no need to go through interpolation process 
			quietly count if `heighttemplo'~=`heighttemphi'
			if r(N)==0 {
				local hilosame=1
			}
			else {
				local hilosame=0
			}
		}
	}

* determine the number of records in dataset 
	quietly count 
	local size=r(N)

* create flag for observations defined in `if' `in' 
	tempvar flag
	quietly gen `flag'=1 `if' `in'

* define temporary names for scalars 
tempname m l s mhi lhi shi mlo llo slo sd3p sd23p sd3n sd23n height weight heightlo heighthi

* calculation of z-scores 
local i = 1
while `i'<=`size' {		/* loop through data */

	* check whether observation included in `if' `in' 
	if `flag'~=1 {
		local i=`i'+1
		continue
	}

	* read sex and age values 
	local sex=`sextemp' in `i'
	local age=`agetemp' in `i'	
	
	* if sex or age are missing: z-scores cannot  be calculated 
	if `sex'==9999|`age'==9999  {
		local i=`i'+1
		continue
	}

	* read height and weight values 
	if `ha_ok'==1 { 
		if `wa_ok'==1 {
			scalar `height'=`heighttemp' in `i'
			scalar `weight'=`weighttemp' in `i'
		}
		else {
			scalar `height'=`heighttemp' in `i'
		}
	}
	else {	
		scalar `weight'=`weighttemp' in `i'
	}

	*** haz 06 ***
		if `ha_ok'==1 {
			if scalar(`height')~=9999 {
				if `age'>=0 & `age'<=1856 & scalar(`height')>0 {			/* limit reference values */
					local row=`age'
					if `sex'==2 {
						local row=`age'+1857
					}
					mata: st_numscalar("`l'", `zlen'[`row'+1,3])		
					mata: st_numscalar("`m'", `zlen'[`row'+1,4])
					mata: st_numscalar("`s'", `zlen'[`row'+1,5])
					quietly replace `haz06'=round((((scalar(`height')/scalar(`m'))^scalar(`l'))-1)/(scalar(`s')*scalar(`l')),0.01) in `i'
						/*note that scalar pseudofunction is used to avoid to confusion with var names (SJ 2006,6(2) 279-80) */
				}
				else {
					quietly replace `haz06'=99 in `i'
				}
			}	
		}

	*** waz 06 ***
		if `wa_ok'==1 {
			if scalar(`weight')~=9999 {
				if `age'>=0 & `age'<=1856 & scalar(`weight')>0 {			/* limit reference values */
					local row=`age'
					if `sex'==2 {
						local row=`age'+1857
					}
					mata: st_numscalar("`l'", `zwei'[`row'+1,3])
					mata: st_numscalar("`m'", `zwei'[`row'+1,4])
					mata: st_numscalar("`s'", `zwei'[`row'+1,5])
					quietly replace `waz06'=round((((scalar(`weight')/scalar(`m'))^scalar(`l'))-1)/(scalar(`s')*scalar(`l')),.01) in `i'	
					if (`waz06'>3 & `waz06'~=.) in `i' {
						scalar `sd3p'=scalar(`m')*((1+scalar(`l')*scalar(`s')*3)^(1/scalar(`l')))
						scalar `sd23p'=scalar(`sd3p')- scalar(`m')*((1+scalar(`l')*scalar(`s')*2)^(1/scalar(`l')))
						quietly replace `waz06'=round(3+((scalar(`weight')-scalar(`sd3p'))/scalar(`sd23p')),0.01) in `i'
					}
					if (`waz06'<-3 & `waz06'~=.) in `i' {
						scalar `sd3n'=scalar(`m')*((1+scalar(`l')*scalar(`s')*(-3))^(1/scalar(`l')))
						scalar `sd23n'= scalar(`m')*((1+scalar(`l')*scalar(`s')*(-2))^(1/scalar(`l')))-scalar(`sd3n')
						quietly replace `waz06'=round((-3)-((scalar(`sd3n')-scalar(`weight'))/scalar(`sd23n')),0.01) in `i'
					}
				}
				else {
					quietly replace `waz06'=99 in `i'
				}
			}	
		}

	*** bmiz06 ***
		if `wa_ok'==1 & `ha_ok' {
			if scalar(`weight')~=9999 & scalar(`height')~=9999 {
				if `age'>=0 & `age'<=1856 & scalar(`weight')>0 & scalar(`height')>0{			/* limit reference values */
					local row=`age'
					if `sex'==2 {
						local row=`age'+1857
					}
					mata: st_numscalar("`l'", `zbmi'[`row'+1,3])
					mata: st_numscalar("`m'", `zbmi'[`row'+1,4])
					mata: st_numscalar("`s'", `zbmi'[`row'+1,5])
					quietly replace `bmiz06'=round((((scalar(`weight')*10000/(scalar(`height')*scalar(`height'))/scalar(`m'))^scalar(`l'))-1)/(scalar(`s')*scalar(`l')),0.01) in `i'
					if (`bmiz06'>3 & `bmiz06'~=.) in `i' {
						scalar `sd3p'=scalar(`m')*((1+scalar(`l')*scalar(`s')*3)^(1/scalar(`l')))
						scalar `sd23p'=scalar(`sd3p')- scalar(`m')*((1+scalar(`l')*scalar(`s')*2)^(1/scalar(`l')))
						quietly replace `bmiz06'=round(3+((scalar(`weight')*10000/(scalar(`height')*scalar(`height'))-scalar(`sd3p'))/scalar(`sd23p')),0.01) in `i'
					}
					if (`bmiz06'<-3 & `bmiz06'~=.) in `i' {
						scalar `sd3n'=scalar(`m')*((1+scalar(`l')*scalar(`s')*(-3))^(1/scalar(`l')))
						scalar `sd23n'= scalar(`m')*((1+scalar(`l')*scalar(`s')*(-2))^(1/scalar(`l')))-scalar(`sd3n')
						quietly replace `bmiz06'=round((-3)-((scalar(`sd3n')-scalar(`weight')*10000/(scalar(`height')*scalar(`height')))/scalar(`sd23n')),0.01) in `i'
					}
				}
				else {
					quietly replace `waz06'=99 in `i'
				}
			}	
		}

	*** whz06 ***
		if `wh_ok'==1 {
			if scalar(`weight')~=9999 & scalar(`height')~=9999 {
				if `age'>=0 & `age'<=1856 & scalar(`weight')>0 & scalar(`height')>0{			/* limit reference values */
					if `hilosame'==1 {							/* no interpolation necessary */
						if `age'<731 {							/* use wfl table */
							if scalar(`height')>=45 & scalar(`height')<=110 {			/* range in length table */
								/* define correct row in table */
								local row=int(round((round(scalar(`height'),.1)-44.9)*10),1)
								if `sex'==1 {
									mata: st_numscalar("`l'", `zwflb'[`row',3])
									mata: st_numscalar("`m'", `zwflb'[`row',4])
									mata: st_numscalar("`s'", `zwflb'[`row',5])
								}
								if `sex'==2 {
									mata: st_numscalar("`l'", `zwflg'[`row',3])
									mata: st_numscalar("`m'", `zwflg'[`row',4])
									mata: st_numscalar("`s'", `zwflg'[`row',5])
								}
							}
						}
						else {									/* use wfh table */
							if scalar(`height')>=65 & scalar(`height')<=120 {				/* range in height table */
								* define correct row in table */
								local row=int(round((round(scalar(`height'),.1)-64.9)*10),1)	
								if `sex'==1 {
									mata: st_numscalar("`l'", `zwfhb'[`row',3])
									mata: st_numscalar("`m'", `zwfhb'[`row',4])
									mata: st_numscalar("`s'", `zwfhb'[`row',5])
								}
								if `sex'==2 {
									mata: st_numscalar("`l'", `zwfhg'[`row',3])
									mata: st_numscalar("`m'", `zwfhg'[`row',4])
									mata: st_numscalar("`s'", `zwfhg'[`row',5])
								}
							}
						}
						if (`age'<731 & scalar(`height')>=45 & scalar(`height')<=110) | (`age'>=731 & scalar(`height')>=65 & scalar(`height')<=120) {
							quietly replace `whz06'=round((((scalar(`weight')/scalar(`m'))^scalar(`l'))-1)/(scalar(`s')*scalar(`l')),.01) in `i'
							if `whz06'>3 & `whz06'~=. in `i' {
								scalar `sd3p' =scalar(`m')*((1+scalar(`l')*scalar(`s')*3)^(1/scalar(`l')))
								scalar `sd23p' =scalar(`sd3p')- scalar(`m')*((1+scalar(`l')*scalar(`s')*2)^(1/scalar(`l'))) 
								quietly replace `whz06'= round(3+((scalar(`weight')-scalar(`sd3p'))/scalar(`sd23p')),.01) in `i'
							}
							if `whz06'<-3 & `whz06'~=. in `i' {
								scalar `sd3n'=scalar(`m')*((1+scalar(`l')*scalar(`s')*(-3))^(1/scalar(`l')))
								scalar `sd23n'= scalar(`m')*((1+scalar(`l')*scalar(`s')*(-2))^(1/scalar(`l')))-scalar(`sd3n')
								quietly replace `whz06'=round((-3)-((scalar(`sd3n')-scalar(`weight'))/scalar(`sd23n')),.01) in `i'
							}
						}
						else {
							quietly replace `whz06'=99 in `i'			/* outside of reference values */
						}			
					}
					else {
						local heightlo=`heighttemplo' in `i'
						local heighthi=`heighttemphi' in `i'
						if `age'<731 {							/* use wfl table */
							if scalar(`height')>=45 & scalar(`height')<=110 {			/* range in length table */
								* define correct row in table */
								local rowlo=int(round((round(`heightlo',.1)-44.9)*10),1)
								local rowhi=int(round((round(`heighthi',.1)-44.9)*10),1)
								if `sex'==1 {
									mata: st_numscalar("`llo'", `zwflb'[`rowlo',3])
									mata: st_numscalar("`mlo'", `zwflb'[`rowlo',4])
									mata: st_numscalar("`slo'", `zwflb'[`rowlo',5])
									mata: st_numscalar("`lhi'", `zwflb'[`rowhi',3])
									mata: st_numscalar("`mhi'", `zwflb'[`rowhi',4])
									mata: st_numscalar("`shi'", `zwflb'[`rowhi',5])
								}
								if `sex'==2 {
									mata: st_numscalar("`llo'", `zwflg'[`rowlo',3])
									mata: st_numscalar("`mlo'", `zwflg'[`rowlo',4])
									mata: st_numscalar("`slo'", `zwflg'[`rowlo',5])
									mata: st_numscalar("`lhi'", `zwflg'[`rowhi',3])
									mata: st_numscalar("`mhi'", `zwflg'[`rowhi',4])
									mata: st_numscalar("`shi'", `zwflg'[`rowhi',5])
								}
							}
						}
						else {									/* use wfh table */
							if scalar(`height')>=65 & scalar(`height')<=120 {				/* range in height table */
								* define correct row in table 
								local rowlo=int(round((round(`heightlo',.1)-64.9)*10),1)	
								local rowhi=int(round((round(`heighthi',.1)-64.9)*10),1)	
								if `sex'==1 {
									mata: st_numscalar("`llo'", `zwfhb'[`rowlo',3])
									mata: st_numscalar("`mlo'", `zwfhb'[`rowlo',4])
									mata: st_numscalar("`slo'", `zwfhb'[`rowlo',5])
									mata: st_numscalar("`lhi'", `zwfhb'[`rowhi',3])
									mata: st_numscalar("`mhi'", `zwfhb'[`rowhi',4])
									mata: st_numscalar("`shi'", `zwfhb'[`rowhi',5])
								}
								if `sex'==2 {
									mata: st_numscalar("`llo'", `zwfhg'[`rowlo',3])
									mata: st_numscalar("`mlo'", `zwfhg'[`rowlo',4])
									mata: st_numscalar("`slo'", `zwfhg'[`rowlo',5])
									mata: st_numscalar("`lhi'", `zwfhg'[`rowhi',3])
									mata: st_numscalar("`mhi'", `zwfhg'[`rowhi',4])
									mata: st_numscalar("`shi'", `zwfhg'[`rowhi',5])
								}
							}
						}		
						if (`age'<731 & scalar(`height')>=45 & scalar(`height')<=110) | (`age'>=731 & scalar(`height')>=65 & scalar(`height')<=120) {
							scalar whz06lo=(((scalar(`weight')/scalar(`mlo'))^scalar(`llo'))-1)/(scalar(`slo')*scalar(`llo'))
							if scalar(whz06lo)>3  {
								scalar `sd3p' =scalar(`mlo')*((1+scalar(`llo')*scalar(`slo')*3)^(1/scalar(`llo')))
								scalar `sd23p' =scalar(`sd3p')- scalar(`mlo')*((1+scalar(`llo')*scalar(`slo')*2)^(1/scalar(`llo'))) 
								scalar whz06lo= 3+((scalar(`weight')-scalar(`sd3p'))/scalar(`sd23p'))
							}
							if scalar(whz06lo)<-3 {
								scalar `sd3n'=scalar(`mlo')*((1+scalar(`llo')*scalar(`slo')*(-3))^(1/scalar(`llo')))
								scalar `sd23n'= scalar(`mlo')*((1+scalar(`llo')*scalar(`slo')*(-2))^(1/scalar(`llo')))-scalar(`sd3n')
								scalar whz06lo=(-3)-((scalar(`sd3n')-scalar(`weight'))/scalar(`sd23n'))
							}
							scalar whz06hi=(((scalar(`weight')/scalar(`mhi'))^scalar(`lhi'))-1)/(scalar(`shi')*scalar(`lhi'))
							if scalar(whz06hi)>3 {
								scalar `sd3p' =scalar(`mhi')*((1+scalar(`lhi')*scalar(`shi')*3)^(1/scalar(`lhi')))
								scalar `sd23p' =scalar(`sd3p')- scalar(`mhi')*((1+scalar(`lhi')*scalar(`shi')*2)^(1/scalar(`lhi'))) 
								scalar whz06hi= 3+((scalar(`weight')-scalar(`sd3p'))/scalar(`sd23p'))
							}
							if scalar(whz06hi)<-3 {
								scalar `sd3n'=scalar(`mhi')*((1+scalar(`lhi')*scalar(`shi')*(-3))^(1/scalar(`lhi')))
								scalar `sd23n'= scalar(`mhi')*((1+scalar(`lhi')*scalar(`shi')*(-2))^(1/scalar(`lhi')))-scalar(`sd3n')
								scalar whz06hi=(-3)-((scalar(`sd3n')-scalar(`weight'))/scalar(`sd23n'))
							}
							scalar ratio=(scalar(`height')-`heightlo')/.1
							quietly replace `whz06'=round(scalar(whz06lo)-((scalar(whz06lo)-scalar(whz06hi))*scalar(ratio)),0.01) in `i'

						}
						else {
							quietly replace `whz06'=99 in `i'			/* outside of reference values */
						}			
					}
				}
				else {
					quietly replace `whz06'=99 in `i'
				}
			}	
		}
		local i=`i'+1
}

* replace oedema cases with . *
if "`o'"~="" {
	quietly replace `waz06'=. if `o'==`oyes'
	quietly replace `whz06'=. if `o'==`oyes'
	quietly replace `bmiz06'=. if `o'==`oyes'
}

display ""
if `ha_ok'==1 {
	quietly gen haz06=`haz06'
	label var haz06 "Length/height-for-age Z-score"
}
if `wa_ok'==1 {
	quietly gen waz06=`waz06'
	label var waz06 "Weight-for-age Z-score"
}
if `wh_ok'==1 {
	quietly gen whz06=`whz06'
	label var whz06 "Weight-for-length/height Z-score"
	quietly gen bmiz06=`bmiz06'
	label var bmiz06 "BMI-for-age Z-score"
}

if `ha_ok'==1 & `wa_ok'~=1 {
	local returntext="(haz06)"
}
if `ha_ok'~=1 & `wa_ok'==1 {
	local returntext="(waz06)"
}
if `ha_ok'==1 & `wa_ok'==1  {
	local returntext="(haz06, waz06, bmiz06 and whz06)"
}
display as res "Z-scores `returntext' succesfully calculated" 
display as res "*** note 1: 99 indicates that height, weight or age were out of the reference value range"
display as res "*** note 2: no zscores are calculated for children with missing age"
end

