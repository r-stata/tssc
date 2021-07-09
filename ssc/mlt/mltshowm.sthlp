{smcl}
{* 06Mar2012}{...}
{hline}
help {cmd:mltshowm} {right: {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Postestimation command for mltcooksd}

{p 4}Syntax

{p 8 14}{cmd:mltshowm} 
[{cmd:,}]
[{cmd:all}]



{p 4 4} {cmd:mltshowm} is part of the {helpb mlt:mlt} (multilevel tools) package. 


{title:Description}

{p 4 4} {cmd:mltshowm} is an postestimation command for {cmd:mltcooksd}. {cmd:mltshowm} shows all models that caused Cook's D to be above the cut off value. 
{cmd:mltshowm} uses Cook's D for the whole model (fixed+random part). See the help for {helpb mltcooksd} if you want to display selected models estimated by mltcooksd.
 
 
{title:Options}

{p 4 8} {cmd:all} forces mltshowm to display all estimated models. 


{title:Authors}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alexander.schmidt@wiso.uni-koeln.de}, 
{browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.


{title:Also see}

{p 4 8}   {helpb mlt: mlt}, {helpb mltshowm: mltshowm}, {helpb mltrsq: mltrsq}, {helpb mltl2scatter: mltl2scatter}, {helpb mlt2stage: mlt2stage}
