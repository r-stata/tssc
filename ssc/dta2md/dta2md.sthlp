{smcl}
{* *! version 1.0.13  10oct2019}{...}
{cmd:help dta2md}
{hline}

{title:Title}

{phang}
{bf:dta2md} {hline 2} Convert Stata system file to metadata{p_end}


{title:Table of contents}

    {help dta2md##syn:Syntax}
    {help dta2md##des:Description}
    {help dta2md##kno:Known issues}
    {help dta2md##exa:Examples}
    {help dta2md##ack:Acknowledgements}
    {help dta2md##aut:Author}

{marker syn}{...}
{title:Syntax}

{p 8 15 2}
{cmd:dta2md} {cmdab:in:put(}{it:filename}{cmd:)} {cmdab:freqvar:list(}{varlist}{cmd:)} {cmdab:out:put(}{it:filename}{cmd:)} [{cmdab:gr:oup(}{var}{cmd:)} {cmdab:re:place} {cmdab:miss:ingdef(}{it:exp}{cmd:)} {cmdab:smiss:ingdef(}{it:exp}{cmd:)} {cmdab:relat:ion(}{it:re}{cmd:)}]

{marker args}{...}

{synoptset 28}{...}
{synopthdr:Arguments}
{synoptline}
{synopt:{cmdab:in:put}}specifies the Stata system file which is converted.{p_end}

{synopt:{cmdab:freqvar:list}}list of variables for which information on value level is computed.{p_end}

{synopt:{cmdab:out:put}}specifies where the metadata file is saved.{p_end}

{synopt:{cmdab:gr:oup}}specifies group variable across which meta data are stratified.{p_end}

{synopt:{cmdab:re:place}}specifies if output file replaces existing file.{p_end}

{synopt:{cmdab:miss:ingdeff}}specifies definition which non-system-missings in numerical variables should be considered as invalid values.{p_end}

{synopt:{cmdab:smiss:ingdeff}}specifies definition which non-system-missings in alpha-numeric variables should be considered as invalid values.{p_end}

{synopt:{cmdab:relat:ion}}specifies a regular expression which is used to indicate 
related variables of main variables. E.g. the suffix _flag indicates flag variables of the respective variables without the suffix. This relation would be specified with {cmd:relation("(_flag)$")}.{p_end}

{marker des}{...}
{title:Description}

{p 4 4 2}
{cmd:dta2md} converts a Stata system file to aggregated metadata. For all variables, 
descriptive statistics are computed. Additionally, for a specified subset of variables, frequencies on the value level can be generated.
The ado allows to generate all metadata for the whole sample and also for all levels of a categorical variable.
Exemplatory use cases might be international comparative data. 

{marker kno}{...}
{title:Known issues}

{p 4 4 2}
Continuous variables: In the metadata file, a observation for each level of an variable in the list {cmd:freqvarlist} is created. 
This leads to a huge metadata file if continuous variables are accidentally included in the list {cmd:freqvarlist}. Therefore, do not include continuous variables.

{p 4 4 2}
Encoding problems: The ado does not guarantee proper translation between encoding. If you run into problems, use {manhelp unicode_translate D:unicode translate} to convert your system file, before you use the ado.

{p 4 4 2}
Missing values: The ado uses system missings to compute the number of valid cases and respective percentages of all cases. The options {cmd:missingdeff} and {cmd:smissingdeff} can be used to
specify missing values. This missing option functionality is designed for identical system missing structure for all variables, e.g. all negative values should be considered as system missings.
It is possible to specify missing definition that differentiate along variables, but the ado is finally tested for such applications. We advise to use consistent missing definitions.

{marker ex}{...}
{title:Examples}

{p 4 4 2}
This is simple application of the ado to convert the auto data to metadata. Here, we only compute frequencies for the variables {cmd:rep78}. We use {cmd:foreign} as group variable, i.e. we get all statistics
also for domestic and foreign cars separately. In the missing option, we define that all negative values in numeric variable should be considered as system missing.

{inp:. dta2md, input(`c(sysdir stata)'auto.dta) output("auto_md.dta") freqvarlist(rep78) group(foreign) missingdef(`"(X < 0) | missing(X)"') smissingdef(missing(X)) replace}
{txt}Variables processed (12)
{txt}----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
{txt}............

{inp:. use auto_md.dta}

{inp:. list in 1/20, sepby(varName)}

{txt}     +---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
{txt}     | group   computed   varName        variableLabel   total_n   total_~g    min     max       Mean   Standa~n   value   valueL~l    n    percent   validP~t   isValid   first |
{txt}     |---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt}  1. |   all          0      make       Make and Model        74          0      .       .          .          .                       .          .          .         .       1 |
{txt}  2. |   DOM          0      make       Make and Model        52          0      .       .          .          .                       .          .          .         .       1 |
{txt}  3. |   FOR          0      make       Make and Model        22          0      .       .          .          .                       .          .          .         .       1 |
{txt}     |---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt}  4. |   all          0     price                Price        74          0   3291   15906   6165.257   2949.496                       .          .          .         .       1 |
{txt}  5. |   DOM          0     price                Price        52          0   3291   15906   6072.423   3097.104                       .          .          .         .       1 |
{txt}  6. |   FOR          0     price                Price        22          0   3748   12990   6384.682   2621.915                       .          .          .         .       1 |
{txt}     |---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt}  7. |   all          0       mpg        Mileage (mpg)        74          0     12      41    21.2973   5.785503                       .          .          .         .       1 |
{txt}  8. |   DOM          0       mpg        Mileage (mpg)        52          0     12      34   19.82692   4.743297                       .          .          .         .       1 |
{txt}  9. |   FOR          0       mpg        Mileage (mpg)        22          0     14      41   24.77273   6.611187                       .          .          .         .       1 |
{txt}     |---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt} 10. |   all          1     rep78   Repair Record 1978        74          5      1       5   3.405797   .9899323       1               2   2.702703   2.898551         1       1 |
{txt} 11. |   all          1     rep78   Repair Record 1978        74          5      1       5   3.405797   .9899323       2               8   10.81081    11.5942         1       0 |
{txt} 12. |   all          1     rep78   Repair Record 1978        74          5      1       5   3.405797   .9899323       3              30   40.54054   43.47826         1       0 |
{txt} 13. |   all          1     rep78   Repair Record 1978        74          5      1       5   3.405797   .9899323       4              18   24.32432   26.08696         1       0 |
{txt} 14. |   all          1     rep78   Repair Record 1978        74          5      1       5   3.405797   .9899323       5              11   14.86487   15.94203         1       0 |
{txt} 15. |   DOM          1     rep78   Repair Record 1978        52          4      1       5   3.020833    .837666       1               2   3.846154   4.166667         1       1 |
{txt} 16. |   DOM          1     rep78   Repair Record 1978        52          4      1       5   3.020833    .837666       2               8   15.38461   16.66667         1       0 |
{txt} 17. |   DOM          1     rep78   Repair Record 1978        52          4      1       5   3.020833    .837666       3              27   51.92308      56.25         1       0 |
{txt} 18. |   DOM          1     rep78   Repair Record 1978        52          4      1       5   3.020833    .837666       4               9   17.30769      18.75         1       0 |
{txt} 19. |   DOM          1     rep78   Repair Record 1978        52          4      1       5   3.020833    .837666       5               2   3.846154   4.166667         1       0 |
{txt} 20. |   FOR          1     rep78   Repair Record 1978        22          1      3       5   4.285714   .7171372       3               3   13.63636   14.28571         1       1 |
{txt}     +---------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

{p 4 4 2}{txt}
In the second example, we also use the option {cmd:relation} to define dependencies among variables, in order to distinguish attached variables from main variables.
We again use the auto.dta, but let's assume the {cmd:length} is the flag variable related to {cmd:weight}. To indicate this, the variable name is {cmd:weight_flag}.
In such a case, we would add the the option {cmd:relation("(_flag)$")}. For illustration we change the auto file accordingly.

{inp:. sysuse auto.dta, clear}
{txt}(1978 Automobile Data)

{inp:. rename length weight_flag}

{inp:. save auto.dta, replace}
{txt}file auto.dta saved

{inp:. dta2md, input(`c(sysdir stata)'auto.dta) output("auto_md.dta") freqvarlist(rep78) group(foreign) missingdef(`"(X < 0) | missing(X)"') smissingdef(missing(X)) relation("(_flag)$") replace}
{txt}Variables processed (12)
{txt}----+--- 1 ---+--- 2 ---+--- 3 ---+--- 4 ---+--- 5 
{txt}............

{inp:. list in 29/34, sepby(varName)}

{txt}     +--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
{txt}     | group   computed       varName   mother   variableLabel   total_n   total_~g    min    max       Mean   Standa~n   value   valueL~l   n   percent   validP~t   isValid   first |
{txt}     |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt} 29. |   all          0        weight            Weight (lbs.)        74          0   1760   4840   3019.459   777.1935                      .         .          .         .       1 |
{txt} 30. |   DOM          0        weight            Weight (lbs.)        52          0   1800   4840   3317.115   695.3638                      .         .          .         .       1 |
{txt} 31. |   FOR          0        weight            Weight (lbs.)        22          0   1760   3420   2315.909   433.0034                      .         .          .         .       1 |
{txt}     |--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
{txt} 32. |   all          0   weight_flag   weight    Length (in.)        74          0    142    233   187.9324   22.26634                      .         .          .         .       1 |
{txt} 33. |   DOM          0   weight_flag   weight    Length (in.)        52          0    147    233   196.1346   20.04605                      .         .          .         .       1 |
{txt} 34. |   FOR          0   weight_flag   weight    Length (in.)        22          0    142    193   168.5455   13.68255                      .         .          .         .       1 |
{txt}     +--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

{p 4 4 2}{txt}
The variable {cmd:mother} indicates that {cmd:weight} is the relational superordinate partner to {cmd:weight_flag}.
Typical use cases would me additional variable that indicate the origin of missing values and flag variables that mark imputed values.

{marker ack}{...}
{title:Acknowledgments}

{p 4 4 2}
Florian Thirolf, Anne Balz

{marker aut}{...}
{title:Author}

{pstd}Klaus Pforr, GESIS, klaus.pforr@gesis.org


