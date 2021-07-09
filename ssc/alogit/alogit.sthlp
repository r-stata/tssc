{smcl}
{* *! version 1.2.1 04June2017}{...}
{viewerdialog alogit "dialog alogit"}{...}
{vieweralsosee "[R] alogit" "mansection R alogit"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] alogit" "help alogit"}{...}
{viewerjumpto "Syntax" "alogit##syntax"}{...}
{viewerjumpto "Menu" "alogit##menu"}{...}
{viewerjumpto "Description" "alogit##description"}{...}
{viewerjumpto "Options" "alogit##options"}{...}
{viewerjumpto "Examples" "alogit##examples"}{...}
{viewerjumpto "Stored results" "alogit##results"}{...}
{viewerjumpto "References" "alogit##references"}{...}
{viewerjumpto "Post" "alogit##references"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{manlink R alogit} {hline 2}}Attentive logit regression{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmdab:alogit}
{depvar}
[{indepvars}]
{ifin}
{cmd:,}
{c -(}{opth def:ault(varname)}
{c |}
{opth cons:ider(varname)}{c )-}
{bind:{cmdab:gr:oup:(}{varname}{cmd:)} [{it:options}]}

{pstd}
The default-specific consideration (DSC) model (see the {help alogit##description:description} below)
can be specified via {opt model(dsc)}

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{p2coldent :* {opth gr:oup(varname)}}individual identifier{p_end}
{p2coldent :+ {opth def:ault(varname)}}binary variable indicating a default good per individual (i.e. per group){p_end}
{p2coldent :+ {opth cons:ider(varname)}}binary variable indicating goods with attention probability 1{p_end}
{synopt :{opth avars(varlist)}}use {it:varlist} instead of {it:indepvars} in attention probability estimation{p_end}
{synopt :{opth zvars(varlist)}}include {it:varlist} in attention probability estimation{p_end}
{synopt :{opth exclude(varlist)}}exclude {it:varlist} from attention probability estimation{p_end}
{synopt :{opt noc:onstant}}don't automatically add a constant when estimating P(A){p_end}
{p2coldent :^ {opth alg:orithm(str)}}{opt matrix}, {opt loop} ({it:alogit} only), {opt fast} (Unix only), and {opt faster} (Unix only).{p_end}
{synopt :{opth model(str)}}{it:model} may be {opt alogit} or {opt dsc}{p_end}

{syntab:Computation}
{synopt :{opth b0(numlist)}}Starting parameters for {it:indepvars} when computing P(Y){p_end}
{synopt :{opth g0(numlist)}}Starting parameters for {it:indepvars} or {it:avars} when computing P(A){p_end}
{synopt :{opth d0(numlist)}}Starting parameters for {it:zvars} and the constant when computing P(A){p_end}
{synopt :{opt  exp}}Estimate exp(b) instead of b.{p_end}
{synopt :{opth method(str)}}{it:method} may be {opt exact} or {opt importance}{p_end}
{synopt :{opth reps(int)}}number of choice sets to randomly sample with {cmd:method(importance)}{p_end}
{synopt :{opth noprob(str)}}{it:noprob} may be {opt error} or {opt drop}: How to handle P(A) = 0{p_end}
{synopt :{opth eval(str)}}d0, d1, d2, d1debug, d2debug; see {help mf_moptimize##syn_alleval}{p_end}

{syntab:Reporting}
{synopt :{opt check:setup}}Hard stops when there is a problem with the dependent variable{p_end}
{synopt :{opt debug}}Print starting parameters{p_end}
{synopt :{opt loglik}}Compute log-likelihood and exit{p_end}

{syntab:Maximization}
{synopt :{it:{help alogit##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {opt group(varname)} is required.{p_end}
{p 4 6 2}
+ One of {opt default(varname)} or {opt consider(varname)} is required.{p_end}
{p 4 6 2}
^ {opt algorithm(str)} {opt faster} depends on OpenMP (see {help alogit##openmp:Checking OpenMP} for more).{p_end}
{p 4 6 2}
See {manhelp alogit_postestimation R:alogit postestimation} for features available after estimation.  {p_end}

{phang}

{marker description}{...}
{title:Description}

{pstd}
{opt alogit} computes an (in)attentive logit model for the choice
model in {help alogit##AA2017:Abaluck and Adams (2017)}. An
inattentive consumer chooses a good as a function of that good's
characteristics and the probability of paying attention to that
good. {it:depvar} indicates the consumer's choice, {it:indepvars}
are covariates that affect choice and attention, and {it:zvars} are
variables that only affect attention.

{pstd}
Note that in the attentive logit model, consideration sets are
probabilistic. Each alternative has some probability of not being
considered, which is estimated by the model. Hence there is a non-zero
probability of a completely empty consideration set. For the model to
be well-specified, the user should say which alternative is chosen when
the consideration set is empty. The default option is specified via
{opt default()}. If it is missing then the user must specify which goods
have a probability 1 of being considered (and thus there would never be
an empty set) via {opt consider()}.

{pstd}
{opt alogit} stores the probability of an empty set in {opt e(mp0)}
and prints a warning to the console if it is non-negligible (when
{opt consider()} is passed, it is ignored for the purposes of computing
this probability).

{pstd}
Alternatively {opt alogit} can also estimate a version of the model
where the probability of attention depends solely on the default good
(henceforth DSC or dsc for default-specific consideration model). In this version the
consumer either pays attention to all goods and makes a choice or
remains inattentive and defaults to the default good.

{marker options}{...}
{title:Options}

{dlgtab:Model}

{phang}
{opth group(varname)} is required; it specifies an identifier variable
(numeric or string) for the matched groups.

{phang}
{opth default(varname)} indicates which good to use as the default good.
There must be 1 (and only 1) default good per individual (if this is not
the case, the function will exit with error). For {opt alogit} this is
the good chosen when the consideration set is empty. For {opt dsc} this
good is chosen when the consumer is inattentive.

{phang}
{opth consider(varname)} indicates which goods have probability 1 of
being considered. The model sets the probability of attention to 1 for
these goods and only computes consideration sets that include the goods
indexed by this variable. This can only be specified with {opt alogit}.

{phang}
{opth avars(varlist)} are variables that affect the probability of
attention but to not affect the choice probability. By default this is
{it:indepvars}. Can be set with {opth zvars(varlist)}.

{phang}
{opth zvars(varlist)} are additional variables that affect the
probability of attention but to not affect the choice probability.
By default this is blank. Can be set with {opth avars(varlist)}.

{phang}
{opth exclude(varlist)} are variables that are not to be used in the
attention probability estimation. This is meant to be used to exclude
variables specified for the utility equation from the attention
equation, but it will supersede {opth avars(varlist)} and {opth zvars(varlist)}.
However, variables specified explicitly in {opth avars(varlist)} or
{opth zvars(varlist)} will be counted by the function hen determining
whether a row has wmissing values. The console will print a warning of
the variables to be excluded are not found in the estimating equations
in the first place. Last, if the user specifies starting parameters,
they must also take care to specify the correct number of parameters
after the exclusion has taken place.

{phang}
{opt noc:onstant} suppresses automatically adding a constant when
estimating the probability of attention P(A)

{phang}
{opth alg:orithm(str)} specifies the algorithm to use; we recommend
against changing the default for {opt model(dsc)}, but {opt model(alogit)}
may see considerable speed and stability improvements by using an
alternative algorithm.
{opt matrix}, the default, performs computations at the matrix level
where each row is a consideration set. For a large number of goods,
creating a matrix will all possible consideration sets, 2^J, is
intractable. {opt loop} has no limit on the number of goods, but Stata
is very inefficient at loops so the added stability comes at the cost
of speed. To hedge against the speed loss, on Unix systems the user can
specify {opt fast} or {opt faster} to use a single or multi-threaded
C-based Stata plugin that computes the likelihood, gradient, and
Hessian. The speed comes at the loss of portability as the plugins will
only work in Unix. Further, while {opt fast} should work on any Unix
system, {opt faster}, the multi-threaded version, additionally depends
on OpenMP (see {help alogit##openmp:Checking OpenMP}).

{phang}
{opth model(str)} {it:model} may be {opt alogit} to compute the.
(in)attentive logit model or {opt dsc} to compute the DSC variation.

{dlgtab:Computation}

{phang}
{opth b0(numlist)} specifies starting parameters for {it:indepvars} when
computing P(Y)

{phang}
{opth g0(numlist)} specifies starting parameters for {it:indepvars} or
{opth avars(varlist)} when computing P(A)

{phang}
{opth d0(numlist)} specifies starting parameters for {opth
zvars(varlist)} when computing P(A); if you want to specify a starting
parameter for the constant it must be done trough {it:d0} even if {opth
zvars(varlist)} is not specified.

{phang}
{opt exp} Specifies {opt alogit} should estimate exp(b) instead of b. If
the user passes starting parameters, they must b and {opt not} exp(b).
However, for the post-estimation any parameters passed via {opt fit()}
must be exp(b).

{phang}
{opth method(str)} {it:method} may be {opt exact} to compute the
likelihood by iterating over all possible {it:2^J} choice sets, or
{opt importance} in order to sample {opt reps} choice sets and compute
the likelihood using an importance sampler to weight the estimated
P(Y). For this latter method we sample once and then vary the choice
sets alongside the parameters (i.e. we sample a set of random uniform
variables once, and through the optimization the choice sets will be
given by phi = exp(xg + zd) / (1 + exp(xg + zd)) > u0, where g and d
change but u0 is fixed)

{phang}
{opth reps(int)} are the number of choice sets to draw when using
{opt method(importance)}; defaults to 100.

{phang}
{opth noprob(str)} specifies how to handle attention probabilities P(A) = 0
with {opt method(importance)}: {opt error} gives an error message and exits;
{opt drop} drops them from the likelihood. Defaults is {opt error}.

{phang}
{opth eval(str)} d0, d1, d2, d1debug, d2debug; see {help mf_moptimize##syn_alleval}{p_end}

{dlgtab:Reporting}

{phang}
{opt loglik} Compute log-likelihood, print to log, and exit. The results
are available in -e(loglik)-.

{phang}
{opt debug} prints the log likelihood at each function call (it also
prints the starting parameters).

{phang}
{opt checksetup} Hard stops when there is a problem detected with the
dependent variable; namely it should be 0/1 and specify a single choice
per individual

{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opth tech:nique(maximize##algorithm_spec:algorithm_spec)},
{opt iter:ate(#)}, [{cmd:{ul:no}}]{opt lo:g}, {opt tr:ace},
{opt grad:ient}, {opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nores:cale(#)},
{opt nrtol:erance(#)}, and
{opt nonrtol:erance}; see {manhelp maximize R}. These options are seldom used.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. set seed 42}{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2)}{p_end}

{pstd}Fit (in)attentive logit regression{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) def(defgood) noc}{p_end}
{phang2}{cmd:. alogit y x*, avars(x1 z1) group(ind) def(defgood) noc}{p_end}

{pstd}Get the log-likelihood at the starting parameters{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) def(defgood) loglik}{p_end}

{pstd}The starting parameters can be manually set{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) loglik def(defgood) b0(12 -2) g0(-3 4) d0(21 3 0)}{p_end}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. set seed 42}{p_end}
{phang2}{cmd:. alogit_sim, n(200) j(4 8) b0(3.8 1.5) g0(0.6 -0.1) d0(-2.3 -1.1) zs(2) dsc}{p_end}

{pstd}Fit (in)attentive logit regression, DSC version{p_end}
{phang2}{cmd:. alogit y x*, group(ind) def(defgood) model(dsc)}{p_end}
{phang2}{cmd:. alogit y x*, zvars(z*) group(ind) def(defgood) noc model(dsc)}{p_end}
{phang2}{cmd:. alogit y x*, avars(x1 z1) group(ind) def(defgood) noc model(dsc)}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:alogit} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)        }} number of observations {p_end}
{synopt:{cmd:e(ic)       }} number of iterations {p_end}
{synopt:{cmd:e(k)        }} number of parameters {p_end}
{synopt:{cmd:e(k_eq)     }} number of equations {p_end}
{synopt:{cmd:e(k_dv)     }} number of dependent variables {p_end}
{synopt:{cmd:e(mp0)      }} Average P(empty choice set) (for DSC, P(Inattention)) {p_end}
{synopt:{cmd:e(mp1)      }} Average P(Attention) (DSC only) {p_end}
{synopt:{cmd:e(rank)     }} rank of e(V) {p_end}
{synopt:{cmd:e(converged)}} {cmd:1} if converged, {cmd:0} otherwise {p_end}
{synopt:{cmd:e(rc)       }} return code {p_end}
{synopt:{cmd:e(loglik0)  }} log-likelihood at starting parameters {p_end}
{synopt:{cmd:e(loglik)   }} log-likelihood at converged parameters {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(model)     }}{opt alogit} or {opt dsc}.{p_end}
{synopt:{cmd:e(method)    }}optimization method: {opt importance} or {opt exact}{p_end}
{synopt:{cmd:e(algorithm) }}algorithm used: {opt matrix}, {opt loop}, {opt fast}, {opt faster}.{p_end}
{synopt:{cmd:e(group)     }}name of {opt group()} variable{p_end}
{synopt:{cmd:e(default)   }}name of {opt default()} variable, if specified{p_end}
{synopt:{cmd:e(consider)  }}name of {opt consider()} variable, if specified{p_end}
{synopt:{cmd:e(indepvars) }}utility variables{p_end}
{synopt:{cmd:e(avars)     }}attention variables{p_end}
{synopt:{cmd:e(afit)      }}{opt loglik} if it was requested; {opt full} otherwise.{p_end}
{synopt:{cmd:e(predict)   }}program used to implement {opt predict}{p_end}
{synopt:{cmd:e(cmd)       }}{cmd:alogit}{p_end}
{synopt:{cmd:e(opt)       }}type of optimization{p_end}
{synopt:{cmd:e(predict)   }}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(user)      }}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method) }}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(technique) }}maximization technique{p_end}
{synopt:{cmd:e(which)     }}{cmd:max} or {cmd:min}; whether optimizer is to perform
                            maximization or minimization{p_end}
{synopt:{cmd:e(depvar)    }}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)       }}coefficient vector{p_end}
{synopt:{cmd:e(V)       }}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(b0)      }}starting parameters{p_end}
{synopt:{cmd:e(Hessian) }}Hessian matrix{p_end}
{synopt:{cmd:e(ilog)    }}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{marker openmp}{...}
{title:Checking OpenMP}

