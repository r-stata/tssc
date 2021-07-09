*! fxbcr V1.0 25/05/2016
*!
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi764.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi764.htm

 program define fxbcr , eclass
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
 syntax varlist(min=1) [if] [in] , [PEriod(int 1) List PRint DDR ///
 sac(str) sap(str) DR(str) DEF(str) INF(str)]

 if "`inf'"!="" & "`def'"!="" {
noi di as err " {bf:inf(#)} {cmd:cannot be combined with def(#)}"
 exit
 }
 local klhs : word count `lhsns'
 local i 1
 while (`i'<=`klhs') {
 local lhsn : word `i' of `lhsns'
 local junk : subinstr local lhsns "`lhsn'" "", word all count(local j)
 if `j' > 1 {
noi di as err " {bf:Do not Include the Same InFlow Variable More than Once}"
 exit
 }
 local i = `i' + 1
 }
 if "`period'"!="" {
 if !inlist("`period'", "1", "2", "3", "4", "12", "52", "365") {
noi di as err " {bf:pe( )} {cmd:for Seasonal Period must be:}
noi di as err " {bf:pe({it:1})}   {cmd:Yearly Rate}"
noi di as err " {bf:pe({it:2})}   {cmd:Half-Yearly Rate}"
noi di as err " {bf:pe({it:3})}   {cmd:Third-Yearly Rate}"
noi di as err " {bf:pe({it:4})}   {cmd:Quarter-Yearly Rate}"
noi di as err " {bf:pe({it:12})}  {cmd:Monthly Rate}"
noi di as err " {bf:pe({it:52})}  {cmd:Weekly Rate}"
noi di as err " {bf:pe({it:365})} {cmd:Daily Rate}"
 exit
 }
 }
 cap mata: mata clear
 } 
di
 preserve
 if ("`if'" != "" | "`in'" != "") {
 keep `in' `if' 
 }
 local rhs `varlist' `word'
 gettoken word 0 : 0, parse(" :, ")
 unab rhs : `varlist'
 local krhs : word count `rhs'
 local i 1
 while (`i'<=`krhs') {
 local rhsn : word `i' of `rhs'
 local junk : subinstr local rhs "`rhsn'" "", word all count(local j)
 if `j' > 1 {
noi di as err " {bf:Do not Include the Same OutFlow Variable More than Once}"
 exit
 }
 local i = `i' + 1
 }
 local kin : word count `varlist'
 forvalue k = 1/`kin' {
 local invu: word `k' of `lhsns'
 local otvu: word `k' of `varlist'
 local ncf1=`invu'[1]-`otvu'[1]
 if `ncf1' >= 0 {
noi di as err " {bf:NCF in First Observation Can not be Psitive}"
 exit
 }
 }
 famio , lhs(`lhsns') rhs(`varlist') sac(`sac') sap(`sap') dr(`dr') ///
 `list' period(`period') inf(`inf') def(`def') `ddr' `print'
 restore
 if `ncf1' < 0 {
 if "`list'"!= "" {
noi _famlist
 } 
 } 
 end

 program define famio , eclass
 syntax [if] [in] , LHS(string) RHS(string) [PEriod(int 1) List PRint ///
 sac(str) sap(str) DR(str) DEF(str) INF(str) DDR]

qui {
 local both : list lhs & rhs
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both LHS and RHS Variables}"
noi di as res " LHS: `lhs' "
noi di as res " RHS: `rhs'"
 exit
 }
 local kot : word count `lhs'
 local kin : word count `rhs'
 if "`kin'" != "`kot'" {
noi di as err " {bf:Number of Variables in (LHS) not Equal (RHS)}"
 exit
 }
