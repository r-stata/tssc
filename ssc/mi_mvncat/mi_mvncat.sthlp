{smcl}
{* version 1.0.1 16mar2011}
{cmd:help mi mvncat}
{hline}

{title:Title}

{p 5}
{cmd:mi mvncat} {hline 2} Assign "final" values to (mvn) imputed categorical variables

{title:Syntax}

{p 8}
{cmd:mi mvncat} {it:dset} [({it:reference})] [{it:\ dset} [({it:reference})] ... ] 
[{cmd:,} {it:options}]


{p 5 8}
where {it:dset} is a set of dummy variables, representing a variable with more than two 
categories

{p 5 8}
{it:reference} is the reference dummy. Make sure to enclose {it:reference} in parentheses.
See {help mi mvncat##ref:Should the reference dummy be specified?}


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt rep:ort}}display {it:dset} and reference category{p_end}
{synopt:{opt noup:date}}do not update MI data; see {help mi update}{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:mi mvncat} assigns "final" values to multiple imputed categorical variables, using the 
procedure described by Allison (2002:40). Categorical variables with {it:k} levels are 
supposed to be represented with {it:k - 1} dummies in the dataset. After these dummies are 
(multiple) imputed using multivariate normal regression ({help mi impute mvn}), 
{cmd:mi mvncat} assigns values 0 or 1 to each dummy, ensuring that dummies representing one 
categorical variable add up to 1. 


{title:Options}

{dlgtab:Options}

{phang}
{opt report} displays {it:dsets} and corresponding reference categories. If the reference 
dummy is not registered {it:imputed}, it is reported as "no reference category".

{phang}
{opt noupdate} suppresses {helpb mi update}. 


{title:Remarks}

{pstd}
{hi:{ul:When to use {cmd:mi mvncat}?}}

{pstd}
Suppose a dataset, containing different types of variables with arbitrary missing pattern. 
In this case multivariate normal regression may be used to (multiple) impute missing 
values. Although this method is originally designed for continuous (normally distributed) 
variables, Allison (2002:38-40) describes how the multivariate normal regression may be used 
to impute dummies or categorical variables.

{pstd}
{hi:{ul:Steps previous to {cmd:mi mvncat}}}

{phang}
1. Create {it:k - 1} dummies for each categorical variable with {it:k} levels in the 
original dataset ({it:m} = 0). You may also create all {it:k} dummies, but only impute 
{it:k - 1} later. Make sure dummies have hard missings (.a, ..., .z), where the categorical 
variable they represent has hard missings.

{phang}
2. {help mi set} your dataset {it:wide}.

{phang}
3. {help mi register} {it:imputed} the {it:k - 1} dummies for each categorical variable 
with {it:k} levels. You may register all {it:k} dummies {it:imputed}.

{phang}
4. {help mi impute mvn} values for {it:k - 1} dummies for each categorical variable with 
{it:k} levels.

{pstd}
{hi:{ul:What does {cmd:mi mvncat} do?}}

{pstd}
For a categorical variable with 3 levels (thus 2 dummies), Allison (2002:40) suggests to 

{phang}
1. calculate a reference category as {it:1 - imputed_dummy1 - imputed_dummy2}

{phang}
2. assign value 1 to whichever category has the largest (imputed) value. If the reference 
category happens to be coded 1, assign value 0 to both dummies.

{pstd}
{cmd:mi mvncat} follows this approach, assigning values 0 and 1 to all dummies that are 
a) registered {it:imputed} and b) specified in {it:dset}. 

{marker ref}
{pstd}
{hi:{ul:Should the reference dummy be specified?}}

{pstd}
Given the reference dummy has been created, it is never wrong to ...

{phang}
(a) specify the reference dummy in {it:dset}

{phang}
(b) specifiy the reference dummy in {cmd:(}{it:reference}{cmd:)}

{pstd}
..., but it is not always necessary. 

{pstd}
There are two possible scenarios after the imputation step. 

{pstd}
In the first scenario, all (soft) missing values in the {it:k-1} dummies in {it:m} = 0 are 
imputed in {it:m} > 0. In this case, {cmd:mi mvncat} determines the reference automatically. 
You do not have to specify {cmd:(}{it:reference}{cmd:)}. If the {it:{hi:k}}th dummy has been 
created, is registered {it:imputed} and specified in {it:dset}, {cmd:mi mvncat} will assign 
"final" values to all {it:k} dummies in {it:m} > 0. If the {it:{hi:k}}th dummy has not been 
created, or is not registered {it:imputed}, or is not specified in {it:dset}, only the 
{it:k-1} dummies are assigned "final" values.

