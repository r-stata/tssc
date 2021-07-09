//electind program
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
  capture program drop electind
  program define electind
  syntax varname [if] [in], [party(varname numeric)] [district(varlist numeric max=5)] [seats(varname numeric)] [polar(varlist numeric max=5)] [time(varname numeric)] [blocks(varname numeric)] [store] [nooutput] [nototal] [save(string)]

//starting procedures
  if "`save'"!="" {
     if "`save'"==c(filename) | "`save'.dta"==c(filename) {
        display in red "filename may not have the same name that current dataset"
        exit
     }
  }
  preserve
  capture confirm new variable `var'
  local district : list uniq district
  local attrib : list uniq polar
  local maxsv = 10000
  if c(flavor)=="Small" local maxsv = 1000
  local stat "mean"
  local size "`seats'"
  local seatpr = 1
  local timepr = 1

//syntax validation
  if "`district'"=="" & "`total'"=="nototal" {
     display in red "nototal is not allowed if district() is empty"
     exit
  }
  if "`time'"=="" & "`blocks'"!="" {
     display in red "time() is required with blocks()"
     exit
  }
  local ins1 : list varlist in party
  local ins2 : list varlist in district
  local ins3 : list varlist in seats
  local ins4 : list varlist in polar
  local ins5 : list varlist in time
  local ins6 : list varlist in blocks
  if `ins1'==1 | `ins2'==1 | `ins3'==1 | `ins4'==1 | `ins5'==1 | `ins6'==1 {
     display in red "repeated variables are not allowed"
     exit
  }
  if "`seats'"!="" {
     local ins7 : list seats in party
     local ins8 : list seats in district
     local ins9 : list seats in polar
     local ins10 : list seats in time
     local ins11 : list seats in blocks
     if `ins7'==1 | `ins8'==1 | `ins9'==1 | `ins10'==1 | `ins11'==1 {
        display in red "repeated variables are not allowed"
        exit
     }
  }

