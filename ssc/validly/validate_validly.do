* This is a test file for validly (see below for the program version)
* Parts are formal validation, and parts are a 'stress test' across varied input.
*
 quietly {
* ________________________________________________
* test file for validly
* currently:
local vers "3.2"
* ________________________________________________
*
capture program drop validly  // ensure newest
vy set_defaults
local shreek 0
local tvers "`r(vers)'"
*
forvalues jjj = 1/2 {
   if `jjj'==2 local nonind nonind

* validate v2.0
* validation do-file for validly v2.5
* 31/3/13
*
   set more off
* The verification strategy is:
*   verify (by inspection) that simple expressions (one operator) 
*         are correctly coded
*   verify a sample of complex expressions against the answer 
*      derivable from repea ted application of the verified 'simples'.
*   do this in both extended and non-extended modes
*
*  The 'sample of complex' is of course arbitrary, but has been chosen
*    to flex as many different coding characteristics as possible
*
*  Make test data
   if `jjj'==1 {
      noisily di as txt _n(8) " {hline}" _n(2) ///
      " UTILITY TO TEST/VALIDATE validly v`vers'" _n(2) 
      if "`tvers'"!="`vers'" {
         noisily di "{err}  NOTE: validly's version number (v`tvers') does not match" _n ///
         "{space 8}this test file (which is designed for v`vers')" _n ///
         "  Proceeding nevertheless" _n(2)
         local shreek 1
      }
      noisily di as txt " Strategy:" _n ///
     "   generate test variables" _n ///
     "   construct and verify dyadic expressions" _n ///
     "   use these to verify more complex operations " _n(2) ///
     " (all estimations, other than the very last, are more-or-less" _n ///
     "  instantaneous" _n(2) ///
     " The tests are first run on a data array of indicator variables (values 1,0,sysmiss,.a,.b)" _n ///
     " then rerun on non-indicator vars, to double-check" _n(2) ///
     " This utility first {err}{bf}clears{sf}{txt} the data array:  do you wish to proceed (y/n)?{txt}  " _r(yy)
     if ("$yy"!="Y") & ("$yy"!="y")  error 4
   }
   else {
      noisily di as txt _n(8) " {hline}" _n(2) ///
      " Now RERUNNING ALL, on the array without constraining the variables to be indicator variables" _n(2)
     local k 99
     while `k'==99 {
        noisily di " Skip (y/n)?"  _r(yy)
        if "$yy"=="Y"|"$yy"=="y" {
           local skip1 1
           continue, break    
        }
        if "$yy"=="N"|"$yy"=="n" {
           local skip1 0
           continue, break    
        }
      }
      if `skip1' continue,break
   }

   clear
   vy set_defaults


* data with extended-missing to ensurethese correctly handled
validly gen_test_vars p q r s t u, extended `nonind'
*  we additionally make two string variables, ps and qs
gen ps = "dog" if p!=0 & !mi(p)
replace ps = "feline" if p==0
gen qs = "dog" if q!=0 & !mi(q)
replace qs = "feline" if q==0
quietly compress
label define tf 1 True 0 False
*
local i " "
if `jjj'==2 local i " nonind"
noisily di as txt " {hline}"_n ///
  " We have used:" _n ///
   `"   {help validly##utility:.validly gen_test_vars p q r s, extended`i'}"' _n ///
   " to make test variables, adding following string variables:" _n ///
   `"   .gen ps = "dog" if p!=0 & !mi(p) "' _n ///
   `"   .replace ps = "feline" if p==0"' _n ///
   `"   .gen qs = "dog" if q!=0 & !mi(q)"' _n ///
   `"   .replace qs = "feline" if q==0"' _n

local first 1
if `jjj'==2 local first True
noisily  di as txt " {hline}" _n ///
  " Having generated the basic test dataset" _n ///
  " with all  possible patterns of values:{bf} `first' 0 . .a .b{sf}" _n 
if `jjj'==2 noisily di " ('True' values are random integers, range 1-100)"
noisily  di " across variables {bf}p q r s t u{sf}" _n(2) ///
  " we first, by visual inspection, check that all" _n ///
  " single logical/relational operators " _n ///
  " give the desired result." _n(2) ///
  " then we do formal checks" _n(2) ///
  " These validated simples (so note var names) are then used" _n ///
  " to validate more complex expressions " _n ///
  " {hline}" _n ///
   " press Enter to continue:" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
* For each non-extended initial command we display one extended-missing 
* to ensure that there are no misspecified p=. rather than p>. errors
foreach x in default extended {
local y ""
local t ""
local lif "if p<.b & q <.b"
if "`x'"=="extended" {
   local t ", e"
   local y "_e"
   local lif ""
   vy set_extended on
}
validly gen np`y':tf = !p
noisily di " {hline}"
noisily list p np`y' in 1/4
noisily di "     .validly generate np`y' = !p`t'"
noisily di " in `x' mode;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
validly gen paq`y':tf = p&q
noisily di " {hline}"
noisily list p q paq`y' `lif' in 1/25
noisily di "     .validly generate paq`y' = p&q`t'"
noisily di " in `x' mode;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
validly gen pvq`y':tf = p|q
noisily di " {hline}"
noisily list p q pvq`y' `lif' in 1/25
noisily di "     .validly generate pvq`y' = p|q`t'"
noisily di " in `x' mode;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
validly gen pGTq`y':tf = p>q
noisily di " {hline}"
noisily list p q pGTq`y' `lif' in 1/25
noisily di "     .validly generate pGTq`y' = p>q`t'"
noisily di " in `x' mode;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
validly gen psysm`y':tf = p==.
validly gen pexmb`y':tf = p==.b
validly gen exmbp`y':tf = .b==p
noisily di " {hline}"
noisily list p  psysm`y' pexmb`y' exmbp`y'  in 1/5
noisily di "     .validly generate psysm`y' = p==. `t'"
noisily di "     .validly generate pexmb`y' = p==.b`t'"
noisily di "     .validly generate exmbp`y' = .b==p`t'"
noisily di " in `x' mode;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
capture drop ys1
capture drop ys2
capture drop ys3  // same in either e/not, but check
validly gen ys1:tf = ps==qs
validly gen ys2:tf = ps==""
validly gen ys3:tf = ""==qs
noisily di " {hline}"
noisily list ps qs ys1 ys2 ys3 in 1/25 if p<=. & q<=.
noisily di `"     .validly generate ys1 = ps==qs `t'"'
noisily di `"     .validly generate ys2 = ps=="" `t'"'
noisily di `"     .validly generate ys3 = ""==qs `t'"'
noisily di " string operations;  (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
* If we rerun these in **replace* mode there should be zero changes throughout
noisily di as txt " {hline}" _n ///
 " We now rerun these using {bf}validly replace{sf}" _n ///
 " Checking that there are (as there should be) {bf}ZERO{sf} changes" _n ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
