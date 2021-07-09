* *! Version 1.1.0 by Francisco Perales 26-April-2013 
* Requires Stata version 12 or higher

program define hildasetup
syntax , DATAdirectory(string) SAVINGdirectory(string) VARiables(string) FILEname(string) RELease(integer) [MASTERfile(string) LWfile(string) UNCONFidentialised]
version 12
quietly clear
quietly cd "`savingdirectory'"
if strpos("`filename'", ".")|strpos("`filename'", " "){
	display in red "The requested file name cannot contain a space or a file extension"
	exit
}
quietly capture erase `filename'.dta
quietly save `filename', replace emptyok
local type "c"
if "`unconfidentialised'" != ""{
	local type "u"
}
display in yellow _newline(1) "Data management started"
local waves = substr(c(alpha), 1, (`release'*2)-1)
	foreach waveprefix in `waves'{
		quietly{
			use "`datadirectory'\Combined_`waveprefix'`release'0`type'", clear
			renpfix `waveprefix'
			local list ""
			foreach variable in xwaveid `variables'{
				capture des `variable', varlist
				if !_rc {
					local list "`list' `r(varlist)'"
				}
			}
			keep `list'
			gen wave = index("abcdefghijklmnopqrstuvwxyz","`waveprefix'")
			lab var wave "Wave of the HILDA survey"
			append using `filename'
			sort xwaveid
			save `filename', replace
		}
		disp in green "Wave `waveprefix' completed"
	}
if "`masterfile'" != ""{
	quietly{
		local waveprefix = substr("abcdefghijklmnopqrstuvwxyz", `release', 1)
		use "`datadirectory'\Master_`waveprefix'`release'0`type'", clear
		sort xwaveid
		keep xwaveid `masterfile'
		merge 1:m xwaveid using `filename'
		drop _merge
		sort xwaveid
	}
	disp in green "Master file completed"
	quietly save `filename', replace
}
if "`lwfile'" != ""{
	quietly{
		local waveprefix = substr("abcdefghijklmnopqrstuvwxyz", `release', 1)
		use "`datadirectory'\Longitudinal_weights_`waveprefix'`release'0`type'", clear
		sort xwaveid
		keep xwaveid `lwfile'
		merge 1:m xwaveid using `filename'
		drop _merge
	}
	disp in green "Longitudinal Weights file completed"
	quietly save `filename', replace
}
sort xwaveid wave
order xwaveid wave
quietly save, replace
display in yellow "Data management finished"
disp in yellow _newline(1) "The new HILDA longitudinal file `filename'.dta has been saved in the directory:"
disp in yellow "`savingdirectory'"
end
