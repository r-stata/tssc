*! Nikolas Mittag 31mar2012

cap program drop twfe
program define twfe, eclass
version 10.0
if replay() {
	if "`e(cmd)'"!="twfe" error 301
	syntax, [EForm(passthru) Level(passthru) NOTABle NOHEader] *
	_get_diopts diopts, `options'
	local diopts "`diopts' `eform' `level'"
}
else {
	syntax varlist(min=1 numeric) [if] [in], IDs(varlist numeric min=2 max=2) [Matcheffect] [MAXit(integer 500)] [Cluster(string)] [Verbose(integer 1)] [Tol(real 1.0e-7)] [replace] [eform(passthru)] [level(passthru)] [NOTABle] [NOHEader] *

	_get_diopts diopts, `options'
	local diopts "`diopts' `eform' `level'"
	marksample touse
	qui {
		if "`replace'"=="" {
			gen touse=`touse'
			tempfile data
			save `data'
		}
	
	keep if `touse'
	gettoken dep cov : varlist
	local id1=word("`ids'",1)
	local id2=word("`ids'",2)
	}

	if "`cluster'"=="" local cluster "none"
	if ("`cluster'"=="het" | "`cluster'"=="none") {
		keep `dep' `cov' `id1' `id2'
	}
	else {
		keep `dep' `cov' `id1' `id2' `cluster'
	}

	sort `id1' `id2'

	if "`matcheffect'"!=""{
		mata: matcheff("`dep'", "`cov'", "`id1'", "`id2'", "`cluster'", `maxit', `tol', `verbose')
		ereturn local title "Linear Model with Match Effects"
		ereturn local model "match"
		sca def nt=`e(nm)'-1
	}
	else {
		mata: twfe("`dep'", "`cov'", "`id1'", "`id2'", "`cluster'", `maxit', `tol', `verbose')
		ereturn local title "Linear Model with Two-Way Fixed Effects"
		ereturn local model "twfe"
		sca def nt=`e(n1)'+`e(n2)'-1
	}
	ereturn local depvar "`dep'"
	ereturn local clustvar "`cluster'"


	if "`replace'"=="" {
		qui: merge `id1' `id2' using `data', sort uniqmaster
		ereturn repost, esample(touse)
		drop _merge
	}
	ereturn local predict "twfe_p"
	ereturn local cmd "twfe"
}

if "`noheader'"=="" {
	di as gr `"`e(title)'"' _col(56) `"Number of obs ="' as ye %8.0f `e(N)'
	di as gr _col(56) `"F("' as gr %3.0f `e(df_m)' as gr `","' as gr %6.0f `e(df_e)' as gr `") ="' as ye %8.2f `e(F)'
	di as gr _col(56) `"Prob > F      ="'  as ye %8.4f e(pval)
	di as gr _col(56) `"R-squared     ="'  as ye %8.4f e(r2)
	di as gr _col(56) `"Adj R-squared ="'  as ye %8.4f e(ar2)
	di as gr _col(56) `"Root MSE      = "' as ye %7.0g e(rmse)
}

if "`notable'"=="" { 
	ereturn display, `diopts' plus
	
	di as yellow "F-Test" as gr _col(13) " {c |}"
	if `e(ncov)'>0 di in smcl as gr "Coefficients" " {c |}"  `"F("' as gr %3.0f `e(ncov)' as gr `","' as gr %6.0f `e(df_e)' as gr `") "' _col(40) `"= "' as ye %8.2f `e(F_x)' _skip(5) `e(p_x)'
	di in smcl as gr "All FEs" _col(13) " {c |}"  `"F("' as gr %3.0f nt as gr `","' as gr %6.0f `e(df_e)' as gr `") "' _col(40) `"= "' as ye %8.2f `e(F_fe)' _skip(5) `e(p_fe)'
	if "`e(model)'"=="twfe" {
		di in smcl as gr "FE " abbrev(`"`e(unit1)'"',9) _col(13) " {c |}"  `"F("' as gr %3.0f `e(n1)' as gr `","' as gr %6.0f `e(df_e)' as gr `") "' _col(40) `"= "' as ye %8.2f `e(F_fe1)' _skip(5) `e(p_fe1)'
		di in smcl as gr "FE " abbrev(`"`e(unit2)'"',9) _col(13) " {c |}"  `"F("' as gr %3.0f `e(n2)' as gr `","' as gr %6.0f `e(df_e)' as gr `") "' _col(40) `"= "' as ye %8.2f `e(F_fe2)' _skip(5) `e(p_fe2)'
	}
	di in smcl as gr "{hline 78}"
}
end


