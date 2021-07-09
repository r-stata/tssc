*! version 1.0 May2014
*! author Ricardo Mora, UC3M

program dseg
syntax anything  [if] [in] [fw],				///
					[GENerate(name)		///
					 Within(varlist) 	///
                                         By(varlist)		///
					 Format(string)		///
					 SAVE(string asis)	///
					 REPLACE]
	version 8.1
	tempname S
	gettoken index varlist: anything
	// error messages
	if "`weight'"!="fweight" {
        	di as err "`weight' is not allowed"
		exit
   		}
	if "`replace'"!="" & "`generate'"=="" {
        	di as err "you must specify a name for the variable that contains the index"
		exit
   		}
	if "`index'"!="mutual" & "`index'"!="atkinson" & "`index'"!="entropy" & "`index'"!="diversity"{
        	di as err "`index' index is not supported"
		exit
   		}
	// saving options
	gettoken saving saving_options: save, parse(",")
	gettoken saving_options saving_options: saving_options, parse(",")
	// defaults
	if "`format'"=="" local format="%9.4f"
	if ("`generate'"=="" | ("`replace'"=="" &  "`saving'"=="" & "`generate'"!="")) local generate="`S'"
 	 _decseg_`index' `varlist' `if' `in' [`weight'`exp'] `using', ///
			within(`within') by(`by') format(`format') ///
			generate(`generate') saving(`"`saving'"') savopt(`saving_options') `replace'
end

program define _decseg_mutual
        syntax  varlist [if] [in] [fw /] ,			///
					[GENerate(name)		///
					 Within(varlist) 	///
                                         By(varlist)		///
					 Format(string)		///
					 SAVING(string) 	///
					 SAVOPT(string) 	///
					 REPLACE]
	quietly {        
	tempvar unit frequency total T level
	marksample touse, strok
	if "`replace'"=="" preserve
	keep if `touse'
	gettoken group unit_list: varlist
        egen `unit'=group(`unit_list')
	if "`weight'"=="" gen `frequency'=1
	if ("`weight'"=="fweight") gen `frequency'=`exp'
	if "`by'"=="" {
		gen `level'=1
		local by="`level'"
		}
 	collapse (sum) `frequency', by(`group' `unit' `within' `by')
	reshape wide `frequency', i(`unit' `within' `by') j(`group')
	egen double `total'=rowtotal(`frequency'*)
	_decseg_M `frequency'*, tot(`total') by(`within' `by') gen(`generate')
	collapse (sum) `total' (mean) `generate', by(`within' `by')
	egen `T'=sum(`total'), by(`by')
	generate `generate'_weight=`total'/`T'
	label variable `generate' "Within Local Mutual Information Index"
	label variable `generate'_weight "Weight in within term"
	drop `total' `T'
	if "`saving'"!="" noi save "`saving'", `savopt'
	replace `generate'=(`generate'_weight)*`generate'
	collapse (sum) `generate', by(`by')
	if "`replace'"=="" char define `generate'[varname] " "
	sort `by'
	if "`by'"=="`level'" local by=""
	noi _decseg_dis, index("Mutual Information") group("`group'") units("`unit_list'") generate("`generate'") ///
		within("`within'") by("`by'") format(`format') 
	if "`replace'"=="" restore
	}
end

