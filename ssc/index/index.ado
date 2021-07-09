*! index V1.0 15/04/2015
*!
program define index , eclass
version 11.2
di 
qui {
if replay() {
noi di as err " {bf:LHS and RHS must be combined}"
 exit
 }
 gettoken q 0 : 0, parse(" =  ") quotes
 while `"`q'"' != ":" & `"`q'"' != "=" {
 if `"`q'"' == " , " | `"`q'"'=="" {
 error 198
 }
 local lhsns `lhsns' `q'
 gettoken q 0 : 0, parse(" = ") quotes
 }
 unab lhsns : `lhsns'
 syntax varlist(min=1) [if] [in] , [panel it(str) id(str) year(int 1) ///
 SUMm SAVE(str) base(int 1) LIst CHain lhs(str) rhs(str) SIMple]

if "`lhs'"!="" {
if !inlist("`lhs'", "p", "q") {
di as err " {bf:LHS( )} {cmd:must be:} {bf:(p) or (q)}" 
 exit
 }
 }
if "`rhs'"!="" {
if !inlist("`rhs'", "q", "v") {
di as err " {bf:RHS( )} {cmd:must be:} {bf:(q) or (v)}" 
 exit
 }
 }
if "`lhs'"=="q" & "`rhs'"=="q"  {
di as err " {bf:LHS( )} & {bf:RHS( )} {cmd:must be different}" 
 exit
 }
if "`lhs'"=="p" & "`rhs'"==""  {
 local rhs "q"
 }
if "`lhs'"=="q" & "`rhs'"==""  {
 local rhs "v"
 }
if "`lhs'"=="" & "`rhs'"=="q"  {
 local lhs "p"
 }
if "`lhs'"=="" & "`rhs'"=="v"  {
 local lhs "q"
 }
if "`lhs'"=="" & "`rhs'"==""  {
 local lhs "p"
 local rhs "q"
 }

if "`panel'"!="" {
 if "`id'"=="" | "`it'"=="" & {
di as err " {bf:id( ) & it( )} {cmd:must be combined with option:} {bf:panel}" 
 exit
 }
 }

 marksample touse
 markout `touse' `varlist' 
 local klhs : word count `lhsns'
 local i 1
 while (`i'<=`klhs') {
 local lhsn : word `i' of `lhsns'
 local junk : subinstr local lhsns "`lhsn'" "", word all count(local j)
 if `j' > 1 {
noi di as err " {bf:Do not Include the Same Variable More than Once}"
 exit
 }
 local i = `i' + 1
 }
 if `klhs' < 1 {
noi di as err " {bf:Number of each LHS & RHS Variables must be at least 1}"
 exit
 }
 } 
 cap mata: mata clear

 preserve
qui {
 if ("`if'" != "" | "`in'" != "") {
 keep `in' `if' 
 }
 keep `lhsns' `varlist' `id' `it' `time'
 local nrhs `varlist' `word'
 gettoken word 0 : 0, parse(" :, ")
 unab nrhs : `varlist'
 local krhs : word count `nrhs'
 local i 1
 while (`i'<=`krhs') {
 local rhsn : word `i' of `nrhs'
 local junk : subinstr local nrhs "`rhsn'" "", word all count(local j)
 if `j' > 1 {
 if "`value'"!="" {
noi di as err " {bf:Do not Include the Same Value Variable More than Once}"
 }
 else {
noi di as err " {bf:Do not Include the Same Value Variable More than Once}"
 }
 exit
 }
 local i = `i' + 1
 }
 local kxrhs : word count `varlist'
