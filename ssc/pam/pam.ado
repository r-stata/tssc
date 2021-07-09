*! pam V2.0 15/04/2015
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

program define pam , eclass 
version 11.2
syntax varlist(numeric min=2 max=2) [if] [in] , DTC(string) WTC(string) ///
 DDF(string) WDF(string) [NOlist SAVE(string)]

qui cap drop _*
qui marksample touse
qui markout `touse' `varlist' , strok
tempname PAM PAM1 PAM2
tempvar dtct wtct ddft wdft

 local pd: word 1 of `varlist'
 local pw: word 2 of `varlist'
 local both : list pd & pw
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both Pd and Pw Variables}"
di as res " pd: `pd'"
di as res " pw: `pw'"
 exit
 }
 local both : list dtc & wtc
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both DTC and WTC Variables}"
di as res " dtc: `dtc'"
di as res " wtc: `wtc'"
 exit
 }
 local both : list ddf & wdf
 if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both DDF and WDF Variables}"
di as res " ddf: `ddf'"
di as res " wdf: `wdf'"
 exit
 }

 local kdtc : word count `dtc'
 local kwtc : word count `wtc'
 if "`kdtc'" != "`kwtc'" {
di
di as err " {bf:Number of Variables in (DTC) not Equal (WTC)}"
 exit
 }
 local kddf : word count `ddf'
 local kwdf : word count `wdf'
 if "`kddf'" != "`kwdf'" {
di
di as err " {bf:Number of Variables in (DDF) not Equal (WDF)}"
 exit
 }
 qui {
 egen `dtct' = rowtotal(`dtc'*) if `touse'
 sum  `dtct' if `touse' , meanonly
 egen `wtct' = rowtotal(`wtc'*) if `touse'
 sum  `wtct' if `touse' , meanonly
 egen `ddft' = rowtotal(`ddf'*) if `touse'
 sum  `ddft' if `touse' , meanonly
 egen `wdft' = rowtotal(`wdf'*) if `touse'
 sum  `wdft' if `touse' , meanonly
 } 
di
di _dup(70) "="
di as txt "{bf:{err:                      Policy Analysis Matrix (PAM)}}"
di as txt "{bf:{hline 70}}"
di as txt "{bf:*      Item        |  Revenue  |  Tradable  |  Domestic |   Profit   *}"
di as txt "{bf:*                  |           |   Inputs   |  Factors  |            *}"
di as txt "{bf:{hline 70}}"
di as txt "{bf:* Private Price    |     {bf:{red:A}}     |      {bf:{red:B}}     |     {bf:{red:C}}     |      {bf:{red:D}}     *}"
di as txt "{bf:{hline 70}}"
di as txt "{bf:* Social Price     |     {bf:{red:E}}     |      {bf:{red:F}}     |     {bf:{red:G}}     |      {bf:{red:H}}     *}"
di as txt "{bf:{hline 70}}"
di as txt "{bf:* Transfer         |     {bf:{red:I}}     |      {bf:{red:J}}     |     {bf:{red:K}}     |      {bf:{red:L}}     *}"
di as txt "{bf:{hline 70}}"
di

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (1)  (PVA) Private Value Added: A - B}}"
 cap gen _PVA=`pd'-`dtct' if `touse'
 label variable _PVA `"Private Value Added"'
if "`nolist'"==""  {
 list _PVA if `touse', string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (2)  (SVA) Social Value Added: E - F}}"
 cap gen _SVA=`pw'-`wtct' if `touse'
 label variable _SVA `"Social Value Added"'
if "`nolist'"==""  {
 list _SVA if `touse' , string(5)
 }
 
di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (3)   (PP) Private Profit: D = A - B - C}}"
 cap gen _PP=`pd'-`dtct'-`ddft' if `touse'
 label variable _PP `"Private Profit"'
if "`nolist'"==""  {
 list _PP if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (4)   (SP) Social Profit: H = E - F - G}}"
 cap gen _SP=`pw'-`wtct'-`wdft' if `touse'
 label variable _SP `"Social Profit"'
if "`nolist'"==""  {
 list _SP if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (5)   (PC) Private Cost: B + C}}"
 cap gen _PC=`dtct'+`ddft' if `touse'
 label variable _PC `"Private Cost"'
if "`nolist'"==""  {
 list _PC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (6)   (SC) Social Cost: F + G}}"
 cap gen _SC=`wtct'+`wdft' if `touse'
 label variable _SC `"Social Cost"'
if "`nolist'"==""  {
 list _SC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (7)   (OT) Output Transfer: I = A - E}}"
 cap gen _OT=`pd'-`pw' if `touse'
 label variable _OT `"Output Transfer"'
if "`nolist'"==""  {
 list _OT if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (8)   (IT) Input Transfer: J = B - F}}"
 cap gen _IT=`dtct'-`wtct' if `touse'
 label variable _IT `"Input Transfer"'
if "`nolist'"==""  {
 list _IT if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: *  (9)   (FT) Factor Transfer: K = C - G}}"
 cap gen _FT=`ddft'-`wdft' if `touse'
 label variable _FT `"Factor Transfer"'
if "`nolist'"==""  {
 list _FT if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (10)   (NT) Net Transfer: L = D - H = I - J - K}}"
 cap gen _NT=_PP-_SP if `touse'
 label variable _NT `"Net Transfer"'
