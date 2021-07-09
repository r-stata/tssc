*! version 1.0  08feb2017  Cong Ye
capture program drop rsz
program define rsz
	version 12.0
	syntax [if] [in], strsamsize(name) replicates(string) ranseed(string) [alt(string) strata(varlist) sorting(varlist) consorting(varlist) serp(string) mos(name) exprr(string) inflatedsamsize(string) desiredinitial(string) extra(string) restore(string) ]
		di " "
	qui {
		foreach v in _rszorder _rszpartial _stratagroup _dupstr _strtotal _rszstrsize _rszcomplete _originaltotal _rsztotal _perzone _maxvals _minvals ///
			_tempran _dupzone _dupgroup _zonetotal _runtotal _grouptotal _temp {
			tempvar `v'
		}
		foreach v in _rszgroup _rszzone _rszreplicate _rszweight _srsweight _sysweight _98rsz* {
			capture drop `v'
			if _rc==0 noi {
				di as text "{it:Warning: variable `v' in the input data was overwritten. Rename it to avoid being overwritten.}"
			}
		}

		set more off
		local alt=lower("`alt'")
		local serp=upper("`serp'")
		local inflatedsamsize=upper("`inflatedsamsize'")
		local restore=upper("`restore'")

		gen `_rszorder'=_n

		gen `_rszpartial'=1 `if' `in'
			replace `_rszpartial'=. if `strsamsize'==.
			
		gen `_tempran'=uniform() if `_rszpartial'==1
		
		egen `_stratagroup'=group(`strata') if `_rszpartial'==1
			sort `_stratagroup' `sorting' `consorting' `_tempran'
			by `_stratagroup': gen `_dupstr'=cond(_N==1,1,_n) if `_rszpartial'==1
			by `_stratagroup': egen `_strtotal'=max(`_dupstr') if `_rszpartial'==1
		
		if "`inflatedsamsize'"=="Y" & "`exprr'"=="" noi {
			di as error "Error: exprr must be supplied if inflatedsamsize is 'Y'."
			sort `_rszorder'
			exit
			}
			
		if "`exprr'"=="" {
			local exprr=1
			}
			
		if "`inflatedsamsize'"=="Y" {
				gen `_rszstrsize'=`strsamsize' if `_rszpartial'==1
				gen `_rszcomplete'=round(`strsamsize'*(1-(1-`exprr')^`replicates'),1) if `_rszpartial'==1
			}
			else {
				gen `_rszstrsize'=round(`strsamsize'/(1-(1-`exprr')^`replicates'),1) if `_rszpartial'==1
				gen `_rszcomplete'=`strsamsize' if `_rszpartial'==1
			}
			
		set seed `ranseed'
			
		if "`alt'"~="srs" & "`alt'"~="sys" {
			egen `_rsztotal'=sum(`_rszstrsize') if `_rszpartial'==1 & `_dupstr'==1
			egen `_originaltotal'=sum(`strsamsize') if `_rszpartial'==1 & `_dupstr'==1
			
			if "`desiredinitial'"~="" {
				set seed `ranseed'		
				local iter=1
				while "`desiredinitial'"~="`actualinitial'" & `iter'<100 {
					local `_temp'=uniform()-0.5
					sum `_originaltotal'
					local originaltotal=r(mean)
					replace `_rszstrsize'=round(`strsamsize'*`desiredinitial'/`originaltotal'+``_temp'',1) if `_rszpartial'==1
					capture drop `_rsztotal'	
					egen `_rsztotal'=sum(`_rszstrsize') if `_rszpartial'==1 & `_dupstr'==1
					sum `_rsztotal'
					local actualinitial=r(mean)
					sum `_rszcomplete' if `_rszpartial'==1 & `_dupstr'==1
					local rszcomplete=r(sum)
					local iter=`iter'+1
					}
					if `iter'>=100 noi {
						dis as text "{it:Warning: actual initial total does not equal to desired initial total.}"
						}
					}
				else {		
					sum `_originaltotal'
					local originaltotal=r(mean)
					sum `_rsztotal'
					local actualinitial=r(mean)
					sum `_rszcomplete' if `_rszpartial'==1 & `_dupstr'==1
					local rszcomplete=r(sum)
					}
			
			sort `_stratagroup' `sorting' `consorting' `_tempran'
			gen _rszgroup=ceil(`_dupstr'/`_strtotal'*`_rszstrsize'-0.0000000001)
			gen `_perzone'=round(2*`_rszstrsize'/`_rszcomplete',1)
			gen _rszzone=ceil(_rszgroup/`_perzone')
			sort `_stratagroup' _rszzone `_tempran'
			by `_stratagroup' _rszzone: egen `_maxvals'=max(_rszgroup) if `_rszpartial'==1
			by `_stratagroup' _rszzone: egen `_minvals'=min(_rszgroup) if `_rszpartial'==1
				replace _rszzone=_rszzone-1 if `_maxvals'-`_minvals'+1<=`_perzone'/2 & `_rszpartial'==1
			
			drop `_maxvals' `_minvals' `_originaltotal' `_rsztotal' `_dupstr' `_strtotal' `_rszcomplete'
			
			sort `_stratagroup' _rszzone `_tempran'
			by `_stratagroup' _rszzone: egen `_maxvals'=max(_rszgroup) if `_rszpartial'==1
			by `_stratagroup' _rszzone: egen `_minvals'=min(_rszgroup) if `_rszpartial'==1
			replace `_perzone'=`_maxvals'-`_minvals'+1 if `_rszpartial'==1
				
			sort `_stratagroup' _rszzone `_tempran'
				by `_stratagroup' _rszzone: gen `_dupzone'=cond(_N==1,1,_n) if `_rszpartial'==1
			by `_stratagroup' _rszzone: egen `_zonetotal'=count(`_rszpartial') if `_rszpartial'==1
			replace _rszgroup=ceil(`_dupzone'/`_zonetotal'*`_perzone'-0.0000000001)
			
			drop `_perzone' `_dupzone' `_zonetotal'
		}		
		if "`extra'"~="" {
			local totreplicates=`replicates'+`extra'
			}
			else {
				local totreplicates=`replicates'
				}
		if "`alt'"=="srs" {
			local _zonegroup_=""
			replace `_rszstrsize'=ceil(`strsamsize'*`totreplicates'/`exprr') if `_rszpartial'==1
			}
		if "`alt'"~="srs" {
			if "`serp'"=="N" {
				local _strsort_="`sorting' `consorting'"
				}
			else if "`sorting'"~="" {
				foreach v of varlist `sorting' {
					tab `v' if `_rszpartial'==1
					if r(r)>100 noi {
						di as text "{it:Warning: sorting variable {bf:`v'} has too many categories. You can define it in the option {it:consorting} instead.}"
					}
					tab `v' if `_rszpartial'==1,gen(_98rsz`v')
				}
				gen `_temp'=0
				foreach v of varlist _98rsz* {
					replace `v'=`v'*(-1) if `_temp'==0 & `_rszpartial'==1
					replace `_temp'=`v'
				}
				local _strsort_="_98rsz* `consorting'"
				}
			else if "`consorting'"~="" {
				local _strsort_="`consorting'"
				}
			if "`alt'"=="sys" {
				local _zonegroup_=""
				replace `_rszstrsize'=ceil(`strsamsize'*`totreplicates'/`exprr') if `_rszpartial'==1
				}
			else {
				local _zonegroup_="_rszzone _rszgroup"
				}
			}

		if "`mos'"=="" {
			local mos=1
		}
		
		set seed `ranseed'
		replace `_tempran'=uniform() if `_rszpartial'==1
		sort `_stratagroup' `_zonegroup_' `_strsort_' `_tempran'
		capture drop `_minvals'
		capture drop `_dupstr'
		by `_stratagroup' `_zonegroup_': gen `_minvals'=_n== 1 if `_rszpartial'==1
		by `_stratagroup' `_zonegroup_': gen `_runtotal'=sum(`mos') if `_rszpartial'==1
		by `_stratagroup' `_zonegroup_': egen `_grouptotal'=max(`_runtotal') if `_rszpartial'==1
		by `_stratagroup' `_zonegroup_': gen `_dupstr'=_n if `_rszpartial'==1
			
		if "`alt'"=="srs" & "`mos'"=="1" {
			gen _rszweight=`_grouptotal'/`mos'/`_rszstrsize' if `_rszstrsize'~=. & `_dupstr'<=`_rszstrsize' & `_rszpartial'==1		
			drop `_dupstr' `_strtotal' `_rszcomplete'	
			}
			
		if "`alt'"=="sys" | ("`alt'"=="srs" & "`mos'"~="1") {
			drop `_dupstr' `_strtotal' `_rszcomplete'	
			gen _rszweight=.
			
			capture drop `_temp'
			egen `_temp'=group(`_stratagroup' `_zonegroup_') if `_rszpartial'==1
			sum `_temp'
			local _strnum_=r(max)
			forvalues _m_=1(1)`_strnum_' {
			
			sum `_rszstrsize' if `_rszpartial'==1 & `_temp'==`_m_'
			local _strmax_=r(max)
			local temp=uniform()
			forvalues k=1(1)`_strmax_' {
				replace _rszweight=1 if (((`_grouptotal'*`temp'/`_rszstrsize'+`_grouptotal'*(`k'-1)/`_rszstrsize')<=`_runtotal' & `_minvals'==1) ///
					| ((`_grouptotal'*`temp'/`_rszstrsize'+`_grouptotal'*(`k'-1)/`_rszstrsize')<=`_runtotal' ///
					& (`_grouptotal'*`temp'/`_rszstrsize'+`_grouptotal'*(`k'-1)/`_rszstrsize')>`_runtotal'[_n-1] & `_minvals'~=1)) & `_rszpartial'==1 & `_temp'==`_m_'
				}
				
				}
			replace _rszweight=`_grouptotal'/`mos'/`_rszstrsize' if _rszweight~=.			
			}
			
		if "`alt'"~="srs" & "`alt'"~="sys" {
			gen _rszreplicate=.
			capture drop `_temp'
			egen `_temp'=group(`_stratagroup' `_zonegroup_') if `_rszpartial'==1
			sum `_temp'
			local _strnum_=r(max)
			forvalues _m_=1(1)`_strnum_' {
			local i=1			
			local temp=uniform()
			replace _rszreplicate=`i' if ((`_grouptotal'*`temp'<=`_runtotal' & `_minvals'==1) ///
				| (`_grouptotal'*`temp'<=`_runtotal' & `_grouptotal'*`temp'>`_runtotal'[_n-1] & `_minvals'~=1)) & `_rszpartial'==1 & `_temp'==`_m_'
			local iter=1
			local min=0
			while `replicates'>1 & `min'<`totreplicates' & `iter'<1000 {
				local i=`i'+1
				local temp=uniform()
				replace _rszreplicate=`i' if _rszreplicate==. & ((`_grouptotal'*`temp'<=`_runtotal' & `_minvals'==1) ///
					| (`_grouptotal'*`temp'<=`_runtotal' & `_grouptotal'*`temp'>`_runtotal'[_n-1] & `_minvals'~=1)) & `_rszpartial'==1 & `_temp'==`_m_'
				
				drop `_maxvals'
				by `_stratagroup' `_zonegroup_': egen `_maxvals'=count(_rszreplicate) if `_rszpartial'==1 & `_temp'==`_m_'
				sum `_maxvals'
				local min=r(min)
				local iter=`iter'+1
				}

				if `iter'>=1000 noi {
					dis as text "{it:Warning: some random groups do not have the desired number of replicates.}"
					}
					
				}

			sort `_stratagroup' `_zonegroup_' _rszreplicate
			by `_stratagroup' `_zonegroup_': gen `_dupgroup'=cond(_N==1,1,_n) if `_rszpartial'==1 & _rszreplicate~=.
			replace `_dupgroup'=. if `_dupgroup'>`totreplicates' & `_dupgroup'~=.
			replace _rszreplicate=`_dupgroup'
			gen _rszweight=`_grouptotal'/`mos' if _rszreplicate~=.
		}

		if "`restore'"~="N" {
			sort `_rszorder'
			}

		foreach v in _98rsz* {
			capture drop `v'
		}
		
		if "`alt'"=="srs" {
			rename _rszweight _srsweight
			local _wt_="srs"			
			}
		if "`alt'"=="sys" {
			rename _rszweight _sysweight
			local _wt_="sys"			
			}		
		if "`alt'"~="srs" & "`alt'"~="sys" {
			local _wt_="rsz"
			}
		sum _`_wt_'weight
		if r(min)<1 {
			di as error "Error: some cases have selection probability lower than 1. They should be selected with"
			di as error _column(5) "certainty and excluded from the input data. Check _`_wt_'weight for details."
			exit
		}
	}
		di " "
		di as text _dup(80) "*"
		di as text "{it:Sampling results: }"
		if "`alt'"~="srs" & "`alt'"~="sys" {
			di as text _column(5) "{it:Cases in each group {bf:_rszgroup} of each zone {bf:_rszzone} in each of your stratum}"
			di as text _column(9) "{it:should be released in sequence as indicated in {bf:_rszreplicate}.}"
			di as text _column(5) "{it:Sampling Weight {bf:_`_wt_'weight} was assigned to each sampled case.}"
			di as text _column(5) "{it:Sample size in the initial replicate: }" as result `actualinitial'
			di as text _column(5) "{it:Sample size in expected completes: }" as result `rszcomplete'
			di as text _column(5) "{it:Sample size as specified: }" as result `originaltotal'
			}
		if "`alt'"=="srs" | "`alt'"=="sys" {
			di as text _column(5) "{it:Sampling Weight {bf:_`_wt_'weight} was assigned to each sampled case.}"
			di as text _column(5) "{it:Sample size drawn: }" as result r(N)
			}
		di as text _column(5) "{it:Number of replicates as specified: }" as result `totreplicates'
		di as text _column(5) "{it:Random seed as specified: }" as result `ranseed'
		if "`strata'"~="" {
			di as text _column(5) "{it:Stratifying variable(s) as specified: }" as result "`strata'"
			}
		if "`sorting'"~="" | "`consorting'"~="" {
			di as text _column(5) "{it:Sorting variable(s) as specified: }" as result "`sorting' `consorting'"
			}
		if "`mos'"~="1" {
			di as text _column(5) "{it:Measure of size as specified: }" as result "`mos'"
			}
		di " "
		di as text _column(5) "{it:Summary of the weight variable {bf:_`_wt_'weight}:}"
		sum _`_wt_'weight
		di " "
		di as text _dup(80) "*"

end