{pstd}
In the second scenario, there are soft missing values in more than one imputed dummy in 
{it:m} > 0. In this case, {cmd:mi mvncat} cannot determine the reference category and will 
exit with an error. You will have to specify a reference dummy in 
{cmd:(}{it:reference}{cmd:)}. Dummies are assigned "final" values, if they have been created 
and are registred {it:imputed}. Note, that there might be a situation, in which two or more 
imputed dummies have soft missing values in {it:m} > 0, but a reference dummy has not been 
created. In this case, you have to specify {cmd:(}{it:reference}{cmd:)} and choose a 
(arbitrary) name that must not be the name of an existing variable.


{title:Example}
	
{pstd}
In this example I do {hi:not} want to show how to properly impute missing values. The point 
is to illustrate, how {cmd:mi mvncat} works.

	. sysuse nlsw88 ,clear
	(NLSW, 1988 extract)

{pstd}	
Create some missing values in {it:race} and {it:industry}.

	. replace race = . in 1/150
	(150 real changes made, 150 to missing)

	. replace industry = . in 100/300
	(201 real changes made, 201 to missing)

{pstd}
Create dummies.

	. tabulate race ,generate(race) nofreq

	. tabulate industry ,generate(ind) nofreq

{pstd}
Remember to copy hard missings from {it:race} and {it: industry} (if there are any), 
when creating the dummies. One way to do this, is using the {help chm} prefix (if installed) 
with {help tabulate}.

{pstd}
Declare data to be MI data. Note that {cmd:mi mvncat} requires the {it:style} to be "wide". 

	. {help mi set} wide

{pstd}
Register variables to be imputed. Here the reference category for {it:industry} is not 
registered and will therefore not exist in imputed datasets ({it:m} > 0).

	. {help mi register} imputed race1 race2 race3 ind1-ind3 ind5-ind12

{pstd}
Impute values using mvn-method (see {help mi impute}). Choose {it:race2} and {it:ind4} as 
reference categories.

	. mi impute mvn ///
	  race1 race3 ind1-ind3 ind5-ind12 = age married grade wage ,add(5)

	[output omitted]

	. list  _1_race1 _1_race2 _1_race3 _5_ind1 _5_ind2 _5_ind12 in 96/105

	     +-----------------------------------------------------------------+
	     | _1_race1   _1_race2   _1_race3    _5_ind1    _5_ind2   _5_ind12 |
	     |-----------------------------------------------------------------|
	 96. |  1.26249          .    .113094          0          0          0 |
	 97. |  .061359          .    .017226          0          0          0 |
	 98. |  1.23018          .   -.110508          0          0          0 |
	 99. |  .500781          .    .057241          0          0          0 |
	100. |  .364564          .    .048897   -.086906   -.013051    .425884 |
	     |-----------------------------------------------------------------|
	101. |  1.32567          .    .145112   -.073345   -.035808   -.292849 |
	102. |  1.48026          .     .04562   -.057562   -.080453    .094772 |
	103. |  .290545          .    .027436   -.039534   -.021071   -.034177 |
	104. |  1.62895          .   -.031766   -.060089    .013959    -.23388 |
	105. |  1.21151          .   -.006183     .02949   -.006173    .528441 |
	     +-----------------------------------------------------------------+

{pstd}
Since all variables listed are dummies, representing categorical variables, they should 
only contain values 0 and 1 (as the non-missing observations 96-99 in _5_ind{it:x}).
Furthermore dummies representing one categorical variable should add up to 1.

	{cmd:. mi mvncat race1 race2 race3 \ ind1-ind12}

	. list  _1_race1 _1_race2 _1_race3 _5_ind1 _5_ind2 _5_ind12 in 96/105

	     +---------------------------------------------------------------+
	     | _1_race1   _1_race2   _1_race3   _5_ind1   _5_ind2   _5_ind12 |
	     |---------------------------------------------------------------|
	 96. |        1          0          0         0         0          0 |
	 97. |        0          1          0         0         0          0 |
	 98. |        1          0          0         0         0          0 |
	 99. |        1          0          0         0         0          0 |
	100. |        0          1          0         0         0          0 |
	     |---------------------------------------------------------------|
	101. |        1          0          0         0         0          0 |
	102. |        1          0          0         0         0          0 |
	103. |        0          1          0         0         0          0 |
	104. |        1          0          0         0         0          0 |
	105. |        1          0          0         0         0          0 |
	     +---------------------------------------------------------------+

{pstd}
Omitting {it:race2} (the reference) from {cmd:mi mvncat race1 race2 race3} will leave 
{it:_1_race2} (and all {it:_m_race2}) unchanged (i.e. soft missing), while still 
correctly assigning values 0 or 1 to {it:_m_race1} and {it:_m_race3}.


{title:References}

{pstd}
Allison, Paul D. (2002) Missing Data. Thousand Oaks, CA:  Sage Publications. 


{title:Author}

{pstd}Daniel Klein, University of Bamberg, klein.daniel.81.@gmail.com

{title:Also see}

{psee}
Online: {helpb mi}, {help egen}{p_end}

{psee}
if installed: {help chm}{p_end}
