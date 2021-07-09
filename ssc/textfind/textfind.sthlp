{smcl}
{* created 23jan2018}{...}
{cmd:help textfind}
{hline}

{title:Title}

{phang}
{bf:textfind} {hline 2} identify, analyze, and convert text entries into
categorical data


{title:Syntax}

{p 8 16 2}{cmd:textfind}
	{varlist}
	{ifin}
	[{cmd:,}
	{cmdab:key:word(}{cmd:"}{it:string1}{cmd:"} {cmd:"}{it:string2}{cmd:"} {it:...}{cmd:)}
	{cmd:but(}{cmd:"}{it:string1}{cmd:"} {cmd:"}{it:string2}{cmd:"} {it:...}{cmd:)}
	{cmd:nocase}
	{cmd:exact}
	{cmd:or}
	{cmd:notable}
	{cmd:tag(}{newvar}{cmd:)}
	{cmd:nfinds}
	{cmd:length}
	{cmd:position}
	{cmd:tfidf}]


{title:Description}

{pstd}
{cmd:textfind} is a data-driven program that identifies, analyzes, and converts
textual data into categorical variables for further use in quantitative
analysis. It uses regular expressions to find one (or more) keyword and
exclusion (i.e. {it:n}-grams), reporting six statistics summarizing search
quality: the number of observations in the dataset that were matched; the number
 of word occurrences per observation; the textual length in which word is found;
 the position at which the word was first found; the term frequency-inverse
document frequency (tf-idf) of the word used in the search; and the p-value of a
 means comparison test between samples identified by different search criteria.


{title:Options}

{phang}{cmdab:key:word(}{cmd:"}{it:string1}{cmd:"} {cmd:"}{it:string2}{cmd:"}
{it:...}{cmd:)} is the main search option. It looks up {it:"string1"},
{it:"string2"}, ..., in each observation of {varlist}, where {it:string} can be
text, numbers, or any other {help ustrregexm()} search criteria.

{phang}{cmd:but(}{cmd:"}{it:string1}{cmd:"} {cmd:"}{it:string2}{cmd:"} {it:...}
{cmd:)} is the main exclusion option. It looks up {it:"string1"}, {it:"string2"},
{it:...}, in each observation of {varlist}, where {it:string} can be text,
numbers, or any other {help ustrregexm()} search criteria, and removes matches
found with {cmd:keyword()}.

{phang}{cmd:nocase} performs a case-insensitive search.

{phang}{cmd:exact} performs an exact search of {cmd:keyword()} in {varlist} and
only matches observations that are entirely equal to {it:"string1"},
{it:"string2"}, ..., etc.

{phang}{cmd:or} performs an alternative match for multiple entries in
{cmd:keyword()}. The default is an additive search of {it:"string1"} {it:and}
 {it:"string2"} {it:...}

{phang}{cmd:notable} asks Stata not to return the table of summary statistics.

{phang}{cmd:tag({newvar})} generates one variable called {newvar} marking all
observations that were found under criteria {cmd:keyword()} and {cmd:but()}.

{phang}{cmd:nfinds} generates one variable per {it:"string"} in {cmd:keyword()}
containing the number of occurrences of {it:"string"} in each observation.
Default variable names are {cmd:{it:myvar1_nfinds}}, {cmd:{it:myvar2_nfinds}},
..., for {it:"string1"}, {it:"string2"}, ..., etc.

{phang}{cmd:length} generates new variable {cmd:{it:myvar_length}} containing
the word length of each variable in {varlist} for which search criteria is
found.

{phang}{cmd:position} generates one variable per {it:"string"} in
{cmd:keyword()} containing the position where {it:"string"} was first found in
each observation. Default variable names are {cmd:{it:myvar1_pos}},
{cmd:{it:myvar2_pos}}, ..., for {it:string1}, {it:string2}, ..., etc.

{phang}{cmd:tfidf} generates one variable per {it:"string"} in {cmd:keyword()}
containing the term frequency-inverse document frequency statistic of
{it:"text"} in each observation. Default variable names are
{cmd:{it:myvar1_tfidf}}, {cmd:{it:myvar2_tfidf}}, ..., for {it:string1},
{it:string2}, ..., etc.


{title:Remarks}

{pstd}
{cmd:textfind} increases Stata's capabilities for conducting content analysis.
Beyond standard keyword search made possible by {help string functions},
{cmd:textfind} allows users to use multiple keyword and exclusion criteria to
identify observations in the dataset.

{pstd}
In particular, {cmd:textfind} has three important features: (i) it makes use of
regular expressions for highly-complex search patterns; (ii) it produces six
measures of textual match quality, including a means comparison test across
search criteria; (iii) it uses Unicode encoding, instead of ASCII, thus making
it compatible with non-English text excerpts and strings.

{pstd}
The program produces a summary table with six statistics by each keyword and
exclusion.

{phang}{cmd:(1) Total Finds (exclusions):} returns the number of observations
found by search criteria in {cmd:keyword()} or {cmd:but()}. If both criteria
have been specified, {cmd:but()} removes finds identified by {cmd:keyword()}.

{phang}{cmd:(2) Average Finds (exclusions):} returns the average number of
occurrences of {it:strings} in {cmd:keyword()} [or exclusions from {cmd:but()}]
by observation.

{phang}{cmd:(3) Average Length:} returns the average length (in words) of text
in observations where {cmd:keyword()} [or {cmd:but()}] were [not] found.

{phang}{cmd:(4) Average Position:} returns the average position in which
{cmd:keyword()} or {cmd:but()} were found.

