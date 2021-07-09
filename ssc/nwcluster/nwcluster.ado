*! Date        : 22avr2016
*! Version     : 1.2.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : charlie.joyez@dauphine.fr

* Calculates node's clustering coefficient and weighted clusteing coefficient
* See Saramaki et al. (2007), “Generalization of the clustering coefficient to weighted complex networks"
*and Onnela et al.(2005) Phys. Rev. E

capture program drop nwcluster
program nwcluster, rclass
	version 9
	syntax [anything(name=netname)]	[, VALued DIRection(string) *]	
	_nwsyntax `netname', max(9999)
	_nwsetobs
	
foreach v in _clustering _wclustering _in_clustering _in_wclustering _out_clustering _out_wclustering {
	capture confirm variable `v'
	
if !_rc {
                      
					   rename `v' old_`v'
               }
}


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


*mata A=(0,4,4,4,0\4,0,8,0,4\4,8,0,4,0\4,0,4,4,0\0,4,0,0,0)
*mata _diag(A,0)
*mata A=A:/A
*mata: _editmissing(A, 0)
*mata A	 

*nwset , mat(A)  undirected 
*nwsummarize
*nwdegree

if "`valued'" == ""{
			if "`directed'" == "true" {
				if "`direction'"!="inward"{
				
				mata: neighbor = A:>0
				mata : D=rowsum(neighbor)
				mata : D
				mata dim1=D:-1
				mata dim1
				mata Ddim1=D:*dim1
				mata Ddim1
				mata : S=rowsum(A)
				mata : S
				mata maxw=max(A)
				mata maxw


				mata W=A:/maxw
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata A3=A*A*A
				mata A3=diagonal(A3)
				mata P=colsum(A3)/colsum(Ddim1)
				mata c=(A*A*A):/Ddim1
				mata c=diagonal(c)
				mata: _editmissing(c, 0)
				
				mata st_local("ov_clust", strofreal(P))

				*noi mata c 
	
				mata: st_matrix("clustering", c)
				capture drop _out_clustering
				mata: resindex = st_addvar("float","_out_clustering")
				mata: st_store((1,rows(c)),resindex,c)
				qui count if _out_clustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt} _out_clustering created"
				quie su _out_clustering
				noi di  "{txt} Average outward clustering coefficient :{res} `r(mean)'"
				noi di  "{txt} Overall outward clustering coefficient :{res} `ov_clust'"


}
				if "`direction'"=="inward"{
				mata: neighbor = A:>0
				mata : D=colsum(neighbor)
				mata : D=D'
				mata dim1=D:-1
				mata dim1
				mata Ddim1=D:*dim1
				mata Ddim1
				mata : S=colsum(A)
				mata : S=S'
				mata maxw=max(A)
				mata maxw

				mata W=A:/maxw
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata A3=A*A*A
				mata A3=diagonal(A3)
				mata P=colsum(A3)/colsum(Ddim1)
				mata c=(A*A*A):/Ddim1
				mata c=diagonal(c)
				mata: _editmissing(c, 0)
				
				mata st_local("ov_clust", strofreal(P))


				*noi mata c 
	
				mata: st_matrix("clustering", c)
				capture drop _in_clustering
				mata: resindex = st_addvar("float","_in_clustering")
				mata: st_store((1,rows(c)),resindex,c)
				qui count if _in_clustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt} _in_clustering created"
				quie su _in_clustering
				noi di  "{txt} Average inward clustering coefficient :{res} `r(mean)'"
				noi di  "{txt} Overall inward clustering coefficient :{res} `ov_clust'"
				
				}

			}
			if "`directed'" != "true" {
			
			mata: neighbor = A:>0
			mata : D=rowsum(neighbor)
			mata : D
			mata dim1=D:-1
			mata dim1
			mata Ddim1=D:*dim1
			mata Ddim1
			mata : S=rowsum(A)
			mata : S
			mata maxw=max(A)
			mata maxw

			mata W=A:/maxw
			mata A=W:/W
			mata: _editmissing(A, 0)
			mata A3=A*A*A
			mata A3=diagonal(A3)
			mata P=colsum(A3)/colsum(Ddim1)			
			mata c=(A*A*A):/Ddim1
			mata c=diagonal(c)
			mata: _editmissing(c, 0)
			
			mata st_local("ov_clust", strofreal(P))

			*noi mata c 
	
			mata: st_matrix("clustering", c)
			capture drop _clustering
			mata: resindex = st_addvar("float","_clustering")
			mata: st_store((1,rows(c)),resindex,c)
			qui count if _clustering!=.

			noi di "{hline 40}"
			noi di "{txt}Network {res}`netname_temp' {txt} "
			noi di"{res}  `r(N)' {txt} real values of {txt}_clustering created"
			quie su _clustering
			noi di  "{txt} Average clustering coefficient :{res} `r(mean)'"
			noi di  "{txt} Overall clustering coefficient :{res} `ov_clust'"
			}
		}
		return scalar avg_cc=`r(mean)'
		return scalar overall_cc=`ov_clust'	
		if "`valued'" != ""{ 
		capture drop _clustering 
		capture drop _in_clustering 
		capture drop _out_clustering
			if "`directed'" == "true" {
				if "`direction'"!="inward"{
				mata: neighbor = A:>0
				mata : D=rowsum(neighbor)
				mata : D
				mata dim1=D:-1
				mata dim1
				mata Ddim1=D:*dim1
				mata Ddim1
				mata : S=rowsum(A)
				mata : S
				mata maxw=max(A)
				mata maxw


				mata W=A:/maxw
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata A3=A*A*A
				mata A3=diagonal(A3)
				mata P=colsum(A3)/colsum(Ddim1)
				mata c=(A*A*A):/Ddim1
				mata c=diagonal(c)
				mata: _editmissing(c, 0)
				
				mata st_local("ov_clust", strofreal(P))


				mata Wt=W:^(1/3)
				 mata W3=Wt*Wt*Wt
				 mata W3=diagonal(W3)
				 mata Pw=colsum(W3)/colsum(Ddim1)
				mata cw=(Wt*Wt*Wt):/Ddim1
				mata cw=diagonal(cw)
				mata: _editmissing(cw, 0)
				mata st_local("ov_wclust", strofreal(Pw))


	
				mata: st_matrix("clustering", c)
				capture drop _out_clustering
				mata: resindex = st_addvar("float","_out_clustering")
				mata: st_store((1,rows(c)),resindex,c)
				qui count if _out_clustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_out_clustering created"
				quie su _out_clustering
				local avg=r(mean)
				noi di  "{txt} Average outward clustering coefficient :{res} `avg'"
				noi di  "{txt} Overall outward clustering coefficient :{res} `ov_clust'"


				mata: st_matrix("wclustering", cw)
				capture drop _out_wclustering
				mata: resindex = st_addvar("float","_out_wclustering")
				mata: st_store((1,rows(cw)),resindex,cw)
				qui count if _out_wclustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_out_wclustering created"
				quie su _out_wclustering
				local wavg=r(mean)
				noi di  "{txt} Average outward weighted clustering coefficient :{res} `wavg'"
				noi di  "{txt} Overall outward weighted clustering coefficient :{res} `ov_wclust'"
				}
				if "`direction'"=="inward"{
				mata: neighbor = A:>0
				mata : D=colsum(neighbor)
				mata : D=D'
				mata dim1=D:-1
				mata dim1
				mata Ddim1=D:*dim1
				mata Ddim1
				mata : S=colsum(A)
				mata : S=S'
				mata maxw=max(A)
				mata maxw


				mata W=A:/maxw
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata A3=A*A*A
				mata A3=diagonal(A3)
				mata P=colsum(A3)/colsum(Ddim1)
				mata c=(A*A*A):/Ddim1
				mata c=diagonal(c)
				mata: _editmissing(c, 0)
				mata st_local("ov_clust", strofreal(P))

				mata Wt=W:^(1/3)
				 mata W3=Wt*Wt*Wt
				 mata W3=diagonal(W3)
				 mata Pw=colsum(W3)/colsum(Ddim1)
				mata cw=(Wt*Wt*Wt):/Ddim1
				mata cw=diagonal(cw)
				mata: _editmissing(cw, 0)
				mata st_local("ov_wclust", strofreal(Pw))

	
				mata: st_matrix("clustering", c)
				capture drop _in_clustering
				mata: resindex = st_addvar("float","_in_clustering")
				mata: st_store((1,rows(c)),resindex,c)
				qui count if _in_clustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_in_clustering created"
				quie su _in_clustering
				local avg=r(mean)
				noi di  "{txt} Average inward clustering coefficient :{res} `avg'"
				noi di  "{txt} Overall inward clustering coefficient :{res} `ov_clust'"


				mata: st_matrix("wclustering", cw)
				capture drop _in_wclustering
				mata: resindex = st_addvar("float","_in_wclustering")
				mata: st_store((1,rows(cw)),resindex,cw)
				qui count if _in_wclustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_in_wclustering created"
				quie su _in_wclustering
				local wavg=r(mean)
				noi di  "{txt} Average inward weighted clustering coefficient :{res} `wavg'"
				noi di  "{txt} Overall inward weighted clustering coefficient :{res} `ov_wclust'"
				
				}
			}
			if "`directed'" != "true" {
				mata: neighbor = A:>0
				mata : D=rowsum(neighbor)
				mata : D
				mata dim1=D:-1
				mata dim1
				mata Ddim1=D:*dim1
				mata Ddim1
				mata : S=rowsum(A)
				mata : S
				mata maxw=max(A)
				mata maxw

				mata W=A:/maxw
				mata A=W:/W
				mata: _editmissing(A, 0)
				mata A3=A*A*A
				mata A3=diagonal(A3)
				mata P=colsum(A3)/colsum(Ddim1)
				mata c=(A*A*A):/Ddim1
				mata c=diagonal(c)
				mata: _editmissing(c, 0)
				mata st_local("ov_clust", strofreal(P))


				mata Wt=W:^(1/3)
				 mata W3=Wt*Wt*Wt
				 mata W3=diagonal(W3)
				 mata Pw=colsum(W3)/colsum(Ddim1)
				mata cw=(Wt*Wt*Wt):/Ddim1
				mata cw=diagonal(cw)
				mata: _editmissing(cw, 0)
				mata st_local("ov_wclust", strofreal(Pw))

	
				mata: st_matrix("clustering", c)
				capture drop _clustering
				mata: resindex = st_addvar("float","_clustering")
				mata: st_store((1,rows(c)),resindex,c)
				qui count if _clustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_clustering created"
				quie su _clustering
				local avg=r(mean)
				noi di  "{txt} Average clustering coefficient :{res} `avg'"
				noi di  "{txt} Overall clustering coefficient :{res} `ov_clust'"

				mata: st_matrix("wclustering", cw)
				capture drop _wclustering
				mata: resindex = st_addvar("float","_wclustering")
				mata: st_store((1,rows(cw)),resindex,cw)
				qui count if _wclustering!=.

				noi di "{hline 40}"
				noi di "{txt}Network {res}`netname_temp' {txt} "
				noi di"{res}  `r(N)' {txt} real values of {txt}_wclustering created"
				quie su _wclustering
				local wavg=r(mean)
				noi di  "{txt} Average weighted clustering coefficient :{res} `wavg'"
				noi di  "{txt} Overall weighted clustering coefficient :{res} `ov_wclust'"
			}
		return scalar avg_cc=`avg'
		return scalar overall_cc=`ov_clust'
		return scalar avg_wcc=`wavg'
		return scalar overall_wcc=`ov_wclust'	
			
	}
		
	local k = `k' + 1
}

foreach v in _clustering _wclustering _in_clustering _in_wclustering _out_clustering _out_wclustering {
	capture confirm variable old_`v'
if !_rc {
          capture drop  `v'           
					  rename old_`v' `v'

               }

			   *else {

				*	capture drop `v'
			  
			   *}
}
	end
