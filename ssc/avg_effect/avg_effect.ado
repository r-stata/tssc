/* 
	avg_effect y1 y2 [ y3 ... ], x(...) Effectvar(...) Controltest(...) [ , options ]

	Calculate average effect size across multiple outcomes.
	
	by Christopher Robert, Harvard Kennedy School, chris_robert@hksphd.harvard.edu
	
	v1.02, October 1, 2010
	
	Thanks to Clément Imbert for helping extend to handle more variables.
*/	

program define avg_effect, rclass
	syntax varlist(min=2 max=100) [if], x(string) Effectvar(string) Controltest(string) [Robust CLuster(string) KEEPmissing]
	version 9.2
	if "`keepmissing'"~="" {
		marksample marked, strok novarlist
	}
	else {
		marksample marked, strok
	}
	quietly {
		* initialize
		cap: est drop _ae*
		
		* loop through all y variables
		local nv=0
		foreach var in `varlist' {
			local nv=`nv'+1
			
			* calculate standard deviation for standardization
			sum `var' if `marked' & `controltest'
			local sd`nv'=r(sd)
			
			* regress y on x
			reg `var' `x' if `marked'
			est store _ae`nv'
		}
		
		* pull estimates together within the seemingly-unrelated framework
		if "`cluster'"~="" {
			local sue_opts=", vce(cluster `cluster')"
		}
		else if "`robust'"~="" {
			local sue_opts=", vce(robust)"
		}
		else {
			local sue_opts=""
		}
		noisily: suest _ae* `sue_opts'
		
		* assemble strings for linear combinations and associated tests
		local totalnum=floor((`nv'-1)/4)
		local test_stg=""
		local evn=0
		foreach ev in `effectvar' {
			local evn=`evn'+1
			
			local i=0
			foreach var in `varlist' {
				local i=`i'+1
				if `i'==1 {
					local stgno=1
					local lc_stg`evn'_`stgno'="(ae_`ev': "
					local test_stg="`test_stg' ae_`ev'"
				}
				else {
					local nextstgno=cond(floor((`i'-1)/4)==((`i'-1)/4),1,0)
					if `nextstgno'==1 {
						local lc_stg`evn'_`stgno'="`lc_stg`evn'_`stgno''+"
						local stgno=`stgno'+1
						local lc_stg`evn'_`stgno'=""
					}
					else {
						local lc_stg`evn'_`stgno'="`lc_stg`evn'_`stgno''+"
					}
				}
				local lc_stg`evn'_`stgno'="`lc_stg`evn'_`stgno''(1/`nv')*(1/`sd`i'')*[_ae`i'_mean]`ev'"
			}
			
			local lc_stg`evn'_`stgno'="`lc_stg`evn'_`stgno'')"
		}
		
		* assemble and test the linear combinations
		noisily: nlcom ///
			`lc_stg1_1'`lc_stg1_2'`lc_stg1_3'`lc_stg1_4'`lc_stg1_5'`lc_stg1_6'`lc_stg1_7'`lc_stg1_8'`lc_stg1_9'`lc_stg1_10' ///
			`lc_stg1_11'`lc_stg1_12'`lc_stg1_13'`lc_stg1_14'`lc_stg1_15'`lc_stg1_16'`lc_stg1_17'`lc_stg1_18'`lc_stg1_19'`lc_stg1_20' ///
			`lc_stg1_21'`lc_stg1_22'`lc_stg1_23'`lc_stg1_24'`lc_stg1_25'`lc_stg1_26'`lc_stg1_27'`lc_stg1_28'`lc_stg1_29'`lc_stg1_30' ///
			`lc_stg2_1'`lc_stg2_2'`lc_stg2_3'`lc_stg2_4'`lc_stg2_5'`lc_stg2_6'`lc_stg2_7'`lc_stg2_8'`lc_stg2_9'`lc_stg2_10' ///
			`lc_stg2_11'`lc_stg2_12'`lc_stg2_13'`lc_stg2_14'`lc_stg2_15'`lc_stg2_16'`lc_stg2_17'`lc_stg2_18'`lc_stg2_19'`lc_stg2_20' ///
			`lc_stg2_21'`lc_stg2_22'`lc_stg2_23'`lc_stg2_24'`lc_stg2_25'`lc_stg2_26'`lc_stg2_27'`lc_stg2_28'`lc_stg2_29'`lc_stg2_30' ///
			`lc_stg3_1'`lc_stg3_2'`lc_stg3_3'`lc_stg3_4'`lc_stg3_5'`lc_stg3_6'`lc_stg3_7'`lc_stg3_8'`lc_stg3_9'`lc_stg3_10' ///
			`lc_stg3_11'`lc_stg3_12'`lc_stg3_13'`lc_stg3_14'`lc_stg3_15'`lc_stg3_16'`lc_stg3_17'`lc_stg3_18'`lc_stg3_19'`lc_stg3_20' ///
			`lc_stg3_21'`lc_stg3_22'`lc_stg3_23'`lc_stg3_24'`lc_stg3_25'`lc_stg3_26'`lc_stg3_27'`lc_stg3_28'`lc_stg3_29'`lc_stg3_30' ///
			`lc_stg4_1'`lc_stg4_2'`lc_stg4_3'`lc_stg4_4'`lc_stg4_5'`lc_stg4_6'`lc_stg4_7'`lc_stg4_8'`lc_stg4_9'`lc_stg4_10' ///
			`lc_stg4_11'`lc_stg4_12'`lc_stg4_13'`lc_stg4_14'`lc_stg4_15'`lc_stg4_16'`lc_stg4_17'`lc_stg4_18'`lc_stg4_19'`lc_stg4_20' ///
			`lc_stg4_21'`lc_stg4_22'`lc_stg4_23'`lc_stg4_24'`lc_stg4_25'`lc_stg4_26'`lc_stg4_27'`lc_stg4_28'`lc_stg4_29'`lc_stg4_30' ///
			`lc_stg5_1'`lc_stg5_2'`lc_stg5_3'`lc_stg5_4'`lc_stg5_5'`lc_stg5_6'`lc_stg5_7'`lc_stg5_8'`lc_stg5_9'`lc_stg5_10' ///
			`lc_stg5_11'`lc_stg5_12'`lc_stg5_13'`lc_stg5_14'`lc_stg5_15'`lc_stg5_16'`lc_stg5_17'`lc_stg5_18'`lc_stg5_19'`lc_stg5_20' ///
			`lc_stg5_21'`lc_stg5_22'`lc_stg5_23'`lc_stg5_24'`lc_stg5_25'`lc_stg5_26'`lc_stg5_27'`lc_stg5_28'`lc_stg5_29'`lc_stg5_30' ///
			`lc_stg6_1'`lc_stg6_2'`lc_stg6_3'`lc_stg6_4'`lc_stg6_5'`lc_stg6_6'`lc_stg6_7'`lc_stg6_8'`lc_stg6_9'`lc_stg6_10' ///
			`lc_stg6_11'`lc_stg6_12'`lc_stg6_13'`lc_stg6_14'`lc_stg6_15'`lc_stg6_16'`lc_stg6_17'`lc_stg6_18'`lc_stg6_19'`lc_stg6_20' ///
			`lc_stg6_21'`lc_stg6_22'`lc_stg6_23'`lc_stg6_24'`lc_stg6_25'`lc_stg6_26'`lc_stg6_27'`lc_stg6_28'`lc_stg6_29'`lc_stg6_30' ///
			`lc_stg7_1'`lc_stg7_2'`lc_stg7_3'`lc_stg7_4'`lc_stg7_5'`lc_stg7_6'`lc_stg7_7'`lc_stg7_8'`lc_stg7_9'`lc_stg7_10' ///
			`lc_stg7_11'`lc_stg7_12'`lc_stg7_13'`lc_stg7_14'`lc_stg7_15'`lc_stg7_16'`lc_stg7_17'`lc_stg7_18'`lc_stg7_19'`lc_stg7_20' ///
			`lc_stg7_21'`lc_stg7_22'`lc_stg7_23'`lc_stg7_24'`lc_stg7_25'`lc_stg7_26'`lc_stg7_27'`lc_stg7_28'`lc_stg7_29'`lc_stg7_30' ///
			`lc_stg8_1'`lc_stg8_2'`lc_stg8_3'`lc_stg8_4'`lc_stg8_5'`lc_stg8_6'`lc_stg8_7'`lc_stg8_8'`lc_stg8_9'`lc_stg8_10' ///
			`lc_stg8_11'`lc_stg8_12'`lc_stg8_13'`lc_stg8_14'`lc_stg8_15'`lc_stg8_16'`lc_stg8_17'`lc_stg8_18'`lc_stg8_19'`lc_stg8_20' ///
			`lc_stg8_21'`lc_stg8_22'`lc_stg8_23'`lc_stg8_24'`lc_stg8_25'`lc_stg8_26'`lc_stg8_27'`lc_stg8_28'`lc_stg8_29'`lc_stg8_30' ///
			`lc_stg9_1'`lc_stg9_2'`lc_stg9_3'`lc_stg9_4'`lc_stg9_5'`lc_stg9_6'`lc_stg9_7'`lc_stg9_8'`lc_stg9_9'`lc_stg9_10' ///
			`lc_stg9_11'`lc_stg9_12'`lc_stg9_13'`lc_stg9_14'`lc_stg9_15'`lc_stg9_16'`lc_stg9_17'`lc_stg9_18'`lc_stg9_19'`lc_stg9_20' ///
			`lc_stg9_21'`lc_stg9_22'`lc_stg9_23'`lc_stg9_24'`lc_stg9_25'`lc_stg9_26'`lc_stg9_27'`lc_stg9_28'`lc_stg9_29'`lc_stg9_30' ///
			`lc_stg10_1'`lc_stg10_2'`lc_stg10_3'`lc_stg10_4'`lc_stg10_5'`lc_stg10_6'`lc_stg10_7'`lc_stg10_8'`lc_stg10_9'`lc_stg10_10' ///
			`lc_stg10_11'`lc_stg10_12'`lc_stg10_13'`lc_stg10_14'`lc_stg10_15'`lc_stg10_16'`lc_stg10_17'`lc_stg10_18'`lc_stg10_19'`lc_stg10_20' ///
			`lc_stg10_21'`lc_stg10_22'`lc_stg10_23'`lc_stg10_24'`lc_stg10_25'`lc_stg10_26'`lc_stg10_27'`lc_stg10_28'`lc_stg10_29'`lc_stg10_30' ///
			, post
		noisily: test `test_stg'
		
		est drop _ae*
	}
end
