{smcl}
{* *! version 3.0.0 06 Jan 2017}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "combival##syntax"}{...}
{viewerjumpto "Description" "combival##description"}{...}
{viewerjumpto "Options" "combival##options"}{...}
{viewerjumpto "Remarks" "combival##remarks"}{...}
{viewerjumpto "Examples" "combival##examples"}{...}
{title:Title}

{phang}
{bf:combival} {hline 2} combines values of a categorical variable over observation groups


{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:combival}
[{varname}]
[{cmd:,}
{it:options}]

{pstd}
where varname is an existing categorical variable in the working file. This so called source variable may be type numeric or type string.

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth gr:oup(varlist)}}{it:Required}. Defines the group for which the values of the source variable are to be combined. {p_end}
{synopt:{opt md(str)}}Mode option, where {it:str} is one of n|s|m. Default is n for numeric and s for string source variables. {p_end}
{synopt:{opt nc:har(#)}}Number of characters being used from the value labels or the string values, respectively, of the source variable. Default is 5.{p_end}
{synopt:{opt fr:om(#)}}Position within the label string or the string value, respectively, from where nchar begins. Default is 1.{p_end}
{synopt:{opt vl:ab(str)}}List of values and labels of the source variable used for the combination variables. If not specified, all levels of the source variable are used, except for missing values.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:combival} is a low-threshold tool for data exploration before applying more sophisticated statistical procedures. It combines values of a 
categorical variable over groups of observations defined by the mandatory option gr(), thus showing in each observation the range of a characteristic 
within the group. 

{pstd}
Optionally, a numeric and/or a string combination variable is generated, indicating all or selected levels 
of the source variable within the group.

{pstd}
Tested with a dataset of about 35 million observations, {cmd:combival} is proven to work properly with very large data sets. A feature that measures the runtime of the program is included.

{pstd}
The actual version 3.0.0 is adapted to work with Stata 14, and is tested to work with previous versions from Stata 11.2

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opth gr:oup(varlist)}   Variable(s) discriminating the groups for which all or selected levels of the source variable will be combined - quite analoguous to the 
"by varlist: " specification of the byable commands in Stata

{phang}
{opt md(str)}  Mode option, where {it:str} is one of {bf:n|s|m}.

{p 8 14 2}
md(n) generates both a numeric and a string combination variable, with unique entries of each involved level of the source variable. Available only with numeric source variables. 

{p 8 14 2}
	md(s) generates a string combination variable, with unique entries of each involved level of the source variable. 

{p 8 14 2}
	md(m) generates a string combination variable, with multiple entries of each involved level of the source variable.

{p 8 14 2}
	Defaults are md(n) for a numerical source variable and md(s) for a string source variable.

{phang}
{opt nc:har(#)}  Number of characters to extract from the value labels of the numeric source variable or the values of the string source variable. The default is 5. 

{phang}
{opt fr:om(#)}  Position from where to start the extraction of the nchar(#) characters. The default is 1. 

{phang}
{opt vl:ab(str)}  Where {it:str} is a list of values and corresponding short labels of the source variable that are to be included into the combination variables. Requirements are:

{p 8 10 2}
	- Values and short labels are to be entered alternately, separated by a blank. 

{p 8 10 2}
	- Labels must not be framed by quotation marks. 

{p 8 10 2}
	- The {bf:values} have to be existing levels of the source variable, while the {bf:short labels} may be assigned newly by vlab(). 

{p 8 8 2}
	If vlab() is not specified, all levels of the source variable are included, except for missing values. It is not possible to include missing values by specifying them via vlab(). They have to be recoded before executing combival if 
	missing values are to be included.


{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

        {help combival##introduction:Introduction}
        {help combival##technical:Details on the construction of the combination variables}
	{help combival##usecases:Typical use cases for {bf:combival}}
	{help combival##recommendations:Recommendations on the use of {bf:combival}}
	{help combival##example_1:Example 1}
	{help combival##example_2:Example 2}
	{help combival##example_3:Example 3}

{marker introduction}{...}
{title:Introduction}

{pstd}
{cmd:combival} is designed for exploratory and data preparation purposes. It creates variables that combine the levels of a source variable within a defined 
group of observations. In the terminology of Hierarchical Linear Modeling: combival generates level n+1-variables for level n-units from a level 
n-variable (see SSCC knowledge base: {browse "https://www.ssc.wisc.edu/sscc/pubs/sfr-hier.htm":Stata for Researchers: Hierarchical Data}).

{pstd}
Thus, information that is spread over several observations is compiled and displayed for each observation of the group. 
{cmd:combival} needs a hierarchical data structure in long form, meaning that an observation in the data set is a level one unit. The level one units 
have to be groupable into higher level units. This applies if there is a variable or variable list that can be 
used as an identifier for the higher level units. Typical examples for such a data structure are persons in households, persons in enterprises in countries, 
spells of a person, spells of a person in time spans, or panel data.  

{pstd}
Depending on the specification of the mode option {bf:md()} and on the type of the source variable, {cmd:combival} creates a numeric and/or a string combination variable. To ease the interpretation by humans, the values of the numeric combination 
variable are labelled automatically.


{marker technical}{...}
{title:Details on the construction of the combination variables}

{pstd}
The combination variables will automatically be named {it:combi} (numeric variable) and {it:combistr} (string variable). If one of these variables already exists, the newly created variables will be named {it:combi1} and {it:combistr1}, or, 
generalized, {it:combi#+1} and {it:combistr#+1} if one of {it:combi#} or {it:combistr#} already exists. The labels of the new variables indicate the mode ({bf:u}nique or {bf:m}ultiple), the source variable and the grouping variables. Thus you 
may generate different versions of combination variables in the same session without having to care about the variable names. 

{pstd}
Depending on the mode option {bf:md()} and on the type of the source variable, {cmd:combival} creates a numeric and/or a string combination variable. The string combination variable may contain unique or multiple entries of the levels of the 
source variable over the groups. 

{p 4 4 2}
{bf:The numeric combination variable}

{p 8 8 2}
The numeric combination variable {it:combi} is generated via a copy of the source variable. This copy has as many levels as the source variable without the missings, or as specified in the {bf:vlab()} option. While the source variable might be 
coded with negative integers or with gaps in the succession of the values, the copied variable is recoded as to have the values of the exponential function to basis 2. So if, for example, the source variable has the codes -2 -1 0 2 3 7 8, the 
copy has the codes 1 2 4 8 16 32 64. Generalized, the copy will have the levels 2^n of n nonmissing levels or levels specified in the {bf:vlab()} option of the source variable. 

{p 8 8 2}
The reason for replacing the original values with the values of the 2^n function is, that {it:combi} can then simply be constructed by adding up the values of the copied source variable. Each value of {it:combi} indicates unambiguously a specific 
combination of the (copied) source variable.

{p 8 8 2}
For example, the value 10 of {it:combi} can only be a combination of 2 and 8. There is no other way to combine the values of the 2^n function that results in 10. However, this holds only if a value of the 2^n function may be included only once.
Otherwise, more than one combination can result in a sum of 10, like 1+1+8 or 1+1+2+2+4.

{p 8 8 2} 
This is why it is not possible to create the numeric combination variable {it:combi} with the {bf:md(m)} ("multiple") option.

{p 8 8 2}
For usability reasons, {cmd:combival} labels the values of {it:combi}. For this, {bf:nchar()} characters, starting with position {bf:from()}, are taken from the value labels of the source variable. If {bf:from()} exceeds the length of the value 
labels of the source variable, the value labels of {it:combi} will be empty. If the source variable has no value labels, the labels of {it:combi} are generated from the source variable's values.

{p 8 8 2}
With Stata, value labels may only be applied to numeric variables up to data type 'long'. Because of this, the numeric combination variable can only be created from source variables that have up to 28 levels. If the source variable has more 
levels, the mode option is automatically set to {bf:md(s)}, and only a string combination variable is generated.

{p 4 4 2}
{bf:The string combination variable}

{p 8 8 2}
The string combination variable {it:combistr} is generated by collecting between 1 and 10 characters - depending on the {bf:nchar()} and {bf:from()} options - from:

{p 8 10 2}
- the value labels, if the source variable is a labelled numeric variable

{p 8 10 2}
- the values converted into a string, if the source variable is an unlabelled numeric variable

{p 8 10 2}
- the values, if the source variable is a string variable

{p 8 8 2}
As with the numeric combination variable, either all levels except the missing values, or the levels specified with the {bf:vlab()} option, enter the combination variable.


{marker usecases}{...}
{title:Typical use cases for combival}

{p 4 4 2}
A main application area is the exploration of spell data. {cmd:combival} can be used to display the parallel (isochronic) spell types of split spell data 
(see: {help splitit.ado}, also written by the authors), making it easy to identify and examine concurrencies of spell types. Also, with {cmd:combival}, 
compiling a priority list of spell types can be supported by empirical evidence of the spell type parallelities in the data instead of applying sheer 
theoretical priority considerations.

{p 4 4 2}
{cmd:combival} can also be used to display the spelltype combinations within whole life courses. For this, the data does not have to be split.

{p 4 4 2}
Another application area is the exploration of characteristics, such as nationalities or party preferences, within higher-level units, 
such as households or enterprises.

{p 4 4 2}
{cmd:combival} is most useful for exploring categorical characteristics that have more than four or five levels and different distribution patterns 
for different population groups, or with changing distribution patterns over time.


{marker recommendations}{...}
{title:Recommendations on the use of combival}

{p 4 4 2}
{bf:Numeric or string combination variable?}

{p 8 8 2}
With numeric variables a wider range of descriptive and statistical operations is available. Apart from this, the numerical combination variable
is more useful for selecting certain combinations. 

{p 8 8 2}
In contrast, the string combination variable ist more useful for selecting combinations having a certain component.

{p 4 4 2}
{bf:Recommendations on the (short) labels used to generate the combination variables}

{p 8 8 2}
While the nchar() and from() options allow for influencing the characters used as short labels, this will often not be sufficient to create suitable short labels. Short labels are suitable if they are short, self-explanatory, and not contained in
each other.

{p 8 8 2}
There are two ways to influence the short labels beyond the nchar() and from() options: create a new label set for the source variable or use 
the vlab() option. The latter will be appropriate if a) the source variable has not too many levels or 
b) you want to combine only selected levels of the source variable and therefore are using the vlab() option anyway.

{p 4 4 2}
{bf:How to display the combination variables?}

{p 8 8 2}
The labels of the numeric combination variable or the values of the string combination variable might be pretty long, depending on the number of levels of your source variable. Mostly it will be more practical to display the frequencies of the 
combination variables using {help fre.ado} instead of tab1 (if not installed, use {stata ssc install fre} to install this command).

{p 8 8 2}
It is also advisable to increase the linesize of the output.


{marker example_1}{...}
{title:Example 1}

{p 4 4 2}
combine parallel spells in order to explore the activity "being a housewife/househusband" (to use with split data, see {help splitit.ado})

   {cmd:. use testdata1_combival, clear}
   (testdata1_combival.dta)

   {cmd:. combival sptype, gr(persno begin_split) nc(9) fr(5)}
{p 4 4 2}
The above command says: combine isochronic activities (exactly concurrent activities, marked by same values in gr()-varlist) of persons. Use nine characters of the value labels of sptype (type of activity) from position 5 onwards. As md() option 
is not specified, md(n) is executed: a numeric and a string combination variable is generated.

   {cmd:. set linesize 200} 

   {cmd:. fre combistr if strpos(combistr, "House") > 0, nowrap all width(140)}
   (see user written program {help fre.ado})
   {p 4 4 2} Using Stata 14 you have to replace strpos() in the above command with ustrpos().

{res}
{txt}combistr {hline 2} uComb_sptype over persno begin_split
{txt}{hline 36}{hline 1}{c TT}{hline 44}
{txt}        {txt}                             {c |}      Freq.    Percent      Valid       Cum.
{txt}{hline 36}{hline 1}{c +}{hline 44}
{txt}Valid   Full-Time+Housewif           {c |}{res}         12       5.04       5.04       5.04
{txt}        Housewif                     {c |}{res}         17       7.14       7.14      12.18
{txt}        Housewif+Minijob             {c |}{res}         39      16.39      16.39      28.57
{txt}        Maternity+Housewif           {c |}{res}         18       7.56       7.56      36.13
{txt}        Maternity+Housewif+Minijob   {c |}{res}          6       2.52       2.52      38.66
{txt}        Part-Time+Housewif           {c |}{res}         56      23.53      23.53      62.18
{txt}        Part-Time+Housewif+Minijob   {c |}{res}         12       5.04       5.04      67.23
{txt}        Part-Time+Maternity+Housewif {c |}{res}          3       1.26       1.26      68.49
{txt}        Part-Time+Retired+Housewif   {c |}{res}         25      10.50      10.50      78.99
{txt}        Retired+Housewif             {c |}{res}         28      11.76      11.76      90.76
{txt}        Retired+Housewif+Minijob     {c |}{res}         16       6.72       6.72      97.48
{txt}        Unemploye+Housewif           {c |}{res}          6       2.52       2.52     100.00
{txt}        Total                        {c |}{res}        238     100.00     100.00           
{txt}{hline 36}{hline 1}{c BT}{hline 44}

{p 4 4 2}
Obviously, the meaning of being a housewife/househusband depends on concurrent activities. With the help of combival you can distinguish different 
combinations of activities and treat them suitably. 

{p 4 4 2} Please note: the table shows frequencies of spell splits, not frequencies of persons.


{marker example_2}{...}
{title:Example 2}

{p 4 4 2}
Explore the composition of households. As an example, the relation of the household members to the head of the household is displayed. 

   {cmd:. use testdata2_combival, clear}
   (testdata2_combival.dta)

   {cmd:. combival reltohead, gr(hhid) md(m) nc(6)}
{p 4 4 2}
The above command says: combine the relation to the head of the household. Show multiple occurrences of the same relation type and display the first 6 characters of the value labels of reltohead.

   {cmd:. set linesize 200} 

   {cmd:. fre combistr, nowrap all width(140)}
   (see user written program {help fre.ado})

{res}
{txt}combistr {hline 2} mComb_reltohead over hhid
{txt}{hline 35}{hline 1}{c TT}{hline 44}
{txt}        {txt}                            {c |}      Freq.    Percent      Valid       Cum.
{txt}{hline 35}{hline 1}{c +}{hline 44}
{txt}Valid   HHEADf+CHLD                 {c |}{res}          4       3.08       3.08       3.08
{txt}        HHEADf+CHLD+CHLD            {c |}{res}          3       2.31       2.31       5.38
{txt}        HHEADf+PRTNm                {c |}{res}          4       3.08       3.08       8.46
{txt}        HHEADf+PRTNm+CHLD           {c |}{res}         15      11.54      11.54      20.00
{txt}        HHEADf+PRTNm+CHLD+CHLD      {c |}{res}         20      15.38      15.38      35.38
{txt}        HHEADf+PRTNm+CHLD+CHLD+CHLD {c |}{res}         20      15.38      15.38      50.77
{txt}        HHEADm+CHLD                 {c |}{res}          2       1.54       1.54      52.31
{txt}        HHEADm+PRTNf                {c |}{res}         14      10.77      10.77      63.08
{txt}        HHEADm+PRTNf+CHLD           {c |}{res}          3       2.31       2.31      65.38
{txt}        HHEADm+PRTNf+CHLD+CHLD      {c |}{res}         32      24.62      24.62      90.00
{txt}        HHEADm+PRTNf+CHLD+CHLD+CHLD {c |}{res}         10       7.69       7.69      97.69
{txt}        HHEADm+PRTNm+CHLD           {c |}{res}          3       2.31       2.31     100.00
{txt}        Total                       {c |}{res}        130     100.00     100.00           
{txt}{hline 35}{hline 1}{c BT}{hline 44}

{p 4 4 2}
Due to option {bf:md(m)} (multiple entries), {it:combi} is not generated, and {it:combistr} distuingishes for the number of persons having a certain relation to the head of the household (showing here as multiple occurences of "CHLD" within the 
string).

{p 4 4 2}Please note: the table shows frequencies of persons, not frequencies of households.

{p 4 4 2}You can identify persons in single parent households simply using the condition 
{cmd: ...if strpos(combistr, "CHLD") > 0 & strpos(combistr, "PRTN") == 0}.

{p 4 4 2} Using Stata 14 you have to replace strpos() in the above command with ustrpos().

{marker example_3}{...}
{title:Example 3}

{p 4 4 2}
Explore the composition of households: Selected nationalities are combined. 

   {cmd:. use testdata2_combival, clear}
   (testdata2_combival.dta)

   {cmd:. combival nat, gr(hhid) vl(1 GER 2 TUR 5 RUS)}
{p 4 4 2}
The above command says: combine nationalities over households, but use only the levels German, Turkish, and Russian (omitted are the nationalities Romanian, Italian, Polish, Spanish). Apply the short labels GER, TUR, and RUS.

   {cmd:. bysort hhid: gen hh = cond(_n==1, 1, 0)}
   construct a marker for households

   {cmd:. fre combi if hh==1}
   (see user written program {help fre.ado})

{res}
{txt}combi {hline 2} uComb_nat over hhid
{txt}{hline 17}{hline 1}{c TT}{hline 44}
{txt}        {txt}          {c |}      Freq.    Percent      Valid       Cum.
{txt}{hline 17}{hline 1}{c +}{hline 44}
{txt}Valid   1 GER     {c |}{res}         16      41.03      41.03      41.03
{txt}        2 TUR     {c |}{res}          6      15.38      15.38      56.41
{txt}        3 GER+TUR {c |}{res}          8      20.51      20.51      76.92
{txt}        5 GER+RUS {c |}{res}          9      23.08      23.08     100.00
{txt}        Total     {c |}{res}         39     100.00     100.00           
{txt}{hline 17}{hline 1}{c BT}{hline 44}

{p 4 4 2}
To show the same thing for a string variable, type:

   {cmd:. decode nat, generate(natstr)} // create a string variable from nat
   {cmd:. combival natstr, gr(hhid) vl(German DE Turkish TR Russian RUS)}
   {cmd:. fre combistr1 if hh==1}

{res}
{txt}combistr1 {hline 2} uComb_natstr over hhid
{txt}{hline 14}{hline 1}{c TT}{hline 44}
{txt}        {txt}       {c |}      Freq.    Percent      Valid       Cum.
{txt}{hline 14}{hline 1}{c +}{hline 44}
{txt}Valid   DE     {c |}{res}         16      41.03      41.03      41.03
{txt}        DE+RUS {c |}{res}          9      23.08      23.08      64.10
{txt}        DE+TR  {c |}{res}          8      20.51      20.51      84.62
{txt}        TR     {c |}{res}          6      15.38      15.38     100.00
{txt}        Total  {c |}{res}         39     100.00     100.00           
{txt}{hline 14}{hline 1}{c BT}{hline 44}

{p 4 4 2}
Note: the tables show frequencies of households, not of persons.

{p 4 4 2}
As {bf:md(m)} for multiple entries was not specified, variables {it:combi} and {it:combistr} show only the occurrences of nationalities within households, but not how many persons have one of the nationalities within a household.

{p 4 4 2}
If a household in the test data had consisted completely of persons with omitted nationalities, 0-values had shown in the table (or missing values, for frequency tables of {it:combistr#}).


{marker:Authors}
{title:Authors}

Klaudia Erhardt, SOEP, DIW Berlin
Email {browse "mailto:firstname.givenname@domain":kerhardt@diw.de}

Ralf Kuenster, NEPS, WZB Berlin
Email {browse "mailto:firstname.givenname@domain":ralf.kuenster@wzb.eu}

Edition: V.3.0.0, January 2017
