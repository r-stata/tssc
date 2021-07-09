** Examples for qv.sthlp and qvgraph.sthlp
capture program drop qv_example
program qv_example
args n

if `n'==0	{
		qui {
        sysuse census, clear
        gen dpop=death/pop*1000
    
        gen NC=region==2
        gen SO=region==3
        gen WS=region==4
        reg dpop NC SO WS medage
        qv NC SO WS, ref(NE) level(95)
    
        mat lb=e(qvlb)
        mat ub=e(qvub)
        svmat lb, names(lb)
        svmat ub, names(ub)
        gen b=(lb1+ub1)/2

        gen group=_n in 1/4
        label variable group "Region"
        label define region 1 "NE" 2 "NC" 3 "SO" 4 "WS"
        label value group region

        graph twoway scatter b group || rspike ub1 lb1 group, vert               /// 
                 legend(off) ytitle("") xlabel(, valuelab)                       ///
				 title("quasi standard errors") name(qv, replace)

		gen lb2=0
		gen ub2=0
		replace lb2=b-1.96*_se[NC] if _n==2
		replace ub2=b+1.96*_se[NC] if _n==2
		replace lb2=b-1.96*_se[SO] if _n==3
		replace ub2=b+1.96*_se[SO] if _n==3
		replace lb2=b-1.96*_se[WS] if _n==4
		replace ub2=b+1.96*_se[WS] if _n==4
		
        graph twoway scatter b group || rspike ub2 lb2 group, vert               /// 
                 legend(off) ytitle("") xlabel(, valuelab)                       ///
				 title("regular standard errors") name(regular, replace)
		
        graph combine regular qv
	}
}
		

if (`n'==1|`n'==2|`n'==3|`n'==4|`n'==5)	{
	sysuse census, clear
	gen dpop=death/pop*1000
}

if (`n'==1|`n'==2|`n'==3)	{
	gen NC=region==2
	gen SO=region==3
	gen WS=region==4
	reg dpop NC SO WS medage
}

if `n'==1	{
qvgraph NC SO WS, hori grplabel(1 Northeast 2 Northcentral 3 South 4 West)				 ///
			      rsp(lw(medium) lc(gs2)) 												///
                  xlab(-2(.5)1, labs(small)) xmtick(-2(.1)1) 							///
				  xtitle("Effect on death per 1,000 people", size(medsmall))  			///
				  ylab(,val labs(small) nogrid angle(horizontal)) 						///
				  ytitle("Region", size(medsmall)) scheme(s2mono) 
}

if `n'==2	{
qvgraph NC SO WS, hori grplabel(1 "Northeast" 2 "North central" 3 "South" 4 "West") mklab 	///
                  scat(msym(D D D D) mlabgap(2) mlabposition(12) mcolor(gs2))    			///
				  rsp(lw(medium) lc(gs2))  ylab(,notick nolab)                				///
				  xtitle("Effect on death per 1,000 people", size(medsmall)) 				///
				  scheme(s2gcolor) ylab(,nolab nogrid) yscale(r(.5(1)4.5))
}

if `n'==3	{
qvgraph NC SO WS, ref(NE) scheme(s2mono) 													///
                  rsp(lw(thick) lc(gs8)) 													///
				  ylab(-2(.5)1, labs(small) glp(dash) glc(gs8) glw(thin)) 					///
				  ymtick(-2(.1)1) xlab(,val labs(small)) 								 	///
				  ytitle("Effect on death per 1,000 people", size(medsmall))				///
				  xtitle("Region", size(medsmall))											///
				  xscale(r(.5(1)4.5))
}

if `n'==4	{
	reg dpop i.region medage
	qvgraph i.region, ytitle("Effect on death per 1,000 people", size(medsmall)) xscale(r(.5(1)4.5))
}
if `n'==5	{
	label value region	// strip value label
	reg dpop i.region medage
	qvgraph i.region, ytitle("Effect on death per 1,000 people", size(medsmall)) xscale(r(.5(1)4.5)) sav(A,replace)
}

if `n'==6	{
	sysuse lifeexp,clear
	reg popgrowth gnppc safewater ib2.region
	qvgraph ib2.region, grplabel(1 "Europe/Cen. Asia" 2 "North America" 3 "South America") 			///
				scat(mlabposition(5) mlabgap(2)) ytitle(Effects on annual % of population growth)	///
				xscale(range(.5 3.5)) xlab(, notick) scheme(sj)
}
end
