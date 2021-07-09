mata: mata clear
version 10.1
mata: mata set matastrict on
mata:
// indcorr 1.0.0  CFBaum 11aug2008
void function indcorr(string scalar ind, 
                      string scalar vn,
                      string scalar newvar)
{
	real matrix pdata, info, highcorr, sigma, z, enn, w
	real vector muret, ret
	real scalar nf, nv, nv1, i, imax
	string scalar mu, maxc, enname
	st_view(ind, ., ind)
	st_view(pdata, ., tokens(vn))
	info = panelsetup(ind, 1)
	nf = rows(info)
	nv = cols(pdata)
	nv1 = nv-1
	maxc = newvar + "max"
	st_view(highcorr, 1::nf, maxc)
	mu = newvar + "mu"
	st_view(muret, 1::nf, mu)
	enname = newvar + "n"
	st_view(enn, 1::nf, enname)
// compute correlations between index columns and last column (ret)
	for(i = 1; i <= nf; i++) {
		sigma = correlation(panelsubmatrix(pdata, i, info))
		ret = sigma[nv,  1::nv1]		
		maxindex(ret, 1, imax, w)
		highcorr[i] = imax	
// calculate mean return and number of quotes for this panel
		z = panelsubmatrix(pdata[.,nv], i, info)
		muret[i] = mean(z)
		enn[i] = rows(z)
	}
}
end

mata: mata mosave indcorr(), dir(PERSONAL) replace
