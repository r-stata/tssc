*! fbep V1.0 25/04/2016
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

 program define fbep , eclass 
 version 11.2
 syntax varlist(numeric min=2 max=2) [if] [in] , TFC(varname) [id(str) mp ///
 qh(varname) RATio(varname) TAX(varname) pf(varname) LIst PCM SAVE(str) txt]

di
 local uP: word 1 of `varlist'
 local uVC: word 2 of `varlist'
 local both : list uP & uVC
 if "`both'" != "" {
di as err " {bf:{cmd:`both'} cannot be included in both uP and uVC Variables}"
di as res "  uP: `uP'"
di as res " uVC: `uVC'"
 exit
 }
 if "`mp'"!="" {
 if "`id'"=="" {
di as err " {bf:id( )} {cmd:must be combined with option:} {bf:mp}" 
 exit
 }
 if "`ratio'"=="" {
di as err " {bf:ratio({var})} {cmd:option} {cmd:must be combined with:} {bf:mp}"
 exit
 } 
 }
 if "`mp'"=="" & "`ratio'"!="" {
di as err " {cmd:option} {bf:mp} {cmd:is valid only with:} {bf:ratio({var})}"
 exit
 }
 if "`pf'"=="" & "`tax'"!="" {
di as err " {cmd:option} {bf:pf({var})} {cmd:must be combined with:} {bf:tax({var})}"
 exit
 }
 cap mata: mata clear
 qui {
 marksample touse
 markout `touse'
 preserve
 tempvar Time idv P V Ps Vs TFC TFCf TFCx PF TX MCRw MCRw CMw CMRw
 mvencode * , mv(0) override
 cap drop _*
 if ("`if'" != "" | "`in'" != "") {
 keep `in' `if' 
 }
 keep `uP' `uVC' `tfc' `ratio' `id' `tax' `pf' `qh'
 gen `Time'=_n
 tsset `Time'
 gen _Tax = 0
 gen _Profit = 0
 if "`pf'" != "" {
 replace _Profit = `pf'
 }
 if "`tax'" != "" {
 replace _Profit = `pf'
 replace _Tax = `tax'/100
 }
 if "`mp'" != "" {
 egen `idv' = group(`id')
 xtset `idv'
 levelsof `idv' , local(levels)
 foreach i of local levels {
 summ `ratio' if `idv' == `i'
 local SumR=r(sum) 
 if `SumR'!=100 {
noi di as err "*** {bf:ratio(var) Summation must = 100}"
 exit
 }
 }
noi di _dup(75) "="
noi di as txt _col(6) "{bf:{err:*** Multiple Products Break-Even Point Analysis (BEP) ***}}"
noi di _dup(75) "="
 bysort `idv': gen double _TFC = `tfc'
 bysort `idv': gen double _uP = `uP'
 bysort `idv': gen double _uVC= `uVC'
 bysort `idv': gen double _uPw = `uP'*`ratio'/100
 bysort `idv': gen double _uVCw = `uVC'*`ratio'/100
 bysort `idv': egen double `Ps' = sum(_uPw)
 bysort `idv': egen double `Vs' = sum(_uVCw)


 bysort `idv': gen double _BEP_Q = _TFC/(`Ps'-`Vs')*`ratio'/100
 bysort `idv': gen double _BEP_V = _BEP_Q*`uP'
 if "`pcm'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** Contribution Margin}}" 
 bysort `idv': gen double _CM  = _uPw - _uVCw
 bysort `idv': gen double _MCR = _uVCw / _uPw*100
 bysort `idv': gen double _CMR = (_uPw - _uVCw) / _uPw*100
noi list `id' _CM _MCR _CMR , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:*  CM = Contribution Margin = (uPw - uVCw)}"
noi di as txt _col(6) "{bf:* MCR = Marginal Cost Ratio = (uVCw ÷ uPw) × 100}"
noi di as txt _col(6) "{bf:* CMR = Contribution Margin Ratio = (uPw - uVCw) ÷ uPw × 100}"
 }
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (1) Multiple Products Break-Even Point (BEP)}}" 
noi di as txt "{bf:{hline 75}}"
 levelsof `idv' , local(levels)
 foreach i of local levels {
 sum _BEP_Q if `idv' == `i'
 local SQs = r(sum)
 sum _BEP_V if `idv' == `i'
 local SVs = r(sum)
 sum _uPw if `idv' == `i'
 local SuPw = r(sum)
 sum _uVCw if `idv' == `i'
 local SuVCw = r(sum)
 local SCMw = `SuPw'-`SuVCw'
 local SMCRw = `SuVCw'/`SuPw'*100
 local SCMRw = 100-`SMCRw'
noi di as txt _col(3) "{bf:{err:* Product ( `i' )}}"
noi di as txt _col(3) "{bf:* Total Weighted Average Unit Price         (uPw)}" _col(56) "=" %14.3f `SuPw'
noi di as txt _col(3) "{bf:* Total Weighted Average Unit Variable Cost (uVCw)}" _col(56) "=" %14.3f `SuVCw'
noi di as txt _col(3) "{bf:* Total Weighted Contribution Margin        (CMw)}" _col(56) "=" %14.3f `SCMw'
noi di as txt _col(3) "{bf:* Total Weighted Marginal Cost Ratio        (MCRw)}" _col(56) "=" %14.3f `SMCRw'
noi di as txt _col(3) "{bf:* Total Weighted Contribution Margin Ratio  (CMRw)}" _col(56) "=" %14.3f `SCMRw'
noi di as txt _col(3) "{bf:* Total Break-Even Point (Units)            (BEP[Q])}" _col(56) "=" %14.3f `SQs'
noi di as txt _col(3) "{bf:* Total Break-Even Point (Value)            (BEP[V])}" _col(56) "=" %14.3f `SVs'
noi di _dup(70) "-"
 }

 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (1-1) Safety Margin of Multiple Products (BEP)}}" 
 bysort `idv': gen double _Qh=`qh'
 bysort `idv': gen double _SM_Q=_Qh-_BEP_Q
 bysort `idv': gen double _SMR_Q=_SM_Q/_Qh*100
 bysort `idv': gen double _Vh=_Qh*`uP'
 bysort `idv': gen double _SM_V=_Vh-_BEP_V
 bysort `idv': gen double _SMR_V=_SM_V/_Vh*100
