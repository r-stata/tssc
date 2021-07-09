*! validly v3.2.1 KIMacdonald 13Aug2013
program validly, byable(onecall) rclass
version 10 // see below
local vers 3.2
local vdate "v3.2.1 13Aug2013"
* 
*
*   (c) Kenneth Macdonald
*          Nuffield College, Oxford, OX1 1NF, UK
*          kenneth.macdonald@nuffield.ox.ac.uk
*
* PROGRAM VERIFICATION
*   The program is complex (and in places, having grown by accretion,
*   less elagant than it might be).  But it has been extensively tested.
*   A test file:
*       validate_validly.do
*   accompanies this program.
*
* PROGRAM STRUCTURE
*   The only 'innovative' part of this coding is section F 
*   which uses cond() to define logical (and implement relational) operators,
*   The rest is simply an interpreter-into-RPN and various degrees
*   of pretty-printing and chat.
*
* EFFICIENCY
*   Not much thought has been given to the CPU efficiency of the 
*   interpreter-into-cond [CPU cost here negligible]
*   BUT attention has been paid to make the *generated coding*
*   as CPU-efficient as possible (taking advntage of indicator-variables;
*   avoiding recalculation; so forth);
*   further: since &| are commutative, and R can be made so,
*   in any particular we check whether
*     e.g.  "s1 & s2" is "more efficient" than "s2 & s1" ?
*   in tersm of minimising cond calls (and within that, bracket depth) -- not sure if this
*   is the optimal strategy, but it does produce more compact code.
*   Intuition might suggest that coding specifically to 3-way relations 
*   (so p&q&r,p|q&r,p&q|r etc etc) might lead to some efficiencies; 
*    exploration suggests this is only very limitedly true, bearing in mind
*    that p,q,r may be non-indicator variables, and would make the parsing more complex.
*    That avenue is in abeyance, for the present.
*
*    other things that might be done:
*       in extended: track no-emv vars (since we have that info) to simplify their coding;
*       in source: keep track of all-logically-poss-source-codes attavhing to s[i] to hardcode
*                  "no-way s1-e,v could match s2-emv", again simplifying (we already do this when
*                  s1 or s2 are vars)
*                  (if one could readily find emvs for a var this could be applied to extended mode also)
*       
*
* VERSION of Stata
*   validly works happily on v10, hence version setting above
*   (to set that to later version would merely exclude those running 'old'
*    Stata versions without any advantage to others)
*   Admittedly the 'infinite string length' of V13 would have made some 
*   programming simpler, but the code was mostly developed when v12 was latest,
*   so let it stand.
*
*
*   Note: no explicit *break* provision since this program is not relevantly sensitive
*   
*
* A. Decode the command, into various expressions
*
* For each expression: (reporting actions if chat)
*    B Split active string into characters/symbols, marking bracket level
*    C Mark logical/relational brackets
*    D whence, Compacting into logical/relational operators and args
*    E Parsing into RPN
*    F Compile RPN into nested functions cond(); choose appropriate one
*
* Then EXECUTE command as appropriate, and issue reminders etc
*
*
*  DEBUG NOTE: (since you are reading the code ...) There is a
*       'debug(n)' option (not documented in the accompanying help file)
*       which sets:  `chat2' ; levels are increasing-inclusive, range 0-9
*       0 off
*       1 echoes final executed command (a useful minimal check)
*       5 shows working of parser
*       6 additional inelegant reporting
*       (undefined levels are free for use)
*       set_debug n    sets the debug default; overridden by debug(n)
*
*       
* Flags:
local actionlist ""
local actionA ""
local actionlistREF exp ifexp ifnot else when
local actionAREF  X C N E W
local alphaLC "abcdefghijklmnopqrstuvwxyz"
local arithopF 0 // arithmetic & extended (so that misbehaviour info can be given)
local arithopC "" //the first-found operator
local assert 0    //flag for assert
local assertOPN "" //assert options passthru
local asstring 0  //flag for assigned-string
local by "" // by text
local byF 0 //by flag
local cedilla = char(184)
local chat 0      //print switch
local chat2 0 // the debug switch
local chatnote  "{c |}{col 18}{it}note{sf} {c +}  "  // to simplify
local chatnotee "{c |}{col 18}{err}{it}note{sf}{txt} {c +}  "  // to simplify
local chatremind "{c |}{col 14}{it}reminder{sf} {c + }  "
local col23A "{txt}{c |}{col 23}"
local col23 "`col23A'{c |} " // single space after, so sometimes need another
local compactF 1 // flag to compact by commutation
local compactN 0 // counter for inversions
local dagger = char(134)
local default0 [if/]  [in]  [, Source(passthru) Sourcez Detail Extended debug(numlist int)  Widely ///
                  IFNot(passthru) else(passthru) when(passthru) 
local default `default0' NOPromote ]
local defaultx `default0' ]
local digits "0123456789"
local dots = char(133)
local else ""  
local elseALL 0 //flag for (else & absent ifnot), so else mops all
local elseF 0
local elseRPN "" //printable RPN
local elseCN 0 //number of compactings, this fn
local emissC 0 // flag for `note extended e-m in fnC'
local equals " =" //ease assert reporting
local equivalentF1 0 // flag for equivalence reporting
local equivalentF2 0 // flag for equivalence reporting
local expCN 0 //number of compactings, this fn
local expU "" // active form in final evaluation for assert
local extended ""
local extendedF 0 //flag for extended option
local extdefF1 0 // this and next, report flags on default extended
local extdefF2 0 
local extdefF3 0 
local fromvy 0 // flag for from-vy, no use at present
local genF 0 // flag for generate
local global 0    //flag for global - also set by wrap
local globalIF 0
local g_short 0 // pretty print on g,ge for gen
local ifexp "" // ifexp in any task
local ifexpF 0 // flag for gen/rep if-clause
local ifexpU "" // active form in final evaluations
local ifnot "" //
local ifnotF 0 //ifnot flag
local ifnotRPN ""  //printable RPN
local ifnotCN 0 //number of compactings, this fn
local impute 0    //imputed gen replace
local isstring 0  // flag for string var
local inF 0 // flag for in
local intext ""
local isNVAR 0 // counter for sourceNVAR
local mark "{txt}  {hline 6}{c TRC} " // indentation marker, for validly
local mark2 "{txt}{space 8}{c |}{space 1}"
local mark3 11 // corresponding _col()for followon
local marku `"local mark \`mark2'"' // update mark after use
local markn `"\`mark'{it}note{sf}: "' // just to save repetition
local markD "" // fn layout
local metmissF 0 // flag for missing optimisation
local metN 0 //number of evermet nonmiss variables
local mline 78 // max line length frem 'reg'
local nonindF 0 // flag for GEN_TV on non-indicator vars
local noneede 0 // flag for source+extended
local nop "" // the nopromote carry-thru option
local numer one two three four five
local plainEVER 0 // flag for a 'plain' argument ever encountered
local operators `"== >= <= != > < ! & | "'
local possible "" //null option
local precedence "" // for r(prcedence)
local prevEMV 0 // flag for emvs in partial replace
local qt "quietly "
local range ""
local refers 0 //flag for "conditional invokes result var
local remindF 0 // reminder switch
local remindeverF 0 // flag to simplify remind reporting for nonchat
local repF 0  // flag for replace
local repALL 0 // flag exhaustive replace
local resultvar 0 //additional switch on resultvar only
local returnRPN "" //simple RPN
local rmist 0     //total literal relations involving mdc
local smax 10     //set stacksize max
local sourceCHAR  97  //active char() for e-mv in source
local sourceREF 97 // reference point
local sourceF 0 //flag for source (E|R)
local sourceR  0 //flag for random source
local sourceVAR "" //source vars
local sourceNVAR "" //vars lacking mvs in source
local sourceXM "" //associated extended-missing codes
local sourcewarnF 0 //flag to warn on interpretation of 'p R emv'
local sourcewarnEMV " " //the emv
local sourceprev 0 // counter for previous used source codes
local stringEMV ".s"
local stringTRIP 0 // flag potential invocation of stringEMV
local stringTRIP 0 // flag to help source table report
local typelist byte int long float double // for generate
local type ""  // for generate explicit 'type' specification
local usevars 0 //flag to use workspace vars in computing
local validlyDefault il ed te ct ng nd ss t2 // use all, else updates may confuse
local vlabND "" // marker for undefined value label
local var ""      //ease assert reporting
local vert " " // replaced by vertical line {c |} for some reporting
local vvers "{c RT}v`vers'{c LT}"
local warn_max 0 // flag for max() reminder
local warn_mi 0 //flag for mi() warning
local warn_min 0 //flag for min() reminder
local warn_mv 0 //flag for pRmissing warning
local when ""
local whenF 0
local whenRPN ""
local whenTXT "" //the txt for when "& zvarW"
local whenVAR "" //the actual var " & `zvarW'"
local whenRAW "" //the when expression
local whenCN 0 //number of compactings, this fn
local whenCONS 0 //flag for when constant
local widely ""   //null otion
local wrap 0      //flag for wrapped command
local w0 0 //flag for explicit R
local zvar ""
local zvarC ""
local zvarW "" // just nulls, in case of inadvertant print
*
* 
local rpn `"`r(RPN)'"'  // lest needed for call to vy RPN below
local precedence "`r(precedence)'"
local tempifcond `"`r(ifcond)'"'
*    (otherwise it gets scrubbed before then (by captures I think))
return local vers `vers'
*
if _by() {
   local by "by `_byvars'`_byrc0': "
   local byF 1
}
*   NOTE when executing generate and replace commands below
*       'by' has no effect where (as for some in `usevars' mode)
*        reference is only to existent variables;so it is there left silent
*
* has it been called from vy? (currently only affects OP layout)
if strpos(`"`0'"',"`dots'") { // that untypable flag, added by vy
   local 0 = subinstr(`"`0'"',"`dots'"," ",.) // scrub it
   local mark "{txt}  {c -}{c TRC} " // remember to use quoted form if using as arg
   local mark2 "{txt}{space 3}{c |}{space 1}"
   local mark3 6
   local fromvy 1 // lest needed at some time
}
* 
* keep track of settings for session in global macro
capture confirm ex $validlyDefault
if _rc!=0 DEFAULT
else {    //paranoia kicks in
   local j 0
   local k 0
   foreach i of local validlyDefault { // not to be confused with $validlyDefault
      local j = (strpos("$validlyDefault","`i':")!=0)+`j'
      local ++k
   }   
   if `j'!=`k' { // very implausible; but caught in alien use
      di "{col `mark3'}{err}Note:{txt} {help validly##macrotoggle:{bf}{c S|}validlyDefault{sf} already defined}" ///
         " (but not by current {bf}validly{sf}),"
      while 1 {
         di "{col `mark3'}{space 6}{txt}can {bf}validly{sf} use it now (y/n)?"  _r(validly_t_m_p_)
         if "$validly_t_m_p_"=="Y"|"$validly_t_m_p_"=="y" {
            DEFAULT
            macro drop validly_t_m_p_
            continue, break    
         }
         if "$validly_t_m_p_"=="N"|"$validly_t_m_p_"=="n" {
            di "{err}Continuation deemed " _c
            macro drop validly_t_m_p_
            error 310 
         }
      }
   }
*
*   get default debug setting
   DEFVAL t2 
   local chat2 `r(default)'  // to allow early debug - see above
}
*
*______________________________________________
* A. decode the command
*
*  use "syntax" to decode where possible, since it does useful checking
*
* local 0 = subinstr(`"`0'"',"()","( )",.) // kludge for a() ## reinstate if reinstate assert
*
* to handle spaces within strings; put a marker there, unscramble later
local imax = length(`"`0'"')
local i 0
local quote 0
local zero ""
while `++i'<= `imax' {   //scan active exp
   local c = substr(`"`0'"',`i',1)
   if `"`c'"'==`"""' local quote = 1 - `quote'
   if `"`c'"'=="" local c " "
   if `quote' & `"`c'"'==" " local c `dots' // space marker
   local zero = `"`zero'"'+`"`c'"'
}
if `quote' {
   di as err "Missing closing quote, " _c
   error 198
}
local 0 `"`zero'"'
*  OK, embedded string spaces now marked
*
local 0 = itrim(`"`0'"') // tidy unquoted spaces to singles
local raw `"`0'"' // storing to allow typing as reminder
*
* note:  ", else()" etc is parsed as if no "else(ex)" has been given; 
* but is better seen as an error (otherwise user may not notice absence=inaction):
local 0 = subinstr(`"`0'"',"( )","()",.) // collapse "else( )" etc to ease detection
foreach x in else() when() ifn() ifnot() source() s() {
   if strpos(`"`0'"',"`x'") CANT `x' "no argument"
}
*
if "`1'"=="egen"  NOEGEN "`mark'" "`mark2'" //issue apology - note quotes since mark contains spaces
else if "`1'"=="global" {
*  *trim first two params out of 0, reducing 0
   gettoken action 0 : 0, parse(" =")
   local action global
   gettoken var 0 : 0, parse(" =")
   confirm names `var'
   gettoken ift : 0, parse(" =")
   if "`ift'"=="if" {
      capture syntax  if/   [, Detail debug(numlist int)  Widely ]
*      to give user reminder, via TELL_G, of restricted syntax, if they have made error
      TELL_G "`mark'" "`mark2'"  `mark3' `mline'  // only writes if error
      syntax  if/   [, Detail debug(numlist int)  Widely ]
      local globalIF 1
      local ifexp = trim(`"`if'"')
      local if "" // clear the if-condition, which otherwise confuses later reporting ##
   }
   else {  //no if
     local 0 = "="+`"`0'"' // add = to allow syntax analyser to work
     capture syntax  =/exp   [, Detail debug(numlist int) Extended ]
*       to give user reminder, via TELL_G, of syntax if they have made error
     TELL_G "`mark'" "`mark2'" `mark3' `mline'  // only writes if error
     syntax  =/exp   [, Detail debug(numlist int) Extended ]
   }
   local global 1
   if  `byF' CANT by global
}
else { // not global
   if "`1'"=="generate" | "`1'"=="gen" |"`1'"=="replace"  | "`1'"=="rep" | "`1'"=="g" ///
    | "`1'"=="ge" | "`1'"=="gene"| "`1'"=="gener" | "`1'"=="genera"  |"`1'"=="generat" {  
*     (I would prefer to restrict to gen/generate, but standard Stata syntax allows all)
       if length("`1'")<3 { // at least mutter about these, reduce confusion on implicit
          di as txt "`mark'{inp}`1'{txt} is read as '{ul:g}enerate' (as is Stata's convention)" 
          `marku'
          local g_short 1
       }
*
*      NOTE: =/exp in *syntax* returns _rc=109 type-mismatch ERROR when
*            it encounters a string expression; [seems a Stata "feature"]
*            so we need following kludge to handle:
      capture syntax  anything  =/exp  // checking just the exp bit
     if _rc==109 { // that error might come from valid string expression:  ="cat" 
         local zanything `anything' //on this error, anything is apparently returned OK
         local j=strpos(`"`0'"',"=")+1
         if `j'==1 error 198
         local 0 = substr(`"`0'"',`j',.)
         local zeroshift `"`0'"' //store this bit 
         syntax  anything  `default'
         local 0 = `"=(`anything')=="text""'  //make a string-equivalence expression
         capture syntax =/exp  //see whether anything=="text" parses    
         if _rc==0 { //valid string
            local asstring 1
            local 0 `"`zeroshift'"' //since that last call has overwritten if and in etc
            syntax  anything  `default'
            local exp `"`anything'"'
         }
         else error 109 // the initial error 109 is real
         local 0 `"`zero'"'  //restore
      } // non 109 errors will anyway fail at the next step
*
     if `asstring' local anything `zanything' // recover
        else syntax anything  =/exp  `default'
*
     tokenize `anything', parse(": ") // to allow :value-label
*      
      if "`1'"=="replace" |"`1'"=="rep" {
         if `"`3'"'!="" {
            di as err `"'`1' `2' `3'' not allowed"' 
            error 101
         }
         local var `2'
         VCHECK `asstring' `var'
         local action replace
         local repF 1
      }
      else {
         local action generate
         local genF 1
         if `chat2'>=5 di as err `"1|`1'|, 2|`2'|, 3|`3'|, 4|`4'|, 5|`5'|, 6|`6'|"' 
*          now extract type and value-label if appropriate, checking
         if `"`2'"'=="" error 111
         else if `"`3'"'=="" local var `2'
         else if `"`4'"'=="" {
            TLABEL  1 `2' `3' // this call ignores `2'
            local type `2'
            local var `3'
         }
         else if `"`5'"'=="" {
            TLABEL  0 `3' `4'
            local vlabND `r(tlabel)'
            local var `2'
            local vlab `4'
         }
         else if `"`6'"'=="" {
            TLABEL  0 `4' `5'
            local vlabND `r(tlabel)'
            local type `2'
            local var `3'
            local vlab `5'
        }
        else error 198
*
        if "`vlab'"!="" local vlab ":`vlab'" //for calls
*
        if "`type'"!="" { //check that 'type' is correct
           local j 1
           foreach i of local typelist {
              if "`i'"==`"`type'"' {
                 if `asstring' CANT `type' "string expression"
                 local j 0
                 continue, break
              }
           }
           if `j' { // not numeric
              local i = substr(`"`type'"',4,.)
              if indexnot(`"`i'"',"`digits'")==0 & length("`type'")<=6 {
                 local n = real("`i'")
                 if  substr("`type'",1,3)=="str" & `n'>0 & `n'<=244 {
                    if !`asstring' CANT `type' "numeric expression"
                    local j 0 
                 }
              }
           }
           if `j'  {
              di _n `"'{bf}`type'{sf}' not a {help data_types:recognised data type}"' 
              error 109
           }
           local type " `type'" //prettyprint
        }
        confirm new variable `var', ex
     }
     if `chat2'>=5 di as err `" report assembled gen/rep, exp1:`exp'    if: `if'    in: `in' "'
}
   else if "`1'"=="assert" {
*     *trim first param out of 0, reducing 0
      gettoken action 0 : 0, parse(" =")
      local 0 = `"=`0'"'
      syntax   =/exp  [if/]  [in]  [, Detail debug(numlist int)  Possible Widely Rc0 Null Fast]
      local ifexp = trim(`"`if'"')
      local assert 1
      local equals "" //stet
      if "`rc0'"!="" | "`null'"!="" | "`fast'"!="" local assertOPN ", `rc0' `null' `fast'" 
   }
   else if "`1'"=="gen_test_vars" {  //logically detached utility to make test data
      gettoken action 0 : 0, parse(" =")  //trim out generate_test_vars
      syntax  newvarlist(max=10)  [, Extended Nonind Ind ]
*      that 'ind' just to let me smuggle null setting in test-file
      if "`extended'"!="" local extendedF 1
      if "`nonind'"!="" local nonindF 1
      GEN_TV "`varlist'" `extendedF' `nonindF'
      exit
   }
   else if "`1'"=="" | "`1'"=="`dots'"{  // to handle both 'validly' amd 'vy'
*   prettyprint for returned r(RPN)
      local n = wordcount(`"`rpn'"')  // that was seved earlier
      local flag 0
      if !`n' {
         di as txt  "{col `mark3'}{res}r(RPN){txt} not currently available" // ###
         exit
      }
      di as txt "{space 6}Displaying the input and the resulting {help validly##RPN:RPN} coding, " 
      if "`precedence'"!=""  di "{space 6}with {help validly##precedence:precedence reminders} where issued, " 
      di  "{space 6}from the last call to {bf}validly{sf}; as found in {help validly##saved:r(RPN)}"
      local nn 0 //loop across components
      local ne 0 // expression count
      forvalues i = 1/`n' {
         local j = word(`"`rpn'"',`i')
         local ++nn
         if `nn'==1 { // expression name
            local j = substr("`j'",2,.)
            local jk = subinstr("`j'",":", "",.)
            local k = 4 - length("`jk'")
            local j = (2*`ne')+2
            if "`precedence'"!="" local flag = word("`precedence'",`j') // loaded same order as rpn
            local ++ne
         }
         if `nn'==2 { // expression
            foreach op of local operators {  // insert spaces for legibility
               if "`op'"=="<" | "`op'"==">" | "`op'"=="!" continue // skip lest get > =
               local j = subinstr(`"`j'"',"`op'", " `op' ",.)
            }
            local kj = length(`"`j'"') + 2
            di as txt _n "{space 6}{c TLC}{hline `kj'}{c TRC}"
            di as txt  " `jk' {hline `k'}{c RT}" _c
            di `" {inp}`j'{txt} {c LT}"'
         }
         if `nn'==4 { // rpn form
 *           local jj `"{txt}{c RT} "'
                        di as txt "  as{space 2}" _c
            if `flag' di as txt "{c LT}{c -}precedence invoked" 
               else di "{c |}"
            di `" RPN {c -}{txt}{c RT} "' _c
            local foot `"{txt}{c BLC}{c -}"'
            local j = subinstr(`"`j'"',"`cedilla'", " `cedilla' ",.) // so that word works
            local j = subinstr(`"`j'"',`"""', "`dagger'",.) // so that word works on strings
