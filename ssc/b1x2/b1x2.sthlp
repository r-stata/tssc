.-
help for ^-b1x2-^                                               
.-

Accounting for changes when X2 is added to a base model with X1
----------------------------------------------------------------------------

    ^b1x2^ depvar [^if^ exp] [^in^ range] [^aweight^ ^fweight^ exp], ^x1all^([vars included in
					both specifications]) ^x2all^([vars
					included only in full specification]) 
					[^x1endog^([list of endogenous vars in x1all])
					^iv^([instruments for x1])
					^r^obust ^c^luster([cluster
					varname]) ^noBase^ 
					^noFull^ ^x1only^([list of x1 vars for 
					which user wants decomposition computed])
					^x2delta^([definition of groups for x2 vars])
					^gamma0^ ^cov0^]


^-b1x2-^ is an eclass estimator and preserves sort order

To reset problem-size limits, see help @matsize@.

Note: This help file is long but cannot explain everything. An example
appears below, illustrating how the command works. Play around with it
yourself to get used to it. It is always possible that logfile
snippets will appear at
http://gelbach.eller.arizona.edu/papers/b1x2/index.html, so feel free
to check there.

Description
-----------

^-b1x2-^ provides decompositions of cross-specification
	 differences in estimates of the coefficient on X1. 
         Because the decomposition is conditional, ^-b1x2-^ 
         is a superior alternative to the common practice of
	 sequentially adding covariates to a base model. The 
         command also computes consistent estimates of the 
         standard error of the difference in base- and 
         full-specification coefficient estimates.

The command was written by Jonah B. Gelbach and is based on his paper,
"When Do Covariates Matter? And Which Ones, And How Much?", University
of Arizona Department of Economics Working Paper #09-07. This paper is
currently available at
http://papers.ssrn.com/sol3/papers.cfm?abstract_id=1425737

In its simplest form, ^-b1x2-^ does the following:

  A. Runs the "base" regression

	. regress depvar x1all

  B. Runs the "full" regression

	. regress depvar x1all x2all

  C. Computes both the difference in the coefficent estimates for x1all
     (including the constant) and a consistent estimate of the
     asymptotic covariance matrix for this difference. 

The covariance matrix used in step C is discussed in Appendix B of the
paper cited above.


Options
-------

MANDATORY:

^x1all^ List of vars included in both base and full regs 
^x2all^ List of vars included in only the full reg


OPTIONAL:

^robust^ Specifies hsk-robust covariance matrix

^cluster^(^varname^) Specifies covariance matrix that accts for
    arbitrary dependence w/in values of specified variable

^x1endog^(^varlist^) Specifies a list of endogenous variables in
    x1all. This list can be identical to x1all, or a subset. All 
    endogenous variables must also be listed in x1all.

^iv^ Specifies instruments used for variables listed in ^x1endog^ 
    in both base and full regressions

^nofull^ Specifies that full regression results should be supressed
    from output (they are always computed). 

^nobase^ Specifies that base regression results should be supressed
    from output (they are always computed).

^x1only^ Specifies a subset of x1all variables for which the 
    decomposition should be done. Use of this option is strongly 
    encouraged when there are more than a few variables in x1all, 
    and only a limited number of variables (maybe even just one?) 
    in x1 are of interest. Using x1only makes computation quicker 
    and also reduces system demands by reducing the dimension of 
    various internally defined matrices.

^x2delta^ Specifies how variables in x2all should be split into groups
    for purposes of decomposing the difference in x1 coefficient 
    estimates across the base and full specifications. See below.


Examples
--------


Methods and Formulas
--------------------

1. The model
------------

Let the model be

	y = b0 + X1 b1 + X2 b2 + e,

where b1 and b2 are, respectively, k1- and k2-dimensional column
vectors, with at least one element of b2 being nonzero. Assume that
E[e|X1] = E[e|X1,X2] = 0. The rest of the econometric discussion will
assume that the matrix [y X1 X2] has been demeaned, so that b0 can be
taken as identically 0, though this is for exposition only.


2. Estimating the impact on b1hat of including X2
-------------------------------------------------

Define the ``full estimator'' b1full by

	b1full = (X1' M2 X1)^-1 (X1' M2 y),