qui forvalue k = 1/`kxrhs' {
 local ylhs : word `k' of `lhsns'
 local xrhs : word `k' of `varlist'
 } 
 } 
 indexpq , nlhs(`lhsns') nrhs(`varlist') `panel' `summ' save(`save') `simple' ///
 year(`year') base(`base') id(`id') it(`it') `list' `chain' lhs(`lhs') rhs(`rhs')
 restore

 if "`list'"!= "" {
 indexlist , nvar(`lhsns') `simple'
 } 
 end

program define indexpq, eclass
 syntax [if] [in] , NLHS(str) NRHS(str) [panel it(str) id(str) SUMm ///
 year(str) SAVE(str) base(int 1) LIst CHain lhs(str) rhs(str) SIMple]
 local both : list nlhs & nrhs
if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
noi di as res " LHS(Prices): `nlhs' "
 if "`value'"!="" {
noi di as res " RHS(Values): `nrhs'"
 }
 else {
noi di as res " RHS(Quantities): `nrhs'"
 }
 exit
 }
 local kylhs : word count `nlhs'
 local kxrhs : word count `nrhs'
if "`kxrhs'" != "`kylhs'" {
noi di as err " {bf:Number of Variables in (LHS) not Equal (RHS)}"
 exit
 }

tempvar Time TimeN idv itv Po Qo Pt Qt P Q Y PoQo PoQt PtQo PtQt miss
tempvar Wo Wt Yo Yt PoPt QoQt TTP TTQ MEP1 MEP2 MEQ1 MEQ2 WP1 WP2 WQ1 WQ2
tempvar MP1 MP2 MQ1 MQ2 MPw1 MPw2 MQw1 MQw2 GLP GLQ HMP1 HMP2 HMP HMQ1 HMQ2 HMQ
tempvar TTPc TTQc LPt LQt LWt PPc PQc LPc LQc FPc FQc BPc BQc Ch1 Ch2
tempvar PP1c PQ1c LP1c LQ1c FP1c FQ1c PP2c PQ2c LP2c LQ2c FP2c FQ2c
tempvar PP1 PQ1 PP2 PQ2 LP1 LP2 LQ1 LQ2 FP1 FP2 FQ1 FQ2 GMP GMQ
tempname Q Y NC

qui {
 gen `TimeN'=_n
 tsset `TimeN'
 gen `Time'=_n
 tsset `Time'
 mark `miss'
 markout `miss' `lhsns' `varlist'
 keep if `miss' == 1
 replace `Time'=_n
 tsset `Time'

if "`panel'" != "" {
 bysort `it' (`id'): replace `id' = _n
 bysort `id' (`it'): replace `it' = _n
 tab `id'
 xtset `id' `it'
 local idv "`r(panelvar)'"
 local itv "`r(timevar)'"
 local NC=r(tmax)
 }
 else {
 gen `idv' = 1
 gen `itv' = `Time'
 local NC=r(tmax)
 }
 tsset `Time'
 local nq `kylhs'
 bysort `idv': gen _Year = _n + `year' -1
 local base1 =`base'+1
 forvalue i = 1/`nq' {
 if inlist("`lhs'", "p") & inlist("`rhs'", "q") {
 local P : word `i' of `nlhs'
 local Q : word `i' of `nrhs'
 bysort `idv': gen `P'_`i' = `P'
 bysort `idv': gen `Q'_`i' = `Q'
 bysort `idv': gen `Y'_`i' = `P'*`Q'
 bysort `idv': gen `Po'_`i'= `P'_`i'[`base']
 bysort `idv': gen `Pt'_`i'= `P'_`i'
 bysort `idv': gen `Qo'_`i'= `Q'_`i'[`base']
 bysort `idv': gen `Qt'_`i'= `Q'_`i'
 if "`simple'"!= "" {
 bysort `idv': gen _P_`i' = `P'_`i'
 bysort `idv': gen _Q_`i' = `Q'_`i'
 bysort `idv': gen _V_`i' = `Y'_`i'
 bysort `idv': gen _IP_`i' = `P'_`i'/`P'_`i'[`base']*100
 bysort `idv': gen _IQ_`i' = `Q'_`i'/`Q'_`i'[`base']*100
 bysort `idv': gen _IV_`i' = `Y'_`i'/`Y'_`i'[`base']*100
 if "`list'"!= "" {
 putmata _IP_`i' , replace
 putmata _IQ_`i' , replace
 putmata _IV_`i' , replace
 }
 }
 }

if inlist("`lhs'", "p") & inlist("`rhs'", "v") {
 local P : word `i' of `nlhs'
 local V : word `i' of `nrhs'
 bysort `idv': gen `P'_`i' = `P'
 bysort `idv': gen `Q'_`i' = `V'/`P'
 bysort `idv': gen `Y'_`i' = `V'
 bysort `idv': gen `Po'_`i'= `P'_`i'[`base']
 bysort `idv': gen `Pt'_`i'= `P'_`i'
 bysort `idv': gen `Qo'_`i'= `Q'_`i'[`base']
 bysort `idv': gen `Qt'_`i'= `Q'_`i'
 if "`simple'"!= "" {
 bysort `idv': gen _P_`i' = `P'_`i'
 bysort `idv': gen _Q_`i' = `Q'_`i'
 bysort `idv': gen _V_`i' = `Y'_`i'
 bysort `idv': gen _IP_`i' = `P'_`i'/`P'_`i'[`base']*100
 bysort `idv': gen _IQ_`i' = `Q'_`i'/`Q'_`i'[`base']*100
 bysort `idv': gen _IV_`i' = `Y'_`i'/`Y'_`i'[`base']*100
 if "`list'"!= "" {
 putmata _IP_`i' , replace
 putmata _IQ_`i' , replace
 putmata _IV_`i' , replace
 }
 }
 }

 if inlist("`lhs'", "q") & inlist("`rhs'", "v") {
 local Q : word `i' of `nlhs'
 local V : word `i' of `nrhs'
 bysort `idv': gen `P'_`i' = `V'/`Q'
 bysort `idv': gen `Q'_`i' = `Q'
 bysort `idv': gen `Y'_`i' = `V'
 bysort `idv': gen `Po'_`i'= `P'_`i'[`base']
 bysort `idv': gen `Pt'_`i'= `P'_`i'
 bysort `idv': gen `Qo'_`i'= `Q'_`i'[`base']
 bysort `idv': gen `Qt'_`i'= `Q'_`i'

 if "`simple'"!= "" {
 bysort `idv': gen _P_`i' = `P'_`i'
 bysort `idv': gen _Q_`i' = `Q'_`i'
 bysort `idv': gen _V_`i' = `Y'_`i'
 bysort `idv': gen _IP_`i' = `P'_`i'/`P'_`i'[`base']*100
 bysort `idv': gen _IQ_`i' = `Q'_`i'/`Q'_`i'[`base']*100
 bysort `idv': gen _IV_`i' = `Y'_`i'/`Y'_`i'[`base']*100
 if "`list'"!= "" {
 putmata _IP_`i' , replace
 putmata _IQ_`i' , replace
 putmata _IV_`i' , replace
 }
 }
 }
 }
 
 egen `Yt' = rowtotal(`Y'_*)
 bysort `idv': gen `Yo' = `Yt'[`base']
 unab nlhs : `nlhs'
 unab nrhs : `nrhs'

 forvalue i = 1/`nq' {
 bysort `idv': gen `PoQo'_`i' = `Po'_`i'*`Qo'_`i'
 bysort `idv': gen `PoQt'_`i' = `Po'_`i'*`Qt'_`i'
 bysort `idv': gen `PtQo'_`i' = `Pt'_`i'*`Qo'_`i'
 bysort `idv': gen `PtQt'_`i' = `Pt'_`i'*`Qt'_`i'
 bysort `idv': gen `PoPt'_`i' = `Po'_`i'*`Pt'_`i'
 bysort `idv': gen `QoQt'_`i' = `Qo'_`i'*`Qt'_`i'
 bysort `idv': gen `Wo'_`i'= (`PoQo'_`i')/`Yo'[`base']
 bysort `idv': gen `Wt'_`i'= (`PtQt'_`i')/`Yt'
 bysort `idv': gen `TTP'_`i' = 0.5*(`Wo'_`i'+`Wt'_`i')*(ln(`Pt'_`i')-ln(`Po'_`i'))
 bysort `idv': gen `TTQ'_`i' = 0.5*(`Wo'_`i'+`Wt'_`i')*(ln(`Qt'_`i')-ln(`Qo'_`i'))
 bysort `idv': gen `LPt'_`i' = `Pt'_`i'[`base'] if _n <= `base'
 bysort `idv': gen `LQt'_`i' = `Qt'_`i'[`base'] if _n <= `base'
 bysort `idv': gen `LWt'_`i' = `Wt'_`i'[`base'] if _n <= `base'
 bysort `idv': replace `LPt'_`i' = `Pt'_`i'[_n-1] if _n > `base'
 bysort `idv': replace `LQt'_`i' = `Qt'_`i'[_n-1] if _n > `base'
 bysort `idv': replace `LWt'_`i' = `Wt'_`i'[_n-1] if _n > `base'
 bysort `idv': gen `TTPc'_`i' = 0.5*(`Wt'_`i'+`LWt'_`i')*(ln(`Pt'_`i')-ln(`LPt'_`i'))
 bysort `idv': gen `TTQc'_`i' = 0.5*(`Wt'_`i'+`LWt'_`i')*(ln(`Qt'_`i')-ln(`LQt'_`i'))
 bysort `idv': gen `PP1'_`i' = `Pt'_`i'*`Qt'_`i'
 bysort `idv': gen `PP2'_`i' = `Po'_`i'*`Qt'_`i'
 bysort `idv': gen `PQ1'_`i' = `Pt'_`i'*`Qt'_`i'
 bysort `idv': gen `PQ2'_`i' = `Pt'_`i'*`Qo'_`i'
 bysort `idv': gen `PP1c'_`i' = `Pt'_`i'*`Qt'_`i'
 bysort `idv': gen `PP2c'_`i' = `LPt'_`i'*`Qt'_`i'
 bysort `idv': gen `PQ1c'_`i' = `Pt'_`i'*`Qt'_`i'
 bysort `idv': gen `PQ2c'_`i' = `LQt'_`i'*`Pt'_`i'
 bysort `idv': gen `LP1'_`i' = `Pt'_`i'*`Qo'_`i'
 bysort `idv': gen `LP2'_`i' = `Po'_`i'*`Qo'_`i'
 bysort `idv': gen `LQ1'_`i' = `Po'_`i'*`Qt'_`i'
 bysort `idv': gen `LQ2'_`i' = `Po'_`i'*`Qo'_`i'
 bysort `idv': gen `LP1c'_`i' = `Pt'_`i'*`LQt'_`i'
 bysort `idv': gen `LP2c'_`i' = `LPt'_`i'*`LQt'_`i'
 bysort `idv': gen `LQ1c'_`i' = `Qt'_`i'*`LPt'_`i'
 bysort `idv': gen `LQ2c'_`i' = `LQt'_`i'*`LPt'_`i'
 bysort `idv': gen `MEP1'_`i' =`PtQo'_`i'+`PtQt'_`i'
 bysort `idv': gen `MEP2'_`i' =`PoQo'_`i'+`PoQt'_`i'
 bysort `idv': gen `MEQ1'_`i' =`PoQt'_`i'+`PtQt'_`i'
 bysort `idv': gen `MEQ2'_`i' =`PoQo'_`i'+`PtQo'_`i'
 bysort `idv': gen `WP1'_`i'=`Pt'_`i'*sqrt(`QoQt'_`i')
 bysort `idv': gen `WQ1'_`i'=`Qt'_`i'*sqrt(`PoPt'_`i')
 bysort `idv': gen `WP2'_`i'=`Po'_`i'*sqrt(`QoQt'_`i')
 bysort `idv': gen `WQ2'_`i'=`Qo'_`i'*sqrt(`PoPt'_`i')
 bysort `idv': gen `MQw2'_`i' = 0.5 * (`Po'_`i'+`Pt'_`i')
 bysort `idv': gen `MPw2'_`i' = 0.5 * (`Qo'_`i'+`Qt'_`i')
 bysort `idv': gen `MP1'_`i' = `Pt'_`i'*`MPw2'_`i'
 bysort `idv': gen `MQ1'_`i' = `Qt'_`i'*`MQw2'_`i'
 bysort `idv': gen `MP2'_`i' = `Po'_`i'*`MPw2'_`i'
 bysort `idv': gen `MQ2'_`i' = `Qo'_`i'*`MQw2'_`i'
 bysort `idv': gen `MPw1'_`i' = `Pt'_`i'*`MPw2'_`i'/`Po'_`i'
 bysort `idv': gen `MQw1'_`i' = `Qt'_`i'*`MQw2'_`i'/`Qo'_`i'
 bysort `idv': gen `GLP'_`i'=`Wo'_`i'*(ln(`Pt'_`i')-ln(`Po'_`i'))
 bysort `idv': gen `GLQ'_`i'=`Wo'_`i'*(ln(`Qt'_`i')-ln(`Qo'_`i'))
 bysort `idv': gen `HMP1'_`i'=`Po'_`i'*`Qo'_`i'
 bysort `idv': gen `HMQ1'_`i'=`Po'_`i'*`Qo'_`i'
 bysort `idv': gen `HMP2'_`i'=(`Po'_`i'^2)*`Qo'_`i'/`Pt'_`i'
 bysort `idv': gen `HMQ2'_`i'=(`Qo'_`i'^2)*`Po'_`i'/`Qt'_`i'
 }

 egen `TTP'=rowtotal(`TTP'_*)
 egen `TTQ'=rowtotal(`TTQ'_*)
 replace `TTP'=exp(`TTP')
 replace `TTQ'=exp(`TTQ')
 egen `TTPc' = rowtotal(`TTPc'_*)
 egen `TTQc' = rowtotal(`TTQc'_*)
 replace `TTPc' = exp(`TTPc')
 replace `TTQc' = exp(`TTQc')
 gen _TT_P= `TTP'*100
 gen _TT_Q= `TTQ'*100
 egen `PP1' = rowtotal(`PP1'_*)
 egen `PP2' = rowtotal(`PP2'_*)
 egen `PQ1' = rowtotal(`PQ1'_*)
 egen `PQ2' = rowtotal(`PQ2'_*)
 egen `PP1c' = rowtotal(`PP1c'_*)
 egen `PP2c' = rowtotal(`PP2c'_*)
 egen `PQ1c' = rowtotal(`PQ1c'_*)
 egen `PQ2c' = rowtotal(`PQ2c'_*)
 gen _P_P= `PP1'/`PP2'*100
 gen _P_Q= `PQ1'/`PQ2'*100
 gen `PPc'= `PP1c'/`PP2c'
 gen `PQc'= `PQ1c'/`PQ2c'
 egen `LP1' = rowtotal(`LP1'_*)
 egen `LP2' = rowtotal(`LP2'_*)
 egen `LQ1' = rowtotal(`LQ1'_*)
 egen `LQ2' = rowtotal(`LQ2'_*)
 egen `LP1c' = rowtotal(`LP1c'_*)
 egen `LP2c' = rowtotal(`LP2c'_*)
 egen `LQ1c' = rowtotal(`LQ1c'_*)
 egen `LQ2c' = rowtotal(`LQ2c'_*)
 gen _L_P= `LP1'/`LP2'*100
 gen _L_Q= `LQ1'/`LQ2'*100
 gen `LPc'= `LP1c'/`LP2c'
 gen `LQc'= `LQ1c'/`LQ2c'
 egen `PoQo' = rowtotal(`PoQo'_*)
 egen `PoQt' = rowtotal(`PoQt'_*)
 egen `PtQo' = rowtotal(`PtQo'_*)
 egen `PtQt' = rowtotal(`PtQt'_*)
 gen _F_P= sqrt(_L_P*_P_P)
 gen _F_Q= sqrt(_L_Q*_P_Q)
 gen `FPc'= sqrt(`LPc'*`PPc')
 gen `FQc'= sqrt(`LQc'*`PQc')
 egen `MEP1' =rowtotal(`MEP1'_*)
 egen `MEP2' =rowtotal(`MEP2'_*)
 egen `MEQ1' = rowtotal(`MEQ1'_*)
 egen `MEQ2' = rowtotal(`MEQ2'_*)
 gen _ME_P= `MEP1'/`MEP2'*100
 gen _ME_Q= `MEQ1'/`MEQ2'*100
 egen `WP1'=rowtotal(`WP1'_*)
 egen `WP2'=rowtotal(`WP2'_*)
 egen `WQ1'=rowtotal(`WQ1'_*)
 egen `WQ2'=rowtotal(`WQ2'_*)
 gen _W_P= `WP1'/`WP2'*100
 gen _W_Q= `WQ1'/`WQ2'*100
 gen _B_P= 0.5*(_L_P+_P_P)
 gen _B_Q= 0.5*(_L_Q+_P_Q)
 gen `BPc'= 0.5*(`LPc'+`PPc')
 gen `BQc'= 0.5*(`LQc'+`PQc')
 egen `MP1' = rowtotal(`MP1'_*)
 egen `MP2' = rowtotal(`MP2'_*)
 egen `MQ1' = rowtotal(`MQ1'_*)
 egen `MQ2' = rowtotal(`MQ2'_*)
 egen `MPw1' = rowtotal(`MPw1'_*)
 egen `MPw2' = rowtotal(`MPw2'_*)
 egen `MQw1' = rowtotal(`MQw1'_*)
 egen `MQw2' = rowtotal(`MQw2'_*)
 gen _M_P= `MP1'/`MP2'*100
 gen _M_Q= `MQ1'/`MQ2'*100
 gen _M_Pw= `MPw1'/`MPw2'*100
 gen _M_Qw= `MQw1'/`MQw2'*100
 egen `GLP' = rowtotal(`GLP'_*)
 egen `GLQ' = rowtotal(`GLQ'_*)
 replace `GLP'=exp(`GLP')
 replace `GLQ'=exp(`GLQ')
 gen _GL_P= `GLP'*100
 gen _GL_Q= `GLQ'*100
 egen `HMP1' = rowtotal(`HMP1'*)
 egen `HMP2' = rowtotal(`HMP2'*)
 egen `HMQ1' = rowtotal(`HMQ1'*)
 egen `HMQ2' = rowtotal(`HMQ2'*)
 gen _HM_P = `HMP1'/`HMP2'*100
 gen _HM_Q = `HMQ1'/`HMQ2'*100

 local LVN " `TTPc' `TTQc' `PPc' `PQc' `LPc' `LQc' `FPc' `FQc' `BPc' `BQc' "
 local CHN " _TT_Pc _TT_Qc _P_Pc _P_Qc _L_Pc _L_Qc _F_Pc _F_Qc _B_Pc _B_Qc "
qui foreach v in `LVN' {
 gen `Ch1'`v'=`v'*100
 gen `Ch2'`v'=`v'*100
qui forvalue i =`base1'/`NC' {
 replace `Ch1'`v' = `Ch2'`v'[`i']*`Ch2'`v'[`i'-1]/100  if _n > `base1'
 replace `Ch2'`v' = `Ch1'`v' in `i'/`i'
  }
 }

qui forvalue j=1/10 {
 local v: word `j' of `LVN'
 local m: word `j' of `CHN'
 gen `m' = `Ch2'`v'
 }
 }

di _dup(50) "="
di as txt _col(1) "{bf:{err:***  Price, Quantity, and Value Index Numbers  ***}}"
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*  (1) Divisia Index (Tornqvist–Theil)}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (2) Paasche Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (3) Laspeyres Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (4) Fisher Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (5) Marshall-Edgeworth Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (6) Walsh Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (7) Bowley Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (8) Mitchell Index}}" _col(50) "{bf:{err:*}}"
* di as txt _col(2) "{bf:{err:*  (9) Geometric Mean Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:*  (9) Geometric Laspeyres Index}}" _col(50) "{bf:{err:*}}"
di as txt _col(2) "{bf:{err:* (10) Harmonic Mean Index}}" _col(50) "{bf:{err:*}}"
di as txt "{bf:{hline 50}}"
if "`lhs'"=="p" {
di as txt _col(2) "{bf:* LHS: Left  Hand Side = Price     [ LHS( P ) ]}"
 }
