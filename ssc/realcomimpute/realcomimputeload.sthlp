{smcl}
{cmd:help realcomImputeLoad}
{hline}

{title:Title}

{phang}
{bf:realcomImputeLoad} Load imputed data from Realcom Impute

{title:Syntax}

{p 8 17 2} {cmd:realcomImputeLoad}

{title:Description}

{pstd}
{cmd:realcomImputeLoad} loads imputed datasets which have been created using
the Realcom Impute package.

{title:Remarks}
{marker remarks}{...}

{pstd}
Along with datasets corresponding to multiple imputations of your data, the 
Realcom Impute package creates a file called impvals.txt, which contains
details of the imputed datasets. {cmd:realcomImputeLoad} looks in Stata's
current working directory for this file - you should therefore make sure
that Stata's working directory is set to the one where the imputations from 
Realcom were saved.

{pstd}
{cmd:realcomImputeLoad} should be called with the dataset with missing values
already loaded in Stata. {cmd:realcomImputeLoad} reads in the imputed dataset,
combines them into one file, and adds them to the original dataset. {cmd:realcomImputeLoad}
makes use of Stata 11's facilities for multiple imputation, and stores the imputed
data in so called wide form - see {helpb mi_styles}.

{pstd}
After loading the imputed datasets using {cmd:realcomImputeLoad}, analyses can
be performed using the {helpb mi_estimate} command. For a list of the estimation
methods which can be used, see {helpb mi_estimation}.

{pstd}
When mi setting the data, {cmd:realcomImputeLoad} treats each variable which was
specified as responses in Realcom Impute as an 'imputed' variable. Therefore,
if you specified responses which had no missing data, these will be listed as 'imputed',
variables but with zero imputed values.


{title:Author}

    Jonathan Bartlett
    jwb133@googlemail.com
	www.thestatsgeek.com
	www.missingdata.org.uk

{title:Also see}

    {helpb realcomImpute}
