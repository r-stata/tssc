*! torumm.ado version 1.1.2 fw 12/23/00 convert stata files to rumm format
*! syntax varlist(numeric) [, FILEname(string) FACTors(varlist numeric max=3) REVerse(varlist) IDvar(varname) ]
*! rev 1.1.0 (12/18/01): adds length of label check

/*
itemSeq		Sequence of study items
testType	E = extended/polytomous M = multiple choice
itemCode	A maximum 5 character code describeing each item
itemState	A 30 character description (label)
respType	N = numeric  A = alpha  
respNumb	The number of possible responses
scKey		Scoring key: blank or R for reversed
respSeq		0 to 5 for numeric, A to E for alpha (the lowest level of response)

itemSeq	testType	itemCode	itemState	respType	respNumb	scKey	respSeq
1	E	I0001	Descriptor for Item 1	N	4		1
2	E	I0002	Descriptor for Item 2	N	4	R	1
3	E	I0003	Descriptor for Item 3	N	4		1
4	E	I0004	Descriptor for Item 4	N	4	R	1
5	E	I0005	Descriptor for Item 5	N	4	R	1
6	E	I0006	Descriptor for Item 6	N	4	R	1
7	E	I0007	Descriptor for Item 7	N	4		1
8	E	I0008	Descriptor for Item 8	N	4	R	1
9	E	I0009	Descriptor for Item 9	N	4	R	1
10	E	I0010	Descriptor for Item 10	N	4		1
11	E	I0011	Descriptor for Item 11	N	4	R	1
12	E	I0012	Descriptor for Item 12	N	4		1
13	E	I0013	Descriptor for Item 13	N	4	R	1
14	E	I0014	Descriptor for Item 14	N	4		1
15	E	I0015	Descriptor for Item 15	N	4		1
16	E	I0016	Descriptor for Item 16	N	4	R	1

*/