noi list `id' _Qh _SM_Q _SMR_Q _Vh _SM_V _SMR_V , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Q) = Safety Margin of Quantity       [Qh - BEP(Q)]}"
noi di as txt _col(6) "{bf:* SMR(Q) = Safety Margin Ratio of Quantity [Qh - BEP(Q)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(V) = Safety Margin of Value          [Vh - BEP(V)]}"
noi di as txt _col(6) "{bf:* SMR(V) = Safety Margin Ratio of Value    [Vh - BEP(V)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list `id' _TFC _uP _uVC _uPw _uVCw _BEP_Q _BEP_V , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:*   TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*    uP = Unit Price}"
noi di as txt _col(6) "{bf:*   uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:*   uPw = Weighted Average Unit Price}"
noi di as txt _col(6) "{bf:*  uVCw = Weighted Average Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Q = Break-Even Point in Quantity (Units)}"
noi di as txt _col(6) "{bf:* BEP_V = Break-Even Point in Value    (Sales)}"
 if "`pf'" != "" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (2) Multiple Products Break-Even Point Target Profit (BEPf)}}" 
noi di as txt "{bf:{hline 75}}"
 bysort `idv': gen double `TFCf' = _TFC+_Profit
 bysort `idv': gen double _BEP_Qf = `TFCf'/(`Ps'-`Vs')*`ratio'/100
 bysort `idv': gen double _BEP_Vf = _BEP_Qf*`uP'
 foreach i of local levels {
 sum _BEP_Qf if `idv' == `i'
 local SQs = r(sum)
 sum _BEP_Vf if `idv' == `i'
 local SVs = r(sum)
noi di as txt _col(3) "{bf:{err:* Product ( `i' )}}"
noi di as txt _col(3) "{bf:* Total (BEP) Target Profit (Units) =}" _col(45) %15.3f `SQs'
noi di as txt _col(3) "{bf:* Total (BEP) Target Profit (Value) =}" _col(45) %15.3f `SVs'
noi di _dup(70) "-"
 }
 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (2-1) Safety Margin of Multiple Products Target Profit (BEPf)}}" 
 bysort `idv': gen double _SM_Qf=_Qh-_BEP_Qf
 bysort `idv': gen double _SMR_Qf=_SM_Qf/_Qh*100
 bysort `idv': gen double _SM_Vf=_Vh-_BEP_Vf
 bysort `idv': gen double _SMR_Vf=_SM_Vf/_Vh*100