mata
void matcheff(string scalar dep, string rowvector cov, string scalar id1, string scalar id2, string scalar clust, real scalar maxit, real scalar tol, real scalar verbose) {
/*declare variables*/
real scalar no,ns,ni,nf,rssall,r2,tss,rss,i,j,rmse,dfm,dfe,fx,fall,ftot,adjr2,ncov
string scalar id1l, id2l,z
real matrix oids,K,L,M,varmat,sm,x,y,beta
real colvector a,b,c,sv,se,iv,ie,fv,fm,fe,ffe,ife,nomov,res,im,iid,fid,mid



/*create views*/
st_view(y=.,.,dep)
st_view(x=.,.,tokens(cov))
st_view(iid=.,.,id1)
st_view(fid=.,.,id2)
id1l=st_varlabel(id1)
if (id1l=="") {
id1l=id1 
} ;
id2l=st_varlabel(id2)
if (id2l=="") {
id2l=id2 
} ;
j=0
if ((clust!="het" & clust!="none")) {
	clust=tokens(clust)
		if ((clust==(id1,id2) | clust==(id2,id1))) {
		st_view(clust,.,(id1, id2))
		j=1
	}
	else {
		st_view(clust,.,clust)
	}
} ;

/*get basic info*/
no=rows(x)
stata("reg "+dep+" "+cov,1)
rssall=st_numscalar("e(rss)")
tss=st_numscalar("e(mss)")+rssall

/*create ids that are consecutive integers*/
/*save original ids (note: can write these to disc to save memory in really large applications)*/
oids=(iid,fid)
iid[.]=sign((iid[|2\no|]\(iid[no]+1))-iid)
maxindex(iid,1,ie=.,.)
iid[.]=runningsum((1\iid[|1\no-1|]))
ni=max(iid)
iv=ie-(0\ie[|1\(ni-1)|])
stata("sort "+id2)
fid[.]=sign((fid[|2\no|]\(fid[no]+1))-fid)
maxindex(fid,1,fe=.,.)
fid[.]=runningsum((1\fid[|1\no-1|]))
nf=max(fid)
fv=fe:-(0\fe[|1\(nf-1)|])
if (nf>ni) {
	swap(iid,fid)
	swap(ni,nf)
	swap(id1l,id2l)
	swap(id1,id2)
	swap(iv,fv)
	swap(ie,fe)
	oids=(oids[,2],oids[,1])
	_sort(oids,(1,2))
	st_local("id1",id1)
	st_local("id2",id2)
} ;

stata("sort "+id1+" "+id2)

/*get and subtract spell means, length and indices (quad precision may not be necessary if values are not too big)*/
mid=abs(sign((iid[|2\no|]\(iid[no]+1))-iid+abs(fid-(fid[|2\no|]\(fid[no]+1)))))
maxindex(mid,1,se=.,.)
mid=runningsum((1\mid[|1\(no-1)|]))
ns=max(mid)
oids=(oids[se,],mid[se])
sv=se-(0\se[|1\(ns-1)|])
sm=J(ns,cols(x)+1,0)
sm[,1]=quadrunningsum(y)[se]
sm[,1]=(sm[,1]-(0\sm[|1,1\ns-1,1|])):/sv
y[1..no]=y-sm[mid,1]

ncov=cols(x)
if (ncov>0) {
	for(i=1;i<=ncov;i++) {
		st_view(a=.,.,tokens(cov)[i])
		sm[,i+1]=quadrunningsum(a)[se]
		sm[,i+1]=(sm[,i+1]-(0\sm[|1,i+1\ns-1,i+1|])):/sv
	}
	a=.
	x[.,.]=x-sm[mid,2..cols(sm)]
	
	/*run regression*/
	stata("reg "+dep+" "+cov,1)
	/*store required info*/
	beta=st_matrix("e(b)")[1..cols(x)]
	if (clust=="none") {
		varmat=st_matrix("e(V)")
		varmat=varmat[|1,1\cols(x),cols(x)|]:*((no-ncov-1)/(no-ncov-ns))
	}
	else {
		stata("tempvar res")
		z=st_local("res")
		stata("qui: predict "+z+" ,resid")
		res=st_data(.,st_local("res"))
		stata("drop "+ z)
		if (clust=="het") varmat=clvar(res,x,1,ncov+ns)
		if (cols(clust)==1) varmat=clvar(res,x,clust,ncov+ns)
		if (cols(clust)==2 & j==0) varmat=clvar(res,x,clust[,1],clust[,2],ncov+ns)
		if (cols(clust)==2 & j==1) varmat=clvar(res,x,clust[,1],clust[,2],mid,ncov+ns)
	}
	rss=st_numscalar("e(rss)")
	r2=1-rss/tss

	/*adjust y, spell means*/
	y[.]=y+sm[mid,1]-(x+sm[mid,2..cols(sm)])*beta'
	sm=sm[,1]-sm[,2..cols(sm)]*beta'

} 
else {
	stata("reg "+dep,1)
	rss=st_numscalar("e(rss)")
	r2=1-rss/tss
	y[.]=y+sm[mid,1]
}

/*get firm and individual means*/
stata("sort "+id2)
fm=quadrunningsum(y)[fe]
fm=(fm-(0\fm[|1\nf-1|])):/fv
stata("sort "+id1+" "+id2)
im=quadrunningsum(y)[ie]
im=(im-(0\im[|1\ni-1|])):/iv
st_dropvar((tokens(cov), dep))
x=y=fe=ie=mid=.
st_view(iid=.,.,id1)
st_view(fid=.,.,id2)


/*set up matrices for cg (note: can save memory by suming up summands after each step, but will be slower)*/
K=(iid[se],fid[se],sv)
/*set up matrix M*/
/*count number of spells for each individual*/
maxindex(K[,1]-(0\K[|1,1\ns-1,1|]),1,a=.,.)
a=(a[2..length(a)]\ns+1)-a
K=(K,iv[K[,1]],a[K[,1]])
/*summands of non-movers*/
M=select(K,K[,5]:==1)[.,1..4]
M=(M[,2],M[,2],M[,3]:^2:/M[.,4]:*(-1))
a=runningsum(J(nf,1,1))
M=(M\(a,a,fv))
/*summands of movers*/
j=max(K[,5])
for(i=2;i<=j;i++) {
	L=select(K,K[,5]:==i)[,1..4]
	if (length(L)!=0) {
		a=J(i-1,1,0)
		a=runningsum(J(rows(L),1,(1\a)))
		b=runningsum(J(i,1,1))
		b=J(rows(L),1,b)
		c=J(i^2-1,1,0)
		c=(c\i)
		c=J(rows(L)/i,1,c)
		c=(0\runningsum(c)[1..(length(c)-1)])
		b=b+c
		L=(L[a,2],L[b,2],L[a,3]:*L[b,3]:/L[a,4]:*(-1))
		M=(M\L)
	} ;
}
a=b=c=L=j=i=.
/*sum elements with same coordinates*/
_sort(M,(1,2))
maxindex(sign((M[|2,1\rows(M),1|]\(nf+1))-M[,1]+abs((M[|2,2\rows(M),2|]\(nf+1))-M[,2])),1,a=.,.)
M[,3]=quadrunningsum(M[,3])
M=(M[a,(1,2)],M[a,3]-(0\M[a[1..(length(a)-1)],3]))
/*get vector y*/
_sort(K,2)
maxindex((K[|2,2\ns,2|]\(nf+1))-K[,2],1,a=.,.)
y=quadrunningsum(K[,3]:*im[K[,1]])[a]
y=y-(0\y[1..length(y)-1])
y=fm:*fv-y
fv=fm=.

/*get rid of firms without movers*/ 
M=select(M,M[,3]:!=0)
a=uniqrows(M[,1])
if (length(a)<nf) {
	c=J(nf,1,0)
	c[a]=a
	minindex(c,1,b=.,.)
	/*store list of firms without movers in macro*/
	nomov=b
	/*assign consecutiveintegers to firms still in M*/
	c[a]=runningsum(J(length(a),1,1))
	M[,1]=c[M[,1]]
	M[,2]=c[M[,2]]
	y=y[a]
	b=c=.
} 
else {
	nomov=0
}
/*launch cga*/
ffe=J(nf,1,0)
b=sparsecga(y,M,maxit,tol,verbose)
if (length(b)==0) {
	exit(error(3360))
} ;
ffe[a]=b
M=y=a=maxit=verbose=.
_sort(K,1)
maxindex((K[|2,1\ns,1|]\(ni+1))-K[,1],1,b=.,.)
ife=quadrunningsum(K[,3]:*ffe[K[,2]]:/iv[K[,1]])[b]
ife=im-ife+(0\ife[1..length(ife)-1])
K=b=L=iv=im=.

/*store fixed effects,ids*/
M=(oids,ife[iid[se]],ffe[fid[se]],sm-ffe[fid[se]]-ife[iid[se]],sv)
stata("clear")
ffe=ife=se=iid=fid=oids=sm=sv=.
a=st_addvar("double",(id1,id2,"matchid","fe1","fe2","matchef","mlength"))
st_varlabel(id1,id1l)
st_varlabel(id2,id2l)
st_varlabel("matchid","Match ID")
st_varlabel("fe1","Fixed Effect for "+ id1l)
st_varlabel("fe2","Fixed Effect for "+ id2l)
st_varlabel("matchef","Match Fixed Effect")
st_varlabel("mlength","Duration of Match (number of obs)")
st_addobs(ns,1)
st_store(.,a,M)
M=a=.
id1l=id2l=""

/*store macros*/
rmse=sqrt(rss/no)
dfm=ncov+ns
dfe=no-dfm-1
fall=((rssall-rss)/(ns-1))/(rss/(dfe))
fx=(beta*cholsolve(varmat,I(ncov))*beta'):/ncov
ftot=(tss-rss)/(dfm-1)/(rss/(dfe))
adjr2=1 - (1-r2)*(no-1)/(dfe)
if (ncov>0) {
	st_matrix("b",beta)
	st_matrix("V",varmat)
	stata("matrix rown b=y1")
	stata("matrix coln b="+cov)
	stata("matrix rown V="+cov)
	stata("matrix coln V="+cov)
	stata("ereturn post b V, dep("+dep+") obs("+strofreal(no)+") dof("+strofreal(dfe)+")")
	st_numscalar("e(F_x)",fx)
	st_numscalar("e(p_x)",Ftail(ncov,dfe,fx))
} 
else {
	st_numscalar("e(df_r)",J(0,0,.))
	st_numscalar("e(r2_a)",J(0,0,.))
	st_numscalar("e(ll)",J(0,0,.))
	st_numscalar("e(ll_0)",J(0,0,.))
	st_numscalar("e(rank)",J(0,0,.))
	st_global("e(cmdline)","")
	st_global("e(marginsok)","")
	st_global("e(vce)","")
	st_global("e(estat_cmd)","")
}
st_numscalar("e(N)",no)
st_numscalar("e(mss)",tss-rss)
st_numscalar("e(rss)",rss)
st_numscalar("e(rmse)",rmse)
st_numscalar("e(df_m)",dfm)
st_numscalar("e(df_e)",dfe)
st_numscalar("e(nm)",ns)
st_numscalar("e(n1)",ni)
st_numscalar("e(n2)",nf)
st_numscalar("e(r2)",r2)
st_numscalar("e(ar2)",adjr2)
st_numscalar("e(F_fe)",fall)
st_numscalar("e(p_fe)",Ftail(ns-1,dfe,fall))
st_numscalar("e(F)",ftot)
st_numscalar("e(pval)",Ftail(dfm-1,dfe,ftot))
st_numscalar("e(ncov)",ncov)
st_matrix("e(nomov)",nomov)
st_global("e(unit1)",id1)
st_global("e(unit2)",id2)
}




void twfe(string scalar dep, string rowvector cov, string scalar id1, string scalar id2, string scalar clust, real scalar maxit, real scalar tol, real scalar verbose) {
/*declare variables*/
real scalar no,ni,nf,ns,rssall,rssfe1,rssfe2,r2,tss,rss,i,j,rmse,dfm,dfe,fx,ffe1,ffe2,ftot,fall,adjr2,ncov
string scalar id1l, id2l,z
real matrix oids,K,L,M,varmat,x,y,beta,fm,im
real colvector a,b,c,d,e,iv,ie,fv,fe,ffe,ife,nomov,res,iid,fid,se,sv



/*create views*/
st_view(y=.,.,dep)
st_view(x=.,.,tokens(cov))
st_view(iid=.,.,id1)
st_view(fid=.,.,id2)
id1l=st_varlabel(id1)
if (id1l=="") {
	id1l=id1 
} ;
id2l=st_varlabel(id2)
if (id2l=="") {
	id2l=id2 
} ;
if ((clust!="het" & clust!="none")) {
	clust=tokens(clust)
	if ((clust==(id1,id2) | clust==(id2,id1))) {
		st_view(clust,.,(id1, id2))
	}
	else {
		st_view(clust,.,clust)
	}
} ;

/*get basic info*/
no=rows(x)
ncov=cols(x)
stata("reg "+dep+" "+cov,1)
rssall=st_numscalar("e(rss)")
tss=st_numscalar("e(mss)")+rssall

/*create ids that are consecutive integers*/
/*save original ids (note: can write these to disc to save memory in really large applications)*/
oids=(iid,fid)
iid[.]=sign((iid[|2\no|]\(iid[no]+1))-iid)
maxindex(iid,1,ie=.,.)
iid[.]=runningsum((1\iid[|1\no-1|]))
ni=max(iid)
iv=ie-(0\ie[|1\(ni-1)|])
stata("sort "+id2)
fid[.]=sign((fid[|2\no|]\(fid[no]+1))-fid)
maxindex(fid,1,fe=.,.)
fid[.]=runningsum((1\fid[|1\no-1|]))
nf=max(fid)
fv=fe:-(0\fe[|1\(nf-1)|])
if (nf>ni) {
	swap(iid,fid)
	swap(ni,nf)
	swap(id1l,id2l)
	swap(id1,id2)
	swap(iv,fv)
	swap(ie,fe)
	oids=(oids[,2],oids[,1])
	_sort(oids,(1,2))
	st_local("id1",id1)
	st_local("id2",id2)
} ;

stata("sort "+id1+" "+id2)

/*get firm and individual means*/
fm=J(nf,ncov+1,0)
stata("sort "+id2)
for(i=1;i<=ncov+1;i++) {
	st_view(a=.,.,(dep,tokens(cov))[i])
	fm[,i]=quadrunningsum(a)[fe]
	fm[,i]=(fm[,i]-(0\fm[|1,i\nf-1,i|])):/fv
}
im=J(ni,ncov+1,0)
stata("sort "+id1+" "+id2)
for(i=1;i<=ncov+1;i++) {
	st_view(a=.,.,(dep,tokens(cov))[i])
	im[,i]=quadrunningsum(a)[ie]
	im[,i]=(im[,i]-(0\im[|1,i\ni-1,i|])):/iv
}

/*get spell ends and lengths*/
maxindex(abs(sign((iid[|2\no|]\(iid[no]+1))-iid+abs(fid-(fid[|2\no|]\(fid[no]+1))))),1,se=.,.)
ns=length(se)
oids=(oids[se,])
sv=se-(0\se[|1\(ns-1)|])

/*get residuals for ftests*/
if (ncov>0) a=y-fm[fid,1]-cross((x:-fm[fid,2..(ncov+1)])',(cholsolve(cross(x:-fm[fid,2..(ncov+1)],x:-fm[fid,2..(ncov+1)]),I(ncov))*cross(x:-fm[fid,2..(ncov+1)],y-fm[fid,1])))
else a=y-fm[fid,1]
rssfe1=cross(a,a)
if (ncov>0) a=y-im[iid,1]-cross((x:-fm[fid,2..(ncov+1)])',(cholsolve(cross(x:-im[iid,2..(ncov+1)],x:-im[iid,2..(ncov+1)]),I(ncov))*cross(x:-im[iid,2..(ncov+1)],y-im[iid,1])))
else a=y-fm[fid,1]
rssfe2=cross(a,a)
a=.

/*apply WK transformation*/
/*set up matrices for cg (note: can save memory by suming up summands after each step, but will be slower)*/
K=(iid[se],fid[se],sv)
/*set up matrix M*/
/*count number of spells for each individual*/
maxindex(K[,1]-(0\K[|1,1\ns-1,1|]),1,a=.,.)
a=(a[2..length(a)]\ns+1)-a
K=(K,iv[K[,1]],a[K[,1]])
/*summands of non-movers*/
M=select(K,K[,5]:==1)[.,1..4]
M=(M[,2],M[,2],M[,3]:^2:/M[.,4]:*(-1))
a=runningsum(J(nf,1,1))
M=(M\(a,a,fv))
/*summands of movers*/
j=max(K[,5])
for(i=2;i<=j;i++) {
	L=select(K,K[,5]:==i)[,1..4]
	if (length(L)!=0) {
		a=J(i-1,1,0)
		a=runningsum(J(rows(L),1,(1\a)))
		b=runningsum(J(i,1,1))
		b=J(rows(L),1,b)
		c=J(i^2-1,1,0)
		c=(c\i)
		c=J(rows(L)/i,1,c)
		c=(0\runningsum(c)[1..length(c)-1])
		b=b+c
		L=(L[a,2],L[b,2],L[a,3]:*L[b,3]:/L[a,4]:*(-1))
		M=(M\L)
	} ;
}
a=b=c=L=j=i=.
/*sum elements with same coordinates*/
_sort(M,(1,2))
maxindex(sign((M[|2,1\rows(M),1|]\(nf+1))-M[,1]+abs((M[|2,2\rows(M),2|]\(nf+1))-M[,2])),1,a=.,.)
M[,3]=quadrunningsum(M[,3])
M=(M[a,(1,2)],M[a,3]-(0\M[a[1..(length(a)-1)],3]))
/*get rid of firms without movers*/ 
M=select(M,M[,3]:!=0)
a=uniqrows(M[,1])
if (length(a)<nf) {
	c=J(nf,1,0)
	c[a]=a
	minindex(c,1,b=.,.)
	/*store list of firms without movers in macro*/
	nomov=b
	/*assign consecutiveintegers to firms still in M*/
	c[a]=runningsum(J(length(a),1,1))
	M[,1]=c[M[,1]]
	M[,2]=c[M[,2]]
	b=c=.
} 
else {
	nomov=0
}

/*run cga for every variable*/
maxindex((K[|2,1\ns,1|]\(ni+1))-K[,1],1,d=.,.)
_sort(K,2)
maxindex((K[|2,2\ns,2|]\(nf+1))-K[,2],1,c=.,.)
b=quadrunningsum(K[,3]:*im[K[,1],1])[c]
b=b-(0\b[1..length(b)-1])
b=fm[,1]:*fv-b
b=b[a]
e=J(nf,1,0)
printf("%s: ",dep)
b=sparsecga(b,M,maxit,tol,verbose)
if (length(b)==0) {
	exit(error(3360))
} ;

if (ncov>0) {
	e[a]=b
	_sort(K,1)
	b=quadrunningsum(K[,3]:*e[K[,2]]:/iv[K[,1]])[d]
	b=b-(0\b[1..length(b)-1])
	y[.]=y-im[iid,1]+b[iid]-e[fid]
	
	for(i=1;i<=ncov;i++) {
		_sort(K,2)
		b=quadrunningsum(K[,3]:*im[K[,1],i+1])[c]
		b=b-(0\b[1..(length(b)-1)])
		b=fm[,i+1]:*fv-b
		b=b[a]
		e=J(nf,1,0)
		printf("%s: ",tokens(cov)[i])
		b=sparsecga(b,M,maxit,tol,verbose)
		if (length(b)==0) {
			printf("Failure to converge occured for variable %s",tokens(cov)[i])
			exit(error(3360))
		} ;
		e[a]=b
		_sort(K,1)
		b=quadrunningsum(K[,3]:*e[K[,2]]:/iv[K[,1]])[d]
		b=b-(0\b[1..(length(b)-1)])
		x[,i]=x[,i]-im[iid,i+1]+b[iid]-e[fid]
	}
	b=e=.

	/*run regression*/
	stata("reg "+dep+" "+cov,1)
	/*store required info*/
	beta=st_matrix("e(b)")[1..cols(x)]
	if (clust=="none") {
		varmat=st_matrix("e(V)")
		varmat=varmat[|1,1\cols(x),cols(x)|]:*((no-ncov-1)/(no-ncov-ni-nf))
	}
	else {
		stata("tempvar res")
		z=st_local("res")
		stata("qui: predict "+z+" ,resid")
		res=st_data(.,st_local("res"))
		stata("drop "+ z)
		if (clust=="het") varmat=clvar(res,x,1,ncov+ni+nf)
		if (cols(clust)==1) varmat=clvar(res,x,clust,ncov+ni+nf)
		if (cols(clust)==2) varmat=clvar(res,x,clust[,1],clust[,2],ncov+ni+nf)
	}
	rss=st_numscalar("e(rss)")
	r2=1-rss/tss

	/*adjust y, spell means*/
	st_dropvar((tokens(cov), dep))
	x=y=fe=ie=.
	im=im[,1]-im[,2..cols(im)]*beta'
	fm=fm[,1]-fm[,2..cols(fm)]*beta'
	st_view(iid=.,.,id1)
	st_view(fid=.,.,id2)

	/*get fixed effects*/
	/*get vector y*/
	_sort(K,2)
	y=quadrunningsum(K[,3]:*im[K[,1]])[c]
	y=y-(0\y[1..length(y)-1])
	y=fm:*fv-y
	y=y[a]
	fv=fm=.
	/*launch cga*/
	ffe=J(nf,1,0)
	printf("%s: ",dep)
	b=sparsecga(y,M,maxit,tol,verbose)
	if (length(b)==0) {
		exit(error(3360))
	} ;
	/*end if (ncov>0)*/
} 
else {
	ffe=J(nf,1,0)
}

ffe[a]=b


if (ncov==0) {
	M=maxit=verbose=.
	_sort(K,1)
	ife=quadrunningsum(K[,3]:*ffe[K[,2]]:/iv[K[,1]])[d]
	ife=im-ife+(0\ife[1..length(ife)-1])
	st_view(iid=.,.,id1)
	st_view(fid=.,.,id2)
	y[.]=y-ife[iid]-ffe[fid]
	stata("reg "+dep,1)
	rss=st_numscalar("e(rss)")
	r2=1-rss/tss

	y=a=fv=fm=fe=ie=b=e=.
} 
else {
	M=y=a=maxit=verbose=.
	_sort(K,1)
	ife=quadrunningsum(K[,3]:*ffe[K[,2]]:/iv[K[,1]])[d]
	ife=im-ife+(0\ife[1..length(ife)-1])
}

K=b=L=iv=im=.

/*store fixed effects,ids*/
M=(oids,ife[iid[se]],ffe[fid[se]],sv)
stata("clear")
ffe=ife=se=iid=fid=oids=sv=.
a=st_addvar("double",(id1,id2,"fe1","fe2","mlength"))
st_varlabel(id1,id1l)
st_varlabel(id2,id2l)
st_varlabel("fe1","Fixed Effect for "+ id1l)
st_varlabel("fe2","Fixed Effect for "+ id2l)
st_varlabel("mlength","Duration of Match (number of obs)")
st_addobs(ns,1)
st_store(.,a,M)
M=a=.
id1l=id2l=""

/*store macros*/
rmse=sqrt(rss/no)
dfm=ncov+ni+nf
dfe=no-dfm-1
ffe1=((rssfe1-rss)/(ni-1))/(rss/(dfe))
ffe2=((rssfe2-rss)/(nf-1))/(rss/(dfe))
fall=((rssall-rss)/(ns-1))/(rss/(dfe))
fx=(beta*cholsolve(varmat,I(ncov))*beta'):/ncov
ftot=(tss-rss)/(dfm-1)/(rss/(dfe))
adjr2=1 - (1-r2)*(no-1)/(dfe)
st_matrix("b",beta)
st_matrix("V",varmat)
if (ncov>0) {
	stata("matrix rown b=y1")
	stata("matrix coln b="+cov)
	stata("matrix rown V="+cov)
	stata("matrix coln V="+cov)
	stata("ereturn post b V, dep("+dep+") obs("+strofreal(no)+") dof("+strofreal(dfe)+")")
	st_numscalar("e(F_x)",fx)
	st_numscalar("e(p_x)",Ftail(ncov,dfe,fx))
}
else {
	st_numscalar("e(df_r)",J(0,0,.))
	st_numscalar("e(r2_a)",J(0,0,.))
	st_numscalar("e(ll)",J(0,0,.))
	st_numscalar("e(ll_0)",J(0,0,.))
	st_numscalar("e(rank)",J(0,0,.))
	st_global("e(cmdline)","")
	st_global("e(marginsok)","")
	st_global("e(vce)","")
	st_global("e(estat_cmd)","")
}
st_numscalar("e(N)",no)
st_numscalar("e(mss)",tss-rss)
st_numscalar("e(rss)",rss)
st_numscalar("e(rmse)",rmse)
st_numscalar("e(df_m)",dfm)
st_numscalar("e(df_e)",dfe)
st_numscalar("e(n1)",ni)
st_numscalar("e(n2)",nf)
st_numscalar("e(r2)",r2)
st_numscalar("e(ar2)",adjr2)
st_numscalar("e(F_fe)",fall)
st_numscalar("e(F_fe1)",ffe1)
st_numscalar("e(F_fe2)",ffe2)
st_numscalar("e(p_fe)",Ftail(ni+nf-1,dfe,fall))
st_numscalar("e(p_fe1)",Ftail(ni,dfe,ffe1))
st_numscalar("e(p_fe2)",Ftail(nf,dfe,ffe2))
st_numscalar("e(F)",ftot)
st_numscalar("e(pval)",Ftail(dfm-1,dfe,ftot))
st_numscalar("e(ncov)",ncov)
st_matrix("e(nomov)",nomov)
st_global("e(unit1)",id1)
st_global("e(unit2)",id2)
}



/*auxilary functions*/
/*sparse conjugate gradient algorithm*/
real vector sparsecga(real vector y, real matrix M, real scalar maxit, real scalar tol, real scalar verbose) {
real scalar c,rso,rsn,i
real colvector x,r,p,mp,b
/*get indices of row ends of M*/
maxindex(sign((M[|2,1\rows(M),1|]\(max(M[,1])+1))-M[,1]),1,b=.,.)
/*note: could experiment with preconditioning, starting value*/
x=J(length(y),1,0)
r=p=y
rso=cross(r,r)
for(i=1;i<=maxit;i++) {
	mp=quadrunningsum(M[,3]:*p[M[,2]])[b]
	mp=mp-(0\mp[1..(length(mp)-1)])
	c=rso/cross(p,mp)
	x=x+p:*c
	r=r-mp:*c
	rsn=cross(r,r)
	if (rsn<=tol) {
		if (verbose>0) printf("Convergence reached after iteration %f with residual %f\n",i,rsn)
		return(x)
	} ;
	rsn=cross(r,r)
	p=r+p:*(rsn/rso)
	rso=rsn
	if (verbose==2) printf("Residual after iteration %f : %f \n",i,rsn)
}
printf("Did not converge in %f iterations. Residual: %f \n",maxit, rsn)
return(J(1,0,0))
}

/*clustered standard errors*/
real matrix clvar(real vector res, real matrix X, transmorphic vector cl1,| real vector cl2,real vector cl3,real scalar df) {
real scalar nclv,no,ncov,ncl,i,j,k
real matrix xx,xeex,covb
real colvector a,b

if (df==.) df=0
if (args()==3) nclv=1
if (args()==4 & length(cl2)==1) {
	df=cl2
	nclv=1
} 
else {
	if (args()==4) nclv=2
}
if (args()==5 & length(cl3)==1) {
	df=cl3
	nclv=2
} 
else {
	if (args()>=5) nclv=3
}
no=length(res)
ncov=cols(X)
xx=cholsolve(cross(X,X),I(ncov))
if (nclv==2) {
	a=order((cl1,cl2),(1,2))
	cl1[.]=cl1[a]
	cl2[.]=cl2[a]
	X[,]=X[a,]
	_collate(res,a)
	cl3=runningsum(sign(cl1[,1]-(0\cl1[|1,1\(no-1),1|])+abs(cl2[,1]-(0\cl2[|1,1\(no-1),1|]))))
	nclv=3
	a=invorder(a)
	cl1[.]=cl1[a]
	cl2[.]=cl2[a]
	cl3[.]=cl3[a]
	X[,]=X[a,]
	_collate(res,a)
};
if (length(cl1)==1) {
	covb=(no/(no-df))*xx*cross(X:*(res:^2),X)*xx
	return(covb)
}
else {
	xeex=J(ncov,ncov,0)
	a=order(cl1,1)
	cl1[.]=cl1[a]
	X[,]=X[a,]
	_collate(res,a)
	maxindex(sign((cl1[2..no]\(cl1[no]+1))-cl1),1,b=.,.)
	ncl=length(b)
	j=1
	for(i=1;i<=ncl;i++) {
		k=b[i]
		xeex=xeex+(ncl/(ncl-1)):*(X[|j,1\k,ncov|]'*res[j..k]*res[j..k]'*X[|j,1\k,ncov|])
		j=k+1
	}
	a=invorder(a)
	cl1[.]=cl1[a]
	X[,]=X[a,]
	_collate(res,a)
	if (nclv==3) {
		a=order(cl2,1)
		cl2[.]=cl2[a]
		X[,]=X[a,]
		_collate(res,a)
		maxindex(sign((cl2[2..no]\(cl2[no]+1))-cl2),1,b=.,.)
		ncl=length(b)
		j=1
		for(i=1;i<=ncl;i++) {
			k=b[i]
			xeex=xeex+(ncl/(ncl-1)):*(X[|j,1\k,ncov|]'*res[j..k]*res[j..k]'*X[|j,1\k,ncov|])
			j=k+1
		}
		a=invorder(a)
		cl2[.]=cl2[a]
		X[,]=X[a,]
		_collate(res,a)
		a=order(cl3,1)
		cl3[.]=cl3[a]
		X[,]=X[a,]
		_collate(res,a)
		maxindex(sign((cl3[2..no]\(cl3[no]+1))-cl3),1,b=.,.)
		ncl=length(b)
		j=1
		for(i=1;i<=ncl;i++) {
			k=b[i]
			xeex=xeex-(ncl/(ncl-1)):*(X[|j,1\k,ncov|]'*res[j..k]*res[j..k]'*X[|j,1\k,ncov|])
			j=k+1
		}
		a=invorder(a)
		cl3[.]=cl3[a]
		X[,]=X[a,]
		_collate(res,a)
	}
	covb=(no/(no-df)):*xx*xeex*xx
}
return(covb)
}

end

