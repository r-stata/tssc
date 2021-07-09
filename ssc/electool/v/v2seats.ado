//v2seats program
//electool: Toolkit to analyze electoral data
//net from http://www.ugr.es/~amjaime/stata
//Antonio M. Jaime-Castillo
//University of Granada, Spain
//e-mail: amjaime@ugr.es
//beta version 3.0
//February 2010
//First version September 2006
*! version 3.0 AMJC February 16, 2010

//program definition
  version 9
  capture program drop v2seats
  program define v2seats
  syntax varname [if] [in], [party(varname numeric)] [skip(numlist)] [formula(name)] [maj(string)] [lrm(string)] [seqv(string)] [hav(string)] [first(numlist)] [district(varlist numeric max=5)] [size(varname numeric)] [seats(integer 0)] [dthres(numlist >=0 <=100)] [athres(numlist >=0 <=100)] [rest] [waste] [preserve(varlist numeric max=10)] [stat(name)] [collapse(varlist numeric max=5)] [simulate(numlist >=0 <=100 max=1)] [details] [nooutput] [save(string)]

//starting procedures
  if "`save'"!="" {
     if "`save'"==c(filename) | "`save'.dta"==c(filename) {
        display in red "filename may not have the same name that current dataset"
        exit
     }
  }
  preserve
  local district : list uniq district
  local skip : list uniq skip
  local dthres : list uniq dthres
  local athres : list uniq athres
  local attrib : list uniq preserve
  local ins : list collapse in district
  if `ins'!=1 {
     display in red "variables in collapse() are not found in district()"
     exit
  }
  local ins1 : list varlist in party
  local ins2 : list varlist in district
  local ins3 : list varlist in size
  local ins4 : list varlist in preserve
  if `ins1'==1 | `ins2'==1 | `ins3'==1 | `ins4'==1 {
     display in red "repeated variables are not allowed"
     exit
  }
  local maxsv = 10000
  if c(flavor)=="Small" local maxsv = 1000