noi list `id' _Qh _SM_Qf _SMR_Qf _Vh _SM_Vf _SMR_Vf , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Qf)= Safety Margin of Quantity       [Qh - BEP(Qf)]}"
noi di as txt _col(6) "{bf:* SMR(Qf)= Safety Margin Ratio of Quantity [Qh - BEP(Qf)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(Vf)= Safety Margin of Value          [Vh - BEP(Vf)]}"
noi di as txt _col(6) "{bf:* SMR(Vf)= Safety Margin Ratio of Value    [Vh - BEP(Vf)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list `id' _Profit _TFC _uP _uVC _BEP_Qf _BEP_Vf , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:* Profit = Target Profit}"
noi di as txt _col(6) "{bf:*    TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*    TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*     uP = Unit Price}"
noi di as txt _col(6) "{bf:*    uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Qf = Break-Even Point Target Profit (Units)}"
noi di as txt _col(6) "{bf:* BEP_Vf = Break-Even Point Target Profit (Value)}"
 }
 if "`tax'" != "" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (3) Multiple Products Break-Even Point Target Profit before Tax (BEPx)}}" 
noi di as txt "{bf:{hline 75}}"
 bysort `idv': gen double `TFCx' = _TFC+_Profit/(1-_Tax)
 bysort `idv': gen double _BEP_Qx = `TFCx'/(`Ps'-`Vs')*`ratio'/100
 bysort `idv': gen double _BEP_Vx = _BEP_Qx*`uP'
 foreach i of local levels {
 sum _BEP_Qx if `idv' == `i'
 local SQs = r(sum)
 sum _BEP_Vx if `idv' == `i'
 local SVs = r(sum)
noi di as txt _col(3) "{bf:{err:* Product ( `i' )}}"
noi di as txt _col(3) "{bf:* Total (BEP) Target Profit before Tax (Units) =}" _col(45) %15.3f `SQs'
noi di as txt _col(3) "{bf:* Total (BEP) Target Profit before Tax (Value) =}" _col(45) %15.3f `SVs'
noi di _dup(70) "-"
 }
 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (3-1) Safety Margin of Multiple Products Target Profit before Tax (BEPx)}}" 
 bysort `idv': gen double _SM_Qx=_Qh-_BEP_Qx
 bysort `idv': gen double _SMR_Qx=_SM_Qx/_Qh*100
 bysort `idv': gen double _SM_Vx=_Vh-_BEP_Vx
 bysort `idv': gen double _SMR_Vx=_SM_Vx/_Vh*100
noi list `id' _Qh _SM_Qx _SMR_Qx _Vh _SM_Vx _SMR_Vx , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Qx)= Safety Margin of Quantity       [Qh - BEP(Qx)]}"
noi di as txt _col(6) "{bf:* SMR(Qx)= Safety Margin Ratio of Quantity [Qh - BEP(Qx)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(Vx)= Safety Margin of Value          [Vh - BEP(Vx)]}"
noi di as txt _col(6) "{bf:* SMR(Vx)= Safety Margin Ratio of Value    [Vh - BEP(Vx)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list `id' _Profit _Tax _TFC _uP _uVC _BEP_Qx _BEP_Vx , abbreviate(30) sepby(`idv')
noi di as txt _col(6) "{bf:* Profit = Target Profit}"
noi di as txt _col(6) "{bf:*    Tax = Tax Rate}"
noi di as txt _col(6) "{bf:*    TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*     uP = Unit Price}"
noi di as txt _col(6) "{bf:*    uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Qx = Break-Even Point Target Profit before Tax (Units)}"
noi di as txt _col(6) "{bf:* BEP_Vx = Break-Even Point Target Profit before Tax (Value)}"
noi di as txt "{bf:{hline 75}}"
 }
 }
 qui {
 if "`mp'" == "" {
 gen double _TFC = `tfc'
 gen double _uP = `uP'
 gen double _uVC= `uVC'
 gen double _BEP_Q = _TFC/(`uP'-`uVC')
 gen double _BEP_V = _BEP_Q*`uP'
noi di _dup(75) "="
noi di as txt _col(6) "{bf:{err:*** Single Product Break-Even Point Analysis (BEP) ***}}"
noi di _dup(75) "="
noi di
 if "`pcm'"!="" {
noi di as txt "{bf:{err:** Contribution Margin}}" 
 gen double _MCR = `uVC' / `uP'*100
 gen double _CM  = `uP' - `uVC'
 gen double _CMR = (`uP' - `uVC') / `uP'*100
noi list _CM _MCR _CMR , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:*  CM = Contribution Margin = (uP - uVC)}"
noi di as txt _col(6) "{bf:* MCR = Marginal Cost Ratio = (uVC ÷ uP) x*100}"
noi di as txt _col(6) "{bf:* CMR = Contribution Margin Ratio = (uP - uVC) ÷ uP x 100}"
 }
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (1) Single Product Break-Even Point (BEP)}}" 
noi di as txt "{bf:{hline 75}}"
 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (1-1) Safety Margin of Single Product (BEP)}}" 
 gen double _Qh=`qh'
 gen double _SM_Q=_Qh-_BEP_Q
 gen double _SMR_Q=_SM_Q/_Qh*100
 gen double _Vh=_Qh*`uP'
 gen double _SM_V=_Vh-_BEP_V
 gen double _SMR_V=_SM_V/_Vh*100