capture drop z
gen z = np`y'
validly np`y' = !p
assert z== np`y'
capture drop z
gen z = paq`y'
validly paq`y' = p&q
assert z== paq`y'
capture drop z
gen z = pvq`y'
validly pvq`y' = p|q
assert z== pvq`y'
capture drop z
gen z = pGTq`y'
validly pGTq`y' = p>q
assert z== pGTq`y'
capture drop z
gen z = psysm`y'
validly psysm`y' = p==.
assert z== psysm`y'
capture drop z
}
capture drop Spaq_e
capture drop Spaq
generate Spaq_e = p&q if !mi(p,q)
replace  Spaq_e = p if mi(p)& (!mi(q) | (p==q))
replace  Spaq_e = q if mi(q)& (!mi(p) | (p==q))
replace  Spaq_e = 0 if (p==0 & mi(q))|(q==0 & mi(p))
generate Spaq = Spaq_e
replace  Spaq =. if mi(Spaq)
assert paq_e == Spaq_e
assert paq == Spaq
noisily di as txt " {hline}" _n ///
 " We next do formal tests on these same variables" _n ///
 " comparing them to correct versions, named Sxxx," _n ///
 " constructed using raw Stata" _n(2) ///
 " Handcrafted Stata p {bf}and{sf} q:" _n ///
 "   .generate Spaq_e = p&q if !mi(p,q)" _n ///
 "   .replace  Spaq_e = p if mi(p)& (!mi(q) | (p==q))" _n ///
 "   .replace  Spaq_e = q if mi(q)& (!mi(p) | (p==q))" _n ///
 "   .replace  Spaq_e = 0 if (p==0 & mi(q))|(q==0 & mi(p))" _n ///
 "   .generate Spaq = Spaq_e" _n ///
 "   .replace  Spaq =. if mi(Spaq)" _n ///
 "   {bf}.assert paq_e == Spaq_e" _n ///
 "   .assert paq == Spaq{sf} " _n(2) ///
 " These {bf}asserts{sf} for p&q accepted. (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
capture drop v1
validly v1 = !(!(!p))
capture drop v2
validly v2 = !p  
assert v1==v2 
if `jjj'==1 { // !!p works for indicator only
   capture drop v1
   validly v1 = (!(!p))
   assert v1==p 
}
capture drop v1
validly v1 = p|q
capture drop v2
validly v2 = !(!p&!q)
assert v1==v2 
capture drop Spvq_e
capture drop Spvq
generate Spvq_e = p|q if !mi(p,q)
replace  Spvq_e = p if mi(p)& (!mi(q) | (p==q))
replace  Spvq_e = q if mi(q)& (!mi(p) | (p==q))
replace  Spvq_e = 1 if ((p&!mi(p)) & mi(q))|((q&!mi(q)) & mi(p))
generate Spvq = Spvq_e
replace  Spvq =. if mi(Spvq)
assert pvq_e == Spvq_e
assert pvq == Spvq
noisily di as txt " {hline}" _n ///
 " Handcrafted Stata p {bf}or{sf} q:" _n ///
 "   .generate Spvq_e = p|q if !mi(p,q)" _n ///
 "   .replace  Spvq_e = p if mi(p)& (!mi(q) | (p==q))" _n ///
 "   .replace  Spvq_e = q if mi(q)& (!mi(p) | (p==q))" _n ///
 "   .replace  Spvq_e = 1 if ((p&!mi(p)) & mi(q))|((q&!mi(q)) & mi(p))" _n ///
 "   .generate Spvq = Spvq_e" _n ///
 "   .replace  Spvq =. if mi(Spvq)" _n ///
 "   .assert pvq_e == Spvq_e" _n ///
 "   .assert pvq == Spvq" _n(2) ///
 " These {bf}asserts{sf} for p|q accepted. (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
