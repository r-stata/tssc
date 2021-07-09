{smcl}
{* 26apr2003}{...}
{hline}
help for {cmd:relyplot}
{hline}

{title:Reliability Plot}   

{p 6 21 2} 
{cmdab:relyplot} [{cmd:if} {it:exp}] [{cmd:in} {it:range}]{cmd:,}
   {cmdab:fra:ctions(}3,4,5,or 10{cmd:)} or {cmdab:gr:oups(}#{cmd:)}
   [{cmd:ci} {it:graph_options}]


{title:Description}

{p 4 6 4}
{cmd:relyplot} examines reliability of predicted risks following a {cmd:logistic}
  model. It creates categories of predicted risk, divided either into
  {cmd:fractions}, e.g. tenths, or any number of equal size {cmd:groups}
  (percentiles). It then calculates proportions of observed "events"
  among subjects within similar predictive probability categories. These
  proportions are plotted against a diagonal line for perfect fit
  (observed=predicted). Deviations from the line indicate worse prediction
  in those categories. {cmd:relyplot} can be repeated on a new sample using
  logistic regression estimates from another sample.


{title:Options required (must choose one only)}

{p 4 8 2}
{cmd:fractions(}#{cmd:)} -- divides predicted risk into fractional categories of
risk. Only groups with observations are displayed. The following values are
allowed:

        3 -- divides risk groups into thirds  (0-.33, .33-.67, .67-1.0)
        4 -- divides risk groups into fourths (0-.25, .25-.50, .50-.75, etc.)
        5 -- divides risk groups into fifths  (0-.20, .20-.40, .40-.60, etc.)
       10 -- divides risk groups into tenths  (0-.10, .10-.20, .20-.30, etc.)

{p 4 8 2}     
{cmd:groups(}#{cmd:)} -- divides predicted risk into percentiles, i.e., # of equal
size groups; this would be useful if using fractions (see {cmd:fractions}) results
in too few observations in some groups to accurately calculate observed risk

    
{title:Options} 

{p 4 8 2}
{cmd:ci} -- Plots the 95% confidence interval around the observed proportions


{title:Examples}
 
    {cmd:. use sample1}
    {cmd:. logistic died chol age htn}
    {cmd:. relyplot, fractions(10)}

        Displays a reliabilitly plot with predicted risks divided into tenths

    {cmd:. use sample2}
    {cmd:. relyplot, fractions(10)}

        Opens a second data set, uses estimates from first data set

    {cmd:. relyplot, group(5)}
 
        Divides predicted risk into 5 equal size groups, i.e., quintiles