*             note that printing has to be piecemeal because the {inp}{txt} will probably overflow strings
*             ## should perhaps anyway checke here fpor stringlength also
            foreach v of local j { // identify component for layout
               local kk 0
               if `"`v'"'=="`cedilla'"  { 
                  local kk 1 // seperator
               }
               else {
                  foreach op of local operators {
                     if `"`v'"'=="`op'" {
                        local kk 2 // operator
                        continue, break
                     }
                  }
               }
               if `kk'==1  {
 *                 local jj `"`jj'`v'"'
                  di " {c |} "  _c
                  local foot "`foot'{c -}{c BT}{c -}"
               }
               else {
                  if `kk'==2 di `"{inp}`v'{txt}"' _c // operator
                  else { // expressioon
                     local v  = subinstr(`"`v'"',"`dagger'", `"""',.) // reset quotes
                     di `"`jj'{res}`v'{txt}"' _c
                  }
                  local ii = length(`"`v'"')
                  local foot "`foot'{hline `ii'}"
               }
            }
            di " {c LT}"
            di as txt "{space 6}`foot'{c -}{c BRC}"
         }
         if `nn'==5 local nn 0 // reset component loop
      }
      return local RPN `"`rpn'"' // this so returns are not destroyed on unargument vy
      if "`precedence'"!="" return local precedence "`precedence'"
      if `"`tempifcond'"'!="" return local ifcond `"`tempifcond'"'
      exit
   }
   else if substr("`1'",1,4)=="set_" {
      return local RPN `"`rpn'"' // this so returns are not destroyed on set
      if "`precedence'"!="" return local precedence "`precedence'"
      if `"`tempifcond'"'!="" return local ifcond `"`tempifcond'"'
*
      if "`1'"=="set_impute" {
         TOGSET te `2'
         exit
      }
      else if "`1'"=="set_extended" {
         TOGSET ed `2'
         if "`2'"=="ON" |"`2'"=="on" {
              di as txt "`mark'OK, extended {ul:on}{space 3}but {it}note{sf} that having {bf}extended{sf} mode as the default"  _n ///
                 "`mark2'{space 18}is {help validly##extended1:computationally expensive}"
         ULINE `mline' `mark3'
         }
         exit
      }
      else if "`1'"=="set_detail" {
          TOGSET il `2'
          exit
      }
      else if "`1'"=="set_compact" {
          TOGSET ct `2'
          exit
      }
      else if "`1'"=="set_nullstring" {
          TOGSET ng `2'
          exit
      }
      else if "`1'"=="set_reminder" {
          TOGSET nd `2'
          exit
      }
      else if "`1'"=="set_nomiss" {
          TOGSET ss `2'
          exit
      }
      else if "`1'"=="set_debug" { //  undocumented option, see above
          TOGSET t2 `2' // global marker "chat2:", preventing user guess at option
          exit
      }
      else if "`1'"=="set_defaults" | "`1'"=="set_default"  { // the non-"s" option just being kind
          DEFAULT
          di as txt "`mark'all switches reset to {help validly##minor:default settings}"
          ULINE `mline' `mark3'
          exit
      }
      else {
        di as err "{col `mark3'}`1' is, for {bf}validly{sf}, an " _c
        error 199 // tough if attempt at wrapping a set_ command
      }
   }
else { //implied gen/replace OR wrapper
*        assume it is implied, unless it fails to parse as such:
*
*       seek implied (but without `type', 'vlabel', 'nopromote'):
      capture syntax  name(name=var)  =/exp  `defaultx'
      if _rc==0 {
         local impute 1 // implied
         local ifexp = trim(`"`if'"')
      }
      else if _rc==109 { // this error - se above - might come from valid string expression: eg  ="cat" 
          local zero `"`0'"' //store
          gettoken var 0 : 0, parse(" =")
          gettoken temp 0 : 0, parse(" =") //trimming only 2
          local zeroshift `"`0'"' //store this bit ##
          capture syntax  anything  `defaultx'
          if _rc==0 & "`temp'"=="=" { //OK so far; check further that is string
              local 0 = `"=(`anything')=="text""'  //make a string-equivalence
              capture syntax =/exp  //see whether   anything=="text"   parses    
              if _rc==0 {  //valid string
                 local impute 1
                 local asstring 1
                 local 0 `"`zeroshift'"' //since that last call has overwritten if and in etc
                 syntax  anything  `defaultx'
                 local exp `"`anything'"'
                 local ifexp = trim( `"`if'"')
              }
           }
           local 0 `"`zero'"'  //restore
       }
*
      if `impute' { // is impute, what type?
         capture confirm variable `var', ex
         if _rc==0 {  //extant, so impute replace, check permission and type
            DEFVAL te
            if !`r(default)'  {
               di as txt _n " You have {help validly##rutility:{bf}validly set_impute{sf} configured to {bf}OFF{sf}}" ///
                _n " so, since {bf}`var'{sf} exists, present command {err}fails, as " _c
               error 110
            }
            VCHECK `asstring' `var' //check type
            local action replace
            local repF 1
         }
         else {  //new, impute gen, hope valid
            confirm new variable `var', ex
            local action generate
            local genF 1
         }
      }
*
      if !`impute' {  // assume wrapped command 
*        * first find validly’s own options
         local temps = strpos(reverse(`"`0'"'),",,")
         if `temps'!=0 {  // validlys options
            local zero `"`0'"'
            local 0 = substr(`"`0'"', -`temps', `temps'+2)
            syntax [, Detail debug(numlist int)  Widely]  
            local 0 = subinstr(`"`zero'"',","+`"`0'"',"",1) //temp delete v's opts 
         }
         local zero `"`0'"'
         local ci 0  // flag for comma
         local q 0 // withinquote flag
         local n = length(`"`0'"')
         forvalues i=1/`n' {
            local c = substr(`"`0'"',`i',1) 
            if `"`c'"'==`"""' local q = 1 - `q'
            if `"`c'"'==`","' & !`q' {  // unquoted comma
               local ci `i'
               continue, break  //out of forvalues
            }
         }
         if `ci'!=0 {    // are single-comma (=command's) options
            if !`temps' { // if no doubles, remark
               di as txt "`mark'attaching {help validly##wrap:single-comma} option(s)"  ///
               `" to {help validly##errorW:perceived wrapped} {bf}`1'{sf}"' 
               `marku'
            }
            local 0 = substr(`"`0'"',1,`ci'-1)
         }
*        * and parse, looking for 'if' and no =exp
         capture syntax [anything] [fweight  aweight  pweight  iweight] [if/] [in]
         if _rc!=0 {
            di as err _n "Check for misspellings, misspecified variables, inappropriate" _n ///
              "or duplicate options, or other varieties of " _c
            error 198
         }
         if `"`if'"'=="" {
            di `"`mark'{txt}Without an {ul:if} clause, we simply execute: {inp}.`by'`zero'{txt} "'
            ULINE `mline' `mark3'
            `by'`zero'
            exit
         }
         else { // wrapper
            local ifexp = trim(`"`if'"')
            local action global
            local global 1
 *           local var valid_if_exp_  // ##
            local wrap 1
            local if "" //##
         }
      }
   }
}
*
* OK, expression read; 
* ______________________________________________________________________________
*
macro drop _tempifcond // since can be long
* but first task is to get chat sorted
DEFVAL il
if `r(default)' local detail = "detail"
if "`detail'"!="" local chat 1
if `chat' & `g_short' ULINE `mline' `mark3'  //just aesthetics
*
* explicit debug status overides default setting
if "`debug'"!="" local chat2 `debug'
*
if `chat2'>=5 di as text "{hline}" _n " `vvers' `vdate'" _n "{hline}"
* di control:  chat=0 results, chat=1 +RPN & cond, 
*    chat=3   anything flagged - additional reassurance plus RPN compiler workings
*    caht=2 (set by setting the default as debug AND invoking debug)
*            minimal reportage of actual gen/replace/wrap/global commands issued
*            This is quite a good checking mode (though it messes layout)
*
local exp = trim(`"`exp'"')
*
local rpn ""
local precedence ""  // I think have by now been reset, but just-in-case
*
* local exp = trim(`"`exp'"')  //since seems to come with trailing blank
*
* next, handle IF 
* local step 1  // default for both global and plain
* local active `"`exp'"'   //exp1 active whether (1) global, plain, or (4)if
***************************************************************
*
        if "`vlabND'"!="" & !`chat' {  //chat OP appears later
           di as txt "`markn'{help validly##extype:value label} '{inp}`vlabND'{txt}'" ///
             " has yet to be defined"
           `marku' 
        }
*
if `"`if'"'!="" {
    local ifexpF 1  // a gen/rep if-clause exists
    local ifexp = trim(`"`if'"')  // already done for global/wrap/assert if appropriate
    local ifTXT " if"
}
else local ifTXT ""  //for reporting   
*
* set widely
    local wide = "`widely'"!=""
    if `wide' & !(`ifexpF'|`wrap'|`globalIF')  NEEDS widely if
*
* set extended  from option only now (to smplify source report below)
 if "`extended'"!="" local extendedF 1  // from option 
*
if `chat' {
   local markD "{col 7}{txt}{c |} " //layout in exp report
   local qt ""
}

*
* set compactor iff permitted
DEFVAL ct
if !`r(default)' local compactF 0
*
* set reminder for syntax inversions
DEFVAL nd
if `r(default)' local remindF 1
*
* set switch for attending to mvs in coding
DEFVAL ss
if `r(default)' local metmissF 1

*
* set extended missing value for null-string relations
DEFVAL ng
local stringEMV `r(default)'
*
* attend to source and source(.x,r)
if "`source'"!="" { //bracketed
   local sourceF 1
   local sourcerr 0
   local sourceraw `source' // for error report
   local source = subinstr("`source'","source(","",1)
   local source = subinstr("`source'",")","",1)
   local source = subinstr("`source'",","," ",1)
   local i = word("`source'", 1)
   local j = word("`source'", 2)
   if "`i'"=="r" { // for source(r)
      local sourceR 1
      if "`j'"!="" local sourcerr 1
   }
   else { // assuming source(.x,r) or source(.x)
      if length("`i'")>2 local sourcerr 1
      if "`j'"=="r" local sourceR 1
        else if "`j'"!="" local sourcerr 1
      local k = substr("`i'", 1,1)
      if "`k'"!="." local sourcerr 1
      local k = substr("`i'", 2,1)
      local jj = (`sourceCHAR'+26) //alphabet plus one
      forvalues m = `sourceCHAR' / `jj' {
         local mm `m'
         if "`k'"==char(`m') continue, break
      }
      if `mm'==123 local sourcerr 1
      local sourceCHAR `mm'
      local sourceREF `mm'
   }
   if `sourcerr' {
      di as txt _n "error in parameters in {inp}`sourceraw'"
      error 198
   }
}
else if "`sourcez'"!="" local sourceF 1
if `sourceR'  local sourceF 1
*
if `impute' & !`chat' { // appearing before notes
     di as txt "`mark'interpreted as a request to " _c
     if `repF' di "{err}`action'{inp} `var'{txt}" //`it'
     else  di "{inp}`action' `var'{txt}" //`it'
     `marku'
}
*
if `sourceF' {
   if `extendedF' {
      local noneede 1 // flag for later chat report
      if !`chat' {
         di as txt "`markn'{help validly##sourcecode:no need to specify {bf}{ul:e}xtended{sf}} " ///
         "in addition to {bf}{ul:s}ource{sf}"
         `marku'
      }
   }
   local extended "extended" //source implies extended mode
   local extendedF 1
}
*
* set extended from switch 
DEFVAL ed
if `r(default)'  { 
   if `assert' | `globalIF' | `wrap' { // only switch on where pertinent
      if !`chat' di as txt "`markn'suppressing, for this command, current default  {bf}extended:on{sf}  setting" 
      `marku'
      local extdefF1 1
   }
   else {
      if `extendedF' & !`sourceF'  { // dont mutter when implied by source
         if !`chat' di as txt "`markn'{bf}extended{sf} is already set as default" 
         `marku'
         local extdefF2 1
      }  
      else local extendedF 1  
   }
 }
*
* remaining checks
if "`nopromote'"!="" {
   if `genF' CANT nopromote generate // only an option in explicit gen/replace
   local nop ", nop" // for calls
}
if `asstring' {
   if `sourceF' CANT source "string-variable {bf}`var'{sf}"
   if `extendedF' {
      if "`extended'"=="" { // tolerant if is default setting only
         local extendedF 0
         if !`chat' di as txt "`markn'suppressing, for string variable, the default '{bf}extended:on{sf}' setting" 
         local extdefF3 1
         `marku'
      }
      else CANT extended "string-variable {bf}`var'{sf}"
   }
}
if `byF' { // given sequential calls, we must not let the by variables be modified
   foreach x of local _byvars {
     if "`x'"=="`var'" CANT "modifying `var'" "its use in {bf}by{sf}"
  }
}
*
local possibleF = "`possible'"!=""
*
if !`chat' {  //minimal need-to-know
   if `global'  {
     local i ""
     if `extendedF' local i " extended"
     di as txt "`mark'valid`i' version of {c RT}{inp} " _c
     `marku'
     if `globalIF'|`wrap' di `"if `ifexp'{txt} {c LT}"' _c
       else di `"`exp'{txt} {c LT}"' _c
     local i = `mark3'+14
     if length(`"`exp'"')+`mark3'>=20 di _n _col(`i') _c
     di `" placed in {res}"' _c
     if `wrap' di `"{c 'g}ifcond'{txt}, {help validly##savecond:{bf}r(ifcond){sf}}"'
       else di `"{c S|}`var'{txt}"'
     if `globalIF' & !`wide' TELL_NV `"`mark'"' //OK in wide mode, since retains raw
     if !`wrap' & !`globalIF' TELL_NC "`var'" `"`exp'"'  `"`mark'"'  
   }
   if `wide' & !`assert' {
      di "`mark'selecting observations when condition is true {it}{ul:or indeterminate}{sf}"
      `marku'
   }
   if `assert' {
      if `ifexpF' {
         di `"`mark'Considering observations where expression {inp}`ifexp' {txt}"' _n ///
           "`mark2'(when validly interpreted) is " _c
         if  !`wide' di "{ul:true};"
           else di "true {it}{ul:or indeterminate}{sf};"
         di "`mark2'amongst these, " _c
     }
     else di as txt "`mark'" _c
     `marku'
     if `possibleF'  di "{ul:only} observations where {c RT} {inp}`exp' {txt}{c LT} (validly interpreted)" _n ///
        "`mark'is {ul:known false}" _c
      else di `"any observations where {c RT} {inp}`exp' {txt}{c LT} (validly interpreted)"' _n ///
        "`mark'is false {ul:or unknown}" _c
	 di " will be seen as {ul:contradicting} the assertion."
     ULINE `mline' `mark3'
   }
 } 
