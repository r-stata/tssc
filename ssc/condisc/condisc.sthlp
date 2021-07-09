{smcl}
{* *! version 1.0 07Apr2015}
{cmd:help condisc}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:condisc }{hline 2}}Convergent and discriminant validity assessment in CFA{p_end}
{p2colreset}{...}


{title:Description}

{bf:condisc} assesses convergent and discriminant validity of latent constructs
expressed by congeneric (not loading on more than one factor) indicators making
up a confirmatory factor model estimated using sem. 

Convergent validity is the extent to which a set of indicators reflecting the same 
construct are positively correlated. Convergent validity of a construct can be 
claimed to be demonstrated when the construct can explain an average amount of 50 
per cent variance of its indicators. This value is commonly referred to as average
variance extracted (AVE) in the litterature.  

AVE = Sum of squared standardised loadings/Number of indicators

Discriminant validity can be exhibited when the average variance extracted (AVE)
value of a latent construct is larger than its squared correlation (SC) with any other
latent construct in the model, showing that each latent construct shares more variance 
with its associated indicators than with any other latent variable expressed by 
different sets of indicators in the model.  

When both convergent and discriminant validity are established, a latent construct 
can be considered valid. 

{bf:condisc} applies a strict criterion supporting discriminant validity only when
all of the AVE values are larger than all of the SC values.   


KW: convergent
KW: discriminant
KW: validity
KW: factor 
KW: confirmatory


{title:Examples}

{phang}{stata "use http://www.ats.ucla.edu/stat/stata/output/m255, clear": . use http://www.ats.ucla.edu/stat/stata/output/m255, clear}{p_end}
{phang}{stata "keep item13-item27 item42 item52": . keep item13-item27 item42 item52}{p_end}

{phang}{stata "qui sem (Factor1->item13 item14 item15)(Factor2->item22 item23 item24)": . qui sem (Factor1->item13 item14 item15)(Factor2->item22 item23 item24)}{p_end}
{phang}{stata "condisc": . condisc}{p_end}

{phang}{stata "qui sem (Factor1->item13 item14)(Factor2->item22 item23 item24)": . qui sem (Factor1->item13 item14)(Factor2->item22 item23 item24)}{p_end}
{phang}{stata "condisc": . condisc}{p_end}

{phang}{stata "qui sem (Factor1->item25 item27)(Factor2->item42 item52)": . qui sem (Factor1->item25 item27)(Factor2->item42 item52)}{p_end}
{phang}{stata "condisc": . condisc}{p_end}


{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}
Fornell, C., & Larcker, D. F. (1981). Evaluating Structural Equation Models with 
Unobservable Variables and Measurement Errors. Journal of Marketing Research, 
18, 39-50. 	


	

  
