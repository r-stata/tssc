*! 1.0.0 25 Apr 2012 Austin Nichols program to get lower case for foreign names
prog slower
version 11.2
syntax [varlist(string)] [if] [in] [, Generate(string) replace oe ]
marksample touse, s
if "`generate'"==""&"`replace'"=="" {
 di as err "Must specify either generate or replace option"
 error 198
 }
foreach v of loc varlist {
if "`generate'"==""&"`oe'"=="oe" mata:slowroe("`v'","`touse'")
if "`generate'"==""&"`oe'"=="" mata:slowr("`v'","`touse'")
if "`generate'"!="" {
 g `generate'`v'=`v'
 if "`oe'"=="oe" mata:slowroe("`generate'`v'","`touse'")
 if "`oe'"=="" mata:slowr("`generate'`v'","`touse'")
 }
}
end
version 11.2
mata
mata set matastrict off
void function slowr(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
d[i,1]=char(a:+(((((a:>64):&(a:<91)):|((a:>191):&(a:<223))):*32)))
}
}
void function slowroe(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
d[i,1]=char(a:+(((((a:>64):&(a:<91)):|((a:>191):&(a:<223))):*32:+((a:==138):|(a:==140):|(a:==142)):*16:+(a:==159):*96)))
}
}
end
