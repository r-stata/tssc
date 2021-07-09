{smcl}
{* 05Oct2015}{...}
{cmd:help dcreate}
{hline}

{title:Title}

{p2colset 5 15 18 2}{...}
{p2col :{hi: dcreate} {hline 1}}Efficient designs for discrete choice experiments{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd: dcreate}
{help fvvarlist}
{opt ,}
{opt nalt(#)} {opt nset(#)} {opt b:mat(name)} [{opt v:mat(name)} {opt asc(numlist)} {opt fixedalt(name)} {opt maxiter(#)} 
{opt criterion(#)} {opt seed(#)} {opt nrep(#)} {opt burn(#)}]

{p 8 15 2}
{cmd:genfact} [{opt ,} {opt levels(name)}]

{p 8 15 2}
{cmd:blockdes} {newvar} {opt ,} {opt nblock(#)} [{opt neval(#)} {opt seed(#)}]

{p 8 15 2}
{cmd:evaldes} {help fvvarlist} {opt ,} {opt b:mat(name)} [{opt v:mat(name)} {opt nrep(#)} {opt burn(#)}]


{title:Description}

{pstd}
{cmd:dcreate} creates efficient designs for discrete choice experiments using the modified 
Fedorov algorithm (Cook and Nachtsheim, 1980; Zwerina et al., 1996; Carlsson and Martinsson, 2003). 
The algorithm maximises the D-efficiency of the design based on the covariance matrix of the 
conditional logit model.

{pstd}
{cmd:dcreate} assumes that the dataset in memory contains the candidate set, i.e. the set of
alternatives from which the choice sets will be created. This will often be the full-factorial
design, which can be created using {cmd:genfact}.

{pstd}
In addition to the variables in the design {cmd:dcreate} creates two id variables, {cmd: choice_set} 
and {cmd: alt}, where {cmd: choice_set} identifies the choice set and {cmd: alt} identifies the 
alternatives within the choice set.

{pstd}
After running {cmd:dcreate} the {cmd: blockdes} command can be used to divide the design into blocks.
This is useful for large designs where it is considered infeasible for a single respondent to complete
all of the choice sets. 

{pstd}
The {cmd: evaldes} command can be used to evaluate the D-efficiency of a generated design for 
alternative model specifications and/or coefficient priors.  


{title:Options for dcreate}

{phang}
{opt nalt(#)} is required; it specifies the number of alternatives in the design.

{phang}
{opt nset(#)} is required; it specifies the number of choice sets in the design.

{phang}
{opt bmat(name)} is required; it specifies a matrix of coefficient priors used to evaluate 
the D-efficiency of the design.

{phang}
{opt vmat(name)} optionally specifies the covariance matrix of the coefficient priors. This allows for 
uncertainty in the priors by using a Bayesian design (Sándor and Wedel, 2001). The priors are assumed to 
be normally distributed, and the D-efficiency measure is approximated using simulation (see {cmd:nrep} 
and {cmd:burn} below for related options). Specifying this option significantly increases the time 
required to generate a design.

{phang}
{opt asc(numlist)} include alternative-specific constants (ASCs) for the alternatives in {it: numlist}.
Coefficients for the ASCs must be included as the final elements of {cmd: bmat}.

{phang}
{opt fixedalt(name)} specifies a matrix with attribute levels for an additional alternative 
in the design. The attribute levels for this alternative are held constant at the specified 
levels in all of the generated choice sets. This option can for example be used to include an 
"opt-out" (or "no purchase") alternative in the design (see Example 3 below).

{phang}
{opt maxiter(#)} specifies the maximum number of iterations for the modified Fedorov
algorithm; default is {cmd:maxiter(10)}.

{phang}
{opt criterion(#)} specifies the convergence criterion for the modified Fedorov algorithm;
default is {cmd:criterion(0.00001)}.
								  
{phang}
{opt seed(#)} sets the random-number seed; default is {cmd:seed(435)}.

{phang}
{opt nrep(#)} specifies the number of draws used for the simulation. The default is {cmd:nrep(50)}.
This option is only relevant if {cmd: vmat} has been specified.

{phang}
{opt burn(#)} specifies the number of initial sequence elements to drop when creating the Halton 
sequences used in the simulation. The default is {cmd:burn(15)}. This option is only relevant if 
{cmd: vmat} has been specified.


{title:Options for genfact}

{phang}
{opt levels(name)} is required; it specifies a matrix containing the levels of the attributes in the design.


{title:Options for blockdes}

{phang}
{opt nblock(#)} is required; it specifies the number of blocks.

{phang}
{opt neval(#)} specifies the number of evaluations for the blocking algorithm. The default is 
{cmd:neval(10)}. In each evaluation a blocking variable is randomly generated and its association
with the design variables is measured using a series of Pearson chi-squared tests. The blocking 
variable with the lowest association with the design attributes is chosen as the final blocking 
variable.{cmd: Important: blockdes} assumes that no changes to the dataset have been made after 
running {cmd: dcreate}. Any changes are likely to affect the quality of the blocking.
								  
{phang}
{opt seed(#)} sets the random-number seed; default is {cmd:seed(435)}.


{title:Examples}

{pstd}
The following examples create choice designs with 2 alternatives and 16 choice sets. 
There are 2 four-level attributes and 4 two-level attributes in the design.{p_end}

{pstd}
{cmd:Example 1:} All the attributes are treated as qualitative using dummy coding.

{pstd}
Create a dataset containing the full-factorial using {cmd:genfact}. The four-level
attributes are coded 1/2/3/4 and the two-level attributes 1/2: {p_end}

{phang}{cmd:. matrix levmat = 4,4,2,2,2,2}{p_end}
{phang}{cmd:. genfact, levels(levmat)}{p_end}

{pstd}
Define {cmd:b}, the coefficient matrix. In this and the following examples all of 
the coefficients are assumed to be equal to zero:{p_end}

{phang}{cmd:. matrix b = J(1,10,0)}{p_end}

{pstd}
Create a design with 16 choice sets using {cmd:dcreate}. Dummy coding of the design 
attributes is specified using factor variable notation (see {help fvvarlist}). The 
lowest level (1) is treated as the base level:{p_end}

{phang}{cmd:. dcreate i.x1 i.x2 i.x3 i.x4 i.x5 i.x6, nalt(2) nset(16) bmat(b)}{p_end}

{pstd}
Divide the design into two blocks with 8 choice sets each using {cmd:blockdes}:{p_end}

{phang}{cmd:. blockdes block, nblock(2)}{p_end}

{pstd}
{cmd:Example 2:} As Example 1 but including an interaction between attributes {cmd:x3} and {cmd:x4}:

{phang}{cmd:. matrix levmat = 4,4,2,2,2,2}{p_end}
{phang}{cmd:. genfact, levels(levmat)}{p_end}
{phang}{cmd:. matrix b = J(1,11,0)}{p_end}

{phang}{cmd:. dcreate i.x1 i.x2 i.x3##i.x4 i.x5 i.x6, nalt(2) nset(16) bmat(b)}{p_end}

{pstd}
Evaluate the efficiency of the generated design for the model specification in Example 1:{p_end}

{phang}{cmd:. matrix b = J(1,10,0)}{p_end}
{phang}{cmd:. evaldes i.x1 i.x2 i.x3 i.x4 i.x5 i.x6, bmat(b)}{p_end}

{pstd}
{cmd:Example 3:} As Example 1 but including an additional "opt-out" alternative with an associated alternative-specific constant:

{phang}{cmd:. matrix levmat = 4,4,2,2,2,2}{p_end}
{phang}{cmd:. genfact, levels(levmat)}{p_end}

{pstd}
Create a matrix containing the attribute levels for the opt-out alternative. All the attribute levels are 
set to the base level (1):{p_end}

{phang}{cmd:. matrix optout = J(1,6,1)}{p_end}

{phang}{cmd:. matrix b = J(1,11,0)}{p_end}

{phang}{cmd:. dcreate i.x1 i.x2 i.x3 i.x4 i.x5 i.x6, nalt(2) nset(16) fixedalt(optout) asc(3) bmat(b)}{p_end}

{pstd}
{cmd:Example 4:} As Example 1 but allowing for uncertainty in the priors using a Bayesian design:

{phang}{cmd:. matrix levmat = 4,4,2,2,2,2}{p_end}
{phang}{cmd:. genfact, levels(levmat)}{p_end}
{phang}{cmd:. matrix b = J(1,10,0)}{p_end}

{pstd}
Define {cmd:V}, the coefficient covariance matrix, which in this example is assumed to be equal
to the identity matrix:{p_end}

{phang}{cmd:. matrix V = I(10)}{p_end}

{phang}{cmd:. dcreate i.x1 i.x2 i.x3 i.x4 i.x5 i.x6, nalt(2) nset(16) bmat(b) vmat(V)}{p_end}


{title:References}

{phang}Carlsson F, Martinsson P. 2003. Design techniques for stated preference methods in health 
economics. {it:Health Economics} 12: 281-294.

{phang}Cook RD, Nachtsheim CJ. 1980. A comparison of algorithms for constructing exact D-optimal
designs. {it:Technometrics} 22: 315-324.

{phang}Sándor Z, Wedel M. 2001. Designing conjoint choice experiments using managers’
prior beliefs. {it:Journal of Marketing Research} 38: 430–444.

{phang}Zwerina K, Huber J, Kuhfeld W. 1996. A general method for constructing efficient choice designs. 
Working Paper, Fuqua School of Business, Duke University.


{title:Author}

{phang}This command was written by Arne Risa Hole (a.r.hole@sheffield.ac.uk),
Department of Economics, University of Sheffield. Comments and suggestions are welcome. {p_end}



