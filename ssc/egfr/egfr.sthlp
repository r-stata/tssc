{smcl}
{* *! version 2.01  09sep2013}{...}
{hline}
help for {cmd:egfr}{right:Version 2.01, 9 September 2013}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col: {bf:egfr}}{hline 2} Calculate estimated glomerular filtration rate (eGFR) from creatinine
and/or cystatin C and other variables

{title:Syntax}

{p 8 18 2}
{opt egfr} {ifin}, {it:options}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt f:ormula(formula_name)}}formula to use. Supported formulae are {bf:mdrd4} (the
default), {bf:mdrd6}, {bf:ckdepi}, {bf:ckdepi_pk}, {bf:ckdepi_cyc}, {bf:ckdepi_cr_cyc}, {bf:mayo}, {bf:cg},
{bf:nankivell} and {bf:schwartz}{p_end}
{synopt:{opth cr:eatinine(varname)}}serum creatinine{p_end}
{synopt:{opth cy:statinc(varname)}}serum cystatin C in mg/L{p_end}
{synopt:{opt fem:ale(expr)}}expression indicating subject is female{p_end}
{synopt:{opth age(varname)}}age in years{p_end}
{synopt:{opt prem(expr)}}expression indicating child was born prematurely{p_end}
{synopt:{opth h:eight(varname)}}height in cm{p_end}
{synopt:{opth w:eight(varname)}}weight in kg{p_end}
{synopt:{opth ur:ea(varname)}}urea; assumed to be recorded in mmol/L unless option
{it:us} specified{p_end}
{synopt:{opth alb:umin(varname)}}albumin; assumed to be recorded in g/L unless option
{it:us} specified{p_end}
{synopt:{opt b:lack(expr)}}expression indicating subject is black{p_end}
{synopt:{opt us}}use US units for creatinine, urea and albumin{p_end}
{synopt:{opt s:tandard}}creatinine is standardised or traceable to IMDS{p_end}
{synopt:{opth g:enerate(varname)}}name of eGFR variable (default is {it:egfr_formula_name}){p_end}
{synopt:{opt replace}}replace existing variable{p_end}


{title:Description}

{pstd}
{opt egfr} calculates estimated glomerular filtration rate (eGFR) in mL/min based on the serum
creatinine and/or cystatin C along with various other variables. The exact variables required depend
on the eGFR formula used and the options that the user specifies.


{title:Options for egfr}

{phang}
{opt formula(formula_name)} specifies the formula to use in calcuating the eGFR. The formulae
supported are:

{pmore}
{bf:mdrd4} 4-variable MDRD equation. This is the default when the {it:formula} option is not
specified. This formula requires the {it:age} and {it:female} options to be specified. Subjects are
assumed to be non-black unless the {it:black} option is also specified. Non-standardised serum
creatinine values are assumed unless the {it:standard} option is used.

{pmore}
{bf:mdrd6} 6-variable MDRD equation. This formula requires the {it:age}, {it:female}, {it:urea} and
{it:albumin} options to be specified. Subjects are assumed to be non-black unless the {it:black}
option is also specified. Non-standardised serum creatinines are assumed unless the {it:standard}
option is used.

{pmore}
{bf:ckdepi} Original creatinine-only CKD-EPI formula. This formula requires the {it:creatinine},
{it:age} and {it:female} options to be specified. Subjects are assumed to be non-black unless the
{it:black} option is also specified. Standardised serum creatinines are assumed.

{pmore}
{bf:ckdepi_pk} Creatinine-only CKD-EPI (Pak) formula. This formula requires the {it:creatinine},
{it:age} and {it:female} options to be specified. Standardised serum creatinines are assumed.

{pmore}
{bf:ckdepi_cyc} CKD-EPI cystatin C formula. This formula requires the {it:cystatinc}, {it:age} and
{it:female} options to be specified.

{pmore}
{bf:ckdepi_cr_cyc} CKD-EPI creatinine-cystatin C formula. This formula requires the {it:creatinine},
{it:cystatinc}, {it:age} and {it:female} options to be specified. Subjects are assumed to be
non-black unless the {it:black} option is also specified. Standardised serum creatinines are assumed.

{pmore}
{bf:mayo} Mayo quadratic formula. This formula requires the {it:age} and {it:female} options to be 
specified.

{pmore}
{bf:cg} Cockroft-Gault formula. This formula requires the {it:age}, {it:female} and {it:weight}
options to be specified.

{pmore}
{bf:nankivell} Nankivell formula for kidney transplant patients. This formula requires the
{it:female}, {it:urea}, {it:height} and {it:weight} options to be specified.

