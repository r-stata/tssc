{smcl}
{* *! version 1.0.2  24jan2012}{...}
{cmd:help spmat putmatrix}
{hline}

{title:Title}

{p2colset 5 24 27 2}{...}
{p2col:{cmd:spmat putmatrix} {hline 2}}Put a Mata matrix into an {bf:spmat}
object{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:spmat} {cmdab:putmat:rix} {it:objname} [{it:matname}]
[{cmd:,} {it:options}]


{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id(varname|vecname)}}variable or Mata vector containing unique IDs{p_end}
{synopt:{opt eig(vecname)}}Mata vector containing eigenvalues{p_end}
{synopt:{opt idist:ance}}convert distance data to inverse distances{p_end}
{synopt:{opt norm:alize(norm)}}normalization method{p_end}
{synopt:{opt b:ands(l u)}}lower and upper band of {it:matname}{p_end}
{synopt:{opt replace}}replace {it:objname}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{opt spmat putmatrix} puts Mata matrices into an existing {cmd:spmat} object
{it:objname}, or into a new {cmd:spmat} object, if the specified object does
not exist.  The optional unique place identifiers can be provided in the
{cmd:id()} option in a Mata vector {it:vecname} or in a Stata variable
{it:varname}.  If {it:objname} does not exist and you do not specify place
identifiers, {cmd:spmat putmatrix} will create the IDs {cmd:1}, ..., {it:n}.


{title:Options}

{phang}
{opt id(varname|vecname)} specifies a Stata variable or a Mata vector containing
	unique place identifiers.

{phang}
{opt eig(vecname)} specifies a Mata vector containing the eigenvalues of
	{it:matname}.

{phang}
{opt idistance} specifies to convert the data to inverse
    distances.  The value d will be converted to 1/d with the exception
    of the main diagonal, which will contain zero entries.

{phang}
{opt normalize(norm)} specifies the normalization method.
    {it:norm} can be {opt row}, {opt min:max}, or {opt spe:ctral}.

{phang}
{opt b:ands(l u)} specifies the lower and upper band of {it:matname} if
    {it:matname} is banded. Neither value can be greater than
    {cmd:floor((cols(}{it:matname}{cmd:)-1)/4)}.

{phang}
{opt replace} allows {it:objname} to be overwritten if it already exists.


{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. spmat use cobj using pollute.spmat}{p_end}
{phang2}{cmd:. spmat getmatrix cobj mymat, id(myid)}{p_end}
{phang2}{cmd:. spmat drop cobj}{p_end}

{pstd}Create the spmat object {cmd:cobj} from the Mata matrix {cmd:mymat} and the
Mata vector {cmd:myid}{p_end}
{phang2}{cmd:. spmat putmatrix cobj mymat, id(myid)}{p_end}


{title:Also see}

{psee}Online:  {helpb spmat}, {helpb spreg}, {helpb spivreg},
               {helpb spmap}, {helpb shp2dta}, {helpb mif2dta} (if installed){p_end}

