*! version 1.0.2 EMZ 11July2019  
* Changed the graph titles, x and y axes labels to reflect the updates in the reviewed paper.

*! version 1.0.1 EMZ 02April2019  
*	Changed Theta_opt so that if it is negative, it will be set to zero.  
*	Changed the graph legend so that only theta opt is shown (not the corresponding y value) 
*		and it is written out as 'optimal theta' (instead of 'θ_opt') 
*	Changed y axis title to be 'Ratio of clusters required'.  
*	Added in legend option (legendoptions) so that the user can change the options of the legend, 
*		for example its position on the graph.                          

* version 1.0.0 EMZ 21feb2019

* bcss: Baseline data Cluster Sample Size
* A program to generate plots examining the impact of varying amount of prospective/retrospective baseline data collection on cluster sample size with
* different cluster autocorrelation and intra-cluster correlation values
*****************************************************************************************************************************
* Pi is the cluster autocorrelation, the correlation between the underlying cluster population means at baseline and endline 
* Rho is the intra-cluster correlation (ICC)
* Total is the cluster size (n_b+n_e) when prospective data collection is selected, where n_b is the number of baseline measurements and n_e is the number of endline measurements from each cluster
* Endline is the cluster size (n_e) when retrospective data collection is selected (i.e. the baseline data of size n_b is retrospective)
* 'Theta-opt' θ_opt=(mρπ+ρ-1)/[ρm(1+π)] is the optimum proportion of baseline measurements to maximise power
* The user also has the option to specify the prospective axes (x = a PROPORTION) and the retrospective axes (x = a RATIO)
* Note from paper: "small cluster size (n_e) of 50 and large of 200, and low ICC ρ=0.01 and high ρ=0.05"
* Example commands using deafult axes ranges:
* bcss, pi(0.5 0.6 0.7) rho(0.01) pro total(200)
* bcss, pi(0.5 0.6 0.7) rho(0.01) ret endline(200)
*****************************************************************************************************************************
*****************************************************************************************************************************

capture program drop bcss
program define bcss, rclass
version 15

syntax , PIlist(numlist) Rho(real) [PROspective Total(int 0) PROPXaxis(numlist min=2 max=2) PROPYaxis(numlist min=2 max=2) PROPYStep(numlist max=1)/*
                                */ RETrospective Endline(int 0) RETXaxis(numlist min=2 max=2) RETYaxis(numlist min=2 max=2) RETYStep(numlist max=1) LEGendoptions(string)]
								
* Range checks
****************

* pi
numlist "`pilist'", sort
local n_pi : word count `pilist'
local minpi : word 1 of `r(numlist)'
local maxpi : word `n_pi' of `r(numlist)'

if `minpi'<0 | `maxpi'>1 & `maxpi'!=. { 
	di as err "pi is out of range"
	exit 198
}

* rho
if `rho'<0 | `rho'>1 & `rho'!=. { 
	di as err "rho is out of range"
	exit 198
}

* total
if `total'<0 | `total'>1000000 & `total'!=. { 
	di as err "total is out of range"
	exit 198
}


* endline
if `endline'<0 | `endline'>1000000 & `endline'!=. { 
	di as err "endline is out of range"
	exit 198
}


//determine what type of graph the user would like to compute
		
	local type = 0 			// type marks whether prospective (1) or retrospective (2) or nothing (0) was selected
	if  "`prospective'" ~= "" & "`retrospective'" ~= "" {
	
         di as error "Either pro *or* ret must be specified, for prospective or retrospective baseine data respectively."
	     exit 198
}
	else if "`prospective'" ~= "" {
		local type = 1
	}
	else if "`retrospective'" ~= "" {
		local type = 2
	}

// ensure that 'total' is not missing and 'endline' is blank if prospective data collection
if `type' == 1 & `total'==0 {

         di as error "Total must be specified for prospective baseine data."
	     exit 198
}

if `type' == 1 & `endline'!=0 {

         di as error "Endline must be blank for prospective baseine data."
	     exit 198
}

// ensure that 'endline' is not missing and 'total' is blank if retrospective data collection
if `type' == 2 & `endline'==0 {

         di as error "Endline must be specified for retrospective baseine data."
	     exit 198
}

