{smcl}
{* 2011-08-12; PR; help file to accompany ralloc v3.7.5}
{cmd:help ralloc}
{hline}

{title:Title}

{p 4 8 2}
{bf:ralloc {c -} Allocation of treatments in controlled trials using random permuted blocks}


{title:Syntax}

{p 8 17 2}
{bf:ralloc} {it:varname1}   {it:varname2}   {it:varname3} {cmd:,} {opt sav:ing}{bf:(}{it:filename1}{bf:)}  [{it:options}]

{p 8 17 2}
{bf:ralloc ?}

{p 4 4 2}
where:

{p 8}
{it: varname1} is the variable that will store the block identifier.{p_end}
{p 8}
{it: varname2} is the variable that will store the block size.{p_end}
{p 8}
{it: varname3} is the variable that will store treatment allocation.{p_end}
{p 7}
{it: filename1} is the filename (or stub of names of multiple files) that will store the randomised allocations.{p_end}


{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Common options}
{synopt:{opt idvar(varname)}}specifies variable to store unique study identifier{p_end}
{synopt:{cmdab:se:ed(}{it:#}{c |}{cmd:date)}}sets seed for the random number generator{p_end}
{synopt:{opt ns:ubj(#)}}specifies number of allocations in each stratum{p_end}
{synopt:{opt nt:reat(#)}}specifies number of treatments (1 to 10){p_end}
{synopt:{opt ra:tio(#)}}specifies allocation ratio (1:{it:#}) in 2 treatment trial. {it:#} is 1, 2, or 3{p_end}
{synopt:{opt os:ize(#)}}specifies number of different block sizes (1 to 7){p_end}
{synopt:{opt init(#)}}specifies smallest block size to be used{p_end}
{synopt:[{cmdab:no}]{opt eq:ual}}specifies whether or not the frequency of block sizes is the same{p_end}
{synopt:{opt strat:a(#)}}specifies number of strata{p_end}
{synopt:[{cmdab:no}]{opt tab:les}}requests informative tables to be displayed{p_end}
{synopt:{opt trtlab}{bf:(}{it:label1 [label2]}...{bf:)}}specifies value labels for at least one treatment{p_end}
{synopt:{opt stratla:b}{bf:(}{it:label1 label2}...{bf:)}}specifies value labels for each and every stratum 
[when no {bf:using()} file is specified]{p_end}
{synopt:[{cmdab:no}]{opt vallab}}requests value labels be attached to strata {it:and} be used as suffixes for allocation filenames{p_end}

{syntab:Special designs}
{synopt:{opt fact:or}{bf:(}{it:#1}{bf:*}{it:#2}{bf:)}}specifies a {it:#1}x{it:#2} factorial trial where 
{it:#1}, {it:#2} = 2, 3 or 4{p_end}
{synopt:{opt fact:or}{bf:(}{it:#1}{bf:*}{it:#2}{bf:*}{it:#3}{bf:)}}specifies a {it:#1}x{it:#2}x{it:#3} factorial trial
 where {it:#1}, {it:#2}, {it:#3} = 2 or 3  but subject to {it:#1} {ul:<} {it:#2} {ul:<} {it:#3} {p_end}
{synopt:{opt fra:tio}{bf:(}{it:#1} {it:#2}{bf:)}}specifies allocation ratios in a 2x2 factorial trial where 
{it:#1}, {it:#2} = 1 or 2{p_end}
{synopt:{cmdab:xo:ver(}{cmd:stand}{c |}{cmd:switch}{c |}{cmd:extra)}}specifies design of a 2x2 crossover trial{p_end}

{syntab:Saving file}
{synopt:[{cmdab:no}]{opt multif}}saves multiple files (one for each stratum) with {it:filename1} as stub{p_end}
{synopt:{cmdab:shap:e(}{cmd:long}{c |}{cmd:wide)}}specifies shape of {it:filename1}{p_end}

{syntab:File defining strata}
{synopt:{opt us:ing}{bf:(}{it:filename2}{bf:)}}names an existing .dta file holding desired stratum-specific allocation 
counts{p_end}
{synopt:{opt count:v}{bf:(}{it:varname}{bf:)}}specifies name of the numeric variable in {it:filename2} that stores desired number of 
allocations in each stratum. {bf: countv} may only be specified - and is not optional - if {bf: using} is specified{p_end}
{synoptline}


{title:Description}

{p 4 4 2}
{bf:ralloc} provides a sequence of treatments randomly permuted in blocks of
constant or varying size.  If not constant, the size and order of the blocks
are also random. Allocation may be stratified by one or more variables.
In non-factorial designs, up to 10 treatments may be specified. Randomisation may also 
proceed simultaneously on 2 factors: 2x2, 2x3, 3x2, 3x3, 2x4, 4x2, 3x4, 4x3 and 4x4 factorial 
designs are supported, or on 3 factors: 2x2x2, 2x2x3, 2x3x3 and 3x3x3 designs are supported. {bf:ralloc} 
will also handle a 2x2 crossover design with or without a supplementary 3rd period as either 
a "switchback" or "extra period" design (Jones and Kenward 1989). {p_end}

{p 4 4 2}
A typical use of {bf:ralloc} is in a randomised controlled clinical trial (RCT),
and, in particular, in a multicentred trial where balance in treatment
allocations may be desirable within centre and other defined strata.

{p 4 4 2}
The second syntax ({cmd:ralloc ?}) displays the syntax diagram for the first syntax.

{p 4 4 2}
Note that {cmd:ralloc} issues a {helpb clear} command immediately after it is invoked, so existing data in memory 
will be lost.


{title:Options}

{dlgtab:Common options}

{p 4 8 2}
{opt idvar(varname)} specifies the name of the unique subject identifier. This identifier is completely uninformative of any 
subject characteristic.

{p 4 8 2}
{cmd:seed(}{it:#}{c |}{cmd:date)} specifies the random number seed. If unspecified, the default is 1234567879. {it:#} should be an integer; if 
it is not it will be truncated. Alternatively, the word {bf:date} may be specified which invites {bf:ralloc} to set the seed to today's 
date (number of days elapsed since January 1, 1960). 

{p 4 8 2}
{opt nsubj}{bf:(}{it:#}{bf:)} specifies the total number of subjects (>0) {it:in each stratum} requiring a random treatment allocation. If 
unspecified, the default is 100. {bf:ralloc} may yield a number greater than {it:#} if this is required to complete the final block in
any stratum. {it:#} is overridden if option {bf:using()} is specified.

{p 4 8 2}
{opt ntreat(#)} specifies the number of treatment arms in a non-factorial design. {it:#} may be 2 to 10. {bf:ntreat()} 
should not be specified in a factorial design, as the number of treatment combinations is defined in the {bf:factor()} option. If 
unspecified, the default for a non-factorial design is 2.

{p 4 8 2}
{opt ratio}{bf:(}{it:#}{bf:)} specifies the ratio of treatment allocations to the arms of a 2 treatment non-factorial trial. {it:#} may 
be 1, 2 or 3, yielding a 1:1, 1:2 or 1:3 ratio of allocations respectively. For a 3 or 4 arm non-factorial trial, only 
{bf:ratio(1)}, the default, may be specified. However, one may allocate certain ratios by "tricking" {bf:ralloc} by judicious 
naming of treatments using the {bf:trtlab()} option: see Examples 9 and 10 below.

{p 4 8 2}
{opt osize}{bf:(}1{bf:|}2{bf:|}3{bf:|}4{bf:|}5{bf:|}6{bf:|}7{bf:)} specifies how many different sizes of blocks will 
be used. For example, if 3 treatment arms are chosen, then {bf:osize(5)}, the default, will yield possible block 
sizes of 3, 6, 9, 12, and 15. Note that it is quite possible not to realise some block sizes if the number of subjects 
requested by option {bf:nsubj()} is low. {bf:osize(1)} gives a constant block size.

{p 4 8 2}
{opt init(#)} specifies the initiating value of the sequence defining the block sizes. {cmd:ralloc} allows 5 schemas:{p_end}

{p 8 12 2}
(1) {it:non-factorial design with balanced allocation}: In this case the default for {cmd:init()} is the number of 
treatments given by {bf:ntreat()}. This may also be specified by {cmd:init(0)}. For example, in a 3 treatment trial, 
{cmd:init(9)} would, if the default {cmd:osize(5)} were chosen, yield block sizes of 9, 12, 15, 18 and 21. If {cmd:init()} 
were unspecified, the block sizes would be 3, 6, 9, 12 and 15.

{p 8 12 2}
(2) {it:2 treatment non-factorial design with unbalanced allocation}: When a {opt ratio} > 1 has been specified for a 2 
treatment trial, the default initiating value of the block size is ({bf:ratio} + 1).

{p 8 12 2}
(3) {it:factorial design with balanced allocation}: When not specified, the default is the number of treatment 
combinations, for example, 6 in a 2x3 design.

{p 8 12 2}
(4) {it:2x2 factorial design with unbalanced allocation}: When {opt fratio()} is specified, the default initiating 
block size is given by ((1st arg of {opt fratio()}) + 1) x ((2nd arg of {opt fratio()}) + 1).

{p 8 12 2}
(5) {it:2x2 crossover design with balanced allocation}: See case (1) above.

{p 8 12 2}
In all cases, when specified, the argument for {cmd:init()} must be an integer multiple of the appropriate default.

{p 4 8 2}
{opt [no]}{opt equal} indicates whether or not block sizes will be allocated in equal proportions. In the example given 
under the {bf:osize()} option, each block would appear on roughly 20% of occasions. This may not be desirable: too many 
small blocks may allow breaking the blind; too many large blocks may compromise balance of treatments in the event of 
premature closure. The default ({bf:noequal}) allocates treatments in proportion to elements of Pascal's triangle. 
In the above example, if {bf:equal} were not specified (or {bf:noequal} were specified), allocation of block sizes would be 
in the ratio of 1:4:6:4:1. That is, the relative frequency of small and large block sizes is down-weighted. See the 
{bf:init()} option for another way to limit the number of small blocks, albeit at the cost of increasing the number of
large blocks.  If {bf:osize()} is 1 or 2, then equality of distribution of block size(s) is forced.

{p 4 8 2}
{opt strata(#)} specifies the number of strata. The default is 1. The number of strata can be calculated as the product, 
over all stratification variables, of the levels in each stratification variable. For example, if we had a trial running 
in 10 centres and we further required balance over 2 sexes and 3 age groups, then {cmd:strata(60)} would be specified.
This option may be specified with or without the {opt using()} option (see below). If {opt using()} is not specified, each 
stratum will hold the number of allocations specified by the {opt nsubj()} option. If {opt using()} is specified, the value 
of {opt strata()} is overridden by the number of rows in {it:filename2}. 

{p 4 8 2}
{opt [no]tables} specifies whether or not a frequency distribution of block sizes is displayed for all allocations 
and, where appropriate, for each stratum. The default is {bf:notables}.

{p 4 8 2}
{opt trtlab(string1 [string2] ...)} specifies value labels for treatments.  At most 10 labels may be specified for a 
non-factorial design. The number of labels that may be specified for a factorial design is equal to the sum of the 
number of possible treatments in the two randomisation axes. For example, a 2x3 study will allow 5 labels.  Labels 
are separated by spaces and so may not themselves contain a space. A label will be truncated after the first 12 
characters. The default treatment labels are A, B, C, D, E, F, G, H, I and J. An older form of the syntax for non-factorial
designs, requiring an option for each label, {opt tr1lab(string)}, {opt tr2lab(string)}, etc., is permitted but obsolete.
Note that treatment labels need not be unique: this may be exploited to allocate treatments in ratios other than those
permitted by {bf:ratio()}.  See Examples 9 and 10 below.

{p 4 8 2}
{opt stratlab(string1 string2 ...)} specifies value labels for the strata when a {bf:using()} file is not specified. 
Labels are separated by spaces and so may not themselves contain a space. The number of labels specified must equal 
the number of strata specified in the {bf:strata()} option.  


{p 4 8 2}
{opt [no]vallab} specifies whether or not value labels will be used. The default is that they will not be used ({bf:novallab}).
If {bf:vallab} {it:is} specified then there are two situations to consider:

{p 6 8 2}
(i) a {bf:using} file is not specified:

{p 8 8 2}
In this case, the value labels will have been explicitly specified in option {bf:stratlab}. The labels will be attached to the 
numeric stratum identifying variable, {bf:StratID}, in the file of allocations. If, in addition, option {bf: multif} is specified, 
each label will form the suffix of the name of the file holding the treatment allocations for the respective stratum.

{p 6 8 2}
(i) a {bf:using} file is specified:

{p 8 8 2}
In this case, the value labels must pre-exist for each stratum-defining variable in the {bf:using} file, and will be attached to the 
numeric stratum identifying variable, {bf:StratID}, in the file of allocations. If, in addition, option {bf: multif} is specified, 
each label will form the suffix of the name of the file holding the treatment allocations for the respective stratum. Any spaces in 
a value label being used as part of a filename will be replaced by underscore characters.  The value labels of the stratum-defining 
variables in the {bf:using} file will also be attached to the same variables in the file of allocations.  

{dlgtab:Special designs}

{p 4 8 2}
{opt factor(string)} specifies that the trial has a factorial design with two or three "axes of randomisation". {it:string} 
must be one of: 2*2, 2*3, 3*2, 3*3, 2*4, 4*2, 3*4, 4*3, 4*4, 2*2*2, 2*2*3, 2*3*3 or 3*3*3. Allocation combinations are balanced 
within blocks, unless {opt fratio()} is specified in a 2x2 design. The names of the treatment variables will be 
{it:varname3}1, {it:varname3}2 and, if required for the 3-way design, {it:varname3}3.

{p 4 8 2}
{opt fratio(string)} specifies, in the case of a 2x2 factorial design, the ratio of allocations in {it:each} axis. 
The string must be one of: 1 1, 1 2, 2 1, or 2 2, that is, two digits separated by at least one space. For example, 
if we require a 1:2 ratio of treatments in the first randomisation axis and a 1:1 ratio of treatments in the 
second axis, {cmd:fratio(2 1)} would be specified.

{p 4 8 2}
{opt xover(string)} specifies the design as a 2x2 crossover. {it:string} may be one of {bf:stand} for the standard 
2 treatment, 2 period design, {bf:switch} for the switchback design where each subject receives the treatment
assigned for period 1 in period 3, or {bf:extra}, for the extra period design, where each subject has the treatment 
assigned for period 2 replicated in period 3. The names of the treatment variables will be {it:varname3}1,
{it:varname3}2 and, if required, {it:varname3}3.


{dlgtab:Saving file}

{p 4 8 2}
{cmd:saving}{bf:(}{it:filename1}{bf:)} specifies the name of the file to which data are saved. This is a required "option". 
If more than one stratum is specified by either the {cmd:strata()} option or the {cmd:using()} option then, in addition to saving 
all random allocations across all strata to {it:filename1}, allocations for each stratum may be saved to individual files (see 
option {cmd:multif}). For these, {it:filename1} is used as a stub to name one file for each stratum. There are then two cases to 
consider:

{p 6 8 2}
(i) Stratum value labels not specified {it:or} Stratum value labels specified, but option {bf:vallab} not specified: 

{p 8 8 2}
The naming schema for stratum specific files is:

{p 12 8 2}
{it:filename1_n1}[{it:_n2_n3} ... {it:_nk}]}

{p 8 8 2}
for a trial with 1 to {it:k} stratification variables. {it:n1} identifies the level of the stratum of the 1st stratification variable, 
{it:n2} gives the level of the stratum of the 2nd stratification variable, etc., each stratification variable's set of suffixes being 
preceded by an underscore character. Suffixes are padded with leading zeros to maintain alphanumeric sort order. 

{p 8 8 2}
For example, if we specified {cmd:saving(myfile)} {it:and} {cmd:multif} and we had only one stratification variable 
with 10 levels, the filenames would be: {cmd:myfile.dta}, {cmd:myfile_01.dta}, {cmd:myfile_02.dta}, ..., {cmd:myfile_09.dta}, and {cmd:myfile_10.dta}. 

{p 8 8 2}
If there were a second stratification variable, with say, 3 levels, we would have {cmd:myfile.dta} plus 30 files named: {cmd:myfile_01_1.dta}, 
{cmd:myfile_01_2.dta}, {cmd:myfile_01_3.dta}, {cmd:myfile_02_1.dta}, ....., {cmd:myfile_10_3.dta}.


{p 6 8 2}
(ii) Stratum value labels specified {it:and} option {bf:vallab} also specified:

{p 8 8 2}
The naming schema for stratum specific files is:

{p 12 8 2}
{it:filename1_valuelabel} if no {bf:using} file is specified and so labels are specified by option {bf:stratlab}.{p_end}
{p 8 8 2}
or {p_end}
{p 12 8 2}
{it:filename1_valuelabel1_valuelabel2} ...... if a {bf:using} file is specified and so labels are derived from that file.{p_end}

{p 8 8 2}
In the case where the value labels are defined directly in the {bf:stratlab} option (that is, no {bf:using} file is specified), 
then, for example, if we specified {cmd:saving(myfile)} {it:and} {cmd:multif} and we had only 1 stratification variable 
with 2 levels, and stratum labels specified as {cmd: stratlab(Seattle_Grace {bind: } Chicago_Hope)}  the names of the 3 files 
holding allocations would be: {cmd:myfile.dta}, {cmd:myfile_Seattle_Grace.dta}, and {cmd:myfile_Chicago_Hope.dta}. 

{p 8 8 2}
If there were a second stratification variable, also with, say, 2 levels, we might have specified: 
{cmd: stratlab(Seattle_Grace_Male {bind: } Seattle_Grace_Female {bind: } Chicago_Hope_Male {bind: } Chicago_Hope_Female)} and the 5 files produced 
would be: {cmd:myfile.dta}, {cmd:myfile_Seattle_Grace_Male.dta}, {cmd:myfile_Seattle_Grace_Female.dta}, {cmd:myfile_Chicago_Hope_Male.dta}, 
and {cmd:myfile_Chicago_Hope_Female.dta}.  

{p 8 8 2}
Note that each value label string must contain information on all the relevant strata, in this case, the value labels each contain information on 
{it:both} hospital and sex. Embedded spaces are not allowed.

{p 8 8 2}
In the case where the value labels are defined indirectly (that is, they are derived from the value labels of the {bf:using} file), then there will 
be separate value labels for each stratum-defining variable. For example, if the {bf:using file} had two stratum defining variables, hospital and 
sex, each of these variables will have a set of value labels. The suffix of the name of an allocation file will be a concatenation of the relevant 
label from each set, with separating underscore characters.  So, for the file saving allocations for females at Chicago Hope, the suffix will be 
{bf: Chicago_Hope_Female}, and we note that underscore characters have been substituted for the space within "Chicago Hope" {it:and} used to bind the 
two value labels.

{p 8 8 2}
If a stratum-defining variable in the {bf:using} file does not have a value label, or a value label exists but not for every level of the 
stratum, then {bf:vallab} will attach whatever value labels it can, and substitute the raw numeric value of the level for those that are not
available. (See Example 12 below).


{p 4 8 2}
{opt [no]}{opt multif} specifies that multiple files will be saved, one file holding all allocations, and a series of 
files for each stratum's allocations. The default is {cmd:nomultif} meaning that just one file holding all allocations 
will be generated.

{p 4 8 2}
{cmd:shape(long{c |}wide)} allows specification of the output to {it:filename1} (or to each of the files with prefix stub 
{it:filename1} if {opt multif} has been specified) in either long or wide form. In long form, the treatment listing is 
sequential down page within the defined block. In wide form, the treatment listing is sequential across page within 
the defined block. The default is long. A factorial or crossover design may not be specified as wide.


{dlgtab:File defining strata}

{p 4 8 2}
{opt using(filename2)} specifies a Stata .dta file defining the stratification schema. The file consists of numeric variables 
defining strata plus one other numeric variable giving the number of subjects required to be randomised in each stratum 
(the {bf:countv()} variable, see below). If the stratum-defining variables have value labels then, if option {bf:vallab} is 
specified, these labels will be used in the treatment allocation file(s). {it:filename2} should reside in the current data path. 
Each row (observation) in this file defines a stratum. Levels of each stratification variable must be coded as consecutive 
positive integers (1,2,3...). {cmd:ralloc} will check this and will also check that each stratum has been uniquely 
specified.  The program will warn, but not exit, if the product of levels over all stratification variables does not equal the
number of rows (strata).  

{p 4 8 2}
{opt countv(varname)} specifies the numeric variable in {it:filename2} whose values give the number of subjects (>0) requiring 
randomisation in each stratum. {bf:countv()} must be specified, and may only be specified, if {bf:using()} is specified. 
Values of the variable specified override the value of {bf:nsubj()} should this option also be specified.


{title:Remarks}

{p 4 4 2}
{cmd:ralloc} addresses four (of the many) objectives of the design of a RCT:{p_end}

{p 4 8 2}
(1) Random allocation of treatments to subjects. Each block represents a random permutation of up to 10
treatments specified.

{p 4 8 2}
(2) Avoiding unnecessary imbalance in the number of subjects allocated to each treatment. Allocation within blocks 
of reasonable size achieves this. In the case of a trial with {it:k} treatments, even in the event of unexpected termination 
of the trial, the imbalance (in each stratum) will be at most 1/{it:k} times the size of the largest block used.

{p 4 8 2}
(3) Maintenance of blinding by concealing the pattern of the blocks. A limited number of block sizes are chosen, the 
number depending on the {opt osize()} option. Treatments are balanced within blocks; by default, there are equal numbers of each 
treatment in each block, although the ratio may be varied (1:2 or 1:3) in a 2 treatment trial.  Block sizes are chosen 
at random with equal or unequal probabilities and then the order of block sizes is randomly shuffled. Such a scheme 
makes "breaking the blind" by working out the block pattern extremely difficult.  If, however, balance in the number 
of allocations to each treatment is more critical than increased protection against breaking the blind, {cmd:osize(1)} 
permits the choice of a constant block size. This may be desired in a trial with a small number of subjects.

{p 4 8 2}
(4) Ensuring that a record is kept of the randomisation protocol. The program saves the allocation sequence into 
user-named .dta file(s). It also (i) writes an exact copy of the user's command in a note in the data file(s) and 
(ii) writes the options specified (seed, number of subjects requested, etc.) and certain other useful information 
(number of blocks used, number of subjects randomised, identification of the levels of each stratum defining the 
schema for the current data file) as notes in the data file(s).

{p 4 4 2}
{cmd:ralloc} requires specification of 3 variables that will appear in the data set(s) that the command creates and 
saves. These are listed under the syntax paragraph. The last of these ({it:varname3}) names the treatment variable 
storing the randomly allocated treatment; values are 1, 2, 3, etc. labelled as {cmd:"A"}, {cmd:"B"}, {cmd:"C"}, etc. respectively, unless 
labels are specified with the {opt trtlab()} option. 

{p 4 4 2}
{cmd:ralloc} creates two additional variables: {p_end}

{p 6 10 2}
{bf:StratID} is an integer identifier whose value is the same for every observation in a given stratum. Optionally,
value labels, specified either by {bf:stratlab()} or, when a {bf:using()} file is used, by {bf: slabv()}, may
be attached. {p_end}

{p 6 10 2}
{bf:SeqInBlk} gives the order of the allocation within block.  This variable is explicit if {cmd:shape(long)} 
is specified, and implicit if {cmd:shape(wide)} is specified. {p_end}

{p 4 4 2}
If {opt using(filename2)} is specified, {cmd:ralloc} adds each stratification variable to the data set and fills 
observations with the values of the levels appropriate to the stratum.

{p 4 4 2}
If {cmd:shape(wide)} is specified, then each observation will be a block. {cmd:ralloc} will create {it:k} = max(blocksize) 
new variables named {it:varname3}{it:#}, where {it:#} = 1...{it:k}, to store the allocated treatments for that block.  Of course,
if a block's size, {it:j}, is such that {it:j} < {it:k}, missing values are stored in variables {it:varname3}{it:(j+1)} 
through {it:varname3}{it:k}.

{p 4 4 2}
Should the original order of allocations be disturbed, then with the data in long form, it may be restored by

{p 8 4 2}. {helpb sort} {bf:StratiD}  {it:varname1}  {bf:SeqInBlk}

{p 4 4 2}
The prudent user will open a {helpb log:log file} before issuing a command such as {cmd:ralloc}. However, even if the 
log file is lost, the data files contain, in the form of {helpb notes}, the information needed to reproduce the 
randomisation protocol. {p_end}


{title:Examples}

{p 2}
{bf:Example 1: basic example} {p_end}

{p 4 8 2}
{cmd:. ralloc block size treat, nsubj(600) seed(675) sav(mytrial) idvar(study_ID)} {p_end}
{p 4 8 2}
{cmd:. list in 1/18, sepby(block)} {p_end}

{p 4 4 2}
allocates treatments A and B at random in a ratio of 1:1 in blocks of sizes 2, 4, 6, 8 and 10 to 600 subjects. Block 
sizes are allocated unequally in the ratio 1:4:6:4:1 (Pascal's triangle). Seed is set at 675. Only 1 stratum is
specified (by default). Sequence is saved to {bf:mytrial.dta} in long form. A unique subject identifier is stored in the 
newly created variable {bf:study_ID}.{p_end}


{p 2}
{bf:Example 2: equal block distribution but 1:3 allocation ratio within each block}{p_end}

{p 4 8 2}
{cmd:. ralloc bn bs Rx, nsubj(920) nt(2) osiz(4) ra(3) init(8) eq sav(mys)} {p_end}

{p 4 4 2}
allocates treatments A and B at random in ratio of 1:3 in blocks of sizes 8, 12, 16 and 20 to 920 subjects using 
the default seed of 123456789. Roughly 25% of blocks will be of each size.  Data saved in default (long) form to
{bf:mys.dta}. Only 1 stratum (the default) is specified, and 1 file is saved. In fact, 932 subjects are allocated, the 
extra 12 being required to complete the final block (the last block's size was 16, but the 920th subject was only
the 4th in the block).{p_end}


{p 2}
{bf:Example 3: saving a file for each stratum's allocations} {p_end}

{p 4 8 2}
{cmd:. ralloc blknum blksiz Rx, ns(494) osiz(2) eq ntreat(2) sav(mywide) shap(wide) seed(date)}{p_end}
{p 8}
{cmd:trtlab(Placebo Active) strata(4) multif} {p_end}

{p 4 4 2}
allocates treatments labelled {cmd:"Placebo"} and {cmd:"Active"} equally in two block sizes, 2 and 4, to 494 subjects in each 
of 4 strata (maybe it's a 4-centre trial). The {helpb seed} is set to today's {helpb dates:date} in Stata's elapsed days 
since January 1, 1960. Data are saved in wide form to 5 files: {cmd:mywide.dta} holds all allocations, and 4 additional files 
named {cmd:mywide_1.dta}, {cmd:mywide_2.dta}, {cmd:mywide_3.dta} and {cmd:mywide_4.dta} hold stratum-specific allocations.  A truncated listing 
of data from {cmd:mywide_4.dta} looks like this (depending on today's date!):{p_end}

{p 8 4 2}
{cmd:. use mywide_4} {p_end}
{p 8 4 2}
{cmd:. li in 1/7, noobs nodisp clean} {p_end}

{space 8}{bf:StratID     blknum     blksiz        Rx1        Rx2        Rx3        Rx4}
{space 14}4        498          2    Placebo     Active          .          .
{space 14}4        499          2     Active    Placebo          .          .
{space 14}4        500          2    Placebo     Active          .          .
{space 14}4        501          4     Active    Placebo    Placebo     Active
{space 14}4        502          2    Placebo     Active          .          .
{space 14}4        503          2    Placebo     Active          .          .
{space 14}4        504          2     Active    Placebo          .          .
{p}

{p 4 4 2}
And we can easily recover the long form of the data: {p_end}

{p 8 4 2}
{cmd:. reshape long}{p_end}
{p 8 4 2}
{cmd:. sort blknum SeqInBlk}{p_end}
{p 8 4 2}
{cmd:. drop if Rx == .}{p_end}
{p 8 4 2}
{cmd:. order StratID}{p_end}
{p 8 4 2}
{cmd:. list in 1/10, noobs clean}{p_end}

{space 8}{bf:StratID     blknum   SeqInBlk     blksiz         Rx}
{space 14}4        498          1          2    Placebo
{space 14}4        498          2          2     Active
{space 14}4        499          1          2     Active
{space 14}4        499          2          2    Placebo
{space 14}4        500          1          2    Placebo
{space 14}4        500          2          2     Active
{space 14}4        501          1          4     Active
{space 14}4        501          2          4    Placebo
{space 14}4        501          3          4    Placebo
{space 14}4        501          4          4     Active
{p}


{p 2}
{bf:Example 4: unequal block size distribution and use of tables} {p_end}

{p 4 8 2}
{cmd:. ralloc blknum blksiz Rx, ns(4984) osiz(4) ntr(4) sav(mys) strat(3) tab}

{p 4 4 2}
allocates treatments A, B, C and D at random in ratio of 1:1:1:1 in blocks of sizes 4, 8, 12 and 16 to 4984 subjects 
in each of 3 strata using the default seed. Block sizes are roughly in ratio of 1:3:3:1 (since {opt equal} was {it:not} 
specified). For this example, the following tables will appear on-screen:{p_end}

{space 8}{bf:Frequency of block sizes in stratum 1:} 

{space 5}    block size |      Freq.     Percent        Cum.
{space 5}   ------------+-----------------------------------
{space 5}             4 |         62       12.50       12.50
{space 5}             8 |        183       36.90       49.40
{space 5}            12 |        185       37.30       86.69
{space 5}            16 |         66       13.31      100.00
{space 5}   ------------+-----------------------------------
{space 5}         Total |        496      100.00

{space 8}{bf:Frequency of block sizes in stratum 2:}
{space 14}{it:output not shown}

{space 8}{bf:Frequency of block sizes in stratum 3:}
{space 14}{it:output not shown}

{space 8}{bf:Frequency of block sizes over ALL data:}

{space 5}    block size |      Freq.     Percent        Cum.
{space 5}   ------------+-----------------------------------
{space 5}             4 |        179       12.01       12.01
{space 5}             8 |        555       37.22       49.23
{space 5}            12 |        577       38.70       87.93
{space 5}            16 |        180       12.07      100.00
{space 5}   ------------+-----------------------------------
{space 5}         Total |       1491      100.00

{p 4 4 2}
If one were to issue the command{p_end}

{p 8 12 2}
{cmd:. tab blksiz Rx}{p_end}

{p 4 4 2}
a table showing the frequency of treatment allocations across all strata would be produced:{p_end}

{space 8}           |                  treatment
{space 8}Block size |         A          B          C          D |     Total
{space 8}-----------+--------------------------------------------+----------
{space 8}         4 |       179        179        179        179 |       716
{space 8}         8 |      1110       1110       1110       1110 |      4440
{space 8}        12 |      1731       1731       1731       1731 |      6924
{space 8}        16 |       720        720        720        720 |      2880
{space 8}-----------+--------------------------------------------+----------
{space 8}     Total |      3740       3740       3740       3740 |     14960

{p 4 4 2}
Note that 14960 subjects were randomised, compared with 3*4984 = 14952 requested. An extra 8 subjects were required 
to ensure completeness of final blocks in the strata.{p_end}


{p 2}
{bf:Example 5: individual specification of allocations to each stratum} {p_end}

{p 4 4 2}
Let us say we have a file, {cmd:raltest6.dta}, defining strata for a RCT to be conducted in 3 centres and we also seek to 
balance allocations within 2 age groups. The number of allocations in each of the 6 strata are held in the variable 
{cmd:freq}.

{p 8 12 2}
{cmd:. use raltest6, clear}{p_end}
{p 8 4 2}
{cmd:. list, clean}{p_end} 

{space 14}{bf:centre    agegrp      freq}
{space 9}1.        1         1        50
{space 9}2.        1         2        80
{space 9}3.        2         1       140
{space 9}4.        2         2       100
{space 9}5.        3         1        70
{space 9}6.        3         2       100

{p 4 4 2}
Note that {cmd:ralloc} does not care about the order of variables in the dataset, nor about the sort order of the 
observations, but it is easier to check the completeness of the schema if levels are coherently nested.

{p 4 4 2}
The command

{p 8 11 2}
{cmd:. ralloc bID bsiz trt, sav(myrct) count(freq) using(raltest6) nsubj(80) seed(54109) multif}

{p 4 4 2}
will produce the following output:{p_end}

{p 8 10 2}
{it}Counts defined in variable {cmd:freq} in file{sf} raltest6 {it}will override the number of subjects specified 
in option nsubj(80){sf}{p_end}

{p 8 10 2}
{it}Number of strata read from file{sf} raltest6 {it}is 6{sf}{p_end}
{p 10 12 2}
{it}number of stratum variables is 2{sf}{p_end}

{p 8 10 2}
{it}stratum variable 1 is centre{sf}{p_end}
{p 10 12 2}
{it}number of levels in centre is 3{sf}{p_end}

{p 8 10 2}
{it}stratum variable 2 is agegrp{sf}{p_end}
{p 10 12 2}
{it}number of levels in agegrp is 2{sf}{p_end}

{p 8 10 2}
{it}the stratum design and allocation numbers are:{sf}{p_end}

{space 7}{bf:       centre  agegrp    freq}
{space 7}   r1       1       1      50
{space 7}   r2       1       2      80
{space 7}   r3       2       1     140
{space 7}   r4       2       2     100
{space 7}   r5       3       1      70
{space 7}   r6       3       2     100

{p 8 10 2}
{it}Allocations over all strata saved to file{sf} {bf:myrct.dta}{p_end}

{space 7}   ....saving data from stratum 1 to file {bf:myrct_1_1.dta}
{space 7}   ....saving data from stratum 2 to file {bf:myrct_1_2.dta}
{space 7}   ....saving data from stratum 3 to file {bf:myrct_2_1.dta}
{space 7}   ....saving data from stratum 4 to file {bf:myrct_2_2.dta}
{space 7}   ....saving data from stratum 5 to file {bf:myrct_3_1.dta}
{space 7}   ....saving data from stratum 6 to file {bf:myrct_3_2.dta}

{p 8 10 2}
{it}Data file{sf} myrct {it}(all allocations) is now in memory{sf}{p_end}
{p 8 10 2}
{it}Issue the -notes- command to review your specifications{sf}{p_end}


{p 4 4 2}
Here are the notes saved to one of the 6 stratum-specific files generated:{p_end}

{p 8 11 2}
{cmd:. use myrct_2_1}{p_end}
{p 8 11 2}
{cmd:. notes}{p_end} 
{p 8 10 2}
_dta:{p_end}
{p 10 15 2}
1.  command issued was: ralloc bID bsiz trt, sav(myrct) count(freq) using(raltest6) nsubj(80) 
seed(54109) multif {p_end}
{p 10 15 2}
2.  Randomisation schema created on 1 Oct 2006 22:38 using ralloc.ado version 3.3 in Stata version 
9.2 born 28 Aug 2006 {p_end}
{p 10 15 2}
3.  Seed used = 54109 {p_end}
{p 10 15 2}
4.  Stratum definitions and numbers of allocations were defined in file 'raltest6.dta' {p_end}
{p 10 15 2}
5.  Number of strata requested = 6 {p_end}
{p 10 15 2}
6.  This is a non-factorial, non-crossover trial with 2 treatments {p_end}
{p 10 15 2}
7.  See notes for parent file 'myrct.dta' {p_end}
{p 10 15 2}
8.  This is stratum 3 of 6 strata requested {p_end}
{p 10 15 2}
9.  ...level 2 of stratum variable -centre- {p_end}
{p 9 15 2}
10.  ...level 1 of stratum variable -agegrp- {p_end}

{p 4 4 2}If the {cmd:shape(wide)} option had been specified, additional notes would have been displayed: {p_end}

{p 9 15 2}
11.  Data saved in wide form: {p_end}
{p 9 15 2}
12.  ...recover 'SeqInBlk' by issuing {cmd:reshape long} command {p_end}
{p 9 15 2}
13.  ...then you may issue {cmd:drop if trt == .} without losing any allocations {p_end}


{p 2}
{bf:Example 6: factorial design} {p_end}

{p 4 4 2}
Consider a study that aims to test both the efficacy of a blood pressure lowering medication, called BPzap, 
versus a placebo, and the utility of two weight reduction exercise programs, called GymSweat and JogaBit, 
versus normal activity on a specified cardiovascular endpoint. An efficient design might be a 2x3 factorial 
RCT (although one should also consider if interaction is an issue here). {p_end}

{p 4 8 2}
{cmd:. ralloc blknum size Rx, sav(rctfact) factor(2*3) osiz(2) eq seed(4512) trtlab(BPzap Placebo GymSweat JogaBit normact) nsubj(300)} {p_end}

{p 4 4 2}
will allocate two treatments, called Rx1 and Rx2, to each of 300 subjects in a single stratum using a 2x3 
factorial design. Blocks of size 6 and 12 with equal frequency will result. After the command we might{p_end}

{p 8 12 2}
{cmd:. list in 1/10}{p_end}


{space 6}{bf}       StratID     blknum       size   SeqInBlk        Rx1        Rx2{sf}
{space 6}  1.         1          1          6          1    Placebo    normact
{space 6}  2.         1          1          6          2      BPzap    JogaBit
{space 6}  3.         1          1          6          3      BPzap    normact
{space 6}  4.         1          1          6          4    Placebo    JogaBit
{space 6}  5.         1          1          6          5      BPzap   GymSweat
{space 6}  6.         1          1          6          6    Placebo   GymSweat
{space 6}  7.         1          2         12          1      BPzap   GymSweat
{space 6}  8.         1          2         12          2    Placebo    normact
{space 6}  9.         1          2         12          3      BPzap    normact
{space 6} 10.         1          2         12          4    Placebo    JogaBit

{p 4 4 2}
So, the 5th subject in Block 1 will receive BPzap and hits the gym, but the 2nd subject in Block 2 takes 
Placebo and gets to slob around as usual. {p_end}

{p 8 12 2}
{cmd:. tab Rx1 Rx2}{p_end}

{space 8}           |               Rx2
{space 8}       Rx1 |  GymSweat    JogaBit    normact |     Total
{space 8}-----------+---------------------------------+----------
{space 8}     BPzap |        50         50         50 |       150
{space 8}   Placebo |        50         50         50 |       150
{space 8}-----------+---------------------------------+----------
{space 8}     Total |       100        100        100 |       300

{p 4 4 2}
and we note the balance in allocations in each axis of the study.{p_end}


{p 2}
{bf:Example 7: 2x2 factorial with 1:2 allocation ratios in both axes} {p_end}

{p 4 4 2}
We reformulate the preceding study as a 2x2 study by excluding the JogaBit treatment. Let's say we wish 
to have twice as many on Placebo as BPzap, and also twice as many subjects on normal activity as on the 
GymSweat regimen.{p_end}

{p 4 8 2}
{cmd:. ralloc blknum size Rx, sav(rctfact2) factor(2*2) osiz(2) eq seed(1131) trtlab(BPzap Placebo GymSweat normact) fratio(2 2) nsubj(300)} {p_end}

{p 4 4 2}
This command will give blocks of sizes 9 (the minimum possible with 1:2 allocation ratios in each axis) and 
18 (because {cmd:osize(2)} was specified). {p_end}

{p 8 12 2}
{cmd:. tab Rx*} {p_end}

{space 8}           |          Rx2
{space 8}       Rx1 |  GymSweat    normact |     Total
{space 8}-----------+----------------------+----------
{space 8}     BPzap |        34         68 |       102
{space 8}   Placebo |        68        136 |       204
{space 8}-----------+----------------------+----------
{space 8}     Total |       102        204 |       306


{p 2}
{bf:Example 8: cross-over trial} {p_end}

{p 4 4 2}
We have a 2x2 crossover design supplemented by a switchback in period 3.  The
trial compares a new anti-arthritic drug "HipLube" versus aspirin in chronic
osteoarthritis of the hip. {p_end}

{p 4 8 2}
{cmd:. ralloc Bnum Bsize medic, saving(chronOA) ns(28) trtlab(HipLube aspirin) xover(switch) strata(2) osiz(1) init(4)}

{p 4 4 2}
will randomise 56 subjects (28 in each of 2 strata) using blocks of constant size, 4, and save results to {cmd:chronOA.dta}. 
Each subject will receive either HipLube or aspirin in the 1st period, and the other drug in the 2nd period. The 1st 
period's drug will be readministered in the 3rd period. {p_end}


{p 2}
{bf:Example 9: non-standard allocation ratios} {p_end}

{p 4 4 2}
We have a parallel design with 5 treatments.  We wish to allocate in the ratio 1:2:2:1:4. The {bf:ratio} option does not
support this. Here's how to achieve it: {p_end}

{p 4 8 2}
{cmd:. ralloc Bnum Bsize treat, saving(mytrial) ntreat(10) nsubj(800) trtlab(A B B C C D E E E E)} {p_end}
{p 4 8 2}
{cmd:. decode treat, gen(final_treat)} {p_end}

{p 4 4 2}
Note that we specified 10 "treatments", not 5, because the sum of the ratios of treatments was 10, and then we "tricked" {bf:ralloc}
by duplicating the treatment names in the {bf:trtlab()} option. The final {cmd:decode} command tidies things up; to see why, 
crosstabulate variables {bf:treat} and {bf:final_treat}.  Many other allocation ratio designs are possible with judicious choice of
{bf:ntreat()} and {bf:trtlab()}.{p_end}


{p 2}
{bf:Example 10: non-standard allocation ratios in a factorial design} {p_end}

{p 4 4 2}
We have a 2*3 factorial design with treatments A and B in the first axis, and C, D and E in the second axis. We wish to 
allocate twice as many subjects to A (in each of C, D and E) as in B. The {bf:fratio()} option does not support this. {p_end}

{p 4 8 2}
{cmd:. ralloc Bnum Bsize treat, saving(mytrial) nsubj(800) factor(3*3) trtlab(A A B C D E)} {p_end}

{p 4 4 2}
and a crosstabulation of {cmd:treat1} by {cmd:treat2} yields:{p_end}

{space 8}           |              treat2
{space 8}    treat1 |         C          D          E |     Total
{space 8}-----------+---------------------------------+----------
{space 8}         A |        89         89         89 |       267 
{space 8}         A |        89         89         89 |       267 
{space 8}         B |        89         89         89 |       267 
{space 8}-----------+---------------------------------+----------
{space 8}     Total |       267        267        267 |       801 

{p 4 8 2}
{cmd:. decode treat1, gen(treat1_new)} {p_end}

{p 4 4 2}
and a crosstabulation of {cmd:treat1_new} by {cmd:treat2} yields, as desired:{p_end}

{space 8}           |              treat2
{space 8}treat1_new |         C          D          E |     Total
{space 8}-----------+---------------------------------+----------
{space 8}         A |       178        178        178 |       534 
{space 8}         B |        89         89         89 |       267 
{space 8}-----------+---------------------------------+----------
{space 8}     Total |       267        267        267 |       801 

{p 4 4 2}
Note that we specified {bf:factor(3*3)} not {bf:factor(2*3)} and tidied up afterwards. {p_end}


{p 2}
{bf:Example 11: a stratified 3-way (2x2x3) factorial design}  {p_end}

{p 4 4 2}
We have a stratified RCT in neonates of supplemental oxygen, admission to NICU, and feeding mode. 
The stratum is the parity of the mother. In this schema we specify labels both for the 7 treatments and for the 4 strata. 
The application of the stratum value labels is toggled on by the {bf:vallab} option.

{p 4 8 2}
{bf}. ralloc b s Rx, sav(temp)  nsubj(500)  fact(2*2*3) osize(1)  strata(4)  vallab  multif  seed(81372)    {break}
trtlab(suppl_O2 {bind: }no_suppl_O2 {bind: }NICU {bind: }no_NICU {bind: }NG_tube {bind: }IV_feed {bind: }breast)  {break}
stratlab(nulliparous primiparous biparous multiparous){sf}
{p_end}

{p 4 8 2}Part of the screen display will be:

{p 8 10 2}
{it}Allocations over all strata saved to file{sf} {bf:temp.dta}{p_end}
 
{p 7 8 2}....saving data from stratum 1 [nulliparous] to file {bf:temp_nulliparous.dta} {p_end}
{p 7 8 2}....saving data from stratum 2 [primiparous] to file {bf:temp_primiparous.dta} {p_end}
{p 7 8 2}....saving data from stratum 3 [biparous] to file {bf:temp_biparous.dta} {p_end}
{p 7 8 2}....saving data from stratum 4 [multiparous] to file {bf:temp_multiparous.dta} {p_end}
 

{p 4 8 2}
{cmd:. table Rx*, by(StratID)}

{space 8}----------------------------------------------------------------------
{space 8}stratum     |                       Rx3 and Rx2                       
{space 8}identifier  | ---- NG_tube ---    ---- IV_feed ---    ---- breast ----
{space 8}and Rx1     |    NICU  no_NICU       NICU  no_NICU       NICU  no_NICU
{space 8}------------+---------------------------------------------------------
{space 8}nulliparous |
{space 8}   suppl_O2 |      42       42         42       42         42       42
{space 8}no_suppl_O2 |      42       42         42       42         42       42
{space 8}------------+---------------------------------------------------------
{space 8}primiparous |
{space 8}   suppl_O2 |      42       42         42       42         42       42
{space 8}no_suppl_O2 |      42       42         42       42         42       42
{space 8}------------+---------------------------------------------------------
{space 8}biparous    |
{space 8}   suppl_O2 |      42       42         42       42         42       42
{space 8}no_suppl_O2 |      42       42         42       42         42       42
{space 8}------------+---------------------------------------------------------
{space 8}multiparous |
{space 8}   suppl_O2 |      42       42         42       42         42       42
{space 8}no_suppl_O2 |      42       42         42       42         42       42
{space 8}----------------------------------------------------------------------


{p 2}
{bf:Example 12: individual specification of allocations to each stratum: using() file has complete stratum value labels} {p_end}

{p 4 4 2}
Let us say we have a file, {cmd:raltest6_lab.dta}, containing the allocation schema for a RCT with 6 strata: 
3 centres (hospitals) and 2 age groups in each centre. Value labels for every level of both stratification variables 
are defined in the data set.

{p 4 8 2}
{cmd:. describe}

{space 8}Contains data from raltest6_lab.dta
{space 8}  obs:             6                          
{space 8} vars:             3                          1 Aug 2011 21:00
{space 8} size:            96 (99.9% of memory free)
{space 8}--------------------------------------------------------------------------
{space 8}              storage  display     value
{space 8}variable name   type   format      label      variable label
{space 8}--------------------------------------------------------------------------
{space 8}centre           byte  %13.0g      cenlab     
{space 8}agegrp            int  %9.0g       agelab     
{space 8}freq              int  %9.0g                  
{space 8}--------------------------------------------------------------------------
  
{p 4 8 2}
{cmd:. label list}

{space 8}cenlab:
{space 8}          1 St Mary's
{space 8}          2 Seattle Grace
{space 8}          3 Chicago Hope
{space 8}agelab:
{space 8}          1 young
{space 8}          2 old

{p 4 8 2}
{cmd:. list, sep(6)}

{space 8}     +-------------------------------+
{space 8}     |        centre   agegrp   freq |
{space 8}     |-------------------------------|
{space 8}  1. |     St Mary's    young     50 |
{space 8}  2. |     St Mary's      old     80 |
{space 8}  3. | Seattle Grace    young    140 |
{space 8}  4. | Seattle Grace      old    100 |
{space 8}  5. |  Chicago Hope    young     70 |
{space 8}  6. |  Chicago Hope      old    100 |
{space 8}     +-------------------------------+


{p 4 8 2}
{cmd:. ralloc b s treat, multif saving(RCTx) using(raltest6_lab) countv(freq) vallab}

{p 4 8 2}Part of the screen display will be:

{p 8 10 2}
{it}Allocations over all strata saved to file{sf} {bf:RCTx.dta}{p_end}

{space 7}....saving data from stratum 1 [St Mary's young] to file {bf:RCTx_St_Mary's_young.dta}
{space 7}....saving data from stratum 2 [St Mary's old] to file {bf:RCTx_St_Mary's_old.dta}
{space 7}....saving data from stratum 3 [Seattle Grace young] to file {bf:RCTx_Seattle_Grace_young.dta}
{space 7}....saving data from stratum 4 [Seattle Grace old] to file {bf:RCTx_Seattle_Grace_old.dta}
{space 7}....saving data from stratum 5 [Chicago Hope young] to file {bf:RCTx_Chicago_Hope_young.dta}
{space 7}....saving data from stratum 6 [Chicago Hope old] to file {bf:RCTx_Chicago_Hope_old.dta}


{p 4 4 2}
Note that although the value labels on the variable {bf:centre} in the {bf:using} file {bf:raltest6_lab.dta} 
permit embedded spaces, these are substituted by underscores "_" in the suffixes of the stratum-specific 
treatment allocation filenames. But the value labels attached to {bf:StratID} and to the stratum-defining
variables within the allocation files preserve any spaces in the labels from the source ({bf:using} file.

{p 4 8 2}
{cmd:. list in 1/5}

{space 8}     +-----------------------------------------------------------------+
{space 8}     |         StratID   b   s   SeqInBlk   treat      centre   agegrp |
{space 8}     |-----------------------------------------------------------------|
{space 8}  1. | St Mary's young   1   4          1       A   St Mary's    young |
{space 8}  2. | St Mary's young   1   4          2       B   St Mary's    young |
{space 8}  3. | St Mary's young   1   4          3       B   St Mary's    young |
{space 8}  4. | St Mary's young   1   4          4       A   St Mary's    young |
{space 8}  5. | St Mary's young   2   6          1       A   St Mary's    young |
{space 8}     +-----------------------------------------------------------------+


{p 2}
{bf:Example 13: individual specification of allocations to each stratum: using() file has incomplete stratum value labels} {p_end}

{p 4 4 2}
Let us say we have a file, {cmd:raltest12_lab.dta}, containing the allocation schema for a RCT with 12 strata: 
3 hospitals x 2 age groups x 2 sexes.  Variables {bf:hospital} and {bf:sex} have value labels defined and attached, but 
{bf: hospital} = 2 does not have a label.  Variable {bf:agegrp} does not have a value label at all.  If {bf:vallab} 
is specified, {cmd:ralloc} will use whatever labels are available.

{p 4 8 2}
{cmd:. describe}

{space 8}Contains data from raltest12_lab.dta
{space 8}  obs:            12                          
{space 8} vars:             4                          2 Aug 2011 15:00
{space 8} size:           108 (99.9% of memory free)
{space 8}----------------------------------------------------------------
{space 8}              storage  display     value
{space 8}variable name   type   format      label      variable label
{space 8}----------------------------------------------------------------
{space 8}centre          byte   %13.0g      cenlab     
{space 8}agegrp          byte   %9.0g                  
{space 8}sex             byte   %9.0g       sexlab     
{space 8}freq            int    %9.0g                  
{space 8}---------------------------------------------

{p 4 8 2}
{cmd:. label list}

{space 8}cenlab: 
{space 8}           1 St Mary's 
{space 8}           3 Chicago Hope 
{space 8}sexlab:{break}
{space 8}           1 male 
{space 8}           2 female 

{p 4 8 2}
{cmd:. list, sepby(centre)}

{space 8}     +---------------------------------------+
{space 8}     |       centre   agegrp      sex   freq |
{space 8}     |---------------------------------------|
{space 8}  1. |    St Mary's        1     male     50 |
{space 8}  2. |    St Mary's        1   female     80 |
{space 8}  3. |    St Mary's        2     male     60 |
{space 8}  4. |    St Mary's        2   female     80 |
{space 8}     |---------------------------------------|
{space 8}  5. |            2        1     male    140 |
{space 8}  6. |            2        1   female    100 |
{space 8}  7. |            2        2     male    100 |
{space 8}  8. |            2        2   female    100 |
{space 8}     |---------------------------------------|
{space 8}  9. | Chicago Hope        1     male     70 |
{space 8} 10. | Chicago Hope        1   female    100 |
{space 8} 11. | Chicago Hope        2     male     50 |
{space 8} 12. | Chicago Hope        2   female     50 |
{space 8}     +---------------------------------------+


{p 4 8 2}
{cmd:. ralloc b s treat, multif saving(RCTx) using(raltest12_lab) countv(freq) vallab}

{p 4 8 2}Part of the screen display will be:

{p 8 10 2}
{it}Allocations over all strata saved to file{sf} {bf:RCTx.dta}{p_end}
 
{space 7}....saving data from stratum 1 [St Mary's 1 male] to file {bf:RCTx_St_Mary's_1_male.dta}
{space 7}....saving data from stratum 2 [St Mary's 1 female] to file {bf:RCTx_St_Mary's_1_female.dta}
{space 7}....saving data from stratum 3 [St Mary's 2 male] to file {bf:RCTx_St_Mary's_2_male.dta}
{space 7}....saving data from stratum 4 [St Mary's 2 female] to file {bf:RCTx_St_Mary's_2_female.dta}
{space 7}....saving data from stratum 5 [2 1 male] to file {bf:RCTx_2_1_male.dta}
{space 7}....saving data from stratum 6 [2 1 female] to file {bf:RCTx_2_1_female.dta}
{space 7}....saving data from stratum 7 [2 2 male] to file {bf:RCTx_2_2_male.dta}
{space 7}....saving data from stratum 8 [2 2 female] to file {bf:RCTx_2_2_female.dta}
{space 7}....saving data from stratum 9 [Chicago Hope 1 male] to file {bf:RCTx_Chicago_Hope_1_male.dta}
{space 7}....saving data from stratum 10 [Chicago Hope 1 female] to file {bf:RCTx_Chicago_Hope_1_female.dta}
{space 7}....saving data from stratum 11 [Chicago Hope 2 male] to file {bf:RCTx_Chicago_Hope_2_male.dta}
{space 7}....saving data from stratum 12 [Chicago Hope 2 female] to file {bf:RCTx_Chicago_Hope_2_female.dta}

{p 4 8 2}
{cmd:. tab StratID treat}

{space 8}                      |         treat
{space 8}   stratum identifier |         A          B |     Total
{space 8}----------------------+----------------------+----------
{space 8}     St Mary's 1 male |        27         27 |        54 
{space 8}   St Mary's 1 female |        41         41 |        82 
{space 8}     St Mary's 2 male |        31         31 |        62 
{space 8}   St Mary's 2 female |        40         40 |        80 
{space 8}             2 1 male |        70         70 |       140 
{space 8}           2 1 female |        51         51 |       102 
{space 8}             2 2 male |        52         52 |       104 
{space 8}           2 2 female |        51         51 |       102 
{space 8}  Chicago Hope 1 male |        36         36 |        72 
{space 8}Chicago Hope 1 female |        50         50 |       100 
{space 8}  Chicago Hope 2 male |        25         25 |        50 
{space 8}Chicago Hope 2 female |        27         27 |        54 
{space 8}----------------------+----------------------+----------
{space 8}                Total |       501        501 |     1,002 



{smcl}
{title:Acknowledgements}

{p 4 4 2}
I thank Liddy Griffith, Tom Sullivan, Nick Cox, Nikolaos Pandis and participants at the 2nd Australian and New Zealand Stata Users Group meeting 
(Melbourne, 2006) for assisting with the development and/or testing of {cmd:ralloc}. 


{title:Reference}

{p 4 8 2}
Jones, B. and Kenward, M.G. 1989. {it:Design and Analysis of Crossover Trials.} London: Chapman and Hall.


{title:Author}

{p 4 4 2}Philip Ryan{break}
Data Management & Analysis Centre{break}
Discipline of Public Health{break}
Faculty of Health Sciences{break}
University of Adelaide{break}
South Australia{break}
philip.ryan@adelaide.edu.au


{title:See also}

{p 4 4 2}STB:  {cmd:ralloc} in STB-54 sxd1.2, STB-50 sxd1.1, STB-41 sxd1
{p 5 4 2} SJ:   SJ 8(1):146;  SJ 8(4):594


