{smcl}
{hline}

{title:Fractal - v1.0 - 22 Jul 2012}

    {hi:Generate fractals }

{title:Syntax}
{p 8 17 2}
{cmd:fractal}  [{cmd:,} {it:options}]

{title:Options}
{p 4 6 2}{cmd:HShape(numlist)} The horizontal (x-axis) proportions of the shape (equivalent to x coordinates of the shape).  Values should be between 0 and 1.0 and be in ascending order. The first value should be 0 and the last value 1.

{p 4 6 2}{cmd:VShape(numlist)} The vertical (y-axis) proportions of the shape (equivalent to y coordinates of the shape). The first value should be zero. 
The last value cannot be zero.  There are no restrictions to other values.  If the last value is not one, all values will be divided by the last value.

{p 4 6 2}{cmd:HRange(numlist)} Horizontal Range (of x-axis) (defines the horizontal size of the shape).  Two numbers, default is 0, 100.

{p 4 6 2}{cmd:VRange(numlist)} Vertical Range (of y-axis) (defines the vertical size of the shape).  Two numbers, default is 0, 100.

{p 4 6 2}{cmd:ITer(#)} The number of iterations of self-similarity (default is 1)

{p 4 6 2}{cmd:KEEPVars} Keep values for all iterations (default is to save only the last iteration).

{p 4 6 2}{cmd:SAVEGraph} Saves and displays graphs of all iterations

{title:Options for more complex fractals}
{p 4 6 2}{cmd:HSHAPE2(numlist)} Horizontal coordinates for a second shape that can be substituted for the base shape probalistically. Same rules as for HSHAPE option.{smcl}
{p 4 6 2}{cmd:VSHAPE2(numlist)} Vertical coordinates for a second shape that can be substituted for the base shape probalistically. 
                                Same rules as for VSHAPE option. {smcl}
{p 4 6 2}{cmd:PROB2(#)} Probability of occurance for this shape (must be a number between 0 and 1).{smcl}
{p 4 6 2}{cmd:HSHAPE3(numlist)} Horizontal coordinates for a third shape that can be substituted for the base shape probalistically. Same rules as for HSHAPE option.{smcl}
{p 4 6 2}{cmd:VSHAPE3(numlist)} Vertical coordinates for a third shape that can be substituted for the base shape probalistically. Same rules as for VSHAPE option.{smcl}
{p 4 6 2}{cmd:PROB3(#)} Probability of occurance for this shape (must be a number between 0 and 1).{smcl}

{p 4 6 2}The sum of PROB2 and PROB3 must be less than 1.0. The probability of using the first (base) shape is 1.0 - (PROB2 + PROB3).{smcl}
{p 4 6 2}This set of commands allows the use of several shapes when generating the fractal.  Use the command -set seed # - to consistently create the same fractal.{smcl}
{title:Description}
{p 4 6 2}{cmd:Fractal} generates points that correspond to the fractal given by the shape specified. Results are saved in the variables _frctlx and _frctly.{smcl}
{p 4 6 2}Mandelbrot argues that the modelling of natural phenomena, including that of the stock market, is problematic.  
The distribution most commonly used, the normal or Gaussian distribution, does not adequately account for natural variation.  
Neither are natural phenomena independent, another common, but erroneous, assumption when modelling.  
Mandelbrot argues that fractals can more accurately model the variation observed in nature.{smcl}
{p 4 6 2}This routine allows the generation of data for use in modelling.  
The examples presented do not begin with a dataset, since the purpose of the routine is to generate data, not to analyse it.

{title:Example - a Fractal Cartoon}
{cmd:. clear}
{cmd:. fractal}  ,hshape(0,.33,.67,1.0) vshape(0,.67,.33,1.0) hr(0 100) vr(0 100) iter(4) savegraph
{cmd:. graph} combine _frctl1.gph _frctl2.gph _frctl3.gph _frctl4.gph{smcl}

{title:Another simple example - an Elliott wave-like shape}
{cmd:. clear}
{cmd:. fractal}  ,hs(0,.2,.3,.40,.5,.618,.75,.85,1.0) vs(0,.25,.2,.35,.25,.516,.366,.42,.2) hr(0 100) vr(0 100) iter(3) savegraph keepvars
{cmd:. line} _frctly1 _frctlx1, lw(vthick) || line _frctly2 _frctlx2, lw(thick) || line _frctly3 _frctlx3, lw(medium){smcl}

{title:An example creating a fractal containing two shapes}
{cmd:. clear}
{cmd:. set seed 1234356789}
{cmd:. fractal}  ,hs(0,.33,.67,1.0) vs(0,.67,.33,1.0) hr(0 100) vr(0 100) iter(4) savegraph hshape2(0,.25,.5,.75,1.0) vshape2(0,-.25,1.25,.5,1.0) prob2(.4)
{cmd:. graph} combine _frctl1.gph _frctl2.gph _frctl3.gph _frctl4.gph{smcl}

{title:Author}
Paul Millar
www.paulmillar.ca
paulmi@nipissingu.ca {smcl}

{title:References}
Mandelbrot and Hudson (2004).  The (Mis)Behavior of Markets.  New York: Basic Books.
