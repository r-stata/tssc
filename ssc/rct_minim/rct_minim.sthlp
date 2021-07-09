{smcl}
{* 2017-03-02}
{* help file to accompany rct_minim 2.2.1}
{cmd:help rct_minim}
{hline}

{title:Title}

{p 4 16 2}
{bf:rct_minim {c -} Allocation of treatments to balance prognostic factors in controlled trials}


{title:Syntax}

{p 8 17 2}
{bf:rct_minim} {cmd:,} {opt file:stub}{bf:(}{it:filenamestub}{bf:)}{space 1}{...}
{opt nt}{bf:(}{it:#}{bf:)}{space 2}{opt nf}{bf:(}{it:#}{bf:)}{space 1}{...}
{opt nl}{bf:(}{it:#1 [#2 [...]}{bf:)}{space 2}{opt pchoice}{bf:(a}|{bf:b}|{bf:c)}{space 2}[{it:options}]


{synoptset 31 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt : {opt file:stub(filenamestub)}}filename prefix for allocations and factor balance files;
required option{p_end}
{synopt : {opt nt(#)}}number of treatment groups;
required option{p_end}
{synopt : {opt nf(#)}}number of prognostic factors;
required option{p_end}
{synopt : {opt nl(#1 #2 ...)}}number of levels in {it:factor1 factor2} etc;
required option{p_end}
{synopt : {opt pchoice}{bf:(a}|{bf:b}|{bf:c)}}method to calculate treatment assignment probabilities;
required option{p_end}

{syntab:Options}
{p2colset 6 38 40 2}{...}
{synopt :*{opt p(#)}}specify probability p for {cmd: pchoice} method {bf:a}{p_end}
{synopt :*{opt q(#)}}specify parameter q for {cmd: pchoice} method {bf:b}{p_end}
{synopt :*{opt t(#)}}specify parameter t for {cmd: pchoice} method {bf:c}{p_end}
{p2colset 7 38 40 2}{...}
{synopt :{opt treatv:ar(varname)}}name of treatment group variable{p_end}
{synopt :{opt factn:ames(name1 name2...)}}names of prognostic factors{p_end}
{synopt :{opt pat:tern(#1 #2 ...)}}current subject's levels on each prognostic factor{p_end}
{synopt :{opt w(#1 #2...)}}weights for each prognostic factor{p_end}
{synopt :{opt mchoice}{bf:(range}|{bf:var}|{bf:sd}|{bf:thresh)}}method for measuring imbalance in 
prognostic factors{p_end}
{synopt :{opt limit(#)}}limit of acceptable imbalance (specified when {bf:mchoice(thresh)} is specified){p_end}
{synopt :{opt delay(#)}}specify first # subjects are allocated treatments at random{p_end}
{synopt :{opt warn}}user response required between re-display of command and treatment assignment{p_end}
{synopt :{opt showd:etail}}display detailed output{p_end}

{synoptline}
{p 5}
* one of {opt p}, {opt q} or {opt t} must be specified
{p_end}


{title:Description}

{pstd}
{cmd:rct_minim} assigns subjects to treatment groups so as to balance categorical or ordered categorical 
prognostic factors across the treatments using a process called {it: minimization} (see Pocock and Simon (1975)). 
This is a form of "covariate adaptive randomisation", the assignment for the current subject depends {it:inter alia} on {p_end} 
{p 8 12 2}
(i) all previous subjects' treatment assignments, 
{p_end}
{p 7 12 2}
(ii) all previous subjects' patterns of prognostic factors, and 
{p_end}
{p 6 12 2}
(iii) the current subject's pattern of prognostic factors. 
{p_end}

{pstd}
Treatment assignment by minimization may be useful in smaller trials, when the number of strata is large relative 
to the sample size, and/or when balance of prognostic factors is judged to be critically important.  
[See {bf:{search ralloc}} for a more common method of randomisation using randomly permuted blocks and 
stratification.] {p_end}

{pstd}
{cmd:rct_minim} sets the random number generator to {bf:kiss32} {p_end}


{title:Options}

{dlgtab:Main}

{phang}
{opt filestub(filenamestub)} specifies the prefix of the names of 2 files that {cmd:rct_minim} will create 
on its first invocation and use on each subsequent treatment assignment. {p_end}

{p 8 8 2}The {it:first} file will be named {it:filenamestub}{bf:_rand.dta}; for each subject it stores the treatment 
assignment, the factor levels, a system-generated {bf:_SeqNum} variable giving the sequential number of 
that subject's allocation, and a system-generated binary variable, {bf:_minim}, indicating whether (1=yes) or not (0=no)
the minimising algorithm was invoked for that subject (see option {opt delay} below). {p_end}

{p 8 8 2}The {it: second} file will be named {it:filenamestub}{bf:_factbal.dta}; it stores summary count data on the 
distribution of treatment assignments and prognostic factor levels in a layout similar to Table 1 of Pocock 
and Simon. Data from this file are used within {cmd: rct_minim} to construct a {it:factor balance matrix}. {p_end}

{phang}
{opt nt(#)} specifies the number of treatment groups; {it:#} must be at least 2.

{phang}
{opt nf(#)} specifies the number of prognostic factors; {it:#} must be at least 1.

{phang}
{opt nl(#1 #2 ...)} specifies the number of levels of {it:factor1 factor2} etc; {it:#} must be 
at least 2 for each factor. Separate the {it:#}s by one or more spaces.

{phang}
{opt pchoice}{bf:(a}|{bf:b}|{bf:c)} specifies how to calculate probabilities that will determine the
extent of the bias in treatment assignments. Minimization seeks to assign a treatment based on 
minimising the prognostic factor imbalance. This imbalance is reflected in function D{it:i} that 
measures the extent of variation across treatments for levels of factor {it:i}.  By default, {cmd:rct_minim} 
specifies D{it:i} as the {it:range} in the counts of each level of factor {it:i} across treatments 
(see option {bf: mchoice} below for alternative methods of measuring imbalance in factors), and 
then calculates G{it:k}, a sum (perhaps weighted) of the D{it:i} for each treatment {it:k} (k = 1..{bf:nt}).
We may then {it:deterministically} assign the subject to the treatment that will minimise G, or, 
perhaps in an effort to better protect the blinding, assign the subject to treatments in a random 
fashion following an empirical probability distribution. This distribution will of course assign more 
probability to the treatment minimizing G. Pocock and Simon discuss 3 methods, denoted "{bf:a}", 
"{bf:b}" and "{bf:c}" for setting up the probability distribution (see section 3.3 of their paper). {p_end}

{p 8 8 2}
Method {bf:a} specifies {bf:p} as the probability for the assignment to the treatment with the lowest 
value of G, and {bf:p}{it:k} = (1-{bf:p})/({bf:nt}-1) for every other treatment (k = 2...{bf:nt}) where k 
is ordered for increasing values of G{it:k}. If {bf:p} = 1 then the assignment is automatically to the 
treatment minimizing G. If {bf:p} = 1/{bf:nt} then each treatment has equal probability of being assigned. 
Commonly, {bf:p} = 2/3 is chosen as a compromise between maintaining the blinding and affording a bias in 
the assignments to achieve factor balance.{p_end}

{p 8 8 2}
Method {bf:b} specifies {bf:q} as some constant such that the probability distribution takes account of 
the ranking of G{it:k} for all k (and not just for k = 1 as is the case in Method {bf:a}). 
p{it:k} = {bf:q} - [2{it:k}(({bf:nt}*{bf:q})-1)/({bf:nt}({bf:nt}+1))]  (k = 1...{bf:nt}).  Pocock and Simon 
give an example using {bf:q} = 1/2 in a 4 treatment trial, yielding p{it:1} = 0.4, p{it:2} = 0.3, p{it:3} = 0.2 
and p{it:4} = 0.1. That is, the subject will be assigned to the treatment for which G is minimized with 
probability 0.4, to the treatment for which G is next in ordered value with probability 0.3 and so on.{p_end}

{p 8 8 2}
Method {bf:c} specifies {bf:t} as some constant such that the probability distribution takes account of 
the actual value of G{it:k} for all k (and not just for the ranking of G{it:k} as is the case in Method {bf:b}). 
The higher the 
value of {bf:t} the more bias in treatment assignment. Under this method 
p{it:k} = (1/({bf:nt} - {bf:t})) * [1 - ({bf:t}*G{it:k}/sum(G{it:k})] (k = 1...{bf:nt}).  {p_end}

{p 8 8 2}
The three methods and their associated probability distributions do not apply to the first subject's treatment
assignment.  This is determined by simple randomisation with assignment to each group equally likely.{p_end}



{dlgtab:Options}

{phang}
{opt p(#)} specifies value of p when {bf:pchoice}({bf:a}) has been chosen. {it:#} must lie between 1/{bf:nt} and 1.

{phang}
{opt q(#)} specifies value of q when {bf:pchoice}({bf:b}) has been chosen. {it:#} must lie between 1/{bf:nt} and 
2/({bf:nt}-1).

{phang}
{opt t(#)} specifies value of t when {bf:pchoice}({bf:c}) has been chosen. {it:#} must lie between 0 and 1.

{phang}
{opt mchoice(string)} specifies the method of measuring the imbalance in prognostic factors across treatments.  
The default is {bf:range}.  Alternatives are {bf:var} (variance of the counts within a factor level across treatments),
 {bf:sd} (standard deviation of the counts), and {bf:thresh} which signals that a bias in treatment assignment will 
only proceed if the imbalance in the range of counts exceeds a specified {bf:limit}.

{phang}
{opt limit(#)} specifies the maximum acceptable (integer) imbalance in prognostic factor levels before a bias in treatment 
assignment (designed to correct the imbalance) will be invoked. Used with option {bf: mchoice(thresh)}. Default is 1.

{phang}
{opt treatvar(varname)}} specifies the name of the treatment group variable; default is "_group".

{phang}
{opt factnames(name1 name2...)} specifies the names of the prognostic factors; default is "factor1", "factor2" etc

{phang}
{opt pattern(#1 #2 ...)} specifies this subject's levels on each prognostic factor. If {bf: pattern} is not 
specified the user is prompted to enter the levels one factor at a time at the cursor. This is simply a 
convenience feature, as the factor levels may be the only option to change for each subject.

{phang}
{opt w(#1 #2...)} specifies the relative importance weights for each prognostic factor.  These are used in the 
linear combination of the D{it:i} to form the G{it:k}.  Higher relative weights are given to factors for 
which an imbalance would be most unwelcome. The {it:#i} should each exceed 0. 

{phang}
{opt delay(#)} specifies that the first {it:#} subjects are allocated treatments purely at random (with equal
probabilities) - the minimisation algorithm is not used for these subjects. [Note that the first subject is
always allocated his/her treatment at random, since no factor balance matrix yet exists.]  The default is {opt delay(1)},
implying that the minimisation algorithm will be used for the second and subsequent subjects.

{phang}
{opt warn} specifies that a user confirmation will be required between re-display of the command and the actual
treatment assignment; by default no warning is given. Because sequential invocations of {cmd:rct_minim} may occur 
after some time has elapsed, it is important for the integrity of the study design that certain options are
specified consistently, especially {bf:filestub}, {bf:nt}, {bf:nf} and {bf:nl}. On each invocation 
{cmd:rct_minim} saves two {it:characteristics} to the data files. The first, named {bf:_dta[TD_{it:n}]} (where
n is the sequential number of the current subject), stores the time and date of the assignment. (See also 
{it:Note} below). The second characteristic, named {bf:_dta[minim_{it:n}]} stores the command and options that 
were issued. Specifying {bf:warn} causes {cmd:rct_minim} to re-display the current command and also the contents 
of {bf:_dta[TD_{it:n-1}]} and of {bf:_dta[alloc_{it:n-1}]} (that is, the command as issued for the previous 
assignment) so that the user can compare these and decide whether or not to proceed with the current randomisation. 
This is in addition to other error traps within the program. 

{p 8 14 2}
{it:Note}: The characteristic {bf:_dta[TD_{it:n}]} stores the time and date of the assignment. {bf:rct_minim} 
uses the date and time, in that order, concatenated and stripped of any non-numeric characters to form the seed
for the current assignment. (This seed is also displayed when option {bf:showdetail} is specified.) 

{phang}
{opt showdetail} specifies that detailed output is displayed. The default is minimal output, but it would be
prudent to both open a log file and specify {bf:showdetail} for each treatment assignment. {bf:showdetail}
will cause the following to be displayed:

{p 12 14 2}
the seed (set from the date and time) {p_end}
{p 12 14 2}
the method chosen for measuring imbalance in prognostic factors{p_end}
{p 12 14 2}
the weight vector {p_end}
{p 12 14 2}
the status of the progostic factor balance matrix from the previous assignment {p_end}
{p 12 14 2}
the sequential number of the subject about to be assigned treatment {p_end}
{p 12 14 2}
the status of the progostic factor balance matrix for each possible treatment assignment for the 
current subject {p_end}
{p 12 14 2}
the values of weighted G for each treatment group {p_end}
{p 12 14 2}
the values of weighted G for each treatment group, sorted in ascending order (with ties broken 
at random) {p_end}
{p 12 14 2}
the smallest value of G and the treatment group it represents {p_end}
{p 12 14 2}
the random number {it:u} used to determine the actual treatment allocation {p_end}
{p 12 14 2}
the cumulative probability distribution (set up by either {bf:p}, {bf:q} or {bf:t}); the value of {it:u}
with respect to this distribution determines the assignment. {p_end}
{p 12 14 2}
the final treatment group assignment {p_end}
{p 12 14 2}
the updated prognostic factor balance matrix {p_end}


{title:Examples}

{pstd}Basic setup for 2-arm trial with 3 prognostic factors; the  {it:first} subject is at level 1 for factor1, level 3 
for factor2, and level 2 for factor3.  The {it:second} subject is at level 2 for each factor. Use the default {bf:range} 
method to measure imbalance. {p_end}

{p 6 10 2}
{cmd:. rct_minim, filestub(my_trial) nt(2) nf(3) nl(2 4 3) pchoice(a) p(.66667) showdet warn pattern(1 3 2)}{p_end}
{p 6 10 2}
{cmd:. rct_minim, filestub(my_trial) nt(2) nf(3) nl(2 4 3) pchoice(a) p(.66667) showdet warn pattern(2 2 2)}{p_end}

{pstd}3-arm trial with 2 user-named prognostic factors, sex has 2 levels, age_group has 5 levels; no warnings and 
no detail displayed; program will request current subject's levels on each factor {p_end}

{p 6 10 2}
{cmd:. rct_minim, filestub(your_trial) nt(3) nf(2) factnames(sex age_group) nl(2 5) pchoice(a) p(.75) } {p_end}

{pstd}Same design as previous example but this time, in an effort to better protect the blind, delay the minimization
process until the 11th subject is randomized; the first 10 subjects will have their treatments allocated at random.{p_end}

{p 6 10 2}
{cmd:. rct_minim, filestub(her_trial) nt(3) nf(2) factnames(sex age_group) nl(2 5) pchoice(a) p(.75)  delay(10)} {p_end}

{pstd}Mimic example from section 3.4 of Pocock and Simon. Ensure that files {bf:pocock_simon_v3_rand.dta} and
{bf:pocock_simon_v3_factbal.dta} (available with the {bf:rct_minim} package from SSC) are installed in the 
current path. 50 subjects have already been randomised, whither the 51st?{p_end}

{p 6 10 2}
{cmd:. rct_minim, filestub(pocock_simon_v3) w(2 1 1) nt(3) nf(3) nl(2 2 3) pchoice(a) p(`=2/3') pattern(1 2 2) treatv(treatment) showd} {p_end}

  
{title:Reference}

{p 4 8 2}
Pocock, S.J. and Simon, R. [1975]. Sequential treatment assignment with balancing for prognostic factors
in the controlled clinical trial. Biometrics 31, 103-115.


{title:Acknowledgements}

{p 4 4 2}
Thanks to Kit Baum, Boston College Economics and DIW Berlin, for suggesting some useful Mata code.{break}
Thanks also to Tom Sullivan, University of Adelaide, for helping test and debug {bf:rct_minim} and to
Ben Leiby and Nooreen Dabbish at TJU, Philadelphia, who spotted and helped correct a bug involving the random seed.

{title:Author}

{p 4 4 2}Philip Ryan{break}
Emeritus Professor{break}
School of Public Health{break}
Faculty of Health Sciences{break}
University of Adelaide{break}
South Australia{break}
philip.ryan@adelaide.edu.au


{title:See also}

    STB:  {cmd:ralloc} in STB-54 sxd1.2, STB-50 sxd1.1, STB-41 sxd1
     SJ:  {cmd:ralloc} in SJ 8(4):594, SJ 8(1):146

