*! pem V2.0 15/04/2015
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
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define pem , eclass 
version 11.2
syntax varlist(numeric min=2 max=2) [if] [in] , model(string) QP(string) QC(string) ///
 ES(string) ED(string) [NOlist SAVE(string)]

qui cap drop _*
qui marksample touse
qui markout `touse' `varlist' , strok
tempname PEM PEM1 PEM2 Xb Xb1 Xb2
tempvar npc tmd tmw txd txw qpw qcw esw edw vpd vcd vpw vcw
 local sthlp pem
 local pd: word 1 of `varlist'
 local pw: word 2 of `varlist'
 local esd `es'
 local edd `ed'
 local qpd `qp'
 local qcd `qc'

 local both : list pd & pw
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both Pd and Pw Variables}"
di as res " pd: `pd'"
di as res " pw: `pw'"
 exit
 }
 local both : list qp & qc
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both QP and QC Variables}"
di as res " qp: `qp'"
di as res " qc: `qc'"
 exit
 }

if "`model'"!="" {
if !inlist("`model'", "expbl", "impbl", "expd", "expw", "impd", "impw") {
di
di as err "{bf:model()} {cmd:must be:} {bf:expbl, impbl, expd, expw, impd, impw}"
di
di in smcl _c "{cmd: see:} {help `sthlp'##03:Model Options}"
di in gr _c " (pem Help):"
 exit
 }
 }
di
tempvar tmd tmw txd txw qpw qcw vpd vpw esw edw vcd vcw