where M2 = I - P2 = I - X2 (X2'X2)^-1 X2 is the residual-maker matrix
for X2. This estimator has plim b1, so it is consistent. Next, write

	X2 = X1 Gamma + W,

where Gamma is the (k1 x k2) linear projection of X2 on X1. It follows
definitionally that E[X1'W] = 0. Consider the base estimator of b1:

	b1base = (X1'X1)^-1 X1'y

This estimator has plim b1 + d1, where d1 = Gamma b2, so b1base is consistent
for b1 if and only if either (i) Gamma=0 or (ii) Gamma and b2 are orthogonal
(we ruled out b2=0 by assumption, since this can most
straightforwardly be tested by running an F/Chi2 test on the
restriction b2=0).

Define the difference between the estimates of b1 as

	dhat = b1base - b1full,

and note that its plim is d1. 


3. Decomposing dhat into component parts
--------------------------------------------

It is easy to show (see Gelbach paper cited above) that 

	dhat = (X1'X1)^-1 X1'X2 b2hat,

where b2hat comes from the full model. Further,

	X2 b2hat = sum_k X2k b2hatk,

where k indexes variables in X2. Now define 

	Hhat = X2 b2hat, 

so that 

	dhat = (X1'X1)^-1 X1'Hhat.

Now consider G mutually exclusive groups of covariates in X2, 
indexed by g. We can write

	Hhat = sum_g Hhatg,

where 

	Hhatg = sum_{k in group g} X2k b2hatk.

Also define 

	dhatg = (X1'X1)^-1 X1'Hhatg,

and note that since the G Hhatg terms sum exactly to the 
overall Hhat, we must have

	dhat = sum_g dhatg.

Since dhat exactly equals the difference in base- and
full-specification estimates of the coefficient on X1, 
it follows that the dhatg components together account 
exactly for the difference between the base- and 
full-specification estimates. Gelbach's paper shows 
that these components are also meaningful.

To define the groups, you use the option x2delta, as 
follows:

x2only( groupname1 = group1varlist : 
	... : groupnameG = groupGvarlist)

In other words, the syntax of x2only is to include a series of G
strings. The gth string has the form

	groupname = varlist,

and the strings must be separated by ":", the colon character. Make
sure that you do not include the same variable in multiple strings
(b1x2 should throw an error in such cases, but it's better to get it
right in the first place).


D. Variance options
-------------------

There are two variance options, gamma0 and cov0. 

The option gamma0 amounts to telling b1x2 to impose the null
hypothesis that x1all and x2all variables are orthogonal when
estimating the decomposition's variance matrix. This option may lead
to more powerful tests of the null, though resulting standard errors
are inconsistent when the null is false.

The option cov0 tells b1x2 to ignore covariance between estimated
components of b2 and estimated components of Gamma. This option is
appropriate under certain conditions discussed in Appendix B of
Gelbach's paper. 


E. Other notes
--------------

b1x2 has internal checks to ensure that no variable dropped from the
full specification will appear in the base specification. This
requirement could lead to problems if the full model involves
variables that cause a variable in x1all to be dropped due to perfect
collinearity. For this reason, it's important to make sure that all
variables you expect to be included in the base specification actually
are.

b1x2 also imposes the requirement that the same sample be used in each
specification. This is a feature, not a bug.


Saved Results
-------------

^-b1x2-^ is an eclass command. It saves results in the following places:


Scalars:

	e(N)   	     =	number of observations
	e(k1) 	     =	number of variables in x1all, including the constant
	e(k2)	     =	number of variables in x2all
	e(numiv)     =  number of instrumental variables
	e(numx1endog)=  number of endogenous variables
        e(N_clust)   =  number of clusters


Local macros:

	e(groupnames)	string of groupnames (see discussion of x2delta)
	e(cmd)	  	"b1x2" 
	e(depvar)  	dependent variable name
	e(weight)  	type of weights and varname
	e(if)	  	if condition
	e(in)	  	in condition
	e(robust)	flag for robust estimation
	e(cluster)	cluster varname, if any

Matrices:

	e(Delta)  	vector of decomposition elements (reported in table of results)
	e(Covdelta)	estimated covariance matrix for Delta
	e(b1base)	vector of base-specification coefficient estimates
	e(V1base)	estimated covariance matrix for b1base
	e(b1full)	vector of full-specification coefficient estimates for X1
	e(V1full)	estimated covariance matrix for b1full
	e(b2full)	vector of full-specification coefficient estimates for X2
	e(V2full)	estimated covariance matrix for b2full
	e(bfull)	vector of full-specification coefficient estimates for X1 and X2
	e(Vfull)	estimated covariance matrix for bfull


Functions:
        e(sample) :  Variable =1 if included and =0 if not included


Examples
--------

Here's one you can mess around with on your own:

. set obs 1000
obs was 0, now 1000

. gen double x1 = invnorm(uniform())

. gen double x21 = x1*1 + invnorm(uniform())

. gen double x22 = x1*0.25 + x21*0.75 + invnorm(uniform())

. gen double x23 = x1*0.4 + x21*0.6 + x22*0.4 + invnorm(uniform())

. gen double y = x1*1 + x21*2 + x22*0.5 + x23*0.75 + invnorm(uniform())


*here's the base model
. reg y x1

      Source |       SS       df       MS              Number of obs =    1000
-------------+------------------------------           F(  1,   998) = 1897.98
       Model |  21304.6529     1  21304.6529           Prob > F      =  0.0000
    Residual |  11202.4862   998  11.2249361           R-squared     =  0.6554
-------------+------------------------------           Adj R-squared =  0.6550
       Total |  32507.1391   999  32.5396788           Root MSE      =  3.3504

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   4.608666   .1057864    43.57   0.000     4.401077    4.816255
       _cons |   .0724791   .1059478     0.68   0.494     -.135427    .2803851
------------------------------------------------------------------------------

*let's save the estimated coefficient on x1:
. scalar bx1base = _b[x1]


*here's the full model
. reg y x*

      Source |       SS       df       MS              Number of obs =    1000
-------------+------------------------------           F(  4,   995) = 7542.43
       Model |  31469.2792     4   7867.3198           Prob > F      =  0.0000
    Residual |  1037.85989   995  1.04307527           R-squared     =  0.9681
-------------+------------------------------           Adj R-squared =  0.9679
       Total |  32507.1391   999  32.5396788           Root MSE      =  1.0213

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.072417   .0483803    22.17   0.000     .9774781    1.167356
         x21 |   1.887788   .0461923    40.87   0.000     1.797143    1.978434
         x22 |   .5403505    .035649    15.16   0.000     .4703945    .6103064
         x23 |   .7604411   .0336674    22.59   0.000     .6943737    .8265084
       _cons |   .0205694   .0323558     0.64   0.525     -.042924    .0840629
------------------------------------------------------------------------------

*let's save the estimated coefficient on x1:
. scalar bx1full = _b[x1]

*here's the difference in the estimated coefficient on x1:
. di bx1base-bx1full
3.5362488


*here's b1x2 at work. comments:
*
* 1. the base specification includes only x1 (and a constant)
* 2. the full specification includes three additional covariates
* 3. we ask b1x2 to put the first two covariates in group g1 and put x23 in g2
*
. b1x2 y, x1all(x1) x2all(x2*) x2delta(g1 = x21 x22 : g2=x23) x1only(x1)

                                                      Number of obs = 1000


Restricted regression:

. b1x2: reg y x1      

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   4.608666   .1057864    43.57   0.000     4.401328    4.816004
       _cons |   .0724791   .1059478     0.68   0.494    -.1351748     .280133
------------------------------------------------------------------------------

Unrestricted regression:

. b1x2: reg y x1  x21 x22 x23      
------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
          x1 |   1.072417   .0483803    22.17   0.000     .9775936    1.167241
         x21 |   1.887788   .0461923    40.87   0.000     1.797253    1.978323
         x22 |   .5403505    .035649    15.16   0.000     .4704796    .6102213
         x23 |   .7604411   .0336674    22.59   0.000     .6944541    .8264281
       _cons |   .0205694   .0323558     0.64   0.525    -.0428468    .0839856
------------------------------------------------------------------------------

Decomposition of changes in coefficients on x1 vars:

       x1

into parts due to these groups:

g1  = x21 x22

g2 = x23

------------------------------------------------------------------------------
           y |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
x1           |
          g1 |   2.468092     .08897    27.74   0.000     2.293714     2.64247
          g2 |   1.068156   .0579061    18.45   0.000     .9546626     1.18165
        __TC |   3.536249   .1071698    33.00   0.000       3.3262    3.746298
------------------------------------------------------------------------------

Note: The __TC...  line is the sum of all x2 variables' impacts on each x1.
      The reported covariance between this coef and all others is zero.
      This is NOT correct!!

Done with -b1x2-.

. 

**This example shows that variables in group g1 account for 2.47 of
**the difference of 3.54 between the base- and full-specification
**estimates of the coefficient on x1. The other 1.07 is explained by
**group g2, which is just the variable x23 in this case.


 
Also see
--------

 Manual:  ^[U] 26 Estimation and post-estimation commands^
          ^[U] 35 Overview of model estimation^
	  ^[R] regress^
	  ^[R] robust^
	  ^[R] test^
	  ^[R] testparm^

On-line:  help for @est@; @regress@; @robust@; @test@; @testparm@

NO WARRANTIES: TO THE EXTENT PERMITTED BY APPLICABLE LAW,
NEITHER JONAH B. GELBACH, NOR ANY OTHER PERSON, EITHER EXPRESSLY OR IMPLICITLY,
WARRANTS ANY ASPECT OF THIS SOFTWARE OR PROGRAM, INCLUDING ANY OUTPUT
OR RESULTS OF THIS SOFTWARE OR PROGRAM. THIS SOFTWARE AND PROGRAM IS BEING PROVIDED "AS IS", WITHOUT
ANY WARRANTY OF ANY TYPE OR NATURE, EITHER EXPRESS OR IMPLIED,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY
WARRANTY THAT THIS SOFTWARE OR PROGRAM IS FREE FROM DEFECTS.

 