noi di _dup(88) "="
noi di as txt _col(20) "{bf:{err:*** Benefit-Cost Ratio (BCR) ***}}"
noi di as txt "{bf:{hline 88}}"
 tempvar inf1 npv t t0 inotu otvd invd ncfu ncfd ncfus ncfds ti pt0
 tempname npv0 bc bc1 Ms Mb
 marksample touse
 markout `touse' `lhs' `rhs'
 gen `t0'=_n-1 
 gen `t'=_n 
 tsset `t'
 gen `ncfu'=.
 gen `npv'=.
 gen `inotu'=.
 gen `otvd'=.
 gen `invd'=.
 gen `ncfd'=.
 gen `ti' = .
 gen `ncfus'=.
 gen `ncfds'=.
 local pe `period'
 if "`period'"!="" {
 if inlist("`period'", "1") {
 tsset `t' , yearly
 local unit "Year"
 local pe = 1
 }
 if inlist("`period'", "2") {
 tsset `t' , halfyearly
 local unit "Half-Year"
 local pe = 0.5
 }
 if inlist("`period'", "4") {
 tsset `t' , quarterly
 local unit "Quarter-Year"
 local pe = 0.25
 }
 if inlist("`period'", "3") {
 local unit "Third-Year"
 local pe = 1/3
 }
 if inlist("`period'", "12") {
 tsset `t' , monthly
 local unit "Month"
 local pe = 30/365
 }
 if inlist("`period'", "52") {
 tsset `t' , weekly
 local unit "Week"
 local pe = 7/365
 }
 if inlist("`period'", "365") {
 tsset `t' , daily
 local unit "Day"
 local pe = 1/365
 }
 }
 local pei = 1/`pe'
 gen `pt0'=`t0'*`pe'
 local F0 = 0
 gen `inf1' = 1
 if "`def'" != "" {
 local F0 = `def'/100
 replace `inf1' = 1/(1+`F0')^`t0'
 }
 if "`inf'" != "" {
 local F0 = `inf'/100
 replace `inf1' =  (1+`F0')^`t0'
 }
 forvalue k = 1/`kin' {
 preserve
 local invu: word `k' of `lhs'
 local otvu: word `k' of `rhs'
 replace `invu'=`invu'*`inf1'
 replace `otvu'=`otvu'*`inf1'
 tempvar miss
 mark `miss'
 markout `miss' `invu' `otvu'
 keep if `miss' == 1
 if "`sap'" != "" {
 replace `invu'=`invu'*(`sap'/100+1)
 }
 if "`sac'" != "" {
 replace `otvu'=`otvu'*(`sac'/100+1)
 }
 replace `inotu' = `otvu'/`invu'
 cap count if `invu'!=.
 local N`k'=r(N)
 local Nx`k'=`N`k''*`pe'
 replace `ncfu'=`invu' - `otvu'
 forvalue i=1/`N`k'' { 
 local ncfu0=`ncfu'[`i']
 local kmin=0
 if `ncfu0' > 0 {
 local ncfu1=`ncfu0'
 local kmin=`i'
 count if `ncfu1' > 0
 continue, break
 }
 }
 summ `ncfu'
 local ncfusum`k'=r(sum)
 summ `ncfu' if `ncfu' > 0
 local ncfusump=r(sum)
 summ `ncfu' if `ncfu' < 0
 local ncfusumn=abs(r(sum))
