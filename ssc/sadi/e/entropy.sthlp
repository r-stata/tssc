TITLE
'ENTROPY': module to compute Shannon, Renyi, HCT entropy & Hill numbers

DESCRIPTION/AUTHOR(S)
`entropy' calculates Shannon(1948) entropy, alpha parameterized Renyi(1961), HCT {Havrda, Charvat (1967), Tsallis (1988)} entropy and Hill's (1973) diversity measure for given parameter value. Renyi and HCT are special case of Shannon entropy and tend to Shannon as alpha --> 1. Renyi and HCT reproduce Shannon results for alpha=1, while Hill’s measure equals to exponential (Shannon) for alpha(1).

KW: Entropy
KW: Shannon
KW: Renyi
KW: Havrda
KW: Charvat
KW: Tsallis
KW: Hill Numbers

Requires: Stata version 12
Distribution-Date: 2019029
      
Author: 
Muhammad Rashid Ansari, INSEAD Business School
Support: email rashid.ansari@insead.edu

*Version January 2019
----------------------
Syntax:
entropy var [, alpha(#) by(varlist) gen ]

Description:
`entropy' calculates Shannon(1948) entropy, alpha parameterized Renyi(1961), HCT {Havrda, Charvat (1967), Tsallis (1988)} entropy and Hill's (1973) diversity measure for given parameter (0 default value). Renyi and HCT are special case of Shannon entropy and tend to Shannon as alpha --> 1. Renyi and HCT reproduce Shannon results for alpha=1, while Hill’s measure equals to exponential (Shannon) for alpha(1). 

Module supports group data and generates new variables for these measures with option `gen’.

*Shannon(1948) entropy
Shannon= - Summation_i (pi* log_pi)

*Renyi(1961) entropy
Renyi= log[summation_i (pi^q] *(1-q)^-1]

*HCT entropy: Havrda & Charvat (1967), Tsallis (1988)
HCT= 1- summation_i (pi^q)*(q-1)^-1

Renyi & HCT tend to Shannon entropy as q --> 1

*Hill’s (1973) number
Hill= summation_i(pi^q)^ 1/(1-q)

Hill=exponential(Shannon) for q=1

where 
pi= proportion of each category & sum(pi)=1
q = alpha parameter (>=0)

Options:
-------
by(varlist): group defined by `varlist' e.g. (region)
alpha: parameter value for computing Renyi, HCT & Hill numbers variables (default 0)
gen: generates variables for Shannon, Renyi, HCT & Hill numbers

Examples:
---------
entropy value
entropy value, alpha(.6)
entropy value, alpha(.6) by(region)
entropy value, alpha(.6) by(region) gen

Author:
Muhammad Rashid Ansari						
INSEAD Business School						
1 Ayer Rajah Avenue, Singapore 138676						
rashid.ansari@insead.edu

References:
Shannon, C. A Mathematical Theory of Communication. Bell Entity Technical Journal, 27 (3): 379-423. Oct. 1948

A. Rényi. On Measures of Entropy and Information. The Regents of the University of California, 1961 

M. O. Hill. Diversity and Evenness: A Unifying Notation and Its Consequences. Ecology, 54(2):427–432, Mar. 1973

J. Havrda and F. Charvát. Quantification Method of Classification Processes. Concept of Structural a-entropy. Kybernetika, 03(1):(30)–35, 1967

C. Tsallis. Possible Generalization of Boltzmann-Gibbs Statistics. Journal of Statistical Physics, 52(1-2): 479–487, 1988