{pmore}
{bf:schwartz} Schwartz formulae for children. If the {it:standard} option is not specified then the
{it:k} constants for non-standardised creatinines are used; determining these requires the {it:age},
{it:female}, {it:height} and {it:prem} options to be specified and the eGFR is only calculated for
subjects {it:age}d 21 or younger. If the {it:standard} option is specified then a {it:k} constant of
0.413 is used; in this case only the {it:height} option needs to be specified.

{phang}
{opt creatinine(varname)} specifies the variable containing the serum creatinine. This option is
required for every eGFR formula apart from the CKD-EPI cystatin C formula. It is assumed to be
recorded in SI units (micromol/L). If the {it:us} option is specified the units are assumed to be
mg/dL.

{phang}
{opt cystatinc(varname)} specifies the variable containing the serum cystatin C in mg/L.

{phang}
{opt female(expr)} specifies an expression which evaluates as true when the subject is female. For
example, female(sex=="F")

{phang}
{opt age}(varname) specifies a variable containing the subject's age in years.

{phang}
{opt prem(expr)} specifies an expression which evaluates as true when the subject was born
prematurely. For example, prem(premature=="Y")

{phang}
{opt height(varname)} specifies a variable containing the subject's height in cm.

{phang}
{opt weight(varname)} specifies a variable containing the subject's weight in kg.

{phang}
{opt urea(varname)} specifies a variable containing the urea. By default this is interpreted as the
serum urea concentration in SI units (mmol/L). However, if the {it:us} option is specified, it is
interpreted as the blood urea nitrogen (BUN) in mg/dL.

{phang}
{opt albumin(varname)} specifies a variable containing the albumin. By default this is assumed to be
recorded in SI units of g/L. If the {it:us} option is specified the units are assumed to be g/dL.

{phang}
{opt black(expr)} specifies an expression which evaluates as true when the subject is black. For
example, black(race=="AA")

{phang}
{opt us} interpret creatinine, urea and albumin as being recorded in US units rather than SI units.
See the {it:creatinine}, {it:urea} and {it:albumin} options for more details.

{phang}
{opt standard} specifies that the creatinine values are standardised or traceable to isotope
dilution mass spectrometry (IDMS) (see Myers et al 2006). Without this option the creatinine values
are assumed to be non-standardised.

{phang}
{opt generate(varname)} allows you to specify the name of the new variable containing the eGFR.
Without this option the new variable is named {it:egfr_formulaname} eg {it:egfr_mdrd4}

{phang}
{opt replace} replace existing eGFR variable if it exists. If you use {help if} or {help in}, the
eGFR will only be overwritten in those observations meeting the {it:if} and {it:in} criteria.


{title:Examples}

{phang}{cmd:. egfr, cr(creat) age(age) female(sex=="F")}{p_end}
{phang}{cmd:. egfr, cr(creat) age(age) female(sex=="F" if !missing(sex))}{p_end}
{phang}{cmd:. egfr, cr(creat) age(age) female(sex=="F") black(black==1) gen(eGFR) replace}{p_end}
{phang}{cmd:. egfr, f(mdrd6) cr(creat) standard age(age) fem(sex=="F") urea(urea) alb(albumin) us}{p_end}
{phang}{cmd:. egfr if age<=21, f(schwartz) cr(creat) s height(height)}{p_end}


{title:Saved results}

{pstd}
{cmd:egfr} saves the summary statistics of the newly created eGFR values in r()


{title:Formuale}

{phang}{bf:4-variable MDRD equation}:{p_end}

{pmore}Without standardised creatinine (Levey et al 2000):{p_end}
{pmore}eGFR = 186 x {it:Cr}^-1.154 x {it:age}^-0.203 x 1.212 if black x 0.742 if female{p_end}

{pmore}With standardised creatinine (Levey et al 2006):{p_end}
{pmore}eGFR = 175 x {it:Cr}^-1.154 x {it:age}^-0.203 x 1.212 if black x 0.742 if female{p_end}

{pmore}where {it:Cr} is creatinine in mg/dL and {it:age} is age in years{p_end}


{phang}{bf:6-variable MDRD equation}:{p_end}

{pmore}Without standardised creatinine (Levey et al 1999):{p_end}
{pmore}eGFR = 170 x {it:Cr}^-0.999 x {it:age}^-0.176 x {it:BUN}^-.170 x {it:alb}^0.318
x 1.18 if black x 0.762 if female{p_end}

{pmore}With standardised creatinine (Levey et al 2006):{p_end}
{pmore}eGFR = 161.5 x {it:Cr}^-0.999 x {it:age}^-0.176 x {it:BUN}^-.170 x {it:alb}^0.318
x 1.18 if black x 0.762 if female{p_end}