program define torumm
  	version 6.0
	syntax varlist(numeric) [, FILEname(string) FACTors(varlist numeric max=3) REVerse(varlist) IDvar(varname) ]
	tokenize `varlist'
   
   set more off
   
   preserve
   
   /* Process spc file items */
	
   qui dropvars itemSeq testType itemCode itemStat respType respNumb scKey respSeq
	
   di "Building SPC file ..."
	qui gen byte itemSeq = .
	qui gen str1 testType = "E"
	qui gen str5 itemCode = ""
	qui gen str30 itemStat	= ""
	qui gen str1 respType = "N"
	qui gen byte respNumb = .	
	qui gen str1 scKey = ""		
	qui gen byte respSeq = .

	
	if "`ttype'" == ""{
				local ttype E
			}
	if "`rtype'" == ""{
				local rtype N
			}
	
	local wcount:  word count `varlist'
	local varnum 0
	while `"`1'"' != ""{
		local varnum `varnum' + 1
		local label : variable label `1' 
		local vword "`1'"
		* di "`1'" " " "`label'"
		* di `vanum'
		qui replace itemStat = "`label'" if _n == `varnum'
		qui replace itemStat = "`vword'" if itemStat == "" & _n == `varnum' 		
		qui replace itemSeq = _n if _n == `varnum'
		qui replace itemCode = "I" + string(_n) if _n == `varnum'
		qui su `1'
		qui replace respNumb = (r(max) - r(min)) + 1 if _n == `varnum'
		qui replace respSeq  = r(min) if _n == `varnum'
      qui bothlist `1' \ `reverse' 
      if "`r(list)'" == "`1'" { 
         qui replace scKey = "R" if _n == `varnum'
      }
      
		mac shift
	}
   qui compress
   listblck itemSeq - respSeq in 1 / `wcount'
	qui outsheet itemSeq-respSeq using "`filename'.spc" in 1 / `wcount',noquote replace
	
   
   
   
	/* Process itm file items */
   
   qui tostring `varlist', nodecode   /* convert study variables to strings */
   qui dropvars blockID segID comments blockS blockW TestType RespType itemLen itemSubN missSymb
		
      
   /* We convert the ID variable to a string format */
   local type : type `idvar'
   if substr("`type'",1,3) != "str" {qui tostring `idvar', f(%5.0f)}
   recast str5 `idvar'
   qui replace `idvar' = ltrim(`idvar')
   qui moreobs
   qui gen order = _n
   qui replace `idvar' ="aaaaa" in l
      
   qui gen blockID = _n /* Data should be in order required before running this program */
	qui gen str2 segID = ""
	qui gen str30 comments = ""
	qui gen byte blockS = .
	qui gen blockW = .
	qui gen byte TestType = 0
	qui gen byte RespType = 0
	qui gen byte itemLen = 0 
	qui gen itemSubN = 0
	qui gen str3 missSymb = "bsp"
	
	/* enter blockID data *** This is for line 1*/
	qui replace blockID = 1 in 1
	qui replace segID = "1" in 1
	qui replace comments = "ID" in 1
	qui replace blockS = 1 in 1
	qui replace blockW = 5 in 1
	local block = 1
	
   if "`factors'" != ""{
		unab cats : `factors'
		tokenize "`cats'"
		local facount : word count `cats'
		*di "Number of factor variables = " "`facount'"
      local counter = 0
      local starter = 7 /* we begin variable placement counting at 30 */
      /* we have skipped a space so lets add the spacer to the output template */
      sort order
      qui gen str1 space1 = ""
      qui replace space1 = "s" in l
         
      /* we have to do the same for the factors - we will do do below */
		while `"`1'"' != ""{
	   	local counter = `counter' + 1
         local facword : word `counter' of `cats' 
	   	qui tab `1'
			*di "Variable (" `counter'  ") " "`1'" " has " `r(r)' " levels"
			local block = `block' + 1
         qui replace blockID in `block' = `block' 
            
         /* Now we enter the factor data - the variable name goes first*/
         qui replace segID = "2" in `block'
         local label : variable label `1'
         if length("`label'") >5 {
            di
            di in red "label for `1' (`label') is more than 5 characters in length"
            exit 198
         }            
         if "`label'" != "" {
            qui replace comments = "`label'" in `block'
         }
         else {qui replace comments = "`1'" in `block'}
           
         qui replace blockS = `starter' in `block'
         qui replace blockW = 1 in `block'
         local starter = `starter' + 1
            
         /* Now we move to the labelled categories & move down a row */          
         local block = `block' + 1
         qui replace blockID in `block' = `block' 
         qui tab `1' /* The number of levels is r(r) then `catlev'*/
         local catlev = `r(r)'
         qui vallist `1',label s(^) 
         local avals `r(list)'
         local avals : subinstr  local avals " " "_", all
         local avals : subinstr  local avals "^" " ", all
         qui vallist `1'
         local nvals `r(list)'
         local vcount = 1
         *di "Alpha list = " "`avals'"
         *di "Numerical list = " "`nvals'"
         *di
            
         while `vcount' <= `catlev' {
            
            local aword : word `vcount' of `avals'
            local nword : word `vcount' of `nvals'
            qui replace comments = "`aword'" in `block'
            qui replace segID = "2`counter'" in `block'
            qui replace blockS = `counter' in `block'
            qui replace blockW = `nword' in `block'
            qui replace missSymb = "0" in `block'
            *di "`aword'" " " "`nword'"
            if `vcount' != `catlev' {local block = `block' + 1 }
            local vcount = `vcount' + 1                       
         }
         qui tostring `1', nod
         sort order
         qui replace `1' = "f" in l
         mac shift	
		}
         
	}	
   else{
      di "No factor model"
      qui gen str1 space1 = ""
      qui replace space1 = "s" in l
      local starter = 7
   }   
      
   /* Now begin the placement of variables */      		
   local block = `block' + 1
   local starter = `starter' + 2
   sort order
   qui gen str2 space2 = ""
   qui replace space2 = "ss" in l
   qui replace segID = "3" in `block'
   qui replace comments = "Items" in `block'
   qui replace blockS = `starter' in `block'
   qui replace blockW =`varnum' in `block'
   qui compress comments
   qui replace TestType = 1 in `block'
   qui replace RespType = 1 in `block'
   qui replace itemLen =  1 in `block'
   qui replace itemSubN = `varnum' in `block'
      
   /* replace varlist here with v */
   tokenize `varlist'
   while `"`1'"' != ""{
      qui replace `1' = "v" in l
      mac shift
   }
   listblck blockID segID comments blockS blockW TestType RespType itemLen itemSubN missSymb  in 1 / `block'
   qui outsheet blockID segID comments blockS blockW TestType RespType itemLen itemSubN missSymb using "`filename'.itm" in 1 / `block',noquote replace
		
   /* We can now concatenate into a long string */
   
   *format `idvar' %030s
   
   if "`factors'" != ""{
      local outvar  "`idvar' space1 `cats' space2 `varlist'"  
   }
   else {local outvar  "`idvar' space1 space2 `varlist'"}  
   tokenize `outvar'
   while `"`1'"' != ""{
      qui replace `1' = "^^^^^^^^^^^^^^^^^^^^" if `1' == "",nop
      mac shift
   }   
   local outvar : subinstr local outvar " " "+" , all
   *di "`outvar'"
   gen str80 outvar = `outvar'
   sort order
   local lcount = 0
   while `lcount' < _N {
      local lcount = `lcount' + 1
      local tempout = outvar in `lcount'
      local sub : subinstr local tempout "^" " " , all
      qui replace outvar = "`sub'" in `lcount'
   }
   qui compress outvar
   qui drop in l
   di "`file'"
   *format outvar %-080s
   outfile outvar using `filename'.dat, wide replace noq
   l outvar  
   restore
   di
   su `varlist'
          
   di
   di "Files Created: (1) `filename'.scr  (2) `filename'.itm  (3) `filename'.dat"
   
end

