*!tree.ado
*!10/4/98 -> 5/8/98
/* 
Maakt tree en nodige variabelen uitgaande van gegevens in de CART history file.

Syntax :
  tree file(filename of posted CART history file) save(string) pnominal

string is de naam van de CART history file

Mogelijk hebben we ook nog nodig value labels uit de basis file waarop de CART is 
uitgevoerd.

A tree consists of split-nodes and branches.


The split-nodes are also numberd in order of generation starting with 1 as
	top-node, i.e. the first split. Per node there are in general
	two branches. However, we will try to take into account future gene-
	ralisations with more than two branches per node. For example at the 
	start of the tree, if one forces a split in three categories on a
	specified variable.
	A node with n>2 branches is thought of as cocnsiting of n-1 subnodes
	at the same level. 
	
*/

program define tree
version 7.0

capture preserve
local options "File(string) Save(string) PNOMinal Pval(real 0.05) "
parse ",`*'"
uc `file'

quietly {
 *Create help variables for location and position of nodes and branches */

 capture confirm new var next
 if _rc==0 {  /* otherwise all help variables are already defined */
  sort group level
  by group:gen next=varnr[_n+1]  /* Var nr of next split variable, if not end-node */
 } 

 if "`pnominal'"!="" { local t1note Split if nominal P<`pval' }
 else                { local t1note Split if (adjusted) P<`pval' }

 su level
 local nlev=_result(6)  
 local nbr =_N+1
 cvar mima
 local lmima:char mima[width]
 local dy=int(20000/`nbr')

 local fh1=int(min(`dy'/2,700))  /* font group descriptor text */
* local fh1=int(min(max(`dy'/2,400),700))  /* font group descriptor text */
 local fw1=int(`fh1'/2)
 local fh2=int(1.1*`fh1')   /* font split variable text (standard font) */
 local fw2=int(1.1*`fw1')

* local fh2=int(max(1.1*`fh1',300))   /* font split variable text (standard font) */
* local fw2=int(`fh2'/2) 
 local fh1x=int(`fh2'/1.1)
 local fw1x=int(`fh1x'/2) 
 
 local dx=int(max(10,`lmima')*1.7*`fw1')
 if (`nlev'+.2)*`dx'+14*1.7*`fw2' >30000 {
	local f=30000/((`nlev'+.2)*`dx'+14*1.7*`fw2')
*	local f=90000/((`nlev'+.2)*`dx'+14*1.7*`fw2')
	local fh1=int(`fh1'*`f')
	local fw1=int(`fw1'*`f')
	local dx=int(`dx'*`f')
 }
 local font1 `fh1' `fw1'
* local font1 `fh1x' `fw1x'
 local font2 `fh2' `fw2'
 local ax=500
 local ay=2000

 local nc1=`ax'+`dx'*(`nlev'+.2)+3*1.6*`fw2'
 local nc2=`ax'+`dx'*(`nlev'+.2)+7*1.6*`fw2'
 local nc3=`ax'+`dx'*(`nlev'+.2)+12*1.6*`fw2'
 local rtop=`ay'+`dy'-2*`fh2'
 local node1 :char _dta[node1]
 local r1=`ay'+`node1'*`dy'
 local c1=`ax'
 sort group level
 local varn=varnr[1]
 local text1:label varnr `varn' 
 
*All elements for a tree are available. Let us make one.
/*
nois display "r1 `r1'"
nois display "c1 `c1'"
nois display "nc1 `nc1'"
nois display "nc2 `nc2'"
nois display "nc3 `nc3'"
nois display "dx `dx'"
nois display "dy `dy'"
nois display "ax `ax'"
nois display "ay `ay'"
nois display "font1 `font1'"
nois display "font2 `font2'"
nois display "text1 `text1'"
pause
*/
  gph open  ,saving(`save')
  gph pen 1
  gph font `font2' 
  gph text `rtop' `nc1'  0 1 N
  gph text `rtop' `nc2'  0 1 F
  gph text `rtop' `nc3'  0 1 RHR
  
  gph point  `r1' `c1' `fw1' 1
  local c1=`c1'+30
  gph pen 2
  gph font `font2' 
  gph text `r1' `c1'  0 -1 `text1'

  sort from level order
  gph pen 1
  local i=1 
  while `i'<=_N {
    if from[`i']==from[`i'-1]&level[`i']==level[`i'-1] {
	local x=`ax'+`dx'*(level[`i']-1)
	local y1=`ay'+`dy'*(order[`i'-1])
	local y2=`ay'+`dy'*(order[`i'])
	gph line `y1' `x' `y2' `x'
    }
    local i=`i'+1
  }

  sort order
  local i=1 
  while `i'<=_N {
   	local last=last[`i']
	local next=next[`i']
	local text1=mima[`i']
	
	local x1=`ax'+`dx'*(level[`i']-1)
	local x2=`ax'+`dx'*(level[`i'])
	local x3=`x2'+30
	local y1 =`ay'+`dy'*order[`i']
	local y2=`y1'-130
        gph pen 1
	gph line `y1' `x1' `y1' `x2'
	gph pen 1
	gph font `font1' 
	gph text `y2' `x1'  0 -1 `text1'
	if "`next'"~="." {
		local text2:label varnr `next' 
		gph point `y1' `x2' `fw1' 1 
		gph pen 2
		gph font `font2'
		gph text `y1' `x3'  0 -1 `text2'
	}
	else {  
		gph point `y1' `x2' `fw1' 2 
		local no=n[`i']
		local nf=f[`i']
		local rhr=rhr[`i']
		fns rhr `rhr' ,dec(2)
		gph font `font2' 
		gph text `y1' `nc1'  0 1 `no'
		gph text `y1' `nc2'  0 1 `nf'
		gph text `y1' `nc3'  0 1 $rhr
	}
	local i=`i'+1
  }
  local t1 :char _dta[time]
  local t2 :char _dta[vars] 
  local t3 :char _dta[adjust] 
  local t4 :char _dta[strata] 
  local nx=("`t3'"~="")+("`t4'"~="")
  local yt=1.2*(`fh2'+(1+`nx')*`fh1')
  local f=min(1,`ay'/`yt')
  local y1=1.2*`f'*`fh2'
  local y2=`y1'+1.2*`fh1'
  local y3=`y2'+1.2*`fh1'
  local y4=`y3'+1.2*`fh1'*(`nx'==2)
  local fh1=`f'*`fh1'
  local fw1=`f'*`fw1'
  local fh2=`f'*`fh2'
  local fw2=`f'*`fw2'
  gph pen 2
  gph font `fh2' `fw2'
  gph text `y1' `ax' 0 -1 CART analysis `t1' - `t1note'
  gph pen 1
  gph font `fh1' `fw1'
  gph text `y2' `ax' 0 -1 With variables: `t2'
  if  "`t3'"~="" {  gph text `y3' `ax' 0 -1 Adjusted for: `t3'}
  if  "`t4'"~="" {  gph text `y4' `ax' 0 -1 Stratified by: `t4'}
  gph close


end