noi di
 if `ncfu'[1]>=0 {
noi di _dup(88) "="
noi di as err "{bf: *** Benefit-Cost Ratio (BCR) for Project (`k'): [ `invu' = `otvu' ]}"
noi di as err "{bf: (NCF) Net Cash Flow Must be Negative Number at least in First Observation}"
noi di _dup(88) "="
noi di
 exit
 }
 if `ncfusum`k'' <=0 {
noi di
noi di _dup(88) "="
noi di as err "{bf: *** Benefit-Cost Ratio (BCR) for Project (`k'): [ `invu' = `otvu' ]}"
noi di as err "{bf: Summation of (NCF) Net Cash Flow is Negative or Zero, and must be Positive}"
noi di
noi noi di as txt _col(7) "Cost (`ncfusumn' >= `ncfusump') Benefit"
noi di _dup(88) "="
noi di
 exit
 }
 scalar `npv0'=.
 if "`dr'" != "" {
 local adr`k' = `dr'/100
 local xdr`k' = `adr`k''*`pe'
 }
 else {
 local i 1
 while ( `npv0' > 0) {
 local npv`k'=`npv0'
 local j =`i'/100
 if "`ddr'" != "" {
 local j =`i'/1000
 }
 replace `npv'= `ncfu'/(1+`j')^`t0'
 summ `npv' 
 scalar `npv0'=r(sum)
 local i = `i' + 1
 }
 local adr`k'=`j'-0.01
 local xdr`k'=`adr`k''*`pe'
 }
 local Rnr`k'= (1+`adr`k'')/(1+`F0')-1
 local Rrn`k'= (1+`adr`k'')*(1+`F0')-1
 replace `npv'= `ncfu'/(1+`xdr`k'')^`pt0'
 summ `npv'
 local npv`k'=r(sum)
 local npvc`k' = (1+`npv`k'')^`pe' - 1
 local npvs`k' = `npv`k''*`pe'
 replace `otvd'= `otvu'/(1+`xdr`k'')^`pt0'
 replace `invd'= `invu'/(1+`xdr`k'')^`pt0'
 replace `ncfd'= `invd' - `otvd'
 forvalue i=1/`N`k'' { 
 local ncfd0=`ncfd'[`i']
 local kmin=0
 if `ncfd0' > 0 {
 local ncfd1=`ncfd0'
 local kmin=`i'
 count if `ncfd1' > 0
 continue, break
 }
 }
 summ `invu'
 local cifu`k'=r(sum)
 summ `otvu'
 local cofu`k'=r(sum)
 summ `ncfu'
 local ncfusum`k'=r(sum)
 summ `ncfu' in 2/`N`k''
 local ncfua1=abs(`ncfu'[1])
 local ncfum=r(mean)
 local ncfus2=r(sum)
 local bcru`k'=`ncfus2'/`ncfua1'
 local cbru`k'=1/`bcru`k''
 summ `invd'
 local cifd`k'=r(sum)
 summ `otvd'
 local cofd`k'=r(sum)
 summ `ncfd'
 local ncfdsum`k'=r(sum)
 summ `ncfd' in 2/`N`k''
 local ncfda1=abs(`ncfd'[1])
 local ncfds2=r(sum)
 local bcrd`k'=`ncfds2'/`ncfda1'
 local cbrd`k'=1/`bcrd`k''
 local xbcru`k'= `bcru`k''*`pei'
 local xcbru`k'= `cbru`k''*`pei'
 local xbcrd`k'= `bcrd`k''*`pei'
 local xcbrd`k'= `cbrd`k''*`pei'
noi {
di _dup(88) "{err:=}"
di as err "{bf:*** Benefit-Cost Ratio (BCR) for Project (`k'): [ `invu' = `otvu' ]}"
 if "`def'" != "" | "`inf'" != "" {
 if "`def'" != "" {
di _dup(68) "-"
di as txt "{bf:** Cash Flow Variables Have been Converted ({err:Deflated}) from ({err:Nominal}) to ({err:Real}) Values}"
di
di as txt "{bf:{err:* (def): Inflation Rate}}" _col(44) "(" %5.3f `def' " %)" _col(58) "=" %9.4f `F0' _col(74) "({err:`unit'})"
 }
 if "`inf'" != "" {
di _dup(68) "-"
di as txt "{bf:** Cash Flow Variables Have been Converted ({err:Inflated}) from ({err:Real}) to ({err:Nominal}) Values}"
di
di as txt "{bf:{err:* (inf): Inflation Rate}}" _col(44) "(" %5.3f `inf' " %)" _col(58) "=" %9.4f `F0' _col(74) "({err:`unit'})"
 }
di as txt "{bf:*  (Rn): Nominal Discount Rate}" _col(44) "(" %5.3f `adr`k''*100 " %)" _col(58) "=" %9.4f `adr`k'' _col(74) "(Year)"
di as txt "{bf:* (Rnr): Nominal to Real Discount Rate}" _col(44) "(" %5.3f `Rnr`k''*100 " %)" _col(58) "=" %9.4f `Rnr`k'' _col(74) "(Year)"
di as txt "{bf:* (Rrn): Real to Nominal Discount Rate}" _col(44) "(" %5.3f `Rrn`k''*100 " %)" _col(58) "=" %9.4f `Rrn`k'' _col(74) "(Year)"
 }
