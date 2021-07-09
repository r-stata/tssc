*! Date    : 8 Jun 2018
*! Version : 1.03
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk
*! Sample size calculation for Gehan two-stage design

/*
 18Apr2018 v1.00 The command is born
  1May2018 v1.01 Changed the output
  8Jun2018 v1.02 Add in help file things
  2Jul2018 v1.03 Fixed bug
*/

/* START HELP FILE
title[a command to give the parameters of the single stage Gehan design]

desc[
 {cmd:sampsi_gehan} calculates the sample sizes for the first and second stages of the Gehan design
    (1961).
]
opt[beta() specifies the first stage maximum probability of seeing no responses.]
opt[p1() specifies the desired probability of response.]
opt[se()  specifies the desired standard error in the second stage.]
opt[start() specifies the smallest n to start the search from.]

example[
 {stata sampsi_gehan, p1(0.2) beta(0.05) se(0.1) }
]

author[Dr Adrian Mander]
institute[MRC Biostatistics Unit, University of Cambridge]
email[adrian.mander@mrc-bsu.cam.ac.uk]

return[n1 The first stage sample size]
return[p1 The interesting p1 ]
return[beta The type 2 error]
return[se Standard error]
return[n2 The second stage sample size]

freetext[]

references[
Gehan, E.A. (1961) The Determination of the Number of Patients Required in a Preliminary and 
Follow-Up Trial of a New Chemotherapeutic Agent. Journal of Chronic Diseases, 13, 346-353.
]

seealso[
{help sampsi_fleming} (if installed)  {stata ssc install sampsi_fleming} (to install this command)

{help simon2stage} (if installed)   {stata ssc install simon2stage} (to install this command)

]

END HELP FILE */

program define sampsi_gehan, rclass
 version 15.0
 preserve
 syntax  [, Beta(real 0.1) P1(real 0.2) SE(real 0.1) Start(integer 1)]

 mata: design = gehan(`p1', `se', `beta', `start')
 return scalar n1= A[1,1]
 return sca p1 = A[1,2]
 return local beta= A[1,3]
 return local se= A[1,4]
 return matrix n2 = n2

 restore
end

/*****************
 * Start of MATA
 *****************/
mata: 
void gehan(real scalar p1, real scalar se, real scalar beta, real scalar startn)
{
 bestn =0 
 found =0
 n=startn
 while(!found) {
   n++
   if ( binomial(n, 0, p1) <= beta) {
     bestn = n
   }
   if (bestn>0) {
     found++
   }
   if (mod(n,1000)==0) printf("{err}n exceeds %g, you might want to change the options\n", n)
 }
 
 

 printf("\n{txt}Sample size calculation for the Gehan design\n")
 printf("{dup 44:{c -}}\n")
 printf("{txt} p1={res}%g\n", p1)
 printf("{p 1 1}{txt} Probability of stopping for futility after first stage ={res}%g\n{p_end}", beta)
 printf("{txt} The first stage sample size is {res} %g\n",bestn)
 
 
  /* second stage find n2 for an se from all observed responses */
 printf("{p 1 1}{txt} The second stage sample size is found such that the estimated SE is less than {res} %g \n{p_end}",se)
 printf("{p 1 1}{txt} The possible second stage sample sizes are below:{res} \n{p_end}")


printf("\n{txt} 1st Stage   {c |} 2nd Stage \n")
printf("  responders {c |} Sample size \n")
printf("{dup 13:{c -}}{c +}{dup 12:{c -}} \n")
 for(resp = 0 ;resp<=bestn;resp++) {
   p = resp/bestn
   n2 = 0
   stde = se+1
   while (stde > se) {
     stde = sqrt(p*(1-p)/(bestn+n2))
     n2++     
   }
   n2--
   
   if (resp>0) storen2 = storen2 \ (resp,n2)
   else storen2 = (resp,n2)
   
   printf ("{res}      %5.0f  {txt}{c |}{res} %3.0f \n", resp, n2)
 }



 design = (bestn, p1, beta, se)
 st_matrix("A", design)
 st_matrix("n2", storen2)
}

end