if `type' == 2 & `total'!=0 {

         di as error "Total must be blank for retrospective baseine data."
	     exit 198
}

// ensure that the correct set of graph axes are selected, if the user defines them 
// for the prospective baseline data graph, if the user would like to select the axes ranges, propxaxis propyaxis propystep must be used 
if "`retxaxis'"~="" | "`retyaxis'"~=""  | "`retystep'"~="" local rr = 1 
else local rr = 0

if `type' == 1 & `rr' == 1  {

         di as error "Axes options with prefix p (instead of r) must be selected for prospective baseine data."
         exit 198
}


// for the retrospective baseline data graph, if the user would like to select the axes ranges, retxaxis retyaxis retystep must be used 
if "`propxaxis'"~="" | "`propyaxis'"~=""  | "`propystep'"~="" local pp = 1 
else local pp = 0

if `type' == 2 & `pp' == 1 {

         di as error "Axes options with prefix r (instead of p) must be selected for retrospective baseine data."
         exit 198
}


// if 1+ of the propective axis options have been filled out then all of them need to be specified
if `type' == 1 & `pp' == 1  {
    local countp = 0
    foreach varp in `propxaxis' `propyaxis' `propystep' {
       if "`varp'"~="" local countp= `countp' + 0.5
	 }
	 
 if `countp'>=1 & `countp'<2.5 {
    di as error "All prospective axis options must be specified: propxaxis() propyaxis() propystep()"
         exit 198
 }
}


// if 1+ of the retrospective axis options have been filled out then all of them need to be specified
if `type' == 2 & `rr' == 1  {
    local countr = 0
    foreach varr in `retxaxis' `retyaxis' `retystep' {
       if "`varr'"~="" local countr= `countr' + 0.5
	 }
	 
 if `countr'>=1 & `countr'<2.5 {
    di as error "All retrospective axis options must be specified: retxaxis() retyaxis() retystep()"
         exit 198
 }
}

// Setting the graphs (for type 0 = nothing, 1 = prospective, 2 = retrospective)
	
if `type' == 0 {

         di as error "Either pro or ret must be specified, for prospective or retrospective baseine data respectively."
         exit 198
}
	
else if `type' == 1 {					// prospective
	

set scheme s1color 

* if x and y axis ranges left blank by the user, then use defaults

if `pp' == 0 {
     local pxmin=0
	 local pxmax=0.5 
	 local pymin=1
	 local pymax=1.25
	 local pystep=0.05
      }
 else {
 
     numlist "`propxaxis'", sort
     local pxmin : word 1 of `r(numlist)'
     local pxmax : word 2 of `r(numlist)'
	 
	 numlist "`propyaxis'", sort
     local pymin : word 1 of `r(numlist)'
     local pymax : word 2 of `r(numlist)'

	 local pystep="`propystep'"
	 }
	 
* check prospective x axis range is between 0 and 1
if `pxmin'<0 | `pxmax'>1 & `pxmax'!=. { 
	di as err "prospective x axis is out of range; needs to be between 0 and 1"
	exit 198
}

* check both prospective x axes not 0
if `pxmin'==0 & `pxmax'==0 { 
	di as err "prospective x axis is out of range"
	exit 198
}


**********************
* PROSPECTIVE GRAPH
**********************