{pmore}where {it:Cr} is creatinine in mg/dL, {it:age} is age in years, {it:BUN} is blood urea
nitrogen (mg/dL) and {it:alb} is albumin (g/dL){p_end}


{phang}{bf:CKD-EPI creatinine equation} (Levey et al 2009):{p_end}

{pmore}Females with {it:Cr}<=62 micromol/L:{p_end}
{pmore}eGFR = (144 + 22 if black) x ({it:Cr}/0.7)^-0.329 x 0.993^{it:age}{p_end}

{pmore}Females with {it:Cr}>62 micromol/L:{p_end}
{pmore}eGFR = (144 + 22 if black) x ({it:Cr}/0.7)^-1.209 x 0.993^{it:age}{p_end}

{pmore}Males with {it:Cr}<=80 micromol/L:{p_end}
{pmore}eGFR = (141 + 22 if black) x ({it:Cr}/0.9)^-0.411 x 0.993^{it:age}{p_end}

{pmore}Males with {it:Cr}<=80 micromol/L:{p_end}
{pmore}eGFR = (141 + 22 if black) x ({it:Cr}/0.9)^-1.209 x 0.993^{it:age}{p_end}

{pmore}where {it:Cr} is creatinine in micromol/L and {it:age} is age in years{p_end}


{phang}{bf:CKD-EPI (Pak) creatinine equation} (Jessani et al 2014):{p_end}

{pmore}eGFR = 0.686 x (CKD-EPI^1.059) {p_end}


{phang}{bf:CKD-EPI cystatin C equation} (Inker et al 2012):{p_end}

{pmore}eGFR = 133 x min({it:CyC}/0.8, 1)^-0.499 x max({it:CyC}/0.8, 1)^-1.328 x 0.996^{it:age}
x 0.932 if female

{pmore}where {it:CyC} is cystatin C in mg/L and {it:age} is age in years{p_end}


{phang}{bf:CKD-EPI creatinine-cystatin C equation} (Inker et al 2012):{p_end}

{pmore}eGFR = 135
x min({it:Cr}/{it:K}, 1)^{it:a} x max({it:Cr}/{it:K}, 1)^-0.601
x min({it:CyC}/0.8, 1)^-0.375 x max({it:CyC}/0.8, 1)^-0.711
x 0.995^{it:age} x 0.969 if female x 1.08 if black

{pmore}where {it:Cr} is creatinine in mg/dL, {it:CyC} is cystatin C in mg/L, {it:K} is 0.7 for
females and 0.9 for males, {it:a} is -0.248 for females and -0.207 for males, and {it:age} is age in
years{p_end}


{phang}{bf:Mayo quadratic formula} (Rule et al 2004):{p_end}

{pmore}If {it:Cr}>=0.8 mg/dL:{p_end}
{pmore}eGFR = exp(1.911 + 5.249/{it:Cr} - 2.114/{it:Cr}^2 - 0.00686x{it:age} - 0.205 if female){p_end}

{pmore}If {it:Cr}<0.8 mg/dL:{p_end}
{pmore}eGFR = exp(1.911 + 5.249/0.8 - 2.114/0.8^2 - 0.00686x{it:age} - 0.205 if female){p_end}

{pmore}where {it:Cr} is creatinine in mg/dL and {it:age} is age in years{p_end}


{phang}{bf:Cockgroft-Gault formula} (Cockroft and Gault 1976):{p_end}

{pmore}eGFR = (140 - {it:age}) x {it:weight} x (1.04 if female, 1.23 if male) / {it:Cr}{p_end}

{pmore}where {it:Cr} is creatinine in micromol/L, {it:age} is age in years and {it:weight} is weight
in kg{p_end}


{phang}{bf:Nankivell formula} (Nankivell et al 1995):{p_end}

{pmore}eGFR = 6.7/({it:Cr}/1000) + 0.25x{it:weight} - 0.5x{it:urea} - 100/({it:height}/100)^2 +
(25 if female, 35 if male){p_end}

{pmore}where {it:Cr} is creatinine in micromol/L, {it:weight} is weight in kg, {it:urea} is serum
urea in mmol/L and {it:height} is height in cm{p_end}


{phang}{bf:Schwartz formulae for children}:{p_end}

{pmore}eGFR = {it:k} x {it:height}/{it:Cr}{p_end}