if "`lhs'"=="q" {
di as txt _col(2) "{bf:* LHS: Left  Hand Side = Quantity  [ LHS( Q ) ]}"
 }
if "`rhs'"=="q"  {
di as txt _col(2) "{bf:* RHS: Right Hand Side = Quantity  [ RHS( Q ) ]}"
 }
if "`rhs'"=="v"  {
di as txt _col(2) "{bf:* RHS: Right Hand Side = Value     [ RHS( V ) ]}"
 }
di 
di as txt _col(2) "* Po = Price    at base time" _col(34) "* Pt = Price    at time t"
di as txt _col(2) "* Qo = Quantity at base time" _col(34) "* Qt = Quantity at time t"
di as txt _col(2) "* Yo = ALL Values at base time" _col(34) "* Yt = ALL Values at time t"
noi di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (1) Divisia Index (Tornqvist–Theil) ***}}"
di
di as txt _col(2) "*   Wo = (Po*Qo) / Yo"
di as txt _col(2) "*   Wt = (Pt*Qt) / Yt"
di as txt _col(2) "* TT_P = Sum{ 0.5 * (Wo+Wt) * [ln(Pt)-ln(Po)] }"
di as txt _col(2) "* TT_Q = Sum{ 0.5 * (Wo+Wt) * [ln(Qt)-ln(Qo)] }"
list _Year `it' `id' _TT_P _TT_Q _TT_Pc _TT_Qc , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _TT_P  = Divisia Price    Index"
di as txt _col(6) "* _TT_Q  = Divisia Quantity Index"
di as txt _col(6) "* _TT_Pc = Divisia Chained Price    Index"
di as txt _col(6) "* _TT_Qc = Divisia Chained Quantity Index"