program define _decseg_atkinson
        syntax  varlist [if] [in] [fw /] ,			///
					[GENerate(name)		///
					 Within(varlist) 	///
                                         By(varlist)		///
					 Format(string)		///
					 SAVING(string) 	///
					 SAVOPT(string) 	///
					 REPLACE]
	quietly {
	tempname Tg alp
        tempvar unit frequency level total PI 
	marksample touse, strok
	if "`replace'"=="" preserve
	keep if `touse'
	gettoken group unit_list: varlist
	qui tab `group'
	local G=(r(r))^(-1)
        egen `unit'=group(`unit_list')
	if "`weight'"=="" gen `frequency'=1
	if ("`weight'"=="fweight" | "`weight'"=="iweight") gen `frequency'=`exp'
	if "`by'"=="" {
		gen `level'=1
		local by="`level'"
		}
 	collapse (sum) `frequency', by(`group' `unit' `within' `by')
	reshape wide `frequency', i(`unit' `within' `by') j(`group')
	mvencode `frequency'*, mv(0) override
	_decseg_A `frequency'*, weight(`G') by(`within' `by') gen(`generate')
	collapse (sum) `frequency'* (mean) `generate', by(`within' `by')
	gen `PI'=1
	foreach v of varlist `frequency'* {
		egen `Tg'1`v' = sum(`v'), by(`within' `by')
		egen `Tg'2`v' = sum(`v'), by(`by')
		replace `PI'=`PI'*((`Tg'1`v'/`Tg'2`v')^(`G'))
	}
	generate `generate'_weight=`PI'
	label variable `generate' "Within Local Mutual Information Index"
	label variable `generate'_weight "Weight in within term"
	drop `frequency'* `Tg'1* `Tg'2* `PI'
	if "`saving'"!="" noi save "`saving'", `savopt'
	replace `generate'=(`generate'_weight)*`generate'
	collapse (sum) `generate', by(`by')
	if "`replace'"=="" char define `generate'[varname] " "
	sort `by'
	if "`by'"=="`level'" local by=""
	noi _decseg_dis, index("Symmetric Atkinson") group("`group'") units("`unit_list'") generate("`generate'") ///
		within("`within'") by("`by'") format(`format') 
	if "`replace'"=="" restore
	}
end

program define _decseg_entropy
        syntax  varlist [if] [in] [fw iw /] ,			///
					[GENerate(name)		///
					 Within(varlist) 	///
                                         By(varlist)		///
					 Format(string)		///
					 SAVING(string) 	///
					 SAVOPT(string) 	///
					 REPLACE]
	quietly {
	tempname R
	local ratio "`R'"
        tempvar unit frequency total T level
	marksample touse, strok
	if "`replace'"=="" preserve
	keep if `touse'
	gettoken group unit_list: varlist 
        egen `unit'=group(`unit_list')
	if "`weight'"=="" gen `frequency'=1
	if ("`weight'"=="fweight" | "`weight'"=="iweight") gen `frequency'=`exp'
	if "`by'"=="" {
		gen `level'=1
		local by="`level'"
		}
 	collapse (sum) `frequency', by(`group' `unit' `within' `by')
	reshape wide `frequency', i(`unit' `within' `by') j(`group')
	egen double `total'=rowtotal(`frequency'*)
	_decseg_E `frequency'*, tot(`total') by(`by') within(`within') gen(`generate') ratio(`ratio')
	collapse (sum) `total' (mean) `generate' `ratio' , by(`within' `by')
	egen `T'=sum(`total'), by(`by')
	generate `generate'_weight=`total'/`T'
	generate `generate'_ratio=`ratio'
	label variable `generate' "Within Local Mutual Information Index"
	label variable `generate'_weight "Weight in within term"
	label variable `generate'_ratio "Ratio in within term"
	drop `total' `T' `ratio'
	if "`saving'"!="" noi save "`saving'", `savopt'
	replace `generate'=(`generate'_weight)*(`generate'_ratio)*`generate'
	collapse (sum) `generate', by(`by')
	if "`replace'"=="" char define `generate'[varname] " "
	sort `by'
	if "`by'"=="`level'" local by=""
	noi _decseg_dis, index("Entropy") group("`group'") units("`unit_list'") generate("`generate'") ///
		within("`within'") by("`by'") format(`format') 
	if "`replace'"=="" restore
	}
end

program define _decseg_diversity
        syntax  varlist [if] [in] [fw iw /] ,			///
					[GENerate(name)		///
					 Within(varlist) 	///
                                         By(varlist)		///
					 Format(string)		///
					 SAVING(string) 	///
					 SAVOPT(string) 	///
					 REPLACE]
	quietly {
	tempname R
	local ratio "`R'"
        tempvar unit frequency total T level
	marksample touse, strok
	if "`replace'"=="" preserve
	keep if `touse'
	gettoken group unit_list: varlist 
        egen `unit'=group(`unit_list')
	if "`weight'"=="" gen `frequency'=1
	if ("`weight'"=="fweight" | "`weight'"=="iweight") gen `frequency'=`exp'
	if "`by'"=="" {
		gen `level'=1
		local by="`level'"
		}
 	collapse (sum) `frequency', by(`group' `unit' `within' `by')
	reshape wide `frequency', i(`unit' `within' `by') j(`group')
	egen double `total'=rowtotal(`frequency'*)
	_decseg_D `frequency'*, tot(`total') by(`by') within(`within') gen(`generate') ratio(`ratio')
	collapse (sum) `total' (mean) `generate' `ratio' , by(`within' `by')
	egen `T'=sum(`total'), by(`by')
	generate `generate'_weight=`total'/`T'
	generate `generate'_ratio=`ratio'
	label variable `generate' "Within Local Mutual Information Index"
	label variable `generate'_weight "Weight in within term"
	label variable `generate'_ratio "Ratio in within term"
	drop `total' `T' `ratio'
	if "`saving'"!="" noi save "`saving'", `savopt'
	replace `generate'=(`generate'_weight)*(`generate'_ratio)*`generate'
	collapse (sum) `generate', by(`by')
	if "`replace'"=="" char define `generate'[varname] " "
	sort `by'
	if "`by'"=="`level'" local by=""
	noi _decseg_dis, index("Relative Diversity") group("`group'") units("`unit_list'") generate("`generate'") ///
		within("`within'") by("`by'") format(`format') 
	if "`replace'"=="" restore
	}
end

