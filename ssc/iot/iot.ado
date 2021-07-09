*! iot V2.0 12/04/2016
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

 program define iot , eclass 
 version 11.2
 syntax varlist , FD(varlist) [EXPort(str) IMPort(str) FC(str) INVt(int 1) ML(str) ///
 list SAVE(str) format(str) txt pall piost pis pos pist post pcmt pcm pssr pcheck pioth3 ///
 pia padjia pinvia pmliou pmliot pmlio1 pmlio2 piot1 piot2 piot3 pioth pioth1 pioth2]

di
 if "`invt'"!="" {
 if !inlist("`invt'", "1", "2") {
di as err " {bf:invt(#)} {cmd:number must be 1, 2}"
di as err " {bf:invt({it:1})} {cmd:Non-Competitive Import Model: { (I-A)^-1 }}"
di as err " {bf:invt({it:2})} {cmd:Competitive Import Model: { [I-(I-M)A]^-1 }}"
 exit
 } 
 }
 if inlist("`invt'", "2") & "`import'"=="" {
di as err " {cmd:option} {bf:import({it:var})} {cmd:must be combined with:} {bf:invt({it:2})}"
 exit
 } 
 local both `varlist'
qui _rmcoll `both' , coll noconstant 
 local both "`r(varlist)'"
 local both: list  varlist - both
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included more than Once in varlist}"
noi di as txt " VARS: `varlist'"
noi di as txt " Coll: `both'"
 exit
 }
 local both `fd'
qui _rmcoll `both' , coll noconstant
 local both "`r(varlist)'"
 local both: list  fd - both
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included more than Once in (FD)}"
noi di as txt " FD: `fd'"
noi di as txt " Coll: `both'"
 exit
 }
 local both: list varlist & fc
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both varlist & (FC) Variables}"
noi di as txt " VARS: `varlist'"
noi di as txt "   FC: `fd'"
 exit
 }
 local both: list varlist & fd
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both varlist & (FD) Variables}"
noi di as txt " VARS: `varlist'"
noi di as txt "   FD: `fd'"
 exit
 }
 local both: list varlist & export
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both varlist & (Export) Variables}"
noi di as txt "   VARS: `varlist'"
noi di as txt " Export: `export'"
 exit
 }
 local both: list varlist & import
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both varlist & (Import) Variables}"
noi di as txt "   VARS: `varlist'"
noi di as txt " Import: `import'"
 exit
 }
 local both: list varlist & ml
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both varlist & (ML) Variables}"
noi di as txt " VARS: `varlist'"
noi di as txt "   ML: `ml'"
 exit
 }
 local both: list fc & fd
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FC) & (FD) Variables}"
noi di as txt " FC: `fc'"
noi di as txt " FD: `fd'"
 exit
 }
 local both: list fc & export
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FC) & (Export) Variables}"
noi di as txt "    FC: `fc'"
noi di as txt " Export: `export'"
 exit
 }
 local both: list fc & import
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FC) & (Import) Variables}"
noi di as txt "    FC: `fc'"
noi di as txt " Import: `import'"
 exit
 }
 local both: list fc & ml
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FC) & (ML) Variables}"
noi di as txt " FC: `fc'"
noi di as txt " ML: `ml'"
 exit
 }
 local both: list fd & export
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FD) & (Export) Variables}"
noi di as txt "    FD: `fd'"
noi di as txt " Export: `export'"
 exit
 }
 local both: list fd & import
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FD) & (Import) Variables}"
noi di as txt "    FD: `fd'"
noi di as txt " Import: `import'"
 exit
 }
 local both: list fd & ml
 if "`both'" != "" {
noi di as err " {bf:{cmd:`both'} cannot be included in both (FD) & (ML) Variables}"
noi di as txt " FD: `fd'"
noi di as txt " ML: `ml'"
 exit
 }
 if "`pall'"!="" {
 local piost "piost"
 local pis "pis"
 local pos "pos"
 local pist "pist"
 local post "post"
 local pcmt "pcmt"
 local pcm "pcm"
 local pssr "pssr"
 local pcheck "pcheck"
 local pia "pia"
 local padjia "padjia"
 local pinvia "pinvia"
 local pmliou "pmliou"
 local pmliot pmliot""
 local pmlio1 "pmlio1"
 local pmlio2 "pmlio2"
 local piot1 "piot1"
 local piot2 "piot2"
 local piot3 "piot3"
 local pioth "pioth"
 local pioth1 "pioth1"
 local pioth2 "pioth2"
 local pioth3 "pioth3"
 }