di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (2) Paasche Index ***}}"
di
di as txt _col(2) "* P_P = Sum[Pt*Qt] / Sum(Po*Qt]"
di as txt _col(2) "* P_Q = Sum[Pt*Qt] / Sum(Pt*Qo]"
list _Year `it' `id' _P_P _P_Q  _P_Pc _P_Qc , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _P_P  = Paasche Price    Index"
di as txt _col(6) "* _P_Q  = Paasche Quantity Index"
di as txt _col(6) "* _P_Pc = Paasche Chained Price    Index"
di as txt _col(6) "* _P_Qc = Paasche Chained Quantity Index"
 
di
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (3) Laspeyres Index ***}}"
di
di as txt _col(2) "* L_P = Sum[Pt*Qo] / Sum[Po*Qo]"
di as txt _col(2) "* L_Q = Sum[Pt*Qt] / Sum[Po*Qo]"
list _Year `it' `id' _L_P _L_Q _L_Pc _L_Qc , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _L_P  = Laspeyres Price    Index"
di as txt _col(6) "* _L_Q  = Laspeyres Quantity Index"
di as txt _col(6) "* _L_Pc = Laspeyres Chained Price    Index"
di as txt _col(6) "* _L_Qc = Laspeyres Chained Quantity Index"

di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (4) Fisher Index ***}}"
di
di as txt _col(2) "* F_P = Sum[ sqrt(Laspeyres_P * Paasche_P) ]
di as txt _col(2) "* F_Q = Sum[ sqrt(Laspeyres_Q * Paasche_Q) ]
list _Year `it' `id' _F_P _F_Q _F_Pc _F_Qc , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _F_P  = Fisher Price    Index"
di as txt _col(6) "* _F_Q  = Fisher Quantity Index"
di as txt _col(6) "* _F_Pc = Fisher Chained Price    Index"
di as txt _col(6) "* _F_Qc = Fisher Chained Quantity Index"
 