capture drop Snp_e
capture drop Snp
generate Snp_e = !p if !mi(p)
replace  Snp_e = p if mi(p)
generate Snp = Snp_e
replace  Snp =. if mi(Snp)
assert np_e == Snp_e
assert np == Snp
noisily di as txt " {hline}" _n ///
 " Handcrafted Stata !p " _n ///
 "   .generate Snp_e = !p if !mi(p)" _n ///
 "   .replace  Snp_e = p if mi(p)" _n ///
 "   .generate Snp = Snp_e" _n ///
 "   .replace  Snp =. if mi(Snp)" _n ///
 "   .assert np_e == Snp_e" _n ///
 "   .assert np == Snp" _n(2) ///
 " These {bf}asserts{sf} for !p accepted. (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
capture drop SpGTq_e
capture drop SpGTq
generate SpGTq_e = p>q if !mi(p,q)
replace  SpGTq_e = p if mi(p)& (!mi(q) | (p==q))
replace  SpGTq_e = q if mi(q)& (!mi(p) | (p==q))
generate SpGTq = SpGTq_e
replace  SpGTq =. if mi(SpGTq)
assert pGTq_e == SpGTq_e
assert pGTq == SpGTq
noisily di as txt " {hline}" _n ///
 " Handcrafted Stata p > q" _n ///
 "   .generate SpGTq_e = p>q if !mi(p,q)" _n ///
 "   .replace  SpGTq_e = p if mi(p)& (!mi(q) | (p==q))" _n ///
 "   .replace  SpGTq_e = q if mi(q)& (!mi(p) | (p==q))" _n ///
 "   .generate SpGTq = SpGTq_e" _n ///
 "   .replace  SpGTq =. if mi(SpGTq)" _n ///
 "   .assert pGTq_e == SpGTq_e" _n ///
 "   .assert pGTq == SpGTq" _n(2) ///
 " These {bf}asserts{sf} for p > q accepted. (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
