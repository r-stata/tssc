{smcl}
help for {hi:drm} version 0.5 {right: (Caspar Kaiser)}
{hline}
{title:Diagonal Reference Models (DRM)}

{title:Syntax}

{p 4 4 2}
{cmd:drm}
{it:{help depvar}}
{it:rowvar}
{it:colvar}
[{it:{help varlist}}] 
[{cmd:if} {it:exp}] 
[{it:{help weight}}] 
[{cmd:,} {it:options}]

{synoptset tabbed}{...}
{synopthdr}
{synoptline}
{syntab:General {help drm##opt_general:[+]}}
{synopt:{cmd:vce(}{it:{help vcetype}}{cmd:)}}set standard error type{p_end}
{synopt:{cmd:wgt(}{it:str}{cmd:)}}one of {cmd:cons}, {cmd:row} or {cmd:col}; specifies if weights are assumed to be constant (default) or dependent on {it:rowvar} ({cmd:row}) or {it:colvar} ({cmd:col}){p_end}
{synopt:{opt inter:vars}{cmd:(}{it:{help varlist}}{cmd:)}}interact weights p and q with {it:{help varlist}}{p_end}
{synopt:{opt iter:ate(#)}}specifies the maximum number of iterations{p_end}
{synopt:{opt l:evel(#)}}set confidence level{p_end}
{synopt:{opt coefl:egend}}specifies that the legend of the coefficients and how to specify them in an expression be displayed rather than displaying the statistics for the coefficients{p_end}
{synopt:{opt ke:ep}}prevents deletion of generated dummies for {it:rowvar} and {it:colvar} after estimation {p_end}
{synopt:{opt old}}forces {cmd:drm} to behave as it did until version 0.4, i.e. to generate illegible temporary variable names for {it:rowvar} and {it:colvar} {p_end}

{syntab:Maximum likelihood {help drm##opt_ml:[+]}}
{synopt:{cmd:link(}{it:str}{cmd:)}}one of {cmd:linear}, {cmd:logit} or {cmd:probit}; specifies link function; default is {cmd:link(}linear{cmd:)} {p_end}
{synopt:{cmd:tech()}}specifies maximization algorithm; see {help ml} for options{p_end}
{synopt:{opt diff:icult}}specifies difficult option; see {help maximize}{p_end}
{synopt:{opt s:obel}}use Sobel's method to find initial value; the default{p_end}
{synopt:{opt cl:assic}}use classic initial values for mu{p_end}
{synopt:{opt a:lternative}}use alternative initial values for mu{p_end}
{synopt:{opt ownc:onstrains}{cmd:(}{it:str}{cmd:)}}specifies further user-written constrains{p_end}

{syntab:Least squares {help drm##opt_nl:[+]}}
{synopt:{cmd:by(}{it:{help varlist}}{cmd:)}}specify variables on which estimates of mu[i,i] and mu[j,j] are made conditional. If more than one variable is specified, every combination of {help varlist} is taken. {p_end}
{synopt:{opt c:onstrain}}explicitly constrains p to lie on [0,1] {p_end}

{synoptline}
{p 4 4} {cmd:pweights}, {cmd:aweights}, {cmd:fweights}, and {cmd:iweights} are allowed; see {help weight}. {p_end}
{p 4 4} factor variables are allowed, but time-series operators are not (yet) supported. {p_end}
{p 4 4} Typing {cmd:drm} without arguments redisplays previous results. {p_end}

{marker introduction}{...}
{title:Introduction}

{p 4 4}{cmd:drm} is a module to estimate several versions of Sobel's (1981; 1985) diagonal reference model. 
Diagonal reference models are especially suited for the estimation of effects of movements across levels of categorical variables like education or social class.
{cmd:drm} allows for a number of extensions that go beyond Sobel's most simple model. 
In particular, weights are allowed to vary conditional on 'destinations' and 'origins' and may be interacted with an arbitrary linear combination of covariates. 
Furthermore, diagonal population means may be estimated conditional on a further (set of) variable(s). 
Finally, next to the linear link function, {cmd:drm} allows for logit as well as probit links to estimate models with a binary dependent variable.

{p 4 4}{cmd:drm} was inspired by and is an alternative to Lizardo's (2007) {cmd: diagref} command (which is no longer available online).  

{p 4 4}At minimum, {cmd:drm} requires Stata version 12.{p_end}

{marker description}{...}
{title:Description}

{p 4 4}{cmd:drm} standardly uses maximum likelihood to estimate parameters and returns in e() all that {help ml} returns. However, by specifying the {cmd:nl} option, estimation may also be done with non-linear least squares. 
In this case, {cmd:drm} returns in e() whatever  {help nl} returns. See {help drm##nlvsml:below} on why outputs will look different between {cmd:nl} and {cmd:ml} estimation. 

{p 4 4} The basic model can be written as:

{marker description_eq1}{...}
{p 6} y[i,j,k] = p*mu[i,i] + q*mu[j,j] + e[i,j,k] (1)

{p 4} Where:

{p 6} p+q=1	and 0<=p<=1	

{p 4 4} Here, y[i,j,k] is the value of {help depvar} of the [k]th observation 
in the [i,j]th cell. mu[i,i] and mu[j,j] are estimated population means of y 
in the [i,j]th cell. Cell positions [i,j] are indices in e.g. a mobility table 
with an origin variable ({it:rowvar}) with values {1,...,i,...R} and a destination variable 
({it:colvar}) with values {1,...,j,...C}. It is necessary that R=C. p and q are weight
parameters to be estimated. 

{p 4 4} The model of equation (1) is quite restrictive. Therefore, {cmd:drm} allows for five 
extensions. First, the assumption of constant weights may be relaxed. Weights may be made
specific to a respondent's value on {it:rowvar} or {it:colvar}, i.e. specific to values of 
i or j. Thus, it is possible to estimate one of:

{marker description_eq2}{...}
{p 6} y[i,j,k] = p[i]*mu[i,i] + q[i]*mu[j,j] + e[i,j,k] (2)

{p 4} or

{p 6} y[i,j,k] = p[j]*mu[i,i] + q[j]*mu[j,j] + e[i,j,k] (3)

{p 4 4} Second, any number of covariates may be entered linearly. Extending (2), this yields:

{p 6} y[i,j,k] = p[i]*mu[i,i] + q[i]*mu[j,j] + XB + e[i,j,k] (4)

{p 4 4} Where X is a vector of covariates and B a vector of parameters.

{p 4 4} Third, mu[i,i] and mu[j,j] may be replaced with mu[i,i,c] and mu[j,j,c]. In other words,
estimated population means on the diagonal may be specific to some (set of) variable(s) {it:byvar} 
that is indexed by c. This may be useful when one has data with multiple levels 
(e.g. persons nested in countries) and would like to have mobility tables be specific 
to each country c. 

{p 4 4} Building on (4), this extension yields:

{marker description_eq5}{...}
{p 6} y[i,j,c,k] = p[i]*mu[i,i,c] + q[i]*mu[j,j,c] + XB + e[i,j,c,k] (5)

{p 4 4} Currently, this option is only supported with least-squares estimation. 

{p 4 4} Fourth, weights p[i] and q[i] may be interacted with a linear combination of variables XB_inter.
As an extension of (2), this yields:

{marker description_eq6}{...}
{p 6} y[i,j,k] = (p[i]+(XB_inter))*mu[i,i] + (q[i]-(XB_inter))*mu[j,j] + e[i,j,k] (6)

{p 4 4} This extension follows e.g. De Graaf, Nieuwbeerta, Heath (1995).

{p 4 4} Fifth, in cases where {it:{help depvar}} is binary, it may be useful to estimate a logit or probit variant of the diagonal reference model. 
Thus, users may estimate:

{p 6} pr(y[i,j,k]=1)=logistic(drm) 

{p 4 4} or 

{p 6} pr(y[i,j,k]=1)=normal(drm) 

{p 4 4}for the logit or probit link, respectively. Here, logistic(x)=1/(1+e^-x) and normal(x) is the cdf of the normal distribution. 
Moreover, drm=p[i]*mu[i,i] + q[i]*mu[j,j] + XB + e[i,j,k], or one of the other variants described above. 


{title:Options}
{marker opt_general}{...}
{dlgtab:General}

{p 4 4} {cmd:vce(}{it:{help vcetype}}{cmd:)} set standard error type. See {help vce_option}, {help nl}, and {help ml} for options.

{p 4 4} {cmd:wgt(}{it:str}{cmd:)} one of {cmd:cons}, {cmd:row} or {cmd:col}. 
Specifies if weights are assumed to be constant (default) or dependent on {it:rowvar} ({cmd:row}) or {it:colvar} ({cmd:col}).
See equations {help drm##description_eq2:(2)} and {help drm##description_eq2:(3)} in the {help drm##description:description}.

{p 4 4} {opt inter:vars}{cmd:(}{it:{help varlist}}{cmd:)} interact weights p and q with {it:{help varlist}}. 
See equation {help drm##description_eq6:(6)} in the {help drm##description:description}.  

{p 4 4} {opt iter:ate(#)} specifies the maximum number of iterations; default is {cmd:iterate(1000)}

{p 4 4} {opt l:evel(#)} set confidence level; default is {cmd:level(95)}

{p 4 4} {opt coefl:egend} specifies that the legend of the coefficients and how to specify them in an expression be displayed rather than displaying the statistics for the coefficients.

{p 4 4} {opt ke:ep} prevents {cmd:drm} from deleting dummies for each level of {it:rowvar} and {it:colvar} that were generated for estimation.

{p 4 4} {opt old} forces {cmd:drm} to behave as it did until version 0.4, i.e. to generate illegible temporary variable names for {it:rowvar} and {it:colvar}.  {p_end}

{marker opt_ml}{...}
{dlgtab:Maximum likelihood}
{p 4 4} N.b. When {cmd:nl} is specified, all maximum likelihood options are ignored. See {help drm##description:description}.

{marker opt_ml_link}{...}
{p 4 4} {cmd:link(}{it:str}{cmd:)} one of {cmd:linear}, {cmd:logit} or {cmd:probit}. Specifies link function; default is {cmd:link(}{it:linear}{cmd:)}. 
Using {cmd:link(}{it:linear}{cmd:)} or specifying {cmd:nl} gives equivalent results, though the resulting output will look somewhat different. See {help drm##nlvsml:difference between nl and ml}.

{p 4 4} {opt s:obel} implements variants of the method documented in appendix A of Sobel (1985) to find initial values; the default. 

{p 4 4} {opt cl:assic} uses (1/R)*(depvar[i,i]}/(depvar[1,1]+...+depvar[R,R])) as initial values for mu[i,i] and 0.5 as initial values for p. 

{p 4 4} {opt a:lternative} uses exp((1/R)*(depvar[i,i]}/(depvar[1,1]+...+depvar[R,R]))) as initial values for mu[i,i] and 0.5 as initial values for p. 

{p 4 4} {cmd:tech()} specifies maximization algorithm. Default is {cmd:nr}. Alternatives are {cmd:bhhh}, {cmd:dfp} and {cmd:bfgs}.
This option may help when convergence can't be achieved with the default settings. See {help maximize} for further help.  

{p 4 4} {opt diff:icult} specifies {cmd:difficult} option for {help ml}. 
This option may help when convergence can't be achieved with the default settings. See {help maximize} for further help.  

{p 4 4} {opt ownc:onstrains}{cmd:(}{it:str}{cmd:)} specifies further user-written constrains. Syntax is {cmd:[}{it:{help exp}} {cmd:=} {it:{help exp}}{cmd:]} [{cmd:[}{it:{help exp}} {cmd:=} {it:{help exp}}{cmd:]} ...],
where {help exp} typically contains: {cmd:[}eq_name{cmd:]}{it:varname}. 
A typical use of {opt ownc:onstrains}{cmd:(}{it:str}{cmd:)} is to constrain weights to lie on the unit interval. Say we fitted a model and found p, i.e. the weight on {it: rowvar}, to be greater than 1:

{p 6} {cmd:.	drm depvar rowvar colvar control1 control2, link(linear)}

{p 4 4} To force p=1,  we specify a constraint as such:

{p 6} {cmd:.	drm depvar rowvar colvar control1 control2, link(linear) ownc([p]_cons=1)}

{p 4 4} If we wanted additional constraints, e.g. {cmd:control1}={cmd:control2} we could write: 

{p 6} {cmd:.	drm depvar rowvar colvar control1 control2, link(linear) ownc([p]_cons=1 [xb]control1=[xb]control2})



{marker opt_nl}{...}
{dlgtab:Least squares}
{p 4 4} N.b. When {cmd:nl} is not specified, these options are ignored.
See {help drm##introduction:introduction}.

{p 4 4} {cmd:by(}{it:{help varlist}}{cmd:)} specify variables on which estimates of mu[i,i] and mu[j,j] are made conditional. 
If more than one variable is specified, every combination of {help varlist} is taken.
See equation {help drm##description_eq5:(5)} in the {help drm##description:description}.  

{p 4 4} {opt c:onstrain} explicitly constrains p to lie on [0,1]. This is achieved by replacing parameter p in e.g.
equation {help drm##description_eq2:(2)} with exp(gamma/(1+gamma)), where gamma is a parameter to be estimated and exp(.) is the exponential function.
If specified, parameter estimates for p and q are obtained using {help nlcom}. 

{marker nlvsml}{...}
{title:Difference between nl and ml estimation}

{p 4 4} The model of equation {help drm##description_eq1:(1)} may be equivalently rewritten as:

{marker description_eq1a}{...}
{p 6} y[i,j,k] = alpha + p*mu[i,i] + q*mu[j,j] + e[i,j,k] (1a)

{p 4 4} Here, alpha is a constant and the constraint mu[1,1]+...+mu[R,R]=0 is set. When {cmd:nl} is not specified and {cmd:drm} thus uses maximum likelihood, 
(variants of) equation {help drm##description_eq1a:(1a)} are estimated. When {cmd:nl} is specified and hence non-linear least squares are used,
{cmd:drm} estimates (variants of) equation {help drm##description_eq1:(1)}. 

{marker intervars}{...}
{title :Finding overall weights when intervars option is used}

{p 4 4} Note that when {opt inter:vars}{cmd:(}{it:intervars}{cmd:)} is used, parameters p and q only give the overall weights on mu[i,i] and mu[j,j] when all variables in {it: intervars} are zero.
To find e.g. the overall weight on mu[i,i] for other values of variables x1,...,xn in {it:intervars}, type:

{p 6} {cmd:.	lincom (_b[p:_cons]+(_b[rho:x1]*x1+...+_b[rho:xn]*xn))}

{p 4 4} When p and q are made specific to levels of i (or j), to find e.g. p[2], just write:

{p 6} {cmd:.	lincom (_b[p2:_cons]+(_b[rho:x1]*x1+...+_b[rho:xn]*xn))}

{p 4 4} Concretely, suppose we estimated a model like this: 

{p 6} {cmd:.	drm depvar rowvar colvar, wgt(col) intervars(intervar1 intervar2 intervar3)}

{p 4 4} To find the overall weight on rowvar when e.g. rowvar=3, intervar1=3, intervar2=5, intervar3=12, we must write:

{p 6} {cmd:.	lincom (_b[p3:_cons]+(_b[rho:intervar1]*3+_b[rho:intervar2]*5+_b[rho:intervar3]*12))}

{p 4 4} You may find it useful to use the {cmd: coeflegend} option to display the names of parameters as they need to be referred to in postestimation commands like {help lincom}.

{title:References}

{p 4 4} De Graaf, N.D.; Nieuwbeerta, P.; Heath, A. (1995). Class Mobility and Political Preferences: Individual and Contextual Effects. The American Journal of Sociology, 100(4), 997-1027.

{p 4 4} Lizardo, O. (2007). Gaussian, Logit, Probit and Poisson Diagonal Reference models.

{p 4 4} Sobel, M. (1981). Diagonal Mobility Models: A Substantively Motivated Class of Designs for the Analysis of Mobility Effects. American Sociological Review, 46(6), 893-906.

{p 4 4} Sobel, M. (1985). Social Mobility and Fertility Revisited: Some New Models for the Analysis of the Mobility Effects Hypothesis. American Sociological Review, 50(5), 699-712.

{title:Author/Citation}

{p 4 4}  Caspar Kaiser {p_end}
{p 4 4}  Department of Social Policy and Intervention {p_end}
{p 4 4}  Nuffield College, University of Oxford {p_end}
{p 4 4}  caspar.kaiser@nuffield.ox.ac.uk {p_end}

{p 4 4} If you use {cmd:drm} for your research, please cite:  {p_end}
{p 4 4} Kaiser, C. (2018). DRM Diagonal Reference Model Stata. Open Science Framework. doi:10.17605/OSF.IO/KFDP6. {p_end}
{p 4 4} or the suggested RePEc entry.  

{title:Feedback}

{p 4 4} {cmd:drm} will be updated. Any feedback or questions are more than welcome. 
If you have ideas for additional features (or would be interested in adding any), please feel free to contact me. 

{title:Planned features:}

{p 4 4} -allow {cmd:wgt()} when using ml {p_end}
{p 4 4} -3-dimensional or N-dimensional mobility tables {p_end}
{p 4 4} -full compatibility with {help predict} and {help margins} {p_end}
{p 4 4} -multinomial logit {p_end}
{p 4 4} -ordered logit/probit {p_end}
{p 4 4} -random effects {p_end}

{title:New in version 0.4:}

{p 4 4} -parameter q is now explicitly estimated when using ml. This fixes repeated convergence problems. {p_end}
{p 4 4} -ml estimation is now the default {p_end}
{p 4 4} -user-written constrains are now allowed {p_end}
{p 4 4} -Sobel's (1985) method to find initial values is now implemented and set to be the default. This speeds up estimation considerably and helps with convergence. {p_end} 

{title:New in version 0.5:}

{p 4 4} -parameter estimates for each level of {it:rowavar} and {it:colvar} are now displayed in legible form and associated dummies are (optionally) saved.{p_end}
{p 4 4} -some users found the display of the ancillary paramter sigma when using the linear link fucntion confusing. This parameter estimate is no longer displayed. {p_end}