qui {
 preserve
 mvencode * , mv(0) override
 tempvar  Oi Ij Xi Xj Vj Yi IMPi EXPi XMXi Yio SSRi SSR XMRi IMPR
 tempname Oi Ij Xi Xj Vj Yi IMPi EXPi XMXi Yio SSRi SSR XMRi IMPR IM IMP Xo
 tempname A I_A AdjI_A In InvI_A DetIA Oi1 Oi2 DIFF Yim IML Yih MLIO MLIO1 MLIO2
 tempname CHID Ms MLt ML MLIOU MLIOT VA W X Xim G J100 IOTR Mc Mr Mcc Mrr Row Col
 mkmat `varlist' , matrix(`Ms')
 local NROW=rowsof(`Ms')
 local NCOL=colsof(`Ms')
 if `NROW'!=`NCOL' {
noi di as err "*** {bf:Input-Output Sectors Matrix is not Square (`NCOL' x `NROW')}"
noi di as err "*** {bf:Number of Columns Must Equal Number of Rows}"
noi di as txt " *** {bf:Input  Sectors Name:}" _col(28) "(" `NCOL' ")" _col(35) "= " "`varlist'"
noi di as txt " *** {bf:Output Sectors Name:}" _col(28) "(" `NROW' ")" _col(35) "= " "`varlist'"
 exit
 }
 matrix `Xo'=J(_N,1,1)
 if "`fc'"!="" {
 mkmat `fc' , matrix(`Yih')
 local NCML=colsof(`Yih')
 if `NCML'!=1 {
noi di as err "*** {bf:fc(var) Forecasting Must be One Variable}"
 exit
 }
 }
 if "`export'"!="" {
 gen `EXPi'= `export'
 mkmat `export' , matrix(`EXPi')
 local NCML=colsof(`EXPi')
 if `NCML'!=1 {
noi di as err "*** {bf:export(var) Export Must be One Variable}"
 exit
 }
 }
 else {
 gen `EXPi'=0
 }
 if "`import'"!="" {
 gen `IMPi'= `import'
 mkmat `import' , matrix(`IMPi')
 local NCML=colsof(`IMPi')
 if `NCML'!=1 {
noi di as err "*** {bf:import(var) Import Must be One Variable}"
 exit
 }
 }
 else {
 gen `IMPi'=0
 }
 if "`ml'"!="" {
 mkmat `ml' , matrix(`ML')
 local NCML=colsof(`ML')
 if `NCML'!=1 {
noi di as err "*** {bf:ML(var) Multiplier Must be One Variable}"
 exit
 }
 }
 else {
 matrix `ML'=J(_N,1,1)
 }
 foreach var in `varlist' `export' `import' {
 summ `var'
 local Min=r(min)
 if `Min' < 0 {
noi di as err "*** {bf: `var' Must be Positive in all Observations}"
 exit
 }
 }
 matrix `In'=I(_N)
 if "`invt'"=="1"  {
 local Wtitle1 "Non-Competitive Import Model"
 local Mtitle1 "[(I-A)]"
 local Mtitle2 "[a(I-A)]"
 local Mtitle3 "{(I-A)^-1}"
 }
 if "`invt'"=="2"  {
 local Wtitle1 "Competitive Import Model"
 local Mtitle1 "[I-(I-M)A]"
 local Mtitle2 "{a[I-(I-M)A]}"
 local Mtitle3 "{[I-(I-M)A]^-1}}"
 }

noi di _dup(60) "{bf:{err:=}}"
noi di as txt " {bf:{err:       ***  Leontief Input-Output Table  ***}}"
noi di _dup(60) "{bf:{err:=}}"
noi di as txt " +---------------------------------------------------------+"
noi di as txt " | Sector | S1   S2   S3  ...  Si  |  Oi   |  Yi   | (R)Xi |"
noi di as txt " |========|========================|=======|=======|=======|"
noi di as txt " |     S1 | X11  X12  X13 ...  X1j |  O1   |  Y1   |  X1   |"
noi di as txt " |     S2 | X21  X22  X23 ...  X2j |  O2   |  Y2   |  X2   |"
noi di as txt " |     S3 | X31  X32  X33 ...  X3j |  O3   |  Y3   |  X3   |"
noi di as txt " |     .. | ...  ...  ... ... ...  |  ..   |  ..   |  ..   |"
noi di as txt " |     Sj | Xi1  Xi2  Xi3 ...  Xij |  Oi   |  Yi   |  Xi   |"
noi di as txt " |=========================================================|"
noi di as txt " |     Ij | I1   I2   I3  ...  Ij  | {err:Oi=Ij} |       |       |"
noi di as txt " +--------+------------------------+-------+-------+-------+"
noi di as txt " |     Vj | V1   V2   V3  ...  Vj  |       | {err:Yi=Vj} |       |"
noi di as txt " +--------+------------------------+-------+-------+-------+"
noi di as txt " |  (C)Xj | X1   X2   X3  ...  Xj  |       |       | {err:Xi=Xj} |"
noi di as txt " +=========================================================+"
noi di as txt " |  Oi = Intermediate Output (Demand)    (O1, O2,..., Oi)  |"
noi di as txt " |  Yi = Final        Output (Demand)    (Y1, Y2,..., Yi)  |"
noi di as txt " |  Xi = Total        Output (Demand)    (X1, X2,..., Xi)  |"
noi di as txt " {bf:{hline 59}}"
noi di as txt " |  Ij = Intermediate Input (Supply)     (I1, I2,..., Ij)  |"
noi di as txt " |  Vj = Value Added        (GDP)        (V1, V2,..., Vj)  |"
noi di as txt " |  Xj = Total        Input (Supply)     (X1, X2,..., Xj)  |"
noi di as txt " {bf:{hline 59}}"
noi di as txt " |         (A) = Technical Coefficients Matrix             |"
noi di as txt " |         (I) = Identity Matrix (n x n)                   |"
noi di as txt " |   (I-A) = Leontief Matrix (Non-Competitive Import Model)|"
noi di as txt " | [I-(I-M)*A] = Leontief Matrix (Competitive Import Model)|"
noi di as txt " |    (I-A)^-1 = Leontief Inverse Matrix (Multiplier)      |"
noi di as txt " {bf:{hline 59}}"

 local N= _N
 egen double `Oi'=rowtotal(`varlist')
 egen double `Yio'=rowtotal(`fd')
 gen double `Yi'=`Yio'+`EXPi'-`IMPi'
 gen double `Xi'=`Oi'+`Yi'
 mkmat `Oi' , matrix(`Oi')
 mkmat `Yi' , matrix(`Yi')
 mkmat `Xi' , matrix(`Xi')
 total `varlist'
 matrix `Ij'=e(b)'
 matrix `Vj'=`Xi'-`Ij'
 matrix `Xj'=`Vj'+`Ij'
 summ `Oi'
 local sOi=r(sum)
 summ `Yi'
 local sYi=r(sum)
 summ `Xi'
 local sXi=r(sum)
 tempname XCR XC XR1 XR2 XR3
 matrix `XC'=`Ms',`Oi',`Yi',`Xi'
 matrix `XR1'=`Ij'',`sOi',.,.
 matrix `XR2'=`Vj'',.,`sYi',.
 matrix `XR3'=`Xj'',.,.,`sXi'
 if "`format'"=="" {
 local form "format(%8.0f)"
 }
 else {
 local form "format(%`format')"
 }
 matrix `XCR'=`XC' \ `XR1' \ `XR2' \ `XR3'
 matrix colnames `XCR' = `varlist' Oi Yi "(R) Xi"
 matrix rownames `XCR' = `varlist' Ij Vj "(C) Xj"
