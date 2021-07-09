{smcl}
{* version 1.0}{...}
{* 07mar2017}{...}
{viewerjumpto "Syntax" "respdiff##syn"}{...}
{viewerjumpto "Functions" "respdiff##fcn"}{...}
{viewerjumpto "Description" "respdiff##des"}{...}
{viewerjumpto "Examples" "respdiff##exa"}{...}
{viewerjumpto "Authors" "respdiff##aut"}{...}
{viewerjumpto "References" "respdiff##ref"}{...}
{title:Title}

{p 4 4 2}{hi:respdiff} {hline 2} Generating response differentiation indices


{marker syn}	
{title:Syntax}

{p 8 8 2}{cmd:respdiff} {newvar} {cmd:=} {it:fcn}({varlist}) [{it:{help if:if} exp}] [{it:{help in:in} range}]

{p 4 8 2}where {it:fcn} specifies the response differentiation index that is 
computed based on the variables in {varlist}, and where {it:fcn} is


{marker fcn}	
{phang2}
{opth cv(varlist)}{p_end}
{pmore2}
It creates the coefficient of variation {it:CV} for each row {it:r} of the data set
(e.g., survey respondents) over the {it:n} variables in {it:varlist}, 
ignoring missing values. Technically, {it:CV_r} is computed as the standard deviation
of responses {it: s_r} divided by the mean of the responses {it:x-bar_r} 
(see below for details on the computation of the standard deviation {it:s_r}). 

{phang2}
{opth nondiff(varlist)}{p_end}
{pmore2}
It creates a binary variable inicating whether rows {it:r}  
of the data set have the same value in the {it:n} variables in {it:varlist} (i.e., 
non-differentiated response patterns), ignoring missing values. Technically, 
a non-differentiated response pattern is equivalent to a standard deviation 
{it:s_r} = 0 (see below for details on the computation of the standard deviation 
{it:s_r}).

{phang2}
{opth sd(varlist)}{p_end}
{pmore2}
It creates the standard deviation {it:s} for each row {it:r} of the data set (e.g., survey respondents)
over the {it:n} variables in {it:varlist}, ignoring missing values. The standard
deviation {it:s_r} equals the square root of the sum of the squared deviations 
of the individual responses to the variables {it:x_ri} from the mean of the responses 
to the variables {it:x-bar_r} divided by the number of variables {it:n_r}.

{phang2}
{opth stdsd(varlist)}{p_end}
{pmore2}
It creates the {it:z}-standardized standard deviation for each row of the data set
{it:s_r} for the {it:n} variables in {it:varlist}, ignoring missing values. 


{marker des}
{title:Description}

{p 4 4 2} The {cmd:respdiff} command enables users to generate several indices 
of response differentiation for each row {it:r} of the data set over the {it:n} 
variables in {it:varlist}, ignoring missing values (i.e., system missing values 
and numeric values that have been changed to missing values using 
the {cmd:mvdecode} command).

{p 4 4 2} {hi: Theoretical background:} Research in survey methodology has provided ample 
evidence that survey respondents differ in the extent to which they differentiate 
their answers to survey questions (Krosnick 1991). With respect to this finding, 
the theory of survey satisficing proposes that under certain 
conditions respondents might select a somehow reasonable response option for the 
first item in a set of question items, and rate all (or almost all) remaining 
items with the exactly same response value (Krosnick 1991). 
In survey methodology, this response pattern is usually referred to as response 
non-differentiation (e.g., Krosnick and Alwin 1988, Krosnick 1991) 
or straightlining (e.g., Couper et al. 2013). The {cmd:respdiff} command enables 
users to generate several indices of response differentiation. While the function 
{it:nondiff} creates a binary indicator for non-differentiated responses, the 
remaining functions (i.e., the ({it:z}-standardized) standard deviation of responses, 
and the coefficient of variation) provide measures of the extent to which each
respondent provided differentiated responses to survey questions. 


{marker exa}
{title:Examples}

{p 4 8 2} Generating a binary variable that indicates whether respondents provided 
non-differentiated responses to the variables v1a through v1d. 

	{com}. respdiff v1_nondiff = nondiff(v1a v1b v1c v1d)
	{txt}

{p 4 8 2} Generating the standard deviation of the responses over the variables 
v1_1 through v1_5.

	{com}. respdiff v1_sd = sd(v1_1 v1_2 v1_3 v1_4 v1_5)
	{txt}

{p 4 8 2} Generating the coefficient of variation for the variables 
q11a through q11e.

	{com}. respdiff q11_cv = cv(q11a q11b q11c q11d q11e)
	{txt}
	
	
{marker aut}
{title:Author}

{p 4 8 2} Joss Roßmann, GESIS {c -} Leibniz Institute for the Social Sciences, joss.rossmann@gesis.org 

{p 4 8 2} Copyright (C) 2017  Joss Roßmann

{p 4 4 2} This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

{p 4 4 2} This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details <http://www.gnu.org/licenses/>.

{p 4 4 2} Recommended citation (APA Style, 6th ed.): {break}
Roßmann, J. (2017). RESPDIFF: Stata module for generating
response differentiation indices (Version: 1.0) 
[Computer Software]. Chestnut Hill, MA: Boston College.


{marker ref}
{title:References}

{p 4 8 2} Couper, M. P., Tourangeau, R., Conrad, F. G., & Zhang, C. (2013). 
The Design of Grids in Web Surveys. 
Social Science Computer Review, 31(3), 322-345. 

{p 4 8 2} Krosnick, J. A. (1991). Response Strategies for Coping with the 
Cognitive Demands of Attitude Measures in Surveys. 
Applied Cognitive Psychology, 5(3), 213-236. 

{p 4 8 2} Krosnick, J. A., & Alwin, D. F. (1988). A Test of the Form-Resistant 
Correlation Hypothesis. Ratings, Rankings, and the Measurement of Values. 
Public Opinion Quarterly, 52(4), 526-538.