{phang}{cmd:(5) Average TF-IDF:} returns the average tf-idf statistic for all
observations where {cmd:keyword()} or {cmd:but()} were found.

{phang}{cmd:(6) Means test:} returns the p-value of a t-test on the difference
of means across two immediate samples. It measures the improvement of using
{it:n} vs. {it:n-1} search criteria when identifying a subsample of textual
observations.


{title:Examples}

{phang}{cmd:. use https://github.com/aassumpcao/textfind/raw/master/CivilServantsNeverland.dta}{p_end}

{pstd}
This is a hypothetical dataset reporting positions of 5,000 government officials
 in Neverland. We want to identify all observations which contain the unigram
"officer" but which do not have the unigram "level". The usual steps would be:
(1) find observations using keyword "officer";
(2) find observations not containing keyword "level";
(3) find observations with keyword "officer" but remove observations which also
contain keyword "level".

{phang}
{cmd:. tab post if ustrregexm(post, "officer", 1) == 1}{p_end}

                            post |      Freq.     Percent        Cum.
    -----------------------------+-----------------------------------
    Senior Hook Security Officer |        525       34.79       34.79
    fairy officer (senior level) |        480       31.81       66.60
                         officer |        504       33.40      100.00
    -----------------------------+-----------------------------------
                           Total |      1,509      100.00

{phang}{cmd:. tab post if ustrregexm(post, "level", 1) == 0}{p_end}

                            post |      Freq.     Percent        Cum.
    -----------------------------+-----------------------------------
                         Analyst |        527       11.66       11.66
    Senior Hook Security Officer |        525       11.62       23.27
                         analist |        501       11.08       34.36
                         analyst |        476       10.53       44.89
                   fairy analyst |        512       11.33       56.22
                         officer |        504       11.15       67.37
                  piracy analyst |        492       10.88       78.25
                  senior manager |        507       11.22       89.47
           senior piracy analyst |        476       10.53      100.00
    -----------------------------+-----------------------------------
                           Total |      4,520      100.00

{phang}{cmd:. tab post if ustrregexm(post, "officer", 1) == 1 & ustrregexm(post, "level", 1) == 0}{p_end}

                            post |      Freq.     Percent        Cum.
    -----------------------------+-----------------------------------
    Senior Hook Security Officer |        525       51.02       51.02
                         officer |        504       48.98      100.00
    -----------------------------+-----------------------------------
                           Total |      1,029      100.00

{pstd}
Here is the result using {cmd:textfind}. It identifies the same observations as
the commands above but it does so in one line of code and it returns six
statistics on the quality of match.

{phang}{cmd:. textfind post, key("officer") but("level") nocase}

		                               Summary Table
    --------------------------------------------------------------------------------
    variable:   post
    n: 5000                                      Average                       Means
                        Total   -----------------------------------------       test
    keyword(s)          Finds      Finds     Length   Position     TF-IDF    p-value
    --------------------------------------------------------------------------------
    officer              1509          1    3.63419    2.36183    .567835    8.e-188
    --------------------------------------------------------------------------------
    Total                1029          1    2.53061    2.53061    .975933          0
    --------------------------------------------------------------------------------
    exclusion(s):
    "level"


{title:Stored Results}

{pstd}
{cmd:textfind} stores the following in {cmd:r()}:

{synoptset 16 tabbed}{...}
{p2col 5 16 18 2: Scalars}{p_end}
{synopt:{cmd:r(fvarmn)}} word {it:m} = [1,2,...], statistic {it:n} = [1,6],
found in each {it:var} from {varlist}.
{p_end}
{synopt:{cmd:r(nvarmn)}} word {it:m} = [1,2,...], statistic {it:n} = [1,6], not
found in each {it:var} from {varlist}.
{p_end}
{synopt:{cmd:r(max)}} maximum number of words in largest string {it:var} in
{varlist}.
{p_end}
{synopt:{cmd:r(nkey)}} number of find criteria.
{p_end}
{synopt:{cmd:r(mbut)}} number of exclusion criteria.
{p_end}


{p2col 5 16 18 2: Macros}{p_end}
{synopt:{cmd:r(allkey)}} all find criteria.
{p_end}
{synopt:{cmd:r(allbut)}} all exclusion criteria.
{p_end}

{p2col 5 16 18 2: Matrices}{p_end}
{synopt:{cmd:r(key)}} ({it:m+1}) x {it:6} matrix containing all find statistics.
{p_end}
{synopt:{cmd:r(but)}} [{it:m},{it:m+1}] x {it:6} matrix containing all exclusion
statistics.
{p_end}


{title:Author}

{phang}Andre Assumpcao{p_end}
{phang}The University of North Carolina at Chapel Hill{p_end}
{phang}Department of Public Policy{p_end}
{phang}aassumpcao@unc.edu{p_end}


{title:Acknowledgments}

{pstd}
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0056":Cox (2011)}
created the original number of occurrences statistics in {cmd:textfind}. Here I
have only modified the function arguments to allow for Unicode encoding search.



{title:References}

{phang} Cox, N. J. 2011. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0056":Stata tip 98: Counting substrings within strings.} {it:Stata Journal}, 11(2): 318-320.


{title:Also see}

{psee}
Help: {manhelp ustrregexm() D}, {help string functions}, {help moss()}

{psee}
FAQs: {browse "http://www.stata.com/support/faqs/data/regex.html":What are regular expressions and how can I use them in Stata?}
{p_end}

{psee}
FAQs: {browse "https://stats.idre.ucla.edu/stata/faq/how-can-i-extract-a-portion-of-a-string-variable-using-regular-expressions/":How can I extract a portion of a string variable using regular expressions? | Stata FAQ}
{p_end}
