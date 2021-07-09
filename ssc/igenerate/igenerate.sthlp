{smcl}
{* 29Apr2015}{...}
{hline}
help {cmd:igenerate} {right: {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt-Catran}}
{hline}

{title:Applying different coding schemes to categorical variables (1.0.3 - beta version)}:


{p 4}Syntax

{p 8 4}{cmd:igenerate} {varlist} {ifin} ,  {cmdab:c:oding}{cmd:({it:coding scheme})} {cmd:[{cmdab:gen:erate}({it:stubnames})] [{cmdab:o:mit}({it:omitted categories})] [ia]}



{title:Description}

{p 4 4} {cmd:ignerate} allows generating indicator variables for different coding schemes. {cmd:ignerate} creates variable for the following coding schemes:
  
{p 8 4} 1.   Dummy coding

{p 8 4} 2.   Effect/deviation coding

{p 8 4} 3.   Weighted effect/deviation coding

{p 8 4} 4.   Forward adjacent coding

{p 8 4} 5.   Backward adjacent coding

{p 4 4} Additionally, {cmd:ignerate} allows generating orthogonal interaction terms of weighted effect coded indicator variables (see Te Grotenhuis et al., 2016b) .

{p 4 4} {cmd:ignerate} allows a maximum of two variables in {varlist}. It should in principle be used with one variable at a time.
Speciyfing two variables in {varlist} should be done if interaction terms between these two variables are to be build. 
  

{p 4 4} Note that stata provides a build-in postestimation command ({cmd:{helpb contrast}}) that provides regression results for a variety of different coding schemes.
 For most situations in applied research {cmd:{helpb contrast}} may be the better alternative. However, for didactical purposes and some special situations 
 {cmd:igenerate} might be a valuable alternative because it allows getting the estimates directly from the regression output without 
 the need to apply a postestimation command. Orthogonal interaction terms of weighted effect coded indicator variables are also not available in {cmd:{helpb contrast}}.
  
{title:Options}

{p 4 8} {cmdab:c:oding}{cmd:({it:coding scheme})} specifies the coding scheme to be applied. {cmd:{it:coding scheme}} must be one of the following alternatives:

{p 8 8} {cmdab:d:ummy}: Standard dummy coding. Compares the levels of the variables in {varlist} to one reference category. 
If the option {cmdab:o:mit} is not specified, {cmd:igenerate} will generate as many indicators as the variables in {varlist} have levels. 
If the option {cmdab:o:mit} is specified, {cmd:igenerate} will not generate indicator variables for the chosen reference categories. 
In this case, the labels of the remaining dummy variables will indicate the reference group.

{p 8 8} {cmdab:e:ffect}: Effect/Deviation coding. Compares the levels of the variables in {varlist} to their grand mean; this is, the mean of the dependent variable 
as if all categories of  the variables in {varlist} had the same number of observations. If the option {cmdab:o:mit} is not specified, 
{cmd:igenerate} will select the first category of the variables in {varlist} as the omitted categories. If the option {cmdab:o:mit} is specified, 
{cmd:igenerate} will not generate an indicator variable for the chosen categories. The labels of the generated variables will indicate the contrast.

{p 8 8} {cmd:weightedeffect}: Weighted effect/deviation coding. compares the levels of the variables in {varlist} to the observed mean. If the option {cmdab:o:mit} is not specified, 
{cmd:igenerate} will select the first category of the variables in {varlist} as the omitted categories. If the option {cmdab:o:mit} is specified, 
{cmd:igenerate} will not generate an indicator variable for the chosen categories. The labels of the generated variables will indicate the contrast.

{p 8 8} {cmd:we}: Same as {cmd:weightedeffect}.

{p 8 8} {cmd:sweeney}: Same as {cmd:weightedeffect}.

{p 8 8} {cmdab:a:djacent}: Compares each level of the variables in {varlist} to the next (adjacent) level. 
This option cannot be combined with {cmdab:o:mit} because the omitted category is always the first. 
The labels of each generated variable indicate the reference group. 

{p 8 8} {cmd:reverseadjacent}: Compares each level of the variables in {varlist} to the former (prior adjacent) level. 
This option cannot be combined with {cmdab:o:mit} because the omitted category is always the first. 
The labels of each generated variable indicate the reference group. 

{p 8 8} {cmd:ra}: Same as {cmd:reverseadjacent}.

{p 4 8} {cmd:ia} Generates orthogonal interaction terms of weighted effect coded indicator variables. {cmd:ia} is allowd only in combination with weighted effect
coding (sweeney coding). {cmd:ia} needs two variables in {varlist}. It builds interaction terms between the two sets of indicators from these two variables.


{p 4 8} {cmdab:gen:erate}{cmd:({it:stubnames})} Defines the name(s) for the generated indicator variables. 
If the option {cmdab:gen:erate} is specified, the constructed variables will begin with {it:stubname} followed by consecutive numbers. 
If the option {cmdab:gen:erate} is not specified, {it:stubname} will be identical to the variables' names in {varlist}. 

{p 4 8} {cmdab:o:mit}{cmd:({it:omitted categories})} Specifies the categories of the variables in {varlist} that ought to be omitted from the regression. 
{cmdab:o:mit} is not allowed in combination with (reversed) adjacent coding. If {cmdab:o:mit} is not specified, 
{cmd:igenerate} will select the first level as the omitted category for every coding scheme except dummy coding 
(because dummy coding is independent of the reference category). If {cmdab:o:mit} is specified, {cmd:igenerate} will omit the specified category.
If {varlist} contains two variables, {cmdab:o:mit} allows two distinct numbers to be specified. If {varlist} contains two variables and {cmdab:o:mit} contains only one argument,
the category specified in {cmdab:o:mit} is used as the omitted category for both variables. 
Note that the {it:omitted category} is the value of that category, not the position of that category. 

{title:Notes}

{p 4 4} Note that some coding schemes (in particular weighted effect coding) may require that {cmd:igenerate} knows the sample that is used in the 
following regression. If your regression excludes cases for which the variables in {varlist} have valid observations (non-missing values), you should use {cmd:{helpb if}} 
to restrict {cmd:igenerate} to the corresponding sample, if you want the reference to be the observed mean in the sample of the regression.


 
{title:References}

{p 4 8} Te Grotenhuis, M.; Pelzer, B.; Schmidt-Catran, A.W.; Nieuwenhuis, R.; König, R. and Eisinga, R. (2016a): When Size Matters. Advantages of Weighted Effect Coding in Observational Studies. International Journal of Public Health (online first).

{p 4 8} Te Grotenhuis, M.; Pelzer, B.; Schmidt-Catran, A.W.; Nieuwenhuis, R.; König, R. and Eisinga, R. (2016b): Weighted effect coded interaction effects: a novel moderated regression model for observational studies. International Journal of Public Health (online first).

{title:Authors}

{p 4 6} Alexander Schmidt-Catran, Institute of Sociology and Social Psychology, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, 
{browse "www.schmidt-catran.de":www.schmidt-catran.de}.


