{smcl}
{* *! version 0.1 16 Dec 2016}{...}
{viewerjumpto "Syntax" "qlqc15##syntax"}{...}
{viewerjumpto "Description" "qlqc15##description"}{...}
{viewerjumpto "Options" "qlqc15##options"}{...}
{viewerjumpto "Examples" "qlqc15##examples"}{...}
{viewerjumpto "References" "sf12##references"}{...}
{viewerjumpto "Author" "sf12##author"}{...}
{title:Title}
{phang}
{bf:qlqc15} {hline 2} Scoring of the EORTC QLQ-C15-PAL

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:qlqc15}
varlist(min=15
max=15
numeric)
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:eplace}} overwrite existing qlq output variables.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd} 
The EORTC QLQ-C15-PAL is an abbreviated 15-item version of the EORTC QLQ-C30 
(version 3.0) developed for palliative care.

{pstd} 
The 15 items are:{break}
q1 = Short walk{break}
q2 = In bed{break}
q3 = Need help{break}
q4 = Short of breath{break}
q5 = Pain{break}
q6 = Trouble sleeping{break}
q7 = Felt weak{break}
q8 = Lacked appetite{break}
q9 = Felt nauseated{break}
q10 = Been constipated{break}
q11 = Been tired{break}
q12 = Pain interference{break}
q13 = Felt tense{break}
q14 = Felt depressed{break}
q15 = Quality of life

{pstd}
Based on 15 variables where the first 14 are scored 1-4 (1='Not at all', 
2='A little', 3='Quite a bit', and 4='Very much') and the fifteenth is scored 
1-7 (1='Very poor' and 7='Excellent') {cmd:qlqc15} calculates function scales, 
symptom scales and single-item scales.
The scales are labeled in accordance with the descriptions for the QLQ-C15-PAL.

{pstd} 
The shortened scales qlq_pf, qlq_ef, qlq_fa, and qlq_nv are scored using the 
special QLQ-C15-PAL scoring while the remaining scales (qlq_ql2, qlq_pa, qlq_dy, 
qlq_sl, qlq_ap, and qlq_co) are scored according to the original scoring 
procedures described in the QLQ-C30 Scoring Manual.

{pstd}
Missing values or out of range input values are all handled as missings and 
value based on these inputs are calulated.

{marker examples}{...}
{title:Examples}

