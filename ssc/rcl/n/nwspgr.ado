/************************************************************************************
nwspgr: Nodes and weights for numerical integration on sparse grids (Smolyak)
(c) Florian Heiss & Viktor Winschel
Nov 05, 2007
ADO-file for generating nodes and weights as Stata matrices and/or variables
*************************************************************************************/

program define nwspgr
version 9
syntax  , DIMensions(integer) ACCuracy(integer) type(string) [ MATNodes(string) MATWeights(string) VARNodes(string) VARWeights(string) ]


if ("`type'" ~= "GQU" & "`type'" ~= "GQN" & "`type'" ~= "KPU" & "`type'" ~= "KPN" ) error("type must be GQU, GQN, KPU, or KPN")
if ("`matnodes'" == "" & "`matweights'" == "" & "`varnodes'" == "" & "`varweights'" == "" ) {
	local matnodes = "nodes" 
	local matweights = "weights" 
}

local _nn = 0
mata: nw = nwspgr("`type'",`dimensions',`accuracy')
mata: st_local("_nn",strofreal(rows(nw)))

if ("`matnodes'" ~= "" ) mata: st_matrix("`matnodes'",nw[.,1..`dimensions'])
if ("`matweights'" ~= "" ) mata: st_matrix("`matweights'",nw[.,`dimensions'+1])
if ("`varnodes'" ~= "" ) {
	if (`_nn' > _N) set obs `_nn' 
	forvalues d = 1/`dimensions' {
		capture gen double `varnodes'`d' = .
		capture replace `varnodes'`d' = .
		mata: 	st_store(1::rows(nw),"`varnodes'`d'",nw[.,`d'])
	}	
}	
if ("`varweights'" ~= "" ) {
	if (`_nn' > _N) set obs `_nn' 
	capture gen double `varweights' = .
	mata: st_store(1::rows(nw),"`varweights'",nw[.,`dimensions'+1])
}	
	

end