noi list _Qh _SM_Q _SMR_Q _Vh _SM_V _SMR_V , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Q) = Safety Margin of Quantity       [Qh - BEP(Q)]}"
noi di as txt _col(6) "{bf:* SMR(Q) = Safety Margin Ratio of Quantity [Qh - BEP(Q)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(V) = Safety Margin of Value          [Vh - BEP(V)]}"
noi di as txt _col(6) "{bf:* SMR(V) = Safety Margin Ratio of Value    [Vh - BEP(V)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list _TFC _uP _uVC _BEP_Q _BEP_V , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:*   TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*    uP = Unit Price}"
noi di as txt _col(6) "{bf:*   uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Q = Break-Even Point in Quantity (Units)}"
noi di as txt _col(6) "{bf:* BEP_V = Break-Even Point in Value    (Sales)}"

 if "`pf'" != "" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (2) Single Product Break-Even Point Target Profit (BEPf)}}" 
noi di as txt "{bf:{hline 75}}"
 gen double `TFCf' = _TFC+_Profit
 gen double _BEP_Qf = `TFCf'/(`uP'-`uVC')
 gen double _BEP_Vf = _BEP_Qf*`uP'
 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (2-1) Safety Margin of Single Product Target Profit (BEPf)}}" 
 gen double _SM_Qf=_Qh-_BEP_Qf
 gen double _SMR_Qf=_SM_Qf/_Qh*100
 gen double _SM_Vf=_Vh-_BEP_Vf
 gen double _SMR_Vf=_SM_Vf/_Vh*100
noi list _Qh _SM_Qf _SMR_Qf _Vh _SM_Vf _SMR_Vf , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Qf)= Safety Margin of Quantity       [Qh - BEP(Qf)]}"
noi di as txt _col(6) "{bf:* SMR(Qf)= Safety Margin Ratio of Quantity [Qh - BEP(Qf)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(Vf)= Safety Margin of Value          [Vh - BEP(Vf)]}"
noi di as txt _col(6) "{bf:* SMR(Vf)= Safety Margin Ratio of Value    [Vh - BEP(Vf)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list _Profit _TFC _uP _uVC _BEP_Qf _BEP_Vf , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:* Profit = Target Profit}"
noi di as txt _col(6) "{bf:*    TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*     uP = Unit Price}"
noi di as txt _col(6) "{bf:*    uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Qf = Break-Even Point Target Profit (Units)}"
noi di as txt _col(6) "{bf:* BEP_Vf = Break-Even Point Target Profit (Value)}"
 }
 if "`tax'" != "" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (3) Single Product Break-Even Point Target Profit before Tax (BEPx)}}" 
