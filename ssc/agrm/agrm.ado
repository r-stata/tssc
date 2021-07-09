* Define name of program *

capture program drop agrm

*! agrm v1.1.2 AEcker 25may2011

program agrm, byable(recall) rclass
	version 9.0

	* define syntax *
	syntax varlist [if] [in] [fweight] [, GENerate(name) CATegories(numlist >1 max=1 integer) BOUnds(numlist max=2 sort) Detail Missing(numlist sort) noPRINT]

	* define marksample *
	marksample touse, novarlist

	* tokenize varlist *
	tokenize `varlist'

	* incrementing through positional arguments, i.e. variables, for example agrm var1 var2 etc.*
	local i 1
	
	while "``i''" != "" {		

		* defining temporal macros *
		tempname freq freq_help col label_cat cat_max varfreq

		* generate temporary variables ```i''_`touse'' and ```i''_original*
		tempvar ``i''_`touse' ``i''_original
		quietly gen ```i''_`touse''=``i'' if `touse' 
		quietly gen ```i''_original'=``i''																/* generate duplicate of original variable */
		
		* search for negatve and noninteger category values *
		quietly inspect ```i''_original'
		if `r(N_neg)' > 0 {
			local negative = 1
		}
		if `r(N_pos)' != `r(N_posint)' {
			local noninteger = 1
		}
		
		* replace numerical missing values *
		if "`missing'" != "" {
			local missing_categories: word count `missing'
			forvalues missing_values=1/`missing_categories' {
				local missing_category_`missing_values': word `missing_values' of `missing'
				quietly mvdecode ```i''_original' ```i''_`touse'', mv(`missing_category_`missing_values'')	/* original in order to prevent counting for categories and touse in order to allow calculation of mean etc. */
			}
		}		
		
		* calculate mean, sd, min, and max *
		quietly sum ```i''_`touse'' [`weight'`exp']
		return scalar mean = r(mean)
		return scalar sd   = r(sd)
		return scalar min  = r(min)
		return scalar max  = r(max)
		
		* extracting name of the value label associated with ``i'' *
		local value_label_``i'': value label ``i'' 														
		
		* define total number of categories if option `categories' specified *
		if "`categories'" != "" {
			local number_categories = `categories'
		}
			
		* define total number of categories if option `categories' NOT specified *
		else {	
			
			* both if value labels assigned and if NO value labels assigned *
			quietly tab ```i''_original' 																/* by tabulating variable */
			local number_categories = r(r)
			
			* only if value labels assigned *
			if "`value_label_``i'''" != "" {															/* by extracting value labels */									
				numlabel `value_label_``i''' , add mask("# ") /*"*/
				quietly label list `value_label_``i''' 
				local minlabel = `r(min)'
				forvalues label_values =`r(min)'/`r(max)' {

					* if `missing' option specified *
					if "`label_values'" == "`missing_category_1'" {										/* greater than first numerical missing value `missing_category_`1'' sufficient */
						continue, break
					}	
	
					* if `missing' option NOT specified *
					else {
						local label_values_help: label `value_label_``i''' `label_values', strict
						if "`label_values_help'" == "" {
								continue
						}		
						else {
							local label_value_max = "`label_values_help'"
						}
					}
				}
				local label_value_max = word("`label_value_max'",1)	

				* ursprünliche value labels wiederherstellen *
				numlabel `value_label_``i''', remove mask("# ") /*"*/
			
				* replace number of categories if value labels result in more categories than tabulating variable *
				quietly levelsof ```i''_original', separate(" ") /*"*/									/* add category if category 0 populated or label for 0 exists */
				local minlevelsof: word 1 of `r(levels)'
				if `minlevelsof' == 0 | `minlabel' == 0 {
					local label_value_max = `label_value_max' + 1
				}
				if `label_value_max' > `number_categories' {											/* note that numerical missing values are already removed in `number_categories' */
					local number_categories = `label_value_max'
					local marker_``i''_vlabels = 1														/* indicator for using value labels */
				}
			}
		}

		* error messages *
		* less than three categories *
		if `number_categories'<3 {
			di "{err}too few categories"
			exit 148
		}		
		
		* noninteger category values *
		if "`noninteger'" == "1" {
			di "{err}noninteger category values"
			exit 126
		}
		
		* negative category values *
		if "`negative'" == "1" {
			di "{err}negative category values"
			exit 508
		}
		
		* numerical missing values *
		quietly levelsof ```i''_original', separate(" ") /*"*/
		local levels: word count `r(levels)'
		local maxlevelsof: word `levels' of `r(levels)'
		
		if `number_categories'>89 | `maxlevelsof'>89 {
			di "{err}numerical missing values"
			exit 416
		} 		
	
		quietly tab ```i''_`touse'' [`weight'`exp'], matcell(`freq_help')
		svmat `freq_help'
		quietly inspect `freq_help'
		local layer = r(N_unique)		

		* create scalar with empirical distribution *		
		quietly tab ``i'' ```i''_`touse'' [`weight'`exp'], matcell(`freq') matcol (`col')
		local nonempty = r(c)		
		local N = r(N)
		local number_observations = r(N)
		
		matrix `varfreq' = J(1,`number_categories',0)

		forvalues x=1/`nonempty' {
			if `col'[1,1]==0 {		
				local pos_`x'=`col'[1,`x']+1
			}			
			else {
				local pos_`x'=`col'[1,`x']
			}
			if `pos_`x''>`number_categories' {
				 if `pos_`x''>89 {
					di "{err}numerical missing values"
					exit 416
				} 				
				else {	
					di "{err}specify number of categories"
					exit 148
				}
			}			
		matrix `varfreq'[1,`pos_`x''] = `freq'[`x',`x']			
		}	

		* disaggregate empirical distribution into `layer' layers and calculate A *
		mata: disaggregate ("`varfreq'", `layer', `number_categories', `number_observations')
		local A = `=agree'
		scalar drop agree
	
		if "`bounds'" != "" {
			gettoken lowerbound upperbound: bounds
			local A = (`A'*(abs(`upperbound'-`lowerbound'))/2)+((abs(`upperbound'-`lowerbound'))/2)+`lowerbound'
		}
		
		* if output NOT supressed *
		if "`print'" != "noprint" {
			* if additional statistics displayed *
			if "`detail'" != "" {
				* if first variable *
				if `i'==1 {
					di as text "   Variable {c |}     Obs" _col(25) "Measure of agreement" _col(48) "Number of categories" _col(80) "Mean" _col(87) "Std. Dev." _col(100) "Min" _col(109) "Max"
					di as text "{hline 12}{c +}{hline 98}"
					* if option `categories specified *
					if "`categories'" != "" {
						di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' "{text} (manually adjusted)" _col(75) %9.2f return(mean) _col(84) %9.2f return(sd) _col(91) %9.0f return(min) _col(94) %9.0f return(max)
					}
					* if option `categories' NOT specified * 
					else {
						* if value labels used *
						if "`marker_``i''_vlabels'" == "1" {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' "{text} (automatically adjusted)" _col(72) %9.2f return(mean) _col(81) %9.2f return(sd) _col(88) %9.0f return(min) _col(91) %9.0f return(max)
						}				
						* if value labels NOT used *
						else {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' _col(75) %9.2f return(mean) _col(84) %9.2f return(sd) _col(91) %9.0f return(min) _col(94) %9.0f return(max)
						}
					}
				}
				* if NOT first variable *
				else {
					* if option `categories specified *
					if "`categories'" != "" {
						di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' "{text} (manually adjusted)" _col(75) %9.2f return(mean) _col(84) %9.2f return(sd) _col(91) %9.0f return(min) _col(94) %9.0f return(max)
					}
					* if option `categories' NOT specified * 
					else {
						* if value labels used *
						if "`marker_``i''_vlabels'" == "1" {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' "{text} (automatically adjusted)" _col(72) %9.2f return(mean) _col(81) %9.2f return(sd) _col(88) %9.0f return(min) _col(91) %9.0f return(max)
						}							
						* if value labels NOT used *
						else {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' _col(27) %9.2f `A' _col(41) %9.0f `number_categories' _col(75) %9.2f return(mean) _col(84) %9.2f return(sd) _col(91) %9.0f return(min) _col(94) %9.0f return(max)
						}
					}
				}
			}			
			* if additional statistics NOT displayed *
			else {	
				* if first variable *
				if `i'==1 {
					di as text "    Variable{c |}     Obs" _col(25) "Measure of agreement" _col(48) "Number of categories"
					di as text "{hline 12}{c +}{hline 61}"
					* if option `categories specified *
					if "`categories'" != "" {
						di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories' as text " (manually adjusted)"						
					}
					* if option `categories' NOT specified * 
					else {
						* if value labels used *
						if "`marker_``i''_vlabels'" == "1" {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories' as text " (automatically adjusted)"
						}
						* if value labels NOT used *					
						else {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories'
						}	
					}
				}
				* if NOT first variable *
				else {
					* if option `categories specified *
					if "`categories'" != "" {
						di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories' as text " (manually adjusted)"						
					}
					* if option `categories' NOT specified * 
					else {
						* if value labels used *
						if "`marker_``i''_vlabels'" == "1" {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories' as text " (automatically adjusted)"
						}
						* if value labels NOT used *	
						else {
							di as text %12s abbrev("``i''",12) "{c |}" as result %8.0fc `N' "     " %9.2f `A' "     " %9.0f `number_categories'
						}	
					}	
				}			
			}
		}

		if "`generate'" != "" {
			if _by()==0 {
				quietly generate `generate'_``i'' = `A' if `touse' & ```i''_`touse'' < .
			}

			else {
				local bycat: word count `_byvars'
				local beginn 0
				local ende 1
					forvalues a=1/`bycat' {
						local bycat`a': word `a' of `_byvars'
						quietly sum `bycat`a'' if `touse'
						local bycat`a'value = r(mean)
						local value`ende'= "`value`beginn''_`bycat`a''`bycat`a'value'"
					local ++beginn
					local ++ende
					}
				quietly generate `generate'_``i''`value`bycat'' = `A' if `touse' & ```i''_`touse'' < .
			}
		}

		* saving results in r() *
		return scalar A = `A'

		local ++i

	}	
	
	if "`print'" != "noprint" {

		if "`detail'" != "" {
			di as text "{hline 12}{c BT}{hline 98}"
		}

		else {
			di as text "{hline 12}{c BT}{hline 61}"
		}
	}
end

mata:
void function disaggregate(matrix varfreq, scalar layer, scalar number_categories, scalar number_observations)
{
	row1 = st_matrix(varfreq)
	row1 = editvalue(row1,0,.)
	rownonmiss = J(layer,1,.)
	tu = J(layer,1,0)
	tdu = J(layer,1,0)
	N = J(layer,1,.)
	U = J(layer,1,.)
	A = J(layer,1,.)
	rows = J(layer-1,cols(row1),.)
	mat = row1\rows
	for (i=1; i<=layer; i++) {
		if (i==1) {
			rownonmiss[i,] = rownonmissing(mat[i,])
			N[i,] = rowmin(mat[i,])*rownonmiss[i,]
		}
		if (i>1) {
			sub = J(1,cols(row1),rowmin(mat[i-1,]))
			mat[i,] = mat[i-1,]-sub
			mat = editvalue(mat,0,.)
			rownonmiss[i,] = rownonmissing(mat[i,])
			N[i,] = rowmin(mat[i,])*rownonmiss[i,]
		}
		j = k = l = 0
		for (val1=1; val1<=number_categories; val1++) {
			j = j+1
			for (val2=2; val2<=number_categories; val2++) {
				k = k+1
				if (val2==2) k = 1
				for (val3=3; val3<=number_categories; val3++) {
					l = l+1
					if (val3==3) l = 1
				
					if (val2==val1) continue
					else if (val3==val2) continue 
					else if (val3==val1) continue
					else if (k<j) continue	
					else if (l<k) continue
					
					triple = (mat[i,val1],mat[i,val2],mat[i,val3])
					rowmiss = rowmissing(triple)
					if (rowmiss!=1) continue
					if (triple[1,2]==.) tdu[i,] = tdu[i,]+1 
					if (triple[1,1]==.) tu[i,] = tu[i,]+1 
					if (triple[1,3]==.) tu[i,] = tu[i,]+1 
				}
			}	
		}	
		U[i,] = ((number_categories-2)*tu[i,]-(number_categories-1)*tdu[i,])/((number_categories-2)*(tu[i,]+tdu[i,]))
		if (tu[i,]==0 & tdu[i,]==0) U[i,] = 1						
		
		A[i,] = U[i,]*(1-(rownonmiss[i,]-1)/(number_categories-1))	
		if (rownonmiss[i,]==number_categories) A[i,] = 0

		A[i,] = A[i,]*(N[i,]/number_observations)	
	}
	A = colsum(A)
	st_numscalar("agree", A)
}
end