//syntax validation
  if "`formula'"=="" & "`maj'"=="" & "`lrm'"=="" & "`seqv'"=="" & "`hav'"=="" {
     display in red "no formula has been selected"
     exit
  }
  if "`formula'"!="" & "`maj'"!="" {
     display in red "formula() and maj() are not compatible"
     exit
  }
  if "`formula'"!="" & "`lrm'"!="" {
     display in red "formula() and lrm() are not compatible"
     exit
  }
  if "`formula'"!="" & "`seqv'"!="" {
     display in red "formula() and seqv() are not compatible"
     exit
  }
  if "`formula'"!="" & "`hav'"!="" {
     display in red "formula() and hav() are not compatible"
     exit
  }
  if "`maj'"!="" & "`lrm'"!="" {
     display in red "maj() and lrm() are not compatible"
     exit
  }
  if "`maj'"!="" & "`seqv'"!="" {
     display in red "maj() and seqv() are not compatible"
     exit
  }
  if "`maj'"!="" & "`hav'"!="" {
     display in red "maj() and hav() are not compatible"
     exit
  }
  if "`lrm'"!="" & "`seqv'"!="" {
     display in red "lrm() and sqv() are not compatible"
     exit
  }
  if "`lrm'"!="" & "`hav'"!="" {
     display in red "lrm() and hav() are not compatible"
     exit
  }
  if "`seqv'"!="" & "`hav'"!="" {
     display in red "seqv() and hav() are not compatible"
     exit
  }
  if "`hav'"=="" & "`first'"!="" {
     display in red "first() is not allowed without hav()"
     exit
  }
  if "`formula'"!="" & "`formula'"!="all" & "`formula'"!="major" & "`formula'"!="plural" & "`formula'"!="oplural" & "`formula'"!="hare" & "`formula'"!="hagb" & "`formula'"!="droop" & "`formula'"!="imp" & "`formula'"!="rimp" & "`formula'"!="dhondt" & "`formula'"!="stlague" & "`formula'"!="stlm" & "`formula'"!="stlh" & "`formula'"!="danish" & "`formula'"!="dimp" & "`formula'"!="hunt" & "`formula'"!="adams" & "`formula'"!="hare_h" & "`formula'"!="hagb_h" & "`formula'"!="droop_h" & "`formula'"!="imp_h" & "`formula'"!="rimp_h" {
     display in red "`formula' is not a recognised formula"
     exit
  }
  if `seats'>0 & "`size'"!="" {
     display in red "seats() and size() are not compatible"
     exit
  }
  if "`district'"=="" & "`size'"!="" {
     display in red "district() is required with size()"
     exit
  }
  if "`size'"=="" & `seats'<=0 {
     display in red "either size() or seats() are required"
     exit
  }
  if "`simulate'"=="" local simulate=0
  if `simulate'>0 {
     if "`formula'"=="all" {
        display in red "formula(all) and simulate() are not compatible"
        exit
     }
     if "`attrib'"!="" {
        display in red "preserve() and simulate() are not compatible"
        exit
     }
     if "`collapse'"!="" {
        display in red "collapse() and simulate() are not compatible"
        exit
     }
     if "`formula'"=="" {
        display in red "simulate is not allowed for customized methods"
        exit
     }
  }
  if "`formula'"=="all" & "`save'"=="" {
     display in red "save() is required with formula(all)"
     exit
  }
  if "`formula'"=="all" & "`attrib'"!="" {
     display in red "formula(all) and preserve() are not compatible"
     exit
  }
  if "`formula'"=="all" & "`collapse'"!="" {
     display in red "formula(all) and collapse() are not compatible"
     exit
  }
  if `simulate'>0 & "`save'"=="" {
     display in red "save() is required with simulate()"
     exit
  }
  if "`attrib'"!="" & "`save'"=="" {
     display in red "save() is required with preserve()"
     exit
  }
  if "`collapse'"!="" {
     if "`save'"=="" {
        display in red "save() is required with collapse()"
        exit
     }
     if "`details'"!="" {
        display in yellow "warning: details has no effect with collapse()"
        macro drop _details
     }
  }
  if "`attrib'"=="" & "`stat'"!="" {
     display in red "preserve() is required with stat()"
     exit
  }
  if "`stat'"=="" {
     local stat "mean"
  }
  if "`rest'"!="" & "`save'"=="" {
     display in red "save() is required with rest()"
     exit
  }
  if "`waste'"=="waste" & "`save'"=="" {
     display in red "save() is required with waste"
     exit
  }
  if "`stat'"!="" & "`stat'"!="min" & "`stat'"!="max" & "`stat'"!="mean" & "`stat'"!="median" & "`stat'"!="sum" {
     display in red "stat(`stat') is not recognised"
     exit
  }
  if "`formula'"=="plural" | "`formula'"=="dhondt" | "`formula'"=="stlague" | "`formula'"=="stlm" | "`formula'"=="stlh" | "`formula'"=="danish" | "`formula'"=="dimp" | "`formula'"=="hunt" | "`formula'"=="adams" | "`formula'"=="hare_h" | "`formula'"=="hagb_h" | "`formula'"=="droop_h" | "`formula'"=="imp_h" | "`formula'"=="rimp_h" {
     if "`rest'"!="" {
        display in red "rest is not allowed for this formula"
        exit
     }
  }

