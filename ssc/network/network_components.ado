*! version 1.2.5 # Ian White # 13mar2017
/*
version 1.2.5 # Ian White # 13mar2017
	changed network_indirect_connection back to be 1 on diagonal 
		- as in Howard Thom's final resubmission
version 1.2.4 # Ian White # 23feb2017
	changed name network_indirect_connect to network_indirect_connection
	changed network_indirect_connection to be 0 on diagonal
	removed debug
# 3feb2017 (numbering to match network_setup revision)
    change matrix names to match Howard Thom's paper:
        new name                    old name    in paper
        network_adjacency           _connect    A 
        network_indirect_connect    _connect2   I(C_n-1) 
        network_distance            _step       D 
        network_components         _components  not specifically defined
    also change network_adjacency and network_distance to be 0 on diagonal
    
version 1.2 # Ian White # 10dec2015 but file date is 21dec2015
    connect2 matrix changed to 0/1
    step matrix computed
    matrix output in Stata: _components _connect _connect2 _step

version 1.1 # Ian White # 27may2015

This program divides the studies (or an if/in subgroup) into connected components.
It generates a new variable identifying the components in the subgroup, 
and returns the number of components in ALL the treatments.

When subgrouping, the component variable may be 1 for all studies in the subgroup 
yet the number of components is >1: this means that the subgroup is connected 
but doesn't include all the treatments.

This program is not to be called directly. It is a subroutine for:
	setup (for general info, used by meta)
	sidesplit (to identify lack of indirect evidence)
*/

program define network_components, rclass
syntax [if] [in], [design(varname) trtlist(string) gen(name)]
if mi("`design'")  local design : char _dta[network_design]
if mi("`design'") di as error "network_components: design() not specified, and network characteristics not set"
if mi("`trtlist'") local trtlist `: char _dta[network_ref]' `: char _dta[network_trtlistnoref]'
if mi("`trtlist'") di as error "network_components: trtlist() not specified, and network characteristics not set"
if mi("`design'") | mi("`trtlist'") exit 198
if mi("`gen'") tempvar gen

marksample touse
foreach trt in `trtlist' {
	tempvar has`trt'
	qui gen `has`trt'' = strpos(" "+`design'+" "," `trt' ")>0 if `touse'
	local hasvars `hasvars' `has`trt''
}
qui gen `gen' = .
mata: FindComponents("`hasvars'", "`gen'", "ncpts", "network_components", "network_adjacency", "network_indirect_connection","network_distance")

* row and column names are treatments 
foreach mat in components adjacency indirect_connection distance {
    mat rownames network_`mat' = `trtlist'
}
foreach mat in adjacency indirect_connection distance {
    mat colnames network_`mat' = `trtlist'
}

* returns
return scalar ncomponents = `ncpts'
end

mata:
void FindComponents(
    string scalar hasvars, // names of the nvars, with data in wide format
    string scalar outname, // name of the variable to identify components
    string scalar outlocal, // name of the local to contain #components
    string scalar outcpts, // name of the matrix to relate treatments to components
    string scalar outadjacency, // name of the matrix to hold adjacency matrix
    string scalar outindirect, // name of the matrix to hold indirect connection matrix
    string scalar outdistance // name of the matrix to hold distance matrix
    ) {
debug=0
	// Matrix N of whether trials contain treatments
	N=st_data(.,hasvars)
	trts=cols(N)
	trials=rows(N)
	
	// Matrix adjacency of whether treatments are directly compared
	adjacency=J(trts,trts,0)
	for(i=1;i<=trials;++i) {
		for(j=1;j<=trts;++j) {
			for(k=1;k<=trts;++k) {
				if(N[i,j]==1 & N[i,k]==1) adjacency[j,k]=1
				if(j==k) adjacency[j,k]=0 // everything is NOT joined to itself (3feb2017)
			}
		}
	}
if(debug) "adjacency"
if(debug) adjacency


	// Matrix indirect of whether treatments are directly or indirectly compared
	// Zeroes in indirect indicate disconnected components
	indirect=adjacency
    distance=adjacency
	for(j=2;j<trts;++j) {
        indirect = indirect+adjacency*indirect
        // elementwise: if distance is 0 and indirect is nonzero then set distance to j
        distance = j*(indirect:>0):*(distance:==0) + distance
	}
    indirect=indirect:>0 // new

	// set diagonals back to 0 (3feb-13mar2017)
    offdiag = J(trts,trts,1) - I(trts)
	distance=distance:*offdiag 
if(debug) "distance"
if(debug) distance
if(debug) "indirect"
if(debug) indirect

	// Map treatments to components
	indirect1diag=indirect+I(trts)
	cpt=indirect1diag[,1]:>0 // vector of components
	icpt=1
	while(!min(cpt)){
		if(debug) icpt
		if(debug) cpt
		++icpt
		newcpt=indirect1diag[,min(selectindex(!cpt))]:>0
		innewcpt=selectindex(newcpt)
		cpt[innewcpt,]=J(rows(innewcpt),1,icpt)
	}
    ncpts=max(cpt)
if(debug) cpt
	
    // Nicer matrix display
    cpt2=(cpt:==1)
    for(j=2;j<=ncpts;++j) {
        cpt2 = cpt2,(cpt:==j)
    }

	// Map studies to components
	studycpts = (N*cpt):/rowsum(N)

    // Output
    st_matrix(outcpts,cpt2)
    st_matrix(outadjacency,adjacency)
    st_matrix(outindirect,indirect)
    st_matrix(outdistance,distance)
	st_store(.,outname,studycpts)
	st_local(outlocal,strofreal(ncpts))
if(debug) "finished FindComponents"

}

end

