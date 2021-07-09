* *! Version 1.3.0 by Francisco Perales 17-July-2019
* Requires Stata version 12 or higher

program define lsacsetup
syntax , DATAdirectory(string) SAVINGdirectory(string) VARiables(string) FILEname(string) RELease(string) [NOMIDwave HHfile(string) NAPLANfile(string)]
version 12
quietly clear
quietly cd "`savingdirectory'"
if strpos("`filename'", ".")|strpos("`filename'", " "){
	display in red "The requested file name cannot contain a space or a file extension"
	exit
}
if "`release'" == "1"{
	local release_number = "b0 k4"
}
if "`release'" == "2"{
	local release_number = "b0 b2 k4 k6"
}
if "`release'" == "3"{
	local release_number = "b0 b2 b3 b4 k4 k5 k6 k8"
}
if "`release'" == "4"{
	local release_number = "b0 b2 b3 b4 b5 b6 k4 k6 k7 k8 k9 k10"
}
if "`release'" == "5"{
	local release_number = "b0 b2 b3 b4 b5 b6 b8 k4 k6 k7 k8 k9 k10 k12"
}
if "`release'" == "6"{
	local release_number = "b0 b2 b3 b4 b5 b6 b8 b10 k4 k6 k7 k8 k9 k10 k12 k14"
}
if "`release'" == "7"{
	local release_number = "b0 b2 b3 b4 b5 b6 b8 b10 b12 k4 k6 k7 k8 k9 k10 k12 k14 k16"
}
quietly capture erase `filename'.dta
quietly save `filename', replace emptyok
display in yellow _newline(1) "Data management started"
foreach file in `release_number'{
	quietly{
			use "`datadirectory'\lsacgr`file'", clear
			if "`file'"=="b0"{
				local prefix = "a" 
			}
			if "`file'"=="b2"|"`file'"=="b3"{
				local prefix = "b" 
			}
			if "`file'"=="b4"|"`file'"=="b5"|"`file'"=="k4"{
				local prefix = "c" 
			}
			if "`file'"=="b6"|"`file'"=="k6"|"`file'"=="k7"{
				local prefix = "d"
			}
			if "`file'"=="b8"|"`file'"=="k8"|"`file'"=="k9"{
				local prefix = "e"
			}
			if "`file'"=="b10"|"`file'"=="k10"{
				local prefix = "f"
			}
			if "`file'"=="b12"|"`file'"=="k12"{
				local prefix = "g"
			}
			if "`file'"=="k14"{
				local prefix = "h"
			}
			if "`file'"=="k16"{
				local prefix = "i"
			}
			capture rename abroth broth
			capture rename asist sist
			capture rename asib sib
			capture rename bbroth broth
			capture rename bsist sist
			capture rename bsib sib
			capture rename bmoth moth
			capture rename cbroth broth
			capture rename csist sist
			capture rename csib sib
			capture rename dbroth broth
			capture rename dsist sist
			capture rename dsib sib
			capture rename dmoth moth
			capture rename defwt ddefwt
			capture rename defwts ddefwts
			capture rename fsist sist
			capture rename fbroth broth
			capture rename fsib sib
			capture rename hsist sist
			capture rename hbroth broth
			capture rename hsib sib
			renpfix `prefix'
			capture rename ohort cohort
			capture rename icid hicid
			local list ""
					foreach variable in `variables'{
						capture des `variable', varlist
						if !_rc {
							local list "`list' `r(varlist)'"
						}
					}
			keep cohort hicid wave `list'
			append using `filename'
			save `filename', replace
		}
		disp in green "File `file' completed"
}
if "`hhfile'" != ""{
	foreach group in b k{
		quietly{
			use "`datadirectory'\hhgr`group'", clear
			local list`group' ""
				foreach variable in `hhfile'{
					capture des `variable', varlist
					if !_rc {
						local list`group' "`list`group'' `r(varlist)'"
					}
				}
			keep hicid `list`group''
			merge 1:m hicid using `filename'
			drop if _merge==1
			drop _merge
			sort hicid
			quietly save `filename', replace
		}
	}
	disp in green "Household files completed"
}
if "`naplanfile'" != ""{
	quietly{
		if "`release'" != "6" & "`release'" != "7"{
			use "`datadirectory'\lsacnaplanacara_gr", clear
		}
		if "`release'" == "6"|"`release'" == "7"{
			use "`datadirectory'\lsacnaplan", clear
		}
		local list_naplan ""
			foreach variable in `naplanfile'{
				capture des `variable', varlist
				if !_rc {
					local list_naplan "`list_naplan' `r(varlist)'"
				}
			}
		keep hicid `list_naplan'
		merge 1:m hicid using `filename'
		drop if _merge==1
		drop _merge
		sort hicid
	}
	quietly save `filename', replace
	disp in green "Naplan file completed"
}
if "`nomidwave'" != ""{
	quietly drop if wave==2.5|wave==3.5
}
foreach var of varlist _all{
	local varlabel "`:variable label `var''"
	local varlabel = regexr("`varlabel'","  "," ")
	local varlabel = regexr("`varlabel'","0/1 - ","")
	local varlabel = regexr("`varlabel'","2/3 - ","")
	local varlabel = regexr("`varlabel'","4/5 - ","")
	local varlabel = regexr("`varlabel'","6/7 - ","")
	local varlabel = regexr("`varlabel'","8/9 - ","")
	local varlabel = regexr("`varlabel'","10/11 - ","")
	local varlabel = regexr("`varlabel'","12/13 - ","")
	local varlabel = regexr("`varlabel'","14/15 - ","")
	local varlabel = regexr("`varlabel'","16/17 - ","")
	lab var `var' "`varlabel'"
}
quietly recode wave 34=1
quietly drop if hicid==0|wave==.
sort cohort hicid wave
order cohort hicid wave
quietly save, replace
display in yellow "Data management finished"
disp in yellow _newline(1) "The new LSAC longitudinal file `filename'.dta has been saved in the directory:"
disp in yellow "`savingdirectory'"
end