if "`nolist'"==""  {
 list _NT if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (11)  (ESR) Economic Surplus Ratio: L ÷ D}}"
 cap gen _ESR=_NT/_PP if `touse'
 label variable _ESR `"Economic Surplus Ratio"'
if "`nolist'"==""  {
 list _ESR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (12) (NPCO) Nominal Protection Coefficient on Tradable Outputs: A ÷ E}}"
 cap gen _NPCO=`pd'/`pw' if `touse'
 label variable _NPCO `"NPC on Tradable Outputs"'
if "`nolist'"==""  {
 list _NPCO if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (13) (NPRO) Nominal Protection Rate on Tradable Outputs: NPCO - 1}}"
 cap gen _NPRO=_NPCO-1 if `touse'
 label variable _NPRO `"NPR on tradable Outputs"'
if "`nolist'"==""  {
 list _NPRO if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (14) (NPCI) Nominal Protection Coefficient on Tradable Inputs: B ÷ F}}"
qui {
 forvalue i = 1/`kdtc' {
 local vard : word `i' of `dtc'
 local varw : word `i' of `wtc'
 cap gen _NPCI_`vard'_`varw'=`vard'/`varw' if `touse'
 label variable _NPCI_`vard'_`varw' `"* NPCI `vard' / `varw' "'
 local ++i
 }
 }
qui cap drop 
 cap gen _NPCI=`dtct'/`wtct' if `touse'
 label variable _NPCI `"NPC on tradable Inputs"'
if "`nolist'"==""  {
 list _NPCI  _NPCI_* if `touse' , string(5) abbreviate(22)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (15) (NPRI) Nominal Protection Rate on Tradable Inputs: NPCI - 1}}"
qui {
 forvalue i = 1/`kdtc' {
 local vard : word `i' of `dtc'
 local varw : word `i' of `wtc'
 cap gen _NPRI_`vard'_`varw'=`vard'/`varw'-1 if `touse'
 label variable _NPRI_`vard'_`varw' `"* NPRI `vard' / `varw' "'
 local ++i
 }
 }
 cap gen _NPRI=_NPCI-1 if `touse'
 label variable _NPRI `"NPR on tradable Inputs"'
if "`nolist'"==""  {
 list _NPRI  _NPRI_* if `touse' , string(5) abbreviate(22)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (16)  (EPC) Effective Protection Coefficient: (A - B) ÷ (E - F)}}"
 cap gen _EPC=(`pd'-`dtct')/(`pw'-`wtct') if `touse'
 label variable _EPC `"Effective Protection Coefficient"'
if "`nolist'"==""  {
 list _EPC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (17)  (EPR) Effective Protection Rate: EPC - 1}}"
 cap gen _EPR=_EPC-1 if `touse'
 label variable _EPR `"Effective Protection Rate"'
if "`nolist'"==""  {
 list _EPR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (18)  (DRC) Domestic Resource Cost: G ÷ (E - F)}}"
 cap gen _DRC=`wdft'/(`pw'-`wtct') if `touse'
 label variable _DRC `"Domestic Resource Cost"'
if "`nolist'"==""  {
 list _DRC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (19)  (PCR) Private Cost Ratio: C ÷ (A - B)}}"
 cap gen _PCR=`ddft'/(`pd'-`dtct') if `touse'
 label variable _PCR `"Private Cost Ratio"'
if "`nolist'"==""  {
 list _PCR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (20)  (PCO) Profitability Coefficient: (A - B - C) ÷ (E - F - G) = D ÷ H}}"
 cap gen _PCO=(`pd'-`dtct'-`ddft')/(`pw'-`wtct'-`wdft') if `touse'
 label variable _PCO `"Profitability Coefficient"'