//program execution
  nobreak {
	  if "`store'"!="" {
	     local statvar = "_midgm _merge dtv dtseats tprae tplh tpg tpl tpsl tpml tpadr tpgrf tcs tcsr dprae dplh dpg dpl dpsl dpml dpadr dpgrf dcs dcsr tefrae tekw teenp telc tedb temol defrae dekw deenp delc dedb demol tpfrae tpkw tpenp tplc tpdb tpmol dpfrae dpkw dpenp dplc dpdb dpmol tecon tecomp decon decomp tpcon tpcomp dpcon dpcomp tpolarb tpolard dpolard dpolarb ttev itev btev tdev idev bdev ttpv itpv btpv tdev idev bdev"
	     confirm new variable `statvar'
	     local mertmp = "`time'" + " " + "`district'"
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
	     capture generate `asize' = 0
	     local size "`asize'"
	     local seatpr = 0
	  }

	//setting time and blocks
	  if "`time'"=="" {
	     tempvar atime
	     capture generate `atime' = 1
	     local time "`atime'"
	  }
	  if "`blocks'"=="" {
	     tempvar ablocks
	     capture generate `ablocks' = 1
	     local blocks "`ablocks'"
	  }

	//generating variables
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
	     contract `time' `district' `size' `varlist' `attrib' `blocks', freq(`vote') nomiss
	     local party "`varlist'"
	     local varlist "`vote'"
	  }
	  collapse (sum) `varlist' `size' `attrib' (max) `blocks', by(`time' `district' `party')
	  capture drop if `time' == . | `party' == .

	//checking dataset
	  quietly summarize `varlist'
	  if r(min)<0 {
	     display in red "the number of votes must be positive"
	     display in red "estimation cannot continue"
	     restore
	     exit
	  }
	  quietly summarize `size'
	  if r(min)<0 {
	     display in red "the number of seats must be positive"
	     display in red "estimation cannot continue"
	     restore
	     exit
	  }
	  local m = 1
	  foreach var in `district' {
		  capture drop if `var' == .
		  quietly summarize `var'
		  local mval`m'=r(max)
		  if `mval`m''>`maxsv' {
		     display in red "too many values for variables in district()"
		     display in red "estimation cannot continue"
		     restore
		     exit
		  }
		  local m = `m'+1
	  }
	  quietly summarize `time'
	  local tval=r(max)
	  if `tval'>`maxsv' {
	       display in red "too many values for variable time"
	       display in red "estimation cannot continue"
	       restore
	       exit
	  }
	  quietly summarize `party'
	  local nval=r(max)
	  if `nval'>`maxsv' {
	       display in red "too many values for variable party"
	       display in red "estimation cannot continue"
	       restore
	       exit
	  }
	  quietly summarize `blocks'
	  local bval=r(max)
	  if `bval'>`maxsv' {
	       display in red "too many values for variable blocks"
	       display in red "estimation cannot continue"
	       restore
	       exit
	  }

	//rearranging dataset
	  tempvar timent
	  capture generate `timent' = `time'
	  tempvar blocknt
	  capture egen `blocknt' = group(`blocks'), lname(blocks)
	  local n = 1
	  foreach var in `district' {
		  tempvar distnt`n'
		  capture egen `distnt`n'' = group(`var'), lname(distl`n')
		  label variable `distnt`n'' "district level `n'"
		  local distlst = "`distlst'" + " " + "`distnt`n''"
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
	  label variable `timent' "time"
	  label variable `blocknt' "block"
	  label variable `sizent' "seats"
	  label variable `partnt' "political list"
	  label variable `varlnt' "vote"
	  keep `timent' `distlst' `sizent' `partnt' `varlnt' `atlstk' `blocknt'
	  local m = 1
	  foreach var in `distlst' {
		  rename `var' distl`m'
		  local disttol = "`disttol'" + " " + "distl`m'"
		  local m = `m'+1
	  }
	  local district "`disttol'"
	  rename `timent' time
	  rename `blocknt' blocks
	  rename `sizent' seats
	  rename `partnt' party
	  rename `varlnt' vote
	  local m = 1
	  foreach var in `attrib' {
		  capture rename `att`m'' _`var'
		  label variable _`var' "`var' (`stat')"
		  local atlst = "`atlst'" + " " + "_`var'"
		  local m = `m'+1
	  }
	  local time = "time"
	  local blocks = "blocks"
	  local district = "`disttol'"
	  local seats = "seats"
	  local party = "party"
	  local varlist = "vote"
	  local attrib = "`atlst'"

	//computing system limits
	  capture egen pid = tag(time party)
	  capture egen iptn = group(time party)
	  quietly summarize iptn
	  local maxpt = r(max)
	  if (`maxpt'*2)+100>c(matsize) {
	     display in red "matsize too small"
	     display in red "estimation cannot continue"
	     restore
	     exit
	  }
	  if `maxpt'*1000>c(memory) {
	     display in red "memory is insufficient"
	     display in red "estimation cannot continue"
	     restore
	     exit
	  }
	  capture egen idt = group(time `district' party)
	  quietly summarize idt
	  local maxp = r(max)
	  local distdisp = 1
	  capture egen idg = group(`district')
	  quietly summarize idg
	  if r(min)==r(max) local distdisp = 0
	  drop idg
	  capture egen idgt = group(time)
	  quietly summarize idgt
	  if r(min)==r(max) local timepr = 0
	  capture egen idg = group(`time' `district')
	  sort idg
	  capture by idg: egen dtseats=sum(seats)
	  label variable dtseats "seats"
	  quietly summarize dtseats
	  if r(min)==0 & `seatpr'==1 {
	     display in red "number of seats is not found for some districts"
	     display in red "estimation cannot continue"
	     restore
	     exit
	  }

	//computing volatility
	  if `timepr'==1 {
             quietly summarize blocks
             capture replace blocks = r(max)+1 if block==.
             capture egen min=min(blocks), by(party)
             capture egen max=max(blocks), by(party)
             capture replace blocks = . if block==r(max)+1
             capture generate dif = 0
             capture replace dif = 1 if min!=max
             quietly summarize dif
             capture drop min max dif
	     if r(max)>=1 {
	        display in red "some party/s belong to different blocks"
	        display in red "estimation cannot continue"
	        restore
	        exit
	     }
             capture egen ttv=sum(vote), by(time)
	     capture egen tpv=sum(vote), by(time party)
	     capture generate tv = tpv/ttv
	     capture egen dtv=sum(vote), by(time `district')
	     capture generate dv=vote/dtv
	     if `seatpr'==1 {
	        capture egen tts=sum(seats), by(time)
	        capture egen tps=sum(seats), by(time party)
	        capture generate ts=tps/tts
	        capture egen tds=sum(seats), by(time `district')
	        capture generate ds=seats/tds
	     }
	     quietly tabulate time, matrow(T)
	     local fyear = T[1,1]
	     local tlength = rowsof(T)
	     drop pid iptn idt idgt idg dtseats ttv tpv dtv
	     capture reshape i `district' blocks party
	     capture reshape j `time'
	     if `seatpr'==1 {
	        drop tts tds tps
	        capture reshape xij vote seats tv dv ts ds "`atlst'"
	     }
	     else {
	          capture reshape xij vote seats tv dv "`atlst'"
	     }
	     capture reshape wide
	     capture recode tv* dv* (.=0)
	     if `seatpr'==1 {
	        capture recode ts* ds* (.=0)
	     }
	     capture egen pid = tag(party)
	     capture egen bid = tag(blocks)
	     capture egen bidd = tag(blocks `district')
	     local n = 2
	     while `n'<=`tlength' {
	           local l = T[`n'-1,1]
	           local m = T[`n',1]
	           capture egen newd1 = sum (dv`l'), by(`district')
	           capture egen newd2 = sum (dv`m'), by(`district')
	           capture replace dv`l' = . if newd1 == 0
	           capture replace dv`m' = . if newd2 == 0
	           capture egen nomiss1 = max(tv`l'), by(party)
	           capture egen nomiss2 = max(tv`m'), by(party)
	           capture replace tv`l' = nomiss1
	           capture replace tv`m' = nomiss2
	           drop nomiss*
	           capture generate tievd = tv`m' - tv`l' if pid==1
	           capture egen ttev`m' = sum(abs(tievd))
	           capture replace ttev`m' = (ttev`m'/2)*100
	           capture egen tievb`m' = sum(tievd), by(blocks)
	           capture replace tievb`m' = . if bid==0
	           capture egen tiev`m' = sum(abs(tievb))
	           capture replace tiev`m' = (tiev`m'/2)*100
	           capture generate tbev`m' = ttev`m'-tiev`m'
	           capture generate dievd = dv`m' - dv`l'
	           capture egen dtev`m' = sum(abs(dievd)), by(`district')
	           capture replace dtev`m' = (dtev`m'/2)*100
	           capture egen dievb`m' = sum(dievd), by(`district' blocks)
	           capture replace dievb`m' = . if bidd==0
	           capture egen diev`m' = sum(abs(dievb)), by(`district')
	           capture replace diev`m' = (diev`m'/2)*100
	           capture generate dbev`m' = dtev`m'-diev`m'
	           drop tievd tievb dievd dievb
	           if `seatpr'==1 {
	              capture egen newd1 = sum (ds`l'), by(`district')
	              capture egen newd2 = sum (ds`m'), by(`district')
	              capture replace ds`l' = . if newd1 == 0
	              capture replace ds`m' = . if newd2 == 0
	              drop newd*
	              capture egen nomiss1 = max(ts`l'), by(party)
	              capture egen nomiss2 = max(ts`m'), by(party)
	              capture replace ts`l' = nomiss1
	              capture replace ts`m' = nomiss2
	              drop nomiss*
	              capture generate tipvd = ts`m' - ts`l' if pid==1
	              capture egen ttpv`m' = sum(abs(tipvd))
	              capture replace ttpv`m' = (ttpv`m'/2)*100
	              capture egen tipvb`m' = sum(tipvd), by(blocks)
	              capture replace tipvb`m' = . if bid==0
	              capture egen tipv`m' = sum(abs(tipvb))
	              capture replace tipv`m' = (tipv`m'/2)*100
	              capture generate tbpv`m' = ttpv`m'-tipv`m'
	              capture generate dipvd = ds`m' - ds`l'
	              capture egen dtpv`m' = sum(abs(dipvd)), by(`district')
	              capture replace dtpv`m' = (dtpv`m'/2)*100
	              capture egen dipvb`m' = sum(dipvd), by(`district' blocks)
	              capture replace dipvb`m' = . if bidd==0
	              capture egen dipv`m' = sum(abs(dipvb)), by(`district')
	              capture replace dipv`m' = (dipv`m'/2)*100
	              capture generate dbpv`m' = dtpv`m'-dipv`m'
	              drop tipvd tipvb dipvd dipvb
	           }
	           local n = `n'+1
	     }
	     drop pid bid bidd
	     if `seatpr'==1 {
	        capture reshape xij vote seats tv dv ts ds ttev tiev tbev dtev diev dbev ttpv tipv tbpv dtpv dipv dbpv "`atlst'"
	     }
	     else {
	          capture reshape xij vote seats tv dv ttev tiev tbev dtev diev dbev "`atlst'"
	          }
	     capture reshape long
	     capture drop if vote==.
	     capture drop tv dv
	     if `seatpr'==1 {
	        capture drop if seats==.
	        capture drop ts ds
	     }
             label variable ttev "Total-V(e)"
	     label variable tiev "Inter-V(e)"
	     label variable tbev "Intra-V(e)"
	     label variable dtev "Total-V(e) district"
	     label variable diev "Inter-V(e) district"
	     label variable dbev "Intra-V(e) district"
	     if `seatpr'==1 {
	        label variable ttpv "Total-V(p)"
	        label variable tipv "Inter-V(p)"
	        label variable tbpv "Intra-V(p)"
	        label variable dtpv "Total-V(p) district"
	        label variable dipv "Inter-V(p) district"
	        label variable dbpv "Intra-V(p) district"
	     }
	     capture egen pid = tag(time party)
	     capture egen iptn = group(time party)
	     capture egen idt = group(time `district' party)
	     capture egen idgt = group(time)
	     capture egen idg = group(`time' `district')
	     sort idg
	     capture by idg: egen dtseats=sum(seats)
	     label variable dtseats "seats"
	     sort time
	  }

	//computing votes and seats
	  sort time
	  capture by time: egen ttv=sum(vote)
	  sort time party
	  capture by time party: egen tpv=sum(vote)
	  capture generate tv=tpv/ttv
	  sort time `district'
	  capture by time: egen tmv=rank(tpv) if pid==1, unique
	  capture by time: egen tmvx=max(tmv)
	  capture generate tmvi1=tpv if tmv==tmvx
	  capture generate tmvi2=tpv if tmv==tmvx-1
	  capture by time: egen tmv1=max(tmvi1)
	  capture by time: egen tmv2=max(tmvi2)
	  capture generate tv2=tv^2
	  capture generate tlv=ln(tv)
	  capture generate tvlv=tv*tlv
	  sort time `district'
	  capture by time `district': egen dtv=sum(vote)
	  label variable dtv "vote"
	  capture generate dv=vote/dtv
	  capture by time `district': egen dmv=rank(vote), unique
	  capture by time `district': egen dmvx=max(dmv)
	  capture generate dmvi1=vote if dmv==dmvx
	  capture generate dmvi2=vote if dmv==dmvx-1
	  capture by time `district': egen dmv1=max(dmvi1)
	  capture by time `district': egen dmv2=max(dmvi2)
	  capture generate dv2=dv^2
	  capture generate dlv=ln(dv)
	  capture generate dvlv=dv*dlv
	  if `seatpr'==1 {
	     sort time
	     capture by time: egen tts=sum(seats)
	     sort time party
	     capture by time party: egen tps=sum(seats)
	     capture generate ts=tps/tts
	     sort time
	     capture by time: egen tms=rank(tps) if pid==1, unique
	     capture by time: egen tmsx=max(tms)
	     capture generate tmsi1=tps if tms==tmsx
	     capture generate tmsi2=tps if tms==tmsx-1
	     capture by time: egen tms1=max(tmsi1)
	     capture by time: egen tms2=max(tmsi2)
	     capture generate ts2=ts^2
	     capture generate tls=ln(ts)
	     capture generate tsls=ts*tls
	     sort time `district'
	     capture by time `district': egen tds=sum(seats)
	     capture generate ds=seats/tds
	     capture by time `district': egen dms=rank(seats), unique
	     capture by time `district': egen dmsx=max(dms)
	     capture generate dmsi1=seats if dms==dmsx
	     capture generate dmsi2=seats if dms==dmsx-1
	     capture by time `district': egen dms1=max(dmsi1)
	     capture by time `district': egen dms2=max(dmsi2)
	     capture generate ds2=ds^2
	     capture generate dls=ln(ds)
	     capture generate dsls=ds*dls
	     capture generate tdif=abs(tv-ts)
	     capture generate tdifr=abs(tv-ts) if tv>0.005
	     capture generate tc=(tv-ts)^2
	     capture generate tcr=(tv-ts)^2 if tv>0.005
	     capture generate tcf=((tv-ts)^2)/tv
	     capture generate ddif=abs(dv-ds)
	     capture generate ddifr=abs(dv-ds) if dv>0.005
	     capture generate dc=(dv-ds)^2
	     capture generate dcr=(dv-ds)^2 if dv>0.005
	     capture generate dcf=((dv-ds)^2)/dv
	  }

	//computing proportionality
	  if `seatpr'==1 {
	     sort time
	     capture by time: egen tprae1 = mean(tdifr) if pid==1
	     capture by time: egen tprae = max(tprae1)
	     capture replace tprae=100-(tprae*100)
	     label variable tprae "Rae"
	     capture by time: egen tplh1 = sum(tdif) if pid==1
	     capture by time: egen tplh = max(tplh1)
	     capture replace tplh=100-((tplh/2)*100)
	     label variable tplh "Mackie-Rose"
	     capture by time: egen tpg1 = sum(tc) if pid==1
	     capture by time: egen tpg = max(tpg1)
	     capture replace tpg=100-((sqrt(tpg/2))*100)
	     label variable tpg "Gallagher"
	     capture by time: egen tpl1 = sum(tcr) if pid==1
	     capture by time: egen tpl = max(tpl1)
	     capture replace tpl=100-((sqrt(tpl/2))*100)
	     label variable tpl "Lijphart"
	     capture by time: egen tpsl1 = sum(tcf) if pid==1
	     capture by time: egen tpsl = max(tpsl1)
	     capture replace tpsl=tpsl*100
	     label variable tpsl "St. Laguë"
	     capture by time: egen tpml1 = max(tdif) if pid==1
	     capture by time: egen tpml = max(tpml1)
	     capture replace tpml=tpml*100
	     label variable tpml "max deviation"
	     capture generate tpadr1 = ts/tv
	     capture by time: egen tpadr = max(tpadr1)
	     label variable tpadr "adv ratio"
	     capture by time: egen tpgrf1 = sum(tdif) if pid == 1
   	     capture by time: egen tpgrf2 = sum(tv2) if pid == 1
   	     capture replace tpgrf2 = 1/(tpgrf2)
	     capture generate tpgrf3 = ((tpgrf1/tpgrf2)*100)
	     capture by time: egen tpgrf = max(tpgrf3)
	     label variable tpgrf "Grofman"
	     quietly summarize idgt
	     local maxit = r(max)
	     local n = 1
	     capture generate tcs=.
	     capture generate tcsr=.
	     while `n'<=`maxit' {
		   capture regress ts tv if idgt==`n'
		   capture replace tcs=_b[tv] if idgt==`n'
		   capture regress ts tv if idgt==`n' & ts>0
		   capture replace tcsr=_b[tv] if idgt==`n'
		   local n = `n'+1
	     }
	     label variable tcs "Cox-Shugart"
	     label variable tcsr "Cox-Shugart(r)"
	     sort time `district'
	     capture by time `district': egen dprae = mean(ddifr)
	     capture replace dprae=100-(dprae*100)
	     label variable dprae "Rae"
	     capture by time `district': egen dplh = sum(ddif)
	     capture replace dplh=100-((dplh/2)*100)
	     label variable dplh "Mackie-Rose"
	     capture by time `district': egen dpg = sum(dc)
	     capture replace dpg=100-((sqrt(dpg/2))*100)
	     label variable dpg "Gallagher"
	     capture by time `district': egen dpl = sum(dcr)
	     capture replace dpl=100-((sqrt(dpl/2))*100)
	     label variable dpl "Lijphart"
	     capture by time `district': egen dpsl = sum(dcf)
	     capture replace dpsl=dpsl*100
	     label variable dpsl "St. Laguë"
	     capture by time `district': egen dpml = max(ddif)
	     capture replace dpml=dpml*100
	     label variable dpml "max deviation"
	     capture generate dpadr1 = ds/dv
	     capture by time `district': egen dpadr = max(dpadr1)
	     label variable dpadr "adv ratio"
	     capture by time `district': egen dpgrf1 = sum(ddif)
   	     capture by time `district': egen dpgrf2 = sum(dv2)
   	     capture replace dpgrf2 = 1/(dpgrf2)
	     capture generate dpgrf = ((dpgrf1/dpgrf2)*100)
	     label variable dpgrf "Grofman"
	     quietly summarize idg
	     local maxit = r(max)
	     local n = 1
	     capture generate dcs=.
	     capture generate dcsr=.
	     while `n'<=`maxit' {
		   capture regress ds dv if idg==`n'
		   capture replace dcs=_b[dv] if idg==`n'
		   capture regress ds dv if idg==`n' & ds>0
		   capture replace dcsr=_b[dv] if idg==`n'
		   local n = `n'+1
	     }
	     label variable dcs "Cox-Shugart"
	     label variable dcsr "Cox-Shugart(r)"
	  }

	//computing fragmentation
	  sort time
	  capture by time: egen tefrae1 = sum(tv2) if pid==1
	  capture by time: egen tefrae = max(tefrae1)
	  capture replace tefrae=1-tefrae
	  label variable tefrae "Rae's F"
	  capture by time: egen tekw1 = sum(tvlv) if pid==1
	  capture by time: egen tekw = max(tekw1)
	  capture replace tekw=exp(-(tekw))
	  label variable tekw "Kesselman-Wildgen"
	  capture generate teenp = 1/(1-tefrae)
	  label variable teenp "ENP"
	  capture generate telc = 1/(tmv1/ttv)
	  label variable telc "Taagepera LC"
	  capture generate tedb = (teenp+telc)/2
	  label variable tedb "Dunleavy-Boucek"
	  capture by time: egen temol1 = sum(tv2) if pid==1
	  capture generate temol2 = 1+(teenp*((temol1-(tmv1/ttv)^2)/temol1)) if tmv==tmvx
	  capture by time: egen temol = max(temol2)
	  label variable temol "Molinar NP"
	  sort time `district'
	  capture by time `district': egen defrae = sum(dv2)
	  capture replace defrae=1-defrae
	  label variable defrae "Rae's F"
	  capture by time `district': egen dekw = sum(dvlv)
	  capture replace dekw=exp(-(dekw))
	  label variable dekw "Kesselman-Wildgen"
	  capture generate deenp = 1/(1-defrae)
	  label variable deenp "ENP"
	  capture by time `district': egen demol1 = sum(dv2)
	  capture generate delc = 1/(dmv1/dtv)
	  label variable delc "Taagepera LC"
	  capture generate dedb = (deenp+delc)/2
	  label variable dedb "Dunleavy-Boucek"
	  capture generate demol2 = 1+(deenp*((demol1-(dmv1/dtv)^2)/demol1)) if dmv==dmvx
	  capture by time `district': egen demol = max(demol2)
	  label variable demol "Molinar NP"
	  if `seatpr'==1 {
	     sort time
	     capture by time: egen tpfrae1 = sum(ts2) if pid==1
	     capture by time: egen tpfrae = max(tpfrae1)
	     capture replace tpfrae=1-tpfrae
	     label variable tpfrae "Rae's F"
	     capture by time: egen tpkw1 = sum(tsls) if pid==1
	     capture by time: egen tpkw = max(tpkw1)
	     capture replace tpkw=exp(-(tpkw))
	     label variable tpkw "Kesselman-Wildgen"
	     capture generate tpenp = 1/(1-tpfrae)
	     label variable tpenp "ENP"
	     capture generate tplc = 1/(tms1/tts)
	     label variable tplc "Taagepera LC"
	     capture generate tpdb = (tpenp+tplc)/2
	     label variable tpdb "Dunleavy-Boucek"
	     capture by time: egen tpmol1 = sum(ts2) if pid==1
	     capture generate tpmol2 = 1+(tpenp*((tpmol1-(tms1/tts)^2)/tpmol1)) if tms==tmsx
	     capture by time: egen tpmol = max(tpmol2)
	     label variable tpmol "Molinar NP"
	     sort time `district'
	     capture by time `district': egen dpfrae = sum(ds2)
	     capture replace dpfrae=1-dpfrae
	     label variable dpfrae "Rae's F"
	     capture by time `district': egen dpkw = sum(dsls)
	     capture replace dpkw=exp(-(dpkw))
	     label variable dpkw "Kesselman-Wildgen"
	     capture generate dpenp = 1/(1-dpfrae)
	     label variable dpenp "ENP(p)"
	     capture generate dplc = 1/(dms1/tds)
	     label variable dplc "Taagepera LC"
	     capture generate dpdb = (dpenp+dplc)/2
	     label variable dpdb "Dunleavy-Boucek"
	     capture by time `district': egen dpmol1 = sum(ds2)
	     capture generate dpmol2 = 1+(dpenp*((dpmol1-(dms1/tds)^2)/dpmol1)) if dms==dmsx
	     capture by time `district': egen dpmol = max(dpmol2)
	     label variable dpmol "Molinar NP"
	  }

	//computing concentration and competitiveness
	  capture generate tecon = ((tmv1+tmv2)/ttv)*100
	  label variable tecon "concentration"
	  capture generate tecomp = ((tmv1-tmv2)/ttv)*100
	  label variable tecomp "competi(vote)"
	  capture generate decon = ((dmv1+dmv2)/dtv)*100
	  label variable decon "concentration"
	  capture generate decomp = ((dmv1-dmv2)/dtv)*100
	  label variable decomp "competi(vote)"
	  if `seatpr'==1 {
	     capture generate tpcon = ((tms1+tms2)/tts)*100
	     label variable tpcon "concentration"
	     capture generate tpcomp = ((tms1-tms2)/tts)*100
	     label variable tpcomp "competi(seats)"
	     capture generate tpeli = ((tmv2*tms2)/(tmv1*tms1))*100
	     label variable tpeli "Perez-Linan RC"
	     capture generate dpcon = ((dms1+dms2)/tds)*100
	     label variable dpcon "concentration"
	     capture generate dpcomp = ((dms1-dms2)/tds)*100
	     label variable dpcomp "competi(seats)"
	     capture generate dpeli = ((dmv2*dms2)/(dmv1*dms1))*100
	     label variable dpeli "Perez-Linan RC"
	  }

	//computing polarization
	  if "`attrib'"!="" {
	     local v = 1
	     foreach var in `attrib' {
		     capture generate wdmean`v' = (dtv/ttv)*`var'
		     sort time party
		     capture by time party: egen wmean`v' = sum(wdmean`v')
		     local tattrib = "`tattrib'" + " " + "wmean`v'"
		     local v = `v'+1
	     }
	     capture egen mattrib = rowmean(`attrib')
	     capture egen mtattrib = rowmean(`tattrib')
	     drop wdmean* wmean*
	     capture generate tpolard=.
	     capture generate tpolarb=.
	     label variable tpolard "polar(euclid)"
	     label variable tpolarb "polar(abs)"
	     local dtn=1
	     quietly summarize idgt
	     local maxit=r(max)
	     while `dtn'<=`maxit' {
		   mkmat party tv mtattrib if idgt==`dtn'
		   matrix P = tv, mtattrib
		   local s = rowsof(P)
		   local r = 1
		   local poldt = 0
		   local polbt = 0
		   while `r'<=`s' {
			 local m = 1
			 while `m'<=`s' {
			       local pold = P[`r',1]*P[`m',1]*((P[`r',2]-P[`m',2])^2)
			       local poldt = `poldt' + `pold'
			       local polb = P[`r',1]*P[`m',1]*(abs(P[`r',2]-P[`m',2]))
			       local polbt = `polbt' + `polb'
			       local m = `m'+1
			 }
			 local r = `r'+1
		   }
		   capture replace tpolard = `poldt' if idgt==`dtn'
		   capture replace tpolarb = `polbt' if idgt==`dtn'
		   matrix drop _all
		   local dtn = `dtn'+1
	     }
	     capture generate dpolard=.
	     capture generate dpolarb=.
	     label variable dpolard "polar(euclid)"
	     label variable dpolarb "polar(abs)"
	     local dtn=1
	     quietly summarize idg
	     local maxit=r(max)
	     while `dtn'<=`maxit' {
		   mkmat party dv mtattrib if idg==`dtn'
		   matrix P = dv, mtattrib
		   local s = rowsof(P)
		   local r = 1
		   local poldt = 0
		   local polbt = 0
		   while `r'<=`s' {
			 local m = 1
			 while `m'<=`s' {
			       local pold = P[`r',1]*P[`m',1]*((P[`r',2]-P[`m',2])^2)
			       local poldt = `poldt' + `pold'
			       local polb = P[`r',1]*P[`m',1]*(abs(P[`r',2]-P[`m',2]))
			       local polbt = `polbt' + `polb'
			       local m = `m'+1
			 }
			 local r = `r'+1
		   }
		   capture replace dpolard = `poldt' if idg==`dtn'
		   capture replace dpolarb = `polbt' if idg==`dtn'
		   matrix drop _all
		   local dtn = `dtn'+1
	     }
	  }

	//erasing variables
	  order `time' `district' dtv dtseats
	  sort `time' `district'
	  drop `attrib' dtv pid-idg ttv-tvlv dv-dvlv tefrae1 tekw1 temol1 temol2 demol1 demol2
	  if `distdisp'==0 {
	     drop defrae-demol decon decomp
	     if `timepr'==1 {
	        drop dtev diev dbev
	     }
	  }
	  if `seatpr'==1 {
	     drop dtseats tts-tprae1 tplh1 tpg1 tpl1 tpsl1 tpadr1 tpgrf1 tpgrf2 tpgrf3 tpml1 tpfrae1 tpkw1 tpmol1 tpmol2 dpadr1 dpgrf1 dpgrf2 dpmol1 dpmol2
	     if `distdisp'==0 {
		drop dprae-dcsr dpfrae-dpmol dpcon dpcomp dpeli
		if `timepr'==1 {
		drop dtpv dipv dbpv
		}
	     }
	  }
	  else drop dtseats
	  if "`attrib'"!="" {
	     drop mattrib mtattrib
	     if `distdisp'==0 {
		drop dpolarb dpolard
	     }
	  }
	  if "`total'"=="nototal" {
	     rename time etime
	     drop t*
	     rename etime time
	  }

	//displaying output(if requested)
	  tempfile ftsav
     	  capture save "`ftsav'", replace
	  if "`output'"!="nooutput" {
	     capture generate total=1
	     label variable total "index"
	     label define total 1 "value"
	     label values total total
	     if `seatpr'==1 {
		display
		display in green "disproportionality"
		if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(tprae tplh tpg tpl tpsl) format(%9.4f)
		   by time: tabdisp total, cellvar(tpml tpadr tpgrf tcs tcsr) format(%9.4f)
		}
		if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(dprae dplh dpg dpl dpsl) format(%9.4f)
		   by time `district': tabdisp total, cellvar(dpml dpadr dpgrf dcs dcsr) format(%9.4f)
		}
	     }
	     display
	     display in green "electoral fragmentation"
	     if "`total'"!="nototal" {
		sort time
		by time: tabdisp total, cellvar(tefrae teenp telc tedb) format(%9.4f)
		by time: tabdisp total, cellvar(temol tekw tecon) format(%9.4f)
	     }
	     if `distdisp'==1 {
		sort time `district'
		by time `district': tabdisp total, cellvar(defrae deenp delc dedb) format(%9.4f)
		by time `district': tabdisp total, cellvar(demol dekw decon) format(%9.4f)
	     }
	     if `seatpr'==1 {
		display
		display in green "parliamentary fragmentation"
		if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(tpfrae tpenp tplc tpdb) format(%9.4f)
		   by time: tabdisp total, cellvar(tpmol tpkw tpcon) format(%9.4f)
		}
		if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(dpfrae dpenp dplc dpdb) format(%9.4f)
		   by time `district': tabdisp total, cellvar(dpmol dpkw dpcon) format(%9.4f)
		}
	     }
	     display
	     display in green "competitiveness"
	     if `seatpr'==1 {
		if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(tecomp tpcomp tpeli) format(%9.4f)
		}
		if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(decomp dpcomp dpeli) format(%9.4f)
		}
	     }
	     else {
	        if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(tecomp) format(%9.4f)
	        }
	        if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(decomp) format(%9.4f)
	        }
	     }
	     if "`attrib'"!="" {
		display
		display in green "polarization"
		if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(tpolarb tpolard) format(%9.4f)
		}
		if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(dpolarb dpolard) format(%9.4f)
		}
	     }
	     if `timepr'==1 {
		capture drop if time==`fyear'
		display
		display in green "electoral volatility"
		if "`total'"!="nototal" {
		   sort time
		   by time: tabdisp total, cellvar(ttev tiev tbev) format(%9.2f)
		}
		if `distdisp'==1 {
		   sort time `district'
		   by time `district': tabdisp total, cellvar(dtev diev dbev) format(%9.2f)
		}
		if `seatpr'==1 {
		   display
		   display in green "parliamentary volatility"
  		   if "`total'"!="nototal" {
 		      sort time
		      by time: tabdisp total, cellvar(ttpv tipv tbpv) format(%9.2f)
		   }
		   if `distdisp'==1 {
		      sort time `district'
		      by time `district': tabdisp total, cellvar(dtev diev dbev) format(%9.2f)
		   }
   		}
	     }
             drop total
	  }

	//saving file (if requested)
          use "`ftsav'", clear
	  sort time `district'
          drop party blocks vote seats
	  if `timepr'==0 {
	      drop time
	  }
	  if `distdisp'==0 {
	      drop `district'
	  }
	  contract _all
	  drop _freq
	  if "`save'"!="" {
	     capture save "`save'", replace
	  }

	//storing results (if requested)
	  if "`store'"!="" {
             use "`ftsav'", clear
	     capture egen _midgm = group(time `district')
	     sort _midgm
	     capture drop if _midgm==.
	     drop time `district' party blocks vote seats
	     capture save "`ftsav'", replace
	     restore
	     capture egen _midgm = group(`mertmp')
	     sort _midgm
	     capture merge _midgm using "`ftsav'"
	     capture drop _merge _midgm
	  }
  }

  end

//the program ends
