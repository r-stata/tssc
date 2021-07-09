*! labmatch version 1.0 1apr2010
*! by Austin Nichols <austinnichols@gmail.com>
prog labmatch, rclass
version 9.2
syntax anything [if] [, noList Alsolist(varlist) Tabulate(varlist min=1 max=2) id(varlist min=1 max=1) ]
if `"`if'"'=="" loc c "if "
else loc c `if'
loc wc: word count `anything'
if mod(`wc',2)!=0 {
 di as err "syntax is one variable, one string pattern, repeat--you have specified an odd number of arguments"
 exit 132
 }
forval j = 1(2)`: word count `anything'' {
loc v: word `j' of `anything'
conf var `v'
loc vs `vs' `v'
loc m: word `=`j'+1' of `0'
mata:st_vlload("`:val lab `v''",v=.,t=.)
mata:st_local("s",invtk(strofreal(select(v,strmatch(t,"`m'"):>0))))
tokenize `s'
if `"`1'"'!="" {
 if `"`c'"'!="if " loc c `c'&
 if `"`2'"'=="" {
  loc c `c'(`v'==`1')
  }
 else {
  loc c `c'(
  loc n 1
  while `"`1'"'!="" {
   if `n++'==1 loc c `c'(`v'==`1')
   else loc c `c'|(`v'==`1')
   mac sh
   }
  loc c `c')
  }
 }
else {
 di as err `"value "`m'" does not appear in label for `v'"'
 exit 111
 }
}
if `"`c'"'=="if " loc c
if `"`c'"'!=""&"`list'"=="" l `vs' `alsolist' `c'
if `"`c'"'!=""&`"`tabulate'"'!="" tab `tabulate' `c'
if `"`c'"'!=""&`"`id'"'!="" qui levelsof `id' `c', loc(ids)
return local cond `c'
return local id `ids'
return local idcomma `: subinstr loc ids " " ",", all'
return local vars `vs'
end
version 9.2
mata:
string scalar invtk(string colvector s) 
{
        if (rows(s) ==0)  return("")
        s2 = J(1,1,s[1,1])
        for(j=2;j<=rows(s); j++) {
           s2 = s2+" "+s[j,1]
        }
        return(s2)
}
end
