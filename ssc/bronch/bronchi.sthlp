{smcl}
{* *! version 1.1.0  15July2011}{...}
{cmd:help bronch}
{hline}

{title:Title}


{phang}
{bf:bronch} {hline 2} Calculates severity of illness in bronchiolitis using the National Children's Hospital 
severity of bronchiolitis model, (NCH-SOB).



{title:Syntax}

{p 8 17 2}
{cmdab:bronch:}
[ work_of_breathing  tachycardia age dehydration]
{if} [{cmd:,} {it:options}]

{p 8 17 2}
{cmdab:bronchi:}
[ work_of_breathing  tachycardia age dehydration]
{if} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nch:}}uses coefficients based on an inpatient derivation dataset, the default{p_end}
{synopt:{opt ol:hsc}}uses coefficients based on an emergency department validation dataset{p_end}
{synopt:{opt print:screen}}sends the output to a printer{p_end}
{synopt:{opt adm:it}}calculates the probability of admission{p_end}
{synopt:{opt dis:charge}}calculates the probability of discharge{p_end}
{synopt:{opt prob:abilities}}calculates the probability of a patient falling into another severity category{p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}

{p 4 6 2}


{title:Description}

{pstd}
{cmd:bronch} calculates the severity of illness for infants presenting with bronchiolitis. It relies on four variables
  age(in months), dehydration classified as none(0) mild(1) moderate(2) or severe(3), tachycardia (heart 
  rate at or above the 98th centile for age), Increased work of breathing defined as (1)for moderate or severe increase in
  work of breathing and (0) otherwise.{p_end}
  
{pstd}
  This command categorizes bronchiolitis severity as mild, moderate or severe using an ordinal logistic regression 
  model.   {cmd:bronch } expects data in the wide format i.e. one observation per row and all the required 
  variables in that row. When issuing bronch the order in which the variables are specified matters. After executing  {cmd:bronch }
  stata issues a warning to the user reminding them which variable has been used 
  to specify each component in the model. It is the user's to ensure that
  they have correctly specified the variables used to calculate the score.  {p_end}
 
 {pstd}


{title:Options}

{dlgtab:Main}

{phang}
{opt nch} uses coefficients based on an inpatient derivation dataset. This is the default. 
The coefficients (odds ratio)for this option are as follows. Age *** ()per month, Dehydration  ***()
per step increase from none,mild, moderate, severe, Tachycardia ** (), Increased work of breathing** ()

{phang}
{opt olhsc} uses coefficients based on an emergency department validation dataset.  The coefficients 
(odds ratio)for this option are as follows. Age *** ()per month, Dehydration  ***()
per step increase from none,mild, moderate, severe, Tachycardia ** (), Increased work of breathing** ()

{phang}
{opt probabilities} calculates the proabability for each observation falling within each bronchiolitis 
severity classification (mild, moderate, severe). This option creates three new variables for each observation 
 _pmild _pmoderate and _psevere containing the values for the mild moderate and severe categories respectively.

{phang}
{opt admit} calculates the proabability for each observation of not having mild disease. This is the probability
of admission when using the {bf}ohlsc {sf} option and the probability of being discharged in less than one day with 
the {bf}nch{sf} option. This option creates a new variable for each observation _padmit.

{phang}
{opt printscreen} sends the output to the screen.

{phang}
{opth generate(newvar)} creates {it:newvar} containing the value for bronchiolitis severity.If not specified the 
default is bronch.


{title:Saved Results}

{dlgtab:Support}

{phang}
{opt _bronch} contains the severity of bronchiolitis (i.e. mild, moderate, or severe)

{phang}
{opt _pmild} contains the probability of mild disease

{phang}
{opt _pmoderate} contains the probability of moderate disease

{phang}
{opt _psevere} contains the probability of severe disease

{phang}
{opt _tachycardia_product} contains the product of the coeficient (odds ratio) of tachycardia and the record value for each observation

{phang}
{opt _age_product} contains the product of the coeficient (odds ratio) of age and the record value for each observation

