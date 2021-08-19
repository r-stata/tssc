{smcl}
{* 17feb2021}{…}
{hline}
help for {hi:scheme_dubois}{right:(Version 1.0)}
{hline}

{title:Title}
Du Bois graphic scheme

{* index schemes}{...}
{title:Scheme description:  Du Bois graphic scheme}

{p 4 4 2}
The {cmd:dubois} scheme automates some parts of graphing in Stata to use the same style as the 1900 data portraits of Black America by W.E.B. Du Bois and his collaborators (Battle-Baptiste & Russert 2018; Stark 2019). The {cmd:dubois} scheme was written using the {cmd:538} scheme file as a template (Bischof 2017).

{title:Syntax}

{p 4 4 2}
For instance, you might type

{p 8 16 2}
{cmd:. graph}
...{cmd:,}
...
{cmd:scheme(dubois)}

{p 8 16 2}
{cmd:. set}
{cmd:scheme}
{cmd: dubois}
[{cmd:,}
{cmdab:perm:anently}
]

{p 4 4 2}
See help {help scheme_option} and help {help set_scheme}.

{title:Description}

{p 4 4 2}
Schemes determine the overall look of a graph; see help {help schemes}.

{p 4 4 2}
The {cmd:dubois} scheme replicates key elements of the style of the Du Bois data portraits of Black America. These style elements include:

{p 8 8 2}
* aspect ratio of 0.78 (portrait) or 1.27 (landscape) consistent with the large format 22x28 inch portrait oriented posters of the Du Bois 1900 Paris exposition.

{p 8 8 2}
* The use of bold solid colors is a characteristic of the DuBois style. Here are the colors in the Du Bois palette: black, brown, tan, gold, pink, crimson, green, blue, often employing the Pan-African combination of red (crimson), yellow (gold) , green, and black.

{p 8 8 2}
* The use of bold solid colors is a characteristic of the DuBois style. Here are the colors in the Du Bois palette: black, brown, tan, gold, pink, crimson, green, blue, often employing the Pan-African combination of red (crimson), yellow (gold) , green, and black.

{p 8 8 2}
* linen color background "250 240 230"

{p 8 8 2}
* grey gridlines for two dimensional line and area plots.

{title:Remarks}

{p 4 4 2}
Many elements of the Du Bois style cannot be automated with a Stata scheme file. For example, graph fonts cannot be controlled via a Stata scheme. One of the most important style elements that cannot be controlled by a Stata scheme is font. Anthony Starks and others have noted that Public Sans closely resembles the original Du Bois font. Adding uncommon fonts like this to the Mac OS Font Book can be challenging for novices. Among the factory installed Mac fonts, Tahoma is closest to that used by Du Bois, especially when key elements like main titles are written with all caps. You can set your graphing font to Tahoma in Stata with the following commands:

{p 8 8 2}
* graph set svg fontface Tahoma

{p 8 8 2}
* graph set eps fontface Tahoma

{p 8 8 2}
* graph set ps fontface Tahoma

{p 4 4 2}
For examples of how to implement other elements of Du Bois style, you can find use cases with data, Stata code, and graphic outputs here: {browse "https://github.com/charlieeatonphd/dubois-data-portraits/tree/master/statascheme"}

{title:References}

{p 4 8 2}
Battle-Baptiste, W. and Rusert, B. eds., 2018. {it:WEB Du Bois's Data Portraits: Visualizing Black America}. Chronicle Books. {browse "https://www.amazon.com/W-Boiss-Data-Portraits-Visualizing/dp/1616897066"}

{p 4 8 2}
Bischof, D. 2017. New Graphic Schemes for Stata: plotplain & plottig. Stata Journal: 17(3): 1-12. {browse "https://danbischof.com/publications/"}

{p 4 8 2}
Starks, A. J. 2019. "What is Dubois-Style Visualization?" {browse "https://github.com/ajstarks/dubois-data-portraits/blob/master/dubois-style.md"}

{title:Author}

{p 4 4 2}
{browse „ceaton2@ucmerced.edu“:Charlie Eaton}, Jay Colond, Ruben Gonzalez, and Waleed Rajabally - Department of Sociology,
University of California, Merced.

{title:Also see}

{p 4 14 2}
Online:  help for {help schemes}; {it:{help scheme_option}}, {help set_scheme}
{p_end}