di as txt _dup(88) "-"
di as txt "{bf:*   (AN): Number of Periods}" _col(58) "=" %9.0f `Nx`k''  _col(74) "(Year)"
 if !inlist("`period'", "1") {
di as txt "{bf:{err:*   (XN): Number of Periods}}" _col(58) "=" %9.0f `N`k''  _col(74) "({err:`unit'})"
 }
di _dup(88) "-"
di as txt "{bf:*  (ADR): Discount Rate}" _col(44) "(" %5.3f `adr`k''*100 " %)" _col(58) "=" %9.4f `adr`k'' _col(74) "(Year)"
 if !inlist("`period'", "1") {
di as txt "{bf:{err:*  (XDR): Discount Rate}}" _col(44) "(" %5.3f `xdr`k''*100 " %)" _col(58) "=" %9.4f `xdr`k'' _col(74) "({err:`unit'})"
 }
di _dup(88) "-"
 }
 if "`sap'" != "" | "`sac'" != "" {
 if "`sap'" != "" {
 if "`sap'" > "0" {
di as txt "{it:* Sensitivity Analysis Scenario - Increasing Cash Inflow  (Benefit) by ( `sap' % )} "
 }
 if "`sap'" < "0" {
di as txt "{it:* Sensitivity Analysis Scenario - Decreasing Cash Inflow  (Benefit) by ( `sap' % )} "
 }
 }
 if "`sac'" != "" {
 if "`sac'" > "0" {
di as txt "{it:* Sensitivity Analysis Scenario - Increasing Cash Outflow (Cost)    by (  `sac' % )} "
 }
 if "`sac'" < "0" {
di as txt "{it:* Sensitivity Analysis Scenario - Decreasing Cash Outflow (Cost)    by (  `sac' % )} "
 }
 }
di as txt "{bf:{hline 88}}"
 }
di as txt _col(10) "{bf: {err:*** Criterion ***}" _col(36) "{bf:* UnDiscount *}}" _col(58) "|" _col(60) "{bf:* {err:Discount} *}" _col(73) "{it:(adr= " %4.2f `adr`k''*100 " %)}"
di as txt "{bf:{hline 88}}"
di as txt "{bf: 1- (CIF): Cash Inflow  (Benefit)}" _col(36) "=" %13.3f `cifu`k'' _col(58) "|" _col(59) %13.3f `cifd`k''
di as txt "{bf: 2- (COF): Cash Outflow (Cost)}" _col(36) "=" %13.3f `cofu`k'' _col(58) "|" _col(59) %13.3f `cofd`k''
di as txt "{bf: 3- (NCF): Net Cash Flow}" _col(36) "=" %13.3f `ncfusum`k'' _col(58) "|" _col(59) %13.3f `ncfdsum`k''
di _dup(88) "-"
di as txt "{bf: 4- (BCR): Benefit-Cost Ratio}" _col(36) "=" %7.3f `xbcru`k'' _col(46) "("%6.2f `xbcru`k''*100 " %)" _col(58) "|" _col(59) %6.3f `xbcrd`k'' _col(66) "("%6.2f `xbcrd`k''*100 " %)" _col(74) "(Year)"
 if !inlist("`period'", "1") {
di as txt "{bf:{err: 4- (BCR): Benefit-Cost Ratio}}" _col(36) "=" %7.3f `bcru`k'' _col(46) "("%6.2f `bcru`k''*100 " %)" _col(58) "|" _col(59) %6.3f `bcrd`k'' _col(66) "("%6.2f `bcrd`k''*100 " %)" _col(74) "({err:`unit'})"
 }
 di _dup(88) "-"
di as txt "{bf: 5- (CBR): Cost-Benefit Ratio}" _col(36) "=" %7.3f `xcbru`k'' _col(46) "("%6.2f `xcbru`k''*100 " %)" _col(58) "|" _col(59) %6.3f `xcbrd`k'' _col(66) "("%6.2f `xcbrd`k''*100 " %)" _col(74) "(Year)"
 if !inlist("`period'", "1") {
di as txt "{bf:{err: 5- (CBR): Cost-Benefit Ratio}}" _col(36) "=" %7.3f `cbru`k'' _col(46) "("%6.2f `cbru`k''*100 " %)" _col(58) "|" _col(59) %6.3f `cbrd`k'' _col(66) "("%6.2f `cbrd`k''*100 " %)" _col(74) "({err:`unit'})"
 }
