* ==========================================================
* ka: computing Krippendorff's alpha
* program belongs to krippalpha
* Version 1.3.1, 2015-01-14
* (Version 1.0.0 corresponds to 2013-10-18)
* ==========================================================
*! version 1.3.1, Alexander Staudt, Mona Krewel, 14jan2015

*mata mata clear
*program drop _all
program ka, rclass
	version 11.2
	syntax varlist [if] [in], Method(string)	
	preserve
	* keep observations of interest
	mark touse `if' `in'
	quietly keep if touse==1
	quietly tab touse
	
	if `r(N)' == 0 {
		mata: _error(111, "the data you selected does not contain any observation")
	}
	else {
		keep `varlist'
		
		foreach x in `varlist' {
			local i = `i' + 1
			rename `x' var`i'
		}
		gen id = _n
		quietly reshape long var, i(id) j(coder)
		quietly levelsof var, local(levx)
		quietly reshape wide
		drop id
		quietly ds
		local vars = "`r(varlist)'"
		* compute Krippendorff's alpha
		mata: kripp_alpha("`method'")
	}
	restore
end

mata:
function kripp_alpha(string scalar method) 
{
	vars = tokens(st_local("vars"))
	vartype = J(1, length(vars), 0)
	for (i=1; i<=length(vars); i++)
	{
		vartype[i] = (st_isnumvar(vars[i]))
	} 
	if (sum(vartype) < length(vars)) _error(108, "Data have to be numeric.")
	else daten = st_data(., .)
	daten = daten'
	x = daten
	if (rows(x)<2) _error(102, "only one coder specified: intercoder reliabilitiy cannot be calculated.")
	else {
		levx = tokens(st_local("levx"))
		levx = strtoreal(levx)
		
		levx = unq(x)'
		
		zeilen = rows(x)
		spalten = cols(x)
		dimx = (zeilen, spalten)
		nval = length(levx)
		cm = J(nval, nval, 0)
		mc = colnonmissing(x) :- 1
		for (col=1; col<=dimx[2]; col++) 
		{
			for (i1=1; i1<=(dimx[1]-1); i1++) 
			{
				for (i2=(i1+1); i2<=dimx[1]; i2++) 
				{
					if (hasmissing(daten[i1, col])==0 && hasmissing(daten[i2, col])==0) 
					{
						index1 = select(1..cols(levx), colmax(levx):==daten[i1, col])
						index2 = select(1..cols(levx), colmax(levx):==daten[i2, col])
						cm[index1, index2] = cm[index1, index2] + (1 + (index1 == index2))/mc[col]
						if (index1 != index2)
						{
						cm[index2, index1] = cm[index1, index2]
						}
					} 
				}
			}
		}
		nmv = sum(colsum(cm)) 
		zeilen_ka = rows(cm) 
		spalten_ka = cols(cm) 
		dimcm = (zeilen_ka, spalten_ka)
		a = lowertriangle(uppertriangle(cm, -9999999999):-9999999999,-9999999999)
		b = vec(a+cm)
		utcm = select(b, b[,1]:>=0)'
		diagcm = diagonal(cm) 
		occ = sum(diagcm)
		nc = rowsum(cm) 
		ncnc = sum(nc :* (nc :- 1))
		dv = levx 
		diff2 = J(1, length(utcm), 0)
		ncnk = J(1, length(utcm), 0)
		ck = 1

		if (dimcm[2] < 2) alpha = 1
		else
			{
			for (k=2; k<=dimcm[2]; k++)
			{
				for (c=1; c<=(k-1); c++)
				{
					ncnk[ck] = nc[c]*nc[k]
					if (method == "nominal") diff2[ck] = 1;
					if (method == "ordinal")
					{
						diff2[ck] = nc[c]/2
						if (k>(c+1)) for (g=(c+1);g<=(k-1);g++) diff2[ck] = diff2[ck]+nc[g]
						diff2[ck] = diff2[ck]+nc[k]/2
						diff2[ck] = diff2[ck]^2
					}
					if (method == "interval") diff2[ck] = (dv[c]-dv[k])^2
					if (method == "ratio") diff2[ck] = (dv[c]-dv[k])^2/(dv[c]+dv[k])^2
					ck = ck+1	
				}
			}
			alpha = 1-((nmv-1)*sum(utcm:*diff2)/sum(ncnk:*diff2))
			}
		}
st_rclear()
st_numscalar("k_alpha", alpha)
st_numscalar("rater", dimx[1])
st_numscalar("units", dimx[2])
}

function unq(x)
{  
	y = sort(vec(x), 1)
	
	if (eltype(x)=="real") 
	{
		y = select(y, y :!= .)
	}
	if (eltype(x)=="string")
	{
		y = select(y, strtrim(y) :!= "")
	}	
	
	unq = J(length(y), 1, 1)
	
	for (i=2; i<=length(y); i++) {
		unq[i] = y[i-1]!=y[i]
	}
	
	unq = select(y, unq:==1)
	return(unq)
}

end