di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (5) Marshall-Edgeworth Index ***}}"
di
di as txt _col(2) "* ME_P = Sum[Pt*(Qo+Qt)] / Sum[(Po*Qo)+(Po*Qt)]"
di as txt _col(2) "* ME_Q = Sum[Qt*(Po+Pt)] / Sum[(Po*Qo)+(Pt*Qo)]"
list _Year `it' `id' _ME_P _ME_Q , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _ME_P = Marshall-Edgeworth Price    Index"
di as txt _col(6) "* _ME_Q = Marshall-Edgeworth Quantity Index"

di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (6) Walsh Index ***}}"
di
di as txt _col(2) "* W_P = Sum[Pt*sqrt(Qo*Qt)] / Sum[Po*sqrt(Qo*Qt)]"
di as txt _col(2) "* W_Q = Sum[Qt*sqrt(Po*Pt)] / Sum[Qo*sqrt(Po*Pt)]"
list _Year `it' `id' _W_P _W_Q , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _W_P = Walsh Price    Index"
di as txt _col(6) "* _W_Q = Walsh Quantity Index"
di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (7) Bowley Index ***}}"
di
di as txt _col(2) "* B_P = Sum[ 0.5*(Laspeyres_P + Paasche_P) ]"
di as txt _col(2) "* B_Q = Sum[ 0.5*(Laspeyres_Q + Paasche_Q) ]"
list _Year `it' `id' _B_P _B_Q  _B_Pc _B_Qc , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _B_P  = Bowley Price    Index"
di as txt _col(6) "* _B_Q  = Bowley Quantity Index"
di as txt _col(6) "* _B_Pc = Bowley Chained Price    Index"
di as txt _col(6) "* _B_Qc = Bowley Chained Quantity Index"
 
