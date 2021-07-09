{smcl}
{* version 1.0.0 19apr2011}
{cmd:help filtertrace}
{hline}

{title:Title}

{p 5}
{cmd:filtertrace} {hline 2} Trace filter or contingency questions

{title:Syntax}

{p 5} Define filters

{p 8}
{cmd:filtertrace} {opt d:efine} [{varlist} {cmd::}] {help exp:{it:exp}} 
[{cmd:;} {it:exp ...}] {ifin} [{cmd:, }{it:options}]

{p 5} Check filters

{p 8}
{cmd:filtertrace} {opt c:heck} {it:vfe} [{cmd:;} {it:vfe ...}] 
[{cmd:, }{it:options}]


{p 5} where

{p 8}
{it:vfe} is [{it:list} {cmd::}] {help varlist:{bf:v}arlist} 
{cmd:(}[T] {bf:f}ilter#{cmd:)} [{help exp:{bf:e}xp}]

{p 5} in {it:vfe}

{p 8 11}
(filter#) is a {help numlist} indicating the filters for which {it:exp} is 
checked. Note that parenthesis must be used. The optional {it:T} indicates 
that {it:exp} is to be checked, only if the filters are true. The optional 
{it:list} is a list with as many elements as filters are specified, and 
indicates that filter 1 will be used checking {it:exp} for the first 
variable in varlist, filter 2 for the second and so on.

{p 5 8 8}
See {help filtertrace##def:filtertrace define} and 
{help filtertrace##chk:filtertrace check} for detailed explanations. Also 
see {help filtertrace##ex:Workflow examples}. 


{p 5} List defined filters

{p 8}
{cmd:filtertrace}

{p 5} Drop or clear filters and flags

{p 8}
{cmd:filtertrace} {{cmd:drop}|{cmd:clear}} [{cmd:all}]

{p 5} Reimport filters from variables or create variables

{p 8}
{cmd:filtertrace} {{opt i:mport}|{opt e:xport}} {it:name}


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:main}}
{synopt:{opt g:enerate(stub)}}create variables {it:stub#}{p_end}
{syntab :{it:define options}}
{synopt:{opt a:dd}}add filter/s{p_end}
{synopt:{opt replace(numlist)}}replace filter/s{p_end}
{syntab :{it:check options}}
{synopt:{opt full:exp}}use complete expression as (flag) variable 
labels{p_end}
{synopt:{opt nof:lag}}do not create variables tagging contradictions{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:filtertrace} is used to trace filter or contingency questions. In 
social research questionnaires often contain {it:contingency} questions, 
i.e. questions respondents are asked contingent on their answer to a 
previous {it:filter} question. {cmd:filtertrace} allows to detect (coding) 
errors in contingency questions in a two-step approach.

{pstd}
In a first step filter questions are reconstructed (see 
{help filtertrace##def:define}). In a second step contingency questions are 
checked and errors are tagged (see {help filtertrace##chk:check}). 

{pstd}
To learn about other subcommands see {help filtertrace##oth:here}.


{title:Options}

{dlgtab:Options}

{phang}
{opt generate(stub)} creates filter variables {it:stub1, ..., stubk}, 
tagging observations for which {it:exp} is true, when used with 
{cmd:filtertrace define}. Default is not to create filter variables. When 
used with {cmd:filtertrace check}, it creates indicator variables 
{it:stub#}, tagging contradictions. If not specified, {it:stub} defaults to 
{it:_con}.

{phang}
{opt add} adds new filters.

{phang}
{opt replace(numlist)} replaces all filters addressed by {it:numlist}.

{phang}
{opt fullexp} uses full expressions as variable labels for flags. Default 
is to use filter number and expression. Any {it:if} and {it:in} qualifiers 
used when defining the filters are omitted.

{phang}
{opt noflag} suppresses the creation of flag variables tagging 
contradictions. The summary report is also suppressed.


{title:Remarks}
{marker def}
{pstd}
{cmd:filtertrace define} is used to reconstruct filter questions in the 
questionnaire. It saves {it:exp} in {cmd:s(}{it:_fltrflg#_}{cmd:)}. Here 
{it:exp} refers to an expression as used in {cmd:if} statements. Thus 
{it:exp} usually contains at least one variable (e.g. var1 <= 42 & 
var1 >= 27). One expression represents one filter question. Use {bf:;} to 
separate multiple expressions. You do not specify names for filters. Once 
defined filters are later addressed using their number. If option 
{opt generate()} is specified, variables indicating observations for which 
{it:exp} is true, are created.

{pstd}
{ul:Helpful hint}

{pstd}
Note that {cmd:filtertrace define} allows an optional {it:varlist}. 
Placeholders {it:@} are used to refer to variables in {it:varlist}.
Specifying

	{cmd:filtertrace define var1-var3 : @ == 1}

{pstd}
is equal to 

	{cmd:filtertrace define var1 == 1 ; var2 == 1 ; var3 == 1}

{pstd}
Both lines will define three filters (1, 2 and 3). You may omit placeholder 
{it:@} in the first command, since a {it:basic} expression is used (see 
{help filtertrace##plc:Placeholders}).

{marker chk}
{pstd}
{cmd:filtertrace check} is used to detect errors in contingency questions. 
Each {it:vfe} specified (and separated by {bf:;}) is checked separately. A 
{it:vfe} consists of a {it:varlist} a list of filter numbers ({it:filter#}) 
and an expression ({it:exp}). For each variable specified in {it:varlist}, 
{it:exp} is checked for observations identified by the filters in 
{it:filter#}. Each {filter#} is checked separatly. A flag variable is 
created, tagging observations for which {it:filter#} is true but {it:exp} 
is {bf:not} true. Use placeholders to refer to variables in {it:varlist} 
(see {help filtertrace##plc: Placeholders}). If {it:exp} is not specified 
it defaults to {bf:!= .} (i.e. not system missing). 

{pstd}
{ul:Helpful hints}

{pstd}
Note that 

	{cmd:filtertrace check var1 (1) != .}

{pstd}
does not only check whether all observations, for which filter 1 is true, 
do not have system missing values in var1, but also checks the condition 
the other way round. That is, it also checks 

	{cmd:filtertrace check var1 !(1) == .}

{pstd}
To suppress the second check, type 

	{cmd:filtertrace check var1 (T 1) != .}

{pstd}
Also note the use of the optional {it:list}

	{cmd:filtertrace check 1/3 : var@ (1/3) != .}

{pstd}
is equal to

	{cmd:filtertrace check var1 (1) != . ; var2 (2) != . ; var3 (3) != .}

{marker oth}
{pstd}
{cmd:filtertrace} typed without subcommand lists and describes all defined 
filters.


{pstd}
{cmd:filtertrace drop} drops created filter variables. If {cmd:all} is 
specified, all flag variables, indicating observations with errors in 
contingency questions are also dropped. Note that it is not necessary to 
drop flag variables, since they are replaced each time 
{cmd: filtertrace check} is used.


{pstd}
{cmd:filtertrace clear} clears defined filters. If {cmd:all} is also 
specified, any user defined {it:stub} is cleared from {cmd:s()}. This is 
similar to specifying {help sreturn clear}.


{pstd}
{cmd:filtertrace import} reconstructs filters from variables previously 
created using {cmd:filtertrace define} with option {opt generate()}. 
Filters may only be imported if there are no filters defined yet.


{pstd}
{cmd:filtertrace export} creates flag variables {it:name#} from defined 
filters.

{marker plc}
{pstd}
{ul:{hi:Placeholders}}

{pstd}
{ul:Placeholders in expressions}

{pstd}
{cmd:filtertrace} knows two types of expressions. An expression is 
considered {it:basic} if it has only one variable and one 
{help operators:relational operator}. Expressions with at least one of the 
{it:logical operators} {bf:&} or {bf:|} are considered {it:complex}. 
Therefore {it:var1 <= 42} is a {it:basic} expression, while 
{it:var1 <=42 & var1 >= 27} is a {it:complex} expression. Note that the 
latter expression can be rewritten as a {help inrange()} function, e.g. 
{it: inrange(var1, 27, 42)}. Functions are also considered 
{it:complex expressions}.

{pstd}
In {it:complex expressions} placeholder/s {bf:@} must be used to refer to 
variables in {it:varlist}. The use of placeholders is not required in 
{it:basic} expressions. Thus typing

	{cmd:filtertrace check var1 var2 (1) > 42} 

{pstd}
is ok, as is 

	{cmd:filtertrace check var1 var2 (1) !inlist(@, 1, 2, 4)}

{pstd}
{ul:Placeholders in ({it:var}){it:list} ({cmd:filtertrace check} only)}

{pstd}
{cmd:filtertrace check} allows an optional {it:list}. This {it:list} 
indicates, that {it:exp} is to be checked for all variables, but contingent 
on different filters. Use placeholders to indicate which filter is to be 
used with which variable. The line

	{cmd:filtertrace check a b : var1@ var2@ var3@ (1/2) inlist(@, 1, 2, 4)}
 
{pstd}
is equal to

	{cmd:filtertrace check var1a var2a var3a (1) inlist(@, 1, 2, 4) ; ///}
	{cmd:var1b var2b var3b (2) inlist(@, 1, 2, 4)}

{pstd}
Note that {it:list} must have as many elements as filter numbers are 
specified. Also note that the placeholder in the {cmd:inlist()} function 
({it:complex} expression) does not have anything to do with the specified 
{it:list}.


{title:Examples}

	. sysuse nlsw88 ,clear

	{cmd:. filtertrace define age > 40 ; inrange(wage, 10, 25)}

{pstd}
defines two filters. Filter one is true for all observations older than 40, 
filter two is true for all observations with wages between 10 and 25.

	{cmd:. filtertrace}

{pstd}
lists the (two) defined filters.
	
	{cmd:. filtertrace export filter}

{pstd}
creates dummy variables {it:filter1} and {it:filter2}, indicating 
observations older than 40 and with wages between 10 and 25.

	{cmd:. filtertrace check married (1 2) == 1}

{pstd}
checks whether all observations older than 40 are married and all 
observations age 40 and younger are not married. It also checks whether 
all observations with wages between 10 and 25 are married and all 
observations with wages outside this range are single. There will be 
contradictions.

{marker ex}
{title:Workflow examples}

{pstd}
I will start with a simple example. Suppose a questionnaire containing the 
question {it:Are you pregnant?}. Obviously this (contingency) question 
should only be asked, if the respondent was female. Therefore it is 
preceded by a question about the respondent's gender. In our dataset we 
have two variables {it:gender} (with value 1 for women) and {it:pregnancy}. 
All male respondents are expected to have a (system) missing value in 
{it:pregnancy}. To check, we first reconstruct the filter.

	{cmd:filtertrace define gender == 0}

{pstd}
The syntax should be self-explanatory. It saves one condition (that is: one 
filter) in {bf:s(}{it:_fltrflg1_}{cmd:)}. Next we will check, whether 
{it:pregnancy} is missing for all male respondents.

	{cmd:filtertrace check pregnancy (1) == .}

{pstd}
Here we specified three arguments. We first specify the variable we want to 
check: {it:pregnancy}. The second argument is the filter's number, for 
which we want to check the (basic) expression specified as the third 
argument. The output we get will be something like
	
	variable: pregnancy

	      (1)
	          checking (pregnancy == .)
	          no contradictions
	     !(1)
	          checking !((pregnancy == .))
	          no contradictions

	         

	Contradictions

	          no contradictions

{pstd}
It tells us that there are no male respondents who answered the pregnancy 
question. The output also tells us, that there are no females who did not 
answer the question.

{pstd}
The above example is very simple, and we would probably be faster using 
{help tabulate_twoway:tabulate} and look at the cross tabulation of 
{it:gender} and {it:pregnancy} (however we would not be able to identify 
observations contradicting the condition, if there were any). We will see 
more complex examples below. 

{pstd}
For the moment pretend we did not have checked filter 1 yet. In our 
questionnaire we asked respondents of all ages. However we only asked the 
pregnancy question if respondents were female and age 14-55. All women 
younger than 14 or older than 55 are not supposed to have answered this 
question. To check we first add a second filter.

	{cmd:filtertrace define age : @ < 14 | @ > 55 ///}
	{cmd:if gender == 1 ,generate(filter) add}

{pstd}
We used a varlist (containing only the one variable {it:age}) so we can 
refer to this variable using placeholders in the {it:complex} expression. 
It is also ok to code 

	{cmd:filtertrace define age < 14 | age > 55 ///}
	{cmd:if gender == 1 ,generate(filter) add}

{pstd}
Note that {it:age} is not considered a {it:varlist} or {it:variable} here, 
but is part of {help expression:exp}. Also note the {it:if} qualifier 
(used in both cases) to restrict {it:exp} to women. All male respondents 
will have system missing values in variable {it:filter2}. Coding 

	{cmd:filtertrace define age : (@ < 14 | @ > 55) ///} 
	{cmd:& gender == 1 ,generate(filter) add}

{pstd}
will assign value 0 to all male respondents, as well as to all females aged 
14-55, but we do not want that. We can now check for (coding) errors in the 
pregnancy question.

	{cmd:filtertrace check pregnancy (T 1) == . ; pregnancy (2) == .}

{pstd}
In this example we used the optional {it:T} in {it:filter1} to suppress 
checking {it:exp} the other way round. We did so, because we do no longer 
expect {it:all} females to have answered the pregnancy question. We check 
{it:filter2} both ways because all females younger than 14 and older than 
55 are expected to have missing values, while {it:all} females between age 
14 and 55 must have answered the pregnancy question.

{pstd}
In a last example, suppose we used a position generator 
(Lin and Dumnin 1986) in our questionnaire. We presented respondents a list 
of 10 occupations asking them to indicate whether they knew anyone having 
these occupations. If so, we asked them about this person's gender age and 
education. The position generator leaves us with 40 variables in our 
dataset (occ1-occ10, gender1-gender10, age1-age10, edu1-edu10). Respondents 
who do not know anyone having occupation 1 are expected to have missing 
values in gender1, age1 and edu1. Respondents knowing someone with 
occupation {it:x} must not have (system) missings. We check this by 
defining ten (more) filters -- one for each occupation.

	{cmd:filtertrace define occ1-occ10 : == 1 ,add}

{pstd}
This line creates 10 filters (filters 3 to 12). Next we check the 
contingency questions.

	{cmd:filtertrace check gender1 age1 edu1 (1) != . ; ///}
	{cmd:gender2 age2 edu2 (2) != . ; [...] ; ///}
	{cmd:gender10 age10 edu10 (10) != .}

{pstd}
These lines will work fine, but are sure a lot of typing. It might be more 
convenient to type

	{cmd:filtertrace check 1/10 : gender@ age@ edu@ (3/12) != .} 

{pstd}
You may also create a simple {help forvalues} loop. The advantage of the 
line given is, that there will only be one summary report instead of 10 
with the {cmd:forvalues} loop.  


{title:Acknowledgments}

{pstd}
The idea for {cmd:filtertrace} is partly inspired by Krishnan Bhaskaran's 
{cmd:datacheck}.

{pstd}
See Bill Rising's {cmd:ckvar} for a more sophisticated approach to 
data validation.

{title:References}

{pstd}
Lin, N and Dumnin, M (1986). Access to Occupations through Social Ties. Social 
Networks, 8. 365-385


{title:Author}

{pstd}Daniel Klein, University of Bamberg, klein.daniel.81@gmail.com

{title:Also see}

{psee}
Online: {help assert}, {help mi()}, {help inlist()}, {help inrange()}, 
{help forvalues}{p_end}

{psee}
if installed: {help datacheck}, {help ckvar}{p_end}
