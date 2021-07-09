capture program drop eperiod
program define eperiod 
*! 1.0.0 May 2009
version 10.0

syntax varlist(min=1 max=2) [in] [if] ,[ Year Month Day Today(string) Generate(string) ]
tokenize `varlist'
local fdate `1'
local idate `2'
quietly {
	if "`year'`month'`day'`today'" == "" {
	di as err "Select a valid count option"
	exit 198
	}
	else if "`year'`month'`day'" != "" & "`idate'" == "" {
	di as err "No final date specified"
	exit 198	
	}
	if "`fdate'" >= "`idate'" & "`idate'" != "" {
	di as err "The final date must be higher than initial date"
	exit 198
	}
	if "`idate'" != "" & "`today'" != "" {
	di as err "Option today must be specified with only an initial date"
	exit 198
	}
	
	tempvar ano0 mes0 dia0 ano1 mes1 dia1 hoy ano_hoy mes_hoy dia_hoy	
	if "`idate'" != "" & "`year'`month'`day'" != "" {
		gen `ano0' = year(`idate')	
		gen `mes0' = month(`idate')	
		gen `dia0' = day(`idate')
	}	
		
		gen `ano1' = year(`fdate')	
		gen `mes1' = month(`fdate')	
		gen `dia1' = day(`fdate')	
		gen `hoy' = date(c(current_date), "DMY")
		gen `ano_hoy' = year(`hoy')
		gen `mes_hoy' = month(`hoy')
		gen `dia_hoy' = day(`hoy')
	
	local freq `today'
	local newvar `generate'
				
	if "`year'`month'`day'" != "" & "`idate'" != "" {
	global year  (((`ano1'-`ano0'))+((`mes1'-`mes0')/12)+((`dia1'-`dia0')/365.25))
	global month  (((`ano1'-`ano0')*12)+(`mes1'-`mes0')+((`dia1'-`dia0')/30.4375))
	global day  (((`ano1'-`ano0')*365.25)+((`mes1'-`mes0')*30.4375)+(`dia1'-`dia0'))
	}
	if "`freq'" != "" {
	global todayy ((`ano_hoy'-`ano1')+((`mes_hoy'-`mes1')/12)+((`dia_hoy'-`dia1')/365.25))	
	global todaym (((`ano_hoy'-`ano1')*12)+(`mes_hoy'-`mes1')+((`dia_hoy'-`dia1')/30.4375))	
	global todayd (((`ano_hoy'-`ano1')*365.25)+((`mes_hoy'-`mes1')*30.4375)+(`dia_hoy'-`dia1'))	
	}
	
	if "`year'" !="" {
		if "`newvar'" !="" {
		gen `newvar' = $year
		label var `newvar' "Elapsed years between `idate' and `fdate'"
		}
		else {
		gen per_years = $year
		label var per_years "Elapsed years between `idate' and `fdate'"
		}
	}

	if "`month'" !="" {
		if "`newvar'" !="" {
		gen `newvar' = $month
		label var `newvar' "Elapsed months between `idate' and `fdate'"
		}
		else {
		gen per_months = $month
		label var per_months "Elapsed months between `idate' and `fdate'"
		}
	}
	
	if "`day'" != "" {
		if "`newvar'" !="" {
		gen `newvar' = $day
		label var `newvar' "Elapsed days between `idate' and `fdate'"
		}
		else {
		gen per_days = $day
		label var per_days "Elapsed days between `idate' and `fdate'"
		}
	}
	

	if "`freq'" != "" {
		if "`freq'" == "y" {
			if "`newvar'" !="" {
			gen `newvar' = $todayy
			label var `newvar' "Elapsed years between `fdate' and current date"
			}
			else {
			gen per_years_today = $todayy
			label var per_years_today "Elapsed years between `fdate' and current date"
			}
		}
		else if "`freq'" == "m" {
			if "`newvar'" !="" {
			gen `newvar' = $todaym
			label var `newvar' "Elapsed months between `fdate' and current date"
			}
			else {
			gen per_months_today = $todaym
			label var per_months_today "Elapsed months between `fdate' and current date"
			}
		}
		else if "`freq'" == "d" {
			if "`newvar'" !="" {
			gen `newvar' = $todayd
			label var `newvar' "Elapsed days between `fdate' and current date"
			}
			else {
			gen per_days_today = $todayd
			label var per_days_today "Elapsed days between `fdate' and current date"
			}
		}
		else {
		di as err "Invalid option"
		exit 198
		}
	}
}	
end