di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (8) Mitchell Index ***}}"
di
di as txt _col(2) "* WtP  = 0.5 * (Po+ Pt)"
di as txt _col(2) "* WtQ  = 0.5 * (Qo+ Qt)"
di as txt _col(2) "* M_P  = Sum[Pt*WtQ] / Sum[Po*WtQ]"
di as txt _col(2) "* M_Q  = Sum[Qt*WtP] / Sum[Qo*WtP]"
di as txt _col(2) "* M_Pw = Sum[(Pt*WtQ/Po)] / Sum[WtQ]"
di as txt _col(2) "* M_Qw = Sum[(Qt*WtP/Qo)] / Sum[WtP]"
list _Year `it' `id' _M_P _M_Q _M_Pw _M_Qw , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _M_P = Mitchell Price    Index"
di as txt _col(6) "* _M_Q = Mitchell Quantity Index"

di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (9) Geometric Laspeyres Index ***}}"
di
di as txt _col(2) "* GL_P = Sum{ Wo * [ln(Pt)-ln(Po)] }"
di as txt _col(2) "* GL_Q = Sum{ Wo * [ln(Qt)-ln(Qo)] }"
list _Year `it' `id' _GL_P _GL_Q , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _GL_P = Geometric Laspeyres Price    Index"
di as txt _col(6) "* _GL_Q = Geometric Laspeyres Quantity Index"