*
*
* option ifnot 
if `"`ifnot'"' != "" {
   local ifnotF 1
   if !`ifexpF' NEEDS ifnot if
   local i = length(`"`ifnot'"')-1
   local ifnot = subinstr(substr(`"`ifnot'"',1,`i'),"ifnot(","",1) //extracting exp
   CHECKEXP `"`ifnot'"' `asstring' ifnot
} //end of ifnot
*
*
* option else 
if `"`else'"' != "" {
   local elseF 1
   if !`ifnotF' local elseALL 1 // flag for 0&mi
   if !`ifexpF' NEEDS else if
   if `wide' CANT else wide
   local i = length(`"`else'"')-1
   local else = subinstr(substr(`"`else'"',1,`i'),"else(","",1) //extracting exp
   CHECKEXP `"`else'"' `asstring' else
}  //end of else()

* option when 
if `"`when'"' != "" {
   local whenRAW `", `when' is True"'
   local whenF 1
*   if !(`ifnotF'|`elseF') NEEDS when ifnot|else
   local i = length(`"`when'"')-1
   local when = subinstr(substr(`"`when'"',1,`i'),"when(","",1) //extracting exp
   CHECKEXP `"`when'"'  0  when // has to be numeric
   if !(`ifnotF'|`elseF') {
      local i = trim(`"`ifexp'"')
      local j = trim(`"`when'"')
      if `ifexpF' & !`wide' & !`extendedF' { // e works with replace, but less confusing to be silent
         if !`chat' {
            di `"`markn'exactly equivalent to {inp}.vy `var' = `exp' if (`i') & (`j'){txt}"'
            `marku'
         }
         local equivalentF1 1  
      }
      if !`ifexpF' & !`extendedF' { // gen in e mode fills-in from if, unlike when()
         if !`chat' {
            di `"`markn'exactly equivalent to {inp}.vy `var' = `exp' if `j'{txt}"'
            `marku'
         }
         local equivalentF2 1  
      }
   }

}  //end of when()
*
*
* make reporting/action strings for ‘in’ 
if "`in'"!="" {
   local in " `in'" // to save layout
   local intext "  in {it}range{sf}"
   local range = subinstr("`in'","in","",1)
   local inF 1
}
*
*
* Decide on computation mode:
*    usevars 1  which utilises workspace variables
*    usevars 0  for simplest '=p' or '=p if q' (default)
if `ifnotF' | `elseF' | `whenF' local usevars 1 
* if a 'fresh generate we followthru conditional emvs
if !`wide' & `genF' & !`elseF' & `extendedF' & `ifexpF' local emissC 1 
if `emissC' local usevars 1 // that also needs worksapce vars
*

* output header:
if `chat'  {
   local i = `mline'-10
   di as txt _n "{c TLC}{hline `i'}`vvers'{hline 2}{c TRC}"
   if `wrap' di `"{txt}{c |} Generating a version of {c RT}{inp} if `ifexp' {txt}{c LT}"'
   else {
      di "{txt}{c |} A version of {input}" _c
      if `impute' & `repF' di "{err}" _c
      di "`action'{txt}"
      if `global' {
	     di "{txt}{c |} to construct a macro " _c
	     if `globalIF' di "for use in conditions" _n "{txt}{c |} (so considering  {inp}if exp{txt} )"
         else di 
	  }
   }
   di "{text}{c |} {ul:correctly} handling 'missing' in logical/relational expressions."
   local it ""
   if `ifnotF'|`elseF'|`whenF' {
     local it = ", "
     if `ifnotF'  local it = "`it'" + "ifnot({it}exp{sf}N) "
     if `elseF' local it = "`it'"+ "else({it}exp{sf}E) "
     if `whenF' local it = "`it'"+ "when({it}exp{sf}W)"
   }
   di as txt  "{c |}" _n "{txt}{c BLC}{hline 14}{c TRC}" _n  "{space 3}{txt}considering {c +}{c -} " _c
   if !`global' di "{inp} `var'`equals' {it}exp{sf}" _c
   if `ifexpF'|`wrap' | `globalIF' di " {inp}if {it}exp{sf}C" _c
     else if `global' di "{inp} exp" _c
   if !`wrap'  di "`intext'`it'{txt}" _c
   di  _n "{txt} {c TLC}{hline 13}{c BRC}" _n " {c |} " _c
   if !`global' &  (`ifexpF'|`usevars')  di "assembling functions, as fitted to their deployment in the evaluation below" 
      else di "and assembling the appropriate function:"
      di " {c BLC}{hline 76}"
}
*
* assemble an action list matching this call
local k 0
foreach ii of local actionlistREF {  // possible exps
   local ++k
   if `"``ii''"'!= ""  { 
      local `ii' = trim(`"``ii''"')  // tidying trailing blamks in paasing
      local actionlist `actionlist' `ii'
      local jj = word("`actionAREF'",`k')
      local actionA `actionA' `jj'
   }
}
*
* next  fill the decision array dij, for processing RPN below:
*  symbols: start#=1   |=2  &=3  R=4  !=5 (=6  )=7 end#=8  
*   dij=  1 is r<c   2 is r=c  3 is r>c  4 is ##  9 is err
local d "111119413111133133111331333113313332133211111291333393339999999955521555"
local m 0
*
* Decision table:
*   #start=1, #end=8  function=@
*      2 3 4 5 6 7 8 9
*      | & R ! ( ) # @
*    +----------------
*   1| 1 1 1 1 1 9 4 1
*   2| 3 1 1 1 1 3 3 1
*   3| 3 3 1 1 1 3 3 1
*   4| 3 3 3 1 1 3 3 1
*   5| 3 3 3 2 1 3 3 2
*   6| 1 1 1 1 1 2 9 1
*   7| 3 3 3 3 9 3 3 3
*   8| 9 9 9 9 9 9 9 9
*   9| 5 5 5 2 1 5 5 5
*
if `chat2'>=5  di _n "Decision table:" _n "#start=1, #end=8  function=@" _n  ///
    "    2 3 4 5 6 7 8 9" _n "    | & R ! ( ) # @" _n "  {c TLC}{hline 16}" _c
forvalues i=1/9 { // put d into 'array' dij
   if `chat2'>=5 di _n " `i'{c |}" _c
   forvalues j=2/9 {
      local ++m
      local d`i'`j' = substr("`d'",`m',1)
      if `chat2'>=5 di " `d`i'`j''" _c
   }
}
if `chat2'>=5 di _n
*
* set reminder counters for invocations of precedence rule;
local remindEXP 0 // number of expressions affected
* for chat the following are zeroed after each expression
* for !chat they cumulate across all expressions
local remind1 0  // flag to count where &| precedence upsets LR sequence
local remind2 0 // dito relation vs  logical 
local remind2a "" // string of relations
local remind2b "" // corresponding logicals
* reset at each pass:
local ticktock 0 // handle double references
local remindTHIS 0  // expression counter
*
*
* OK, now examine each expression, decoding as appropriate
* ______________________________________________________________________________________________
* _________________________________________________________________________________________________________
* _____________________________________________________________________________________________
*
local actionn 0 //action counter, only used for W lookup below
foreach what of local actionlist { 
* _________________________________________________________________________________________________
*
   local active `"``what''"' // active is processed
   local ++actionn
   local W = word("`actionA'", `actionn')  //capital what
   if "`W'"=="X" local W  "" // X to allow being fed as arg
*
*   for simplification, set flags for "this expression is':
   foreach i of local actionlistREF {  // clear all
      local is`i' 0
   }
   local is`what' 1 // this exp
*
   local everN 0 // flag for any no-mv simplifications this command
   local everIND 0 // flag for any indicator simplification actually used in this command
   local sourceD 0 // flag to register whether potential source var in fact had mv
* behaviour of source and extended is expression-specific;
*   expW never heeds;
*   expW heeds only on generate, without else or wide
   local emiss 0    // expression-specific flag for 'use e-m'
   local esourceF 0 // ditto for source
   local esourceR 0 // ditto for sourceR
if  `isexp' | (`isifexp' & `emissC') | `isifnot' | `iselse' {
       local emiss `extendedF'
       local esourceF `sourceF'
       local esourceR `sourceR'
   }
*
*  validly assumes the user leaves all the "handling of misssing-tests" to it
*  but we should check that user has followed this sdvice:
*  this is test for warn_mi; warn_mv is set later
*  We also check min(), max() to give reminder
   foreach x in mi min max {
      local temp `"`active'"'
      local i = strpos(`"`temp'"',"missing(")
      if `isifexp'  & `i'>0  local warn_mi 1
      while `warn_`x''==0 { // mi( screened against other fn ending in mi(
         local i = strpos(`"`temp'"',"`x'(")
         if `i'==0 continue,break
         local c = substr(`"`temp'"',`i'-1,1)
         local j 1
         if `"`c'"'!="" local j= indexnot( `"`c'"',  "`alphaLC'"+upper("`alphaLC'")+"`digits'"+"_")
         if `j'==1 {
            if "`x'"=="mi" {
               if `isifexp' local warn_`x' 1
            } 
            else local warn_`x' 1
            continue, break
         }
        local temp =  substr(`"`temp'"',`i'+2,.)
      }
   } // checking complete
* __________________________________
* B. Split active string into characters/symbols, marking bracket level
*
local funf 0 //flag to note function call inthis exp
local n 0  //decomposed string length
local p 0  //bracket level
local imax = length(`"`active'"')
local i 0
if `chat2'>=5 di as err `" reporting active exp## `active' ##"'
local outstring 1 //to denature symbols within strings
local subscript 0 // and symbols in subscripts
while `++i'<= `imax' {   //scan active exp
   local c = substr(`"`active'"',`i',1) 
   if `"`c'"' ==`"""' local outstring = 1 - `outstring'
   else if `"`c'"' ==`"["' local ++subscript
   if `"`c'"' ==`"]"' local --subscript
   if `"`c'"' !="" {  //only consider nonspace
      if `"`c'"' =="~" local c "!"  //simplify to one negation symbol
      if `outstring' & !indexnot(`"`c'"',"<>=!") { //symbols
         if substr(`"`active'"',`i'+1,1)=="=" {  // composites
            local x`++n' = `"`c'"'+"="
            local ++i
         }
         else {
            if "`c'"=="=" ERR197 `"`raw'"' 1
            local x`++n' = `"`c'"'
         }
         local t`n' 4 // relation
         if `"`x`n''"'=="!" local t`n' 5 // negation
         local q`n' `p'
      }  
      else {  
         local x`++n' `"`c'"'
         local t`n' 0
         local q`n' `p'
         if `outstring' {
   	   		 if `"`c'"'=="(" { 
                local ++p
                local q`n' `p'  
             }
     	     else if `"`c'"'==")" {
                 local --p
     	         if `p'<0 ERR197 `"`raw'"' 2
             }
      	     else if `"`c'"'=="|" local t`n' 2
             else if `"`c'"'=="&" local t`n' 3
         }
      }
      if `outstring' & !`subscript' & `emiss' & !`arithopF' & !indexnot(`"`c'"',"+*/-^") { 
         local arithopF 1  //side-task, look for arithmetic ops
         local arithopC "`c'"
      } 
   } 
} 
if `p'!=0 | `n'==0 | `subscript' ERR197 `"`raw'"' 3
*   (probably this  - and calls to ERR197 above - unnecessary since picked up by 'syntax')
*
if `chat2'>=5 { //chatter
   local i=0
   di as inp " x[i] t[i]  q[i] before markup"
   while (`++i'<= `n') {   //1
      di as res `" `x`i''  `t`i'' `q`i`'' "'
   }
}
*  so x is 'vector' of characters, length n
*  their type in t
*  and their bracket level in q

* __________________________________
* C Mark logical/relational brackets
*
local i=0
while (`++i'<= `n') {   //1
   if (`t`i''>=2&`t`i''<=5) & `q`i''>0 {  //binary or logical
*   doing it even for Unary, which will be redundant but not bad
*   works without need to check intervening operators because of way levels works
      local p `q`i''  // level
      local j `i'
      while (`--j'>0)  {  
         if `"`x`j''"'=="(" & `q`j''==`p'  {  
            local t`j' 6
            continue, break
         } 
      } 
      local j `i'
      while (`++j'<=`n')  {  
         if `"`x`j''"'==")" & `q`j''==`p'  {  
            local t`j' 7
            continue, break
         } 
      } 
   }
   if `t`i''==5 {  //unary not    -- further test for following bracket
      local j=`i'+1
      if `"`x`j''"'=="(" {  
         local p `q`j''  
         local t`j' 6
         while (`++j'<=`n')  { 
            if `"`x`j''"'==")" & `q`j''==`p'  {  
               local t`j' 7
               continue, break
            } 
         } 
      }
   } 
}
*   (probably this ## - and calls to ERR197 above - unnecessary since picked up by 'syntax')
*
if `chat2'>=5 { // chatter
   local i=0
   di " {res} x[i] t[i]  q[i]  aftr markup"
   while (`++i'<= `n') {   //1
     if `t`i''>0 di "{inp}" _c
     if `t`i''==6 |`t`i''==7 di "{txt}" _c
     if `q`i''==1 local h "#"
     if `q`i''==2 local h "##"
     if `q`i''==3 local h "###"
     if `q`i''==4 local h "####"
     di `" `x`i''  `t`i''  `q`i''  `h'  {res}"'
   }
}
* __________________________________
* D whence, Compacting into logical/relational operators and args
*
local k 0
local i 0
* top :
local x0 "#"
local t0 1    // start symbol
while (`++i'<= `n') {   
   if  `t`i''==6 & `t`k''==0 {  // bracket, nonlogic before 
*     Presently, an 'error':
*      we get here if
*     EITHER a function contains logical/relational expression
*     OR logical/relational expression pre-operated on by arithmetic.
*     The second restriction (unless validly were to decode ALL operators to RPN and reconstitute them)
*      is probably unavoidable (there is also a further call to MIXED below for arithmetic POST-operators). 
*      There may in future be ways around the first restriction?
      local function `x`k''
*        extract, for report, title of specific function
      local i= indexnot( reverse(`"`function'"'),"`alphaLC'"+upper("`alphaLC'")+"`digits'"+"_")
      if `i'!=0     local function = substr(`"`function'"',length(`"`function'"') - `i' + 2,.)
      local j 0
      if  `i'==1 {
         local j 1 // pre-operator flag
         local k `active'
      }
      else local k `function'
      MIXED `j'  `vvers'  `k'  // report, exit with error
   }
   local ++k
   if (`t`i''!=0) {  // operator
      local t`k' `t`i''
      local x`k' `"`x`i''"'  //note: compacting back into x
   }
   else  {   
      local t`k' 0
      local x`k' `"`x`i''"'
      local j `i'
      while `++j'<=`n' {    
         if `t`j'' !=0 {
            local --j
            continue, break
         }
		 local ct `"`x`j''"' 
		 if `"`ct'"'=="`dots'" local ct " " //restoring quoted space
         local x`k' = `"`x`k''"' +  `"`ct'"' 
      }  
      if `"`x`k''"'=="(" | `"`x`k''"'==")"  local --k
*      above, since zero level singleton brackets are 
*      redundant logical or relational brackets
      local i `j'
   }  
}  
* and tail:
local ++k
local x`k' "#"
local t`k' 8  // end symbol, distinguished by type
local plain =`k'==2 // flag for expression without logical/relational operators
*______chatter:
if  `chat2'>=5 {
   local c ""
   di _n  "{txt}Packed version of exp{res}`c'{txt}:"
   di as txt " Cell{c |}typ{c |}char "
   local i= -1
   while (`++i'<= `k') {
      if `i'<10  di `"  `i'  {c |} {res}`t`i''{txt} {c |} {res}`x`i''{txt}"' 
       else di `" `i'  {c |} {res}`t`i''{txt} {c |} {res}`x`i''{txt}"' 
   }
}
*^^^^^^end chatter.
*
* __________________________________
* E Parsing into RPN
*
* From compacted x into r, index ir
* using as sidings
*    symbol stack s, index is
*    variable stack b, index ib
*
* these vectors contain not values, but pointers to x, t
*   NOTE x,t run from 0 
* and negative pointer in ib points to ir
*
forvalues i = 1 / `smax' {
  local s`i' 0
  local b`i' 0
}
local rmax 200 // the result can grow either end - but cant use neg names
local rmin 200 // so centre r on 200, arbitrarily for prettyprint
local ib 0
local i  0 
local m  0  // now scan from first read item in x1
local is 1  // prime the symbol stack with start
local s1 0  // start symbol in x0,t0
local s2 0  // to allow first while

* __________________________________
*
while  `t`s2''!=8 | `ib'>0 {   //until endsymbol but while args 
* __________________________________
* we repeatedly deal with the symbol stack,
* only getting fresh chars when symbol stack flags no-action
*
*______chatter:
   if `chat2'>=5 {
      local ++m
      di _n "{inp}Step `m' {txt}" _n " {c |} Sym{c |} Operands (cell, content)"
      local a = max(`is',`ib')+1
      while `--a' >0 {
         local w1 `"`x`s`a'''"'
         local w4 = length(`"`w1'"')
         if `w4'<2 local w1 `" `w1'"'
         if `a'>`is' local w1 "  "
         if `a'>`ib'  di `" {c |} {res}`w1'{txt} {c |}    "'
         else{
            if `b`a'' > 9  di `" {c |} {res}`w1'{txt} {c |}   `b`a'' {res}`x`b`a'''{txt}"'
            else if `b`a'' >= 0  di `" {c |} {res}`w1'{txt} {c |}    `b`a'' {res}`x`b`a'''{txt}"'
            else di `" {c |} {res}`w1'{txt} {c |} `b`a'' {inp}Stack{txt}"'
         }
      }
      di " {c BLC}{hline 4}{c BT}{hline 10} "
      if `rmin'<`rmax' {  //print stack, and marker for top expression
         di "Stack:"
         local it = `rmax' +1
         local ikk 1 //operands excess
         while (`--it' > `rmin') {
            if `t`r`it'''>0 & `t`r`it'''!=5 local ++ikk //dyadic ops
            di `" `it' {c |} {inp}`x`r`it'''{txt}   `t`r`it'''  "'
            if `t`r`it'''==0 { //operand
               local --ikk
               if `ikk'==0 { 
                  di " {hline 7}"
                  local ikk 9999 // only marking top exp
               }
            }
         }
      } 
      else{
         di "Stack: {inp}empty{txt}"
      }
   }
*^^^^^^end chatter.
   if `is'== 1 local dd 1 // no action on first entry
   else {  // real comparisons
      local is2 =`is' - 1
      local dd `d`t`s`is2'''`t`s`is''''   //decision lookup
*
      if `chat2'>=5 di `"Relate sym {res}`x`s`is2'''{txt} to {res}`x`s`is'''{txt} {hline 2} decision {res}`dd'{txt}"'
      if `chat2' & `dd'==3 & (`t`s`is'''==4) & (`t`s`is2'''==4)  ///
         di as err "`mark'{err}`x`s`is2''' and `x`s`is''' have merely left->right precedence order{txt}"
*
      if `remindF' { //check, if enabled, for syntax sequence inversions
         if `is'>2 & `dd'==1 {
            if `chat2'>=5 di as err `"PRECEDENCE `t`s`is''' ## `t`s`is2''' ##   `x`s`is''' ## `x`s`is2'''     "'
            if (`t`s`is'''+`t`s`is2''')==5 {
                local ticktock = 1 - `ticktock' // handling double-call each occurrence
                if `ticktock' {
                   local remindTHIS 1 // flag for rule-invoked--this-exp
                   local ++remind1 // & |
                }
            }
            if (`t`s`is'''==4) & (`t`s`is2'''==2 | `t`s`is2'''==3) {  // relation v logical
               local remind2 1 
               local ticktock = 1 - `ticktock' // as above
               if `ticktock' {
                  local remindTHIS 1 // flag for rule-this-exp
                  local remind2a `"`remind2a'  `x`s`is'''"'  // cumulate
                  local remind2b `"`remind2b'  `x`s`is2'''"'
               }
            }
         }
      }
   } 
   if `dd'==5 { // move fn -- ## currently inactive
      ERR197 `"`raw'"' 51 // ###
      local funf 1
      local ib3 = `ib' -2
      local r`rmin' `b`ib3'' // pretext
      local --rmin
      local ++rmax
      local r`rmax' `b`ib'' //posttext
      local --ib
      local --ib
      local ++rmax 
      local r`rmax' `s`is2'' //@ marker
      local s`is2' `s`is''
      local --is
      local b`ib' = 0 -`rmax' //E
   }
   else if `dd'==3 {    // construct result stack
*      treat monadic (ie !) separately
      if `t`s`is2'''==5 | `t`s`is2'''==9{ //negation or fn
         if  `b`ib''>0 {  //plain
            local ++rmax
            local r`rmax' `b`ib''
         }
*        E requires no action since in stack
      }
      else { //dyadic  
         local ib2 = `ib' -1
*         negative pointers are E markers
*         depending upon position vars are added to head or tail
         if  `b`ib2''>0 & `b`ib''>0 {  //plain
            local ++rmax
            local r`rmax' `b`ib2''
            local ++rmax
            local r`rmax' `b`ib''
         }
         else if `b`ib''>0 & `b`ib2''< 0  {  //just add ib
            local ++rmax
            local r`rmax' `b`ib''
         }
         else if `b`ib''<0 & `b`ib2''> 0  {  //add ib2 at head ##of top exp
*          ## positioning operand just-after top exp in stack
            local itkk= `rmin'+1
            if `rmin'<`rmax' {  //do I here need this ##
               local it = `rmax' +1
               local ikk 1
               while (`--it' > `rmin') {  //find length, as in chatter about stack above
                  if `t`r`it'''>0 & `t`r`it'''!=5 local ++ikk //dyadic ops
                  if `t`r`it'''==0 { //operand
                     local --ikk
                     if `ikk'==0 {
                        local ikk 9999 // only marking top exp
                        local itkk `it'
                     }
                  }
               }
            } 
            local --itkk
            if `chat2'>=5 di as err "REPORT consider `itkk' rather than `rmin' " //##
            if `itkk'!=`rmin' {
               if `chat2'>=5 di as err " REPORT moving"
               local jtkk=`itkk'-1
               forvalues iikk=`rmin'/`jtkk' {
                  local jjkk=`iikk'+1
                  local r`iikk' `r`jjkk''
               }
               local r`itkk' `b`ib2'' 
            }
            else local r`rmin' `b`ib2''
            local --rmin
         }
*         NOTE E E requires no action, since already in stack
         local --ib //one fewer param
      } 
*     *operator:
      local ++rmax
      local r`rmax' `s`is2''
      local s`is2' `s`is''
      local --is
*     *reference:
      local b`ib' = 0 -`rmax'
   }
   else if  `dd'==2  {  //scrap brackets
      local --is
      local --is
   }
   else if  `dd'==4  {  //startend
      if `ib'== 1 {  //deal with possible single param
         if `b`ib''>0 {
            local ++rmax
            local r`rmax' `"`b`ib''"'   
         }    //no action needed on stack pointer
      }
      else if `ib'>1 MIXED 1 "`vvers'" "`active'"
