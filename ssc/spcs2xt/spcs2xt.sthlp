{smcl}
{hline}
{cmd:help: {helpb spcs2xt}}{space 50} {cmd:dialog:} {bf:{dialog spcs2xt}}
{hline}

{bf:{err:{dlgtab:Title}}}

{bf:spcs2xt: Convert Squared Cross Section to Panel Spatial Weight Matrix}

{marker 00}{bf:{err:{dlgtab:Table of Contents}}}
{p 4 8 2}

{p 5}{helpb spcs2xt##01:Syntax}{p_end}
{p 5}{helpb spcs2xt##02:Description}{p_end}
{p 5}{helpb spcs2xt##03:Options}{p_end}

{p 1}*** {helpb spcs2xt##04:Examples}{p_end}

{p 5}{helpb spcs2xt##05:Author}{p_end}

{marker 01}{bf:{err:{dlgtab:Syntax}}}
{phang}

{cmd: spcs2xt} {varlist} {cmd:,} {opt p:anel(numlist)} {opt t:ime(numlist)} {opt m:atrix(new_panel_weight_file)}

{marker 02}{bf:{err:{dlgtab:Description}}}

{p 2 2 2} {cmd: spcs2xt} creates or generates squared panel spatial weight matrix and file among neighbor locations, from squared Cross Section weight matrix, that already exists in stata dta file, for using in panel spatial regression analysis.{p_end}

{marker 03}{bf:{err:{dlgtab:Options}}}

{p 2 2 2}{cmd: time}: Number of time series in each cross section (must be balanced).{p_end}

{p 2 2 2}{cmd: matrix}: Specify name of new panel spatial weight matrix file as stata dta file, that will be created.{p_end}

{marker 04}{bf:{err:{dlgtab:Examples}}}

	{stata clear all}

	{stata use spcs2xt.dta, clear}

	{stata db spcs2xt}

	{stata spcs2xt v1 v2 v3 v4, time(4) matrix(W)}

{cmd:OR USE}

	{stata spcs2xt v*, time(4) matrix(W)}

	{stata mat list W}

	{stata mat list Wxt}

{p 2 2 2} The final shape of cross section and panel spatial weight matrix will be as follows:.{p_end}

  --------------------------
  |   {bf:1}      {bf:2}      {bf:3}      {bf:4}
  |-------------------------
  |   0      {bf:{red:1}}      {bf:{red:1}}      {bf:{red:1}}
  |   {bf:{red:1}}      0      {bf:{red:1}}      0
  |   {bf:{red:1}}      {bf:{red:1}}      0      {bf:{red:1}}
  |   {bf:{red:1}}      0      {bf:{red:1}}      0
  |-------------------------

            (1)               (2)               (3)               (4)         
    |-----------------|-----------------|-----------------|-----------------|
(1) |  0   0   0   0  |  {bf:{red:1}}   0   0   0  |  {bf:{red:1}}   0   0   0  |  {bf:{red:1}}   0   0   0  |
    |  0   0   0   0  |  0   {bf:{red:1}}   0   0  |  0   {bf:{red:1}}   0   0  |  0   {bf:{red:1}}   0   0  |
    |  0   0   0   0  |  0   0   {bf:{red:1}}   0  |  0   0   {bf:{red:1}}   0  |  0   0   {bf:{red:1}}   0  |
    |  0   0   0   0  |  0   0   0   {bf:{red:1}}  |  0   0   0   {bf:{red:1}}  |  0   0   0   {bf:{red:1}}  |
    |-----------------|-----------------|-----------------|-----------------|
(2) |  {bf:{red:1}}   0   0   0  |  0   0   0   0  |  {bf:{red:1}}   0   0   0  |  0   0   0   0  |
    |  0   {bf:{red:1}}   0   0  |  0   0   0   0  |  0   {bf:{red:1}}   0   0  |  0   0   0   0  |
    |  0   0   {bf:{red:1}}   0  |  0   0   0   0  |  0   0   {bf:{red:1}}   0  |  0   0   0   0  |
    |  0   0   0   {bf:{red:1}}  |  0   0   0   0  |  0   0   0   {bf:{red:1}}  |  0   0   0   0  |
    |-----------------|-----------------|-----------------|-----------------|
(3) |  {bf:{red:1}}   0   0   0  |  {bf:{red:1}}   0   0   0  |  0   0   0   0  |  {bf:{red:1}}   0   0   0  |
    |  0   {bf:{red:1}}   0   0  |  0   {bf:{red:1}}   0   0  |  0   0   0   0  |  0   {bf:{red:1}}   0   0  |
    |  0   0   {bf:{red:1}}   0  |  0   0   {bf:{red:1}}   0  |  0   0   0   0  |  0   0   {bf:{red:1}}   0  |
    |  0   0   0   {bf:{red:1}}  |  0   0   0   {bf:{red:1}}  |  0   0   0   0  |  0   0   0   {bf:{red:1}}  |
    |-----------------|-----------------|-----------------|-----------------|
(4) |  {bf:{red:1}}   0   0   0  |  0   0   0   0  |  {bf:{red:1}}   0   0   0  |  0   0   0   0  |
    |  0   {bf:{red:1}}   0   0  |  0   0   0   0  |  0   {bf:{red:1}}   0   0  |  0   0   0   0  |
    |  0   0   {bf:{red:1}}   0  |  0   0   0   0  |  0   0   {bf:{red:1}}   0  |  0   0   0   0  |
    |  0   0   0   {bf:{red:1}}  |  0   0   0   0  |  0   0   0   {bf:{red:1}}  |  0   0   0   0  |
    |-----------------|-----------------|-----------------|------------------


{p 2 2 2} After creating panel spatial weight matrix, you can use {helpb spautoreg} {opt (if installed)} to generate eigenvalues vector and standardized weight matrix.{p_end}

{marker 05}{bf:{err:{dlgtab:Author}}}

  {hi:Emad Abd Elmessih Shehata}
  {hi:Professor (PhD Economics)}
  {hi:Agricultural Research Center - Agricultural Economics Research Institute - Egypt}
  {hi:Email: {browse "mailto:emadstat@hotmail.com":emadstat@hotmail.com}}
  {hi:WebPage:{col 27}{browse "http://emadstat.110mb.com/stata.htm"}}
  {hi:WebPage at IDEAS:{col 27}{browse "http://ideas.repec.org/f/psh494.html"}}
  {hi:WebPage at EconPapers:{col 27}{browse "http://econpapers.repec.org/RAS/psh494.htm"}}

{bf:{err:{dlgtab:SPCS2XT Citation}}}

{p 1}{cmd:Shehata, Emad Abd Elmessih (2012)}{p_end}
{p 1 10 1}{cmd:SPCS2XT: "Convert Squared Cross Section to Panel Spatial Weight Matrix"}{p_end}

	{browse "http://ideas.repec.org/c/boc/bocode/s457348.html"}

	{browse "http://econpapers.repec.org/software/bocbocode/s457348.htm"}


{title:Online Help:}

{bf:{err:*** Spatial Econometrics Regression Models:}}

--------------------------------------------------------------------------------
{bf:{err:*** (1) Spatial Panel Data Regression Models:}}
{helpb spregxt}{col 14}Spatial Panel Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2slsxt}{col 14}Generalized Spatial Panel 2SLS Regression
{helpb gs2slsarxt}{col 14}Generalized Spatial Panel Autoregressive 2SLS Regression
{helpb spglsxt}{col 14}Spatial Panel Autoregressive Generalized Least Squares Regression
{helpb spgmmxt}{col 14}Spatial Panel Autoregressive Generalized Method of Moments Regression
{helpb spmstarxt}{col 14}(m-STAR) Spatial Lag Panel Models
{helpb spmstardxt}{col 14}(m-STAR) Spatial Durbin Panel Models
{helpb spmstardhxt}{col 14}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb spmstarhxt}{col 14}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb spregdhp}{col 14}Spatial Panel Han-Philips Linear Dynamic Regression: Lag & Durbin Models
{helpb spregdpd}{col 14}Spatial Panel Arellano-Bond Linear Dynamic Regression: Lag & Durbin Models
{helpb spregfext}{col 14}Spatial Panel Fixed Effects Regression: Lag & Durbin Models
{helpb spregrext}{col 14}Spatial Panel Random Effects Regression: Lag & Durbin Models
{helpb spregsacxt}{col 14}MLE Spatial AutoCorrelation Panel Regression (SAC)
{helpb spregsarxt}{col 14}MLE Spatial Lag Panel Regression (SAR)
{helpb spregsdmxt}{col 14}MLE Spatial Durbin Panel Regression (SDM)
{helpb spregsemxt}{col 14}MLE Spatial Error Panel Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (2) Spatial Cross Section Regression Models:}}
{helpb spregcs}{col 14}Spatial Cross Section Regression Econometric Models: {cmd:Stata Module Toolkit}
{helpb gs2sls}{col 14}Generalized Spatial 2SLS Cross Sections Regression
{helpb gs2slsar}{col 14}Generalized Spatial Autoregressive 2SLS Cross Sections Regression
{helpb gs3sls}{col 14}Generalized Spatial Autoregressive 3SLS Regression 
{helpb gs3slsar}{col 14}Generalized Spatial Autoregressive 3SLS Cross Sections Regression
{helpb gsp3sls}{col 14}Generalized Spatial 3SLS Cross Sections Regression
{helpb spautoreg}{col 14}Spatial Cross Section Regression Models
{helpb spgmm}{col 14}Spatial Autoregressive GMM Cross Sections Regression
{helpb spmstar}{col 14}(m-STAR) Spatial Lag Cross Sections Models
{helpb spmstard}{col 14}(m-STAR) Spatial Durbin Cross Sections Models
{helpb spmstardh}{col 14}(m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections Models
{helpb spmstarh}{col 14}(m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections Models
{helpb spregsac}{col 14}MLE Spatial AutoCorrelation Cross Sections Regression (SAC)
{helpb spregsar}{col 14}MLE Spatial Lag Cross Sections Regression (SAR)
{helpb spregsdm}{col 14}MLE Spatial Durbin Cross Sections Regression (SDM)
{helpb spregsem}{col 14}MLE Spatial Error Cross Sections Regression (SEM)
--------------------------------------------------------------------------------
{bf:{err:*** (3) Tobit Spatial Regression Models:}}

{bf:*** (3-1) Tobit Spatial Panel Data Regression Models:}
{helpb sptobitgmmxt}{col 14}Tobit Spatial GMM Panel Regression
{helpb sptobitmstarxt}{col 14}Tobit (m-STAR) Spatial Lag Panel Models
{helpb sptobitmstardxt}{col 14}Tobit (m-STAR) Spatial Durbin Panel Models
{helpb sptobitmstardhxt}{col 14}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Panel Models
{helpb sptobitmstarhxt}{col 14}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Panel Models
{helpb sptobitsacxt}{col 14}Tobit MLE Spatial AutoCorrelation (SAC) Panel Regression
{helpb sptobitsarxt}{col 14}Tobit MLE Spatial Lag Panel Regression
{helpb sptobitsdmxt}{col 14}Tobit MLE Spatial Panel Durbin Regression
{helpb sptobitsemxt}{col 14}Tobit MLE Spatial Error Panel Regression
{helpb spxttobit}{col 14}Tobit Spatial Panel Autoregressive GLS Regression
--------------------------------------------------------------
{bf:*** (3-2) Tobit Spatial Cross Section Regression Models:}
{helpb sptobitgmm}{col 14}Tobit Spatial GMM Cross Sections Regression
{helpb sptobitmstar}{col 14}Tobit (m-STAR) Spatial Lag Cross Sections Models
{helpb sptobitmstard}{col 14}Tobit (m-STAR) Spatial Durbin Cross Sections Models
{helpb sptobitmstardh}{col 14}Tobit (m-STAR) Spatial Durbin Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitmstarh}{col 14}Tobit (m-STAR) Spatial Lag Multiplicative Heteroscedasticity Cross Sections
{helpb sptobitsac}{col 14}Tobit MLE AutoCorrelation (SAC) Cross Sections Regression
{helpb sptobitsar}{col 14}Tobit MLE Spatial Lag Cross Sections Regression
{helpb sptobitsdm}{col 14}Tobit MLE Spatial Durbin Cross Sections Regression
{helpb sptobitsem}{col 14}Tobit MLE Spatial Error Cross Sections Regression
--------------------------------------------------------------------------------
{bf:{err:*** (4) Spatial Weight Matrix:}}
{helpb spcs2xt}{col 14}Convert Cross Section to Panel Spatial Weight Matrix
{helpb spweight}{col 14}Cross Section and Panel Spatial Weight Matrix
{helpb spweightcs}{col 14}Cross Section Spatial Weight Matrix
{helpb spweightxt}{col 14}Panel Spatial Weight Matrix
--------------------------------------------------------------------------------

{psee}
{p_end}

