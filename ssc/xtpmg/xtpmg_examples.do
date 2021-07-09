version 9
capture log close
log using "xtpmg.log", replace



/* This do file runs all estimation commands to generate the output     */
/* in "Estimation of Nonstationsry Panels," SJ7-2, pp. 197-208		*/
/* Authored by Ed Blackburne and Mark Frank				*/

/* Please send all questions/comments regarding the xtpmg command	*/
/* to blackburne (at) shsu (dot) edu					*/


/* For more information type "help xtpmg" in the Stata command window.  */


/* Load Pesaran's OECD Data						*/


use jasa2, clear
tsset id year




/* Run an ardl(1,1,1) pooled-mean group model				*/
/* Where the long-run coefficients on pi and y are constrained to	*/
/* be equal across all panels (the coefficient on l.c will be restricted*/
/* to unity for identification).					*/

/* The short-run coefficients, d.pi and d.y, as well as the speed of 	*/
/* adustment parameter, are unrestricted				*/
/* A new variable (ec) will be created holding the cointegrating vector */
/* The *full* option indicates all parameter estimates will be reported */
 
xtpmg d.c d.pi d.y if year>=1962, lr(l.c pi y) ec(ec) full pmg

/* Test of the long-run income elasticity				*/

test [ec]y=1


/* Predict for a particular country					*/

predict dc111 if id==111, eq(id_111)


/* Test for the condition of zero adjustment for two specific countries */

test [id_111]ec=[id_112]ec=0



/* Run the same model, but only report a summary (since the full option */
/* was not specified) of regression results 				*/

xtpmg d.c d.pi d.y if year>=1962, lr(l.c pi y) ec(ec) replace pmg


/* Estimate the mean-group model					*/

xtpmg d.c d.pi d.y if year>=1962, lr(l.c pi y) ec(ec) replace mg


/* Estimate the fixed-effects model (here we use the cluster() option	*/
/* to obtain robust standard errors, a la Pesaran's original code)	*/

xtpmg d.c d.pi d.y if year>=1962, lr(l.c pi y) ec(ec) replace dfe cluster(id)


/* Perform Hausman tests 						*/

hausman mg pmg, sigmamore

hausman mg DFE, sigmamore

log close
