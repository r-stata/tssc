{smcl}
{* *! version 1.0.0.  01aug2007}{...}
{cmd:help blinding}
{hline}

{title:Title}

{p2colset 9 21 23 2}{...}
{p2col :{hi:  blinding} {hline 2}}Estimate blinding index{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:blinding} matname [{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth bwei:ght(matname)}}weights for the main data, to be used in Bang's index
          when the data is in the 2x5 form{p_end}
{synopt :{opth anc:illary(matname)}}ancillary data{p_end}
{synopt :{opth ancw:eight(matname)}}weights for the ancillary 
data{p_end}
{synopt :{opt le:vel(#)}}confidence level{p_end}


{title:Description}

{pstd}
{opt blinding} is an implementation of the blinding indexes introduced by James et al (1990) and
Bang et al (2004), to assess the success of blinding in clinical trials. The command performs
the estimation of both indexes, along with standard errors, confidence intervals and significance
levels, based on the null hypothesis that the trial is successfully blinded.

{pstd}
The usual procedure to measure the effectivness of blindness is to ask the participants for
the treatment allocation they believe they are assigned. The command -blinding- works with the
two most common structures for the responses, that is, the 2x3 setting and the 2x5 setting.

{pstd}
The argument {it:matname} is a matrix of dimensions either 2x3 or 2x5, where the rows
correspond to the true allocation of the participants: the first row contains the data from 
the drug arm and the second row contains the data from the placebo arm; the columns correspond 
to the treatment allocation that participants believe they are assigned. In the 2x3 setting, 
the columns correspond to drug, placebo and "don't know" (DK) respectively, and in the 2x5 
setting, the columns correspond to "strongly believe that the treatment is drug", "somehow 
believe that the treatment is drug", "somehow believe that the treatment is placebo", "strongly 
believe that the treatment is placebo" and "don't know", in this order.

{pstd}
The Jame's index is only computed for the 2x3 setting. When the
original data is entered in the 2x5 form, it is transformed to
the 2x3 form in order to compute the James' index.

{title:Options}

{phang}
{opth bweight(matname)}
specifies the weights to be applied to the main data for computing the Bang's index
when the data is in the 2x5 format. This option is used to assign weights to the 
"somewhat believe" responses and the "strongly believe" responses. 
It is a matrix in the same 2x5 format; the default is {cmd:weight(1,0.5,0.5,1,0\1,0.5,0.5,1,0)}.
According to Bang et al(2004), the weights matrix needs to verify the following
conditions: the elements of this matrix should be numbers between 0 and 1; the first and the 
forth column should be equal; the second and the third column should be equal; the last column 
should only contain zeros.

{phang}
{opth ancillary(matname)} specifies a 2x3 matrix of ancillary data (when available),
to be used to compute the Bang's index. In some trials, participants who answer 
DK are asked to choose a treatment allocation anyway. The ancillary matrix contains
this data. Therefore, the total of counts for each row in this matrix should be equal
to the corresponding DK cell in the main data matrix.

{phang}
{opth ancweight(matname)}
specifies a 2x3 matrix containing the weights for the ancillary data.
Requires the ancillary() option. The default is {cmd:ancweight(0.25,0.25,0\0.25,0.25,0)}.
This matrix needs to verify: the entries should be numbers between 0 and 1; 
the first and the second column should be equal; the last column should only 
contain zeros.

{phang}
{opt level(#)} specifies the level of the confidence intervals. The default is 
{cmd:level(95)}.



{title:Examples}

    Setup
         {cmd:. matrix define A=(2,5,3,4,6\2,4,3,5,8)}
         {cmd:. matrix define B=(1,0.6,0.6,1,0\1,0.6,0.6,1,0)}
         {cmd:. matrix define C=(3,3,0\3,4,1)}
         {cmd:. matrix define D=(0.2,0.2,0\0.2,0.2,0)}

{pstd}Estimate blinding indexes for A{p_end}
{phang2}{cmd:. blinding A}

{pstd}Estimate blinding indexes for A using the weight matrix B{p_end}
{phang2}{cmd:. blinding A, bweight(B)}

{pstd}Estimate blinding indexes for A using the ancillary data C{p_end}
{phang2}{cmd:. blinding A, ancillary(C)}

{pstd}Estimate blinding indexes for A using the ancillary data C and its weight 
D{p_end}
{phang2}{cmd:. blinding A, ancillary(C) ancweight(D)}

{pstd}Estimate blinding indexes for A using the weight matrix B and the ancillary data 
C{p_end}
{phang2}{cmd:. blinding A, bweight(B) ancillary(C)}

{pstd}Estimate blinding indexes for A using the weight matrix B, the ancillary data C and 
its weight D, and specify the level of confidence interval to 90{p_end}
{phang2}{cmd:. blinding A, bweight(B) ancillary(C) ancweight(D) level(90)}



{title:Saved results}

{pstd}
{cmd:blinding} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}vector containing the reported indexes{p_end}
{synopt:{cmd:r(var)}}vector containing the variances of the indexes{p_end}


{title:References}

{pstd}
Bang, H., L. Ni, and  C. E. Davis. 2004. Assessment of blinding in 
clinical trial. {it:Controlled Clinical Trials} 25: 143-156.

{pstd}
James, K. E., K. K. Lee,  H. K. Kraemer, and R. K. Fuller. 1990.
An index for assessing blindness in  a multicenter clinical trial: 
disulfiram for alcohol cessation-a VA cooperative study. 
{it: Statistics in Medicine} 15: 1421-1434.


{title:Author}

{pstd}
Jiefeng Chen, Texas A&M University, Department of Statistics
{pstd}
jfchen@stat.tamu.edu





