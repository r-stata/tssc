{smcl}
{* 06Mar2012}{...}
{hline}
help {cmd:mlt} {right: {browse "mailto:moehring@wiso.uni-koeln.de": Katja Moehring} and {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Multilevel tools (mlt) - An ado package for multilevel modeling (Version 1.4 beta)}


{p 4 4} The {cmd:mlt}-package consists of five ados:


{space 2} {helpb mltl2scatter: mltl2scatter} {col 18} {lalign 25: is an easy way to produce scatter plots at higher levels.}
{space 2} {helpb mltrsq: mltrsq} {col 18} {lalign 25: Snijders/Bosker and Bryk/Raudenbusch R-squared (postestimation for {helpb xtmixed:xtmixed}).}
{space 2} {helpb mlt2stage: mlt2stage} {col 18} {lalign 25: estimates two-stage (or slopes as outcomes) coefficients.}
{space 2} {col 18} {lalign 25: Can be used together with {helpb mltl2scatter:mltl2scatter} to produce two-stage plots.}
{space 2} {helpb mltcooksd: mltcooksd} {col 18} {lalign 25: estimates Cook's D and DFBETAs for the second level units in hierarchical mixed models}
{space 2} {col 18} {lalign 25: (postestimation for {helpb xtmixed:xtmixed}, {helpb xtmelogit:xtmelogit} and {helpb xtmepoisson:xtmepoisson}). }
{space 2} {helpb mltshowm: mltshowm} {col 18} {lalign 25: shows the models which caused Cook's D to be above the cutoff point.}
{space 2} {col 18} {lalign 25: postestimation command for {cmd:mltcooksd}.}




{title:Authors}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, 
{browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.

{p 4} Please report bugs!
