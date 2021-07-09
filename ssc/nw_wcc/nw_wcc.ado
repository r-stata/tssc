*! Date        : 15Feb2017
*! Version     : 1.2.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : charlie.joyez@dauphine.fr

* Calculates several clustering coefficients for complex direct networks.
* See Giorgio Fagiolo, “Clustering in complex directed networks" Phys. Rev. E 76 (2007)
*Last updates : 1.1.0 several Normalize option possible (see help file)
			   *1.2.0 Makes valued default, add binary option

capture program drop nw_wcc
program nw_wcc, rclass
	version 9
	syntax [anything(name=netname)]	[, Normalize42 Normalize(string) BINary CYCle MIDdleman In Out All ]	
	_nwsyntax `netname', max(9999)
	_nwsetobs

	    if (mi(`"`normalize'"') & ("`normalize42'" != "")) {
        local normalize "max"
    }
    
    if !inlist(`"`normalize'"', "", "max", "sum") {
        display as err "invalid option normalize()"
        exit 198
    }
	    display "`normalize'"

	if `networks' > 1 {
		local k = 1
	}
	_nwsetobs `netname'
	
	set more off
 quietly foreach netname_temp in `netname' {
 nwtomata `netname_temp', mat(A)

_nwsyntax `netname_temp' 
local nodes_temp `nodes' 
local directed `directed' 


if "`normalize'"=="" & "`binary'"==""{
 	mata maxA=max(A)
	mata st_local("maxA", strofreal(maxA))
	if `maxA'>1 {
	di as error "weights above one, normalize() or binary options should be used"
	exit
	}
}



if "`binary'" != ""{
	if "`directed'" != "true" {

			mata: neighbor = A:>0
			mata : D=rowsum(neighbor)
			mata : D
			mata dim1=D:-1
			mata dim1
			mata Ddim1=D:*dim1
			mata Ddim1
			mata : S=sum(A)
			mata : S
			mata maxw=max(A)
			mata maxw

			mata W=A /*non normalization*/
					if "`normalize'"=="max"{ 
					mata W=A:/maxw /*normalization*/
					}
					if "`normalize'"=="sum"{ 
					mata W=A:/S
					}
				
			mata A=W:/W
			mata: _editmissing(A, 0)
			mata A3=A*A*A
			mata A3=diagonal(A3)
			mata ov=colsum(A3)/colsum(Ddim1)			
			mata c=(A*A*A):/Ddim1
			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
			
			mata st_local("ov_clust", strofreal(ov))


	
			mata: st_matrix("clustering", cci)
			capture drop _clustering
			mata: resindex = st_addvar("float","_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _clustering!=.
			noi di  "{txt} Network not directed standard clustering coefficient computed"
			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt}_clustering created"
			quie su _clustering
			noi di  "{txt} Average clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall clustering coefficient :{res} `ov_clust'"
			}
			
	if "`directed'" == "true" {
			if "`in'" == "" & "`out'" == "" & "`cycle'" == "" & "`middleman'" == "" & "`all'"  == "" {
				 noi di  "no option specified, by default, All(D) calculated"
				 local all  = "all"

			}
	
			mata : neighbor = A:>0
			mata : Do=rowsum(neighbor)
			mata : Di=colsum(neighbor)
			mata : Di =Di'
			mata Di
			mata Do
			mata : D = A :* (A :< A') + A' :* (A' :< A) /*min of symmetrics elements : reciprocated ties*/
			mata D
			mata : Db=rowsum(D)
			mata : Db
			mata : DiDomDb=Di:*Do:-Db
			mata : DiDomDb
			mata : DiDimDi=Di:*Di:-Di
			mata : DoDomDo=Do:*Do:-Do
			mata : Dtot=Di+Do
			mata : Dtot
			mata : denumtot=2*(Dtot:*Dtot:-Dtot:-Db:-Db)
			mata maxw=max(A)
			mata : S=sum(A)
			mata W=A /*non normalization*/
					if "`normalize'"=="max"{ 
					mata W=A:/maxw /*normalization*/
					}
					if "`normalize'"=="sum"{ 
					mata W=A:/S
					}
				
			mata A=W:/W
			mata: _editmissing(A, 0)

			
			if "`in'" != ""{
            mata c=(A'*A*A):/DiDimDi
			
			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
		
			mata A3=(A'*A*A)
			mata A3=diagonal(A3)
			mata ov=colsum(A3)/colsum(DiDimDi)	
			mata st_local("ov_clust", strofreal(ov))

	
			mata: st_matrix("clustering", cci)
			capture drop _in_clustering
			mata: resindex = st_addvar("float","_in_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _in_clustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _in_clustering created"
			quie su _in_clustering
			noi di  "{txt} Average inward clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall inward clustering coefficient :{res} `ov_clust'"


}
			if "`out'" != ""{
            mata c=(A*A*A'):/DoDomDo
			
			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
			
			mata A3=(A*A*A')
			mata A3=diagonal(A3)
			mata ov=colsum(A3)/colsum(DoDomDo)	
			mata st_local("ov_clust", strofreal(ov))

	
			mata: st_matrix("clustering", cci)
			capture drop _out_clustering
			mata: resindex = st_addvar("float","_out_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _out_clustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _out_clustering created"
			quie su _out_clustering
			noi di  "{txt} Average outward clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall outward clustering coefficient :{res} `ov_clust'"
			}
			
			if "`cycle'"!=""{
			 mata c=(A*A*A):/DiDomDb
			
			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
			
			mata A3=(A*A*A)
			mata A3=diagonal(A3)
			mata ov=colsum(A3)/colsum(DiDomDb)	
			mata st_local("ov_clust", strofreal(ov))

	
			mata: st_matrix("clustering", cci)
			capture drop _cyc_clustering
			mata: resindex = st_addvar("float","_cyc_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _cyc_clustering!=.	
					
			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _cycle_clustering created"
			quie su _cyc_clustering
			noi di  "{txt} Average cycle clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall cycle clustering coefficient :{res} `ov_clust'"
				
				}
			if "`middleman'"!=""{
				
			mata c=(A*A'*A):/DiDomDb
			
			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
			
			mata A3=(A*A'*A)
			mata A3=diagonal(A3)
			mata ov=colsum(A3)/colsum(DiDomDb)	
			mata st_local("ov_clust", strofreal(ov))

	
			mata: st_matrix("clustering", cci)
			capture drop _mid_clustering
			mata: resindex = st_addvar("float","_mid_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _mid_clustering!=.	
					
			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _mid_clustering created"
			quie su _mid_clustering
			noi di  "{txt} Average middleman clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall middleman clustering coefficient :{res} `ov_clust'"
				
				}				
			if "`all'"!=""{

			mata AAt=A+A'	
			mata AAt3=AAt*AAt*AAt
			mata c=AAt3:/denumtot

			mata cci=diagonal(c)
			mata: _editmissing(cci, 0)
			
			mata AAt3=diagonal(AAt3)
			mata ov=colsum(AAt3)/colsum(denumtot)	
			mata st_local("ov_clust", strofreal(ov))

	
			mata: st_matrix("clustering", cci)
			capture drop _all_clustering
			mata: resindex = st_addvar("float","_all_clustering")
			mata: st_store((1,rows(cci)),resindex,cci)
			qui count if _all_clustering!=.	
			
			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _all_clustering created"
			quie su _all_clustering
			noi di  "{txt} Average all clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall all clustering coefficient :{res} `ov_clust'"
				}					
			
			
		}
		return scalar avg_cc=`r(mean)'
		return scalar overall_cc=`ov_clust'	
	}	
if "`binary'" == ""{ 

			if "`directed'" != "true" {
			
				mata: neighbor = A:>0
				mata : D=rowsum(neighbor)
				mata dim1=D:-1
				mata Ddim1=D:*dim1
				mata : S=sum(A)
				mata maxw=max(A)

				mata W=A /*non normalization*/
					if "`normalize'"=="max"{ 
						mata W=A:/maxw /*normalization*/
					}
					if "`normalize'"=="sum"{ 
						mata W=A:/S
					}
					
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata: _editmissing(W, 0)
				mata Wh=W:^(1/3)
				
				mata c=(Wh*Wh*Wh):/Ddim1
				mata wcci=diagonal(c)
				mata: _editmissing(wcci, 0)				

				mata Wh3=(Wh*Wh*Wh)
				mata Wh3=diagonal(Wh3)
				mata ov=colsum(Wh3)/colsum(Ddim1)
				mata st_local("ov_wclust", strofreal(ov))

				mata: st_matrix("wclustering", wcci)
				capture drop _wclustering
				mata: resindex = st_addvar("float","_wclustering")
				mata: st_store((1,rows(wcci)),resindex,wcci)
				qui count if _wclustering!=.
				noi di  "{txt} Network not directed standard weighted clustering coefficient computed"
				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_wclustering created"
				quie su _wclustering
				local wavg=r(mean) 
				noi di  "{txt} Average weighted clustering coefficient :{res} `r(mean)'"
				noi di  "{txt} Overall weighted clustering coefficient :{res} `ov_wclust'"
			}
			
			if "`directed'" == "true" {
			    if "`in'" == "" & "`out'" == "" & "`cycle'" == "" & "`middleman'" == "" & "`all'"  == "" {
				 noi di  "no option specified, by default, All(D) calculated"

				 local all  = "all"
				}

			mata : neighbor = A:>0
			mata : Do=rowsum(neighbor)
			mata : Di=colsum(neighbor)
			mata : Di =Di'
			mata Di
			mata Do
			mata : D = A :* (A :< A') + A' :* (A' :< A) /*min of symmetrics elements : reciprocated ties*/
			mata D
			mata : Db=rowsum(D)
			mata : Db
			mata : DiDomDb=Di:*Do:-Db
			mata : DiDomDb
			mata : DiDimDi=Di:*Di:-Di
			mata : DoDomDo=Do:*Do:-Do
			mata : Dtot=Di+Do
			mata : Dtot
			mata : denumtot=2*(Dtot:*Dtot:-Dtot:-Db:-Db)
			mata maxw=max(A)
			mata : S=sum(A)
			mata W=A /*non normalization*/
				if "`normalize'"=="max"{ 
					mata W=A:/maxw /*normalization*/
				}
				if "`normalize'"=="sum"{ 
					mata W=A:/S
				}
				
			mata A=W:/W
			mata: _editmissing(A, 0)
			mata A3=A*A*A
			mata A3=diagonal(A3)
			mata: _editmissing(W, 0)
			mata W3=W*W*W
			mata W3=diagonal(W3)
			mata Wh=W:^(1/3)
				
			
		if "`in'" != ""{
				
			mata c=(Wh'*Wh*Wh):/DiDimDi
			mata wcci=diagonal(c)
			mata: _editmissing(wcci, 0)
			
			mata Wh3=(Wh'*Wh*Wh)
			mata Wh3=diagonal(Wh3)
			mata ov=colsum(Wh3)/colsum(DiDimDi)	
			mata st_local("ov_wclust", strofreal(ov))

	
			mata: st_matrix("clustering", wcci)
			capture drop _in_wclustering
			mata: resindex = st_addvar("float","_in_wclustering")
			mata: st_store((1,rows(wcci)),resindex,wcci)
			qui count if _in_wclustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _in_wclustering created"
			quie su _in_wclustering
			local wavg=r(mean) 
			noi di  "{txt} Average inward weighted clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall inward weighted clustering coefficient :{res} `ov_wclust'"


}
		if "`out'"!=""{
			mata c=(Wh*Wh*Wh'):/DoDomDo
			
			mata wcci=diagonal(c)
			mata: _editmissing(wcci, 0)
			
			mata Wh3=(Wh*Wh*Wh')
			mata Wh3=diagonal(Wh3)
			mata ov=colsum(Wh3)/colsum(DoDomDo)	
			mata st_local("ov_wclust", strofreal(ov))

	
			mata: st_matrix("clustering", wcci)
			capture drop _out_wclustering
			mata: resindex = st_addvar("float","_out_wclustering")
			mata: st_store((1,rows(wcci)),resindex,wcci)
			qui count if _out_wclustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _out_wclustering created"
			quie su _out_wclustering
			local wavg=r(mean) 
			noi di  "{txt} Average outward weighted clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall outward weighted clustering coefficient :{res} `ov_wclust'"
				
				}

		if "`cycle'"!=""{
			mata c=(Wh*Wh*Wh):/DiDomDb
			
			mata wcci=diagonal(c)
			mata: _editmissing(wcci, 0)
			
			mata Wh3=(Wh*Wh*Wh)
			mata Wh3=diagonal(Wh3)
			mata ov=colsum(Wh3)/colsum(DiDomDb)	
			mata st_local("ov_wclust", strofreal(ov))

	
			mata: st_matrix("clustering", wcci)
			capture drop _cyc_wclustering
			mata: resindex = st_addvar("float","_cyc_wclustering")
			mata: st_store((1,rows(wcci)),resindex,wcci)
			qui count if _cyc_wclustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _cyc_wclustering created"
			quie su _cyc_wclustering
			local wavg=r(mean) 
			noi di  "{txt} Average cycle weighted clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall cycle weighted clustering coefficient :{res} `ov_wclust'"
				
				}
			if "`middleman'"!=""{
				
			mata c=(Wh*Wh'*Wh):/DiDomDb
			
			mata wcci=diagonal(c)
			mata: _editmissing(wcci, 0)
	
			mata Wh3=(Wh*Wh'*Wh)
			mata Wh3=diagonal(Wh3)				
			mata ov=colsum(Wh3)/colsum(DiDomDb)	
			mata st_local("ov_wclust", strofreal(ov))

	
			mata: st_matrix("clustering", wcci)
			capture drop _mid_wclustering
			mata: resindex = st_addvar("float","_mid_wclustering")
			mata: st_store((1,rows(wcci)),resindex,wcci)
			qui count if _mid_wclustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _mid_wclustering created"
			quie su _mid_wclustering
			local wavg=r(mean) 
			noi di  "{txt} Average middleman weighted clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall middleman weighted clustering coefficient :{res} `ov_wclust'"
					
				}				
			if "`all'"!=""{

	        mata WhWht=Wh+Wh'	
			mata WhWht3=(WhWht)*(WhWht)*(WhWht)
			mata WhWht3
			
			mata c=WhWht3:/denumtot	
			
			mata wcci=diagonal(c)
			mata: _editmissing(wcci, 0)
			
			
			mata Wh3=diagonal(WhWht3)
			mata ov=colsum(Wh3)/colsum(denumtot)	
			mata st_local("ov_wclust", strofreal(ov))


			mata: st_matrix("clustering", wcci)
			capture drop _all_wclustering
			mata: resindex = st_addvar("float","_all_wclustering")
			mata: st_store((1,rows(wcci)),resindex,wcci)
			qui count if _all_wclustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt} _all_wclustering created"
			quie su _all_wclustering
			local wavg=r(mean) 
			noi di  "{txt} Average all weighted clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall all weighted clustering coefficient :{res} `ov_wclust'"
				
				}					
			}
			
		return scalar avg_wcc=`wavg'
		return scalar overall_wcc=`ov_wclust'	
			
	}
		
	local k = `k' + 1
}


	end