noi di as txt "{bf:{hline 75}}"
 gen double `TFCx' = _TFC+_Profit/(1-_Tax)
 gen double _BEP_Qx = `TFCx'/(`uP'-`uVC')
 gen double _BEP_Vx = _BEP_Qx*`uP'
 if "`qh'"!="" {
noi di
noi di as txt "{bf:{hline 75}}"
noi di as txt "{bf:{err:** (3-1) Safety Margin of Single Product Target Profit before Tax (BEPx)}}" 
 gen double _SM_Qx=_Qh-_BEP_Qx
 gen double _SMR_Qx=_SM_Qx/_Qh*100
 gen double _SM_Vx=_Vh-_BEP_Vx
 gen double _SMR_Vx=_SM_Vx/_Vh*100
noi list _Qh _SM_Qx _SMR_Qx _Vh _SM_Vx _SMR_Vx , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:*     Qh = Expected Quantity}"
noi di as txt _col(6) "{bf:*  SM(Qx)= Safety Margin of Quantity       [Qh - BEP(Qx)]}"
noi di as txt _col(6) "{bf:* SMR(Qx)= Safety Margin Ratio of Quantity [Qh - BEP(Qx)] ÷ Qh × 100}"
noi di as txt _col(6) "{bf:*     Vh = Expected Value                  [Qh × _uP]}"
noi di as txt _col(6) "{bf:*  SM(Vx)= Safety Margin of Value          [Vh - BEP(Vx)]}"
noi di as txt _col(6) "{bf:* SMR(Vx)= Safety Margin Ratio of Value    [Vh - BEP(Vx)] ÷ Vh × 100}"
noi di as txt "{bf:{hline 75}}"
 }