*       This condition IS an error,
*        and (I think) is triggered uniquely by arithmetic 
*            POST-operating on logical/relational expression
      continue, break
   }
   else if  `dd'==1  {  // no symbol action, so getnext thing
      local ++i  //no need to boundcheck ? since t8 traps
      if `t`i''==0 {   //char into char stack
        local ++ib
        local b`ib' `i'
      }
      else {  //symbol into symbol stack
         local ++is
         local s`is' `i'
      }
   }
   else ERR197 `"`raw'"' 5
* __________________________________
}  // while
* __________________________________
*
*      assembling RPN record even for plain expressions
      local nrpn 1 // which section - using nrpn rather than n since needed later
      local rpnPL 7 // print line length, to presrve pretty print
*       can't do it on length of assembled string since it carries unprinting smcl
      local rpns "" // also plain RPN for macro store
*      {c RT] if placed in rpns will di OK, but remains as {c RT] within rpns, so
      local it `rmin'  //since rmin points below end
      while (`++it'<= `rmax') {  //avoid evaluation =s, cause with syntax is longstring
         local arg `"`x`r`it'''"'
         local argn = length(`"`arg'"')
         local rpnPL = `rpnPL' + `argn' + 3 
         if `it'==(`rmin'+1) {
            local rpn`nrpn' `"{txt}{c RT}"'
            local rpnB`nrpn' "{col 7}{txt}{c LT}"
         }
         else {
            local rpn`nrpn' `"`rpn`nrpn'' {txt}{c |}"'
            local rpnB`nrpn' `"`rpnB`nrpn''{c -}{c BT}"'
            local rpns `"`rpns'`cedilla'"'
            if (`rpnPL' >= (`mline'+2))  & (`it'!=`rmax') { // allow last to overflow a bit
               local ++nrpn
               local rpn`nrpn' `"{txt}{c RT}"'
               local rpnB`nrpn' "{col 7}{txt}{c LT}"
               local rpnPL 7
            }
        }
         local rpns `"`rpns'`arg'"'
         if `t`r`it'''==0 local rpn`nrpn' `"`rpn`nrpn''{res} `arg'"'
           else local rpn`nrpn' `"`rpn`nrpn''{inp}{bf} `arg'{sf}"'
         local k = length(`" `arg'"')
         local rpnB`nrpn' `"`rpnB`nrpn''{hline `k'}"'
      }
      local rpn`nrpn' `"`rpn`nrpn''{txt} {c LT}{c -}"'
      local rpnB`nrpn' `"`rpnB`nrpn''{c -}{c BRC}"'

      local activet = trim(`"`active'"')
      local activet = subinstr(`"`activet'"'," ","",.) // `active' has embedded space=dots
      local rpns = subinstr(`"`rpns'"'," ","`dots'",.) // set rpns to match
*        visually clearer; added benefit easier parsing for vy RPN
      local returnRPN `returnRPN' [exp`W': `activet' »»  `rpns'  ««]
*
*
* keep track of precedence invocation for r(precedence)
   if `remindF' {
      local i 0
      if `remindTHIS' {
         local i 1
         local ++remindEXP
      }
      local precedence "`precedence' exp`W' `i' "
   }
*
* __________________________________
* 
* F   Compile RPN into nested functions cond(), into s1
* __________________________________
*
* Evaluate RPN
* (re)using S[is] as the working computational stack
*    (Note: this section began life as a stand-alone routine;
*           it could be rewritten simply to use pointers to r[]
*           but calculation astack is conceptually clearer, so leave as is.)
* to build up the nested cond() function
* through the use of nested macros
*
*   s[i] is stack
*   cs[i] flag whether indictor (with appropriate mvs) var or exp
*   ns[i]  no missing values (var or exp)
*   ss[i] ‘sourced’ variable; if so the emv
*   vs[i] if ss[i], the variable
*
forvalues i = 1 / `smax' {  // set start stack values
   local s`i' "null"    // emptying stack
   local cs`i' 0 //flag whether stack entry is now indicator
   local ns`i' 0 //flag whether stack entry is variable with no missintg-values
   local ss`i' 0 //flag whether stack entry is a 'sourced' variable (if so, the emv)
   local vs`i' 0 // if ss[i], it gives the implicated variable
}
* comment:
*    cs[i] set if cell is an indicator variable (with apt mmvs), or an invoked cond(...)
*          knowing cell is well-behaved allows some simplifications
*    ns[i] allows e.g. !p to be coded merely as !p (Stata operators OK if no mv)
*          (could encode cs[]and ns[] into one, but ensuing tests simpler like this)
*    ss[i] allows eg !p to be expressed as  cond(`vs1',0,1,`ss1') i.e. cond(p,0,1,.a) as against the 
*           standard extended formula cond(`s1',0.1.`s1') which expamds to
*           cond(cond(p,p,0,.a),0.1.cond(p,p,0,.a))
*
local i  0       // stack counter
local it `rmin'  //since rmin points below end
local rmis 0 //for pretty print literal mdc
local compactN 0 //reset counter for optimising
local s1_mF "ERROR" // missing->False form of s1 (only)
*   the mF form of s1, if coded directly, will be more compact than having
*   to add a step coding  cond(s1,1,0,0)
*   (note mF always reduced to 1,0,0 - no interest in actual value)
*   only used in functional (i.e. !`usevars') evaluation;
*   simplest code is "garner all" and "use last"
*
while (`++it'<= `rmax') {
   local y `"`x`r`it'''"'
   local m `t`r`it'''
   if `m'==5 { // negation
      if `i'<1 error 102
*
      if `ns1' { // no-missing in s1
         local s1_mF  !`s1'  // if s1 is p&q that will already be bracketed
         local s1 !`s1'  
         local everN 1 // flag for simplification report
      }
      else if `ss1' { // can simplify for source
         local s1_mF cond(`vs1',0,1) //pre-mod s1
         local s1 cond(`vs1',0,1,`ss1')  //ss1 entails emiss
      }
      else {
         local s1_mF cond(`s1',0,1) //pre-mod s1 -- missing returns 
         if `emiss'  local s1 cond(`s1',0,1,`s1')
           else local s1 cond(`s1',0,1,.)
      }
      local cs1 1 // flag as indicator
      local ss1 0 // flag as no longer simple source
*       note ns1 retains its value
   }
   else if `m'>0 {      // any dyadic operator
       local vacillate 1 //  reset by nonmiss actions to avoid swaps below
*
*      two COMPACT calls here just for report when chat>1
      if `chat2'>=5 {
         COMPACT `"`s1'"' `chat2' s1
         COMPACT `"`s2'"' `chat2' s2
      }
*      results of more complex calls to COMPACT below are (on current
*      definitions (v2.5.1) obvioulsy computable from results on s1, s2;
*      but have left as is, partly laziness, partly facilitate trial of alternate
*      definitions within COMPACT
*
      local setns1 0 // default, result contains missing
*
      local s1t `"`s1'"' //to feed s1_mF
      local sysmiss .  // other than source(r)
      if `esourceR' local sysmiss cond(int(2*runiform()),`s2' ,`s1')
*
      if `m'==9 { //function etc  ## inoperative
         ERR197 `"`raw'"' 91
         if `i--'<3 error 102
         if `chat2'>=5 di " {txt}Mixed portion becomes: {res}`s3'({inp}`s2'{res})`s1'{txt} "
         di as err " Mixed portion becomes: {res}`s3'({inp}`s2'{res})`s1'{txt} "
         local s1 `"`s3'(`s2')`s1'"'
         forvalues j = 2/`i' {     // extra pop stack
            local k = `j'+1
            local s`j' `"`s`k''"'
         }
         local --i
      }
*
      if `m'==3 {       // conjunction
         if `i--'<2 error 102
*
         if `ns1' & `ns2' { // both args nonmiss
            local s1 (`s2'&`s1')
            local s1_mF `s1'  // after computed s1 OK
            local setns1 1 // so that propagates
            local vacillate 0 //  to skip the comparison section
            local everN 1 // flag for simplification report ##########
         }
         else if `ns1'|`ns2' { // one arg nonmiss -- NOTE source handled also
            local p1 1
            if `ns2' local p1 2
            local p2 = 3 - `p1'
*
            if `cs`p2'' { // indicator works as-as
               local a `s`p2''
               local ++everIND // flag for actual invocation
            }
            else if `emiss' {
               if `ss`p2'' local a cond(`vs`p2'',1,0,`ss`p2'') // source simplification
               else local a cond(`s`p2'',1,0,`s`p2'')
            }
            else local a cond(`s`p2'',1,0,.)
            local s1_mF cond(`s`p1'',cond(`s`p2'',1,0,0),0)  // must precede plain s1 assign
            local s1 cond(`s`p1'',`a',0)
            local vacillate 0 //  to skip the comparison section
            local everN 1 // flag for simplification report ##########
         }
         else if `ss1'|`ss2' { // at least one source-var
            forvalues ii=1/2 {  // store appropriate
               if `ss`ii'' { // source-var
                  local SS`ii' `ss`ii'' // emv
                  local VS`ii' `vs`ii'' // var
               }
               else { // not source-var, so use as-is
                  local SS`ii' `"`s`ii''"'
                  local VS`ii' `"`s`ii''"'
               }
            }
            if `ss2' & !`ss1' { // if only one source-var, it's neatest in S1
               foreach ii in S V {
                  local x `"``ii'S1'"'
                  local `ii'S1 `"``ii'S2'"'
                  local `ii'S2 `"`x'"'
               }
            } // swapped so source-var is 1
            if `esourceR' local sysmiss cond(int(2*runiform()),`SS2' ,`SS1')
            if `ss1'&`ss2' { // we can hard-code the decision on both-sourced-missing since we know emvs
               if `"`VS1'"'==`"`VS2'"' local bothmiss  `"`SS1'"' // substantively unlikely
*                of course could have simplified unlikely p&p to p; above just to avoid an error
               else local bothmiss `"`sysmiss'"'
            }
            else { // we have to test
               local bothmiss cond(`SS1'==`SS2',`SS1',`sysmiss') // SS1 is the known one
            }   
            local s1_mF cond(`VS2',cond(`VS1',1,0,0),0,0)
            local s1 cond(`VS2',cond(`VS1',1,0,`SS1'),0,cond(`VS1',`SS2',0,`bothmiss'))
            local vacillate 0 //  to skip the comparison section
         }
         else { // handling operands both potentailly containing missing
*
            local z1 1 //start with s1 nd s2, then flip
            local z2 2
            forvalues zi = 1/2 {  //explore commutation
               local sxvalue `s`z1''  //option if known indicator vars
               local ++everIND // flag for actual invocation
               if `emiss' { // to track, as much as may be, "extended missing"
                  if  !`cs`z1'' {
                     local sxvalue cond(`s`z1'',1,0,`s`z1'') //not indicator, so force 1,0, emv
                     local --everIND
                  }
                  local s`z1'z  cond(`s`z2'',`sxvalue',0,cond(`s`z1'',`s`z2'',0,cond(`s2'==`s1',`s2',`sysmiss')))       
                  local s`z1'bz cond(`s`z2'',`sxvalue',0,cond(`s`z1'',`s`z2'',0,cond(`s2'==`s1',`s1',`sysmiss')))
*                 these differ only in which used to return missing if missing identical       
               }
               else {
                  if !`cs`z1'' {
                     local sxvalue cond(`s`z1'',1,0,.) //not indicator, so force 1,0, sysmiss
                     local --everIND
                  }
                  local s`z1'z cond(`s`z2'',`sxvalue',0,cond(`s`z1'',.,0))
*                  Note: elided fourth element in final cond() is intentional
               }
               local s`z1'_mFz cond(`s`z2'',cond(`s`z1'',1,0,0),0,0)  //missing_>False form, same for emiss or not
*                capture cummutative scores:
               COMPACT `"`s`z1'z'"' `chat2' z`z1'
               local n`z1' = r(conds)
               local d`z1' = r(depth)
               if `emiss' {
                  COMPACT `"`s`z1'bz'"' `chat2' "z`z1'b"
                  local n`z1'b = r(conds)
                  local d`z1'b = r(depth)
               }
*
               local zt `z1' //commute
               local z1 `z2'
               local z2 `zt'
            }  //end of explore commutation
         } // end of variaties of operands
      }
      else if `m'==2 {  // disjunction -- comments as for conjunction
         if `i--'<2 error 102
*
         if `ns1' & `ns2' { // both args nonmiss
            local s1 (`s2'|`s1')
            local s1_mF `s1'  // after computed s1 OK
            local setns1 1 // so that propagates
            local vacillate 0 //  to skip the comparison section
            local everN 1 // flag for simplification report ##########
         }
         else if `ns1'|`ns2' { // one arg nonmiss -- NOTE source handled also
            local p1 1
            if `ns2' local p1 2
            local p2 = 3 - `p1'
*
            if `cs`p2'' {
               local a `s`p2''
               local ++everIND // flag for actual invocation
            }
            else if `emiss' {
               if `ss`p2'' local a cond(`vs`p2'',1,0,`ss`p2'') // source simplification
               else local a cond(`s`p2'',1,0,`s`p2'')
            }
            else local a cond(`s`p2'',1,0,.)
            local s1_mF cond(`s`p1'',1,cond(`s`p2'',1,0,0))  // must precede plain s1 assign
            local s1 cond(`s`p1'',1,`a')
            local vacillate 0 //  to skip the comparison section
            local everN 1 // flag for simplification report 
         }
         else if `ss1'|`ss2' { // at least one source-var
            forvalues ii=1/2 {  // store appropriate
               if `ss`ii'' { // source-var
                  local SS`ii' `ss`ii'' // emv
                  local VS`ii' `vs`ii'' // var
               }
               else { // not source-var, so use as-is
                  local SS`ii' `"`s`ii''"'
                  local VS`ii' `"`s`ii''"'
               }
            }
            if `ss2' & !`ss1' { // if only one source-var, it's neatest in S1
               foreach ii in S V {
                  local x `"``ii'S1'"'
                  local `ii'S1 `"``ii'S2'"'
                  local `ii'S2 `"`x'"'
               }
            } // swapped so source-var is 1
            if `esourceR' local sysmiss cond(int(2*runiform()),`SS2' ,`SS1')
            if `ss1'&`ss2' { // we can hard-code the decision on both-sourced-missing since we know emvs
               if `"`VS1'"'==`"`VS2'"' local bothmiss  `"`SS1'"' // substantively unlikely
*                of course could have simplified unlikely p&p to p; above just to avoid an error
               else local bothmiss `"`sysmiss'"'
            }
            else { // we have to test
               local bothmiss cond(`SS1'==`SS2',`SS1',`sysmiss') // SS1 is the known one
            }   
            local s1_mF cond(`VS2',1,cond(`VS1',1,0,0),cond(`VS1',1,0,0))
            local s1 cond(`VS2',1,cond(`VS1',1,0,`SS1'),cond(`VS1',1,`SS2',`bothmiss'))
            local vacillate 0 //  to skip the comparison section
         }
         else { // handling operands both potentailly containing missing
*
         local z1 1 //start with s1 nd s2, then flip
         local z2 2
         forvalues zi = 1/2 {  //explore commutation
            local sxvalue `s`z1''
            local ++everIND // flag for actual invocation
            if `emiss' {
               if  !`cs`z'1' {
                  local sxvalue cond(`s`z1'',1,0,`s`z1'') // force 1,0,emv
                  local --everIND
               }
               local s`z1'z  cond(`s`z2'',1,`sxvalue',cond(`s`z1'',1,`s`z2'',cond(`s2'==`s1',`s2',`sysmiss')))       
               local s`z1'bz cond(`s`z2'',1,`sxvalue',cond(`s`z1'',1,`s`z2'',cond(`s2'==`s1',`s1',`sysmiss')))       
            }
            else {
               if !`cs`z1'' {
                  local sxvalue cond(`s`z1'',1,0,.) //not indicator, so force 1,0, sysmiss
                  local --everIND
               }
               local s`z1'z cond(`s`z2'',1,`sxvalue',cond(`s`z1'',1,.,.))
            }
            local s`z1'_mFz cond(`s`z2'',1,cond(`s`z1'',1,0,0),cond(`s`z1'',1,0,0))
*             capture scores
            COMPACT `"`s`z1'z'"' `chat2' z`z1'
            local n`z1' = r(conds)
            local d`z1' = r(depth)
            if `emiss' {
               COMPACT `"`s`z1'bz'"' `chat2' "z`z1'b"
               local n`z1'b = r(conds)
               local d`z1'b = r(depth)
            }
