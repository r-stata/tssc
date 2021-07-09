*! 1.0.0 25 Apr 2012 Austin Nichols program to get lower case for foreign names
prog supper
version 11.2
syntax [varlist(string)] [if] [in] [, Generate(string) replace oe ]
marksample touse, s
if "`generate'"==""&"`replace'"=="" {
 di as err "Must specify either generate or replace option"
 error 198
 }
foreach v of loc varlist {
if "`generate'"==""&"`oe'"=="oe" mata:supproe("`v'","`touse'")
if "`generate'"==""&"`oe'"=="" mata:suppr("`v'","`touse'")
if "`generate'"!="" {
 g `generate'`v'=`v'
 if "`oe'"=="oe" mata:supproe("`generate'`v'","`touse'")
 if "`oe'"=="" mata:suppr("`generate'`v'","`touse'")
 }
}
end
version 11.2
mata
mata set matastrict off
void function suppr(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
d[i,1]=char(a:-(((((a:>96):&(a:<123)):|((a:>223):&(a:<255))):*32)))
}
}
void function supproe(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
d[i,1]=char(a:-(((((a:>96):&(a:<123)):|((a:>223):&(a:<255))):*32:+((a:==154):|(a:==156):|(a:==158)):*16:+(a:==255):*96)))
}
}
end