noi list _Profit _Tax _TFC _uP _uVC _BEP_Qx _BEP_Vx , abbreviate(30) sepby(`Time')
noi di as txt _col(6) "{bf:* Profit = Target Profit}"
noi di as txt _col(6) "{bf:*    Tax = Tax Rate}"
noi di as txt _col(6) "{bf:*    TFC = Total Fixed Cost}"
noi di as txt _col(6) "{bf:*     uP = Unit Price}"
noi di as txt _col(6) "{bf:*    uVC = Unit Variable Cost}"
noi di as txt _col(6) "{bf:* BEP_Qx = Break-Even Point Target Profit before Tax (Units)}"
noi di as txt _col(6) "{bf:* BEP_Vx = Break-Even Point Target Profit before Tax (Value)}"
 }
 }
 }
 }
 if "`list'"!= "" {
 cap putmata _TFC , replace
 cap putmata _uP , replace
 cap putmata _uVC , replace
 cap putmata _BEP_Q , replace
 cap putmata _BEP_V , replace
 if "`mp'" != "" {
 cap putmata _uPw , replace
 cap putmata _uVCw , replace
 }
 if "`pf'"!="" {
 cap putmata _Profit , replace
 cap putmata _BEP_Qf , replace
 cap putmata _BEP_Vf , replace
 }
 if "`tax'"!="" {
 cap putmata _Tax , replace
 cap putmata _BEP_Qx , replace
 cap putmata _BEP_Vx , replace
 }
 if "`pcm'"!="" {
 cap putmata _MCR , replace
 cap putmata _CM , replace
 cap putmata _CMR , replace
 }
 if "`qh'"!="" {
 cap putmata _Qh , replace
 cap putmata _SM_Q , replace
 cap putmata _SMR_Q , replace
 cap putmata _Vh , replace
 cap putmata _SM_V , replace
 cap putmata _SMR_V , replace
 if "`pf'"!="" {
 cap putmata _SM_Qf , replace
 cap putmata _SMR_Qf , replace
 cap putmata _SM_Vf , replace
 cap putmata _SMR_Vf , replace
 }
 if "`tax'"!="" {
 cap putmata _SM_Qx , replace
 cap putmata _SMR_Qx , replace
 cap putmata _SM_Vx , replace
 cap putmata _SMR_Vx , replace
 }
 }
 }
 restore
 if "`list'"!= "" {
 cap getmata _TFC , force replace
 cap getmata _uP , force replace
 cap getmata _uVC , force replace
 if "`mp'" != "" {
 cap getmata _uPw , force replace
 cap getmata _uVCw , force replace
 label variable _uPw `"uPw = Weighted Average Unit Price"'
 label variable _uVCw `"uVCw = Weighted Average Unit Variable Cost"'
 }
 cap getmata _BEP_Q , force replace
 cap getmata _BEP_V , force replace
 label variable _TFC `"TFC = Total Fixed Cost"'
 label variable _uP `"uP = Unit Price"'
 label variable _uVC `"uVC = Unit Variable Cost"'
 label variable _BEP_Q `"BEP_Q = Break-Even Point in Quantity (Units)"'
 label variable _BEP_V `"BEP_V = Break-Even Point in Value    (Sales)"'
 if "`pf'"!="" {
 cap getmata _Profit , force replace
 cap getmata _BEP_Qf , force replace
 cap getmata _BEP_Vf , force replace
 label variable _Profit `"Profit = Target Profit"'
 label variable _BEP_Qf `"BEP_Qf = Break-Even Point Target Profit (Units)"'
 label variable _BEP_Vf `"BEP_Vf = Break-Even Point Target Profit (Value)"'
 }
 if "`tax'"!="" {
 cap getmata _Tax , force replace
 cap getmata _BEP_Qx , force replace
 cap getmata _BEP_Vx , force replace
 label variable _Tax `"Tax = Tax Rate"'
 label variable _BEP_Qx `"BEP_Qx = Break-Even Point Target Profit before Tax (Units)"'
 label variable _BEP_Vx `"BEP_Vx = Break-Even Point Target Profit before Tax (Value)"'
 }
 if "`pcm'"!="" {
 cap getmata _MCR , force replace
 cap getmata _CM , force replace
 cap getmata _CMR , force replace
 label variable _MCR `"MCR = Marginal Cost Ratio"'
 label variable _CM `"CM = Contribution Margin"'
 label variable _CMR `"CMR = Contribution Margin Ratio"'
 }
 if "`qh'"!="" {
 cap getmata _Qh , force replace
 cap getmata _SM_Q , force replace
 cap getmata _SMR_Q , force replace
 cap getmata _Vh , force replace
 cap getmata _SM_V , force replace
 cap getmata _SMR_V , force replace
 label variable _Qh `"Qh = Expected Quantity"'
 label variable _SM_Q `"SM(Q) = Safety Margin of Quantity"'
 label variable _SMR_Q `"SMR(Q) = Safety Margin Ratio of Quantity"'
 label variable _Vh `"Vh = Expected Value"'
 label variable _SM_V `"SM(V) = Safety Margin of Value"'
 label variable _SMR_V `"SMR(V) = Safety Margin Ratio of Value"'
 if "`pf'"!="" {
 cap getmata _SM_Qf , force replace
 cap getmata _SMR_Qf , force replace
 cap getmata _SM_Vf , force replace
 cap getmata _SMR_Vf , force replace
 label variable _SM_Qf `"SM(Qf) = Safety Margin of Quantity Target Profit"'
 label variable _SMR_Qf `"SMR(Qf) = Safety Margin Ratio of Quantity Target Profit"'
 label variable _SM_Vf `"SM(Vf) = Safety Margin of Value Target Profit"'
 label variable _SMR_Vf `"SMR(Vf) = Safety Margin Ratio of Value Target Profit"'
 }
 if "`tax'"!="" {
 cap getmata _SM_Qx , force replace
 cap getmata _SMR_Qx , force replace
 cap getmata _SM_Vx , force replace
 cap getmata _SMR_Vx , force replace
 label variable _SM_Qx `"SM(Qx) = Safety Margin of Quantity Target Profit before Tax"'
 label variable _SMR_Qx `"SMR(Qx) = Safety Margin Ratio of Quantity Target Profit before Tax"'
 label variable _SM_Vx `"SM(Vx) = Safety Margin of Value Target Profit before Tax"'
 label variable _SMR_Vx `"SMR(Vx) = Safety Margin Ratio of Value Target Profit before Tax"'
 }
 }
 }
 if "`save'" != "" {
 if "`txt'"!="" {
 local txt "delimiter(" ")"
 local txt1 "txt"
 }
 else {
 local txt "comma"
 local txt1 "csv"
 }
qui outsheet _* using "`save'", `txt' replace
noi di 
noi di as txt "{bf:{err:*** Save Break-Even Point Analysis ***}}"
noi di as txt "{bf:*** (BEP) Results File Has Been saved in:}"
noi di
noi di as txt " {bf:Data Directory:}" _col(20) `"{browse "`c(pwd)'"}
noi di 
noi di as txt " {bf:Open File:}" _col(20) `"{browse "`save'.`txt1'"}
noi di "{err:{hline 50}}"
 }
 cap mata: mata drop *
 cap mata: mata clear
 ereturn local cmd "bep"
 end