program define _decseg_M
       syntax varlist, TOT(varname) [BY(varlist)] GENerate(name)
       tempname pg
       tempvar T t m Mj pj
       tokenize `varlist'
       gen double `Mj'=0
       gen double `m'=0
       egen double `T'=sum(`tot'), by(`by')
       gen double `pj'=`tot'/`T'
               while "`1'" ~= ""{
               gen double `pg'`1'=`1'/`tot'
               egen double `t'=sum(`1'), by(`by')
               replace `m'=(`pg'`1')*log((`pg'`1')/(`t'/`T')) if `pg'`1'>0 & `pg'`1'<.
               replace `Mj'=`Mj'+`m'
               replace `m'=0
               drop `t'
               macro shift
       }
       replace `m'=`pj'*`Mj'
       egen double `generate'=sum(`m'), by(`by')
end

program define _decseg_A
       syntax varlist, Weight(real) [BY(varlist)] GENerate(name)
       tempname Tg
       tempvar PI
       tokenize `varlist'
       gen double `PI'=1
       while "`1'" ~= ""{
	       egen double `Tg'`1'=sum(`1'), by(`by')
               replace `PI'=`PI'*((`1'/`Tg'`1')^(`weight'))
               macro shift
       }
       egen double `generate'=sum(`PI'), by(`by')
       replace `generate'=1-`generate'
end

program define _decseg_E
       syntax varlist, TOT(varname) [BY(varlist) WITHIN(varlist)] GENerate(name) RATIO(name)

       tempvar T t m Mj pj pg e Ek TT tt E ee    
       tokenize `varlist'
       gen double `Mj'=0
       gen double `Ek'=0
       gen double `E'=0
       gen double `m'=0
       gen double `e'=0
       gen double `ee'=0
       egen double `T'=sum(`tot'), by(`by' `within')
       egen double `TT'=sum(`tot'), by(`by')
       gen double `pj'=`tot'/`T'       
       while "`1'" ~= ""{
               gen double `pg'=`1'/`tot'
               egen double `t'=sum(`1'), by(`by' `within')
               egen double `tt'=sum(`1'), by(`by')
               replace `m'=(`pg')*log((`pg')/(`t'/`T')) if `pg'>0 & `pg'<.
               replace `e'=(`t'/`T')*log(1/(`t'/`T')) if `t'>0 & `t'<.
               replace `ee'=(`tt'/`TT')*log(1/(`tt'/`TT')) if `tt'>0 & `tt'<.
               replace `Mj'=`Mj'+`m'
               replace `Ek'=`Ek'+`e'
               replace `E'=`E'+`ee'
               replace `m'=0
               replace `e'=0
               replace `ee'=0
               drop `pg' `t' `tt'
               macro shift
       }
       replace `m'=`pj'*`Mj'
       egen double `generate'=sum(`m'), by(`by' `within')
       replace `generate'=`generate'/`Ek'
       gen double `ratio'=`Ek'/`E'
end

program define _decseg_D
       syntax varlist, TOT(varname) [BY(varlist) WITHIN(varlist)] GENerate(name) RATIO(name)
       tempvar T t dj Ij pj pg ij Ik TT tt I ik ii
       tokenize `varlist'
       gen double `Ij'=0
       gen double `Ik'=0
       gen double `I'=0
       gen double `ij'=0
       gen double `ik'=0
       gen double `ii'=0
       egen double `T'=sum(`tot'), by(`by' `within')
       egen double `TT'=sum(`tot'), by(`by')
       gen double `pj'=`tot'/`T'       
       while "`1'" ~= ""{
               gen double `pg'=`1'/`tot'
               egen double `t'=sum(`1'), by(`by' `within')
               egen double `tt'=sum(`1'), by(`by')
               replace `ij'=(`pg')*(1-`pg') if `pg'>0 & `pg'<.
               replace `ik'=(`t'/`T')*(1-(`t'/`T')) if `t'>0 & `t'<.
               replace `ii'=(`tt'/`TT')*(1-(`tt'/`TT')) if `tt'>0 & `tt'<.
               replace `Ij'=`Ij'+`ij'
               replace `Ik'=`Ik'+`ik'
               replace `I'=`I'+`ii'
               replace `ij'=0
               replace `ik'=0
               replace `ii'=0
               drop `pg' `t' `tt'
               macro shift
       }
       gen double `dj'=`pj'*(`Ik'-`Ij')/(`Ik')
       egen double `generate'=sum(`dj'), by(`by' `within')
       gen double `ratio'=`Ik'/`I'
end

program define _decseg_dis
	syntax  ,[			///
		 Index(string)		///
		 Group(string)		///
		 Units(string)		///
		 Generate(string)	///
		 Within(string) 	///
		 BY(string)		///
		 Format(string)]
	if "`format'"!="" format `generate' `format'
	if "`by'"!="" sort `by'
	dis _newline _col(4) in g "Index: " in y "`index'" 
	dis _col(4) in g "Segregation by " in y "`group'" in g " groups along" in y "`units'" in g " units" 
	if "`within'" != "" dis _col(4) in g "Within " in y "`within'"
	if "`by'" != "" dis _col(4) in g "By " in y "`by'"
	if "`by'" == "" {
		l `generate', noobs clean noheader
		}
	if "`by'" != "" {
		l `by' `generate', noobs table subvarname ab(10)
		}
end