qui {
 cap gen `npc'=`pd'/`pw' if `touse'
if inlist("`model'", "impd", "impw", "impbl") {
 cap gen `tmd'=(`npc'-1)/`npc' if `touse'
 cap gen `tmw'=`npc'-1 if `touse'
 }
if inlist("`model'", "expd", "expw", "expbl") {
 cap gen `txd'=(1-`npc')/`npc' if `touse'
 cap gen `txw'=1-`npc' if `touse'
 }
 cap gen `qpw'=`qpd'-(`esd'*(`pd'-`pw')*`qpd'/`pd') if `touse'
 cap gen `qcw'=`qcd'-(`edd'*(`pd'-`pw')*`qcd'/`pd') if `touse'
 cap gen `vpd'=`pd'*`qpd' if `touse'
 cap gen `vpw'=`pw'*`qpw' if `touse'
 cap gen `esw'=`esd'*(`pw'*`qpd')/(`pd'*`qpw') if `touse'
 cap gen `edw'=`edd'*(`pw'*`qcd')/(`pd'*`qcw') if `touse'
 cap gen `vcd'=`pd'*`qcd' if `touse'
 cap gen `vcw'=`pw'*`qcw' if `touse'
 }
di _dup(78) "="
di as txt "{bf:{err:*** Partial EquiLibrium Model (PEM) ***}}"
di as txt "{bf:{hline 78}}"
if inlist("`model'", "expbl", "impbl") {
if inlist("`model'", "expbl") {
di as txt "{bf:{err:* Bale-Lutz (PEM) Model - Export Case}}"
di _dup(78) "{bf:=}"
 }
if inlist("`model'", "impbl") {
di as txt "{bf:{err:* Bale-Lutz (PEM) Model - Import Case}}"
di _dup(78) "{bf:=}"
 } 
qui cap gen _NELp=0.5*(`qpw'-`qpd')*(`pw'-`pd') if `touse'
qui cap gen _NELc=0.5*(`qcw'-`qcd')*(`pd'-`pw') if `touse'
qui cap gen _PS=`qpd'*(`pd'-`pw')-_NELp if `touse'
qui cap gen _CS=`qcd'*(`pw'-`pd')-_NELc if `touse'
qui cap gen _GR=-_NELp-_NELc-_PS-_CS if `touse'
qui cap gen _FE=-`pw'*(`qpw'-`qpd'+`qcd'-`qcw') if `touse'
qui cap gen _NET=_GR+_PS+_CS if `touse'
 }

if inlist("`model'", "expd") {
di as txt "{bf:{err:* Export Tax: [Private (Financial Price)] - Intervention Case}}"
di _dup(78) "{bf:{err:=}}"
qui gen _NELp= 0.5*`esd'*((1-`npc')/`npc')^2*`vpd' if `touse'
qui cap gen _NELc= abs(0.5*`edd'*((1-`npc')/`npc')^2*`vcd') if `touse'
qui cap gen _PS= -((((1-`npc')/`npc')*`vpd')+_NELp) if `touse'
qui cap gen _CS= ((((1-`npc')/`npc')*`vcd')-_NELc) if `touse'
qui cap gen _GR= ((1-`npc')/`npc')*(`vpd'-`vcd') if `touse'
qui cap gen _FE= -((1-`npc')/`npc'^2)*(`esd'*`vpd'-`edd'*`vcd') if `touse'
qui cap gen _NET= _GR+_PS+_CS if `touse'
 }

if inlist("`model'", "expw") {
di as txt "{bf:{err:* No Export Tax: [Social (Economic Price)] - No Intervention Case]}}"
di _dup(78) "{bf:{err:=}}"
qui cap gen _NELp= 0.5*`esw'*(1-`npc')^2*`vpw' if `touse'
qui cap gen _NELc= abs(0.5*`edw'*(1-`npc')^2*`vcw') if `touse'
qui cap gen _PS= -(((1-`npc')*`vpw')-_NELp) if `touse'
qui cap gen _CS= ((1-`npc')*`vcw')+_NELc if `touse'
qui cap gen _GR= (1-`npc')*(`vpw'*(1-`esw'*(1-`npc'))-`vcw'*(1-`edw'*(1-`npc'))) if `touse'
qui cap gen _FE = -((1-`npc')*(`esw'*`vpw'-`edw'*`vcw')) if `touse'
qui cap gen _NET= _GR+_PS+_CS if `touse'
 }

if inlist("`model'", "impd") {
di as txt "{bf:{err:* Import Tariff: [Private (Financial Price)] - Intervention Case}}"
di _dup(78) "{bf:{err:=}}"
qui cap gen _NELp= 0.5*`esd'*((`npc'-1)/`npc')^2*`vpd' if `touse'
qui cap gen _NELc= abs(0.5*`edd'*((`npc'-1)/`npc')^2*`vcd') if `touse'
qui cap gen _PS= (((`npc'-1)/`npc')*`vpd')-_NELp if `touse'
qui cap gen _CS= -((((`npc'-1)/`npc')*`vcd')+_NELc) if `touse'
qui cap gen _GR= ((`npc'-1)/`npc')*(`vcd'-`vpd') if `touse'
qui cap gen _FE= -((`npc'-1)/`npc'^2)*(`esd'*`vpd'-`edd'*`vcd') if `touse'
qui cap gen _NET= _GR+_PS+_CS if `touse'
 }

if inlist("`model'", "impw") {
di as txt "{bf:{err:* No Import Tariff: [Social (Economic Price)] - No Intervention Case}}"
di _dup(78) "{bf:{err:=}}"
qui cap gen _NELp= 0.5*`esw'*((`npc'-1)^2)*`vpw' if `touse'
qui cap gen _NELc= abs(0.5*`edw'*(`npc'-1)^2*`vcw') if `touse'
qui cap gen _PS= ((`npc'-1)*`vpw')+_NELp if `touse'
qui cap gen _CS= -(((`npc'-1)*`vcw')-_NELc) if `touse'
qui cap gen _GR= (`npc'-1)*(`vcw'*(1+`edw'*(`npc'-1))-`vpw'*(1+`esw'*(`npc'-1))) if `touse'
qui cap gen _FE= -((`npc'-1)*(`esw'*`vpw'-`edw'*`vcw')) if `touse'
qui cap gen _NET= _GR+_PS+_CS if `touse'
 }
 
 label variable _NELp `"Net Economic Loss in Production"'
 label variable _NELc `"Net Economic Loss in Consumption"'
 label variable _PS `"Change in Producer Surplus"'
 label variable _CS `"Change in Consumer Surplus"'
 label variable _GR `"Change in Government Revenue"'
 label variable _FE `"Change in Foreign Exchange"'
 label variable _NET `"Net Economic Loss"'
di

 if "`nolist'"==""  {
 qui {
if inlist("`model'", "expd", "expw", "expbl") {
 cap gen _TXD=`txd' if `touse'
 cap gen _TXW=`txw' if `touse'
 label variable _TXD `"Export Tax Rate"'
 label variable _TXW `"No Export Tax Rate"'
 }
if inlist("`model'", "impd", "impw", "impbl") {
 cap gen _TMD=`tmd' if `touse'
 cap gen _TMW=`tmw' if `touse'
 label variable _TMD `"Import Tariff Rate"'
 label variable _TMW `"No Import Tariff Rate"'
 }
 cap gen _QPD=`qpd' if `touse'
 cap gen _QPW=`qpw' if `touse'
 label variable _QPD `"Private Production Quantity"'
 label variable _QPW `"Social Production Quantity"'
 cap gen _QCD=`qcd' if `touse'
 cap gen _QCW=`qcw' if `touse'
 label variable _QCD `"Private Consumption Quantity"'
 label variable _QCW `"Social Consumption Quantity"'
 cap gen _VPD=`vpd' if `touse'
 cap gen _VPW=`vpw' if `touse'
 label variable _VPD `"Private Production Value"'
 label variable _VPW `"Social Production Value"'
 cap gen _ESD=`esd' if `touse'
 cap gen _ESW=`esw' if `touse'
 label variable _ESD `"Private Supply Price Elasticity"'
 label variable _ESW `"Social Supply Price Elasticity"'
 cap gen _EDD=`edd' if `touse'
 cap gen _EDW=`edw' if `touse'
 label variable _EDD `"Private Demand Price Elasticity"'
 label variable _EDW `"Social Demand Price Elasticity"'
 cap gen _VCD=`vcd' if `touse'
 cap gen _VCW=`vcw' if `touse'
 label variable _VCD `"Private Consumption Value"'
 label variable _VCW `"Social Consumption Value"'
 }

di as txt "{bf:{err:* Private (Financial Price) Variables:}}"
if inlist("`model'", "expd", "expw", "expbl") {
di as txt "{bf:* Txd : Export Tax Rate}"
 }
if inlist("`model'", "impd", "impw", "impbl") {
di as txt "{bf:* Tmd : Import Tariff Rate}"
 }
di as txt "{bf:* QPd : Production Quantity}"
di as txt "{bf:* VPd : Production Value}"
di as txt "{bf:* QCd : Consumption Quantity}"
di as txt "{bf:* VCd : Consumption Value}"
di as txt "{bf:* Esd : Supply Price Elasticity}"
di as txt "{bf:* Edd : Demand Price Elasticity}"
di _dup(78) "{bf:-}"
di as txt "{bf:{err:* Social (Economic Price) Variables:}}"
if inlist("`model'", "expd", "expw", "expbl") {
di as txt "{bf:* Txw : No Export Tax Rate}"
 }
if inlist("`model'", "impd", "impw", "impbl") {
di as txt "{bf:* Tmw : No Import Tariff Rate}"
 }
di as txt "{bf:* QPw : Production Quantity}"
di as txt "{bf:* VPw : Production Value}"
di as txt "{bf:* QCw : Consumption Quantity}"
di as txt "{bf:* VCw : Consumption Value}"
di as txt "{bf:* Esw : Supply Price Elasticity}"
di as txt "{bf:* Edw : Demand Price Elasticity}"
di _dup(78) "{bf:-}"

if inlist("`model'", "expd", "expw", "expbl") {
 mkmat _TXD _QPD _VPD _QCD _VCD _ESD _EDD if `touse' , matrix(`PEM1')
 mkmat _TXW _QPW _VPW _QCW _VCW _ESW _EDW if `touse' , matrix(`PEM2')
qui mean _TXD _QPD _VPD _QCD _VCD _ESD _EDD if `touse'
 matrix `Xb1'=e(b)
qui mean _TXW _QPW _VPW _QCW _VCW _ESW _EDW if `touse'
 matrix `Xb2'=e(b)
 matlist `PEM1', twidth(5) format(%10.3f) names(all) border(all) lines(columns)
 matrix  rownames `Xb1' = Mean
 matlist `Xb1', twidth(5) format(%10.3f) names(rows) border(all) lines(columns)
 matlist `PEM2', twidth(5) format(%10.3f) names(all) border(all) lines(columns)
 matrix  rownames `Xb2' = Mean
 matlist `Xb2', twidth(5) format(%10.3f) names(rows) border(all) lines(columns)
 }

if inlist("`model'", "impd", "impw", "impbl") {
 mkmat _TMD _QPD _VPD _QCD _VCD _ESD _EDD if `touse' , matrix(`PEM1')
 mkmat _TMW _QPW _VPW _QCW _VCW _ESW _EDW if `touse' , matrix(`PEM2')
qui mean _TMD _QPD _VPD _QCD _VCD _ESD _EDD if `touse'
 matrix `Xb1'=e(b)
qui mean _TMW _QPW _VPW _QCW _VCW _ESW _EDW if `touse'
 matrix `Xb2'=e(b)
 matlist `PEM1', twidth(5) format(%10.3f) names(all) border(all) lines(columns)
 matrix  rownames `Xb1' = Mean
 matlist `Xb1', twidth(5) format(%10.3f) names(rows) border(all) lines(columns)
 matlist `PEM2', twidth(5) format(%10.3f) names(all) border(all) lines(columns)
 matrix  rownames `Xb2' = Mean
 matlist `Xb2', twidth(5) format(%10.3f) names(rows) border(all) lines(columns)
 }
di
 }
di _dup(78) "="
di as txt "{bf:{err:*** Partial EquiLibrium Model (PEM) Results ***}}"
di as txt "{bf:{hline 78}}"
di as txt "{bf:* NELp: Net Economic Loss in Production}"
di as txt "{bf:* NELc: Net Economic Loss in Consumption}"
di as txt "{bf:*  PS : Change in Producer Surplus}"
di as txt "{bf:*  CS : Change in Consumer Surplus}"
di as txt "{bf:*  GR : Change in Government Revenue}"
di as txt "{bf:*  FE : Change in Foreign Exchange}"
if inlist("`model'", "expd", "expw", "expbl") {
di as txt "{bf:* NET : Net Economic Loss in Export}"
 }
if inlist("`model'", "impd", "impw", "impbl") {
di as txt "{bf:* NET : Net Economic Loss in Import}"
 }
di _dup(78) "="

qui mean _NELp _NELc _PS _CS _GR _FE _NET if `touse'
 matrix `Xb'=e(b)
 mkmat _NELp _NELc _PS _CS _GR _FE _NET if `touse' , matrix(`PEM')
 matlist `PEM', twidth(5) format(%10.3f) names(all) border(all) lines(columns)
 matrix  rownames `Xb' = Mean
 matlist `Xb', twidth(5) format(%10.3f) names(rows) border(all) lines(columns)
 ereturn matrix pem=`PEM'

if ("`save'" != "") {
di
di as txt "{bf:{err:*** Save Partial EquiLibrium Model (PEM) ***}}"
di as txt "{bf:*** Partial EquiLibrium Model (PEM) Results File Has Been saved in:}"
di
di as txt " {bf:Data Directory:}" _col(20) `"{browse "`c(pwd)'"}
di
di as txt " {bf:Open File:}" _col(20) `"{browse "`save'.txt"}
di "{err:{hline 50}}"
qui outsheet _NELp _NELc _PS _CS _GR _FE _NET using "`save'.txt",  delimiter(" ") replace
 }
end