di 
di as txt "{bf:{hline 50}}"
di as txt _col(2) "{bf:{err:*** (10) Harmonic Mean Index ***}}"
di
di as txt _col(2) "* HM_P = Sum[Po*Qo] / Sum[(Po^2)*Qo/Pt]"
di as txt _col(2) "* HM_Q = Sum[Po*Qo] / Sum[(Qo^2)*Po/Qt]"
list _Year `it' `id' _HM_P _HM_Q , separator(`NC') nocompress divider abbreviate(30)
di as txt _col(6) "* _HM_P = Harmonic Mean Price    Index"
di as txt _col(6) "* _HM_Q = Harmonic Mean Quantity Index"

 if "`simple'"!= "" {
di 
di as txt "{bf:{hline 55}}"
di as txt _col(2) "{bf:{err:*** Simple Price, Quantity, and Value Index Numbers ***}}"
qui forvalue i = 1/`nq' {
 local P : word `i' of `nlhs'
 local Q : word `i' of `nrhs'
noi di
noi di as txt " {bf:* (`i') Simple Index Number for Commodity:} " "`Q'"
noi list _Year _P_`i' _IP_`i' _Q_`i' _IQ_`i' _V_`i' _IV_`i' , separator(`NC') abbreviate(30)  nocompress divider noobs
 }
di as txt _col(6) "* _IP = Price    Simple Index Number [ Pt / Po * 100 ]"
di as txt _col(6) "* _IQ = Quantity Simple Index Number [ Qt / Qo * 100 ]"
di as txt _col(6) "* _IV = Value    Simple Index Number [ Vt / Vo * 100 ]"
 }

 if "`summ'"!="" {
di
di _dup(75) "{bf:{err:-}}"
di as txt "{bf:{err:*** Report Summary Statistics ***}}"
di _dup(70) "{bf:{err:-}}"
di 
di as txt " {bf:{err:* (1) Summary Statistics for Price Index Numbers:}}"
summ _TT_P _P_P _L_P _F_P _ME_P _W_P _B_P _M_P _M_Pw _GL_P _HM_P _TT_Pc ///
 _P_Pc _L_Pc _F_Pc _B_Pc , separator(16)
di 
di _dup(70) "{bf:{err:-}}"
di as txt " {bf:{err:* (2) Summary Statistics for Quantity Index Numbers:}}"
summ _TT_Q _P_Q _L_Q _F_Q _ME_Q _W_Q _B_Q _M_Q _M_Qw ///
 _GL_Q _HM_Q _TT_Qc _P_Qc _L_Qc _F_Qc _B_Qc , separator(16)
di "{err:{hline 78}}"
 }

 if "`chain'" != "" {
di 
di "{err:{hline 78}}"
di as txt " {bf:{err:*** Main Price & Quantity Index Numbers with CHAIN ***}}"
di 
di as txt " {bf:{err:* (1) (Divisia - Paasche - Laspeyres - Fisher) Index Numbers *}}"
list _TT_P _P_P _L_P _F_P _TT_Q _P_Q _L_Q _F_Q , separator(`NC') compress divider abbreviate(10)
di as txt _col(6) "* _TT_P = Divisia   Price Index" _col(46) "* _TT_Q = Divisia   Quantity Index"
di as txt _col(6) "*  _P_P = Paasche   Price Index" _col(46) "*  _P_Q = Paasche   Quantity Index"
di as txt _col(6) "*  _L_P = Laspeyres Price Index" _col(46) "*  _L_Q = Laspeyres Quantity Index"
di as txt _col(6) "*  _F_P = Fisher    Price Index" _col(46) "*  _F_Q = Fisher    Quantity Index"
di "{err:{hline 80}}"
di
di as txt " {bf:{err:* (2) (Divisia - Paasche - Laspeyres - Fisher) Chained Index Numbers *}}"
list _TT_Pc _P_Pc _L_Pc _F_Pc _TT_Qc _P_Qc _L_Qc _F_Qc , separator(`NC') compress divider abbreviate(10)
di as txt _col(6) "* _TT_P = Divisia   Chained Price Index" _col(46) "* _TT_Q = Divisia   Chained Quantity Index"
di as txt _col(6) "*  _P_P = Paasche   Chained Price Index" _col(46) "*  _P_Q = Paasche   Chained Quantity Index"
di as txt _col(6) "*  _L_P = Laspeyres Chained Price Index" _col(46) "*  _L_Q = Laspeyres Chained Quantity Index"
di as txt _col(6) "*  _F_P = Fisher    Chained Price Index" _col(46) "*  _F_Q = Fisher    Chained Quantity Index"
di "{err:{hline 80}}"
 } 

if ("`save'" != "") {
di
di as txt " {bf:{err:* Price Index Results File Has Been saved in:}}"
qui outsheet _TT_P _P_P _L_P _F_P _ME_P _W_P _B_P _M_P _M_Pw _GL_P _HM_P _TT_Pc _P_Pc ///
 _L_Pc _F_Pc _B_Pc _TT_Q _P_Q _L_Q _F_Q _ME_Q _W_Q _B_Q _M_Q _M_Qw _GL_Q _HM_Q _TT_Qc ///
 _P_Qc _L_Qc _F_Qc _B_Qc using "`save'.txt", delimiter(" ") replace
di
di as txt " {bf:Data Directory:}" _col(20) `"{browse "`c(pwd)'"}
di
di as txt " {bf:Open File:}" _col(20) `"{browse "`save'.txt"}
di "{err:{hline 50}}"
 }

 if "`list'"!= "" {
 qui {
 putmata _TT_P , replace
 putmata _TT_Q , replace
 putmata _P_P , replace
 putmata _P_Q , replace
 putmata _L_P , replace
 putmata _L_Q , replace
 putmata _F_P , replace
 putmata _F_Q , replace
 putmata _ME_P , replace
 putmata _ME_Q , replace
 putmata _W_P , replace
 putmata _W_Q , replace
 putmata _B_P , replace
 putmata _B_Q , replace
 putmata _M_P , replace
 putmata _M_Q , replace
 putmata _M_Pw , replace
 putmata _M_Qw , replace
 putmata _GL_P , replace
 putmata _GL_Q , replace
 putmata _HM_P , replace
 putmata _HM_Q , replace
 putmata _TT_Pc , replace
 putmata _TT_Qc , replace
 putmata _P_Pc , replace
 putmata _P_Qc , replace
 putmata _L_Pc , replace
 putmata _L_Qc , replace
 putmata _F_Pc , replace
 putmata _F_Qc , replace
 putmata _B_Pc , replace
 putmata _B_Qc , replace
 }
 }

if "`list'"== "" {
 qui cap mata: mata clear
 }
 ereturn local cmd "index"
 cap matrix drop _all
 end

program define indexlist , eclass
 version 11.2
 syntax [if] [in] , nvar(str) [simple]
 getmata _TT_P = _TT_P , force replace
 getmata _P_P = _P_P , force replace
 getmata _L_P = _L_P , force replace
 getmata _F_P = _F_P , force replace
 getmata _ME_P = _ME_P , force replace
 getmata _W_P = _W_P , force replace
 getmata _B_P = _B_P , force replace
 getmata _M_P = _M_P , force replace
 getmata _M_Pw = _M_Pw , force replace
 getmata _GL_P = _GL_P , force replace
 getmata _HM_P = _GL_P , force replace
 getmata _TT_Pc = _TT_Pc , force replace
 getmata _P_Pc = _P_Pc , force replace
 getmata _L_Pc = _L_Pc , force replace
 getmata _F_Pc = _F_Pc , force replace
 getmata _B_Pc = _B_Pc , force replace
 getmata _TT_Q = _TT_Q , force replace
 getmata _P_Q = _P_Q , force replace
 getmata _L_Q = _L_Q , force replace
 getmata _F_Q = _F_Q , force replace
 getmata _ME_Q = _ME_Q , force replace
 getmata _W_Q = _W_Q , force replace
 getmata _B_Q = _B_Q , force replace
 getmata _M_Q = _M_Q , force replace
 getmata _M_Qw = _M_Qw , force replace
 getmata _GL_Q = _GL_Q , force replace
 getmata _HM_Q = _GL_Q , force replace
 getmata _TT_Qc = _TT_Qc , force replace
 getmata _P_Qc = _P_Qc , force replace
 getmata _L_Qc = _L_Qc , force replace
 getmata _F_Qc = _F_Qc , force replace
 getmata _B_Qc = _B_Qc , force replace
 cap label variable _TT_P `"_TTP Divisia Price Index"'
 cap label variable _TT_Q `"_TTQ Divisia Quantity Index"'
 cap label variable _P_P `"_PP Paasche Price Index"'
 cap label variable _P_Q `"_PQ Paasche Quantity Index"'
 cap label variable _L_P `"_LP Laspeyres Price Index"'
 cap label variable _L_Q `"_LQ Laspeyres Quantity Index"'
 cap label variable _F_P `"_FP Fisher Price Index"'
 cap label variable _F_Q `"_FQ Fisher Quantity Index"'
 cap label variable _ME_P `"_MEP Marshall-Edgeworth Price    Index"'
 cap label variable _ME_Q `"_MEQ Marshall-Edgeworth Quantity Index"'
 cap label variable _W_P `"_WP Walsh Price Index"'
 cap label variable _W_Q `"_WQ Walsh Quantity Index"'
 cap label variable _B_P `"_BP Bowley Price Index"'
 cap label variable _B_Q `"_BQ Bowley Quantity Index"'
 cap label variable _M_P `"_MP Mitchell Price Index"'
 cap label variable _M_Q `"_MQ Mitchell Quantity Index"'
 cap label variable _M_Pw `"_MPW Mitchell Price Index"'
 cap label variable _M_Qw `"_MQW Mitchell Quantity Index"'
 cap label variable _GL_P `"_GLP Geometric Price Mean Index"'
 cap label variable _GL_Q `"_GLQ Geometric Quantity Mean Index"'
 cap label variable _HM_P `"_HMP Geometric Price Harmonic Index"'
 cap label variable _HM_Q `"_HMQ Geometric Quantity Harmonic Index"'
 cap label variable _TT_Pc `"_TT_Pc Divisia Chained Price Index"'
 cap label variable _TT_Qc `"_TT_Qc Divisia Chained Quantity Index"'
 cap label variable _P_Pc `"_P_Pc Paasche Chained Price Index"'
 cap label variable _P_Qc `"_P_Qc Paasche Chained Quantity Index"'
 cap label variable _L_Pc `"_L_Pc Laspeyres Chained Price Index"'
 cap label variable _L_Qc `"_L_Qc Laspeyres Chained Quantity Index"'
 cap label variable _F_Pc `"_F_Pc Fisher Chained Price Index"'
 cap label variable _F_Qc `"_F_Qc Fisher Chained Quantity Index"'
 cap label variable _B_Pc `"_B_Pc Bowley Chained Price Index"'
 cap label variable _B_Qc `"_B_Qc Bowley Chained Quantity Index"'

 if "`simple'"!= "" {
 local kPXY : word count `nvar'
qui forvalue i = 1/`kPXY' {
 getmata _IP_`i' = _IP_`i' , force replace
 getmata _IQ_`i' = _IQ_`i' , force replace
 getmata _IV_`i' = _IV_`i' , force replace
 cap label variable _IP_`i' `"_IP_`i' Simple Price Index"'
 cap label variable _IQ_`i' `"_IQ_`i' Simple Quantity Index"'
 cap label variable _IV_`i' `"_IV_`i' Simple Value Index"'
 }
 }
 end