{phang}
{opt _dehydration_product} contains the product of the coeficient (odds ratio) of dehydration and the record value for each observation

{phang}
{opt _work_of_breathing_product} contains the product of the coeficient (odds ratio) of work of breathing and the record value for each observation

{phang}
{opt _Z} contains the summation of the products of the four parameters for each observation

{phang}
{opt _Z_difference_Zi_k1} contains the data that corresponds to mild disease for each observation

{phang}
{opt _difference_Zi_k2} contains the data that corresponds to both mild and moderate disease for each observation

{phang}
{opt _probability_Zi_k2} contains the combined probability of mild and moderate disease for each observation

{phang}
{opt _logit1_1} contains the probability of mild disease

{phang}
{opt _logit2_1} contains the probability of moderate disease

{phang}
{opt _logit3_1} contains the probability of severe disease

{phang}
{opt _padmit} contains the probability of admission using anything greater than mild disease as a surrogate marker for a patient that should be admitted

{phang}
{opt _discharge} contains the probability of discharge using mild disease as a surrogote marker for a dischargable patient

{phang}
{opt _wob_processed} contains a simplified version of the mapped work of breathing data 

{phang}
{opt _wob_processed_mod} contains the mapped work of breathing data as described in the algorithm in reference 1

{phang}
{opt _age_processed} contains the mapped age data as described in the algorithm in reference 1

{phang}
{opt _dehyd_processed} contains the mapped dehydration data as described in the algorithm in reference 1

{phang}
{opt _tachy_processed} contains the mapped tachycardia data as described in the algorithm in reference 1

{phang}
{opt _missing_wob} contains the number of observation with missing data for work of breathing

{phang}
{opt _missing_age} contains the number of observation with missing data for age

{phang}
{opt _missing_tachy} contains the number of observation with missing data for tachycardia

{phang}
{opt _missing_dehydration} contains the number of observation with missing data for dehydration

{phang}
{opt _valid_calculation} contains the number of observation with valid data


{title:Remarks}
{pstd}

 The NCH-SOB was derived in one childrens hospital where mild was defined as immediate 
 discharge on review of the resident admission by an attending pediatrician, moderate as 
 hospital admission less than and including median length of stay, and severe disease as 
 admission greater than the median length of stay. The model was validated in another 
 childrens hospital Emergency Department. In the validation 'mild' severity was based on 
 actual discharge from the  pediatric emergency room by a resident with at least five years
 post graduate training.  'Moderate' disease was defined as hospital admission less than and 
 including median length of stay, and 'severe' disease as admission for greater than the 
 median length of stay. The median length of stay was the same in both derivation and 
 validation phases. 
 
 
 Both models satisfied the proportional odds assumption. Users may select which coefficents 
 to use based on whether they are dealing primarily with inpatient or outpatient data. Full 
 details of the model used in this severity of illness classification tool can be found in
 reference 1.
 
{pstd}

{title:Examples}


{phang}
{cmd:. bronchi mild  150 2 mild }  

{phang}
{cmd:. bronch work_of_breathing  tachycardia age dehydration }

{phang}
{cmd:. bronch work_of_breathing  tachycardia age dehydration , olhsc prob admit }

{phang}
{cmd:. bronch work_of_breathing tachycardia age dehydration, by(gender) }
{p_end}
{pstd}



{title:Authors}
{pstd}

Carl E. Mitchell
Department of Emergency Medicine
Kern Medical Center
Bakersfield, CA 93306

{pstd}

Paul Walsh
Department of Emergency Medicine
Kern Medical Center
Bakersfield, CA 93306


{title:References}
{pstd}

 Walsh, P.  Rothenberg, S.J.,  O'Doherty, S., Hoey, H. and  Healy, R. 2004 A validated clinical
 model to predict the need for admission and length of stay in children with acute 
 bronchiolitis.{it} European Journal of Emergency Medicine {sf} 11:5 265-72

{pstd}