local graph_n 1
	
     foreach pi of local pilist {
	 
        local graph_nplus1 = `graph_n'+1
		* colour scheme has 15 options, so mod 15
		local graph_colour = mod(`graph_n'+11,15)
	 
	    // make theta opt and corresponding y-value
		local theta_opt`graph_n' = ((`total' * `rho' * `pi') + `rho' -1)/((`rho' * `total')*(1 + `pi'))
		* if theta opt is negative, then set to 0 as per Andrew Copas' instructions
		if `theta_opt`graph_n''<0 local theta_opt`graph_n' = 0
		local ytheta_opt`graph_n' = (1-`rho'+(`total'*`rho'*(1-`theta_opt`graph_n'')))*(1/(1-`theta_opt`graph_n''))*(1-((`pi'*`pi'*`rho'*`rho'*`total'*`total'*`theta_opt`graph_n''*(1-`theta_opt`graph_n''))/((1+(((`total'*(1-`theta_opt`graph_n''))-1)*`rho'))*(1+(((`total'*`theta_opt`graph_n'')-1)*`rho')))))/(1+((`total'-1)*`rho'))
		local roundtheta_opt`graph_n': di %5.3f `theta_opt`graph_n''
		local roundytheta_opt`graph_n': di %5.3f `ytheta_opt`graph_n''
		
		// Define graph
        local call "y = (1-`rho'+(`total'*`rho'*(1-x)))*(1/(1-x))*(1-((`pi'*`pi'*`rho'*`rho'*`total'*`total'*x*(1-x))/((1+(((`total'*(1-x))-1)*`rho'))*(1+(((`total'*x)-1)*`rho')))))/(1+((`total'-1)*`rho'))"
        
		
        // Make graph
		if "`legendoptions'"=="" local legendoptions "pos(10) ring(0) forcesize symxsize(8) symysize(1) rowgap(1) size(small) colgap(1) symplacement(left) textfirst cols(1) colfirst"
        local graphcommand "function `call', range(`pxmin' `pxmax') ylabel(`pymin'(`pystep')`pymax') color("scheme p`graph_colour'") || (scatteri `roundytheta_opt`graph_n'' `roundtheta_opt`graph_n'', mcolor("scheme p`graph_colour'") msymbol(d)), legend(on label(`graph_n' "pi =`pi'") label(`graph_nplus1' "Optimal theta = `roundtheta_opt`graph_n''") `legendoptions' )"
       
		// overlay graphs 
		local aggregate_graphcommand `aggregate_graphcommand' `graphcommand' ||

        // Make graph for next value of pi
        * local ++graph_n
		local graph_n = `graph_n'+2
		
		}
		   
graph twoway `aggregate_graphcommand' , title("total cluster size=`total', ICC=`rho'") ytitle("Proportionate change in clusters required") xtitle("Baseline data as a proportion of total") 

}
			

else if `type' == 2 {					// retrospective
			

set scheme s1color


* if x and y axis ranges left blank by the user, then use defaults

if `rr' == 0 {
     local rxmin=0
	 local rxmax=2
	 local rymin=0
	 local rymax=1
	 local rystep=0.1
 }
 else {
 
     numlist "`retxaxis'", sort
     local rxmin : word 1 of `r(numlist)'
     local rxmax : word 2 of `r(numlist)'
	 
	 numlist "`retyaxis'", sort
     local rymin : word 1 of `r(numlist)'
     local rymax : word 2 of `r(numlist)'

	 local rystep="`retystep'"
	 }

* check retrospective x axis is >=0
if `rxmin'<0 { 
	di as err "retrospective x axis is out of range; needs to be >=0"
	exit 198
}

* check both retrospective x axes not 0
if `rxmin'==0 & `rxmax'==0 { 
	di as err "retrospective x axis is out of range"
	exit 198
}

************************
* RETROSPECTIVE GRAPH
************************


local graph_n 1

	
     foreach pi of local pilist {
	 
		local graph_colour = mod(`graph_n'+2,15)
	 
	 		
		// Define graph
        local call "y = (1 - ((`pi'*`pi'*`rho'*`rho'*`endline'*`endline'*x)/((1+((`endline'-1)*`rho'))*(1+((((`endline'*x))-1)*`rho')))))"
        
		
        // Make graph
		if "`legendoptions'"=="" local legendoptions "pos(7) ring(0) forcesize symxsize(8) symysize(1) rowgap(1) size(small) colgap(1) symplacement(left) textfirst cols(1) colfirst"
        local graphcommand2 "function `call', range(`rxmin' `rxmax') yscale(range(`rxmin')) ylabel(`rymin'(`rystep')`rymax') color("scheme p`graph_colour'") , legend(on label(`graph_n' "pi =`pi'") `legendoptions')"
       
		// overlay graphs 
		local aggregate_graphcommand2 `aggregate_graphcommand2' `graphcommand2' ||

        // Make graph for next value of pi
		local graph_n = `graph_n'+1
		
		}
		   
graph twoway `aggregate_graphcommand2' , title("endline cluster size=`endline', ICC=`rho'") ytitle("Proportionate change in clusters required") xtitle("Baseline data as a ratio to endline")  			
			
}			
			
			

end