{pstd}Generating the 15 input variables (example data) in correct order:{end}

	{stata `"clear"'}
	{stata `"set obs 4"'}
	{stata `"generate q1 = _n"'}
	{stata `"generate q2 = q1"'}
	{stata `"generate q3 = q1"'}
	{stata `"fillin *"'}
	{stata `"drop _fillin"'}
	{stata `"generate q4 = q3 if _n < 5"'}
	{stata `"generate q5 = q2 if _n < 17"'}
	{stata `"generate q6 = q3 if _n < 5"'}
	{stata `"generate q7 = q2 if _n < 17"'}
	{stata `"generate q8 = q3 if _n < 5"'}
	{stata `"generate q9 = q3 if _n < 5"'}
	{stata `"generate q10 = q3 if _n < 5"'}
	{stata `"generate q11 = q3 if _n < 17"'}
	{stata `"generate q12 = q3 if _n < 17"'}
	{stata `"generate q13 = q2 if _n < 17"'}
	{stata `"generate q14 = q3 if _n < 17"'}
	{stata `"generate q15 = _n if _n < 8"'}

{pstd}Run the command on the 15 input variables:

	{stata `"qlqc15 q*"'}

{pstd}See the result variables:

	{stata `"list qlq*, sep(4)"'}

     +-------------------------------------------------------------------------------------------+
     | qlq_pf2   qlq_ef   qlq_ql2   qlq_fa   qlq_nv   qlq_pa   qlq_dy   qlq_sl   qlq_ap   qlq_co |
     |-------------------------------------------------------------------------------------------|
  1. |   93.33   100.00      0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00 |
  2. |   73.33    83.33     16.67    22.22    16.67    16.67    33.33    33.33    33.33    33.33 |
  3. |   60.00    66.67     33.33    33.33    50.00    33.33    66.67    66.67    66.67    66.67 |
  4. |   46.67    50.00     50.00    55.56   100.00    50.00   100.00   100.00   100.00   100.00 |
     |-------------------------------------------------------------------------------------------|
  5. |   73.33    83.33     66.67    22.22        .    16.67        .        .        .        . |
  6. |   60.00    66.67     83.33    33.33        .    33.33        .        .        .        . |
  7. |   46.67    50.00    100.00    55.56        .    50.00        .        .        .        . |
  8. |   33.33    41.67         .    66.67        .    66.67        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
  9. |   60.00    66.67         .    33.33        .    33.33        .        .        .        . |
 10. |   46.67    50.00         .    44.44        .    50.00        .        .        .        . |
 11. |   33.33    41.67         .    66.67        .    66.67        .        .        .        . |
 12. |   26.67    16.67         .    88.89        .    83.33        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 13. |   46.67    50.00         .    44.44        .    50.00        .        .        .        . |
 14. |   33.33    41.67         .    66.67        .    66.67        .        .        .        . |
 15. |   26.67    16.67         .    88.89        .    83.33        .        .        .        . |
 16. |   20.00     0.00         .   100.00        .   100.00        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 17. |   73.33        .         .        .        .        .        .        .        .        . |
 18. |   60.00        .         .        .        .        .        .        .        .        . |
 19. |   46.67        .         .        .        .        .        .        .        .        . |
 20. |   33.33        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 21. |   60.00        .         .        .        .        .        .        .        .        . |
 22. |   46.67        .         .        .        .        .        .        .        .        . |
 23. |   33.33        .         .        .        .        .        .        .        .        . |
 24. |   26.67        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 25. |   46.67        .         .        .        .        .        .        .        .        . |
 26. |   33.33        .         .        .        .        .        .        .        .        . |
 27. |   26.67        .         .        .        .        .        .        .        .        . |
 28. |   20.00        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 29. |   33.33        .         .        .        .        .        .        .        .        . |
 30. |   26.67        .         .        .        .        .        .        .        .        . |
 31. |   20.00        .         .        .        .        .        .        .        .        . |
 32. |   13.33        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 33. |   60.00        .         .        .        .        .        .        .        .        . |
 34. |   46.67        .         .        .        .        .        .        .        .        . |
 35. |   33.33        .         .        .        .        .        .        .        .        . |
 36. |   26.67        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 37. |   46.67        .         .        .        .        .        .        .        .        . |
 38. |   33.33        .         .        .        .        .        .        .        .        . |
 39. |   26.67        .         .        .        .        .        .        .        .        . |
 40. |   20.00        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 41. |   33.33        .         .        .        .        .        .        .        .        . |
 42. |   26.67        .         .        .        .        .        .        .        .        . |
 43. |   20.00        .         .        .        .        .        .        .        .        . |
 44. |   13.33        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 45. |   26.67        .         .        .        .        .        .        .        .        . |
 46. |   20.00        .         .        .        .        .        .        .        .        . |
 47. |   13.33        .         .        .        .        .        .        .        .        . |
 48. |    6.67        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 49. |   46.67        .         .        .        .        .        .        .        .        . |
 50. |   33.33        .         .        .        .        .        .        .        .        . |
 51. |   26.67        .         .        .        .        .        .        .        .        . |
 52. |   20.00        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 53. |   33.33        .         .        .        .        .        .        .        .        . |
 54. |   26.67        .         .        .        .        .        .        .        .        . |
 55. |   20.00        .         .        .        .        .        .        .        .        . |
 56. |   13.33        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 57. |   26.67        .         .        .        .        .        .        .        .        . |
 58. |   20.00        .         .        .        .        .        .        .        .        . |
 59. |   13.33        .         .        .        .        .        .        .        .        . |
 60. |    6.67        .         .        .        .        .        .        .        .        . |
     |-------------------------------------------------------------------------------------------|
 61. |   20.00        .         .        .        .        .        .        .        .        . |
 62. |   13.33        .         .        .        .        .        .        .        .        . |
 63. |    6.67        .         .        .        .        .        .        .        .        . |
 64. |    0.00        .         .        .        .        .        .        .        .        . |
     +-------------------------------------------------------------------------------------------+

{marker references}{...}
{title:References}

{phang}
	Mogens Groenvold and Morten Aagaard Petersen on behalf of the EORTC 
	Quality of Life Group (2006){break}
	{browse "http://www.eortc.be/qol/files/SCManualQLQ-C15-PAL.pdf":Addendum to the EORTC QLQ-C30 Scoring Manual: Scoring of the EORTC QLQ-C15-PAL}
{p_end}

{marker author}{...}
{title:Author}
{p}

{phang}{bf:Author:}{break}
 	Niels Henrik Bruun, {break}
	Section for General Practice, {break}
	Dept. Of Public Health, {break}
	Aarhus University
{p_end}
{phang}{bf:Support:} {break}
	nhbr@ph.au.dk
{p_end}
