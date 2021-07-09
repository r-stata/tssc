*! qll  1.0.0  CFBaum 19jul2007  
*! Elliott-Muller efficient test for general persistence in time variation in
*! regression coefficients (Rev Ec Stud  (2006) 73, 907-940)

program qll, rclass
	version 9.2

// syntax: depvar xvarlist  [ (zvarlist) ]	
// where xvar coefficients potentially time varying 
// and zvar coefficients assumed to be fixed

	syntax [anything(name=0)] [if] [in]  [, RLAG(integer 0)]

	gettoken y 0 : 0
	while "`0'" ~= "" {
		gettoken next 0 : 0, match(paren)
		if "`paren'"=="(" {
				local z "`z' `next'"
			}
			else {
				local x "`x' `next'"
			}				
	}

// ensure tsset, onepanel	
    marksample touse
        _ts timevar panelvar if `touse', sort onepanel
    markout `touse' `timevar'
	
//	tempvar iota
	tempname nameq namecv
	scalar `nameq' = .
	matrix `namecv' = J(3,1,.)

// handle ts ops 
	tsrevar `y'
	local depvar `r(varlist)'
// should have a noconstant option?
	tsrevar `x'
	local xvar0 `r(varlist)' 
	tsrevar `z'
	local zvar `r(varlist)'

	markout `touse' `depvar' `xvar0' `zvar'
//	qui g `iota' = 1 if `touse'
// do not include constant in xvar
	local xvar "`xvar0'" //  `iota'"
	
	mata: qll("`depvar'","`xvar'","`zvar'",`rlag',"`touse'","`nameq'","`namecv'")

//  di in r "qval is " `nameq'	
	qui count if `touse'
	matrix rownames `namecv' = 10pc 5pc 1pc
	matrix colnames `namecv' = critVal

	qui tsset
	local tfmt `r(tsfmt)'
	su `timevar' if `touse', meanonly
	local tmin = string(`r(min)',"`tfmt'")
	local tmax = string(`r(max)',"`tfmt'")

	di as res _n  "Elliott-M{c u:}ller qLL test statistic" as txt " for time varying coefficients"
	di as txt "in the model of " as res "`y'" as txt ", `tmin' - `tmax'"
	di as txt     "Allowing for time variation in `kvarying' regressors"
	di     "H0: all regression coefficients fixed over the sample period (N = `r(N)')"
	
	di _n "Test stat." _col(15) "1% Crit.Val." _col(30) "5% Crit.Val." _col(45) "10% Crit.Val."
	di %9.3f `nameq' _col(18) `namecv'[3,1] _col(33) `namecv'[2,1] _col(48) `namecv'[1,1]

	if "`lags'" ~= "" & `rlag'<0 {
		di _n "Long-run variance computed with `lags' lags chosen by BIC."
		return local biclags "`lags'"
	}
	else if `rlag' > 0 {
		di _n "Long-run variance computed with `lags' lags."
		return local rlag "`rlag'"
	}
	
	return local cmdname "qll"
	return local N `r(N)'
	return local tmin `tmin'
    return local tmax `tmax'
	return local depvar "`y'"
	return local kvarying "`kvarying'"
	return local xvar "`x'"
	return local zvar "`z'"
	return scalar qll = `nameq'
	return matrix cvmat `namecv'

	end

version 9.2	
mata:
void qll(string scalar yvar,
		string scalar xvar,
		string scalar zvar,
		real scalar rlag,
		string scalar touse,
		string scalar nameq,
		string scalar namecv)
{
	string rowvector vars
	string scalar v
	real colvector y
	real matrix cvmat
	real matrix X, Z, Xe, u, w
	real scalar Q, n, k
	
	cvmat=(-7.14,-12.80,-18.07,-23.37,-28.55,-33.45,-38.49,-43.59,-48.78,-53.38 \
	       -8.36,-14.32,-19.84,-25.28,-30.6,-35.74,-40.80,-46.18,-51.1,-56.14 \
	       -11.05,-17.57,-23.42,-29.18,-35.09,-40.24,-45.85,-51.18,-56.46,-61.77)

	vars=tokens(yvar)
	v = vars[|1,.|]
	st_view(y,.,v,touse)

	vars=tokens(xvar)
	v = vars[|1,.|]
	st_view(X,.,v,touse)
	
	q = X	
	n = rows(X)
	k = cols(X)

	if (zvar ~= "") {
		vars=tokens(zvar)
		v = vars[|1,.|]
		st_view(Z,.,v,touse)
		if (cols(Z)) {
			q = X, Z
		}
	}

// step 1
	ehat = y - q*invsym(quadcross(q,q))*q'*y

// step 2
	Xe = X :* ehat
	if (rlag==0) {
// robust estimator of VCE
		vx = quadcross(Xe,Xe) :/n
	}
	else {
		vx = s0(Xe,1,n,rlag,1)
	}

// step 3: need general inverse, and transpose of result	
	u = Xe*luinv(cholesky(vx))'

// step 4
	w = u
	r = 1-10/n
 
 	du = u[1,.] \ ( u[|(2,1)\(n,k)|] - u[|(1,1)\((n-1),k)|] )
 	for(i=2;i<=n;i++) {
 		w[i,.] = w[(i-1),.] :* r + du[i,.]
	}

// step 5
	xr = r :^ (1::n)
	sra = 0
	for(i=1;i<=k;i++){
		sra = sra + quadcross(w[.,i],w[.,i]) - w[.,i]' *xr*invsym(quadcross(xr,xr))*xr' * w[.,i]
	}

// step 6
	qval = r*sra - trace(u',u)
// trap for k > 10
	cv = (.\.\.)
	if (k <= 10) {
		cv = cvmat[.,k]
	}
// return q (scalar), cv (colvector) 	
	st_numscalar(nameq,qval)
	st_replacematrix(namecv,cv)	
	st_local("kvarying",strofreal(k))
}


real matrix s0(real matrix y,
               real scalar nfirst,
               real scalar nlast,
               real scalar k,
               real scalar fdet)
               
// fdet should be set to 1 to conform with MATLAB routine

{
	real scalar n,p,maxlag,nf,nl
	real matrix bic

	n = rows(y)
	p = cols(y)
	if (k<0) {
		maxlag = abs(k)
// select lag length using BIC
		nf = nfirst + maxlag + 1
		nl = nlast
		bic = J(maxlag+1,1,0)

		for(nlag=0;nlag<=maxlag;nlag++) {
			if (fdet==1) {
				xa = J(nl-nf+1,1,1)
			} 
			else {
				xa = J(nl-nf+1,1,1),(1::nl-nf+1)
			}
			if (nlag>0) {
				for(i=1;i<=nlag;i++) {
					xa9 = y[nf-i..nl-i,1..p]
					xa = xa,xa9
				}
			}

			amat=invsym(quadcross(xa,xa))*xa'*y[nf..nl,1..p]
			res = y[nf..nl,1..p]-xa*amat
// length(xa) -> rows(xa)
			gtt = log(rows(xa))/rows(xa)
			bic[nlag+1,1] = log(det(quadcross(res,res)/rows(xa))) + (2 + p*nlag)*gtt
		}
		psel = minindc(bic)-1
	}
	else {
// lag length specified by user
		psel = k
	}
	
// do the VAR with psel lags
	nf = nfirst+psel
	nl = nlast
// why 2, if fdet is supposed to be 0/1?
	if (fdet < 2) {
		xa = J(nl-nf+1,1,1)
	} 
	else {
		xa = J(nl-nf+1,1,1),(1::nl-nf+1)
	}

	if (psel > 0) {
		for(i=1;i<=psel;i++) {
			xa9 = y[nf-i..nl-i,1..p]
			xa = xa,xa9
		}
	}
	if(psel+fdet==0) {
		res = y
		sig = quadcross(res,res)/rows(res)
	}
	else {
		xxi = invsym(quadcross(xa,xa))
		amat = xxi*xa'*y[nf..nl,1..p]
		res = y[nf..nl,1..p]-xa*amat
	}
	
// compute spectral density
	sig = quadcross(res,res)/rows(res)
	a1 = I(p)
	if (psel>0) {
		if (fdet==1) {
			amat = amat[2..rows(amat),1..p]
		}
		else if (fdet==2) {
			amat = amat[3..rows(amat),1..p]
		}

		for(im=1;im<=psel;im++) {
			a1=a1-amat[p*(im-1)+1..p*im,1..p]'
		}
	}
// end psel > 0
// don't need else a1=eye(p), as that was done above

// need general inverse 
	om = luinv(a1)*sig*(luinv(a1)')
	st_local("lags",strofreal(psel))
	return(om)
}

//	from serena-bai stuff

real vector minindc(real matrix x)
{
		ncols = cols(x)
		pos = J(ncols,1,0)
		minv = colmin(x)
		for(i=1;i<=ncols;i++) {		
			pos[i]= mm_posof(x[.,i],minv[i])
		}
		return(pos)
}
end

/*

Original MATLAB code from Graham Elliott (qll(), s0())

% program to compute Elliott and Mueller break test procedure qLL

function [q,cv] = qll(y,x,z,rlag);

zf=length(z);
[n,k]=size(x);
if zf>1;
    q=[x z];
else;
    q=x;
end;

% obtain critical value for the test
cvmat=[-8.36 ; -14.32 ; -19.84 ; -25.28 ; -30.6 ; -35.74 ; -40.80 ; -46.18
        ; -51.1 ; -56.14];


% step 1
ehat=y-q*inv(q'*q)*q'*y;

% step 2
xe=x;
for i=1:k;
xe(:,i)=x(:,i).*ehat;
end;

if rlag==0;
    vx=(xe'*xe)/n;
else;
    [vx] = s0(xe,1,n,rlag,1);
end;

% step 3
u=xe*inv(chol(vx));

% step 4
w=u;
r=eye(k)*(1-10/n);
du=[u(1,1:k);u(2:n,1:k)-u(1:n-1,1:k)];
for i=2:n;
    w(i,1:k)=w(i-1,1:k)*r+du(i,1:k);
end;
    
% step 5
xr=r(1,1).^((1:n)');
sra=0;
for i=1:k;
    sra=sra+w(1:n,i)'*w(1:n,i)-w(1:n,i)'*xr*inv(xr'*xr)*xr'*w(1:n,i);
end;

% step 6
q=r(1,1)*sra-sum(diag(u'*u));
cv=cvmat(k,1);

********************************
% GE mar95 proc to estimate the spectral density matrix of data using
%   the AR method.
%

function [om] = s0(y,nfirst,nlast,k,fdet);

%     Inputs
%       y       :   data
%       nfirst  :   first ob to use
%       nlast   :   last ob to use
%       k       :   Lag length (negative for automatic selection
%       fdet    :   0=no constant, 1=constant
%
%       Output
%
%       om      :   nxn matrix of the spectral density at freq zero
%                   (scaled by 2*pi)


n x n,   or (nk+1) x n ?


%    This proc returns (nk+1) by n matrix of coefficients and se's
%     The first row is the constant, then the next nxn block is the
%     coefficients for L=1 etc 

[n,p]=size(y);
if k<0;
 maxlag=abs(k);
%  select lag length using BIC lag length selector 
nf=nfirst+maxlag+1;
nl=nlast;

bic=zeros(maxlag+1,1);
for nlag=0:maxlag;

if fdet==1; 
 xa=ones(nl-nf+1,1);
 else;
 xa=[ones(nl-nf+1,1) (1:nl-nf+1)'];
end;

if nlag>0;
 for i=1:nlag;
 xa9=y(nf-i:nl-i,1:p);
 xa=[xa xa9];
end;

end;

amat=inv(xa'*xa)*xa'*y(nf:nl,1:p);
res=y(nf:nl,1:p)-xa*amat;
gtt=ln(length(xa))/(length(xa));
bic(nlag+1,1)=ln(det((res'*res)/(length(xa))))+(2+p*nlag)*gtt;


end;

psel=minindc(bic)-1; 


else;
psel=k;
end;


%  do the VAR with psel lags 

nf=nfirst+psel;
nl=nlast;

if fdet<2; 
  xa=ones(nl-nf+1,1);  
  else;
  xa=[ones(nl-nf+1,1) (1:nl-nf+1)']; 
end;
if psel>0;
for i=1:psel;
 xa9=y(nf-i:nl-i,1:p);
 xa=[xa xa9];
end;

end;

if (psel+fdet)==0;
 res=y;
 sig=(res'*res)/(length(res));

else;

xxi=inv(xa'*xa);
amat=xxi*xa'*y(nf:nl,1:p);
res=y(nf:nl,1:p)-xa*amat;

end;

% compute spectral density  
sig=(res'*res)/(length(res));
a1=eye(p);
if psel>0;
if fdet==1; 
 amat=amat(2:length(amat),1:p);
 elseif fdet==2; 
 amat=amat(3:length(amat),1:p);
end;

for im=1:psel;

 a1=a1-amat(p*(im-1)+1:p*im,1:p)';
end;
else;
a1=eye(p);
end;

om=inv(a1)*sig*(inv(a1)');

* Utility functions from Bai-Ng PANIC library

function pos=minindc(x);
ncols=size(x,2);
nrows=size(x,1);
pos=zeros(ncols,1);
seq=seqa(1,1,nrows);
for i=1:ncols;
dum=min(x(:,i));
dum1= seq .* ( (x(:,i)-dum) ==0);
pos(i)=sum(dum1);
end;

function x=seqa(a,b,c);
x=linspace(a,(a+(c-1)*b),c)';

*/
    