*
            local zt `z1'
            local z1 `z2'
            local z2 `zt'
         }  //end of explore commutation
         } // end of operands with missing
      }
*
      else if `m'==4 {  // relation
         if `i--'<2 error 102
*
         if `ns1' & `ns2' { // both args nonmiss
            local s1 `"(`s2'`y'`s1')"'      
            local s1_mF `"`s1'"'
            local setns1 1 // so that propagates
            local vacillate 0 //  to skip the comparison section
            local everN 1 // flag for simplification report 
         }
         else { // one or other has potentially missing
         local w0 0
*          first check for relations to explicit missing-values or NULL
         forvalues j = 1/2 {   // scan for mdc
            local w1 = substr(`"`s`j''"',1,1)
            local w2 = substr(`"`s`j''"',2,1)
            local w3 = length(`"`s`j''"')
            if (`"`w1'"'=="." & `w3'<=2 & indexnot(`"`w2'"',"`alphaLC'")==0) {
               if `isifexp' local warn_mv 1
               local w0 =3 - `j' //the nonexplicit one
               local w5 `"`s`j''"' //for report
               if "`w5'"=="." local w5 sysmiss
               continue, break
            }
*         scan for null string
            if (`"`w1'"'==`"""' & `w3'==2 & `"`w2'"'==`"""') {
               if `isifexp' local warn_mv 1
               local w0 1
               local w5 NULL  //for report
               continue, break
            }
         }
         if `w0' {    // explicit missing-data reference
*           leaving this section with literal-source usage for simplicity
            local j 0 // report flag
            local ++rmis
            local rmist `rmis' //aggregate flag
            if "`w5'"!="sysmiss" & "`w5'"!="NULL" & "`y'"=="==" { //handle p==.x slightly differently 
               local s1_mF `"(`s2'`y'`s1')"'
               local s1 cond(`s`w0''==.,.,`s2'`y'`s1')
               local j 1 // report flag
            }
            else {
*                this and above is only context in which realation can ends abuting relation unbracketed
*                expexp>r becomes   p==.>r, so return bracketed:
               local s1 `"(`s2'`y'`s1')"'
               local s1_mF `"`s1'"'
            }
*            store instances for later report
            local rmisA`rmis' `"`y'"'
            local rmisB`rmis' `w5'
            local rmisC`rmis' `j'
            if "`w5'"!="sysmiss" & "`w5'"!="NULL" & `esourceF'  { //worry about 'v R .x' in sourcemode
                local sourcewarnF 1
                local sourcewarnEMV `w5'
            }
         }
         else {  // code the varying s2 R s1 relationxx
*           first handle the one-nonmiss scenario
*            (note that one-nonmiss entails numeric)
            if `ns1'|`ns2' {  // one or other nonmiss; source handled
               local jj 2
               if `ns2' local jj 1
               local S2 `s`jj'' // operand with missing
               local SS2 `s`jj''
               if `ss`jj'' { // that one operand a sourced var
                  local S2 `vs`jj''
                  local SS2 `ss`jj''
                  if `jj'==1 local s1 `S2'
                    else local s2 `S2'
               }
              local s1_mF cond(`S2'<.,`s2'`y'`s1',0)  // has to be before s1
*                coding non-transparent; but s2Rs1 is assessed correct order
              if `emiss' local s1  cond(`S2'<.,`s2'`y'`s1',`SS2')
                 else local s1  cond(`S2'<.,`s2'`y'`s1',.)
              local vacillate 0 // the coding as is
              local everN 1 // flag for simplification report 
          } // end of one-nonmiss
         else if `ss1'|`ss2' { // at least one source-var -- so both numeric
            forvalues ii=1/2 {  // store appropriate
               if `ss`ii'' { // source-var
                  local SS`ii' `ss`ii'' // emv
                  local VS`ii' `vs`ii'' // var
               }
               else { // not source-var, so use as-is
                  local SS`ii' `"`s`ii''"'
                  local VS`ii' `"`s`ii''"'
               }
            }
            if `ss2' & !`ss1' { // if only one source-var, it's neatest in S1
               foreach ii in S V {
                  local x `"``ii'S1'"'
                  local `ii'S1 `"``ii'S2'"'
                  local `ii'S2 `"`x'"'
               }
            } // swapped so source-var is 1
            if `esourceR' local sysmiss cond(int(2*runiform()),`SS2' ,`SS1')
            if `ss1'&`ss2' { //  we can further simplify
               if `"`VS1'"'==`"`VS2'"' local final  `"`SS1'"' // substantively unlikely
*                of course could have simplified unlikely pRp  above just to avoid an error
               else local final cond(`VS1'<.,`SS2',`sysmiss')
            }
            else { // we have to test
               local final cond((`SS1'==`SS2')|`VS1'<.,`SS1',`sysmiss') // SS1 is the known one
            }   
            local s1_mF cond(`VS2'<.,cond(`VS1'<.,`s2'`y'`s1',0),0)
            local s1 cond(`VS2'<.,cond(`VS1'<.,`VS2'`y'`VS1',`SS1'),`final')
            local vacillate 0 //  to skip the comparison section
         }
         else { // two nonmiss (or string)
*              First, identify string operands, since missing-test has to be coded differently
*              (function mi() would test either, but, in relations-of-relations,
*               we get nested calls, which Stata disallows; and in extended mode
*               we would anyway have to test for strings for result return if indeterminate)
            local isstring 0
            local ink `in'  // etc, since call to syntax will scrub
            local ifk `"`if'"'
            local expk `"`exp'"'
            foreach xit in s1 s2 {  //## revised to handle spaces in stringso 
               local xit `"``xit''"'
*                 so instead deploy a test that is more general
                local 0 = "="+`"(`xit')"'+`"=="c""'  //make a string-equivalence
                if `chat2'>=5 di as err `" Report STRING CHECK testing `0' "'
				capture syntax =/exp  //see whether cell=="c" parses
                if _rc==0 {
                    if `chat2'>=5 di as err " REPORT that is a string"
                    local isstring 1
                    continue, break  //no need to check both arguments
                }   
            }    // end  foreach
            local in `ink'  // restore
            local if `"`ifk'"'
            local exp `"`expk'"'
*
            if `emiss' {
*                 to track, as much as may be, "extended missing codes"
               if `isstring' {
                  local s1 cond(`s2'!=""&`s1'!="",`s2'`y'`s1',`stringEMV')
                  local stringTRIP 1 // so that source report can list
               }
               else {  //the only assymetric-sized possible s1/s2 case
                     local s1z cond(`s2'<.,cond(`s1'<.,`s2'`y'`s1',`s1'),cond(`s2'==`s1'|`s1'<.,`s2',`sysmiss'))
                     COMPACT `"`s1z'"' `chat2' "z1(R)"
                     local n1 = r(conds)
                     local d1 = r(depth)
                     local s2z cond(`s1'<.,cond(`s2'<.,`s2'`y'`s1',`s2'),cond(`s2'==`s1'|`s2'<.,`s1',`sysmiss'))
*                      commuting s2 R s1 itself within 2nd cond  would be immaterial to complexity
                     COMPACT `"`s2z'"' `chat2' "z2(R)"
                     local n2 = r(conds)
                     local d2 = r(depth)
                  }
*                 Note: avoidance of mi() use is deliberate, to avoid later nesting.
            }
            else { //not emiss
               if `isstring' local s1 cond(`s2'!=""&`s1'!="",`s2'`y'`s1',.)
               else local s1 cond(`s2'<.&`s1'<.,`s2'`y'`s1',.)   
*                 note dont need brackets around y cause at this point s2,s1 well defined 
            }
         if `isstring' local s1_mF cond(`s2'!=""&`s1t'!="",`s2'`y'`s1t',0)
           else local s1_mF cond(`s2'<.&`s1t'<.,`s2'`y'`s1t',0)   //symmetrical, so no swap
         }
         }
         } // end of one or other missing ##
      }
*
*       for conjunction, disjunction, emiss-relation now consider alternate pXq sequeces:
       if `vacillate' & (`m'==2 | `m'==3 |(`m'==4 & !`w0' & `emiss' & !`isstring')) { 
          local s1 `s1z'
          if `m'!=4 local s1_mF `s1_mFz' //note: relation, s1_mF symmetrical
          if `compactF' { //consider switching only if enabled
             if `emiss' & `m'!=4 {
                local zt = min(`n1',`n1b',`n2', `n2b') // lowest cond count
                local list "1 1b 2 2b"
             }
             else {
                 local zt = min(`n1',`n2') // lowest cond count
                 local list "1 2"
            }
            local dm 500
            foreach z of local list { //find smallest depth of lowest cond
                if `n`z''==`zt' local dm = min(`dm',`d`z'')   
            }
            foreach z of local list { 
               if `n`z''==`zt' & `d`z''==`dm' { // cond dominates, given above
                   local s1 `s`z'z'
                   if `m'!=4 local s1_mF `s`z'_mFz' //matching mF for conjunction,disjunction
                   if "`z'"!="1"  { // report if switched
                      local ++compactN
                      if `chat2'>=5 {
                        if "`z'"=="1b" di "# Swapping final argument"
                         else di "# Commuting to score `zt'"
                      }
                   }
                   continue, break
                }
             }
          }
       } //decided
*      OK:
      forvalues j = 2/`i' {     // pop stack
         local k = `j'+1
         local s`j' `"`s`k''"'
         local cs`j' "`cs`k''"
         local ns`j' "`ns`k''"
         local ss`j' "`ss`k''"
         local vs`j' "`vs`k''"
      }
      local cs1 1 // flag type for evaluated exp
      local ss1 0 // not a source var
      local ns1 `setns1'  // depends on what done, default is 0
   }
   else{                // arguments
      if `i++'>=`smax' error 103
*
      forvalues j = `i'(-1)2 {  //pushdown the stack
         local k = `j'-1
         local s`j' `"`s`k''"'
         local cs`j' "`cs`k''"
         local ns`j' "`ns`k''"
         local ss`j' "`ss`k''"
         local vs`j' "`vs`k''"
      }
      local cs1 0 //default values
      local ns1 0 //default values
      local ss1 0 //default values
      local vs1 0 //default values
*
      local s1 `"`y'"' // store arg
      local s1_mF cond(`s1',1,0,0) // mF disattends to emv 
*     
      if `isifexp'  { //now just reportage of refers #### modify to handle any when
         capture confirm  variable `s1', ex
         if _rc==0 { // is a variable 
            if "`var'"=="`s1'" local resultvar 1
            if `resultvar' & (`ifnotF' | `elseF') local refers 1
         }
      }
*
*     if a numeric variable, 
*     - check whether indicator var,and record
*       - if appropriate emv, can simplify subsequent cond calls
*       - with any emv, if `plain', affects how used
*     - if `source', insert appropriate emv
      local cs1 0 //default assumption: not binary
      local onezero 0 // cs[n] looks at mv match, this just 1,0 match
      capture confirm numeric variable `s1', ex
*
      if _rc==0 { // arg is a numeric variable, so:
* has it been met  (only matters for numeric vars, since only for them do we do misstable/assert
*                   to simplify exps, but themselves are expensive)
         local met 0
         forvalues v = 1/`metN' {
            if "`s1'"=="`metV`v''" {  // characteristics stored = ones ascertained
               local met `v'
               local emvX `metVemv`v''
               local mvX `metVmv`v''
               local assX `metVass`v''
               continue, break
            }
         }
         if !`met' { // ascertain characteristics   
            local ++metN     
            capture misstable sum `s1' `in'
            local emvX =r(N_gt_dot)
            if "`emvX'"=="." local emvX 0
            local mvX =r(N_eq_dot)
            if "`mvX'"=="." local mvX 0
            local assX 0
            capture assert (`s1'==0|`s1'==1|`s1'>=.) `in', f //indicator?
            if _rc==0 local assX 1
            local  metV`metN'  `s1'
            local  metVemv`metN'  `emvX'
            local  metVmv`metN'   `mvX'
            local  metVass`metN'  `assX'
         }

         local ns1 0 // ##
         if `metmissF' local ns1 = !(`emvX'+`mvX')  // to determine whether nomiss is attended to
         local cs1 0
         if `assX' { // ie 0,1,any mv
            local onezero 1 //indicator, any mv pattern
            if `emiss' | `isifexp' | `iswhen'  local cs1 1 // extended ok if in extended mode, or within conditions (which only attend in e 
            else if !`emvX' local cs1 1  //binary with sysmiss ok in non-ext mode
*                 here allowing more relaxed emv would not give errors, but would give puzzlingly 
*                 erratic passthru of emv to result
*            if `cs1' local everIND 1 -- we track actual use insteead ####
         } // end indicator test
*
         if `esourceF' { // if source, set notional e-mvs by variable
*           this code predates the metV faclity to track characteristics of all numeric vars
*           it could be rewritten to use its lists, but source works as is, so left for now
            local isv : list posof "`s1'" in sourceVAR
            local isnv : list posof "`s1'" in sourceNVAR
            local sourceD 0 // default no missing
            if `isv'==0 & `isnv'==0 {  //unmet var for source
*              capture assert(`s1'<.) `in', f // does it contain missing?
*              if _rc==0 { // no missing
               if `ns1' { // no missing
                  local sourceNVAR `sourceNVAR' `s1' // keep track, save recalc
                  local ++isNVAR
               }
               else { // new, missing values                 
                  local jsv = "."+char(`sourceCHAR')
                  if "`stringEMV'"=="`jsv'" {  //avoid conflicts with string-missing
                     local ++sourceCHAR
                     local jsv = "."+char(`sourceCHAR')
                  }
                  if `sourceCHAR'>122 { // unlikely unless base high  -- but e-mv exhausted
                     if `sourceREF'>97 {
                        local i = char(`sourceREF')
                        di as txt _n "{ul:suggestion}: for option {bf}source{sf}," ///
                          " {help validly##sourcev:use an alphabetically 'earlier' base;}" ///
                         _n(2) "{err}given use of {bf}.`i'{sf} as base, " _c
                     }
                     else di as err _n "for option {bf}source{sf}, " _c
                     error 103 
                  }
                  local sourceVAR `sourceVAR' `s1'
                  local sourceXM = "`sourceXM'" + " `jsv'"
                  local ++sourceCHAR
                  local sourceD 1  // flag actuala sourced
               }
            }
            else if `isv'!=0 { // previously met
               local jsv : word `isv' of `sourceXM' 
               local sourceD 1 // flag actual sourced
            }
*
*             assign if ppropriate 
            if `chat2'>=5 di as err " so we deploy `jsv' for `s1' "
*            for esource, the si_mF coding below becomes needlessly complex [it should be cond(`s1',1,0,0) 
*            before next step] but immaterial because never used
            if `sourceD' { // var has mvs
               local ss1 `jsv' // flag for is-sourced-var
               local vs1 `s1'  // sourced-var (note that s1 will effectively contain cond(`vs1',`vs1',0,`ss1') or somesuch)
               if `onezero' | (`plain' & `isifexp' & `usevars') {
                  local s1 cond(`s1',1,0,`jsv') // marginally more compact for indicator, ensure plain expC==1 works if needed
                  local onezero 1
               }
               else local s1 cond(`s1',`s1',0,`jsv') //so as not to flatten non-indicators
            }
         } // end esourceF
*
     }  // end of arg-is-numeric
      else if `emiss' { // non numeric; might it be 'chunk' (e.q  p+q   sqrt(p) ) -- if it matters for e-mv
         capture confirm string variable `s1', ex
         if _rc!=0 { // not string, so is potentially `chunk'
            local j = length(`"`s1'"')
            local c = substr(`"`s1'"',1,1) //## check range
            if `"`c'"'!="." | `j'>2 {  // to screen out .a etc -- 
               local plainEVER 1
               local plainTXT `"`s1'"'  // just one exemplar
            }
         }
      }
      if `chat2'>=5 di as err "REPORT s1#`s1' cs1#`cs1' step#`step' plain#`plain' usevars#`usevars'"
*
      if `isifexp' & `plain' & `usevars' & !`onezero'  { //ensure that tests for zvarC==1 work
*        When evaluating simply "if fnC" we rely on any-number-T, but when using vars
*        need T=1;  whereas expW uses merely fnW_mF
 * ##           local plain 0  //treat not as simple plain
             if `emiss' local s1 cond(`s1',1,0,`s1') 
              else local s1 cond(`s1',1,0,.) 
      }
 *
   } // end is-arg
 } 
   if `i'!=1 ERR197 `"`raw'"' 6
*
   local `what'fn `"`s1'"'
   local `what'fn_mF `"`s1_mF'"'
*
* _______________________________________________________
*
 local markE  `" {hline 5}{c RT} "'
if `plain' & `chat'  {
*
   local plainV 0
*   local plainB = `onezero' & (`iswhen' | (`isifexp' & `usevars'))
*   local plainB = `onezero' &  (`isifexp' & `usevars') // zvarC only place it matters
   local plainB = `onezero' &  ((`isifexp' & `usevars')|`esourceF')  // zvarC only place it matters xcpt if simplifies when sourcevar
   capture confirm numeric variable ``what'', ex
   if _rc==0 local plainV  1 // plain, numeric variable
   local plainSV = `esourceF' & `plainV'  & `sourceD' // plain, Source, Numeric variable
* ##   if `plainSV'!=`sourceD' di as err "HERE HERE HERE HERE"
   local ptxt0  di as txt `"`markE'we\`ptxt4' place unmodified {c RT} {inp}``what'' {txt}{c LT} into local macro {res}{c 'g}fn`W''{txt}"' 
   local ptxt5  di "`markE'{text}giving, in local macro{res} {c 'g}fn`W''{txt}, the valid function:" _n ///
                    "`markD'(coded to preserve " _c 
   local ptxt1 "a single"
   local ptxt2 ""
   local ptxt3 ""
   local ptxt4 ""
* *    if `plainB' & !`esourceF' {
   if `plainB'  {   // ##
      local ptxt1 "an indicator"
      local i ""
      if `inF' local i " there"
      local ptxt2 "`in' (coded 1/0`i')"
      if `isifexp'|`iswhen' local ptxt3 ", for tests,"
      local ptxt4 " can"
   }
   di as txt  _n " {inp}exp`W'{txt}{col 7}{c |} " _c
   if `plainV' {
     if `esourceF' & !`sourceD' di "is a variable with no missing values`in', so, despite {bf}source{sf},"
     else di "is `ptxt1' variable`ptxt2', so`ptxt3'" 
   }
   else di as txt  "contains no logical/relational operators, so" 
*
   if `isexp'|`isifnot'|`iselse'  { // non-conditions
      if `plainSV'  { // source emvs
         `ptxt5'
         di "source-tagged-missing)"
          TELL_COND  `"``what'fn'"' 0
      }
      else { // not plainSV
        `ptxt0'
         if `possibleF' { // an assert idiosyncracy
 *            local expU `"`expfn'"'
 *            local exp1q ""
              di "{space 6}{text}{c |} {err}Note: {text}since {inp}possible{txt} has been specified,  " _n ///
             "{space 6}{text}{c |}{space 7}only cases where {it}exp{sf} is {res}false{txt} " ///
             "are deemed {res}contradictions{txt}" 
             ULINE2
         } // end possible
         else if `assert' { //plain assert
*            local expU `"`expfn_mF'"'
*            local exp1q "_mF"
               TELL_MF `""""'  2
               TELL_COND `"`expfn_mF'"' 0
         }
         else { // other non-cond
            if (`esourceF'|`extendedF') & !`plainV'  di "`markD'(any extended-missing values likely smoothed to sysmiss)"
            ULINE2
         } // end types of exp
      } // end plainSV switch
   }
   else { //  conditions
      if `isifexp' & `emissC' & `plainV' & (!`plainB'|`esourceF')  { // need track e-mv var   last ##
         `ptxt5'
          if `esourceF'  di "source-tagged-missing)"
            else di "extended-missing values)"
          TELL_COND  `"``what'fn'"' 0
      }
      else if `plainB' | !`usevars' | `iswhen' {
         `ptxt0'
         if `usevars' & !`iswhen'  ULINE2
         else {
            if `wide' TELL_WS `chat'  //i.e. for functional wide only
            else { //not wide
               TELL_MF `W' 1
               TELL_COND `"``what'fn_mF'"' 0
            }
         }
      }
      else {
         di "`markE'{text}givingY, in local macro{res} {c 'g}fn`stepf''{txt}, the valid function:" _n ///
            `"`markD'(coded to constrain 'True' to return '1')"'
               TELL_COND `"``what'fn'"' 0
     }
   }  // end types
 } // end plain
* the conds can be in generic, with the U assignments also
*
if !`plain' {   // ##
*
* now report on this expression
*     report headers for expressions
   local plainSN  0
   if `plain' & `esourceF' {
       capture confirm numeric variable ``what'', ex
       if _rc==0 local plainSN  1 // plain, Source, Numeric variable
   }
      if `plain' & (!`esourceF'|!`plainSN') & `chat'  TELL_NLR `"``what''"' 0 `W'
      else {
         if `chat' {
            if `plainSN' {
               TELL_NLR `"``what''"' 1 `W'
            }
         else {
            TELL_RPN  `W'
            forvalues j=1/`nrpn' { // `nrpn' is sections from preceeding
               if `j'==1 di " {hline 5}" _c
                 else di "{space 5}>" _c
               di `"`rpn`j''"'
               di `"`rpnB`j''"'
            }
         }
       }
     }
*
   if !(`plain' & (!`esourceF'|!`plainSN') & `chat')  {
      local i 1
      if `remind1' {  // &| precedence
         local j = `remind1'+1
         if `chat' TELL_PREC  `remind2' `chat' 19 `"`markD'"' `j' 
         local i 0  //flag header `chat' 19 `"`markD'"' `j'printed
      }
      if `remind2' & `chat' TELL_PREC 0 `chat' 19 `"`markD'"' `i' `"`mark2'"' `"`remind2a'"' `"`remind2b'"' 
*
      if `chat' {
         forvalues ii=1/`rmis' { // report treatment of explicit missings if any
            local ww ""
            if `ii'>1 local ww "further, "
            di as txt `"`markD'(`ww'relation '{inp}`rmisA`ii''{txt}' referencing '{res}`rmisB`ii''{txt}' will be treated literally"' _c
            if `rmisC`ii'' di as txt ";" _n "`markD' but, within that, sysmiss will {help validly##emvexp:still yield sysmiss})"
            else di ")"
         }
         di _col(7) "{c |} " _c
         TELL_MA `"`W'"' `emiss' `compactN' `esourceF' `esourceR' `everN' `everIND'
         local tail 0
         if (`isifexp' & !(`wide' | `usevars')) | (`isexp' & `assert') | (`global' & `wide') | `iswhen' ///
           local tail 1
         TELL_COND `"``what'fn'"' `tail'
      }
   }