noi matlist `XCR' , title({bf:{err:*** Leontief Input-Output Table ***}}) twidth(7) ///
 border(all) rowtitle(Sector) `form' nohalf lines(rctotal)
noi di as txt "* (Oi) Intermediate Output = (Ij) Intermediate Input" _col(54) "=" %15.3f `sOi'
noi di as txt "* (Yi) Final Output        = (Vj) Value Added" _col(54) "=" %15.3f `sYi'
noi di as txt "* (Xi) Total Output        = (Xj) Total Input" _col(54) "=" %15.3f `sXi'
noi di "{err:{hline 70}}"
noi di as err " {bf:*** `Wtitle1' ***}"
noi di as txt " *** {bf:Sectors Name}" _col(18) ": " "`varlist'"
noi di as txt " *** {bf:Final Demand}" _col(18) ": " "`fd'"
noi di as txt " {bf:*** Sectors Matrix: (`NROW' x `NCOL')}"
noi di "{err:{hline 73}}"

 mata: `Ms' = st_matrix("`Ms'")
 mata: `W'=`Ms':/`Ms'
 mata: _editmissing(`W', 0)
 mata: `W'=st_matrix("`W'",`W')
 matrix `Mc'=`W''
 matrix `Mr'=`W'
 mata: `Mcc' = st_matrix("`Mc'")
 mata: `Mrr' = st_matrix("`Mr'")
 getmata (`Mcc'*)=`Mcc' , force replace
 getmata (`Mrr'*)=`Mrr' , force replace
 egen double `Col' = rowtotal(`Mcc'*)
 egen double `Row' = rowtotal(`Mrr'*)
 mkmat `Row' in 1/`N' , matrix(`Row')
 mkmat `Col' in 1/`N' , matrix(`Col')
 matrix `Col'=`Col' \ .
 matrix `IOTR'=`W', `Row' \ `Col''
 matrix  rownames `IOTR' = `varlist' "Total(C)"
 matrix  colnames `IOTR' = `varlist' "Total(R)"
 if "`piost'"!="" {
 if "`format'"=="" {
 local form "format(%8.0f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOTR' , title({bf:{err:*** Input-Output Sectors Transactions ***}}) twidth(12) ///
 border(all) rowtitle(Sector) `form' nohalf lines(rctotal)
noi di "{err:{hline 73}}"
 }
 matrix `J100'=J(_N,1,100)'
 tempvar CoV RoV
 tempname CoM RoM
 foreach var of local varlist {
 summ `var'
 local svar=r(sum)
 gen double `CoV'_`var'=`var'/`svar'*100
 }
 mkmat `CoV'_* , matrix(`CoM')
 matrix `CoM'=`CoM' \ `J100'
 matrix rownames `CoM' = `varlist' "Total(C)"
 matrix colnames `CoM' = `varlist'
 if "`pis'"!="" {
 if "`format'"=="" {
 local form "format(%8.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `CoM' , title({bf:{err:*** Input Share (%) in Intermediate Input (Ij) ***}}) ///
 twidth(8) border(all) rowtitle(Sector) `form' nohalf lines(rowtotal)
noi di "{err:{hline 73}}"
 }
 foreach var of local varlist {
 gen double `RoV'_`var'=0
 forvalue i=1/`N' {
 replace `RoV'_`var'=`var'/`Oi'*100 in `i'
 }
 }
 mkmat `RoV'_* , matrix(`RoM')
 matrix `RoM'=`RoM', `J100''
 matrix rownames `RoM' = `varlist'
 matrix colnames `RoM' = `varlist' "Total(R)"
 if "`pos'"!="" {
 if "`format'"=="" {
 local form "format(%8.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `RoM' , title({bf:{err:*** Output Share (%) in Intermediate Output (Oi) ***}}) ///
 twidth(8) border(all) rowtitle(Sector) `form' nohalf lines(coltotal)
noi di "{err:{hline 73}}"
 }
 tempvar Ois Yis Ijs  Vjs 
 tempname Ois Yis Ijs  Vjs RoMx CoMx
 mata: `Ij' = st_matrix("`Ij'")
 getmata (`Ij')=`Ij' , force replace
 gen double `Vj'=`Xi'-`Ij'
 gen double `Ois'=`Oi'/`Xi'*100
 gen double `Yis'=`Yi'/`Xi'*100
 gen double `Ijs'=`Ij'/`Xi'*100
 gen double `Vjs'=`Vj'/`Xi'*100
 mkmat `Ij' `Ijs' `Vj' `Vjs' `Xi' , matrix(`CoMx')
 matrix  rownames `CoMx' = `varlist'
 matrix  colnames `CoMx' = Ij "Ijs (%)" Vj "Vjs (%)" Xj
 mkmat `Oi' `Ois' `Yi' `Yis' `Xi' , matrix(`RoMx')
 matrix  rownames `RoMx' = `varlist'
 matrix  colnames `RoMx' = Oi "Ois (%)" Yi "Yis (%)" Xi
 if "`pist'"!="" {
 if "`format'"=="" {
 local form "format(%11.2f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `CoMx' , title({bf:{err:*** Intermediate Input & Value Added Share in Total Intput ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Ij) = Intermediate Intput"
noi di as txt "* (Ijs)= Intermediate Intput Share in Total Intput (Xj)"
noi di as txt "* (Vj) = Value Added"
noi di as txt "* (Vjs)= Value Added Share in Total Intput (Xj)"
noi di as txt "* (Xj) = Total Intput"
noi di "{err:{hline 73}}"
 }
 if "`post'"!="" {
 if "`format'"=="" {
 local form "format(%11.2f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `RoMx' , title({bf:{err:*** Intermediate & Final Output Share in Total Output ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Oi) = Intermediate Output"
noi di as txt "* (Ois)= Intermediate Output Share in Total Output (Xi)"
noi di as txt "* (Yi) = Final Output"
noi di as txt "* (Yis)= Final Output Share in Total Output (Xi)"
noi di as txt "* (Xi) = Total Output"
noi di "{err:{hline 73}}"
 }
 matrix `G'=`Xo'*`Xo''*diag(`Xi')
 mata: `Ms' = st_matrix("`Ms'")
 mata: `G' = st_matrix("`G'")
 mata: `A'=`Ms':/`G'
 mata: `A'=st_matrix("`A'",`A')
 tempname Col1 Col2 Row1 Row2 Mr At sCol1 sCol2
 tempvar  Row1 Row2 Mr
 matrix `Mr'=`A''
 mata: `Mr' = st_matrix("`Mr'")
 getmata (`Mr'*)=`Mr' , force replace
 egen double `Row1'= rowtotal(`Mr'*)
 matrix `Row2'=J(_N,1,1)
 mkmat `Row1' in 1/`N' , matrix(`Row1')
 matrix `At'=`A' \ `Row1'' \ `Row2''
 matrix  rownames `At' = `varlist' "Value Added"  "Total Input"
 matrix  colnames `At' = `varlist'
 if "`pcmt'"!="" {
 if "`format'"=="" {
 local form "format(%8.4f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `At' , title({bf:{err:*** [(A)] Technical Coefficients Matrix Table ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di "{err:{hline 73}}"
 }
 matrix  rownames `A' = `varlist'
 matrix  colnames `A' = `varlist'
 if "`pcm'"!="" {
 if "`format'"=="" {
 local form "format(%8.4f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `A' , title({bf:{err:*** [(A)] Technical Coefficients Matrix ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di "{err:{hline 73}}"
 }
 if "`import'"!="" {
 gen double `XMXi'=`Yio'+`Oi'
 mkmat `XMXi' , matrix(`XMXi')
 gen double `XMRi'=`IMPi'/`XMXi'
 gen double `IMPR'=`XMRi'*100
 mkmat `IMPR' , matrix(`IMPR')
 mkmat `XMRi' , matrix(`XMRi')
 gen double `SSRi'=(1-`XMRi')*100
 mkmat `SSRi' , matrix(`SSRi')
 matrix `IM'=diag(`XMRi')
 matrix `SSR'=`IMPi', `XMXi', `IMPR', `SSRi'
 matrix  rownames `SSR' = `varlist'
 matrix  colnames `SSR' = Import Production "Import Rate %" "SSR (%)"
 if "`pssr'"!="" {
 if "`format'"=="" {
 local form "format(%13.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `SSR' , title({bf:{err:*** (SSR) Self Sufficiency Ratio ***}}) ///
 twidth(9) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt " * Production = Total Domestic Demand = Total Output - Export - Import"
noi di as txt " * Import Rate = Import / Production * 100"
noi di as txt " * SSR = Self Sufficiency Ratio = (100- Import Rate)"
noi di "{err:{hline 73}}"
 }
 }
 matrix `In'=I(_N)
 if "`invt'"=="1"  {
 matrix `I_A'=`In'-`A'
 }
 if "`invt'"=="2"  {
 matrix `I_A'=`In'-(`In'-`IM')*`A'
 }
 matrix `InvI_A'=inv(`I_A')
 matrix `Oi1'=`Xi'-`Yi'
 matrix `Oi2'=`A'*`Xi' 
 matrix `DIFF'=`Oi1'-`Oi2'
 matrix `CHID' = `Oi1' , `Oi2' , `DIFF'
 matrix rownames `CHID' = `varlist'
 matrix colnames `CHID' = Oi1 Oi2 Difference
 if "`pcheck'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `CHID' , title({bf:{err:*** Check Input-Output Table Matrix ***}}) twidth(15) ///
 `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt " * Oi1 = Xi - Y"
noi di as txt " * Oi2 = A * Xi"
noi di "{err:{hline 73}}"
 }
 matrix  rownames `I_A' = `varlist'
 matrix  colnames `I_A' = `varlist'
 if "`pia'"!="" {
 if "`format'"=="" {
 local form "format(%8.4f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `I_A' , title({bf:{err:*** `Mtitle1' Leontief Matrix ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di "{err:{hline 73}}"
 }
 matrix `DetIA'=det(`I_A')
 matrix `AdjI_A'=`InvI_A'*`DetIA'
 matrix  rownames `AdjI_A' = `varlist'
 matrix  colnames `AdjI_A' = `varlist'
 if "`padjia'"!="" {
 if "`format'"=="" {
 local form "format(%8.4f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `AdjI_A' , title({bf:{err:*** `Mtitle2' Adjusted Leontief Matrix ***}}) ///
 twidth(10) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di "{err:{hline 73}}"
 }
 matrix  rownames `InvI_A' = `varlist'
 matrix  colnames `InvI_A' = `varlist'
 if "`pinvia'"!="" {
 if "`format'"=="" {
 local form "format(%8.4f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `InvI_A' , title({bf:{err:*** `Mtitle3' Leontief Inverse Matrix ***}}) ///
 twidth(12) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di "{err:{hline 73}}"
 }
 tempname Mcc Mrr Row Col MLo ML1
 tempvar  Mcc Mrr Row Col
 matrix `MLo'= `InvI_A'
 matrix `X'=`InvI_A'*`Yi'
 matrix `Yim'=`Yi'+`ML'
 matrix `Xim'=`InvI_A'*`Yim'
 matrix `MLt'=`Xim'-`X'
 matrix `IML'=`MLo'
 matrix `ML1'= `InvI_A'*diag(`ML')
 matrix `Mc'=`IML''
 matrix `Mr'=`IML'
 mata: `Mcc' = st_matrix("`Mc'")
 mata: `Mrr' = st_matrix("`Mr'")
 getmata (`Mcc'*)=`Mcc' , force replace
 getmata (`Mrr'*)=`Mrr' , force replace
 egen double `Col' = rowtotal(`Mcc'*)
 egen double `Row' = rowtotal(`Mrr'*)
 summ `Col'
 scalar `sCol1'=r(sum)
 scalar `sCol2'= `N' / `sCol1'
 mkmat `Row' in 1/`N' , matrix(`Row')
 mkmat `Col' in 1/`N' , matrix(`Col')
 matrix `Col1'= `Col' \ `sCol1'\ .
 matrix `Col2'= `Col'*`sCol2'
 matrix `Col2'= `Col2' \ . \ `N'
 matrix `Row2'= `Row'*`sCol2'
 matrix `MLIOU'= `IML', `Row', `Row2' \ `Col1'' \ `Col2''
 matrix  rownames `MLIOU' = `varlist' "Total(C)" IER
 matrix  colnames `MLIOU' = `varlist' "Total(R)" IRR
 if "`pmliou'"!="" {
 if "`format'"=="" {
 local form "format(%11.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `MLIOU' , title({bf:{err:*** [MLIOU] Unit Input-Output Multiplier Table ***}}) ///
 twidth(10) border(all) `form' nohalf lines(rctotal) rowtitle(Sector)
noi di as txt " * IRR = Index Response Ratio = Index Sensitivity Dispersion"
noi di as txt " * IER = Index Effect   Ratio = Index Power Dispersion"
noi di "{err:{hline 73}}"
 }
 tempvar Mcc Mrr Row Col
 matrix `IML'=`ML1'
 matrix `Mc'=`IML''
 matrix `Mr'=`IML'
 mata: `Mcc' = st_matrix("`Mc'")
 mata: `Mrr' = st_matrix("`Mr'")
 getmata (`Mcc'*)=`Mcc' , force replace
 getmata (`Mrr'*)=`Mrr' , force replace
 egen double `Col' = rowtotal(`Mcc'*)
 egen double `Row' = rowtotal(`Mrr'*)
 summ `Col'
 scalar `sCol1'=r(sum)
 scalar `sCol2'= `N' / `sCol1'
 mkmat `Row' in 1/`N' , matrix(`Row')
 mkmat `Col' in 1/`N' , matrix(`Col')
 matrix `Col1'= `Col' \ `sCol1'\ .
 matrix `Col2'= `Col'*`sCol2'
 matrix `Col2'= `Col2' \ . \ `N'
 matrix `Row2'= `Row'*`sCol2'
 matrix `MLIOT'= `IML', `Row', `Row2' \ `Col1'' \ `Col2''
 matrix  rownames `MLIOT' = `varlist' "Total(C)" IER
 matrix  colnames `MLIOT' = `varlist' "Total(R)" IRR
 if "`pmliot'"!="" {
 if "`format'"=="" {
 local form "format(%11.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `MLIOT' , title({bf:{err:*** [MLIOT] Total Input-Output Multiplier Table ***}}) ///
 twidth(10) border(all) `form' nohalf lines(rctotal) rowtitle(Sector)
noi di as txt " * IRR = Index Response Ratio = Index Sensitivity Dispersion"
noi di as txt " * IER = Index Effect   Ratio = Index Power Dispersion"
noi di "{err:{hline 73}}"
 }
 matrix `MLIO1'=`ML', `MLt', `Yi', `Yim'
 tempname MLIO1_
 mata: `MLIO1_' = st_matrix("`MLIO1'")
 mata: `MLIO1_'=colsum(`MLIO1_')
 mata: `MLIO1_'=st_matrix("`MLIO1_'",`MLIO1_')
 matrix `MLIO1'= `MLIO1' \ `MLIO1_'
 matrix  rownames `MLIO1' = `varlist' Total
 matrix  colnames `MLIO1' = ML MLT Yi Yim
 if "`pmlio1'"!="" {
 if "`format'"=="" {
 local form "format(%12.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `MLIO1' , title({bf:{err:*** Total Input-Output Multiplier [Final Output (Demand)] ***}}) ///
 twidth(9) `form' names(all) border(all) lines(rowtotal) rowtitle(Sector)
noi di as txt " * ML  = Multiplier Variable"
noi di as txt " * MLT = Total Multiplier"
noi di as txt " * Yi  = Final Output (Demand)"
noi di as txt " * Yim = Final Output (Demand) after Multiplier"
noi di "{err:{hline 73}}"
 }
 matrix `MLIO2'=`ML', `MLt', `X', `Xim'
 tempname MLIO2_
 mata: `MLIO2_' = st_matrix("`MLIO2'")
 mata: `MLIO2_'=colsum(`MLIO2_')
 mata: `MLIO2_'=st_matrix("`MLIO2_'",`MLIO2_')
 matrix `MLIO2'= `MLIO2' \ `MLIO2_'
 matrix  rownames `MLIO2' = `varlist' Total
 matrix  colnames `MLIO2' = ML MLT Xi Xim
 if "`pmlio2'"!="" {
 if "`format'"=="" {
 local form "format(%12.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `MLIO2' , title({bf:{err:*** Total Input-Output Multiplier [Total Output (Demand)] ***}}) ///
 twidth(9) `form' names(all) border(all) lines(rowtotal) rowtitle(Sector)
noi di as txt " * ML  = Multiplier Variable"
noi di as txt " * MLT = Total Multiplier"
noi di as txt " * Xi  = Total Output (Demand) (Xi) (Xi = Xj)"
noi di as txt " * Xim = Total Output (Demand) after Multiplier"
noi di "{err:{hline 73}}"
 }
 matrix `MLIO'=`ML', `MLt', `Yi', `Yim', `X', `Xim'
 matrix  rownames `MLIO' = `varlist'
 matrix  colnames `MLIO' = ML MLT Yi Yim Xi Xim
 tempname IOT IOT1 IOT2 IOT3 IOTv
 if "`piot1'"!="" |  "`piot2'"!="" |  "`piot3'"!="" | {
noi di
noi di as txt "{bf:{hline 53}}"
noi di as txt "{bf:{err:*** Leontief Input-Output Table Results ***}}"
noi di as txt "{bf:{hline 53}}"
 }
 matrix `IOT1'=`Ms'
 matrix  rownames `IOT1' = `varlist'
 matrix  colnames `IOT1' = `varlist'
 if "`piot1'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOT1' , title({bf:{err:*** Input-Output Sectors ***}}) ///
 twidth(15) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Oi) Intermediate Output (Rows)"
noi di as txt "* (Ij) Intermediate Input  (columns)"
noi di "{err:{hline 73}}"
 }
 matrix `IOT2'=`Oi', `Yi', `Xi'
 matrix rownames `IOT2' = `varlist'
 matrix colnames `IOT2' = Oi Yi Xi
 if "`piot2'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOT2' , title({bf:{err:*** Output Sectors ***}}) ///
 twidth(15) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Oi) Intermediate Output"
noi di as txt "* (Yi) Final Output"
noi di as txt "* (Xi) Total Output"
noi di "{err:{hline 73}}"
 }
 matrix `IOT3'=`Ij', `Vj', `Xj'
 matrix colnames `IOT3' = Ij Vj Xj
 matrix rownames `IOT3' = `varlist'
 if "`piot3'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOT3' , title({bf:{err:*** Input Sectors ***}}) ///
 twidth(15) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Ij) Intermediate Input"
noi di as txt "* (Vj) Value Added"
noi di as txt "* (Xj) Total Input"
noi di "{err:{hline 73}}"
 }
 if "`fc'" != "" {
 tempvar Col Row Mcc Mrr Xih
 tempname Yih Xih Xjh Mh Vjh Ijh Oih XCRh IOTh IOTh1 IOTh2 IOTh3
 mkmat  `fc' , matrix(`Yih')
 matrix `Xih'=`InvI_A'*`Yih'
 matrix `Mh'=`A'*diag(`Xih')
 matrix `Mc'=`Mh''
 matrix `Mr'=`Mh'
 mata: `Mcc' = st_matrix("`Mc'")
 mata: `Mrr' = st_matrix("`Mr'")
 getmata (`Mcc'*)=`Mcc' , force replace
 getmata (`Mrr'*)=`Mrr' , force replace
 egen double `Col' = rowtotal(`Mcc'*)
 egen double `Row' = rowtotal(`Mrr'*)
 mkmat `Row' in 1/`N' , matrix(`Row')
 mkmat `Col' in 1/`N' , matrix(`Col')
 matrix `Oih'=`Row'
 matrix `Xih'=`Oih'+`Yih'
 matrix `Ijh'=`Col''
 matrix `Vjh'=`Xih'-`Col'
 matrix `Xjh'=`Vjh'+`Col'
 mata: `Oih' = st_matrix("`Oih'")
 getmata (`Oih')=`Oih' , force replace
 mata: `Yih' = st_matrix("`Yih'")
 getmata (`Yih')=`Yih' , force replace
 mata: `Xih' = st_matrix("`Xih'")
 getmata (`Xih')=`Xih' , force replace
 summ `Oih'
 local sOi=r(sum)
 summ `Yih'
 local sYi=r(sum)
 summ `Xih'
 local sXi=r(sum)
 tempname XC XR1 XR2 XR3
 matrix `XC'=`Mh',`Oih',`Yih',`Xih'
 matrix `XR1'=`Ijh',`sOi',.,.
 matrix `XR2'=`Vjh'',.,`sYi',.
 matrix `XR3'=`Xjh'',.,.,`sXi'
 matrix `XCRh'=`XC' \ `XR1' \ `XR2' \ `XR3'
 matrix rownames `XCRh' = `varlist' Ijh Vjh "(C) Xjh"
 matrix colnames `XCRh' = `varlist' Oih Yih "(R) Xih"
 if "`pioth'"!="" {
 if "`format'"=="" {
 local form "format(%8.1f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `XCRh' , title({bf:{err:*** Predicted (h) Leontief Input-Output Table ***}}) ///
 twidth(7) border(all) rowtitle(Sector) `form' nohalf lines(rctotal)
noi di as txt "* (Oih) Intermediate Output = (Ijh) Intermediate Input" _col(56) "=" %15.3f `sOi'
noi di as txt "* (Yih) Final Output        = (Vjh) Value Added" _col(56) "=" %15.3f `sYi'
noi di as txt "* (Xih) Total Output        = (Xjh) Total Input" _col(56) "=" %15.3f `sXi'
noi di "{err:{hline 70}}"
noi di as txt " *** {bf:Sectors Name}" _col(18) ": " "`varlist'"
noi di as txt " *** {bf:Predicted Final Demand}" _col(18) ": " "`fc'"
noi di as txt " {bf:*** Sectors Matrix: (`NROW' x `NCOL')}"
noi di "{err:{hline 73}}"
 ereturn matrix ioth=`XCRh'
 }
 matrix `IOTh1'=`Mh'
 matrix  rownames `IOTh1' = `varlist'
 matrix  colnames `IOTh1' = `varlist'
 if "`pioth1'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOTh1' , title({bf:{err:*** Predicted Input-Output Sectors ***}}) ///
 twidth(15) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Oih) Predicted Intermediate Output (Rows)"
noi di as txt "* (Ijh) Predicted Intermediate Input  (columns)"
noi di "{err:{hline 73}}"
 }
 matrix `IOTh2'=`Oih', `Yih', `Xih'
 matrix rownames `IOTh2' = `varlist'
 matrix colnames `IOTh2' = Oih Yih Xih
 if "`pioth2'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOTh2' , title({bf:{err:*** Predicted Output Sectors ***}}) ///
 twidth(15) `form' names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Oih) Predicted Intermediate Output"
noi di as txt "* (Yih) Predicted Final Output"
noi di as txt "* (Xih) Predicted Total Output"
noi di "{err:{hline 73}}"
 }
 matrix `IOTh3'=`Ijh'', `Vjh', `Xjh'
 matrix colnames `IOTh3' = Ijh Vjh Xjh
 matrix rownames `IOTh3' = `varlist'
 if "`pioth3'"!="" {
 if "`format'"=="" {
 local form "format(%15.3f)"
 }
 else {
 local form "format(%`format')"
 }
noi matlist `IOTh3' , title({bf:{err:*** Predicted Input Sectors ***}}) ///
 twidth(15) format(%15.3f) names(all) border(all) lines(columns) rowtitle(Sector)
noi di as txt "* (Ijh) Predicted Intermediate Input"
noi di as txt "* (Vjh) Predicted Value Added"
noi di as txt "* (Xjh) Predicted Total Input"
noi di "{err:{hline 73}}"
 }
 }
 cap drop _*
 local Msv ""
 local Mhv ""
 if "`save'" != "" {
 if "`txt'"!="" {
 local txt "delimiter(" ")"
 local txt1 "txt"
 }
 else {
 local txt "comma"
 local txt1 "csv"
 }
 }
 if "`fc'" != "" | "`list'" != "" | "`save'" != "" {
 forvalue i=1/`N' {
 local s: word `i' of `varlist'
 cap gen double _`s'=`s'
 unab Msv : `Msv' _`s'
 }
 if "`fc'" != "" {
 svmat double `Mh' 
 unab Mha : `Mh'*
 forvalue i=1/`N' {
 local s: word `i' of `varlist'
 local h: word `i' of `Mha'
 cap gen double _`s'_h=`h'
 unab Mhv : `Mhv' _`s'_h
 }
 }
 }
 if "`fc'" != "" {
 if "`list'" != "" | "`save'" != "" {
 matrix `IOTv'=`Ms', `Oi', `Yi', `Xi', `Ij', `Vj', `Xj', `Mh', `Oih', `Yih', ///
 `Xih', `Ijh'',`Vjh', `Xjh', `MLt', `Yim', `Xim'
 matrix colnames `IOTv' = `Msv' Oi Yi Xi Ij Vj Xj `Mhv' Oih Yih Xih Ijh Vjh Xjh ML Yim Xim
 matrix rownames `IOTv' = `varlist'
 svmat double `IOTv' , names( eqcol )
 if "`list'" != "" {
 putmata `Msv' _Oi _Yi _Xi _Ij _Vj _Xj `Mhv' _Oih _Yih _Xih ///
 _Ijh _Vjh _Xjh _ML _Yim _Xim , replace
 }
 if "`save'" != "" {
 outsheet `Msv' _Oi _Yi _Xi _Ij _Vj _Xj `Mhv' _Oih _Yih _Xih ///
 _Ijh _Vjh _Xjh _ML _Yim _Xim using "`save'", `txt' replace
 }
 }
 }
 else {
 if "`list'" != "" | "`save'" != "" {
 matrix `IOTv'=`Ms', `Oi', `Yi', `Xi', `Ij',`Vj', `Xj', `MLt', `Yim', `Xim'
 matrix colnames `IOTv' = `Msv' Oi Yi Xi Ij Vj Xj ML Yim Xim
 matrix rownames `IOTv' = `varlist'
 svmat double `IOTv' , names( eqcol )
 if "`list'" != "" {
 putmata `Msv' _Oi _Yi _Xi _Ij _Vj _Xj _ML _Yim _Xim , replace
 }
 if "`save'" != "" {
 outsheet `Msv' _Oi _Yi _Xi _Ij _Vj _Xj _ML _Yim _Xim ///
 using "`save'", `txt' replace
 }
 }
 }
 ereturn matrix a=`A'
 ereturn matrix invia=`MLo'
 matrix `IOT'=`IOT1', `IOT2'
 ereturn matrix iot=`IOT'
 ereturn matrix iott=`XCR'
 ereturn matrix at=`At'
 ereturn matrix ia=`I_A'
 ereturn matrix check=`CHID'
 ereturn matrix adjia=`AdjI_A'
 ereturn matrix inviam=`ML1'
 ereturn matrix ml=`MLIO'
 ereturn matrix mliou=`MLIOU'
 ereturn matrix mliot=`MLIOT'
 ereturn matrix ist=`CoMx'
 ereturn matrix ost=`RoMx'
 }
 restore
 if "`list'" != "" {
 if "`fc'" != "" {
 getmata `Msv' _Oi _Yi _Xi _Ij _Vj _Xj `Mhv' _Oih _Yih _Xih _Ijh _Vjh _Xjh _ML _Yim _Xim , replace
 if "`pall'"!="" {
 tabstat `Msv' _Oi _Ij _Yi _Vj _Xi _Xj `Mhv' _Oih _Ijh _Yih _Vjh _Xih _Xjh ///
 _ML _Yim _Xim , statistics(sum) columns(statistics) format(%15.3f)
 }
 }
 else {
 getmata `Msv' _Oi _Yi _Xi _Ij _Vj _Xj _ML _Yim _Xim , replace
 if "`pall'"!="" {
 tabstat `Msv' _Oi _Ij _Yi _Vj _Xi _Xj _ML _Yim _Xim , ///
 statistics(sum) columns(statistics) format(%15.3f)
 }
 }
 }
 if "`save'" != "" {
noi di 
noi di as txt "{bf:{err:*** Save Input-Output Table (IOT) ***}}"
noi di as txt "{bf:*** (IOT) Results File Has Been saved in:}"
noi di
noi di as txt " {bf:Data Directory:}" _col(20) `"{browse "`c(pwd)'"}
noi di 
noi di as txt " {bf:Open File:}" _col(20) `"{browse "`save'.`txt1'"}
noi di "{err:{hline 50}}"
 }
 cap mata: mata drop *
 cap mata: mata clear
 cap matrix drop _all
 ereturn local cmd "iot"
 end