{pmore}where {it:Cr} is creatinine in mg/dL, {it:height} is height in cm and{p_end}
{pmore}{it:k}=0.413 if standardised creatinine used (Schwartz et al 2009), otherwise:{p_end}
{pmore}{it:k}=0.33 if age<1 year and subject was premature (Brion et al 1986){p_end}
{pmore}{it:k}=0.45 if age<1 year and subject was not premature (Schwartz et al 1984){p_end}
{pmore}{it:k}=0.55 if age>=1 and <13 years (Schwartz et al 1976){p_end}
{pmore}{it:k}=0.55 if age>=13 and <=21 years and female (Schwartz et al 1976){p_end}
{pmore}{it:k}=0.70 if age>=13 and <=21 years and male (Schwartz et al 1985){p_end}
		

{title:References}

{phang}Saleem Jessani, Andrew S. Levey, Rasool Bux, Lesley A. Inker, Muhammad Islam, Nish Chaturvedi, 
Christophe Mariat, Christopher H. Schmid, and Tazeen H. Jafar. Estimation of GFR in South Asians: 
A Study From the General Population in Pakistan. Am J Kidney Dis. 2014 January ; 63(1): 49–58.{p_end}
{phang}Brion LP, Fleischman AR, McCarton C, Schwartz GJ. A simple estimate of glomerular filtration
rate in low birth weight infants during the first year of life: noninvasive assessment of body
composition and growth. J Pediatr. 1986 Oct.;109(4):698Ð707.{p_end}
{phang}Cockcroft DW, Gault MH. Prediction of creatinine clearance from serum creatinine.
Nephron. 1976;16(1):31-41.{p_end}
{phang}Inker LA, Schmid CH, Tighiouart H, Eckfeldt JH, Feldman HI, Greene T, et al. Estimating
glomerular filtration rate from serum creatinine and cystatin C.
N Engl J Med. 2012 Jul 5;367(1):20Ð9.{p_end}
{phang}Levey AS, Bosch JP, Lewis JB, Greene T, Rogers N, Roth D. A more accurate method to estimate
glomerular filtration rate from serum creatinine: a new prediction equation.
Modification of Diet in Renal Disease Study Group.
Ann Intern Med. 1999 Mar. 16;130(6):461-470.{p_end}
{phang}Levey AS, Stevens LA, Schmid CH, Zhang YL, Castro AF, Feldman HI, et al.
A new equation to estimate glomerular filtration rate.
Ann Intern Med. 2009 May 5;150(9):604-612.{p_end}
{phang}Levey AS, Coresh J, Greene T, Stevens LA, Zhang YL, Hendriksen S, et al.
Using standardized serum creatinine values in the modification of diet in renal disease
study equation for estimating glomerular filtration rate.
Ann Intern Med. 2006 Aug. 15;145(4):247-254.{p_end}
{phang}Levey A, Greene T, Kusek J, Beck G. A simplified equation to predict glomerular filtration
rate from serum creatinine (abstract). J Am Soc Nephrol. 2000 May 20;11(11):155A.
Available from: http://nephron.org/nephsites/nic/mdrdgfr{p_end}
{phang}Myers GL, Miller WG, Coresh J, Fleming J, Greenberg N, Greene T, et al. Recommendations for
improving serum creatinine measurement: a report from the Laboratory Working Group of the National
Kidney Disease Education Program. Clin Chem. 2006 Jan.;52(1):5-18.{p_end}
{phang}Nankivell BJ, Gruenewald SM, Allen RD, Chapman JR. Predicting glomerular filtration rate
after kidney transplantation. Transplantation. 1995 Jun. 27;59(12):1683-1689.{p_end}
{phang}Rule AD, Larson TS, Bergstralh EJ, Slezak JM, Jacobsen SJ, Cosio FG. Using serum creatinine
to estimate glomerular filtration rate: accuracy in good health and in chronic kidney disease.
Ann Intern Med. 2004 Dec. 21;141(12):929-937.{p_end}
{phang}Schwartz GJ, Haycock GB, Edelmann CM, Spitzer A. A simple estimate of glomerular filtration
rate in children derived from body length and plasma creatinine.
Pediatrics. 1976 Aug.;58(2):259-263.{p_end}
{phang}Schwartz GJ, Feld LG, Langford DJ. A simple estimate of glomerular filtration rate in
full-term infants during the first year of life. J Pediatr. 1984 Jun.;104(6):849-854.{p_end}
{phang}Schwartz GJ, Gauthier B. A simple estimate of glomerular filtration rate in adolescent boys.
J Pediatr. 1985 Mar.;106(3):522-526.{p_end}
{phang}Schwartz GJ, Mu–oz A, Schneider MF, Mak RH, Kaskel F, Warady BA, et al. New equations to
estimate GFR in children with CKD. J Am Soc Nephrol. 2009 Mar. 1;20(3):629-637.{p_end}

{title:Author}

{p 4 4 2}
Phil Clayton, ANZDATA Registry, Australia, phil@anzdata.org.au

