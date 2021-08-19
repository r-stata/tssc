{smcl}
{* *! version 0.1 22Dec2020}{...}
{right:also see:  {help stpm2}, {help strcs}}
{hline}

{title:Title}

{p2colset 5 18 16 2}{...}
{p2col :{hi:mrsprep} {hline 2}}Prepare data for fitting a marginal relative survival model{p_end}
{p2colreset}{...}


{title:Syntax}
{p 8 16 2}{cmd:mrsprep} {cmd:using} {it:filename}{ifin}, {opt agediag(varname)} {opt datediag(varname)} {opt breaks(numlist)} [{it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Options}
{synopt :{opt aged:iag(varname)}}age at diagnosis (in years){p_end}
{synopt :{opt br:eaks(numlist)}}break points to calculate time-dependent weights{p_end}
{synopt :{opt dated:iag(varname)}}date at diagnosis (in years){p_end}
{synopt :{opt by:(varlist)}}calculate mean hazard and weights separately by {varlist}{p_end}
{synopt :{opt indw:eights(varname)}}individual level weights{p_end}
{synopt :{opt keep:(varlist)}}name of additional variables to keep in dataset{p_end}
{synopt :{opt newfr:ame(#)}}name of new frame to create{p_end}
{synopt :{opt pmage(varname)}}name of age variable in popmort file{p_end}
{synopt :{opt pmother(varname)}}name of other variables in popmort file{p_end}
{synopt :{opt pmrate(varname)}}name of rate variable in popmort file{p_end}
{synopt :{opt pmyear(varname)}}name of calendar year variable in popmort file{p_end}
{synopt :{opt pmmaxage(#)}}maximum age in popmort file{p_end}
{synopt :{opt pmmaxyear(#)}}maximum year in popmort file{p_end}
{synopt :{opt verbose}}more detailed output{p_end}

{p2colreset}{...}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:mrsprep} prepares data for fitting modelling marginal relative survival models using parametric models. 
{cmd:mrsprep} obtains the mean expected hazard rate at each event time (weighted by the inverse of expected survival) 
and expands the data so that time-dependent weights can be incorporated when subsequently fitting models. 

{pstd}
By expanding the data and calculating weighted mean expected mortality rates and time-dependent weights, 
it is then possible to use standard relative survival estimation commands (e.g. {cmd:stpm2} and {cmd:strcs}) 
to directly estimate marginal relative survival. 
Including individual weights enables external (age) standardization without the need to model the effect of age.

{pstd}
The data must be {cmd:stset} before using {cmd:mrsprep}. As the data is expanded the {cmd:id()} option of {cmd:stset} must be used. There should only be 1 row of data per subject before using {cmd:mrsprep}.

{pstd}
After using using {cmd:mrsprep} a new data frame is created (default name, {cmd:mrs_data}). The original data is still available. It possible to switch between the data sets (e.g. {cmd:frame change default}).

{title:Options}

{phang}
{opt agediag(varname)} gives the name of the variable containing age at diagnosis. This should be in years. Note that if possible it is best to
avoid using truncated (integer) age as this assumes that each person was diagnosed on their birthday.{p_end}

{phang}
{opt breaks(numlist)} break points to split the time-scale for calculation of the time-dependent weights. The narrower the interval, the greater the accuracy.{p_end}

{phang}
{opt datediag(varname)} gives the name of the variable containing the date at diagnosis.{p_end}

{phang}
{opt by(varlist)} will calculate mean expected hazard rates separately by variables in {varlist}.{p_end}

{phang}
{opt indweights(varname)} incorporates individual level weights to up- or down-weight individuals relative to a reference
population. This is useful for external age standardization.{p_end}

{phang}
{opt keep(varlist)} keeps the named variables in the expanded dataset.{p_end}

{phang}
{opt newframe(framename)} gives the name of new frame to create. {cmd:mrsprep} creates a new frame {cmd:mrs_frame} which is the working frame immediately after running the command. Using {cmd:frame change default} will return to the original data frame. If the frame {cmd:mrs_frame} exists and you want to replace it use {cmd:newframe(,replace)}.{p_end}

{phang}
{opt pmage(varname)} gives the name of the age variable in the population mortality file. The default is _age. This variable cannot exist in
the patient data file, but should exist in the population mortality file.{p_end}

{phang}
{opt pmother(varname)} names additional variables in the population mortality file.  Usually this will include sex, but could
additionally be, for example, information on region, deprivation etc.  All variables listed should be in both the data and
the population mortality file.{p_end}

{phang}
{opt pmrate(varname)} gives the name of the rate variable in the population mortality file. The default is {cmd:rate}.  The rate should be expressed
per person year.  If you only have one year survival probabilities in the population mortality file, then you can obtain
the rate using gen rate = -ln(survprob), where survprob is the one year survival probability.{p_end}

{phang}
{opt pmmaxage(#)} specifies the maximum age for which general-population mortality rates are provided in the population mortality file.
Rates for individuals older than this value are assumed to be the same as for maximum age {it:#}.
The default maximum age is 99.

{phang}
{opt pmmaxyear(#)} specifies the maximum year for which general-population mortality rates are provided in the population mortality file.
Rates for individuals still at risk after this year are assumed to be the same as for maximum year {it:#}.  

{phang}
{opt pmyear(varname)} name of year variable in the population mortality file. The default is {cmd:_year}. This variable cannot exist in the patient data file, but should exist in the population mortality file.

{phang}
{opt verbose} give some details about the how far the calculations have proceeded. 

{title:Examples}

All examples use melanoma data available with {help strs}. You can either run the examples and return to your current data or leave the example data in memory.
For the latter, you should not have data in memory in the active frame.

{title:Example 1: Direct modelling of marginal relative survival}

{pstd}Load and stset melanoma data{p_end}
{phang2}
{cmd:. use "https://pclambert.net/data/melanoma.dta"}{p_end}
{phang2}
{cmd:. stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"}{

{pstd}Use mrsprep to expand data and calculate weights{p_end}
{phang2}
{cmd:. mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///}{p_end}
{p 16 20 2}
{cmd:verbose breaks(0(0.2)10)}{p_end} 

{pstd}Incorprate weights when using stset{p_end}                           
{phang2}{cmd:. stset tstop [iw=wt], enter(tstart) failure(event==1)}{p_end}	

{pstd}Fit marginal model using the weighted mean hazard{p_end}
{phang2}{cmd:. stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)}{p_end} 

{pstd}Predict marginal relative survival{p_end}
{phang2}
{cmd:range tt 0 10 101}{p_end}
{phang2}
{cmd:predict s_mrs, surv timevar(tt)}{p_end} 

{pstd}Plot results{p_end} 
{phang2}
{cmd:. twoway (line s_mrs* tt, lcolor(red..) lpattern(solid dash dash))} ///{p_end}
{p 16 20 2} 
{cmd:, legend(off) {space 44} ///}{p_end}
{p 16 20 2}
{cmd:ylabel(0.6(0.1)1, format(%3.1f)) {space 25} ///}{p_end}
{p 16 20 2}  
{cmd:ytitle("Marginal relative survival") {space 21} ///}{p_end}
{p 16 20 2}
{cmd:xtitle("Years from diagnosis")}{p_end}

{pmore}
{it:({stata "mrsprep_example, egnumber(1)":click to run Example 1})}{break}
{it:({stata "mrsprep_example, egnumber(1) leavedata":click to run Example 1 and leave data in memory})}

{title:Example 2: Incorporate individual weights for external standardization}

{pstd}Load and stset melanoma data{p_end}
{phang2}
{cmd:. use "https://pclambert.net/data/melanoma.dta"}{p_end}
{phang2}
{cmd:. stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"}{}

{pstd}Change age groups to those defined in ICSS{p_end}
{phang2}{cmd:. drop agegrp}{p_end}
{phang2}{cmd:. egen agegrp=cut(age), at(0 45 55 65 75 200) icodes}{p_end}
{phang2}{cmd:. replace agegrp = agegrp + 1}{p_end}
{phang2}{cmd:. label variable agegrp "Age group"}{p_end}
{phang2}{cmd:. label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace}{p_end}
{phang2}{cmd:. label values agegrp agegrplab}{p_end}

{pstd}Create weights in reference population (ICSS){p_end}
{phang2}{cmd:. recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)}{p_end}
         
{pstd}Calculate relative weights}{p_end}         
{phang2}{cmd:. local total= _N}{p_end}
{phang2}{cmd:. bysort agegrp: gen a_age = _N/`total'}{p_end}
{phang2}{cmd:. gen double wt_age = ICSSwt/a_age}{p_end}         

{pstd}Prepare data for marginal model{p_end}
{phang2}{cmd:. mrsprep using "https://pclambert.net/data/popmort.dta", pmother(sex) agediag(age) datediag(dx) ///}{p_end}
{p 16 20 2}{cmd:verbose breaks(0(0.2)10) {space 34} ///}{p_end}
{p 16 20 2}{cmd:indweights(wt_age) {space 40} ///}{p_end}
{p 16 20 2}{cmd:newframe(mrs_stand, replace)}{p_end}
                           
{pstd}Incorprate weights when using stset{p_end}                           
{phang2}{cmd:. stset tstop [iw=wt], enter(tstart) failure(event==1)}{p_end}					   

{pstd}Fit marginal model using the weighted mean hazard{p_end}
{phang2}{cmd:. stpm2, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)}{p_end}
                           
{pstd}Predict externally age standardized marginal relative survival{p_end}
{phang2}{cmd:. range tt 0 10 101}{p_end}
{phang2}{cmd:. predict s_mrs, surv timevar(tt) ci}{p_end}                          

{pstd}Plot results{p_end}
{phang2}{cmd:. twoway (line s_mrs* tt, lcolor(red..) lpattern(solid dash dash))} ///{p_end}
{p 16 20 2}{cmd:, legend(off) {space 44} ///}{p_end}
{p 16 20 2}{cmd:ylabel(0.6(0.1)1, format(%3.1f)) {space 25} ///}{p_end}
{p 16 20 2}{cmd:ytitle(Marginal relative survival) {space 23} ///}{p_end}
{p 16 20 2}{cmd:xtitle(Years from diagnosis)}{p_end} 
{pmore}
{it:({stata "mrsprep_example, egnumber(2)":click to run Example 2})}{break}
{it:({stata "mrsprep_example, egnumber(2) leavedata":click to run Example 2 and leave data in memory})}


{title:Example 3: Fit a parametric model for the CIF}

{pstd}Load and stset melanoma data{p_end}
{phang2}
{cmd:. use "https://pclambert.net/data/melanoma.dta"}{p_end}
{phang2}
{cmd:. stset exit, origin(dx) failure(status=1,2) id(id) exit(time dx + 10*365.24) scale(365.24)"}{}

{pstd}Change age groups to those defined in ICSS{p_end}
{phang2}{cmd:. drop agegrp}{p_end}
{phang2}{cmd:. egen agegrp=cut(age), at(0 45 55 65 75 200) icodes}{p_end}
{phang2}{cmd:. replace agegrp = agegrp + 1}{p_end}
{phang2}{cmd:. label variable agegrp "Age group"}{p_end}
{phang2}{cmd:. label define agegrplab 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+", replace}{p_end}
{phang2}{cmd:. label values agegrp agegrplab}{p_end}

{pstd}Create weights in reference population (ICSS){p_end}
{phang2}{cmd:. recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)}{p_end

{pstd}Proportion within each age group by sex to calculate weights{p_end}
{phang2}{cmd:. gen female = sex == 2}{p_end}
{phang2}{cmd:. bysort female: egen totalsex = total(sex)}{p_end}
{phang2}{cmd:. bysort agegrp female: gen a_age_sex = _N/totalsex}{p_end}
{phang2}{cmd:. gen double wt_age_sex = ICSSwt/a_age_sex}{p_end} 
{pstd}Prepare data for marginal model{p_end}
{phang2}{cmd:. mrsprep using popmort.dta, pmother(sex) agediag(age) datediag(dx) ///}{p_end}
{p 16 20 2}{cmd:pmmaxyear(2000) {space 43} ///}{p_end}
{p 16 20 2}{cmd:verbose breaks(0(0.2)10) {space 34} ///}{p_end}
{p 16 20 2}{cmd:indweights(wt_age_sex) {space 36} ///}{p_end}
{p 16 20 2}{cmd:by(female)}{p_end}

{pstd}Incorprate weights when using stset{p_end}                           
{phang2}{cmd:. stset tstop [iw=wt], enter(tstart) failure(event==1)}{p_end}	
{pstd}Fit proportional hazards marginal model{p_end}
{phang2}{cmd:. stpm2 female, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id)}{p_end}    

{pstd}Relax proportional hazards assumption{p_end}
{phang2}{cmd:. stpm2 female, scale(hazard) df (5) bhazard(meanhazard_wt) vce(cluster id) ///}{p_end}
{p 16 20 2}{cmd:tvc(female) dftvc(3)}{p_end} 

{pstd}predict externally age standardized marginal relative survival by sex{p_end}
{phang2}{cmd:. range tt 0 10 101}{p_end}
{phang2}{cmd:. predict s_mrs_male,   surv timevar(tt) ci at(female 0)}{p_end}
{phang2}{cmd:. predict s_mrs_female, surv timevar(tt) ci at(female 1)}{p_end}

{pstd}Plot results{p_end}
{phang2}{cmd:. twoway (line s_mrs_male* tt, lcolor(red..) lpattern(solid dash dash)) {space 2}///}{p_end}
{p 16 20 2}{cmd:(line s_mrs_female* tt, lcolor(blue..) lpattern(solid dash dash)) ///}{p_end}
{p 16 20 2}{cmd:, legend(off) {space 52}///}{p_end}
{p 16 20 2}{cmd:ylabel(0.6(0.1)1, format(%3.1f)) {space 33}///}{p_end}
{p 16 20 2}{cmd:ytitle(Marginal relative survival) {space 31}///}{p_end}
{p 16 20 2}{cmd:xtitle(Years from diagnosis)}{p_end}  
{pmore}
{it:({stata "mrsprep_example, egnumber(3)":click to run Example 3})}{break}
{it:({stata "mrsprep_example, egnumber(3) leavedata":click to run Example 3 and leave data in memory})}
  

{title:Author}

{pstd}
Paul Lambert, University of Leicester, UK.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})


{title:References}

Lambert PC, Syriopoulou E, Rutherford M.J. 

{title:Also see}

{psee}
 {help stpm2} {help strcs};
{manhelp stset ST}