if "`nolist'"==""  {
 list _PCO if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (21)  (SRP) Subsidy Ratio to Producer: (D - H) ÷ E = L ÷ E}}"
 cap gen _SRP=(_PP-_SP)/`pw' if `touse'
 label variable _SRP `"Subsidy Ratio to Producer"'
if "`nolist'"==""  {
 list _SRP if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (22) (PCBR) Private Cost-Benefit Ratio: (B + C) ÷ A}}"
 cap gen _PCBR=(`dtct'+`ddft')/`pd' if `touse'
 label variable _PCBR `"Private Cost-Benefit Ratio"'
if "`nolist'"==""  {
 list _PCBR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (23) (SCBR) Social Cost-Benefit Ratio: (F + G) ÷ E}}"
 cap gen _SCBR=(`wtct'+`wdft')/`pw' if `touse'
 label variable _SCBR `"Social Cost-Benefit Ratio"'
if "`nolist'"==""  {
 list _SCBR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (24)  (PPR) Private Profitability Ratio: (A - B - C) ÷ A = D ÷ A}}"
 cap gen _PPR=(`pd'-`dtct'-`ddft')/`pd' if `touse'
 label variable _PPR `"Private Profitability Ratio"'
if "`nolist'"==""  {
 list _PPR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (25)  (SPR) Social Profitability Ratio: (E - F - G) ÷ E = H ÷ E}}"
 cap gen _SPR=(`pw'-`wtct'-`wdft')/`pw' if `touse'
 label variable _SPR `"Social Profitability Ratio"'
if "`nolist'"==""  {
 list _SPR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (26) (PCAC) Private Cost Adjustment coefficient: A ÷ (B + C) - 1}}"
 cap gen _PCAC=`pd'/(`dtct'+`ddft')-1 if `touse'
 label variable _PCAC `"Private Cost Adjustment coefficient"'
if "`nolist'"==""  {
 list _PCAC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (27) (SCAC) Social Cost Adjustment coefficient: E ÷ (F + G) - 1}}"
 cap gen _SCAC=`pw'/(`wtct'+`wdft')-1 if `touse'
 label variable _SCAC `"Social Cost Adjustment coefficient"'
if "`nolist'"==""  {
 list _SCAC if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (28) (PVAR) Private Value Added Ratio: (A - B) ÷ A}}"
 cap gen _PVAR=(`pd'-`dtct')/`pd' if `touse'
 label variable _PVAR `"Private Value Added Ratio"'
if "`nolist'"==""  {
 list _PVAR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (29) (SVAR) Social Value Added Ratio: (E - F) ÷ E}}"
 cap gen _SVAR=(`pw'-`wtct')/`pw' if `touse'
 label variable _SVAR `"Social Value Added Ratio"'
if "`nolist'"==""  {
 list _SVAR if `touse' , string(5)
 }

di as txt "{bf:{hline 75}}"
di as txt "{bf:{err: * (30) (DOFAR) Domestic Factors Ratio: C ÷ G}}"
qui {
 forvalue i = 1/`kddf' {
 local vard : word `i' of `ddf'
 local varw : word `i' of `wdf'
 cap gen _DOFAR_`vard'_`varw'=`vard'/`varw' if `touse'
 label variable _DOFAR_`vard'_`varw' `"* DOFAR `vard' / `varw' "'
 local ++i
 }
 }
 cap gen _DOFAR=`ddft'/`wdft' if `touse'
 label variable _DOFAR `"Domestic Factors Ratio"'
if "`nolist'"==""  {
 list _DOFAR _DOFAR_* if `touse' , string(5) abbreviate(22)
 }

di as txt "{bf:{hline 75}}"
mkmat _PVA _SVA _PP _SP _PC _SC _OT _IT _FT _NT _ESR _NPCO _NPRO _NPCI _NPCI_* _NPRI _NPRI_* if `touse', matrix(`PAM1')
mkmat _EPC _EPR _DRC _PCR _PCO _SRP _PCBR _SCBR _PPR _SPR _PCAC _SCAC _PVAR _SVAR _DOFAR _DOFAR_* if `touse', matrix(`PAM2')
matrix `PAM'=`PAM1',`PAM2'
matrix `PAM'=`PAM''
di
di _dup(75) "="
di as txt "{bf:{err:*** Policy Analysis Matrix (PAM) Results: ***}}"
di _dup(75) "="
matlist `PAM', twidth(15) format(%10.4f) names(all) border(all) lines(rows)
ereturn matrix pam=`PAM'

if ("`save'" != "") {
di
di as txt "{bf:{err:*** Save Policy Analysis Matrix (PAM) ***}}"
di as txt "{bf:*** Policy Analysis Matrix (PAM) Results File Has Been saved in:}"
di
di as txt " {bf:Data Directory:}" _col(20) `"{browse "`c(pwd)'"}
di
di as txt " {bf:Open File:}" _col(20) `"{browse "`save'.txt"}
di "{err:{hline 50}}"

qui outsheet _PVA _SVA _PP _SP _PC _SC _OT _IT _FT _NT _ESR _NPCO _NPRO _NPCI _NPCI_* _NPRI _NPRI_* _EPC _EPR ///
_DRC _PCR _PCO _SRP _PCBR _SCBR _PPR _SPR _PCAC _SCAC _PVAR _SVAR _DOFAR _DOFAR_* using "`save'.txt",  delimiter(" ") replace
 }
end