{pstd}
{opt algorithm(faster)} depends on OpenMP for multithreading (since
operations run in parallel, the speed gains can be very significant).
While this is a very common library on Unix, you can check the plugin
will find it by running, from a shell,

{phang2}{cmd:$ ldconfig -p | grep libgomp}{p_end}
{phang2}{cmd:$ echo $LD_LIBRARY_PATH}{p_end}

{pstd}
The first command will print the path to {it:libgomp.so} (or
{it:libgomp.so.1}), which is the relevant file. The second will print
the paths where your system looks for such libraries. If the path to
{it:libgomp.so} is not in {it:LD_LIBRARY_PATH}, run (in bash or zsh)

{phang2}{cmd:$ export LD_LIBRARY_PATH=/path/to/libgomp:$LD_LIBRARY_PATH}{p_end}

{pstd}
where {it:/path/to/libgomp} is the folder containing {it:libgomp.so}. In case
your shell is csh or tcsh, run

{phang2}{cmd:$ setenv LD_LIBRARY_PATH /path/to/libgomp:$LD_LIBRARY_PATH}{p_end}

{pstd}
To make this change permanent, add to your {it:~/.bashrc} or {it:~/.zshrc}

        {cmd:if [[ ! "$LD_LIBRARY_PATH" == */path/to/libgomp* ]]; then   }
            {cmd:export LD_LIBRARY_PATH=/path/to/libgomp:$LD_LIBRARY_PATH}
        {cmd:fi                                                          }

{pstd}
or your {it:~/.cshrc} or {it:~/.tcshrc}

        {cmd:if !($?LD_LIBRARY_PATH) then                                     }
            {cmd:setenv LD_LIBRARY_PATH /path/to/libgomp                      }
        {cmd:else                                                             }
            {cmd:if !($LD_LIBRARY_PATH:q =~ */path/to/libgomp*) then          }
                {cmd:setenv LD_LIBRARY_PATH /path/to/libgomp:$LD_LIBRARY_PATH }
            {cmd:endif                                                        }
        {cmd:endif                                                            }

{pstd}
One last note: If you are working on a remote server, there is a
chance the snippet will not work if your system administrator sets
{it:LD_LIBRARY_PATH} after your {it:~/.*rc} files are processed. In this
case, append the above snippet to {it:~/.profile} if using {it:bash} or
{it:zsh} and {it:~/.login} if using {it:csh} or {it:tcsh}.

{marker references}{...}
{title:References}

{marker AA2017}{...}
{phang}
Abaluck, J. and Adams, A. 2017. What do consumers consider before they choose? Identification from asymmetric demand responses. {it:Working paper}.
{p_end}
