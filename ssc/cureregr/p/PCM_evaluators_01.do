*program define PCM010101_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010101_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = (etht1:/(one+etht1))
k  = one-exp(-1:*tt)
k0 = one-exp(-1:*tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = exp(-1:*tt):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010102_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010102_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = exp(-1:*etht1)
k  = one-exp(-1:*tt)
k0 = one-exp(-1:*tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = exp(-1:*tt):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010103_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010103_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = (tht1)
k  = one-exp(-1:*tt)
k0 = one-exp(-1:*tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = exp(-1:*tt):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010201_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010201_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = (etht1:/(one+etht1))
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = normalden(ln(tt)):*etht3:/ t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010202_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010202_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
pi = exp(-1:*etht1)
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = normalden(ln(tt)):*etht3:/ t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010203_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010203_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
pi = (tht1)
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = normalden(ln(tt)):*etht3:/ t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010301_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010301_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = (etht1:/(one+etht1))
k  = tt:/(one+tt)
k0 = tt0:/(one+tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (one:/(one+tt):^2):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010302_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010302_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = exp(-1:*etht1)
k  = tt:/(one+tt)
k0 = tt0:/(one+tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (one:/(one+tt):^2):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010303_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010303_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(etht2:*t):^etht3
tt0   =(etht2:*t0):^etht3
one=J(rows(d),1,1)
pi = (tht1)
k  = tt:/(one+tt)
k0 = tt0:/(one+tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (one:/(one+tt):^2):*etht3:*tt:/t

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010401_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010401_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one, zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(t):/etht2
tt0   =(t0):/etht2
one=J(rows(d),1,1)
pi = (etht1:/(one+etht1))
k  = gammap(etht3,tt)
k0 = gammap(etht3,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(etht3,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010402_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010402_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(t):/etht2
tt0   =(t0):/etht2
pi = exp(-1:*etht1)
k  = gammap(etht3,tt)
k0 = gammap(etht3,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(etht3,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010403_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010403_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht2, etht3, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht2 = exp(tht2)
etht3 = exp(tht3)
tt    =(t):/etht2
tt0   =(t0):/etht2
pi = tht1
k  = gammap(etht3,tt)
k0 = gammap(etht3,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(etht3,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010501_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010501_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, etht2, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one, zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
tt    =(t):/etht2
tt0   =(t0):/etht2
one=J(rows(d),1,1)
pi = (etht1:/(one+etht1))
k  = gammap(one,tt)
k0 = gammap(one,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(one,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010502_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010502_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, etht2, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one, zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
tt    =(t):/etht2
tt0   =(t0):/etht2
one=J(rows(d),1,1)
pi = exp(-1:*etht1)
k  = gammap(one,tt)
k0 = gammap(one,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(one,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010503_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010503_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht2, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one, zro
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht2 = exp(tht2)
tt    =(t):/etht2
tt0   =(t0):/etht2
one=J(rows(d),1,1)
pi = tht1
k  = gammap(one,tt)
k0 = gammap(one,tt0)
for(i=1; i<=rows(d); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
zro=J(rows(d),1,0)
dk = gammaden(one,etht2,zro,t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010601_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010601_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
tt    = ln(t)
tt0   =t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}
one=J(rows(etht1),1,1)
pi = (etht1:/(one+etht1))
sigma=exp(tht3)
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010602_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010602_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
tt    = ln(t)
tt0   =t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}

pi = exp(-1:*(etht1))
sigma=exp(tht3)
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010603_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010603_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, tht3, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	tht3 = moptimize_util_xb(ML, b, 3) 
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = tht1
tt    = ln(t)
tt0   =t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}

pi = (etht1)
sigma=exp(tht3)
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010701_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010701_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
tt    = ln(t)
tt0   = t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}
one=J(rows(etht1),1,1)
pi = (etht1:/(one+etht1))
sigma=one
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010702_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010702_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
tt    = ln(t)
tt0   =t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}
one=J(rows(etht1),1,1)
pi = exp(-1:*(etht1))
sigma=one
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010703_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010703_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, z, z0, sigma, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = tht1
tt    = ln(t)
tt0   =t0

for(i=1; i<=rows(t0); i++) {
	if (t0[i]==0) {
	tt0[i] = -8e+307
	}
	else {
	tt0[i] = ln(t0[i])
	}
}
one=J(rows(etht1),1,1)
pi = (etht1)
sigma=one
z  = ((tt -  tht2) :/sigma)
z0 = ((tt0 - tht2) :/sigma)
k  = normal(z)
k0 = normal(z0)
dk = (normalden(tt ,tht2,sigma):/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010801_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010801_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, etht2, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
one=J(rows(etht1),1,1)
tt    = (etht2:*t):^one
tt0   = (etht2:*t0):^one
pi = (etht1:/(one + etht1))
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(t0); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (normalden(ln(tt)):*one:/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010802_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010802_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, etht2, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
etht2 = exp(tht2)
one=J(rows(etht1),1,1)
tt    = (etht2:*t):^one
tt0   = (etht2:*t0):^one
pi = exp(-1:*etht1)
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(t0); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (normalden(ln(tt)):*one:/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

*program define PCM010803_lf
version 13.0
mata: mata set matastrict on
mata:
void PCM010803_lf(transmorphic scalar ML, 
real rowvector b,
real colvector lnf)
{
    real colvector tht1, tht2, t, d, t0, lc  
    real colvector etht1, tt, tt0, pi, k, k0, dk
    real scalar i
    real colvector one
	
	tht1 = moptimize_util_xb(ML, b, 1)
	tht2 = moptimize_util_xb(ML, b, 2)
	t    = moptimize_util_depvar(ML, 1)
	d    = moptimize_util_depvar(ML, 2)
	t0   = moptimize_util_depvar(ML, 3)
	lc   = moptimize_util_depvar(ML, 4)

etht1 = exp(tht1)
one=J(rows(etht1),1,1)
tt    = (tht2:*t):^one
tt0   = (tht2:*t0):^one
pi = tht1
k  = normal(ln(tt))
k0 = normal(ln(tt0))
for(i=1; i<=rows(t0); i++) {
	if (tt0[i]==0) {
	k0[i] = 0
	}
}
dk = (normalden(ln(tt)):*one:/ t)

lnf=J(rows(d),1,0)
for(i=1; i<=rows(d); i++) {
     if (d[i]==1 & lc[i]==0) {
lnf[i] = (ln(-1:*ln(pi[i]))+k[i]:*ln(pi[i])+ln(dk[i]))-(k0[i]*ln(pi[i])) 
}
else if (d[i]==0 & lc[i]==0) {
lnf[i] = (k[i]:*ln(pi[i]))-(k0[i]:*ln(pi[i])) 
}
else if (d[i]==1 & lc[i]==1) {
lnf[i] = (ln((pi[i]:^k0[i])-(pi[i]:^k[i])))-(k0[i]:*ln(pi[i]))  
}
}
}
end

