program define _getmxdatabie
	syntax anything(name=vars) , [ key(string) ]
	qui{
	local tokenbie `key'
	tempfile f1 f2 varbase meta1 meta2 meta3 meta4
	gettoken next :vars
	local j=1
	while `"`next'"' != "" {
	gettoken varname vars:vars
	local varname `varname'
	local link "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/INDICATOR/`varname'/es/0700/false/BIE/2.0/`tokenbie'?type=json"
	copy "`link'" `f1'
	filefilter `f1' `f2', from("{") to(\r) replace
	import delimited using `f2', delim(":,") stripquotes(yes) clear
	set type double
	split v2, parse("/") gen(fecha)	
	gen double indicador=real(v4) if _n>3
	
		local frecuencia = v4[3]
if `frecuencia'!=3{
	gen year=real(fecha1) if _n>3
	gen freq=real(fecha2)
	}
	else {
		gen year=real(fecha1) if _n>3
	}
	local indicador = v2[3]
	*local fuente = v12[3]
	local unidades = v8[3]
	if `j'==1{
	local freqmaster = v4[3]
	}
	local diffreq=`frecuencia'-`freqmaster'
	if `diffreq'!=0{
	di as err "error: variables must have same frecuency"
	clear
	exit 498
	}
	drop if indicador==.
	
	if `frecuencia'!=3{
	keep indicador year freq v2
	}
	else {
	keep indicador year v2
	}
	
	rename v2 Periodo
	rename indicador v_`varname'
	* read freq
	if `frecuencia'==3{
	gen fecha=year
		drop year
	}
	else if `frecuencia'==6{
	gen fecha=yq(year,freq)
	format fecha %tq
		drop year freq
	}
	else if `frecuencia'==8{
	gen fecha=ym(year,freq)
	format fecha %tm
		drop year freq
	}
	order Periodo fecha v*
	*metadata
	preserve
	local link "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/CL_INDICATOR/`varname'/es/BIE/2.0/`tokenbie'?type=json"
	copy "`link'" `meta1'
	filefilter `meta1' `meta2', from("[") to(\r) replace
	local link "https://www.inegi.org.mx/app/api/indicadores/desarrolladores/jsonxml/CL_UNIT/`unidades'/es/BIE/2.0/`tokenbie'?type=json"
	copy "`link'" `meta3'
	filefilter `meta3' `meta4', from("[") to(\r) replace
	import delimited using `meta2', delim(":}") stripquotes(yes) clear
	local varlabel = inegiversion[1]
	import delimited using `meta4', delim(":}") stripquotes(yes) clear
	local unidlabel = inegiversion[1]
	restore
	label var v_`varname' "`varlabel', `unidlabel'"
	capture merge 1:1 fecha using `varbase'
	capture drop _merge
	gettoken next :vars, quotes
	sort fecha
	recast strL Periodo
	save `varbase', replace
	local ++j
}
}
 di in green "`=`j'+1' variables, `=_N' obs"
end
