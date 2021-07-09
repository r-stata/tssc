*! Program to assign features with no contiguous neighbors (islands) their first nearest neighbors 
*! Author P. Wilner Jeanty
*! Date April 17, 2009
program define spwmatfill
	version 9.2
	syntax varlist, id(str) INWName(str) INWFrom(str) OUTWName(str) [EIGNval(name) eignvar(str) cart r(str) mataf matlab(str) ///
		ROWstand replace Connect favor(str)]
	mata: mata clear	
	tempvar nei_id distn
	if !inlist("`inwfrom'", "Stata", "Mata") {
      	di 
        di as err "Either Stata or Mata must specified with the {bf:inwfrom()} option"
		exit 198
     }
	if "`inwfrom'"=="Mata" confirm file `inwname'
	else confirm matrix `inwname'
	if "`matlab'"!="" {
		local outmatl `matlab'.dat
		Confnewfile `outmatl' `replace'
	}
	if "`mataf'"!="" Confnewfile `outwname' `replace'
		
	if "`eignval'"!="" & "`mataf'"!="" Confnewfile `eignval' `replace'
	
	if "`eignvar'"!="" {
		cap confirm new var `eignvar'
		if _rc & "`replace'"!="" drop `eignvar'
		else if _rc & "`replace'"=="" confirm new var `eignvar'
	}
	*** Use nearstat to identify the first nearest neighbors	
	qui nearstat `varlist', near(`varlist') dist(`distn') nid(`id' `nei_id') `cart' `r' favor(`favor')
	mata: Fill_SPW_matrix()	
	di
	di as txt "{bf: Contiguity weights matrix filled sucessfully, and the following actions have been taken:}"
	local foreign1 ""
	local foreign2 ""
	if "`eignval'"!="" {
		local foreign1 and its eigenvalues
		local foreign2 as txt " and " in ye "`eignval'" as txt
		if scalar(spwmatfill_forst)!=0 & "`mataf'"=="" local foreign3 as txt " and " in ye "`eignval'_n"  
	}
	if scalar(spwmatfill_forst)==0 & "`mataf'"=="" {
		local ROW="SWMDist No "
		if "`rowstand'"!="" local ROW="`ROW'Yes"
		else local ROW="`ROW'No"
		matrix rownames `outwname'=`ROW'		
		di
		di as txt " - Spatial weights matrix `foreign1' created as Stata object(s): " in ye "`outwname'" `foreign2' "."
		di
		di as txt " - N.B.: The Stata weights matrix, " in ye "`outwname'" as txt ", can be used as if it was created by the {cmd:spatwmat} command"
	}
	if scalar(spwmatfill_forst)!=0 {
		if "`mataf'"=="" {
 			di
			di as txt " - Weights matrix `foreign1' saved in Mata file(s): " in ye "`c(pwd)'`c(dirsep)'`outwname'_n" `foreign3'," 
			di
			di as txt "    since dimensions exceed {it:matsize} of your Stata flavor."
		}
		if "`mataf'"!="" {
			di 
			di as txt " - Spatial weights matrix `foreign1' saved to Mata file(s): " in ye "`c(pwd)'`c(dirsep)'`outwname'" `foreign2' "."
		}
	}
	if "`rowstand'"!="" {
		di
		di as txt " - Spatial weights matrix has been row-standardized."
	}
	if "`mataf'"!="" & scalar(spwmatfill_forst)==0 {
		di
		di as txt " - Spatial weights matrix `foreign1' saved to Mata file(s): " in ye "`c(pwd)'`c(dirsep)'`outwname'" `foreign2' "."
	}
	if "`matlab'"!="" {
		di
		di as txt " - Spatial weights matrix saved to the text file, " in ye "`c(pwd)'`c(dirsep)'`outmatl'" as txt ", for use in " in ye "Matlab"
	}
	if "`eignvar'"!="" {
		di
		di as txt " - The variable " in ye "`eignvar'" as txt " contains the eigenvalues."
	}
	if "`connect'"!="" {	
		tempvar neighbr
		mata: spwmatfill_Connect()
		di
		di as txt "{bf:Spatial weights connectivity information}"
		di as txt " - Sparseness:" as res %5.3f spwmatfill_spa as txt "%"
		qui sum `neighbr', detail
		local mean=r(mean)
		local min=r(min)
		local max=r(max)
		local med=r(p50)
		di as txt " - Neighbors: "
		di as txt "  	Min   : " in ye `min'
		di as txt "  	Mean  : " in ye `mean'
		di as txt "  	Median: " in ye `med'
		di as txt "  	Max   : " in ye `max'
	}
	* Cleaning up
	capture scalar drop spwmatfill_forst
	mata: mata clear 
end
prog define Confnewfile
        version 9.2
        args filename replace
        local conf_file confirm new file		
        cap `conf_file' `filename'
        if _rc {
                if "`replace'"!="" erase `filename'
                else {
					di              
                    `conf_file' `filename'
                }
        } 
end
version 9.2
mata:
	mata set matastrict on
	void Fill_SPW_matrix() {
	external real matrix inw
	if (st_local("inwfrom")=="Mata") {
		fh = fopen(st_local("inwname"), "r")
		inw=fgetmatrix(fh)
		fclose(fh)
	}
	else inw=st_matrix(st_local("inwname"))
	w1=st_data(., (st_local("id"), st_local("nei_id")))
      ""            
      display(" N.B.: First nearest neighbors for " + strofreal(sum(rowsum(inw):==0)) +
		  " features have been calculated.")
	// Now assign to observations having no contiguous neighbors their first nearest neighbors
	j=0
	for (i=1; i<=rows(rowsum(inw)); i++) {
           if (rowsum(inw)[i]==0) {			
			for (s=1; s<=rows(w1); s++) { 
				if (w1[s,1]==i) inw[i,w1[s,2]]=1
			}
			j=j+1
		}
		if (j==sum(rowsum(inw):==0)) i=rows(rowsum(inw)) // break would do as well, to avoid continuing searching
	}
	if (st_local("rowstand")!="") inw=inw:/rowsum(inw)

// Now output spatial weights and eigenvalues
	colw=cols(inw); ind=0
	if (c("flavor")=="Small" & colw>40) ind=1
	if (c("flavor")=="Intercooled") {
		if ((c("SE")==0 & c("MP")==0) & colw>800) ind=2
		if ((c("SE")==1 | c("MP")==1) & colw>11000) ind=3	
	} 	
	if (ind==0) {	
		if (st_local("mataf")!="") {
			fh = fopen(st_local("outwname"), "w")
			fputmatrix(fh, inw)
			fclose(fh)
		}
		else st_matrix(st_local("outwname"), inw)	
	}
	if (ind!=0) {
		if (st_local("mataf")!="") {			
			fh = fopen(st_local("outwname"), "w")
			fputmatrix(fh, inw)
			fclose(fh)
		}
	  	else {
			fh = fopen(st_local("outwname") + "_n", "rw")
			fputmatrix(fh, inw)
			fclose(fh)
		}
	}	
	if (st_local("matlab")!="") spwmatfill_xport(st_local("outmatl"), strofreal(inw))  
	if (st_local("eignval")!="") {
		if (issymmetric(inw)==1) eigw=symeigenvalues(inw) // row-standardized inw may or may not be symmetric
		else	{
			eigw=eigenvalues(inw)  
			eigw=Re(eigw); eigw=eigw'
		}
		if (ind==0) {
			st_matrix(st_local("eignval"), eigw)	
			if (st_local("mataf")!="") {
				fh = fopen(st_local("eignval"), "w")
				fputmatrix(fh, eigw)
				fclose(fh)
			}
		}
		if (ind!=0) {
			if (st_local("mataf")!="") {
				fh = fopen(st_local("eignval"), "w")
				fputmatrix(fh, eigw)
				fclose(fh)
			}
			else {
	  			fh = fopen(st_local("eignval") + "_n", "rw")
				fputmatrix(fh, eigw)
				fclose(fh)
			}
		}
	}
	st_numscalar("spwmatfill_forst", ind)
	if (st_local("eignvar")!="") {
		if (st_local("eignval")!="") st_store(., st_addvar("double", st_local("eignvar")), eigw)
		else {
			if (issymmetric(inw)) eigw=symeigenvalues(inw) // row-standardized w may or may not be symmetric
			else	{
				eigw=eigenvalues(inw)  
				eigw=Re(eigw); eigw=eigw'
			}
			st_store(., st_addvar("double", st_local("eignvar")), eigw)
		}
	}

}
void spwmatfill_Connect() {
	external real matrix inw
	n=rows(inw)
	spa=(sum(inw:!=0)/(n*n))*100
	neighb=rowsum(inw:!=0)
	st_numscalar("spwmatfill_spa", spa)
	st_store(., st_addvar("double", st_local("neighbr")), neighb)
}	
void spwmatfill_xport(string scalar jnct, string matrix g)
{
	string scalar line
    real scalar i, j, fho
	// tod=(spwmatfill_rep0==1? "rw" : "w")
	delim = char(9)
      fho = fopen(jnct, "w")
      for (i=1; i<=rows(g); i++) {
		line = J(1,1,"")
            for (j=1; j<=cols(g); j++) {
                line = line + g[i,j]
                if (j<cols(g)) line = line + delim
            }
            fput(fho, line)
	}
      fclose(fho)
}
end