di as txt "{bf:{hline 88}}"
 }

 if "`print'"!= "" {
 local NK=`N`k''+10
 mkmat `t0' `invu' `otvu' `ncfu' `invd' `otvd' `ncfd' in 1/`N`k'' , matrix(`Ms')
 total `t0' `invu' `otvu' `ncfu' `invd' `otvd' `ncfd' in 1/`N`k''
 matrix `Mb'= e(b) 
 set matsize `NK'
 matrix `Ms'=`Ms' \ `Mb'
noi di

noi di _dup(88) "{bf:{err:-}}"
noi di as txt "{bf:{err:*** UnDiscounted and Discounted Cash Flow Values ***}}"
noi di as err "{bf:*** Project (`k'): [ `invu' = `otvu' ]}"
 matrix colnames `Ms' = Time CIF_u COF_u NCF_u CIF_d COF_d NCF_d
noi matlist `Ms', border(all) format(%10.3f) names(columns) lines(rowtotal) 
noi di as txt "{err: * (CIF_u) & (CIF_d): UnDiscounted & Discounted Cash INFlow   (Benefit)}"
noi di as txt "{err: * (COF_u) & (COF_d): UnDiscounted & Discounted Cash OUTFlow  (Cost)}"
noi di as txt "{err: * (NCF_u) & (NCF_d): UnDiscounted & Discounted Net Cash Flow (Benefit-Cost)}"
noi di _dup(88) "{bf:{err:-}}"
 }
 if "`list'"!= "" {
 mkmat `invu' , matrix(`invu')
 mkmat `otvu' , matrix(`otvu')
 mkmat `ncfu' , matrix(`ncfu')
 mkmat `invd' , matrix(`invd')
 mkmat `otvd' , matrix(`otvd')
 mkmat `ncfd' , matrix(`ncfd')
 cap mata: kmata = J(1,1,`kin')
 mata: st_numscalar("kmata", kmata)
 mata: CIFu`k'= st_matrix("`invu'")
 mata: COFu`k'= st_matrix("`otvu'")
 mata: NCFu`k'= st_matrix("`ncfu'")
 mata: CIFd`k'= st_matrix("`invd'")
 mata: COFd`k'= st_matrix("`otvd'")
 mata: NCFd`k'= st_matrix("`ncfd'")
 }
 restore
 }
 }
qui cap matrix drop _all
 if "`list'"== "" {
qui cap mata: mata clear
 }
 ereturn local cmd "fxbcr"
 end

 program define _famlist, eclass
 version 11.2
 syntax [if] [in]
 cap ereturn scalar kmata = scalar(kmata)
 cap local kmata=e(kmata)
qui forvalue k = 1/`kmata' {
 cap getmata _CIF_u`k'= CIFu`k' , force replace
 cap getmata _COF_u`k'= COFu`k' , force replace
 cap getmata _NCF_u`k'= NCFu`k' , force replace
 cap getmata _CIF_d`k'= CIFd`k' , force replace
 cap getmata _COF_d`k'= COFd`k' , force replace
 cap getmata _NCF_d`k'= NCFd`k' , force replace
 cap label variable _CIF_u`k' `"CIFu = UnDiscounted Cash INFlow (Benefit)"'
 cap label variable _COF_u`k' `"COFu = UnDiscounted Cash OUTFlow (Cost)"'
 cap label variable _NCF_u`k' `"NCFu = UnDiscounted Net Cash Flow (Benefit-Cost)"'
 cap label variable _CIF_d`k' `"CIFd = Discounted Cash INFlow (Benefit)"'
 cap label variable _COF_d`k' `"COFd = Discounted Cash OUTFlow (Cost)"'
 cap label variable _NCF_d`k' `"NCFd = Discounted Net Cash Flow (Benefit-Cost)"'
 }
 end


