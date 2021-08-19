//Example 2

//Load in the refugee return conjoint experiment dataset (Ghosn et al., 2021a) 
//as analysed in Ghosn et al., (2021b): 
use refugee_return_conjoint

//Estimate AMCEs across all participants and using all attributes and the 
//standard errors adjusted for clustering as shown in the left panel in Figure 3 
//of Ghosn et al., (2021b) (model 1):
conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID)

//Estimate the AMCEs by experience, or not, of violence as shown in the middle 
//and right panel in the same figure (model 2):
conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID) ///
subgroup(ExpViol)

//To replicate Figure 3, re-run model 1:
conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID)

//Save the results
matrix overall_results = e(results)

//Re-run model 2:
conjoint Chosen ChancePeace Easework HarmR NumPpl, est(amce) id(ID) ///
subgroup(ExpViol) graph(2)

//Save the results:
matrix no_exp_viol_results = e(results_No)
matrix exp_viol_results = e(results_Yes)

//Display the code used to generate the graph:
display _asis "`e(graph_code)'"

//Change the code to add our other matrix (from model 1), renaming the current 
//two matrix references to match our new matrix names, and change cols(2) to 
//cols(3) to show our plots in 3 columns:
coefplot  matrix(overall_results[,1]), bylabel(Overall) || ///
matrix(no_exp_viol_results[,1]), bylabel(No experience) || ///
matrix(exp_viol_results[,1]), bylabel(Experienced violence) ||, ci(( 5 6)) ///
keep(*:) xline(0, lpattern(-) lcolor(black)) coeflabels( Low= "Low" ///
Moderate= "Moderate" High= "High" Easy= "Easy" Moderate= "Moderate"  ///
Hard= "Hard"  Low= "Low"  Moderate= "Moderate"  High= "High"  None= "None"  ///
Some= "Some"  Many= "Many" ) eqlabels( "{bf:Chance of peace lasting a year}" ///
"{bf:Ease of finding work}" "{bf:Chance of harm on route}" ///
"{bf:Number of people known there}", asheadings) byopts(graphregion(col(white)) ///
cols(3)) subtitle(, fcolor (gs15)) scale(0.7) xtitle({bf:Estimated AMCEs})

//Change the code to make the labels and markers small:
coefplot  matrix(overall_results[,1]), bylabel(Overall) || ///
matrix(no_exp_viol_results[,1]), bylabel(No experience) || ///
matrix(exp_viol_results[,1]), bylabel(Experienced violence) ||, ci(( 5 6)) ///
keep(*:) xline(0, lpattern(-) lcolor(black)) coeflabels( Low= "Low"  ///
Moderate= "Moderate"  High= "High"  Easy= "Easy"  Moderate= "Moderate"  ///
Hard= "Hard"  Low= "Low"  Moderate= "Moderate"  High= "High"  None= "None"  ///
Some= "Some"  Many= "Many", labsize(small)) eqlabels( ///
"{bf:Chance of peace lasting a year}" "{bf:Ease of finding work}" ///
"{bf:Chance of harm on route}" "{bf:Number of people known there}", ///
asheadings labsize(small)) byopts(graphregion(col(white)) cols(3)) ///
subtitle(, fcolor (gs15) size(small)) scale(0.7) xtitle({bf:Estimated AMCEs}, ///
size(small))  xlabel(,labsize(small)) msize(small)