//setting formulas
  if "`maj'"!="" {
     local formula = "persmeth"
     local fname = "personalized majority"
  }
  if "`lrm'"!="" {
     local formula = "persmeth"
     local fname = "personalized largest remainder"
  }
  if "`seqv'"!="" {
     local formula = "persmeth"
     local fname = "personalized divisors sequence"
     confirm matrix `seqv'
  }
  if "`hav'"!="" {
     local formula = "persmeth"
     local fname = "personalized highest average"
  }
  if "`formula'"=="major" {
     local maj = "v/2"
     local fname = "majority"
  }
  if "`formula'"=="plural" local fname = "FPTP"
  if "`formula'"=="oplural" local fname = "ordered plurality"
  if "`formula'"=="hare" | "`formula'"=="hare_h" {
     local lrm = "v/s"
     local fname = "Hare quota"
  }
  if "`formula'"=="hagb" | "`formula'"=="hagb_h" {
     local lrm = "v/(s+1)"
     local fname = "Hagenbach-Bischoff quota"
  }
  if "`formula'"=="droop" | "`formula'"=="droop_h" {
     local lrm = "int((v/(s+1))+1)"
     local fname = "Droop quota"
  }
  if "`formula'"=="imp" | "`formula'"=="imp_h" {
     local lrm = "v/(s+2)"
     local fname = "Imperiali quota"
  }
  if "`formula'"=="rimp" | "`formula'"=="rimp_h" {
     local lrm = "v/(s+3)"
     local fname = "reinforced Imperiali quota"
  }
  if "`formula'"=="dhondt" {
     local hav = "n"
     local fname = "D'Hondt"
  }
  if "`formula'"=="stlague" {
     local hav = "2*n-1"
     local fname = "St. Lagüe"
  }
  if "`formula'"=="stlm" {
     local hav = "2*n-1"
     local first = 1.4
     local fname = "modified St. Lagüe method"
  }
  if "`formula'"=="stlh" {
     local hav = "2*n-1"
     local first = 1.5
     local fname = "Hungarian St. Lagüe"
  }
  if "`formula'"=="danish" {
     local hav = "3*n-2"
     local fname = "Danish method"
  }
  if "`formula'"=="dimp" {
     local hav = "(n+1)/2"
     local fname = "Imperiali divisors"
  }
  if "`formula'"=="hunt" {
     local hav = "sqrt(n*(n-1))"
     local fname = "Huntington method"
  }
  if "`formula'"=="adams" {
     local hav = "n-1"
     local fname = "Adams method"
  }

