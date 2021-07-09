program define _getmxdatabanxico
		syntax anything(name=vars) , [key(string)]
qui{
	local tokenbanxico `key'
	tempfile f1 f2 varbase meta1 meta2 meta3 meta4
	gettoken next :vars
	local j=1
	while `"`next'"' != "" {
	gettoken varname vars:vars
	local varname `varname'
	local link "https://www.banxico.org.mx/SieAPIRest/service/v1/series/`varname'/datos?token=`tokenbanxico'"
	copy "`link'" `f1'
	filefilter `f1' `f2', from("[") to(\r) replace
	filefilter `f2' `f1', from("},{") to(\r) replace
	import delimited using `f1', delim(",:}") stripquotes(yes) clear
	moss v4, match("([0-9\.]+)") regex
	egen vardat=concat(_match*) if v3=="dato"
	destring vardat, gen(indicador)
	drop _c* _m* _p*
	drop if indicador==. & v3!="dato"
	split v2, parse("/") gen(fy)
	keep v2 fy* indicador
	destring fy*, replace
	preserve
	copy "https://www.banxico.org.mx/SieAPIRest/service/v1/series/`varname'?token=`tokenbanxico'" `meta1'
	import delimited using `meta1', delim(",") stripquotes(yes) clear
	split v1, parse("<" ">") gen (metadata)
	local freq=metadata3[26]
	local varlabel=metadata3[14]
	local unidad=metadata3[34]
	if `j'==1{
	local freqmaster `freq'
	}
	restore
	if "`freqmaster'" != "`freq'" {
	clear
	di as err "error: variables must have same frecuency"
 	exit 498
	}
	label var indicador "`varlabel', `unidad'"
	if "Mensual"=="`freq'"  {
	gen  fecha=ym(fy3,fy2)
	format fecha %tm
	}
	else if "Diaria"=="`freq'" | "Semanal"=="`freq'"  {
	gen fecha = mdy(fy2,fy1,fy3)
	format fecha %td
	}
	else if "Trimestral"=="`freq'"  {
	gen fecha = qofd(dofm(ym(fy3,fy2)))
	format fecha %tq
	}
	else if "Anual"=="`freq'"  {
	rename fy3 fecha
	}
	drop fy*
	rename v2 Periodo
	rename indicador `varname'
	capture merge 1:1 fecha using `varbase'
	capture drop _merge
	gettoken next :vars, quotes
	save `varbase', replace
	local ++j
}
}
 di in green "`=`j'+1' variables, `=_N' obs"
end
