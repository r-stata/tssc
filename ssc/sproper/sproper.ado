*! 1.0.0 25 Apr 2012 Austin Nichols program to get proper case for foreign names
prog sproper
version 11.2
syntax [varlist(string)] [if] [in] [, Generate(string) replace oe ]
marksample touse, s
if "`generate'"==""&"`replace'"=="" {
 di as err "Must specify either generate or replace option"
 error 198
 }
foreach v of loc varlist {
if "`generate'"==""&"`oe'"=="oe" mata:spropoe("`v'","`touse'")
if "`generate'"==""&"`oe'"=="" mata:sprop("`v'","`touse'")
if "`generate'"!="" {
 g `generate'`v'=`v'
 if "`oe'"=="oe" mata:spropoe("`generate'`v'","`touse'")
 if "`oe'"=="" mata:sprop("`generate'`v'","`touse'")
 }
}
end
version 11.2
mata
mata set matastrict off
void function spropoe(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
l=1,a
l=l[.,1..cols(a)]
d[i,1]=char(a:+(((((a:>64):&(a:<91)):|((a:>191):&(a:<223))):*32:+((a:==138):|(a:==140):|(a:==142)):*16:+(a:==159):*96):*(((l:>64):&(l:<91)):|((l:>191):&(l:<223)):|(l:==138):|(l:==140):|(l:==142):|(l:==159):|((l:>96):&(l:<123)):|((l:>223):&(l:<256)):|(l:==154):|(l:==156):|(l:==158))))
}
}
void function sprop(string scalar v,string scalar t) {
st_sview(d=.,.,v,t)
for (i=1; i<=rows(d); i++) {
a=ascii(d[i,1])
l=1,a
l=l[.,1..cols(a)]
d[i,1]=char(a:+(((((a:>64):&(a:<91)):|((a:>191):&(a:<223))):*32):*(((l:>64):&(l:<91)):|((l:>191):&(l:<223)):|((l:>96):&(l:<123)):|((l:>223):&(l:<255)))))
}
}
end