//program execution
  nobreak {

	//managing thresholds
	  local dtl : list sizeof dthres
	  local atl : list sizeof athres
	  local ctl = `dtl'*`atl'
	  if `dtl'==0 local dthres=0
	  if `atl'==0 local athres=0
	  if `ctl'==0 local ctl = max(`dtl',`atl')
	  if `dtl'>1 | `atl'>1 {
	     if "`save'"=="" {
		display in red "save() is required with multiple thresholds"
		exit
	     }
	     if `simulate'>0 {
		display in red "multiple thresholds and simulate() are not compatible"
		exit
	     }
	     if "`attrib'"!="" {
		display in red "multiple thresholds and preserve() are not compatible"
		exit
	     }
	     if "`collapse'"!="" {
		display in red "multiple thresholds and collapse() are not compatible"
		exit
	     }
	     if "`formula'"=="persmeth" {
		display in red "multiple thresholds are not allowed for customized methods"
		exit
	     }
	  }

	//selecting cases
	  capture if "`in'"!="" keep `in'
	  capture if "`if'"!="" keep `if'

	//setting district and size
	  if "`district'"=="" {
	     tempvar adist
	     capture generate `adist' = 1
	     local district "`adist'"
	  }
	  if "`size'"=="" {
	     tempvar asize
	     capture generate `asize' = `seats'
	     local size "`asize'"
	     local seats = 0
	  }

	//generating variables
	  sort `district'
	  tempvar minsize
	  capture by `district': egen `minsize'=min(`size')
	  capture replace `size'=`minsize'
	  sort `district' `varlist'
	  local m = 1
	  foreach var in `attrib' {
		  tempvar att`m'
		  capture by `district' `varlist': egen `att`m''=`stat'(`var')
		  capture replace `var'=`att`m''
		  local m = `m'+1
	  }

	//contracting extended datasets
	  if "`party'"=="" {
	     tempvar vote
	     contract `district' `size' `varlist' `attrib', freq(`vote') nomiss
	     local party "`varlist'"
	     local varlist "`vote'"
	  }
	  collapse (sum) `varlist', by(`district' `size' `attrib' `party') cw

	//checking dataset
	  quietly summarize `varlist'
	  if r(min)<0 {
	     display in red "the number of votes must be positive"
	     display in red "allocation cannot continue"
	     use "`fn'", clear
	     exit
	  }
	  local m = 1
	  foreach var in `district' {
		  quietly summarize `var'
		  local mval`m'=r(max)
		  if `mval`m''>`maxsv' {
		     display in red "too many values for variables in district()"
		     display in red "allocation cannot continue"
		     use "`fn'", clear
		     exit
		  }
		  local m = `m'+1
	  }
	  quietly summarize `party'
	  local nval=r(max)
	  if `nval'>`maxsv' {
	       display in red "too many values for variable party"
	       display in red "allocation cannot continue"
	       use "`fn'", clear
	       exit
	  }

	//rearranging dataset
	  local n = 1
	  foreach var in `district' {
		  tempvar distnt`n'
		  capture egen `distnt`n'' = group(`var'), lname(distl`n')
		  label variable `distnt`n'' "district level `n'"
		  local distlst = "`distlst'" + " " + "`distnt`n''"
		  local i : list posof "`var'" in collapse
		  if `i' > 0 {
		  local collst = "`collst'" + " " + "`distnt`n''"
		  }
		  local n = `n'+1
	  }
	  tempvar sizent
	  capture generate `sizent' = `size'
	  tempvar partnt
	  capture egen `partnt' = group(`party'), lname(party)
	  tempvar varlnt
	  capture generate `varlnt' = `varlist'
	  local m = 1
	  foreach var in `attrib' {
		  tempvar att`m'
		  capture generate `att`m'' = `var'
		  local atlstk = "`atlstk'" + " " + "`att`m''"
		  local m = `m'+1
	  }
	  label variable `sizent' "size"
	  label variable `partnt' "political list"
	  label variable `varlnt' "vote"
	  keep `distlst' `sizent' `partnt' `varlnt' `atlstk'
	  local m = 1
	  foreach var in `distlst' {
		  rename `var' distl`m'
		  local disttol = "`disttol'" + " " + "distl`m'"
		  local i : list posof "`var'" in collst
		  if `i' > 0 {
		  local collst2 = "`collst2'" + " " + "distl`m'"
		  }
		  local m = `m'+1
	  }
	  local district "`disttol'"
	  local collapse "`collst2'"
	  rename `sizent' size
	  rename `partnt' party
	  rename `varlnt' vote
	  local m = 1
	  foreach var in `attrib' {
		  capture rename `att`m'' _`var'
		  label variable _`var' "`var' (`stat')"
		  label value _`var' `var'
		  local atlst = "`atlst'" + " " + "_`var'"
		  local m = `m'+1
	  }
	  local district = "`disttol'"
	  local size = "size"
	  local party = "party"
	  local varlist = "vote"
	  local attrib = "`atlst'"

	//computing system limits
	  capture egen idt=group(`district' party)
	  quietly summarize idt
	  local maxp = r(max)
	  local distdisp = 1
	  capture egen idg=group(`district')
	  quietly summarize idg
	  if r(min)==r(max) local distdisp = 0
	  drop idg
	  quietly summarize `size'
	  local mins = r(min)
	  local maxs = r(max)
	  if `mins'<=0 {
	     display in red "size is too small for some districts"
	     display in red "allocation cannot continue"
	     use "`fn'", clear
	     exit
	  }
	  if `maxs'+100>c(matsize) {
	     display in red "matsize too small"
	     display in red "allocation cannot continue"
	     use "`fn'", clear
	     exit
	  }
	  if `maxs'*`maxp'*1000>c(memory) {
	     display in red "memory is insufficient"
	     display in red "allocation cannot continue"
	     use "`fn'", clear
	     exit
	  }

	//multiple thresholds
	  if `dtl'>1 | `atl'>1 {
	     local mdthres : list sort dthres
	     local mathres : list sort athres
	     if "`rest'"!="" display in yellow "warning: rest has no effect with multiple thresholds"
	     if "`waste'"=="waste" display in yellow "warning: waste has no effect with multiple thresholds"
	     if "`details'"=="details" display in yellow "warning: details has no effect with multiple thresholds"
	     local m = 1
	     foreach numdt of local mdthres {
		     foreach numat of local mathres {
			     tempfile fnft`m'
			     v2seats `varlist', party(`party') skip(`skip') formula("`formula'") district(`district') size(`size') dthres(`numdt') athres(`numat') nooutput save("`fnft`m''")
			     local m = `m'+1
		     }
	     }
	     local m = 0
	     local n = `ctl'
	     while `n'>=1 {
		   capture confirm file "`fnft`n''"
		   if !_rc local m = `n'
		   local n = `n'-1
	     }
	     if `m'!=0 {
		use "`fnft`m''", clear
		local n = `m'+1
		while `n'<=`ctl' {
		      capture confirm file "`fnft`n''"
		      if !_rc {
			 capture append using "`fnft`n''"
		      }
		      local n = `n'+1
		}
		gsort athres dthres `district' -vote
		capture save "`save'", replace
	     }
	     restore
	     exit
	  }

	//setting thresholds
	  capture generate dthres = `dthres'
	  capture generate athres = `athres'
	  label variable dthres "district threshold"
	  label variable athres "aggregate threshold"
	  order `district' size athres dthres `attrib' party vote idt
	  quietly summarize `varlist'
	  local tvote = r(sum)
	  sort `district'
	  capture by `district': egen tdvote = sum(`varlist')
	  capture generate ltlyn = 1
	  capture replace ltlyn = 0 if ((`varlist'/tdvote)*100)<dthres
	  drop tdvote
	  sort party
	  capture by party: egen tpvote = sum(`varlist')
	  capture generate ntlyn = 1
	  capture replace ntlyn = 0 if ((tpvote/`tvote')*100)<athres
	  drop tpvote
	  sort `district'
          capture generate lvote = `varlist'
          capture replace lvote = 0 if ltlyn==0 | ntlyn==0
          foreach skval in `skip' {
                  capture replace lvote = 0 if party==`skval'
          }
	  capture by `district': egen vvalid = sum(lvote)
	  quietly summarize vvalid
	  local vtest = r(min)
	  if `vtest'<=0 {
	     display in red "valid votes are too low for some districts"
	     display in red "allocation cannot continue"
	     restore
	     exit
	  }
	  drop vvalid

	//setting formula all
	  if "`formula'"=="all" {
	     if "`rest'"!="" display in yellow "warning: rest has no effect with formula(all)"
	     if "`waste'"=="waste" display in yellow "warning: option waste has no effect with formula(all)"
	     if "`details'"=="details" display in yellow "warning: option details has no effect with formula(all)"
	     local formlst "major plural oplural hare hagb droop imp rimp dhondt stlague stlm stlh danish dimp"
	     tokenize `formlst'
	     local m = 1
	     foreach form of local formlst {
		   tempfile fnf`m'
		   v2seats `varlist', party(`party') skip(`skip') formula("`form'") district(`district') size(`size') dthres(`dthres') athres(`athres') nooutput save("`fnf`m''")
		   local m = `m'+1
	     }
	     local m = 0
	     local n = 14
	     while `n'>=1 {
		   capture confirm file "`fnf`n''"
		   if !_rc local m = `n'
		   local n = `n'-1
	     }
	     if `m'!=0 {
		use "`fnf`m''", clear
		local n = `m'+1
		while `n'<=14 {
		      local forml ``n''
		      capture confirm file "`fnf`n''"
		      if !_rc {
			 capture merge `district' `party' using "`fnf`n''", keep(`forml') sort
			 drop _merge
		      }
		      local n = `n'+1
		}
             gsort `district' -vote
	     capture save "`save'", replace
	     }
	     restore
	     exit
	  }

	//simulating vote
	  if `simulate'>0 {
	     if "`rest'"!="" display in yellow "warning: rest has no effect with simulate()"
	     if "`waste'"=="waste" display in yellow "warning: option waste has no effect with simulate()"
	     if "`details'"=="details" display in yellow "warning: option details has no effect with simulate()"
	     tempfile fnfsf
	     v2seats `varlist', party(`party') skip(`skip') formula("`formula'") district(`district') size(`size') dthres(`dthres') athres(`athres') nooutput save("`fnfsf'")
	     capture confirm file "`fnfsf'"
	     if _rc {
		restore
		exit
	     }
	     local n = 1
	     while `n'<=100 {
		   tempfile fnfs`n'
		   capture generate svote=`varlist'+(`varlist'*invnormal(uniform())*`simulate'/100)
		   capture replace svote=0 if svote<0
		   v2seats svote, party(`party') skip(`skip') formula("`formula'") district(`district') size(`size') dthres(`dthres') athres(`athres') nooutput save("`fnfs`n''")
		   drop svote
		   local n = `n'+1
	     }
	     local n = 1
	     while `n'<=100 {
		   capture confirm file "`fnfs`n''"
		   if !_rc {
		      use "`fnfs`n''", clear
		      rename `formula' `formula'`n'
		      capture save, replace
		   }
		   local n = `n'+1
	     }
	     capture confirm file "`fnfsf'"
	     if !_rc {
		use "`fnfsf'", clear
		local n = 1
		while `n'<=100 {
		      capture confirm file "`fnfs`n''"
		      if !_rc {
			 capture merge `district' `party' using "`fnfs`n''", keep(`formula'`n') sort
			 drop _merge
			 local m = `n'
		      }
		      local n = `n'+1
		}
		capture egen min=rowmin(`formula'*)
		capture egen max=rowmax(`formula'*)
		capture egen avg=rowmean(`formula'*)
		label variable min "minimum seats"
		label variable max "maximum seats"
		label variable avg "average seats"
		rename `formula' tempform
		drop `formula'*
		rename tempform `formula'
		gsort `district' -vote
		capture save "`save'", replace
	     }
	     restore
	     exit
	  }

	//majority and plurality methods
	  if "`formula'"=="plural" | "`formula'"=="oplural" | "`maj'"!="" {

           //computing number of seats
	     sort `district'
	     capture by `district': egen v = sum(lvote)
	     capture by `district': egen fptp = max(lvote)
	     capture by `district': egen orun = rank(lvote), unique
	     capture by `district': egen mxorun = max(orun)
	     capture by `district': egen orunalt = rank(lvote), track
	     capture generate ties = abs(orun-orunalt)
	     quietly summarize ties
	     if r(max) > 0 {
	        display in yellow "warning: ties found using `fname'"
	        display in yellow "ties have been randomly broken"
	     }
	     drop orunalt ties
	     capture generate `formula'=0
	     label variable `formula' "number of seats using `fname'"
	     if "`maj'"!="" {
		capture generate reqm = `maj'
		if _rc!=0 {
		   display in red "`maj' is not a valid formula"
		   exit
	        }
		capture replace `formula' = size if lvote >= reqm & lvote > 0
		drop reqm
	     }
	     if "`formula'"=="plural" {
		capture replace `formula' = size if orun == mxorun & lvote > 0
	     }
	     if "`formula'"=="oplural" {
		capture replace `formula' = 1 if orun > mxorun-size & lvote > 0
	     }
	     capture by `district': egen tfseats = sum(`formula')
	     capture generate notas = size-tfseats
	     quietly summarize notas
	     if r(min)<0 {
		display in yellow "warning: inconsistent allocation using `fname'"
		display in yellow "seats exceed district size for some districts"
	     }
	     drop tfseats notas
	     capture generate rest = 0
	     capture by `district': egen asig = sum(`formula')
	     capture replace rest = size-asig
	     label variable rest "not allocated seats at district level"
	     capture generate waste=0
	     capture replace waste=vote if `formula'==0
	     label variable waste "wasted votes"
	     drop idt ltlyn ntlyn lvote v fptp orun mxorun asig
	     order `district' size rest athres dthres `attrib' party vote `formula' waste

	   //displaying details (if requested)
	     if "`details'"=="details" & "`output'"!="nooutput" {
		list `district' party vote `formula', sepby(`district') noobs
	     }

	   //displaying output (if requested)
	     if "`output'"!="nooutput" {
		if `seats'==0 & `distdisp'==1 {
		   sort `district'
		   by `district': table party if `formula'>0, contents(sum `formula')
		}
		quietly summarize `formula'
		local tseats = r(sum)
		if `tseats'> 0{
		   display
		   display in green "total seats"
		   table party if `formula'>0, contents(sum `formula')
		}
		else {
		     display
		     display in green "total seats"
		     display in green "no observations"
		}
	     }
	     gsort `district' -vote

	   //saving file (if requested)
	     if "`save'"!="" {
		if "`collapse'"!="" {
		   capture egen dtid=tag(`district')
		   capture replace rest=. if dtid==0
		   capture replace size=. if dtid==0
		   if "`attrib'"==""{
		      collapse (sum) size vote `formula' waste rest, by(`collapse' party)
		      order `collapse' size party
		   }
		   else {
			collapse (`stat') "`attrib'" (sum) size vote `formula' waste rest, by(`collapse' party)
			order `collapse' size party
		   }
		   sort `collapse'
		   capture by `collapse': egen tcrest=sum(rest)
		   capture replace rest=tcrest
		   capture by `collapse': egen tcsize=sum(size)
		   capture replace size=tcsize
		   drop tcrest tcsize
		   gsort `collapse' -vote
		}
		if "`rest'"=="" {
		   drop rest
		}
		if "`waste'"=="" {
		   drop waste
		}
		capture save "`save'", replace
	     }

	   //restoring original file
	     restore
	     exit
	  }

	//largest remainder formulas
	  if "`lrm'"!="" {

	   //computing number of seats
	     sort `district'
	     capture by `district': egen v = sum(lvote)
	     capture generate s = size
	     capture generate quota = `lrm'
	     if _rc!=0 {
	        display in red "`lrm' is not a valid formula"
	        exit
	     }
	     label variable quota "quota"
	     capture generate div = (lvote/quota)
	     label variable div "vote/quota"
	     capture by `district': egen orun = rank(div), unique
	     capture by `district': egen orunalt = rank(div), track
	     capture generate ties = abs(orun-orunalt)
	     quietly summarize ties
	     if r(max) > 0 {
	        display in yellow "warning: ties found using `fname'"
	        display in yellow "ties have been randomly broken"
	     }
	     drop s orun orunalt ties
	     capture generate fseats = int(div)
	     capture generate rests = div-fseats
	     if "`formula'"=="hare_h" | "`formula'"=="hagb_h" | "`formula'"=="droop_h" | "`formula'"=="imp_h" | "`formula'"=="rimp_h" {
		capture replace rests = (div-fseats)/(fseats+1)
	     }
	     capture by `district': egen tfseats = sum(fseats)
	     capture generate notas = size-tfseats
	     quietly summarize notas
	     if r(min)<0 {
		display in yellow "warning: inconsistent allocation using `fname'"
		display in yellow "seats exceed district size for some districts"
	     }
	     capture by `district': egen rvrest = rank(rests), unique
	     capture by `district': egen mrvrest = max(rvrest)
	     capture generate add=0
	     if "`rest'"=="" {
		capture replace add=1 if rvrest>mrvrest-notas
	     }
	     capture generate `formula' = fseats + add
	     label variable `formula' "number of seats using `fname'"
	     capture generate rest = notas
	     label variable rest "not allocated seats at district level"
	     capture generate waste=0
	     capture replace waste=round(vote-(`formula'*quota))
	     capture replace waste=0 if waste=<0
	     label variable waste "wasted votes"
	     drop idt ltlyn ntlyn lvote v fseats rests tfseats notas rvrest mrvrest add
	     order `district' size rest athres dthres `attrib' party vote `formula' waste

	   //displaying details (if requested)
	     if "`details'"=="details" & "`output'"!="nooutput" {
		list `district' party vote `formula' quota div, sepby(`district') noobs
	     }
	     if "`details'"!="details" {
		drop quota div
	     }

	   //displaying output (if requested)
	     if "`output'"!="nooutput" {
		if `seats'==0 & `distdisp'==1 {
		   sort `district'
		   by `district': table party if `formula'>0, contents(sum `formula')
		}
		quietly summarize `formula'
		local tseats = r(sum)
		if `tseats'> 0{
		   display
		   display in green "total seats"
		   table party if `formula'>0, contents(sum `formula')
		}
		else {
		     display
		     display in green "total seats"
		     display in green "no observations"
		}
	     }
	     gsort `district' -vote

	   //saving file (if requested)
	     if "`save'"!="" {
		if "`collapse'"!="" {
		   capture egen dtid=tag(`district')
		   capture replace rest=. if dtid==0
		   capture replace size=. if dtid==0
		   if "`attrib'"==""{
		      collapse (sum) size vote `formula' waste rest, by(`collapse' party)
		      order `collapse' size party
		   }
		   else {
			collapse (`stat') "`attrib'" (sum) size vote `formula' waste rest, by(`collapse' party)
			order `collapse' size party
		   }
		   sort `collapse'
		   capture by `collapse': egen tcrest=sum(rest)
		   capture replace rest=tcrest
		   capture by `collapse': egen tcsize=sum(size)
		   capture replace size=tcsize
		   drop tcrest tcsize
		   gsort `collapse' -vote
		}
		if "`rest'"=="" {
		   drop rest
		}
		if "`waste'"=="" {
		   drop waste
		}
		capture save "`save'", replace
	     }

	   //restoring original file
	     restore
	     exit
	  }

	//highest average formulas
	  if "`hav'"!="" | "`seqv'"!="" {

	//setting divisors
	     if "`hav'"!="" {
	        local nd=1
	        tempvar gendiv
	        capture generate n=`nd' in f
	        capture generate `gendiv' = `hav' in f
	        if _rc!=0 {
	           display in red "`hav' is not a valid formula"
	           exit
	        }
	        local mdiv = `gendiv' in f
	        matrix div = `mdiv'
	        while `nd'<=`maxs' {
	              local nd = `nd'+1
	              capture replace n=`nd' in f
	              capture replace `gendiv' = `hav' in f
	              local mdiv = `gendiv' in f
	              matrix div = div \ `mdiv'
	        }
	        drop n `gendiv'
	        local n = 1
	        capture {
	                foreach numseq of numlist `first' {
		                if `n' <= rowsof(div) matrix div[`n',1] = `numseq'
		                local n = `n' +1
	                }
	        }
	     }
	     if "`seqv'"!="" {
	        if rowsof(`seqv') < `maxs' {
	           display in red "`seqv' has not enough divisors"
	           exit
	        }
	        matrix div = `seqv'
	     }

	//computing number of seats
	     local n = 1
	     while `n'<=`maxs' {
		   capture generate div`n' = lvote/div[`n',1]
		   capture replace div`n' = 1.0e+30 if div[`n',1] == 0 & ntlyn == 1 & ltlyn == 1
	           local n = `n' +1
	     }
	     reshape i `district' party
	     reshape j new
	     reshape xij div
	     capture reshape long
	     sort `district'
	     capture by `district': egen rvdiv = rank(div), unique
	     capture by `district': egen mrvdiv = max(rvdiv)
	     capture by `district': egen rvdivalt = rank(div), track
	     capture generate ties = abs(rvdiv-rvdivalt)
	     quietly summarize ties if rvdiv>mrvdiv-size
	     if r(max) > 0 {
	        display in yellow "warning: ties found using `fname'"
	        display in yellow "ties have been randomly broken"
	     }
	     drop rvdivalt ties
	     capture generate asig = 0
	     capture replace asig = 1 if rvdiv>mrvdiv-size & rvdiv!=.
	     sort idt
	     capture by idt: egen `formula' = sum(asig)
	     label variable `formula' "number of seats using `fname'"
	     drop idt ltlyn ntlyn lvote rvdiv mrvdiv asig
	     capture reshape wide
	     capture generate waste=0
	     capture replace waste=vote if `formula'==0
	     label variable waste "wasted votes"
	     order `district' size athres dthres `attrib' party vote `formula' waste

	   //displaying details (if requested)
	     if "`details'"=="details" & "`output'"!="nooutput" {
		list `district' party vote `formula' div*, sepby(`district') noobs
	     }
	     if "`details'"!="details" {
		drop div*
	     }

	   //displaying output (if requested)
	     if "`output'"!="nooutput" {
		if `seats'==0 & `distdisp'==1 {
		   sort `district'
		   by `district': table party if `formula'>0, contents(sum `formula')
		}
		quietly summarize `formula'
		local tseats = r(sum)
		if `tseats'> 0{
		   display
		   display in green "total seats"
		   table party if `formula'>0, contents(sum `formula')
		}
		else {
		     display
		     display in green "total seats"
		     display in green "no observations"
		}
	     }
	     gsort `district' -vote

	   //saving file (if requested)
	     if "`save'"!="" {
		if "`collapse'"!="" {
		   capture egen dtid=tag(`district')
		   capture replace size=. if dtid==0
		   if "`attrib'"==""{
		      collapse (sum) size vote `formula' waste, by(`collapse' party)
		      order `collapse' size party
		   }
		   else {
			collapse (`stat') "`attrib'" (sum) size vote `formula' waste, by(`collapse' party)
			order `collapse' size party
		   }
		   sort `collapse'
		   capture by `collapse': egen tcsize=sum(size)
		   capture replace size=tcsize
		   drop tcsize
		   gsort `collapse' -vote
		}
		if "`waste'"=="" {
		   drop waste
		}
		capture save "`save'", replace
	     }

	   //restoring original file
	     restore
	     exit
	  }
  }

  end

//the program ends