*
if `isexp' & `assert' { // choose appropriate form of expfn; chat
   if `possibleF' {
      local expU `"`expfn'"'
      local exp1q ""
      if `chat'  di "{space 6}{text}{c |} {err}Note: {text}since {inp}possible{txt} has been specified,  " _n ///
         "{space 6}{text}{c |}{space 7}only cases where {it}exp{sf} is {res}false{txt} " ///
         "are deemed {res}contradictions{txt}" _n "{space 6}{c BLC}{hline 71}"
   }
   else {
      local expU `"`expfn_mF'"'
      local exp1q "_mF"
      if `chat' {
         TELL_MF `""""'  2
         TELL_COND `"`expU'"' 0
      }
   }
}
*
   if `iswhen' & `chat' {
      TELL_MF W 1
      TELL_COND `"`whenfn_mF'"' 0
   }
*
   if `isifexp'  {  // decide, and report, on version of expC
      if `wide' | `usevars' {
         local exp2q ""
         local ifexpU `"`ifexpfn'"'
         if !`usevars' TELL_WS `chat'  //i.e. for functional wide only
      }
      else {  //use the m->F version of s1 we have been repeatedly making
         local exp2q "_mF"
         local ifexpU `"`ifexpfn_mF'"'
         if `chat' {
            TELL_MF `W' 1
            TELL_COND `"`ifexpfn_mF'"' 0
         }
      }
   }
*
} // end if !plain ##
*
*     report where is choice of action for expressions
*
if `isexp' & `assert' { // choose appropriate form of expfn; chat
   if `possibleF' {
      local expU `"`expfn'"'
      local exp1q ""
   }
   else {
      local expU `"`expfn_mF'"'
      local exp1q "_mF"
   }
}
   if `isifexp'  {  // decide, and report, on version of expC
      if `wide' | `usevars' {
         local exp2q ""
         local ifexpU `"`ifexpfn'"'
      }
      else {  //use the m->F version of s1 we have been repeatedly making
         local exp2q "_mF"
         local ifexpU `"`ifexpfn_mF'"'
      }
   }
*
* reset flag for particular expression
local remindTHIS 0
* and reset the counters in chat mode
if `chat' {
   local remind1 0  // flag to count where &| precedence upsets LR sequence
   local remind2 0 // dito R logical 
   local remind2a ""
   local remind2b ""
}
} // ]] end of foreach action 
* ________________________________________________________________________________________
* ________________________________________________________________________________________
* ________________________________________________________________________________________
* Note: editor does not see this as the matching closing bracket
* but a. logic says it is
* and b. if program is ended here and bracket added/removed the interpreter
*        reports an error
* so I think the attributionis correct
*
* Task is now executing and reporting.
* cond coded xxxx is in xxxxfn and xxxxfn_mF 
* (the _mF form redundant for some xxxx)
*
* __________________________________
*
* G Execute compiled function(s) or make macro
* __________________________________
*
* reportd precedences in nonchat
if !`chat' {
     local k = `mark3'+10
     if `remind1' {  // &| precedence
         local j = `remind1'+1
         TELL_PREC `remind2'  `chat' `k' `"`mark'"' `j' `"`mark2'"'
         local i 0  //flag header `chat' 19 `"`markD'"' `j'printed
      }
      if `remind2'  TELL_PREC 0 `chat' `k' `"`mark'"' `i' `"`mark2'"' `"`remind2a'"' `"`remind2b'"'
      if `remindEXP' {
         `marku' // so that closing line happens
         local j = word("`numer'",`remindEXP')
         if `remindEXP'>1 di "`mark2'{col `k'}(this reminder covers `j' expressions)" 
          else if `ifexpF'|`whenF' di "`mark2'{col `k'}(only one expression affected)"
      }
}
*
if `global' { // global (subsumes wrap) takes precedence
*  *  rely on Stata zapping missing->true in widely, else force missing to false in conditional
   if !`wide' & (`globalIF'|`wrap')  local s1 `"`s1_mF'"'
*   global `var' `s1'
   if `chat' {
     di as txt _n "{space 6}{c TLC}{hline 70}{c TRC}"
     if `globalIF'|`wrap' {
         di "{txt}{space 6}{c |} The conditional:{col 78}{c |}" _n "{space 6}{c |}{space 5}{res}if {c 'g}fn" _c
         if !`wide' di "_mF" _c
         di  "{res}'{txt}{col 78}{c |}" _c
	  }
	  else di as txt  "`markD'That function (coding for {bf}T, F{sf} and {ul:missing}){col 78}{c |}" _c
	  if `wrap' {
          di _n `"{space 6}{c |}{txt} is placed in macro {res}{c 'g}ifcond'{txt}"' _c
          if `everN' di "{col 78}{c |}"
          else di ", and also returned in  {help validly##saved:{bf}r(ifcond){sf}}{col 78}{c |}"
      }
      else {
         di _n "{txt}`markD'is returned in the global macro {res}{c S|}`var'{txt}{col 78}{c |}"
         if `globalIF' {
		    di "{txt}`markD'to be used, with a command, by typing: {inp}.{it}command{sf} {c S|}`var'{txt}{col 78}{c |}"
            if !`wide'  TELL_NV `"`markD'"'
		 }
		 else {
		    di "`markD'to be used as required{col 78}{c |}" 
		    TELL_NC "`var'" `"`exp'"' `"`markD'   "'
         }
	  }
   }
if !`wrap' { // i.e. global
   if `everN' {
      if `chat' di "`markD'" _c
        else di "`mark'" _c
      di "{err}{it}note{sf}:{txt}" _c
      di " coded assuming that{inp}" _c
      local j 0
      forvalues i= 1/`metN' {
          if !(`metVmv`i'' + `metVemv`i'') {
             local jj ""
             if `j' local jj ","
             di "`jj' `metV`i''" _c
             local ++j
          }
      }
      if `chat' di _n "{txt}`markD'" _c
        else di _n "{txt}`mark'" _c
      di "{space 6}shall {help validly##globwarn:continue to have {ul:no} missing} values" _c
      if `chat' di "{col 78}{c |}"
        else di
   }


     if `chat' di as txt "{space 6}{c BLC}{hline 70}{c BRC}"
     if `globalIF' global `var'  `" if  `s1'"'
       else if !`wrap' global `var' `s1'
     if !`chat' ULINE `mline' `mark3'
     return local RPN `returnRPN' 
     exit // global done
   }
   if `wrap' {
      local condition `" if `s1'"'
      if `chat' di as txt "{space 6}{c BLC}{hline 70}{c BRC}"
*       next 3 lines  kludge to get length
      local ii = subinstr(`"`zero'"',`"if `ifexp'"',`"xifcondx "',1)  
      local n=  length(`" Executing  .`by'`ii'"')
      if !`chat' ULINE `mline' `mark3'
	  di  _n `" {txt}Executing{inp}{space 2}.`by'"'subinstr(`"`zero'"',`"if `ifexp'"',`"{c 'g}ifcond' "',1) "{txt} {c |}" ///
         _n  " {hline `n'}{c BRC}"   
      local zero = subinstr(`"`zero'"',`"if `ifexp'"',`"\`condition' "',1)  //all spaces single by now
*        note `condition' must be entered "suppressed" in substitution, else it becomes too long a string
      if `chat2' di as err _n `" EXECUTING: `by'`zero'"' _n
      return local RPN `returnRPN' // the RPN condition
      if `remindF' return local precedence `precedence'
      local i WITHHELD:  nonmiss-specific code
      if `everN' return local ifcond `i'
      else return local ifcond `condition'
      `by'`zero'
*  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      return add  // to preserve any r() returns from wrapped command
      return local RPN `returnRPN' // repetition so that return even if wrapped command fails
      if `everN' return local ifcond `i'
      else return local ifcond `condition'
      if `remindF' return local precedence `precedence'
*
      exit
   }
} // ]]end global
else  {  // ##
*
if `emissC' &`chat' ///
    di   _n " {txt}Since we are generating a fresh variable, {inp}`var'{txt}, we can flag " _n  ///
    "    when {bf}`var'{sf} {help validly##extended4:becomes undefined {ul:because}} "  ///
         "{bf}{c 'g}fnC'{sf} is a specific {ul:extended}-missing value; " _n ///
    "    by setting the result to that extended-missing code." 
*
* test size and warn? 
   TESTS X  =`expfn'
   if `wide' TESTS C =`ifexpfn'
     else TESTS C_mF =`ifexpfn_mF'
   if `ifnotF' TESTS N =`ifnotfn'
   if `elseF'  TESTS E =`elsefn'
*
*     make a copy of our target variable, to allow summary reporting
   if `repF' {
      tempvar prevar
      quietly generate `prevar' = `var'
      quietly compress `prevar'
   }
   local qt "quietly "
   if `chat' local qt ""
*
   if `chat' {  //## not only usevars
      local i ""
      if `impute' { // expand
          if `genF' local i " gen"
          else local i " {err}replace{inp}"
      }
      else { // turn rep into replace
         local j = substr(`"`raw'"',1,4)
         if "`j'"=="rep " local raw = subinstr(`"`raw'"',"rep ","replace ",1)
      }
      di _n "{c TLC}{hline 76}{c TRC}" _n "{c |} evaluating:" _n ///
      `"{c |} {inp}.`by'validly`i' `raw'{txt}"'
   }
*
*
   if `usevars' {  //  ## check whether want to keep refers for chat
      if `chat' di as txt "{c |}"
      if `chat' di "`col23A'{c TLC}{hline 3}" _n  ///
        "{c |}{col 8}{txt}temp workspace {c RT} " _c
      local secondtemp 0
      if `ifexpF' {
         tempvar zvarC
         if `chat2' di as err _n `" EXECUTING: `by'gen  `zvarC'=`ifexpfn' `in' "' _n
         quietly `by'gen byte `zvarC'=`ifexpfn' `in' //we need to fix the condition for repeat replace calls
         if `chat' {
            di "{inp}.`by'gen byte zvarC = {c 'g}fnC'`intext'"
            local secondtemp 1
         }
      }
      if `whenF' { // when() stores for calls
         tempvar zvarW
         quietly `by'gen byte `zvarW'=`whenfn_mF' `in' //
         quietly sum `zvarW' `in'
         if r(min)==r(max) local whenCONS = r(min)+1  //tell user if when is a constant
         if `chat2' di as err _n `" EXECUTING: `by'gen `zvarW'=`whenfn_mF' `in' "' _n
         if `chat' {
             if `secondtemp' di  "`col23'" _c //cant use LIN since two spaces
             di "{inp}.`by'gen byte zvarW = {c 'g}fnW_mF'`intext'"
         }
         if `ifexpF' {
            local whenTXT " & zvarW"
            local whenVAR `" & `zvarW'"'
         }
         else { // 'when' without 'if'
            local whenTXT  "zvarW"
            local whenVAR `"`zvarW'"'
         }
      }
      if `emissC' { // store fn for extend-missing in if
         tempvar zvar
         if `chat2' di as err _n `" EXECUTING: `by'`zvar'=`expfn' `in'  "' _n
         quietly `by'gen  `zvar'=`expfn' `in' 
*          NOTE we could save CPU time by inserting `whenVAR' here, but at the risk
*          of tilting the evaluation into the "too long" category; since expcon is 
*          possible locus of too-long have opted to squander CPU in return for
*          more-robust
         if `chat' di  "`col23'{inp}.`by'gen zvar{space 2}= {c 'g}fn'`intext'"
      }
      if `chat' & `refers' COMFORT `var'
*
      if !`ifexpF' local wideR ""
        else if `wide' local wideR "!=0"
        else local wideR "==1"
   } 
*
   if `chat' {
      if `usevars' {
         LIN 3
         di "{txt}{c LT}{hline 4} main expression {c RT} {inp}." _c
      }
      else   di  "{txt}{c |}" _n "`col23A'{c TLC}{hline 3}" _n ///
         "{txt}{c LT}{hline 4} using the above {c RT} {inp}." _c
      local i " "
      local j ""
      if `repF' {
         local i "{space 2}"
         if `impute' local j "{err}{bf}"
      }
      if `usevars' {
         if `ifexpF' local k zvarC
           else local k "" // usevars no-if always has active when
         if `emissC' di "`action'`type'`i'`var'{sf}`vlab'{inp}`equals' zvar{space 2}if `k'`wideR'`whenTXT'`intext'`nop'" 
            else di "`by'`j'`action'{sf}{inp}`type'`i'`var'`vlab'{inp}`equals' {c 'g}fn'{space 2}if `k'`wideR'`whenTXT'`intext'`nop'" 
         if `wide' {
            LIN 2 _c
            di "with option {bf}widely{sf},  using '{inp}!=0{txt}' instead of '{bf}==1{sf}'" 
         }
      }
      else { // functional form
         if `ifexpF' local k `" if {c 'g}fnC`exp2q''"'
           else local k "" 
         di "`by'`j'`action'{sf}{inp}`type'`i'`var'`vlab'{inp}`equals' {c 'g}fn`exp1q''`k'`intext'`nop'" 
         if `assert' di "{txt}{c BLC}{hline 21}{c BT}{hline 54}{c BRC}"
      }
   }
*
   if `assert' {   //just pretifying the output from assert
       local iftxt ""
       if `ifexpF' local ifTXT `" if `ifexpU' "'
       capture    `by' assert `expU' `ifTXT' `in'`assertOPN'
       if _rc!=0 & `chat' di  _n _col(11)"{txt}Note: RPN parsing returned in {res}r(RPN){txt}"
	   di as txt  _n " Finding, {ul:on that interpretation}, "  _c
       if _rc==0 di "no contradictions."
       else if "`fast'"!="" di "that {err}the " _c
*
*
    if `chat2' di as err _n `" EXECUTING: `by' assert `expU' `ifTXT' `in'`assertOPN'"' _n
    `qta' `by' assert `expU' `ifTXT' `in'`assertOPN'
*    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     exit
   }
*
*
   if `usevars' {
      local tidy = !`asstring'&`genF' // to tidy main generate reporting, only works for numeric
      if `chat' local vert "{txt}{c |}"
*
      if `emissC' {
        if `chat2' di as err _n `" EXECUTING  `action'`type' `var'`vlab' `equals' `zvar' if `zvarC'`wideR'`whenVAR' `in'`nop'"' _n
        if `chat' LIN 2 _c
        local qt2 ""
        if `genF'|(`repF' & !`chat')  local qt2 "quietly "
        `qt2'`action'`type' `var'`vlab' `equals' `zvar' if `zvarC'`wideR'`whenVAR' `in'`nop' //  'by' irrelevant since here vars
*         since gen itself sometimes does sometimes does not generate output, we make our own
        if `genF' & `chat'  REPORT `var' `asstring' `chat' `repF' 0 1 `prevar'
*        but suppressing here the 'extended' output for consistency with following 'replaces'
        if `chat' di  "{txt}{c LT} noting e-m in {c 'g}fnC' {c RT} {input}.replace  `var'`equals' zvarC " ///
             "if zvarC>. & (zvar<. | zvar==zvarC)`whenTXT'`intext'`nop'" ///
             _n "`col23' " _c  
        if `chat2' di as err _n `" EXECUTING replace `var' `equals' `zvarC' if (`zvarC'>.) & (`zvar'<. | `zvar'==`zvarC')`whenVAR'`in'`nop'"' _n
        `qt' replace `var' `equals' `zvarC' if (`zvarC'>.) & (`zvar'<. | `zvar'==`zvarC')`whenVAR'`in'`nop'
        if `chat' di `"`col23' (these would be "changes from {it}sysmiss{sf} to {ul:extended}-missing")"' 
        if `sourceR' {
*           if `chat' di _col(10) "{txt}In addition to the {help validly##sourcecode:coded random tie-breaking}, we need, for that" _n ///
*           _col(10) "e-mv replace{space 2}{c RT}{inp} .replace `var' = cond(int(2*runiform()),zvar,zvarC) if (zvar>. & zvarC>.)" ///
*            " & (zvar!=zvarC)`whenTXT'`in'`nop'{txt}" _n _col(10) _c
         if `chat' di  "{txt}{c LT} random tie-breaking {c RT} {input}.replace `var' = cond(int(2*runiform()),zvar,zvarC){space 2}///" ///
           _n "{txt}{c |} for e-mv in {c 'g}fnC'{space 3}{c |}{space 13}{inp} if (zvar>. & zvarC>.) & (zvar!=zvarC)`whenTXT'`intext'`nop'{txt}" ///
             _n "`col23' " _c  
          if `chat2' di as err _n `" EXECUTING `qt' replace `var' = cond(int(2*runiform()),`zvar',`zvarC') if (`zvar'>.&`zvarC'>.) & (`zvar'!=`zvarC')`whenVAR'`in'`nop'"' _n
           `qt' replace `var' = cond(int(2*runiform()),`zvar',`zvarC') if (`zvar'>.&`zvarC'>.) & (`zvar'!=`zvarC')`whenVAR'`in'`nop'  
        if `chat' di `"`col23' (these would be "changes from {it}sysmiss{sf} to {ul:extended}-missing")"' 
        }
      }
      else {  // not emissC
        if `chat2' di as err _n `" EXECUTING `by'`action'`type' `var'`vlab'`equals' `expfn' if `zvarC'`wideR'`whenVAR' `in'`nop' "' _n
        if `chat' di as txt "`col23' " _c 
        local qt2 ""
        if `genF'|(`repF' & !`chat')  local qt2 "quietly "
        `qt2'`by'`action'`type' `var'`vlab'`equals' `expfn' if `zvarC'`wideR'`whenVAR' `in'`nop' 
        if `genF' & `chat'  REPORT `var' `asstring' `chat' `repF' 0 1 `prevar'
      }
   }
   else {  // not usevars computation,  explicit function call
      if `repF' {
         tempvar prevar
         quietly generate `prevar' = `var'
      }
* ## size checks?
      if `chat2' di as err _n`" EXECUTING `by'`action'`type' `var'`vlab'`equals' `expfn'`ifTXT' `ifexpU'`in'`assertOPN'`nop'"' _n
      quietly `by'`action'`type' `var'`vlab'`equals' `expfn'`ifTXT' `ifexpU' `in'`assertOPN'`nop'
*     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
   }
*
    if `ifnotF' {
     local i 0
      if `chat' {
        di "{txt}{c LT}{hline 1} implementing {bf}{ul:ifnot}{sf} {c RT} {input}.`by'replace  `var'`equals' {c 'g}fnN' if " ///
             "zvarC==0`whenTXT'`intext'`nop'{txt}" _n  "`col23' " _c 
      }
      if `chat2' di as err _n `" EXECUTING:  `by'replace `var' `equals' `ifnotfn' if `zvarC'==0`whenVAR'`in'`nop'"' _n
      `qt'`by'replace `var' `equals' `ifnotfn' if `zvarC'==0`whenVAR'`in'`nop'
 *    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  }
    if `elseF' {
      local elseT ">=."
      if `elseALL' local elseT "!=1"  //needed both in chatty and non chatty modes
      if `chat' {
        di "{txt}{ c LT}{hline 2} implementing {bf}{ul:else}{sf} {c RT} {input}.`by'replace  `var'`equals' {c 'g}fnE' if " ///
             "zvarC`elseT'`whenTXT'`intext'`nop'{txt}" _n  "`col23' " _c 
        if `elseALL' di "(no {bf}ifnot{sf}, so capturing false {ul:and} {it}indeterminate{sf})" ///
             _n "`col23' "  _c
      }
      if `chat2' di as err _n `" EXECUTING: `by'replace `var' `equals' `elsefn' if `zvarC'`elseT'`whenVAR'`in'`nop'"' _n
      `qt'`by'replace `var' `equals' `elsefn' if `zvarC'`elseT'`whenVAR'`in'`nop'
*      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    }
*
if `chat' { // note various reports
*
    if `usevars'  {
       LIN 3
       di as txt "{c |}{col 8}temp workspace {c +}" ///
      "  {bf}cleared{sf} ({it}workspace variable-names were fictitious{sf})"
    }
*
if `extdefF1'|`extdefF3' {
     if `extdefF1' di as txt "`chatnote'for this command," 
       else di as txt "`chatnote'with a target string variable," 
     LIN 2 _c
     di "  the default '{bf}extended:on{sf}' setting has been suppressed" 
}
if `extdefF2' di as txt "`chatnote'option {bf}extended{sf} otiose, since already set as default" 

if (`equivalentF1' | `equivalentF2')  {
      di as txt  "`chatnote'we would get the identical result, without {bf}when{sf}, by:"
      LIN 2 _c
      if `equivalentF1' di `"  {bf}.vy `dots' if (`ifexp') & (`when'){sf}"'
       else di `"  {bf}.vy `dots' if `when'{sf}"'
}
*
    if  `noneede' & `chat' di as txt  "`chatnote'{help validly##sourcecode:no need to specify {bf}{ul:e}xtended{sf}} " ///
           "in addition to {bf}{ul:s}ource{sf}"
*
} // end pure chat notes
*
    if  `repF' & (`elseF'|!`ifexpF') & !`inF' & (!`whenF' | (`whenF' & `whenCONS'==2)) {
       if `chat' di as txt  "`chatnote'variable {bf}`var'{sf} now {ul:completely} replaced."
       local repALL 1  //used below, so not within chat
    }
*
if `whenCONS' {
   local i "not-"
   if `whenCONS'==2 local i ""
   if `chat' di "`chatnotee'" _c  
    else {
       di "`mark'{err}{it}note{sf}:{txt} " _c
       `marku'
    }
    di `"the '{bf}when{sf}' condition, {inp}`when'{txt}, was uniformly {bf}`i'True{sf} `in'"' 
   if `chat' {
      LIN 2 _c
      if `whenCONS'==1 di "  so the {bf}`action'{sf} command had {bf}no{sf} effect."
      else di "  so added no constraint."
   }
}
*
if `warn_max'|`warn_min' {
   local i "min"
   if `warn_max' local i "max"
   if `chat' di "`chatnotee'" _c 
   else {
       di "`mark'{err}note{txt}: " _c
       `marku'
    }
    di "{help validly##max:click here for a caution} on the interpretation of {inp}`i'(){txt}"
}
*
if `stringTRIP' & ("`stringEMV'"!=".s") & !`sourceF' {  // source reports this in table
   if `chat' di as txt "`chatremind'" _c
   else {
      di as txt "`mark'" _c
      `marku'
   }
   di "indeterminate string relations return {bf}`stringEMV'{sf}"
}
*
if `extendedF' {
   if `arithopF' {
      REMINDA  1 `arithopC' `chat' "`mark'" // a reminder about arithmetic misstreatment of missing
      `marku'
   }
*   inelagntly, thse are seperate tests - the arithop tested characters, thy plainever is set 
*   by any plain chunk.  Rescue by only reporting 2nd if it is nonarithmetic; not exact, but will do
   if `plainEVER' {  
      local k 1
      foreach i in  + * / - ^  {
         if strpos("`plainTXT'","`i'") {
            local k 0
            continue, break
         }
      }
      if `k' |!`arithopF' {
         REMINDA  0 `plainTXT' `chat' "`mark'" // a reminder about function misstreatment of missing
         `marku'
      }
   }
}
*
if `remindEXP' & `chat' {
   local j = word("`numer'",`remindEXP')
   if `remindEXP'== 1  local i ""
   else local i "s"
   di as txt "`chatremind'{help validly##precedence:precedence sequence inversion`i'}{txt} in the parsing of" 
   LIN 2 _c
   di  "  `j' expression`i' (see above)"  
}
*
if `sourcewarnF' {
      if `chat' {
          di "{c |}{col 15}{err}{bf}warning{sf}{txt} {c +}  with {bf}{ul:s}ource{sf}" /// 
         " set, explicit reference to {bf}" _c
         forvalues ii=1/`rmis' {
             di " `rmisB`ii''" _c
         }
         di "{sf}"
         LIN 2 _c
         di "  may not have worked as you intended, since"  
         LIN 2 _c
         di  "  extended-missing codes {help validly##sourceimp:{ul:within} the data are not visible.}"
      }
      else di "`mark2'{err}{bf}warning{sf}:{txt} on use of '{inp}`sourcewarnEMV'{txt}' in this context;" ///
        "{help validly##sourceimp: click here for discussion}"
}
*
   if "`vlabND'"!="" & `chat' {
        di "`chatnotee'{help validly##extype:value label} '{inp}`vlabND'{txt}'" ///
             " has yet to be defined"
   }
*
if (`warn_mi'|`warn_mv') {
   WARN_MI `warn_mi' `chat' "`mark'"
   `marku'
}
*
   if `repF' & `sourceF' & !`repALL' {  // look to see whether codes preused
*      taking care this code happens *before* final REPORT, which modifies prevar
      capture misstable sum `prevar' if `prevar'==`var'  //both untouched and changed-to-match
*        better just untouched, but no way to flag
	  local prevEMV =r(N_gt_dot)
      if "`prevEMV'"=="." local prevEMV 0
      local total 0
      if `prevEMV' { // emvs, are they sourced
         tempvar hunt
*        count number of each source 
         foreach emv of local sourceXM {
             quietly gen byte `hunt' = 1 if `prevar'==`emv' & `prevar'==`var'
             capture misstable sum `hunt' if `prevar'==`var'
             local i = r(N_lt_dot)	
             if "`i'"=="." local i 0
             if `i' local ++sourceprev
             local total = `total'+`i'
             capture drop `hunt'
         }
         local prevEMV = `prevEMV' - `total'
         if `prevEMV' local prevEMV 1
     }
   }

if `repF'|`genF' {  //final summary
   local i 2
   if `chat' {
      LIN 3
      di as txt  "{c LT}{hline 6} final summary {c RT}  " _c
      local i 0
   }
   else {
      if `"`mark'"'==`"`mark2'"' ULINE `mline' `mark3'
      di "{col `mark3'}" _c
   }
   REPORT `var' `asstring' `chat' `repF' `extendedF'  `i' `prevar'
   if `chat' di "{c |}{col 20}{hline 3}{c BT}{hline 3}"
}
*
local skip 0
if `extendedF' {  // report on extended values, iff appropriate
   TELL_EM "`var'" "`in'" `chat' `genF'  `ifnotF'|`elseF' `"`whenRAW'"' `zvarW'
   if `r(skip)' local skip 1 // no point in reporting table
}
*
}
else if 3==4 {  //exp only ##
   local qta "quietly"
   if `assert' {   //just pretifying the output from assert
       di as txt  _n " Finding, {ul:on that definition}, "  _c
       capture `by'`action' `var' `equals' `s1' `in'`assertOPN'
       if _rc==0 di "no contradictions."
       local qta ""
   }
    if `repF' {
       tempvar prevar
       quietly generate `prevar' = `var'
    }
*
    if `chat2' di as err _n `" EXECUTING: `by'`action'`type' `var'`vlab' `equals' `expfn' `in'`assertOPN'`nop'"' _n
    `qta' `by'`action'`type' `var'`vlab' `equals' `expfn' `in'`assertOPN'`nop'
*    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
}
*
if `chat' local vert "{c |}"
*
*
*
if `sourceF' {  // report for source
   if `sourceCHAR'==97 di as txt "`vert'" _n "`vert'  {txt}{it}note{sf}:" ///
     " no relevant raw variables (with missing values) were found as logical/relational" ///
       _n "`vert'" _col(10)"operands (or as simple expressions), so option {bf}source{sf} is here inefficacious."
   else if `skip' {
       if `chat' di as txt "{c |}  and, for the same reason, the table of 'source' codes is immaterial"
   }
   else {
      if `chat' {
         di as txt "{c |}" _n "{c LT} " _c
         local jpos `vert'{col 8}
      }
      else {
         local jpos {col `mark3'}
         di _n "`jpos'" _c
      }
      di  "{txt}Source of missing values (conflicts " _c
      if `sourceR' di "{help validly##rscode:broken randomly})"
      else di "set to {it}sysmiss{sf})"
      local i 1
      di  "`jpos'{c TLC}{hline 4}{c TT}{hline 17}{c TRC}" _n ///
           "`jpos'{txt}{c |}e-mv{c |} Source variable {c |}" _n ///
          "`jpos'{c LT}{hline 4}{c +}{hline 17}{c RT}"
      foreach vin of local sourceVAR {
         local vinm : word `i' of `sourceXM'
         local ++i
         di  "{txt}`jpos'{c |} {res}`vinm' {txt}{c |}{inp} `vin'"
      }
      if `stringTRIP' di  "{txt}`jpos'{txt}{c |} {res}`stringEMV' {txt}{c |}[string vars]{space 4}{c |}"
      if !`sourceR' & `i'>2 {
          di "{txt}`jpos'{txt}{c |} {res}.  {txt}{c |}[conflict]" _c
          if `genF' &  ((`ifexpF' & !`elseF') | (`whenF' & `whenCONS'!=2)) ///
            di "{bf}{c |}{sf}{it}not-generated{sf}"
           else di "{space 7}{c |}"
      }
      di  "{txt}`jpos'{c BLC}{txt}{hline 4}{c BT}{hline 17}{c BRC}"
      if `isNVAR' {
          di "`jpos'variable" _c
          if `isNVAR'>1 di "s" _c
          foreach j of local sourceNVAR {
             di " {inp}`j'{txt}" _c
          }
          di " had no missing values`in'"
      }
      if `i'==2 di "`jpos'(odd to invoke {bf}source{sf} for only one pertinent variable?)" 
      local j 0
      if `sourceprev' & !`repALL'  {
         if `sourceprev'<6  local sourceprev = word("`numer'",`sourceprev')
         di "`jpos'{err} note{txt} variable {inp}`var'{txt} " ///
         "{help validly##varsource:already held `sourceprev' of these e-mv codes}" 
         local j 1
      }
      if `prevEMV' & !`repALL'  {
        if `j' di as txt "`jpos'{space 6}and also" _c
         else  di "`jpos'{err} note{txt} {inp}`var'{txt}" _c 
        di as txt " contains other e-mv codes, predating the current command."
      }
   }
}
if `chat2'>=5 di as text _n " End: `vvers'  `vdate'"


if `chat' {
   if !`global' {
      di as txt "{c |}" _n  "{c |} {txt}RPN parsing returned in {res}r(RPN){txt}" ///
      "{space 4}To view it again, type:  {inp}.vy{txt}"
      di as txt "{c BLC}{hline 76}{c BRC}"
   }
}
*
return local RPN `returnRPN'
if `remindF' return local precedence `precedence'

*
************************************************************************************
************************************************************ END main program ******
************************************************************************************
end
*
*
*
*
*****************************************************
* Subprograms, of varying importance and complexity.
* In alphabetic rather than 'functional' order:
*****************************************************

program CANT
args a b
   di  _n `" {txt}'{inp}`a'{txt}' does not make sense with '{inp}`b'{txt}'; "'  ///
       _n  "{err} these " _c 
   error 184
end

program CHECKEXP
args putative asstring what
* checks whether the first arg is a valid expression
*
   local i `asstring'
   if `asstring' { //exp1 was a string, so this has to be
      local 0 =  `"=(`putative')=="c""'  //remmake as string-equivalence assignment
      capture syntax =/exp //to allow location report
      FINGER `what'
      syntax =/exp 
   }
   else { // numeric
      local 0  = `"=`putative'"'
      capture syntax [=/exp ]
      FINGER `what'
      syntax [=/exp ]
}
end

program COMFORT
args var
   di as txt "{c |}{col 23}{c |}  for reassurance: though {c 'g}fnC' itself references {bf}`var'{sf}," _n /// 
   "{c |}{col 23}{c |}  use of zvarC prevents side effects in sequential changes below"
end

program COMPACT, rclass
args fn chat2 what
* to assemble the evaluation of alternate codings
* Note: cant use string operators since exps will often by too long for strings
*       so options restricted.
*
* count cond(
   global validly_t_m_p_ `"`fn'"' // must use a global
   global validly_t_m_p_ :  subinstr global validly_t_m_p_ "cond(" "(", count(local count) all
*
* count operators 
   local operators 0
   local list "== >= <= != > < * + / ^" //note conjoint first
   foreach z of local list {
      global validly_t_m_p_ :  subinstr global validly_t_m_p_ "`z'" "",  count(local n) all
      local operators = `operators'+`n'
   }
* scrub remaining non-bracket
   forvalues i = 32/255 {  
      if `i'!=96 & `i'!=40 & `i'!=41{  // 96 is ` which messes up if included
         if `i'==32 local j " "
           else local j=char(`i') //assign char(32) seems not to work
         global validly_t_m_p_ :  subinstr global validly_t_m_p_ `"`j'"' "", all
      }
   }
* count bracket depth and pairs
   local pairs 0
   forvalues i = 1/30 {
      local depth = `i'-1
      local n : length global  validly_t_m_p_
      if `n'==0 continue, break
      global validly_t_m_p_ :  subinstr global validly_t_m_p_ "()" "",  count(local n) all
      local pairs = `pairs'+`n'
   }
   macro drop validly_t_m_p_ //clean up
* chatter
   if `chat2'>=5 {
      di as txt `"# Coding `what', conds `count', depth `depth', pairs `pairs', operators `operators':"'
      TELL_COND `"`fn'"' 0
   }
   if `"`what'"'=="err" { //error call from TESTS
      di _n "For information: it embodies `count' calls to {bf}cond{sf};" ///
      _n _col(18) "also `pairs' pairs of brackets, in places `depth' deep;" ///
      _n _col(18) "further, it contains `operators' dyadic operators." _n
      exit
   }
*    reporting conds and depth for action:
   return scalar conds = `count'
   return scalar depth = `depth'
end

program DEFAULT
   global validlyDefault ///
   "detail:OFF extended:OFF impute:ON  compact:ON  nullstring:.s remind:ON  nomiss:ON  chat2:0  "
end

program DEFVAL, rclass
args key
*    calling program knows if answer is OFF/ON
   local default = substr("$validlyDefault",strpos("$validlyDefault","`key':")+3,3)
   if "`default'"=="OFF" local default 0
   if "`default'"=="ON " local default 1  // other flags passthru as are
   local default = trim("`default'")
   return local default `default'
end

program ERR197
args raw n
   di as err _n(2)"{ul:PLEASE}:"  
   di " {help validly##contact:email the author}" _n " listing the ERROR SUB-CODE {inp}`n'{err}" 
   di " and the precipitating command line:" 
   di as inp `"   .`raw'"'  _n 
   di as err " {hline 3} it is possible that this particular" _n ///
    " error may be ascribable to the author's " _c
   error 197
end

program FINGER
args where
*  to allow notification of exp errors in ifnot|else|when
   if _rc!=0  di _n "{err}Error in {inp}`where'(){err} {hline 2} " _c
end

program GEN_TV
args varlist extendedF nonindF
*      program to generate test variables
*      Essentially a stand-alone utility whose internal logic
*      has NO connection to the rest of program validly.
   local arraymax 60000 // max array considered
   local nv 0
   foreach var in `varlist' {
      local ++nv
      if `nv'==1 local var1 `var'
      if `nv'==2 local var2 `var'
   }
   if `nv'==1 error 102
   local b  1  // active bite
   local bs 3 //bitesize
   if `extendedF' local bs 5
*   
   local m  =`bs'^`nv'
   if `m'>`arraymax' {
      if `extendedF' di "With 'extended' set, " _c
      di "that would generate `m' patterns; " _c
      error 103
}  
   local ms = _N
*
   local ma `m'  //array size default
   if `ms'>0  {  // extant data
      if `m'>`ms' {
         local i = `ms'+1
         di " {err}{ul:Note}:{txt} This would require addition of empty rows, {res}`i'{txt} to {res}`m'{txt}, across" ///
         _n  " the other variables already in the data.  {err}Continue ({bf}y{sf}/{bf}n{sf}) {bf}?{sf}{txt}" _r(validly_t_m_p_)
         if ltrim("$validly_t_m_p_")=="y" | ltrim("$validly_t_m_p_")=="Y" {
            di as txt " continuing:"
            macro drop validly_t_m_p_
         }
         else {
            di as err " User termination."
            macro drop validly_t_m_p_
            exit
         }    
      }
      else local ma `ms'  // datat bigger than needed
   }
*   
   quietly set obs `ma'
*
*    these few lines do the work:
   foreach var in `varlist' {
      local bd `b'
      local b = `b'*`bs'
      quietly generate `var'=.
      local r1 1
      while `r1' < `m' {
         local r2 = `r1' + `b' -1
         quietly replace `var' = floor((_n-`r1')/`bd') in `r1'/`r2'
         local r1 = `r2'+1
      }
      quietly recode `var' (0=1) (1=0) (2=.) (3=.a) (4=.b)
      if `nonindF' quietly replace `var' = 1+int((100)*runiform()) if `var'==1
   }
*
* more talk:
   if `nonindF' local i "" 
     else local i " (one)"
   di as txt _n "{hline}" _n " Generating all possible patterns of the values{res} {bf}True`i'{sf}, {bf}False (zero){sf}, {it}sysmis" _c
   if `extendedF' di ", .a{sf}, and {bf}.b{sf} {txt}"
      else di "{sf}{txt}"
   di " across variables: {inp}{bf}`varlist'{sf}{txt}; so, making {res}`m'{txt} distinct patterns." ///
        _n " (leftmost variables vary most rapidly)" 
   if `nonindF' di `" (variables are NOT "indicator variables":"' ///
        _n `"  observations evaluated True contain random integers, range 1-100)"'
    else di `" (variables are "indicator variables")"'
   if `m'<`ma' di " (Note: patterns in rows 1 to `m' only)"
*      guidance:
   local i 2
   di _n " To examine all patterns"
   while `i'<=`nv' {
      di _col(5) "{hline 7} across" _c
      local ir = `nv'-`i'+2
      local j 1
      foreach var in `varlist' {
         if `j'>1  {
            if `j'==`ir' di " and" _c
            else di "," _c
         }
         di " {inp}{bf}`var'{sf}{txt}" _c
         local ++j
         if `j'>`ir' continue, break
      }
      local r2 = `bs'^`ir'
      if `r2'==`ma' di ":  use all observations"
         else di `":  specify "{res}{bf}in 1/`r2'{sf}{txt}""'
      local ++i
   }

   if `nv'>2 {
      di _col(7) "{ul:Note}: the" _c
      if `m'<`ma'|`nv'>3 di "se ranges apply only to these specific sets"
         else di" range applies only to that specific subset"
   }
   di _n "    {ul:Example}" _n  /// giving example
     "    Using {inp}`var1'{txt} and {inp}`var2'{txt}, you could compare the results from:" ///
     _n  _col(9) "{inp}{bf}.gen ys = `var1' | !`var2' {sf}" _c 
   local r2 = `bs'^2
   if `r2'<`ma' di "{bf}in 1/`r2'{sf}{txt}"
      else di " {txt}"
   di "    (perhaps modifying by some tests for missing values????)" _n ///
     "    with the correct ones from:" _n ///
       _col(9) "{inp}{bf}.validly gen yv = `var1' | !`var2'{sf}" _c
   if `r2'<`ma' di " {bf}in 1/`r2'{sf}" _c
   if `extendedF' di ",  {sf}extended{txt}"
      else di "{txt}"
   di "{hline}"
end

program LIN
args n cont
*
if `n'==3 di as txt "{c |}{col 23}{c LT}{hline 3}"
else if `n'==2 di as txt "{c |}{col 23}{c |}  " `cont'
else di as txt "{c |}
*
end

program MIXED
args n vvers fn
*    p1=1 iff function (function in p3), ==2 iff arithmetic
*    p2   is version
      di   _n "{txt} {ul:Apologies}:{err} `vvers' of {bf}validly{sf} does not handle "
      if `n' {
         di as err "   {ul:arithmetic} carried out on the {ul:{bf}RESULTS{sf}} of logical/relational expressions," _n ///
           "   as in expression: {inp}`fn'{txt}"
       }
         else di as err "   logical/relational operators {bf}WITHIN{sf} a function such as {ul:`fn'({c 133})}  "    
      di as txt _n  " {ul:Suggested Workaround:}" 
      if `n' di " First, check that you meant to make that exact request" _n ///
      " (though admittedly definable, it is still a mite substantively odd" _n ///
      "  to need to do arithmetic on things which are True or False?);" _n ///
      " if you did mean it, then:" _n
      di " Use {res}validly generate{txt} to make new variable(s)," _n  ///
        "   correctly evaluating the {bf}relevant{sf} logical/relational expression(s)" _c
      if `n' di ""
        else  di " within {inp}`fn'({c 133})"  
     local i ""
     if `n' local i " for arithmetic"
     di as txt " And then reissue your current command" _n ///
       "    using the new variable(s)`i' in place of the relevant expression(s)" _c
     if `n' di "" _n(2) " {help validly##restrictions:click here}" _c
       else di " within {inp}`fn'({c 133})"  _n(2) " {help validly##restrict2:click here}" _c
     di as txt " for more information" _n 
   error 696
end


program NEEDS
args a b
   di as txt _n `"'{inp}`a'{txt}' presupposes '`b''; "' _c
   error 119
end

program NOEGEN
args mark mark2
   di as txt  "`mark'apologies, but {err}validly does not operate on egen{txt}" _n(2) ///
       "`mark2'{ul:Suggestion}:" _n "`mark2'   Turn the relevant logical/relational expression(s) into valid function(s)" _n ///
       "`mark2'   using   {help validly##global:{bf}vy global mname exp{sf}}   {ul:or}" ///
       "   {help validly##global:{bf}vy global mname if exp{sf}}  as appropriate" _n ///
       "`mark2'   and invoke {bf}egen{sf}, embeding these macros where relevant." _n
   error 133
end

program PLAIN1
args exp action
      di _n `" {res}Note{txt} Since {c RT} `exp' {c LT} uses no logical/relational operators,"' ///
        _n "      a plain {inp}`action'{txt} would here give the same result." _n
end

program REMINDA
args n arithopC chat mark
     if `chat' {
        di as txt  "{c |}{col 14}{it}reminder{sf} {c +}  Stata's " _c
        if `n' di  "{help validly##extendedn2:arithmetic operators discard {ul:extended}-missing}" 
        else  di  "{help validly##extendedn2:functions mostly smooth {ul:extended}-missing to {it}sysmiss{sf}}" 
        LIN 2 _c
        di "  for eaxmple, {bf}" _c
        if `n' {
           di "4`arithopC'(.a){sf} is seen as {it}sysmiss{sf}, not correctly as {bf}.a{sf}"
           LIN 2 _c
           di "  so {ul:extended} preserved only for logical/relational operators."  
        }
        else di "`arithopC'{sf} may return only sysmiss for missing."
     }
     else {
        di "`mark'{it}note{sf}: " _c
        local i "does"
        if `n' di "arithmetic (e.g. '{bf}`arithopC'{sf}')" _c
        else {
           di "function '{bf}`arithopC'{sf}'" _c
           local i "may"
        }
        di " {help validly##extendedn2:`i' not preserve extended-missing codes}"
    }
end

program REPORT
args var asstring chat repF extendedF brace prevar
*    print summary info on a varianle
*    prevar last argument since may be absent
*
* enter knowing either generate or replace
* follow Stata convention of report-is-over-ALL-of-variable
* note catering for strings (none of which come extendedF)
local bs ""
local bf ""
if `brace' {
   local bs "("
   local bf ")"
}
if `repF' {
      if `asstring' {
         tempvar varmiss // misstable does not work on strings, so we do:
         quietly gen byte `varmiss' = cond(`prevar'==`var',1,cond(mi(`var'), ., .a))
*         so 1 is no-change, .a is changed-to-value, . is changed-to-any-missing
         capture misstable sum `varmiss' //. no qualifiers, cause Stata reports over all 
         drop `varmiss'
      }
      else { // numeric
         quietly replace `prevar' = cond(`prevar'==`var',1,cond(mi(`var'), ., .a))
         quietly compress `prevar'
*         so 1 is no-change, .a is changed-to-value, . is changed-to-any-missing
         capture misstable sum `prevar' //. no qualifiers, cause Stata reports over all 
      }
	  local tonum=r(N_gt_dot)
      if "`tonum'"=="." local tonum 0
	  local tomi=r(N_eq_dot)
      if "`tomi'"=="." local tomi 0
      local tot = `tonum'+`tomi'
      local toemv 0
      if `tomi'>0 &  `extendedF'  {  // (strings are not extended)
         quietly replace `prevar' = cond(`prevar'==.,cond(`var'>.,.a,.),1)
         capture misstable sum `prevar' //. no qualifiers, cause Stata reports over all 
         local toemv = r(N_gt_dot)
      }
      if !`tot' di as txt "`bs'{res}no{txt} real changes made" _c  
        else if `tot'==1 di as txt "`bs'{res}1{txt} real change made" _c  
        else di as txt "`bs'{res}`tot'{txt} real changes made" _c  
      if `tomi'==0 {
         if `extendedF' & `tot' di ", {res}none{txt} to any missing value`bf'"
           else di "`bf'"
      }
      else {
         if `tot'==`tomi' di "{bf};{sf} {res}all{txt} to missing" _c
         else di "{bf};{sf} {res}`tomi'{txt} to missing" _c
         if `extendedF' {
            if `toemv'==0 di ", none" _c
            else if `toemv'==`tomi' di ", {res}all{txt} of these" _c
            else di ", of these {res}`toemv'{txt}" _c 
            di " to {ul:extended}" _c
         }
      di "`bf'"
      }
   }
   else { // generate, repeat calls possible
      local res "{res}"
      if `brace'==1 local res ""
      if `asstring'{
          tempvar varmiss // misstable does not work on strings, so we do:
          quietly gen byte `varmiss' = 1 if `var'==""
          capture misstable sum `varmiss' //. no qualifiers, cause Stata reports over all 
	      local tomi=r(N_lt_dot)
          if "`tomi'"=="." local tomi 0 // get here if varmiss has no missing
          local tot `tomi'
          drop `varmiss'
      }
      else { // numeric
         capture misstable sum `var' //. no qualifiers, cause Stata reports over all 
	     local toemv=r(N_gt_dot)
         if "`toemv'"=="." local toemv 0
	     local tomi=r(N_eq_dot)
         if "`tomi'"=="." local tomi 0
         local tot = `toemv'+`tomi'
      }
      if !`tot' di as txt "`bs'`res'no{txt} missing values generated" _c
        else if `tot'==1 di as txt "`bs'`res'1{txt} missing value generated" _c
        else di as txt "`bs'`res'`tot'{txt} missing values generated" _c  
      if `extendedF' { // (strings are not extended)
         if `toemv'==0 di ", `res'none{txt}" _c
         else if `toemv'==`tomi' di ", `res'all{txt}" _c
         else di ", `res'`toemv'{txt}" _c 
         di " of these {ul:extended}" _c
      }
      di "`bf'"
   }
end

program RRPN, rclass
args  rpn precedence tempifcond
      return local RPN `"`rpn'"' // this and following so returns are not destroyed
      if "`precedence'"!="" return local precedence "`precedence'"
      if `"`tempifcond'"'!="" return local ifcond `"`tempifcond'"'
end

program SETT 
args str set
   local j = strpos("$validlyDefault","`str':")+3
   local k = substr("$validlyDefault",`j',3)
   local was = "`str':`k'"
   local now = "`str':`set'"
   global validlyDefault = subinstr("$validlyDefault","`was'","`now'",1)
end

program TELL_COND 
args cond tail
      local mline : length local cond
      local char "71"
      local char2 "76"
      if `mline'>76 {
         local char ""
         local char2 ""
      }
      di "{txt} {c TLC}{hline 4}{c BT}{hline `char'}" ///
         _n  `" {c |}{res}`cond' {txt}"' 
      if `tail' di "{txt} {c BLC}{hline 4}{c TT}{hline `char'}"
        else di " {c BLC}{hline `char2'}"
end

program TELL_EM, rclass
args var in chat genF ifnels whenRAW zvarW
*
      local zvarWW ""
      local skip 0
      if "`whenRAW'"!="" local zvarWW " if `zvarW'"
      capture misstable sum `var' `in' `zvarWW'
*
      local inplus ""
      if "`in'"!="" local inplus = ", " + "`in'"
	  local i=r(N_gt_dot)
	  local j=r(N_eq_dot)
      local k " now"
      if `genF' local k ""
      if `i'==0 | `i'==. {
         if `chat' {
            di as txt "{c |}" _n "{c LT}{c - } Suppressing the table:" _n ///
           `"{c |} {res} "Frequency of missing values for `var'`inplus'`whenRAW'"{txt}"' _n ///
            "{c |}  since it would contain no {ul:extended}-missing codes"
              note:`k' no {ul:extended-missing}-values"  ///
 *            " in variable {inp}`var'" _c     if `genF' di "{txt}"      else di "`inplus'`whenRAW'{txt}"
         }
         local skip 1 // so we suppress the table
      }
      else {
	     if `chat' {
            local i = length(`"`var'`inplus'`whenRAW':"')+34
            local ii = max(`i',46)
            local j = max(`ii'-`i'+1,1)
            local ii = `ii'-12
            di as txt "{c |}" _n "{c LT}{c -} Frequency of missing values for {inp}`var'`inplus'`whenRAW'{txt}{space `j'}{c |}" _n ///
              "{c BLC}{hline 11}{c TT}{hline `ii'}{c BRC}" _c
            
            if "`whenRAW'"!="" local zvarWW " & `zvarW'"
            tab `var' `in' if `var'>=.`zvarWW', m
            di as txt "{c TLC}{hline 11}{c BT}{hline 35}"
         }
	  }
      return local skip `skip'
 end

program TELL_G
args mark mark2 mark3 mline
local ii ""
  if _rc==109 local ii  " (& non-string)"
  if _rc!=0 {
     di as txt "`mark'{bf}global{sf} here must reference a legitimate`ii' expression," ///
    _n  "`mark2'and has only two forms:" ///
    _n  "`mark2'{space 4}{bf}.validly global{sf} {inp}mname {help exp:exp}{txt}   {ul:OR}   {bf}.validly global{sf} {inp}mname {help exp:if exp}{txt}" ///
    _n  "`mark2'and for options: the first form allows {help validly##extended:{ul:e}xtended}," ///
     " second allows {help validly##widely:{ul:w}idely}" 
    ULINE `mline' `mark3'
   }
end

program TELL_MA
args stepf emiss compactN sourceF sourceR everN everIND
   local sc "{ul:extended}-missing values"
   if `sourceF' local sc "source-tagged-missing"
   local opt ""
   if `compactN' local opt "optimised "
   local ip ", if possible,"
   local rt ""
   if `sourceR' {
      local ip ""
      local rt "; {help validly##rscode:random tie-breaking}"
   }
   di "{text}giving, in local macro{res} {c 'g}fn`stepf''{txt}, the valid `opt'function:"
   if `everN'|`everIND' {
      di "{col 7}{c |} (simplifying where variables" _c
      local opt ""
      if `everN' {
          di " lack missing values" _c
          if `everIND' di ", or" _c
      }
      if `everIND' di " are indicator variables" _c
      di ")"
   }
   if `emiss' di "{col 7}{c |} (coded to preserve`ip' `sc'`rt'):" 
end

program TELL_MF
args W n
   di "{space 6}{text}{c |} which in '{bf}m{sf}issing->{bf}F{sf}alse' form " _c
   if `n'==1 di "(to circumvent Stata's" _n ///
   _col(7) "{c |} assumption that missing-{it}means{sf}-True) becomes, in {res}{c 'g}fn`W'_mF'{txt}"
   if `n'==2 di _col(10) "(to coerce Stata's 'assert' " _n ///
     "{space 6}{text}{c |} to see {ul:missing} as {ul:not}-known-{ul:true}) becomes {res}{c 'g}fn`W'_mF'{txt}"
end

program TELL_NC
args var exp markq
   di  "`markq'but unsuitable for {help validly##global:a conditional call} {hline 2} so {ul:not}:" ///
     " {inp}.command {err}if \$`var'{sf}{txt}" ///
     _n  `"`markq'{hline 2} for that task, invoke:{space 2}{inp}.vy global `var' {ul:if} `exp'{txt}"'
end

program TELL_NLR
args exp svarF n
   di
    di as txt  " {inp}exp`n'{txt}{col 7}{c |} " _c
   if `svarF' di "is the simple variable {c RT} {inp}`exp' {txt}{c LT}" _n  `" {hline 5}{c BRC} "' _c
     else di as txt  "contains no logical/relational operators, so" _n ///
     `" {hline 5}{c RT} we place unmodified {c RT} {inp}`exp' {txt}{c LT} into local macro {res}{c 'g}fn`n''{txt}"'
end

program TELL_NV
args markq
   di  `"`markq'{space 6}(unsuitable for re-use {help validly##ewrap:{ul:within}} {bf}validly{sf})"'
end

program TELL_PREC
args and chat pos markU1 first  markU2 remind2a remind2b
local times  X twice thrice repeatedly 
* stored as words to allow transfer, move to subscripted for evaluation
*
if `first' {
    di as txt "`markU1'{it}reminder{sf}: " _c
    if `chat' di "following standard syntactical convention" _n `"`markU1'"' _c
}
if `first'>1 { // to report &|
   local m = `first'-1
   local mm = word(`"`times'"',min(4,`m'))
   if "`mm'"=="X" local mm ""
     else local mm " `mm'"
   di as txt  _col(`pos') "logical '{inp}&{txt}' has`mm' {help validly##precedence:taken precedence} over '{inp}|{txt}'" _c
   if `and' di "; also"
     else di ""
}
else { // relation over logical -- explicit report
   local n 0
   foreach i of local remind2a {  // put into subscripted vector
      local ++n
      local a`n' "`i'"
      local b`n'=word(`"`remind2b'"',`n')
   }
*
   forvalues i=1/`n' {
      if "`a`i''"=="X" continue // has been done
      local m 1 // instances counter
      if `i'<`n' { // still to see
         local jj = `i'+1
         forvalues j = `jj'/`n' {
            if "`a`i''"=="`a`j''" & "`b`i''"=="`b`j''" { // repeat
               local ++m // count
               local a`j' X
            }
         }
       }
       local mm = word(`"`times'"',min(4,`m'))
       if "`mm'"=="X" local mm ""
         else local mm " `mm'"
       if `first' {
*           di as txt "`markU1'{help validly##precedence:reminder:} " _c
           local j ""
           local first 0
       }
*       else di "     " _c
       else {
          local j `markU2'
          if `chat' local j `markU1'
       }
       di as txt `"`j'"' _col(`pos') `"relation '{inp}`a`i''{txt}' has`mm' {help validly##precedence:taken precedence} over logical '{inp}`b`i''{txt}'"'
   }
}
end

program TELL_RPN
args n
   di 
   di as txt " {inp}{it}exp{sf}`n'{txt}{col 7}{c |} {help validly##RPN:RPN form}, parsing on logical/relational operators, is:"
end

program TELL_WS
args chat
      if `chat' {
         di as txt  "{space 6}{text}{c |} {err}Note: {text}since option {bf}widely{sf} has been specified, observations"
         di "{space 6}{text}{c |}{space 7}will be selected when {c 'g}{bf}fnC{sf}' is true {ul:or indeterminate}"
         di "{space 6}{c BLC}{hline 71}"
      }
end

program TESTS
* guidance on overlength.
* uses syntax to decode call: N =`condexp'
   capture syntax name  =/exp //sensitive to overlength exps
   local i = _rc
   if "`namelist'"=="X" local namelist  ""
   if `i'==130 {
      di  _n "{err}The constructed function {c 'g}{bf}fn`namelist'{sf}' is too complex for Stata;{txt}" 
      COMPACT "`2'"  0  "err"
      di "{help validly##toolong:{bf}click here{sf} for suggestions} on how how to circumvent" _n ///
      "the error: " _c
      error 130
   }
end

program TLABEL , rclass
args n colon value
    if "`value'"==":" {
      di as err "value label missing after colon"
      error 111
    }
    if `n' exit
    if "`colon'"!=":" error 198
    capture label list `value'
*   if _rc!=0 label list `value'
    return local tlabel ""
    if _rc!=0 return local tlabel `value'
end
 
program TOGSET
args str 
local alphaLC "abcdefghijklmnopqrstuvwxyz"
* to set specified toggle
   if "`str'"=="ng" {
      local error 0
      if length("`2'")!=2 local error 1
      if substr("`2'",1,1)!="." local error 1
      if indexnot(substr("`2'",2,1),"`alphaLC'")!=0 local error 1
      if `error' {
         di as err _n `"'`2'' where {ul:extended}-missing value expected"'
         error 7
      }
      SETT `str' "`2' " // to keep 3 char spacing
   }
   else if  "`str'"=="t2" {
      if `2'<0 | `2'>9 error 198
      SETT `str' "`2'  " // to keep 3 char spacing
   }
   else {
      if  "`2'"=="OFF" |  "`2'"=="off"  SETT "`str'" "OFF"
      else if  "`2'"=="ON" |  "`2'"=="on" SETT `str' "ON "
      else {
          di as txt "Unrecognised parameter '{inp}`2'{txt}', whence " _c
          error 199
      }
   }
end

program ULINE
args mline mark3
         local j = `mark3'-3
         local k = `mline'-`j'-1
         di as txt "{space `j'}{c BLC}{hline `k'}"
end

program ULINE2
di as txt "{col 7}{c BLC}{hline 71}"
end

program VCHECK
args asstring var
* check existing variable OK for type
   if `asstring' {
      capture confirm string variable `var', ex
      if _rc!=0 {
         if _rc==7 di as err " Numeric variable " _c
         confirm string variable `var', ex  // error exit
       }
    }
    else {
       capture confirm numeric variable `var', ex
       if _rc!=0 {
          if _rc==7 di as err " String variable " _c
          confirm numeric variable `var', ex // error exit
       }
    }
end

program WARN_MI
args warn_mi chat mark
   local tell "a conditional test-for-missing"
   if `warn_mi' local tell "a conditional mention of {inp}mi(){txt}"
   if `chat' {
 *   LIN 3 // need to tag this ## 
    di  "{c |}{col 15}{err}{bf}warning{sf}{txt} {c +}  {bf}validly{sf} noticed `tell', "
    LIN 2 _c
    di "but has not analysed its use; {help validly##reminder:click here}"
    LIN 2 _c
    di "for discussion of why that use might matter. " 
   }
   else di "`mark'{err}{bf}warning{sf}:{txt} on `tell', {help validly##reminder:click here for discussion}"
end

* note on preferred editor colours: font Courier New, 9pt
* built-in B, B    comments DG, -   compound M,B    key-words DB, B
* Macros P, B      numbers B, B     opeartors R, B  strings M, -