validly set_extended off
*
* OK, assume simples work
* compare
*   direct assessment of complex expression with
*   assessment built up through repeated deployment of validated simples
* using these validated definitions to validate conditionals
* p equivalents
*quietly { 
noisily di as txt _n(3) " {hline}" _n " Using these validated expressions as comparator variables," _n ///
 _col(4) "now assessing the operators within conditionals;"  _n ///
 _col(4) "Note: [to ease programming] {bf}pt{sf} below is simply {bf}p{sf} " _n ///
 _col(4) "truncated to 0,1,sysmiss, {bf}pt_e{sf} is simply full {bf}p{sf} " _n(2) ///
  _col(4) "for each operator" _n ///
_col(4) "looking at the conditional across the twelve possible states of the " _n ///
 _col(4) "options:  wide  ifnot(.z) else(.y)  extended" _n(2) ///
 _col(4) "For example, for one state of the operator '&' we have, :" _n ///
 _col(4) "using the validated comparator paq_e (see above), the test:" _n ///
 _col(11) "validly generate v = 7 if p&q,  ifn(.z) e" _n ///
 _col(11) "assert (paq_e==1)==(v==7)" _n ///
 _col(11) "assert (paq_e==0)==(v==.z)" _n ///
 _col(11) "assert (paq_e==.)==(v==.)" _n ///
 _col(11) "assert (paq_e==.a)==(v==.a)" _n ///
 _col(11) "assert (paq_e==.b)==(v==.b)" _n ///
 _col(11) "assert (v==7)|(v==.z)|(v==.)|(v==.a)|(v==.b)" _n ///
 _col(14) "(see the do-file for full details of the other tests)" _n " {hline}"
noisily di as txt " (press Enter to continue)" _r(yy)
*
validly set_extended off
capture drop pt
capture drop pt_e
capture drop pexmb
gen pexmb = p==.b if p!=. //nuanced definition of ==.x
capture drop pexmb_e
gen pexmb_e = pexmb
gen pt_e = p
gen pt = p if !mi(p)
local act "pt np paq pvq pGTq psysm pexmb pexmb"
local i 0
*
foreach p in p !p p&q p|q p>q p==. p==.b .b==p {
*
local ++i
local x = word("`act'",`i')
*
noisily di  " {txt}{hline}" _n " Assessing:  {bf}validly v = 7 if `p' {sf}" _n ///
     "   across the twelve valid  combinations of options {bf} w  ifn(.z) else(.y) e {sf}" _n ///
     "   with validated comparator: {bf}`x'{sf} (default mode),  {bf}`x'_e{sf} (extended mode)"
capture drop v
validly v=7 if `p', w ifn(.z)
assert (`x'!=0)==(v==7)
assert (`x'==0)==(v==.z)
assert (v==7)|(v==.z)
drop v
validly v=7 if `p', w 
assert (`x'!=0)==(v==7)
assert (`x'==0)==(v==.)
assert (v==7)|(v==.)
drop v
validly v=7 if `p',  ifn(.z)
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0)==(v==.z)
assert (`x'==.)==(v==.)
assert (v==7)|(v==.z)|(v==.)
capture drop v
validly v = 7 if `p'
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0|`x'>=.)==(v==.)
assert (v==7)|(v==.)
* and now do same in extended mode
drop v
validly v=7 if `p', w ifn(.z) e
assert (`x'_e!=0)==(v==7)
assert (`x'_e==0)==(v==.z)
assert (v==7)|(v==.z)
drop v
validly v=7 if `p', w e
assert (`x'_e!=0)==(v==7)
assert (`x'_e==0)==(v==.)
assert (v==7)|(v==.)
drop v
validly v=7 if `p',  ifn(.z) e
assert (`x'_e>=1&`x'_e<.)==(v==7)
assert (`x'_e==0)==(v==.z)
assert (`x'_e==.)==(v==.)
assert (`x'_e==.a)==(v==.a)
assert (`x'_e==.b)==(v==.b)
assert (v==7)|(v==.z)|(v==.)|(v==.a)|(v==.b)
drop v
validly v = 7 if `p', e
assert (`x'_e>=1&`x'_e<.)==(v==7)
assert ((`x'_e==0)|(`x'_e==.))==(v==.)
assert (`x'_e==.a)==(v==.a)
assert (`x'_e==.b)==(v==.b)
assert (v==7)|(v==.)|(v==.a)|(v==.b)
* and now repeat for the acceptable with else
drop v
validly v=7 if `p',  ifn(.z)  else(.y)
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0)==(v==.z)
assert (`x'==.)==(v==.y)
assert (v==7)|(v==.z)|(v==.y)
capture drop v
validly v = 7 if `p',  else(.y)
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0|`x'>=.)==(v==.y)
assert (v==7)|(v==.y)
* and now do same in extended mode
drop v
validly v=7 if `p',  ifn(.z) e  else(.y)
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0)==(v==.z)
assert (`x'==.)==(v==.y)
assert (v==7)|(v==.z)|(v==.y)
drop v
validly v = 7 if `p', e  else(.y)
assert (`x'>=1&`x'<.)==(v==7)
assert (`x'==0|`x'>=.)==(v==.y)
assert (v==7)|(v==.y)
}
* simple minded test of sousrce
* first generate actual vars corresponding to the 'as if' vars
capture drop pa
generate pa = p
replace pa = .a if mi(p)
capture drop qb
generate qb = q
replace qb = .b if mi(q)
capture drop rc
generate rc = r
replace rc = .c if mi(r)
capture drop sd
generate sd = s
replace sd = .d if mi(s)
*
capture drop vr
validly gen vr = qb&pa, e //we know from above this works
capture drop v
validly gen v = p&q, source //to test
assert v==vr
*
*
noisily di as txt _n(2) " {hline}" _n ///
 " Now checking that option {bf}source{sf} works as intended" _n ///
 " we first generate actual vars pa, qb etc" _n /// 
 " with their extended-missing values" _n /// 
 " corresponding to the notional vars enacted by source" _n(2) ///
 " Then compare." _n ///
 "   .validly gen vr = qb&pa, e //we know from above this works" _n ///
 "   .validly gen v = p&q, source //to test" _n ///
 "   .validly gen vr2 = vr if rc|sd, e //we now know that to work" _n ///
 "   .validly gen v2 = p&q if r|s, source //to test" _n ///
 "   .assert v==vr" _n ///
 "   .assert v==vr2" _n(2) ///
 " These {bf}asserts{sf} for source accepted. (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
* no easy way to "verify" source's random splitting option
* but we can do soome visual checking in bivariate mode
noisily di as txt _n(2) " {hline}" _n ///
 " No easy way to exactly verify the random splitting in " _n ///
 " source(r).  But we can do some checking " _n ///
 " in bivariate mode running" _n ///
 "   .validly vr = pa R qb, e" _n ///
 "   .validly v = p R q, source(r)" _n ///
 " for the relations & |  >=" _n(2) ///
 " Splitting should only happen when vr is sysmis" _n ///
 "   .assert vr==v if vr!=." _n(2) ///
 " Also  by visually inspecting the tab of v by vr when v!=vr" _n ///
 " source(r) should split these {ul:roughly} equally" _n(2) ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
foreach r in & | >= {
capture drop vr
validly vr = pa`r'qb, e
capture drop v
validly v = p`r'q, source(r)
* disagreements between v and vr should only be when vr gives sysmis
* and v should have spli these roughly equally
assert vr==v if vr!=.
noisily di as txt "{hline 11}{c RT} for `r' when v!=vr {c LT}{hline}"
noisily tab vr v if v!=vr, m
}
capture drop v
capture drop vr
validly vr = !p, source
validly v = !p, source(r)
assert v==vr
noisily di as txt _n(2) " {hline}" _n ///
" (We have also checked that source and source(r) give identical" _n ///
"  results when making !p)" _n(2) ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
*
noisily di as txt _n(2) " {hline}" _n ///
" There is no way to exhaustively check the RPN-parser. " _n(2) ///
" But we can try throwing at it disparate but logically equivalent renditions, and " _n ///
" asserting equivalence.  Thus for example: " _n(2) ///
" .validly gen y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s))) " _n ///
" .validly gen y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)) " _n ///
" .assert y1==y2" _n(2) ///
" or " _n(2) ///
" .validly gen y1 = (p&q)|r if s|(t&u) , ifnot((q>r)|t) else(p|!u) e" _n ///
" .validly gen y2 = !((!p|!q)&!r) if !((!u|!t)&!s) , ifnot(!(!t&(q<=r))) else(!(!p&u)) e"  _n ///
" .assert y1==y2" _n(2) ///
" or, checking source"  _n(2) ///
" .validly gen y1 = (p&q)|(r>u) if s|(t&u) , ifnot(!q|t) else(p|!u) source"  _n ///
" .validly gen y2 = !((!p|!q)&(r<=u)) if !((!u|!t)&!s) , ifnot(!(!t&q)) else(!(!p&u)) s"  _n ///
" .replace y2 = .x if y2==.e //since assigned in different sequence"  _n ///
" .replace y2 = .e if y2==.f"  _n ///
" .replace y2 = .f if y2==.x"  _n ///
" .assert y1==y2"_n(2) ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
capture drop y1
validly y1 = (p&q)|r if s|(t&u) , ifnot((q>r)|t) else(p|!u) e
capture drop y2
validly y2 = !((!p|!q)&!r) if !((!u|!t)&!s) , ifnot(!(!t&(q<=r))) else(!(!p&u)) e
assert y1==y2
capture drop y1
validly y1 = (p&q)|(r>u) if s|(t&u) , ifnot(!q|t) else(p|!u) source
capture drop y2
validly y2 = !((!p|!q)&(r<=u)) if !((!u|!t)&!s) , ifnot(!(!t&q)) else(!(!p&u)) s
assert y1==y2
*
noisily di as txt _n(2) " {hline}" _n ///
" Now taking the first pair of expressions above andusing them" _n ///
" to test the 'optimisation' to plain relations for missing data" _n ///
" by running the equivalence test on the data-set reduced sequentially to non-missing" _n(2) ///
" sequentially from each end of the array, and also a couple of random sequences" _n ///
" and checking that with no missing, Stata and validly agree." _n(2) ///
" This section also exercises various optimisations found in 'source' mode," _n ///
" and checks that they work as expected when paired with non-missing variables." _n(2) ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
noisily di " Wait {c 133}{c 133}"
foreach vv in p q r s t u { // from front
   replace `vv' = 7 if `vv'>=.
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
}
* and with no missingthey should match plain
capture drop sy1
gen sy1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop sy2
gen sy2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert sy1==sy2
assert sy1==y1
clear
validly gen_test_vars u t s r q p, extended `nonind'
foreach vv in p q r s t u {
   replace `vv' = 7 if `vv'>=.
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
}
clear
validly gen_test_vars p q r s t u, extended `nonind'
foreach vv in p q r s t u { // from back
   replace `vv' = 7 if `vv'>=.
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
}
clear
validly gen_test_vars p q r s t u, extended `nonind'
foreach vv in p u t s r q { // arbitrary 1
   replace `vv' = 7 if `vv'>=.
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
}
clear
validly gen_test_vars p q r s t u, extended `nonind'
foreach vv in q r s t u p { // arbitrary 2
   replace `vv' = 7 if `vv'>=.
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
assert y1==y2
}

* section to test v3.2 introduced optimisation on sourced variables
clear
vy gen_test_vars p q  r s  t u, e
local sc 97
foreach i in p q r s t u {
   local val = char(`sc')
   local val .`val'
   replace `i' =  `val' if mi(`i')
   local ++sc
}
capture drop a
capture drop aa
validly gen aa = !((p&q)|(r&s))>(!t&!u), e d 
validly gen a = !((p&q)|(r&s))>(!t&!u), s d 
assert a==aa
capture drop as
validly gen as = !((p&q)|(r&s))>(!t&!u),  d 
replace a = . if mi(a)
assert as==a
local sc 97
foreach i in p  r  t  {
   local val = char(`sc')
   local val .`val'
   replace `i' =  `val' if mi(`i')
   local ++sc
}
foreach i in q s u  {
   replace `i' =  7 if mi(`i') //nonindicator
}

capture drop a
capture drop aa
validly gen aa = !((p&q)|(r&s))>(!t&!u), e d 
validly gen a = !((p&q)|(r&s))>(!t&!u), s d 
assert a==aa
capture drop as
validly gen as = !((p&q)|(r&s))>(!t&!u),  d 
replace a = . if mi(a)
assert as==a
foreach i in q s u  {
   replace `i' =  1 if `i'==7 // indicator
}
capture drop a
capture drop aa
validly gen aa = !((p&q)|(r&s))>(!t&!u), e d 
validly gen a = !((p&q)|(r&s))>(!t&!u), s d 
assert a==aa
*
clear
vy gen_test_vars p q  r s  t u, e
local sc 97
foreach i in s t u  {
   local val = char(`sc')
   local val .`val'
   replace `i' =  `val' if mi(`i')
   local ++sc
}
foreach i in p q r  {
   replace `i' =  7 if mi(`i') //nonindicator
}
capture drop a
capture drop aa
validly gen aa = !((p&q)|(r&s))>(!t&!u), e d 
validly gen a = !((p&q)|(r&s))>(!t&!u), s d 
assert a==aa
capture drop as
validly gen as = !((p&q)|(r&s))>(!t&!u),  d 
replace a = . if mi(a)
assert as==a
*
* further, since the coding for one-no-miss is idiosyncratic, we should give it a workout
clear
vy gen_test_vars p q r s t, e n
foreach i in p q {
   vy `i'n = `i'
   vy `i'n = 1 if mi(`i')
}
foreach j in | & > {
foreach j2 in e s " " {
local jn  & 
if "`j'"=="&" local jn "|"   
capture drop a
capture drop b
di "vy a = pn`j'q, `j2'"
vy a = pn`j'q, `j2'
if "`j'"!=">" vy b  = !(!pn `jn' !q), `j2'
else vy b = q < pn, `j2'
assert a==b
}
}
* abd checking that ifnot and else behave under these circumstances
foreach p in p pn {
foreach q in q qn {
foreach ii in " " "ifnot(`p'&`q') else(`p'&`q')" {
local jj " "
if "`ii'"!=" " local jj "if t"
capture dro`p' a
capture dro`p' a2
vy a = (`p'&`q') `jj', `ii' when(r&s) 
vy a2 = (`p'&`q') if r&s 
assert a==a2
vy a = !(!`p'|!`q') `jj', when( !r|!s) `ii' 
vy a2 = !(!`p'|!`q') if !r|!s
assert a==a2
capture dro`p' ras
vy ras = r&s
vy a = !(!(`p'&`q')) `jj', `ii' when(mi(ras)) 
vy a2 = !(!(`p'&`q')) if mi(ras)
assert a==a2
capture dro`p' b
vy b = `p'&`q'
assert a==b
}
}
}

clear
validly gen_test_vars p q r s t u, extended `nonind'
*
*
noisily di as txt _n(2) " {hline}" _n ///
" Now taking the first pair of expressions above and testing them" _n ///
" when positioned within the condition, and {bf}ifnot{sf}, and {bf}else{sf}" _n(2) ///
" and verifying them against the expression cumulatively constructed" _n ///
" from (verifiied) simple calls to validly with dyadic relations." _n(2) ///
" Also checking that {sf}validly global{sf} parses equivalently." _n(2) ///
" (See  do file for details)" _n ///
 " (press Enter to continue)" _r(yy)
if "$yy"!="Y"&"$yy"!="y"&"$yy"!="" exit
noisily di " Wait {c 133}{c 133}"
* build from simples
capture drop paq
validly paq = p&q
capture drop ras
validly ras = r&s
capture drop paqvras
validly paqvras = paq | ras
capture drop npaqvras
validly npaqvras = ! paqvras
capture drop nt
validly nt = ! t
capture drop nu
validly nu = ! u
capture drop ntanu
validly ntanu = nt & nu
capture drop pvr
validly pvr = p|r
capture drop pvrvs
validly pvrvs = pvr|s
capture drop part2
validly part2 = ntanu < pvrvs
capture drop part1
validly part1 = npaqvras > part2
capture drop ref
validly ref  = ! part1
capture drop y1
validly y1 = !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
assert ref== y1
*
capture drop y2
validly y2 = ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)) //now known correct
validly global m1 !(!((p&q)|(r&s))>((!t&!u)<(p|r|s)))
validly global m2 ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
capture drop y1
gen y1 = $m1
assert y1==y2
capture drop y2
gen y2 = $m2
assert y1==y2
capture drop y1 y2
gen y1 = 7 if $m1 == 1
validly y2 = 7 if ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
capture drop y3
validly y3 = 7 if ref
assert y1 == y2
assert y1 == y3
capture drop y1 y2 y3
validly y1 = 7 if p, ifnot(!(!((p&q)|(r&s))>((!t&!u)<(p|r|s))))
validly y2 = 7 if p, ifnot(((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)))
validly y3 = 7 if p, ifnot(ref)
assert y1==y2
assert y1==y3
capture drop y1 y2 y3
validly y1 = 7 if p, else(!(!((p&q)|(r&s))>((!t&!u)<(p|r|s))))
validly y2 = 7 if p, else(((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)))
validly y3 = 7 if p, else(ref)
assert y1==y2
assert y1==y3
capture drop y1 y2 y3
validly y1 = 7 if p, ifnot(8) else(!(!((p&q)|(r&s))>((!t&!u)<(p|r|s))))
validly y2 = 7 if p, ifnot(8) else(((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)))
validly y3 = 7 if p, ifnot(8) else(ref)
assert y1==y2
assert y1==y3
capture drop y1 y2 y3
validly y1 = 7 if p, ifnot(8) when(!(!((p&q)|(r&s))>((!t&!u)<(p|r|s))))
validly y2 = 7 if p, ifnot(8) when(((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)))
validly y3 = 7 if p, ifnot(8) when(ref)
assert y1==y2
assert y1==y3
capture drop y2 y3
gen y2 = 7 if (p>=1 & p<.) & $m1==1
replace y2 = 8 if p==0 & $m1==1
assert y1==y2
capture drop y1 y2 y3
validly y1 = 7 if p, ifnot(8) else(9) when(!(!((p&q)|(r&s))>((!t&!u)<(p|r|s))))
validly y2 = 7 if p, ifnot(8) else(9) when(((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p)))
validly y3 = 7 if p, ifnot(8) else(9) when(ref)
assert y1==y2
assert y1==y3
capture drop y2 y3
gen y2 = 7 if (p>=1 & p<.) & $m1==1
replace y2 = 8 if p==0 & $m1==1
replace y2 = 9 if mi(p) & $m1==1
assert y1==y2
macro drop m1
macro drop m2
*
* use this to check on wrapper behaviour
capture drop rn
gen rn = r
replace rn = 5 if mi(r)  //so no mi in reg itself
replace rn=20 if ref!=1 //so that range matters to reg
capture drop sn
gen sn = s
replace sn = 5 if mi(s)
replace sn=20 if ref!=1
validly reg rn sn if ((!s|!r)&(!q|!p))<=!(!(u|t)>=!(!s&!r&!p))
capture drop preg
validly predict preg if !(!((p&q)|(r&s))>((!t&!u)<(p|r|s))) //the other form
reg rn sn if ref==1
capture drop preg2
predict preg2 if ref==1
assert preg==preg2
*
*
validly global paq p&q
validly global pvq p|q
capture drop y1
gen y1 = cond(r,$paq,$pvq,.)
capture drop y2
validly gen y2 = p&q if r, ifnot(p|q)
assert y1==y2
*
* a simplified version of further
* since the full version (across all combinations)
* takes forever (i.e. >10hrs on FAST machine)
noisily di as txt _n(2) " {hline}" _n ///
" The next two parts take a 'try everything' approach" _n(2) ///
" PART 1 Looking at:"  _n(2) ///
 " validly v = pRq if rRs, ifnot(tRu) else(rRt) when(qRu) e"  _n(2) ///
" varying by the possible combinations of ifnot/else/when"  _n ///
" and within that allowing each R to"  _n ///
" range over & | >=, so 3^5  permutations" _n ///
" each explicitly checked against known validated expressions"  _n ///
" (see the do file for details)"  _n(2) ///
" PART 2 A slightly different test is to take some arbitrary complex expression" _n ///
" ((p R1 q) R2 !(!r R3 s)) R4 !t" _n ///
" and try all possible permutations acrosss R1,R2,R3,R4 of & | > >= < <= == !=" _n ///
" in each case validating against a sequential pairwise construct version;" _n ///
" using the expression in each of five possible spaces of " _n ///
" (andd in extended and non-extended mode)" _n ///
" v = exp if exp, ifnot(exp) else(exp) when(exp)" _n(2) ///
" Scanning across these permutations takes some time " _n ///
`" ("some time" == leisurely lunchtime-ish ? -- depends on your machine)"' _n ///
" so you can, if you wish, skip for now. "
local k 99
while `k'==99 {
  noisily di " Skip (y/n)?"  _r(yy)
  if "$yy"=="Y"|"$yy"=="y" {
     local skip 1
     continue, break    
  }
  if "$yy"=="N"|"$yy"=="n" {
     local skip 0
     continue, break    
  }
}
if !`skip' {
*
local v1 p
local v2 q
local v3 r
local v4 s
local v5 t
local v6 u
local v7 r
local v8 t
*
noisily di " {txt}PART 1" _n ///
" Patience, until the dots reach{hline 47}here." _n " ."_c 
foreach r1 in & | >= {
foreach r2 in & | >= {
foreach r3 in & | >= {
foreach r4 in & | >= {
noisily di "." _c
foreach r5 in & | >= {
*
local s `v1'`r1'`v2'
local p `v3'`r2'`v4'
local q `v5'`r3'`v6'
local r `v7'`r4'`v8'
local t `v2'`r5'`v6'
*
foreach x in p q r s t { // ie across expressions, not vars
local v`x' "``x''"
if strpos("``x''","&")!=0 local v`x' = subinstr("``x''","&","a",1)
if strpos("``x''","|")!=0 local v`x' = subinstr("``x''","|","v",1)
if strpos("``x''",">=")!=0 local v`x' = subinstr("``x''",">=","GE",1)
capture drop `v`x''_e
quietly validly `v`x''_e = ``x'' , e
}
*
capture drop v
validly v = `s' if `p', ifnot(`q') e
assert (v==`vs'_e) if (`vp'_e==1)
assert (v==`vq'_e) if (`vp'_e==0)
assert (v==.) if (`vp'_e==.)
assert  (v==.a) if (`vp'_e==.a) & ((`vs'_e==.a)|(`vs'_e<.))
assert  (v==.b) if (`vp'_e==.b) & ((`vs'_e==.b)|(`vs'_e<.))
capture drop v
validly v = `s' if `p', ifnot(`q') else(`r') e
assert (v==`vs'_e) if (`vp'_e==1)
assert (v==`vq'_e) if (`vp'_e==0)
assert (v==`vr'_e) if ((`vp'_e!=1)&(`vp'_e!=0))
capture drop v
validly v = `s' if `p', else(`r') e
assert (v==`vs'_e) if (`vp'_e==1)
assert (v==`vr'_e) if (`vp'_e!=1)
*
capture drop v
validly v = `s' if `p', ifnot(`q') when(`t') e
assert (v==`vs'_e) if (`vp'_e==1)&(`vt'_e==1)
assert (v==`vq'_e) if (`vp'_e==0)&(`vt'_e==1)
assert (v==.) if ((`vp'_e==.)&(`vt'_e==1))|(`vt'_e!=1)
assert  (v==.a) if (`vp'_e==.a) & ((`vs'_e==.a)|(`vs'_e<.))&(`vt'_e==1)
assert  (v==.b) if (`vp'_e==.b) & ((`vs'_e==.b)|(`vs'_e<.))&(`vt'_e==1)
capture drop v
gen v = 3
validly v = `s' if `p', ifnot(`q') when(`t') e // no e-m passthru from p
assert (v==`vs'_e) if (`vp'_e==1)&(`vt'_e==1)
assert (v==`vq'_e) if (`vp'_e==0)&(`vt'_e==1)
assert (v==3) if (`vp'_e>=.)|(`vt'_e!=1)
}
}
}
}
}

clear
validly gen_test_vars p q r s t, e `nonind' // can slightly shrink data
local list "& | > >= < <= == !="
noisily di _n " PART 2 (without extended)" _n ///
 " Patience, until the dots reach{hline 30}here." _n " ."_c 
validly set_extended off
foreach r1 of local list {
foreach r2 of local list {
noisily di "." _c
foreach r3 of local list {
foreach r4 of local list {
*
capture drop v
capture drop v1
capture drop v2
capture drop v3
capture drop v4
*
capture drop v
validly v = ((p`r1'!q)`r2'!(!r`r3's))`r4'!t
capture drop vt
validly vt = !q
capture drop v1
validly v1 = (p`r1'vt)
capture drop vt
validly vt = !r
capture drop v2
capture drop v3
validly v2 = (vt`r3's)
validly v2 = !v2
validly v3 = v1`r2'v2
capture drop vt
validly vt = !t
capture drop v4
validly v4 = v3`r4'vt
assert v4==v
capture drop v
capture drop v1
validly v = 7 if v4
validly v1 = 7 if ((p`r1'!q)`r2'!(!r`r3's))`r4'!t
assert v==v1
capture drop v
capture drop v1
validly v = 7 if p, ifn(v4)
validly v1 = 7 if p, ifnot(((p`r1'!q)`r2'!(!r`r3's))`r4'!t)
assert v==v1
capture drop v
capture drop v1
validly v = 7 if p, ifn(3) when(v4)
validly v1 = 7 if p, ifn(3) when(((p`r1'!q)`r2'!(!r`r3's))`r4'!t)
assert v==v1
*
}
}
}
}
*
clear
validly gen_test_vars p q r s , e `nonind' // can further shrink data
noisily di _n " PART 2 (with extended)" _n ///
 " Patience, until the dots reach{hline 30}here." _n " ."_c 

validly set_extended on
local list "& | > >= < <= == !="
foreach r1 of local list {
foreach r2 of local list {
noisily di "." _c
foreach r3 of local list {
capture drop v
capture drop v1
capture drop v2
capture drop v3
capture drop v4
validly v = (p`r1'!q)`r2'!(!r`r3's)
capture drop vt
validly vt = !q
validly v1 = (p`r1'vt)
capture drop vt
validly vt = !r
validly v2 = (vt`r3's)
validly v2 = !v2
validly v4 = v1`r2'v2
assert v4==v
capture drop v
capture drop v1
validly v = 7 if v4
validly v1 = 7 if ((p`r1'!q)`r2'!(!r`r3's))
assert v==v1
capture drop v
capture drop v1
validly v = 7 if p, ifn(v4)
validly v1 = 7 if p, ifnot((p`r1'!q)`r2'!(!r`r3's))
assert v==v1
capture drop v
capture drop v1
validly v = 7 if p, ifn(3) when(v4)
validly v1 = 7 if p, ifn(3) when((p`r1'!q)`r2'!(!r`r3's))
assert v==v1
}
}
}
}
}
noisily di _n(3) "{hline}" _n(2) _col(14) "NO ERRORS DETECTED" 
if `shreek' noisily di " {err}BUT note that since validly's version was v`tvers'" _n ///
     "     whilst this test file was designed to exercise v`vers'" _n ///
     "     there may be slippage;" _n ///
     "     get and use the relevant test file before believing implications.{txt}" _n(2) 
noisily di _n _col(8) "Implication?" _n(2) ///
 _col(8) "Translation from RPN to the cond() functions is robust;" _n ///
_col(8) "Syntax of: if p, ifnot(q) else(r) when(t) is robust;" _n ///
_col(8) "Translations from simple algebraic expressions into RPN is robust;" 
if `skip' {
   noisily di _col(8) "Examples of complex algebraic expressions are handled correctly" 
}
else {
   noisily di _col(8) "An extensive range of examples of complex algebraic expressions is handled correctly" _n ///
   _col(8) "(these examples provide a comprehensive test of program features)."  
}
if `skip'|`skip1' noisily di  _col(8) "(but, when at more leisure, do run the full test [not skipping])" 
noisily di _n(2) _col(8) "These constitute reasonable grounds for continuing to believe that" _n ///
_col(8) "{bf}validly{sf} does what it says: validly handle missing data" _n ///
_col(8) "in logical and relational expressions." _n(2) "{hline}"
vy set_defaults
}
