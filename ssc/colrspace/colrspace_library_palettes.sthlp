*! version 1.0.0  27may2020  Ben Jann
* {smcl}
* {title:ColrSpace palettes library}
* 
* Palette entries have the following structure:
*     n:<name of palette>
*    [c:<palette class>]
*    [d:<palette description>]
*    [s:<palette source>]
*     P[#]:<comma-separated list of color codes>
*    [...]
*    [N:<comma-separated list of color names>]
*    [I:<comma-separated list of color descriptions>]
* Elements in brackets are optional.
* Use multiple P# lines for palettes that come in different sizes, where #
* denotes the number of colors. Example:
*     P3:<color1>,<color2>,<color3>
*     P4:<color1>,<color2>,<color3>,<color4>
*     P5:<color1>,<color2>,<color3>,<color4>,<color5>
*     ...
* For palettes that only come in one size, use P without #. In this case you can
* also assign color names and descriptions using N and I. Example:
*     P:<color1>,<color2>,<color3>
*     N:<name1>,<name2>,<name3>
*     I:<info1>,<info2>,<info3>
* The elements in the lists must be comma separated. Use quotes if an element
* contains a comma.
* Color codes can be specified in any format that is understood by ColrSpace,
* Palette names should be unique.
* Lines starting with * will be ignored.
* {asis}
* {smcl}
* {title:s2}{asis}
n:s2
c:qualitative
d:colors used for p1 to p15 in Stata's s2color scheme
P:navy,maroon,forest_green,dkorange,teal,cranberry,lavender,khaki,sienna,emidblue,emerald,brown,erose,gold,bluishgray
* {smcl}
* {title:s1}{asis}
n:s1
c:qualitative
d:colors used for p1 to p15 in Stata's s1color scheme
P:dkgreen,orange_red,navy,maroon,teal,sienna,orange,magenta,cyan,red,lime,brown,purple,olive_teal,ltblue
* {smcl}
* {title:s1r}{asis}
n:s1r
c:qualitative
d:colors used for p1 to p15 in Stata's s1rcolor scheme
P:yellow,lime,midblue,magenta,orange,red,ltblue,sandb,mint,olive_teal,orange_red,blue,pink,teal,sienna
* {smcl}
* {title:economist}{asis}
n:economist
c:qualitative
d:colors used for p1 to p15 in Stata's economist scheme
P:edkblue,emidblue,eltblue,emerald,erose,ebblue,eltgreen,stone,navy,maroon,brown,lavender,teal,cranberry,khaki
* {smcl}
* {title:mono}{asis}
n:mono
c:qualitative
d:gray scales used for p1 to p15 in Stata's monochrome schemes
P:gs6,gs10,gs8,gs4,black,gs12,gs2,gs7,gs9,gs11,gs13,gs5,gs3,gs14,gs15
* {smcl}
* {title:cblind}{asis}
n:cblind
c:qualitative
d:colorblind-friendly colors suggested by Okabe and Ito (2002), including gray as suggested at www.cookbook-r.com
s:https://jfly.uni-koeln.de/color/
P:#000000,#999999,#e69f00,#56b4e9,#009e73,#f0e442,#0072b2,#d55e00,#cc79a7
N:Black,Gray,Orange,Sky Blue,bluish Green,Yellow,Blue,Vermillion,reddish Purple
* {smcl}
* {title:plottig}{asis}
n:plottig
c:qualitative
d:colors used for p1 to p15 in the plottig scheme by Bischof (2017)
s:https://www.stata-journal.com/article.html?article=gr0070
P:black,97 156 255,0 192 175,201 152 0,185 56 255,248 118 109,0 176 246,0 186 56,163 165 0,231 107 243,255 103 164,0 188 216,107 177 0,229 135 0,253 97 209
N:black,plb1,plg1,ply1,pll1,plr1,plb2,plg2,ply2,pll2,plr2,plb3,plg3,ply3,pll3
I:,blue,lght greenish,yellow/brownish,purple,red,bluish,greenish,yellow/brownish,purple,red,blue,green,orange,purple
* {smcl}
* {title:538}{asis}
n:538
c:qualitative
d:colors used for p1 to p6, background, labels, axes etc. in the 538 scheme by Bischof (2017)
s:https://ideas.repec.org/c/boc/bocode/s458404.html
P:3 144 214,254 48 11,120 172 68,247 187 5,229 138 233,254 133 3,242 242 242,205 205 206,155 155 155,162 204 246,254 181 167,42 161 237,255 244 241
N:538b,538r,538g,538y,538m,538o,538background,538axis,538label,538bs6,538rs6,538bs1,538rs11
I:,,,,,,,,,used for ci,used for ci2,used for contour_begin,used for contour_end
* {smcl}
* {title:mrc}{asis}
n:mrc
c:qualitative
d:colors used for p1 to p7 in the mrc scheme by Morris (2013)
s:https://ideas.repec.org/c/boc/bocode/s457703.html
P:33 103 126,106 59 119,130 47 90,208 114 50,255 219 0,181 211 52,138 121 103
N:mrcblue,mrcpurple,mrcred,mrcorange,mrcyellow,mrcgreen,mrcgrey
* {smcl}
* {title:tfl}{asis}
n:tfl
c:qualitative
d:colors used for p1 to p8 in the tfl scheme by Morris (2015)
s:https://ideas.repec.org/c/boc/bocode/s458103.html
P:220 36 31,0 25 168,0 114 41,232 106 16,137 78 36,117 16 86,255 206 0,65 75 86
N:tflred,tflblue,tflgreen,tflorange,tflbrown,tflpurple,tflyellow,tflgrey
* {smcl}
* {title:burd}{asis}
n:burd
c:qualitative
d:colors used for p1 to p9 and for CIs in the burd scheme by Briatte (2013)
s:https://ideas.repec.org/c/boc/bocode/s457623.html
P:33 102 172,178 24 43,27 120 55,230 97 1,1 102 94,197 27 125,118 42 131,140 81 10,77 77 77,103 169 207,209 229 240,239 138 98,253 219 199
N:Bu,Rd,Gn,Or,BG,Pi,Pu,Br,Gy,,,,
I:Bu from RdBu-7,Rd from RdBu-7,Gn from PRGn-7,Or from PuOr-7,BG from BrBG-7,Pi from PiYG-7,Pu from PuOr-7,Br from BrBG-7,Gy from RdGy-7,used for ci_arealine,used for ci_area,used for ci2_arealine,used for ci2_area
* {smcl}
* {title:lean}{asis}
n:lean
c:qualitative
d:gray scales used for p1area to p15area in schemes lean1 and lean2 by Juul (2003)
s:https://www.stata-journal.com/article.html?article=gr0002
P:gs14,gs10,gs12,gs8,gs16,gs13,gs10,gs7,gs4,gs0,gs14,gs10,gs12,gs0,gs16
* {smcl}
* {title:tableau}{asis}
n:tableau
c:qualitative
d:categorical colors provided by Lin et al. (2013)
s:https://github.com/StanfordHCI/semantic-colors/blob/master/Engine/ColorAssigner.cs
P:#1f77b4,#ff7f0e,#2ca02c,#d62728,#9467bd,#8c564b,#e377c2,#7f7f7f,#bcbd22,#17becf,#aec7e8,#ffbb78,#98df8a,#ff9896,#c5b0d5,#c49c94,#f7b6d2,#c7c7c7,#dbdb8d,#9edae5
* {smcl}
* {title:Accent}{asis}
n:Accent
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:127 201 127,190 174 212,253 192 134,255 255 153,56 108 176,240 2 127,191 91 23,102 102 102
n:Accent cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.5 0 .5 0,.25 .25 0 0,0 .25 .4 0,0 0 .4 0,.8 .4 0 0,0 1 0 0,.25 .6 .9 0,0 0 0 .6
* {smcl}
* {title:Dark2}{asis}
n:Dark2
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:27 158 119,217 95 2,117 112 179,231 41 138,102 166 30,230 171 2,166 118 29,102 102 102
n:Dark2 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.9 0 .55 0,.15 .6 1 0,.55 .45 0 0,.05 .85 .05 0,.6 .1 1 0,.1 .3 1 0,.35 .45 .9 0,0 0 0 .6
* {smcl}
* {title:Paired}{asis}
n:Paired
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:166 206 227,31 120 180,178 223 138,51 160 44,251 154 153,227 26 28,253 191 111,255 127 0,202 178 214,106 61 154,255 255 153,177 89 40
n:Paired cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.35 .07 0 0,.9 .3 0 0,.3 0 .45 0,.8 0 1 0,0 .4 .25 0,.1 .9 .8 0,0 .25 .5 0,0 .5 1 0,.2 .25 0 0,.6 .7 0 0,0 0 .4 0,.23 .73 .98 .12
* {smcl}
* {title:Pastel1}{asis}
n:Pastel1
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:251 180 174,179 205 227,204 235 197,222 203 228,254 217 166,255 255 204,229 216 189,253 218 236,242 242 242
n:Pastel1 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:0 .3 .2 0,.3 .1 0 0,.2 0 .2 0,.12 .17 0 0,0 .15 .3 0,0 0 .2 0,.1 .12 .2 0,0 .15 0 0,0 0 0 .05
* {smcl}
* {title:Pastel2}{asis}
n:Pastel2
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:179 226 205,253 205 172,203 213 232,244 202 228,230 245 201,255 242 174,241 226 204,204 204 204
n:Pastel2 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.3 0 .15 0,0 .2 .25 0,.2 .1 0 0,.03 .2 0 0,.1 0 .2 0,0 .05 .3 0,.05 .1 .15 0,0 0 0 .2
* {smcl}
* {title:Set1}{asis}
n:Set1
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:228 26 28,55 126 184,77 175 74,152 78 163,255 127 0,255 255 51,166 86 40,247 129 191,153 153 153
n:Set1 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.1 .9 .8 0,.8 .3 0 0,.7 0 .8 0,.4 .65 0 0,0 .5 1 0,0 0 .8 0,.35 .6 .8 0,0 .5 0 0,0 0 0 .4
* {smcl}
* {title:Set2}{asis}
n:Set2
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:102 194 165,252 141 98,141 160 203,231 138 195,166 216 84,255 217 47,229 196 148,179 179 179
n:Set2 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.6 0 .3 0,0 .45 .5 0,.45 .25 0 0,.07 .45 0 0,.35 0 .7 0,0 .15 .8 0,.1 .2 .35 0,0 0 0 .3
* {smcl}
* {title:Set3}{asis}
n:Set3
c:qualitative
d:categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P:141 211 199,255 255 179,190 186 218,251 128 114,128 177 211,253 180 98,179 222 105,252 205 229,217 217 217,188 128 189,204 235 197,255 237 111
n:Set3 cmyk
c:qualitative
d:CMYK variant of categorical colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P:.45 0 .15 0,0 0 .3 0,.25 .2 0 0,0 .5 .4 0,.5 .15 0 0,0 .3 .55 0,.3 0 .6 0,0 .2 0 0,0 0 0 .15,.25 .45 0 0,.2 0 .2 0,0 .07 .55 0
* {smcl}
* {title:Blues}{asis}
n:Blues
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:222 235 247,158 202 225,49 130 189
P4:239 243 255,189 215 231,107 174 214,33 113 181
P5:239 243 255,189 215 231,107 174 214,49 130 189,8 81 156
P6:239 243 255,198 219 239,158 202 225,107 174 214,49 130 189,8 81 156
P7:239 243 255,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 69 148
P8:247 251 255,222 235 247,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 69 148
P9:247 251 255,222 235 247,198 219 239,158 202 225,107 174 214,66 146 198,33 113 181,8 81 156,8 48 107
n:Blues cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.13 .03 0 0,.38 .08 0 0,.82 .27 0 0
P4:.08 .02 0 0,.28 .07 0 0,.57 .14 0 0,.9 .34 0 0
P5:.08 .02 0 0,.28 .07 0 0,.57 .14 0 0,.82 .27 0 0,1 .45 0 .07
P6:.08 .02 0 0,.24 .06 0 0,.38 .08 0 0,.57 .14 0 0,.82 .27 0 0,1 .45 0 .07
P7:.08 .02 0 0,.24 .06 0 0,.38 .08 0 0,.57 .14 0 0,.75 .22 0 0,.9 .34 0 0,1 .55 0 .05
P8:.03 .01 0 0,.13 .03 0 0,.24 .06 0 0,.38 .08 0 0,.57 .14 0 0,.75 .22 0 0,.9 .34 0 0,1 .55 0 .05
P9:.03 .01 0 0,.13 .03 0 0,.24 .06 0 0,.38 .08 0 0,.57 .14 0 0,.75 .22 0 0,.9 .34 0 0,1 .45 0 .07,1 .55 0 .3
* {smcl}
* {title:Greens}{asis}
n:Greens
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:229 245 224,161 217 155,49 163 84
P4:237 248 233,186 228 179,116 196 118,35 139 69
P5:237 248 233,186 228 179,116 196 118,49 163 84,0 109 44
P6:237 248 233,199 233 192,161 217 155,116 196 118,49 163 84,0 109 44
P7:237 248 233,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 90 50
P8:247 252 245,229 245 224,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 90 50
P9:247 252 245,229 245 224,199 233 192,161 217 155,116 196 118,65 171 93,35 139 69,0 109 44,0 68 27
n:Greens cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.1 0 .1 0,.37 0 .37 0,.81 0 .76 0
P4:.07 0 .07 0,.27 0 .27 0,.55 0 .55 0,.84 .1 .83 0
P5:.07 0 .07 0,.27 0 .27 0,.55 0 .55 0,.81 0 .76 0,1 .2 1 0
P6:.07 0 .07 0,.22 0 .22 0,.37 0 .37 0,.55 0 .55 0,.81 0 .76 0,1 .2 1 0
P7:.07 0 .07 0,.22 0 .22 0,.37 0 .37 0,.55 0 .55 0,.75 0 .7 0,.87 .1 .83 0,1 .35 .9 0
P8:.03 0 .03 0,.1 0 .1 0,.22 0 .22 0,.37 0 .37 0,.55 0 .55 0,.75 0 .7 0,.87 .1 .83 0,1 .35 .9 0
P9:.03 0 .03 0,.1 0 .1 0,.22 0 .22 0,.37 0 .37 0,.55 0 .55 0,.75 0 .7 0,.87 .1 .83 0,1 .2 1 0,1 .5 1 0
* {smcl}
* {title:Greys}{asis}
n:Greys
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:240 240 240,189 189 189,99 99 99
P4:247 247 247,204 204 204,150 150 150,82 82 82
P5:247 247 247,204 204 204,150 150 150,99 99 99,37 37 37
P6:247 247 247,217 217 217,189 189 189,150 150 150,99 99 99,37 37 37
P7:247 247 247,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37
P8:255 255 255,240 240 240,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37
P9:255 255 255,240 240 240,217 217 217,189 189 189,150 150 150,115 115 115,82 82 82,37 37 37,0 0 0
n:Greys cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 0 0 .06,0 0 0 .26,0 0 0 .61
P4:0 0 0 .03,0 0 0 .2,0 0 0 .41,0 0 0 .68
P5:0 0 0 .03,0 0 0 .2,0 0 0 .41,0 0 0 .61,0 0 0 .85
P6:0 0 0 .03,0 0 0 .15,0 0 0 .26,0 0 0 .41,0 0 0 .61,0 0 0 .85
P7:0 0 0 .03,0 0 0 .15,0 0 0 .26,0 0 0 .41,0 0 0 .55,0 0 0 .68,0 0 0 .85
P8:0 0 0 0,0 0 0 .06,0 0 0 .15,0 0 0 .26,0 0 0 .41,0 0 0 .55,0 0 0 .68,0 0 0 .85
P9:0 0 0 0,0 0 0 .06,0 0 0 .15,0 0 0 .26,0 0 0 .41,0 0 0 .55,0 0 0 .68,0 0 0 .85,0 0 0 1
* {smcl}
* {title:Oranges}{asis}
n:Oranges
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:254 230 206,253 174 107,230 85 13
P4:254 237 222,253 190 133,253 141 60,217 71 1
P5:254 237 222,253 190 133,253 141 60,230 85 13,166 54 3
P6:254 237 222,253 208 162,253 174 107,253 141 60,230 85 13,166 54 3
P7:254 237 222,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,140 45 4
P8:255 245 235,254 230 206,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,140 45 4
P9:255 245 235,254 230 206,253 208 162,253 174 107,253 141 60,241 105 19,217 72 1,166 54 3,127 39 4
n:Oranges cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .1 .15 0,0 .32 .5 0,.1 .65 .95 0
P4:0 .07 .1 0,0 .26 .4 0,0 .45 .7 0,.15 .7 1 0
P5:0 .07 .1 0,0 .26 .4 0,0 .45 .7 0,.1 .65 .95 0,.35 .75 1 0
P6:0 .07 .1 0,0 .19 .3 0,0 .32 .5 0,0 .45 .7 0,.1 .65 .95 0,.35 .75 1 0
P7:0 .07 .1 0,0 .19 .3 0,0 .32 .5 0,0 .45 .7 0,.05 .58 .9 0,.15 .7 1 0,.45 .78 1 0
P8:0 .04 .06 0,0 .1 .15 0,0 .19 .3 0,0 .32 .5 0,0 .45 .7 0,.05 .58 .9 0,.15 .7 1 0,.45 .78 1 0
P9:0 .04 .06 0,0 .1 .15 0,0 .19 .3 0,0 .32 .5 0,0 .45 .7 0,.05 .58 .9 0,.15 .7 1 0,.35 .75 1 0,.5 .8 1 0
* {smcl}
* {title:Purples}{asis}
n:Purples
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:239 237 245,188 189 220,117 107 177
P4:242 240 247,203 201 226,158 154 200,106 81 163
P5:242 240 247,203 201 226,158 154 200,117 107 177,84 39 143
P6:242 240 247,218 218 235,188 189 220,158 154 200,117 107 177,84 39 143
P7:242 240 247,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,74 20 134
P8:252 251 253,239 237 245,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,74 20 134
P9:252 251 253,239 237 245,218 218 235,188 189 220,158 154 200,128 125 186,106 81 163,84 39 143,63 0 125
n:Purples cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.06 .05 0 0,.28 .18 0 0,.55 .48 0 0
P4:.05 .04 0 0,.2 .15 0 0,.38 .3 0 0,.6 .6 0 0
P5:.05 .04 0 0,.2 .15 0 0,.38 .3 0 0,.55 .48 0 0,.7 .8 0 0
P6:.05 .04 0 0,.14 .1 0 0,.26 .18 0 0,.38 .3 0 0,.55 .48 0 0,.7 .8 0 0
P7:.05 .04 0 0,.14 .1 0 0,.26 .18 0 0,.38 .3 0 0,.5 .4 0 0,.6 .6 0 0,.75 .9 0 0
P8:.01 .01 0 0,.06 .05 0 0,.14 .1 0 0,.26 .18 0 0,.38 .3 0 0,.5 .4 0 0,.6 .6 0 0,.75 .9 0 0
P9:.01 .01 0 0,.06 .05 0 0,.14 .1 0 0,.26 .18 0 0,.38 .3 0 0,.5 .4 0 0,.6 .6 0 0,.7 .8 0 0,.8 1 0 0
* {smcl}
* {title:Reds}{asis}
n:Reds
c:sequential
d:sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:254 224 210,252 146 114,222 45 38
P4:254 229 217,252 174 145,251 106 74,203 24 29
P5:254 229 217,252 174 145,251 106 74,222 45 38,165 15 21
P6:254 229 217,252 187 161,252 146 114,251 106 74,222 45 38,165 15 21
P7:254 229 217,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,153 0 13
P8:255 245 240,254 224 210,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,153 0 13
P9:255 245 240,254 224 210,252 187 161,252 146 114,251 106 74,239 59 44,203 24 29,165 15 21,103 0 13
n:Reds cmyk
c:sequential
d:CMYK variant of sequential colors (single hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .12 .12 0,0 .43 .43 0,.12 .82 .75 0
P4:0 .1 .1 0,0 .32 .32 0,0 .59 .59 0,.2 .9 .8 0
P5:0 .1 .1 0,0 .32 .32 0,0 .59 .59 0,.12 .82 .75 0,.35 .95 .85 0
P6:0 .1 .1 0,0 .27 .27 0,0 .43 .43 0,0 .59 .59 0,.12 .82 .75 0,.35 .95 .85 0
P7:0 .1 .1 0,0 .27 .27 0,0 .43 .43 0,0 .59 .59 0,.05 .77 .72 0,.2 .9 .8 0,.4 1 .9 0
P8:0 .04 .04 0,0 .12 .12 0,0 .27 .27 0,0 .43 .43 0,0 .59 .59 0,.05 .77 .72 0,.2 .9 .8 0,.4 1 .9 0
P9:0 .04 .04 0,0 .12 .12 0,0 .27 .27 0,0 .43 .43 0,0 .59 .59 0,.05 .77 .72 0,.2 .9 .8 0,.35 .95 .85 0,.6 1 .9 0
* {smcl}
* {title:BuGn}{asis}
n:BuGn
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:229 245 249,153 216 201,44 162 95
P4:237 248 251,178 226 226,102 194 164,35 139 69
P5:237 248 251,178 226 226,102 194 164,44 162 95,0 109 44
P6:237 248 251,204 236 230,153 216 201,102 194 164,44 162 95,0 109 44
P7:237 248 251,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 88 36
P8:247 252 253,229 245 249,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 88 36
P9:247 252 253,229 245 249,204 236 230,153 216 201,102 194 164,65 174 118,35 139 69,0 109 44,0 68 27
n:BuGn cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.1 0 0 0,.4 0 .15 0,.83 0 .7 0
P4:.07 0 0 0,.3 0 .05 0,.6 0 .3 0,.87 .1 .83 0
P5:.07 0 0 0,.3 0 .05 0,.6 0 .3 0,.83 0 .7 0,1 .2 1 0
P6:.07 0 0 0,.2 0 .06 0,.4 0 .15 0,.6 0 .3 0,.83 0 .7 0,1 .2 1 0
P7:.07 0 0 0,.2 0 .06 0,.4 0 .15 0,.6 0 .3 0,.75 0 .55 0,.87 .1 .83 0,1 .35 1 0
P8:.03 0 0 0,.1 0 0 0,.2 0 .06 0,.4 0 .15 0,.6 0 .3 0,.75 0 .55 0,.87 .1 .83 0,1 .35 1 0
P9:.03 0 0 0,.1 0 0 0,.2 0 .06 0,.4 0 .15 0,.6 0 .3 0,.75 0 .55 0,.87 .1 .83 0,1 .2 1 0,1 .5 1 0
* {smcl}
* {title:BuPu}{asis}
n:BuPu
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:224 236 244,158 188 218,136 86 167
P4:237 248 251,179 205 227,140 150 198,136 65 157
P5:237 248 251,179 205 227,140 150 198,136 86 167,129 15 124
P6:237 248 251,191 211 230,158 188 218,140 150 198,136 86 167,129 15 124
P7:237 248 251,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,110 1 107
P8:247 252 253,224 236 244,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,110 1 107
P9:247 252 253,224 236 244,191 211 230,158 188 218,140 150 198,140 107 177,136 65 157,129 15 124,77 0 75
n:BuPu cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.12 .03 0 0,.38 .14 0 0,.47 .6 0 0
P4:.07 0 0 0,.3 .1 0 0,.45 .3 0 0,.47 .7 0 0
P5:.07 0 0 0,.3 .1 0 0,.45 .3 0 0,.47 .6 0 0,.47 .95 0 .05
P6:.07 0 0 0,.25 .09 0 0,.38 .14 0 0,.45 .3 0 0,.47 .6 0 0,.47 .95 0 .05
P7:.07 0 0 0,.25 .09 0 0,.38 .14 0 0,.45 .3 0 0,.45 .5 0 0,.47 .7 0 0,.5 1 0 .15
P8:.03 0 0 0,.12 .03 0 0,.25 .09 0 0,.38 .14 0 0,.45 .3 0 0,.45 .5 0 0,.47 .7 0 0,.5 1 0 .15
P9:.03 0 0 0,.12 .03 0 0,.25 .09 0 0,.38 .14 0 0,.45 .3 0 0,.45 .5 0 0,.47 .7 0 0,.47 .95 0 .05,.5 1 0 .4
* {smcl}
* {title:GnBu}{asis}
n:GnBu
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:224 243 219,168 221 181,67 162 202
P4:240 249 232,186 228 188,123 204 196,43 140 190
P5:240 249 232,186 228 188,123 204 196,67 162 202,8 104 172
P6:240 249 232,204 235 197,168 221 181,123 204 196,67 162 202,8 104 172
P7:240 249 232,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 88 158
P8:247 252 240,224 243 219,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 88 158
P9:247 252 240,224 243 219,204 235 197,168 221 181,123 204 196,78 179 211,43 140 190,8 104 172,8 64 129
n:GnBu cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.12 0 .12 0,.34 0 .25 0,.75 .12 0 0
P4:.06 0 .08 0,.27 0 .23 0,.52 0 .15 0,.8 .2 0 0
P5:.06 0 .08 0,.27 0 .23 0,.52 0 .15 0,.75 .12 0 0,1 .35 0 0
P6:.06 0 .08 0,.2 0 .2 0,.34 0 .25 0,.52 0 .15 0,.75 .12 0 0,1 .35 0 0
P7:.06 0 .08 0,.2 0 .2 0,.34 0 .25 0,.52 0 .15 0,.7 .05 0 0,.85 .2 0 0,1 .42 0 .05
P8:.03 0 .05 0,.12 0 .12 0,.2 0 .2 0,.34 0 .25 0,.52 0 .15 0,.7 .05 0 0,.85 .2 0 0,1 .42 0 .05
P9:.03 0 .05 0,.12 0 .12 0,.2 0 .2 0,.34 0 .25 0,.52 0 .15 0,.7 .05 0 0,.85 .2 0 0,1 .35 0 0,1 .5 0 .2
* {smcl}
* {title:OrRd}{asis}
n:OrRd
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:254 232 200,253 187 132,227 74 51
P4:254 240 217,253 204 138,252 141 89,215 48 31
P5:254 240 217,253 204 138,252 141 89,227 74 51,179 0 0
P6:254 240 217,253 212 158,253 187 132,252 141 89,227 74 51,179 0 0
P7:254 240 217,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,153 0 0
P8:255 247 236,254 232 200,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,153 0 0
P9:255 247 236,254 232 200,253 212 158,253 187 132,252 141 89,239 101 72,215 48 31,179 0 0,127 0 0
n:OrRd cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .09 .18 0,0 .27 .4 0,.1 .7 .7 0
P4:0 .06 .12 0,0 .2 .4 0,0 .45 .55 0,.15 .8 .8 0
P5:0 .06 .12 0,0 .2 .4 0,0 .45 .55 0,.1 .7 .7 0,.3 1 1 0
P6:0 .06 .12 0,0 .17 .32 0,0 .27 .4 0,0 .45 .55 0,.1 .7 .7 0,.3 1 1 0
P7:0 .06 .12 0,0 .17 .32 0,0 .27 .4 0,0 .45 .55 0,.05 .6 .6 0,.15 .8 .8 0,.4 1 1 0
P8:0 .03 .06 0,0 .09 .18 0,0 .17 .32 0,0 .27 .4 0,0 .45 .55 0,.05 .6 .6 0,.15 .8 .8 0,.4 1 1 0
P9:0 .03 .06 0,0 .09 .18 0,0 .17 .32 0,0 .27 .4 0,0 .45 .55 0,.05 .6 .6 0,.15 .8 .8 0,.3 1 1 0,.5 1 1 0
* {smcl}
* {title:PuBu}{asis}
n:PuBu
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:236 231 242,166 189 219,43 140 190
P4:241 238 246,189 201 225,116 169 207,5 112 176
P5:241 238 246,189 201 225,116 169 207,43 140 190,4 90 141
P6:241 238 246,208 209 230,166 189 219,116 169 207,43 140 190,4 90 141
P7:241 238 246,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,3 78 123
P8:255 247 251,236 231 242,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,3 78 123
P9:255 247 251,236 231 242,208 209 230,166 189 219,116 169 207,54 144 192,5 112 176,4 90 141,2 56 88
n:PuBu cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.07 .07 0 0,.35 .15 0 0,.85 .2 0 0
P4:.05 .05 0 0,.26 .13 0 0,.55 .17 0 0,1 .3 0 0
P5:.05 .05 0 0,.26 .13 0 0,.55 .17 0 0,.85 .2 0 0,1 .3 0 .2
P6:.05 .05 0 0,.18 .12 0 0,.35 .15 0 0,.55 .17 0 0,.85 .2 0 0,1 .3 0 .2
P7:.05 .05 0 0,.18 .12 0 0,.35 .15 0 0,.55 .17 0 0,.8 .2 0 0,1 .3 0 0,1 .3 0 .3
P8:0 .03 0 0,.07 .07 0 0,.18 .12 0 0,.35 .15 0 0,.55 .17 0 0,.8 .2 0 0,1 .3 0 0,1 .3 0 .3
P9:0 .03 0 0,.07 .07 0 0,.18 .12 0 0,.35 .15 0 0,.55 .17 0 0,.8 .2 0 0,1 .3 0 0,1 .3 0 .2,1 .3 0 .5
* {smcl}
* {title:PuBuGn}{asis}
n:PuBuGn
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:236 226 240,166 189 219,28 144 153
P4:246 239 247,189 201 225,103 169 207,2 129 138
P5:246 239 247,189 201 225,103 169 207,28 144 153,1 108 89
P6:246 239 247,208 209 230,166 189 219,103 169 207,28 144 153,1 108 89
P7:246 239 247,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 100 80
P8:255 247 251,236 226 240,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 100 80
P9:255 247 251,236 226 240,208 209 230,166 189 219,103 169 207,54 144 192,2 129 138,1 108 89,1 70 54
n:PuBuGn cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.07 .09 0 0,.35 .15 0 0,.9 .12 .27 0
P4:.03 .05 0 0,.26 .13 0 0,.6 .15 0 0,1 .15 .35 0
P5:.03 .05 0 0,.26 .13 0 0,.6 .15 0 0,.9 .12 .27 0,1 .25 .65 0
P6:.03 .05 0 0,.18 .12 0 0,.35 .15 0 0,.6 .15 0 0,.9 .12 .27 0,1 .25 .65 0
P7:.03 .05 0 0,.18 .12 0 0,.35 .15 0 0,.6 .15 0 0,.8 .2 0 0,1 .15 .35 0,1 .3 .7 0
P8:0 .03 0 0,.07 .09 0 0,.18 .12 0 0,.35 .15 0 0,.6 .15 0 0,.8 .2 0 0,1 .15 .35 0,1 .3 .7 0
P9:0 .03 0 0,.07 .09 0 0,.18 .12 0 0,.35 .15 0 0,.6 .15 0 0,.8 .2 0 0,1 .15 .35 0,1 .25 .65 0,1 .5 .8 0
* {smcl}
* {title:PuRd}{asis}
n:PuRd
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:231 225 239,201 148 199,221 28 119
P4:241 238 246,215 181 216,223 101 176,206 18 86
P5:241 238 246,215 181 216,223 101 176,221 28 119,152 0 67
P6:241 238 246,212 185 218,201 148 199,223 101 176,221 28 119,152 0 67
P7:241 238 246,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,145 0 63
P8:247 244 249,231 225 239,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,145 0 63
P9:247 244 249,231 225 239,212 185 218,201 148 199,223 101 176,231 41 138,206 18 86,152 0 67,103 0 31
n:PuRd cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.09 .09 0 0,.2 .38 0 0,.1 .9 .15 0
P4:.05 .05 0 0,.15 .25 0 0,.1 .6 0 0,.17 .95 .35 0
P5:.05 .05 0 0,.15 .25 0 0,.1 .6 0 0,.1 .9 .15 0,.4 1 .47 0
P6:.05 .05 0 0,.16 .23 0 0,.2 .38 0 0,.1 .6 0 0,.1 .9 .15 0,.4 1 .47 0
P7:.05 .05 0 0,.16 .23 0 0,.2 .38 0 0,.1 .6 0 0,.05 .85 .05 0,.17 .95 .35 0,.43 1 .5 0
P8:.03 .03 0 0,.09 .09 0 0,.16 .23 0 0,.2 .38 0 0,.1 .6 0 0,.05 .85 .05 0,.17 .95 .35 0,.43 1 .5 0
P9:.03 .03 0 0,.09 .09 0 0,.16 .23 0 0,.2 .38 0 0,.1 .6 0 0,.05 .85 .05 0,.17 .95 .35 0,.4 1 .47 0,.6 1 .75 0
* {smcl}
* {title:RdPu}{asis}
n:RdPu
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:253 224 221,250 159 181,197 27 138
P4:254 235 226,251 180 185,247 104 161,174 1 126
P5:254 235 226,251 180 185,247 104 161,197 27 138,122 1 119
P6:254 235 226,252 197 192,250 159 181,247 104 161,197 27 138,122 1 119
P7:254 235 226,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119
P8:255 247 243,253 224 221,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119
P9:255 247 243,253 224 221,252 197 192,250 159 181,247 104 161,221 52 151,174 1 126,122 1 119,73 0 106
n:RdPu cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .12 .08 0,0 .38 .12 0,.2 .9 0 0
P4:0 .08 .08 0,0 .3 .15 0,0 .6 .1 0,.3 1 0 0
P5:0 .08 .08 0,0 .3 .15 0,0 .6 .1 0,.2 .9 0 0,.5 1 0 .05
P6:0 .08 .08 0,0 .23 .15 0,0 .38 .12 0,0 .6 .1 0,.2 .9 0 0,.5 1 0 .05
P7:0 .08 .08 0,0 .23 .15 0,0 .38 .12 0,0 .6 .1 0,.1 .8 0 0,.3 1 0 0,.5 1 0 .05
P8:0 .03 .03 0,0 .12 .08 0,0 .23 .15 0,0 .38 .12 0,0 .6 .1 0,.1 .8 0 0,.3 1 0 0,.5 1 0 .05
P9:0 .03 .03 0,0 .12 .08 0,0 .23 .15 0,0 .38 .12 0,0 .6 .1 0,.1 .8 0 0,.3 1 0 0,.5 1 0 .05,.7 1 0 .15
* {smcl}
* {title:YlGn}{asis}
n:YlGn
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:247 252 185,173 221 142,49 163 84
P4:255 255 204,194 230 153,120 198 121,35 132 67
P5:255 255 204,194 230 153,120 198 121,49 163 84,0 104 55
P6:255 255 204,217 240 163,173 221 142,120 198 121,49 163 84,0 104 55
P7:255 255 204,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 90 50
P8:255 255 229,247 252 185,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 90 50
P9:255 255 229,247 252 185,217 240 163,173 221 142,120 198 121,65 171 93,35 132 67,0 104 55,0 69 41
n:YlGn cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.03 0 .27 0,.32 0 .43 0,.81 0 .76 0
P4:0 0 .2 0,.24 0 .39 0,.53 0 .53 0,.87 .1 .83 0
P5:0 0 .2 0,.24 0 .39 0,.53 0 .53 0,.81 0 .76 0,1 .25 .9 0
P6:0 0 .2 0,.15 0 .35 0,.32 0 .43 0,.53 0 .53 0,.81 0 .76 0,1 .25 .9 0
P7:0 0 .2 0,.15 0 .35 0,.32 0 .43 0,.53 0 .53 0,.75 0 .7 0,.87 .15 .83 0,1 .35 .9 0
P8:0 0 .1 0,.03 0 .27 0,.15 0 .35 0,.32 0 .43 0,.53 0 .53 0,.75 0 .7 0,.87 .15 .83 0,1 .35 .9 0
P9:0 0 .1 0,.03 0 .27 0,.15 0 .35 0,.32 0 .43 0,.53 0 .53 0,.75 0 .7 0,.87 .15 .83 0,1 .25 .9 0,1 .5 .9 0
* {smcl}
* {title:YlGnBu}{asis}
n:YlGnBu
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:237 248 177,127 205 187,44 127 184
P4:255 255 204,161 218 180,65 182 196,34 94 168
P5:255 255 204,161 218 180,65 182 196,44 127 184,37 52 148
P6:255 255 204,199 233 180,127 205 187,65 182 196,44 127 184,37 52 148
P7:255 255 204,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,12 44 132
P8:255 255 217,237 248 177,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,12 44 132
P9:255 255 217,237 248 177,199 233 180,127 205 187,65 182 196,29 145 192,34 94 168,37 52 148,8 29 88
n:YlGnBu cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.07 0 .3 0,.5 0 .2 0,.85 .27 0 0
P4:0 0 .2 0,.37 0 .25 0,.75 0 .1 0,.9 .45 0 0
P5:0 0 .2 0,.37 0 .25 0,.75 0 .1 0,.85 .27 0 0,.9 .7 0 0
P6:0 0 .2 0,.22 0 .27 0,.5 0 .2 0,.75 0 .1 0,.85 .27 0 0,.9 .7 0 0
P7:0 0 .2 0,.22 0 .27 0,.5 0 .2 0,.75 0 .1 0,.9 .15 0 0,.9 .45 0 0,1 .7 0 .1
P8:0 0 .15 0,.07 0 .3 0,.22 0 .27 0,.5 0 .2 0,.75 0 .1 0,.9 .15 0 0,.9 .45 0 0,1 .7 0 .1
P9:0 0 .15 0,.07 0 .3 0,.22 0 .27 0,.5 0 .2 0,.75 0 .1 0,.9 .15 0 0,.9 .45 0 0,.9 .7 0 0,1 .7 0 .4
* {smcl}
* {title:YlOrBr}{asis}
n:YlOrBr
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:255 247 188,254 196 79,217 95 14
P4:255 255 212,254 217 142,254 153 41,204 76 2
P5:255 255 212,254 217 142,254 153 41,217 95 14,153 52 4
P6:255 255 212,254 227 145,254 196 79,254 153 41,217 95 14,153 52 4
P7:255 255 212,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,140 45 4
P8:255 255 229,255 247 188,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,140 45 4
P9:255 255 229,255 247 188,254 227 145,254 196 79,254 153 41,236 112 20,204 76 2,153 52 4,102 37 6
n:YlOrBr cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .03 .25 0,0 .23 .65 0,.15 .6 .95 0
P4:0 0 .17 0,0 .15 .4 0,0 .4 .8 0,.2 .67 1 0
P5:0 0 .17 0,0 .15 .4 0,0 .4 .8 0,.15 .6 .95 0,.4 .75 1 0
P6:0 0 .17 0,0 .11 .4 0,0 .23 .65 0,0 .4 .8 0,.15 .6 .95 0,.4 .75 1 0
P7:0 0 .17 0,0 .11 .4 0,0 .23 .65 0,0 .4 .8 0,.07 .55 .9 0,.2 .67 1 0,.45 .78 1 0
P8:0 0 .1 0,0 .03 .25 0,0 .11 .4 0,0 .23 .65 0,0 .4 .8 0,.07 .55 .9 0,.2 .67 1 0,.45 .78 1 0
P9:0 0 .1 0,0 .03 .25 0,0 .11 .4 0,0 .23 .65 0,0 .4 .8 0,.07 .55 .9 0,.2 .67 1 0,.4 .75 1 0,.6 .8 1 0
* {smcl}
* {title:YlOrRd}{asis}
n:YlOrRd
c:sequential
d:sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:255 237 160,254 178 76,240 59 32
P4:255 255 178,254 204 92,253 141 60,227 26 28
P5:255 255 178,254 204 92,253 141 60,240 59 32,189 0 38
P6:255 255 178,254 217 118,254 178 76,253 141 60,240 59 32,189 0 38
P7:255 255 178,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,177 0 38
P8:255 255 204,255 237 160,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,177 0 38
P9:255 255 204,255 237 160,254 217 118,254 178 76,253 141 60,252 78 42,227 26 28,189 0 38,128 0 38
n:YlOrRd cmyk
c:sequential
d:CMYK variant of sequential colors (multi-hue) from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .07 .35 0,0 .3 .65 0,.05 .77 .8 0
P4:0 0 .3 0,0 .2 .6 0,0 .45 .7 0,.1 .9 .8 0
P5:0 0 .3 0,0 .2 .6 0,0 .45 .7 0,.05 .77 .8 0,.25 1 .7 0
P6:0 0 .3 0,0 .15 .5 0,0 .3 .65 0,0 .45 .7 0,.05 .77 .8 0,.25 1 .7 0
P7:0 0 .3 0,0 .15 .5 0,0 .3 .65 0,0 .45 .7 0,0 .7 .75 0,.1 .9 .8 0,.3 1 .7 0
P8:0 0 .2 0,0 .07 .35 0,0 .15 .5 0,0 .3 .65 0,0 .45 .7 0,0 .7 .75 0,.1 .9 .8 0,.3 1 .7 0
P9:0 0 .2 0,0 .07 .35 0,0 .15 .5 0,0 .3 .65 0,0 .45 .7 0,0 .7 .75 0,.1 .9 .8 0,.25 1 .7 0,.5 1 .7 0
* {smcl}
* {title:BrBG}{asis}
n:BrBG
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:216 179 101,245 245 245,90 180 172
P4:166 97 26,223 194 125,128 205 193,1 133 113
P5:166 97 26,223 194 125,245 245 245,128 205 193,1 133 113
P6:140 81 10,216 179 101,246 232 195,199 234 229,90 180 172,1 102 94
P7:140 81 10,216 179 101,246 232 195,245 245 245,199 234 229,90 180 172,1 102 94
P8:140 81 10,191 129 45,223 194 125,246 232 195,199 234 229,128 205 193,53 151 143,1 102 94
P9:140 81 10,191 129 45,223 194 125,246 232 195,245 245 245,199 234 229,128 205 193,53 151 143,1 102 94
P10:84 48 5,140 81 10,191 129 45,223 194 125,246 232 195,199 234 229,128 205 193,53 151 143,1 102 94,0 60 48
P11:84 48 5,140 81 10,191 129 45,223 194 125,246 232 195,245 245 245,199 234 229,128 205 193,53 151 143,1 102 94,0 60 48
n:BrBG cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.15 .25 .55 0,0 0 0 .05,.65 .05 .23 0
P4:.35 .55 .9 0,.12 .2 .45 0,.5 0 .17 0,1 .1 .55 0
P5:.35 .55 .9 0,.12 .2 .45 0,0 0 0 .05,.5 0 .17 0,1 .1 .55 0
P6:.45 .6 1 0,.15 .25 .55 0,.03 .08 .2 0,.22 0 .06 0,.65 .05 .23 0,1 .3 .6 0
P7:.45 .6 1 0,.15 .25 .55 0,.03 .08 .2 0,0 0 0 .05,.22 0 .06 0,.65 .05 .23 0,1 .3 .6 0
P8:.45 .6 1 0,.25 .43 .8 0,.12 .2 .45 0,.03 .08 .2 0,.22 0 .06 0,.5 0 .17 0,.8 .12 .35 0,1 .3 .6 0
P9:.45 .6 1 0,.25 .43 .8 0,.12 .2 .45 0,.03 .08 .2 0,0 0 0 .05,.22 0 .06 0,.5 0 .17 0,.8 .12 .35 0,1 .3 .6 0
P10:.45 .6 1 .4,.45 .6 1 0,.25 .43 .8 0,.12 .2 .45 0,.03 .08 .2 0,.22 0 .06 0,.5 0 .17 0,.8 .12 .35 0,1 .3 .6 0,1 .3 .7 .4
P11:.45 .6 1 .4,.45 .6 1 0,.25 .43 .8 0,.12 .2 .45 0,.03 .08 .2 0,0 0 0 .05,.22 0 .06 0,.5 0 .17 0,.8 .12 .35 0,1 .3 .6 0,1 .3 .7 .4
* {smcl}
* {title:PiYG}{asis}
n:PiYG
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:233 163 201,247 247 247,161 215 106
P4:208 28 139,241 182 218,184 225 134,77 172 38
P5:208 28 139,241 182 218,247 247 247,184 225 134,77 172 38
P6:197 27 125,233 163 201,253 224 239,230 245 208,161 215 106,77 146 33
P7:197 27 125,233 163 201,253 224 239,247 247 247,230 245 208,161 215 106,77 146 33
P8:197 27 125,222 119 174,241 182 218,253 224 239,230 245 208,184 225 134,127 188 65,77 146 33
P9:197 27 125,222 119 174,241 182 218,253 224 239,247 247 247,230 245 208,184 225 134,127 188 65,77 146 33
P10:142 1 82,197 27 125,222 119 174,241 182 218,253 224 239,230 245 208,184 225 134,127 188 65,77 146 33,39 100 25
P11:142 1 82,197 27 125,222 119 174,241 182 218,253 224 239,247 247 247,230 245 208,184 225 134,127 188 65,77 146 33,39 100 25
n:PiYG cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.07 .35 .03 0,0 0 0 .03,.37 0 .6 0
P4:.15 .9 0 0,.04 .28 0 0,.28 0 .47 0,.7 0 1 0
P5:.15 .9 0 0,.04 .28 0 0,0 0 0 .03,.28 0 .47 0,.7 0 1 0
P6:.2 .9 .1 0,.07 .35 .03 0,0 .12 0 0,.1 0 .17 0,.37 0 .6 0,.7 .15 1 0
P7:.2 .9 .1 0,.07 .35 .03 0,0 .12 0 0,0 0 0 .03,.1 0 .17 0,.37 0 .6 0,.7 .15 1 0
P8:.2 .9 .1 0,.11 .52 .06 0,.04 .28 0 0,0 .12 0 0,.1 0 .17 0,.28 0 .47 0,.5 .05 .8 0,.7 .15 1 0
P9:.2 .9 .1 0,.11 .52 .06 0,.04 .28 0 0,0 .12 0 0,0 0 0 .03,.1 0 .17 0,.28 0 .47 0,.5 .05 .8 0,.7 .15 1 0
P10:.1 1 0 .35,.2 .9 .1 0,.11 .52 .06 0,.04 .28 0 0,0 .12 0 0,.1 0 .17 0,.28 0 .47 0,.5 .05 .8 0,.7 .15 1 0,.75 0 1 .4
P11:.1 1 0 .35,.2 .9 .1 0,.11 .52 .06 0,.04 .28 0 0,0 .12 0 0,0 0 0 .03,.1 0 .17 0,.28 0 .47 0,.5 .05 .8 0,.7 .15 1 0,.75 0 1 .4
* {smcl}
* {title:PRGn}{asis}
n:PRGn
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:175 141 195,247 247 247,127 191 123
P4:123 50 148,194 165 207,166 219 160,0 136 55
P5:123 50 148,194 165 207,247 247 247,166 219 160,0 136 55
P6:118 42 131,175 141 195,231 212 232,217 240 211,127 191 123,27 120 55
P7:118 42 131,175 141 195,231 212 232,247 247 247,217 240 211,127 191 123,27 120 55
P8:118 42 131,153 112 171,194 165 207,231 212 232,217 240 211,166 219 160,90 174 97,27 120 55
P9:118 42 131,153 112 171,194 165 207,231 212 232,247 247 247,217 240 211,166 219 160,90 174 97,27 120 55
P10:64 0 75,118 42 131,153 112 171,194 165 207,231 212 232,217 240 211,166 219 160,90 174 97,27 120 55,0 68 27
P11:64 0 75,118 42 131,153 112 171,194 165 207,231 212 232,247 247 247,217 240 211,166 219 160,90 174 97,27 120 55,0 68 27
n:PRGn cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.31 .38 0 0,0 0 0 .03,.5 .05 .5 0
P4:.53 .77 0 0,.23 .3 0 0,.35 0 .35 0,1 0 1 0
P5:.53 .77 0 0,.23 .3 0 0,0 0 0 .03,.35 0 .35 0,1 0 1 0
P6:.55 .8 .1 0,.31 .38 0 0,.09 .14 0 0,.15 0 .15 0,.5 .05 .5 0,.9 .2 .9 0
P7:.55 .8 .1 0,.31 .38 0 0,.09 .14 0 0,0 0 0 .03,.15 0 .15 0,.5 .05 .5 0,.9 .2 .9 0
P8:.55 .8 .1 0,.4 .49 .05 0,.23 .3 0 0,.09 .14 0 0,.15 0 .15 0,.35 0 .35 0,.65 .05 .65 0,.9 .2 .9 0
P9:.55 .8 .1 0,.4 .49 .05 0,.23 .3 0 0,.09 .14 0 0,0 0 0 .03,.15 0 .15 0,.35 0 .35 0,.65 .05 .65 0,.9 .2 .9 0
P10:.6 1 0 .4,.55 .8 .1 0,.4 .49 .05 0,.23 .3 0 0,.09 .14 0 0,.15 0 .15 0,.35 0 .35 0,.65 .05 .65 0,.9 .2 .9 0,1 .5 1 0
P11:.6 1 0 .4,.55 .8 .1 0,.4 .49 .05 0,.23 .3 0 0,.09 .14 0 0,0 0 0 .03,.15 0 .15 0,.35 0 .35 0,.65 .05 .65 0,.9 .2 .9 0,1 .5 1 0
* {smcl}
* {title:PuOr}{asis}
n:PuOr
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:241 163 64,247 247 247,153 142 195
P4:230 97 1,253 184 99,178 171 210,94 60 153
P5:230 97 1,253 184 99,247 247 247,178 171 210,94 60 153
P6:179 88 6,241 163 64,254 224 182,216 218 235,153 142 195,84 39 136
P7:179 88 6,241 163 64,254 224 182,247 247 247,216 218 235,153 142 195,84 39 136
P8:179 88 6,224 130 20,253 184 99,254 224 182,216 218 235,178 171 210,128 115 172,84 39 136
P9:179 88 6,224 130 20,253 184 99,254 224 182,247 247 247,216 218 235,178 171 210,128 115 172,84 39 136
P10:127 59 8,179 88 6,224 130 20,253 184 99,254 224 182,216 218 235,178 171 210,128 115 172,84 39 136,45 0 75
P11:127 59 8,179 88 6,224 130 20,253 184 99,254 224 182,247 247 247,216 218 235,178 171 210,128 115 172,84 39 136,45 0 75
n:PuOr cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.05 .35 .7 0,0 0 0 .03,.4 .35 0 0
P4:.1 .6 1 0,0 .28 .55 0,.3 .25 0 0,.65 .7 0 0
P5:.1 .6 1 0,0 .28 .55 0,0 0 0 .03,.3 .25 0 0,.65 .7 0 0
P6:.3 .6 1 0,.05 .35 .7 0,0 .12 .24 0,.15 .1 0 0,.4 .35 0 0,.7 .8 .05 0
P7:.3 .6 1 0,.05 .35 .7 0,0 .12 .24 0,0 0 0 .03,.15 .1 0 0,.4 .35 0 0,.7 .8 .05 0
P8:.3 .6 1 0,.12 .46 .92 0,0 .28 .55 0,0 .12 .24 0,.15 .1 0 0,.3 .25 0 0,.5 .45 .05 0,.7 .8 .05 0
P9:.3 .6 1 0,.12 .46 .92 0,0 .28 .55 0,0 .12 .24 0,0 0 0 .03,.15 .1 0 0,.3 .25 0 0,.5 .45 .05 0,.7 .8 .05 0
P10:.5 .7 1 0,.3 .6 1 0,.12 .46 .92 0,0 .28 .55 0,0 .12 .24 0,.15 .1 0 0,.3 .25 0 0,.5 .45 .05 0,.7 .8 .05 0,.75 1 0 .4
P11:.5 .7 1 0,.3 .6 1 0,.12 .46 .92 0,0 .28 .55 0,0 .12 .24 0,0 0 0 .03,.15 .1 0 0,.3 .25 0 0,.5 .45 .05 0,.7 .8 .05 0,.75 1 0 .4
* {smcl}
* {title:RdBu}{asis}
n:RdBu
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:239 138 98,247 247 247,103 169 207
P4:202 0 32,244 165 130,146 197 222,5 113 176
P5:202 0 32,244 165 130,247 247 247,146 197 222,5 113 176
P6:178 24 43,239 138 98,253 219 199,209 229 240,103 169 207,33 102 172
P7:178 24 43,239 138 98,253 219 199,247 247 247,209 229 240,103 169 207,33 102 172
P8:178 24 43,214 96 77,244 165 130,253 219 199,209 229 240,146 197 222,67 147 195,33 102 172
P9:178 24 43,214 96 77,244 165 130,253 219 199,247 247 247,209 229 240,146 197 222,67 147 195,33 102 172
P10:103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,209 229 240,146 197 222,67 147 195,33 102 172,5 48 97
P11:103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,247 247 247,209 229 240,146 197 222,67 147 195,33 102 172,5 48 97
n:RdBu cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.05 .45 .5 0,0 0 0 .03,.6 .15 0 0
P4:.2 1 .75 0,.03 .35 .38 0,.43 .08 0 0,1 .3 0 0
P5:.2 1 .75 0,.03 .35 .38 0,0 0 0 .03,.43 .08 0 0,1 .3 0 0
P6:.3 .9 .7 0,.05 .45 .5 0,0 .14 .16 0,.18 .04 0 0,.6 .15 0 0,.9 .4 0 0
P7:.3 .9 .7 0,.05 .45 .5 0,0 .14 .16 0,0 0 0 .03,.18 .04 0 0,.6 .15 0 0,.9 .4 0 0
P8:.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,.18 .04 0 0,.43 .08 0 0,.75 .2 0 0,.9 .4 0 0
P9:.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 .03,.18 .04 0 0,.43 .08 0 0,.75 .2 0 0,.9 .4 0 0
P10:.6 1 .75 0,.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,.18 .04 0 0,.43 .08 0 0,.75 .2 0 0,.9 .4 0 0,1 .5 0 .4
P11:.6 1 .75 0,.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 .03,.18 .04 0 0,.43 .08 0 0,.75 .2 0 0,.9 .4 0 0,1 .5 0 .4
* {smcl}
* {title:RdGy}{asis}
n:RdGy
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:239 138 98,255 255 255,153 153 153
P4:202 0 32,244 165 130,186 186 186,64 64 64
P5:202 0 32,244 165 130,255 255 255,186 186 186,64 64 64
P6:178 24 43,239 138 98,253 219 199,224 224 224,153 153 153,77 77 77
P7:178 24 43,239 138 98,253 219 199,255 255 255,224 224 224,153 153 153,77 77 77
P8:178 24 43,214 96 77,244 165 130,253 219 199,224 224 224,186 186 186,135 135 135,77 77 77
P9:178 24 43,214 96 77,244 165 130,253 219 199,255 255 255,224 224 224,186 186 186,135 135 135,77 77 77
P10:103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,224 224 224,186 186 186,135 135 135,77 77 77,26 26 26
P11:103 0 31,178 24 43,214 96 77,244 165 130,253 219 199,255 255 255,224 224 224,186 186 186,135 135 135,77 77 77,26 26 26
n:RdGy cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:.05 .45 .5 0,0 0 0 0,0 0 0 .4
P4:.2 1 .75 0,.03 .35 .38 0,0 0 0 .27,0 0 0 .75
P5:.2 1 .75 0,.03 .35 .38 0,0 0 0 0,0 0 0 .27,0 0 0 .75
P6:.3 .9 .7 0,.05 .45 .5 0,0 .14 .16 0,0 0 0 .12,0 0 0 .4,0 0 0 .7
P7:.3 .9 .7 0,.05 .45 .5 0,0 .14 .16 0,0 0 0 0,0 0 0 .12,0 0 0 .4,0 0 0 .7
P8:.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 .12,0 0 0 .27,0 0 0 .47,0 0 0 .7
P9:.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 0,0 0 0 .12,0 0 0 .27,0 0 0 .47,0 0 0 .7
P10:.6 1 .75 0,.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 .12,0 0 0 .27,0 0 0 .47,0 0 0 .7,0 0 0 .9
P11:.6 1 .75 0,.3 .9 .7 0,.15 .6 .57 0,.03 .35 .38 0,0 .14 .16 0,0 0 0 0,0 0 0 .12,0 0 0 .27,0 0 0 .47,0 0 0 .7,0 0 0 .9
* {smcl}
* {title:RdYlBu}{asis}
n:RdYlBu
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:252 141 89,255 255 191,145 191 219
P4:215 25 28,253 174 97,171 217 233,44 123 182
P5:215 25 28,253 174 97,255 255 191,171 217 233,44 123 182
P6:215 48 39,252 141 89,254 224 144,224 243 248,145 191 219,69 117 180
P7:215 48 39,252 141 89,254 224 144,255 255 191,224 243 248,145 191 219,69 117 180
P8:215 48 39,244 109 67,253 174 97,254 224 144,224 243 248,171 217 233,116 173 209,69 117 180
P9:215 48 39,244 109 67,253 174 97,254 224 144,255 255 191,224 243 248,171 217 233,116 173 209,69 117 180
P10:165 0 38,215 48 39,244 109 67,253 174 97,254 224 144,224 243 248,171 217 233,116 173 209,69 117 180,49 54 149
P11:165 0 38,215 48 39,244 109 67,253 174 97,254 224 144,255 255 191,224 243 248,171 217 233,116 173 209,69 117 180,49 54 149
n:RdYlBu cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .45 .55 0,0 0 .25 0,.43 .11 0 0
P4:.15 .9 .8 0,0 .32 .55 0,.33 .03 0 0,.85 .3 0 0
P5:.15 .9 .8 0,0 .32 .55 0,0 0 .25 0,.33 .03 0 0,.85 .3 0 0
P6:.15 .8 .75 0,0 .45 .55 0,0 .12 .4 0,.12 0 0 0,.43 .11 0 0,.75 .37 0 0
P7:.15 .8 .75 0,0 .45 .55 0,0 .12 .4 0,0 0 .25 0,.12 0 0 0,.43 .11 0 0,.75 .37 0 0
P8:.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .4 0,.12 0 0 0,.33 .03 0 0,.55 .15 0 0,.75 .37 0 0
P9:.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .4 0,0 0 .25 0,.12 0 0 0,.33 .03 0 0,.55 .15 0 0,.75 .37 0 0
P10:.35 1 .7 0,.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .4 0,.12 0 0 0,.33 .03 0 0,.55 .15 0 0,.75 .37 0 0,.85 .7 0 0
P11:.35 1 .7 0,.15 .8 .75 0,.03 .57 .63 0,0 .35 .55 0,0 .12 .4 0,0 0 .25 0,.12 0 0 0,.33 .03 0 0,.55 .15 0 0,.75 .37 0 0,.85 .7 0 0
* {smcl}
* {title:RdYlGn}{asis}
n:RdYlGn
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:252 141 89,255 255 191,145 207 96
P4:215 25 28,253 174 97,166 217 106,26 150 65
P5:215 25 28,253 174 97,255 255 191,166 217 106,26 150 65
P6:215 48 39,252 141 89,254 224 139,217 239 139,145 207 96,26 152 80
P7:215 48 39,252 141 89,254 224 139,255 255 191,217 239 139,145 207 96,26 152 80
P8:215 48 39,244 109 67,253 174 97,254 224 139,217 239 139,166 217 106,102 189 99,26 152 80
P9:215 48 39,244 109 67,253 174 97,254 224 139,255 255 191,217 239 139,166 217 106,102 189 99,26 152 80
P10:165 0 38,215 48 39,244 109 67,253 174 97,254 224 139,217 239 139,166 217 106,102 189 99,26 152 80,0 104 55
P11:165 0 38,215 48 39,244 109 67,253 174 97,254 224 139,255 255 191,217 239 139,166 217 106,102 189 99,26 152 80,0 104 55
n:RdYlGn cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .45 .55 0,0 0 .25 0,.43 0 .65 0
P4:.15 .9 .8 0,0 .32 .55 0,.35 0 .6 0,.9 0 .9 0
P5:.15 .9 .8 0,0 .35 .55 0,0 0 .25 0,.35 0 .6 0,.9 0 .9 0
P6:.15 .8 .75 0,0 .45 .55 0,0 .12 .42 0,.15 0 .45 0,.43 0 .65 0,.9 0 .9 0
P7:.15 .8 .75 0,0 .45 .55 0,0 .12 .42 0,0 0 .25 0,.15 0 .45 0,.43 0 .65 0,.9 0 .8 0
P8:.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,.15 0 .45 0,.35 0 .6 0,.6 0 .65 0,.9 0 .8 0
P9:.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,0 0 .25 0,.15 0 .45 0,.35 0 .6 0,.6 0 .65 0,.9 0 .8 0
P10:.35 1 .7 0,.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,.15 0 .45 0,.35 0 .6 0,.6 0 .65 0,.9 0 .8 0,1 .25 .9 0
P11:.35 1 .75 0,.15 .8 .75 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,0 0 .25 0,.15 0 .45 0,.35 0 .6 0,.6 0 .65 0,.9 0 .8 0,1 .25 .9 0
* {smcl}
* {title:Spectral}{asis}
n:Spectral
c:diverging
d:diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_all_schemes_RGBonly3.XLS
P3:252 141 89,255 255 191,153 213 148
P4:215 25 28,253 174 97,171 221 164,43 131 186
P5:215 25 28,253 174 97,255 255 191,171 221 164,43 131 186
P6:213 62 79,252 141 89,254 224 139,230 245 152,153 213 148,50 136 189
P7:213 62 79,252 141 89,254 224 139,255 255 191,230 245 152,153 213 148,50 136 189
P8:213 62 79,244 109 67,253 174 97,254 224 139,230 245 152,171 221 164,102 194 165,50 136 189
P9:213 62 79,244 109 67,253 174 97,254 224 139,255 255 191,230 245 152,171 221 164,102 194 165,50 136 189
P10:158 1 66,213 62 79,244 109 67,253 174 97,254 224 139,230 245 152,171 221 164,102 194 165,50 136 189,94 79 162
P11:158 1 66,213 62 79,244 109 67,253 174 97,254 224 139,255 255 191,230 245 152,171 221 164,102 194 165,50 136 189,94 79 162
n:Spectral cmyk
c:diverging
d:CMYK variant of diverging colors from colorbrewer2.org (Brewer et al. 2003); licensed under Apache License Version 2.0 (see http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html)
s:https://github.com/axismaps/colorbrewer/blob/master/cb.csv
P3:0 .45 .55 0,0 0 .25 0,.4 0 .4 0
P4:.15 .9 .8 0,0 .32 .55 0,.33 0 .33 0,.85 .25 0 0
P5:.15 .9 .8 0,0 .32 .55 0,0 0 .25 0,.33 0 .33 0,.85 .25 0 0
P6:.15 .75 .5 0,0 .45 .55 0,0 .12 .42 0,.1 0 .4 0,.4 0 .4 0,.82 .23 0 0
P7:.15 .75 .5 0,0 .45 .55 0,0 .12 .42 0,0 0 .25 0,.1 0 .4 0,.4 0 .4 0,.82 .23 0 0
P8:.15 .75 .5 0,.03 .57 .53 0,0 .32 .55 0,0 .12 .42 0,.1 0 .4 0,.33 0 .33 0,.6 0 .3 0,.82 .23 0 0
P9:.15 .75 .5 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,0 0 .25 0,.1 0 .4 0,.33 0 .33 0,.6 0 .3 0,.82 .23 0 0
P10:0 1 .2 .35,.15 .75 .5 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,.1 0 .4 0,.33 0 .33 0,.6 0 .3 0,.82 .23 0 0,.65 .6 0 0
P11:0 1 .2 .35,.15 .75 .5 0,.03 .57 .63 0,0 .32 .55 0,0 .12 .42 0,0 0 .25 0,.1 0 .4 0,.33 0 .33 0,.6 0 .3 0,.82 .23 0 0,.65 .6 0 0
* {smcl}
* {title:ptol qualitative}{asis}
n:ptol qualitative
c:qualitative
d:qualitative colors by Tol (2012)
s:https://personal.sron.nl/~pault/colourschemes.pdf
P1:68 119 170
P2:68 119 170,204 102 119
P3:68 119 170,221 204 119,204 102 119
P4:68 119 170,17 119 51,221 204 119,204 102 119
P5:51 34 136,136 204 238,17 119 51,221 204 119,204 102 119
P6:51 34 136,136 204 238,17 119 51,221 204 119,204 102 119,170 68 153
P7:51 34 136,136 204 238,68 170 153,17 119 51,221 204 119,204 102 119,170 68 153
P8:51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,204 102 119,170 68 153
P9:51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,204 102 119,136 34 85,170 68 153
P10:51 34 136,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,136 34 85,170 68 153
P11:51 34 136,102 153 204,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,136 34 85,170 68 153
P12:51 34 136,102 153 204,136 204 238,68 170 153,17 119 51,153 153 51,221 204 119,102 17 0,204 102 119,170 68 102,136 34 85,170 68 153
* {smcl}
* {title:ptol rainbow}{asis}
n:ptol rainbow
c:sequential
d:rainbow colors by Tol (2012)
s:https://personal.sron.nl/~pault/colourschemes.pdf
P4:64 64 150,87 163 173,222 167 58,217 33 32
P5:64 64 150,82 157 183,125 184 116,227 156 55,217 33 32
P6:64 64 150,73 140 194,99 173 153,190 188 72,230 139 51,217 33 32
P7:120 28 129,63 96 174,83 158 182,109 179 136,202 184 67,231 133 50,217 33 32
P8:120 28 129,63 86 167,75 145 192,95 170 159,145 189 97,216 175 61,231 124 48,217 33 32
P9:120 28 129,63 78 161,70 131 193,87 163 173,109 179 136,177 190 78,223 165 58,231 116 47,217 33 32
P10:120 28 129,63 71 155,66 119 189,82 157 183,98 172 155,134 187 106,199 185 68,227 156 55,231 109 46,217 33 32
P11:120 28 129,64 64 150,65 108 183,77 149 190,91 167 167,110 179 135,161 190 86,211 179 63,229 148 53,230 104 45,217 33 32
P12:120 28 129,65 59 147,64 101 177,72 139 194,85 161 177,99 173 153,127 185 114,181 189 76,217 173 60,230 142 52,230 100 44,217 33 32
* {smcl}
* {title:ptol diverging}{asis}
n:ptol diverging
c:diverging
d:diverging colors by Tol (2012)
s:https://personal.sron.nl/~pault/colourschemes.pdf
P3:153 199 236,255 250 210,245 162 117
P4:0 139 206,180 221 247,249 189 126,208 50 50
P5:0 139 206,180 221 247,255 250 210,249 189 126,208 50 50
P6:58 137 201,153 199 236,230 245 254,255 227 170,245 162 117,210 77 62
P7:58 137 201,153 199 236,230 245 254,255 250 210,255 227 170,245 162 117,210 77 62
P8:58 137 201,119 183 229,180 221 247,230 245 254,255 227 170,249 189 126,237 135 94,210 77 62
P9:58 137 201,119 183 229,180 221 247,230 245 254,255 250 210,255 227 170,249 189 126,237 135 94,210 77 62
P10:61 82 161,58 137 201,119 183 229,180 221 247,230 245 254,255 227 170,249 189 126,237 135 94,210 77 62,174 28 62
P11:61 82 161,58 137 201,119 183 229,180 221 247,230 245 254,255 250 210,255 227 170,249 189 126,237 135 94,210 77 62,174 28 62
* {smcl}
* {title:d3 10}{asis}
n:d3 10
c:qualitative
d:categorical colors from d3js.org
s:https://github.com/d3/d3-scale
P:#1f77b4,#ff7f0e,#2ca02c,#d62728,#9467bd,#8c564b,#e377c2,#7f7f7f,#bcbd22,#17becf
* {smcl}
* {title:d3 20}{asis}
n:d3 20
c:qualitative
d:categorical colors from d3js.org
s:https://github.com/d3/d3-scale
P:#1f77b4,#aec7e8,#ff7f0e,#ffbb78,#2ca02c,#98df8a,#d62728,#ff9896,#9467bd,#c5b0d5,#8c564b,#c49c94,#e377c2,#f7b6d2,#7f7f7f,#c7c7c7,#bcbd22,#dbdb8d,#17becf,#9edae5
* {smcl}
* {title:d3 20b}{asis}
n:d3 20b
c:qualitative
d:categorical colors from d3js.org
s:https://github.com/d3/d3-scale
P:#393b79,#5254a3,#6b6ecf,#9c9ede,#637939,#8ca252,#b5cf6b,#cedb9c,#8c6d31,#bd9e39,#e7ba52,#e7cb94,#843c39,#ad494a,#d6616b,#e7969c,#7b4173,#a55194,#ce6dbd,#de9ed6
* {smcl}
* {title:d3 20c}{asis}
n:d3 20c
c:qualitative
d:categorical colors from d3js.org
s:https://github.com/d3/d3-scale
P:#3182bd,#6baed6,#9ecae1,#c6dbef,#e6550d,#fd8d3c,#fdae6b,#fdd0a2,#31a354,#74c476,#a1d99b,#c7e9c0,#756bb1,#9e9ac8,#bcbddc,#dadaeb,#636363,#969696,#bdbdbd,#d9d9d9
* {smcl}
* {title:lin carcolor}{asis}
n:lin carcolor
c:qualitative
d:Turkers-selected car colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:214 39 40,199 199 199,127 127 127,44 160 44,140 86 75,31 119 180
N:Red,Silver,Black,Green,Brown,Blue
* {smcl}
* {title:lin carcolor algorithm}{asis}
n:lin carcolor algorithm
c:qualitative
d:algorithm-selected car colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:214 39 40,199 199 199,127 127 127,44 160 44,140 86 75,31 119 180
N:Red,Silver,Black,Green,Brown,Blue
* {smcl}
* {title:lin food}{asis}
n:lin food
c:qualitative
d:Turkers-selected food colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:199 199 199,31 119 180,140 86 75,152 223 138,219 219 141,196 156 148,214 39 40
N:Sour cream,Blue cheese dressing,Porterhouse steak,Iceberg lettuce,Onions (raw),Potato (baked),Tomato
* {smcl}
* {title:lin food algorithm}{asis}
n:lin food algorithm
c:qualitative
d:algorithm-selected food colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:31 119 180,255 127 14,140 86 75,44 160 44,255 187 120,219 219 141,214 39 40
N:Sour cream,Blue cheese dressing,Porterhouse steak,Iceberg lettuce,Onions (raw),Potato (baked),Tomato
* {smcl}
* {title:lin features}{asis}
n:lin features
c:qualitative
d:Turkers-selected feature colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:214 39 40,31 119 180,174 119 232,44 160 44,152 223 138
N:Speed,Reliability,Comfort,Safety,Efficiency
* {smcl}
* {title:lin features algorithm}{asis}
n:lin features algorithm
c:qualitative
d:algorithm-selected feature colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:214 39 40,31 119 180,140 86 75,255 127 14,44 160 44
N:Speed,Reliability,Comfort,Safety,Efficiency
* {smcl}
* {title:lin activities}{asis}
n:lin activities
c:qualitative
d:Turkers-selected activity colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:31 119 180,214 39 40,152 223 138,44 160 44,127 127 127
N:Sleeping,Working,Leisure,Eating,Driving
* {smcl}
* {title:lin activities algorithm}{asis}
n:lin activities algorithm
c:qualitative
d:algorithm-selected activity colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:140 86 75,255 127 14,31 119 180,227 119 194,214 39 40
N:Sleeping,Working,Leisure,Eating,Driving
* {smcl}
* {title:lin fruits}{asis}
n:lin fruits
c:qualitative
d:expert-selected fruit colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:146 195 51,251 222 6,64 105 166,200 0 0,127 34 147,251 162 127,255 86 29
N:Apple,Banana,Blueberry,Cherry,Grape,Peach,Tangerine
* {smcl}
* {title:lin fruits algorithm}{asis}
n:lin fruits algorithm
c:qualitative
d:algorithm-selected fruit colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:44 160 44,188 189 34,31 119 180,214 39 40,148 103 189,255 187 120,255 127 14
N:Apple,Banana,Blueberry,Cherry,Grape,Peach,Tangerine
* {smcl}
* {title:lin vegetables}{asis}
n:lin vegetables
c:qualitative
d:expert-selected vegetable colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:255 141 61,157 212 105,245 208 64,104 59 101,239 197 143,139 129 57,255 26 34
N:Carrot,Celery,Corn,Eggplant,Mushroom,Olive,Tomato
* {smcl}
* {title:lin vegetables algorithm}{asis}
n:lin vegetables algorithm
c:qualitative
d:algorithm-selected vegetable colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:255 127 14,44 160 44,188 189 34,148 103 189,140 86 75,152 223 138,214 39 40
N:Carrot,Celery,Corn,Eggplant,Mushroom,Olive,Tomato
* {smcl}
* {title:lin drinks}{asis}
n:lin drinks
c:qualitative
d:expert-selected drinks colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:119 67 6,254 0 0,151 37 63,1 106 171,1 159 76,254 115 20,104 105 169
N:A&W Root Beer,Coca-Cola,Dr. Pepper,Pepsi,Sprite,Sunkist,Welch's Grape
* {smcl}
* {title:lin drinks algorithm}{asis}
n:lin drinks algorithm
c:qualitative
d:algorithm-selected drinks colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:140 86 75,214 39 40,227 119 194,31 119 180,44 160 44,255 127 14,148 103 189
N:A&W Root Beer,Coca-Cola,Dr. Pepper,Pepsi,Sprite,Sunkist,Welch's Grape
* {smcl}
* {title:lin brands}{asis}
n:lin brands
c:qualitative
d:expert-selected brands colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:161 165 169,44 163 218,242 99 33,255 183 0,0 112 66,204 0 0,123 0 153
N:Apple,AT&T,Home Depot,Kodak,Starbucks,Target,Yahoo!
* {smcl}
* {title:lin brands algorithm}{asis}
n:lin brands algorithm
c:qualitative
d:algorithm-selected brands colors by Lin et al. (2013)
s:brewextra.ado from https://ideas.repec.org/c/boc/bocode/s458050.html
P:152 223 138,31 119 180,255 127 14,140 86 75,44 160 44,214 39 40,148 103 189
N:Apple,AT&T,Home Depot,Kodak,Starbucks,Target,Yahoo!
* {smcl}
* {title:spmap heat}{asis}
n:spmap heat
c:sequential
d:heat color scheme from the spmap package by Pisati (2007)
s:spmap_color.ado from https://ideas.repec.org/c/boc/bocode/s456812.html
P2:255 255 0,255 0 0
P3:255 255 0,255 128 0,255 0 0
P4:255 255 128,255 255 0,255 128 0,255 0 0
P5:255 255 128,255 255 0,255 170 0,255 85 0,255 0 0
P6:255 255 128,255 255 0,255 191 0,255 128 0,255 64 0,255 0 0
P7:255 255 128,255 255 0,255 204 0,255 153 0,255 102 0,255 51 0,255 0 0
P8:255 255 191,255 255 64,255 255 0,255 204 0,255 153 0,255 102 0,255 51 0,255 0 0
P9:255 255 191,255 255 64,255 255 0,255 213 0,255 170 0,255 128 0,255 85 0,255 42 0,255 0 0
P10:255 255 191,255 255 64,255 255 0,255 219 0,255 182 0,255 146 0,255 109 0,255 73 0,255 36 0,255 0 0
P11:255 255 191,255 255 64,255 255 0,255 223 0,255 191 0,255 159 0,255 128 0,255 96 0,255 64 0,255 32 0,255 0 0
P12:255 255 213,255 255 128,255 255 42,255 255 0,255 223 0,255 191 0,255 159 0,255 128 0,255 96 0,255 64 0,255 32 0,255 0 0
P13:255 255 213,255 255 128,255 255 42,255 255 0,255 227 0,255 198 0,255 170 0,255 142 0,255 113 0,255 85 0,255 57 0,255 28 0,255 0 0
P14:255 255 213,255 255 128,255 255 42,255 255 0,255 229 0,255 204 0,255 178 0,255 153 0,255 128 0,255 102 0,255 77 0,255 51 0,255 26 0,255 0 0
P15:255 255 213,255 255 128,255 255 42,255 255 0,255 232 0,255 209 0,255 185 0,255 162 0,255 139 0,255 116 0,255 93 0,255 70 0,255 46 0,255 23 0,255 0 0
P16:255 255 223,255 255 159,255 255 96,255 255 32,255 255 0,255 232 0,255 209 0,255 185 0,255 162 0,255 139 0,255 116 0,255 93 0,255 70 0,255 46 0,255 23 0,255 0 0
* {smcl}
* {title:spmap terrain}{asis}
n:spmap terrain
c:sequential
d:terrain color scheme from the spmap package by Pisati (2007)
s:spmap_color.ado from https://ideas.repec.org/c/boc/bocode/s456812.html
P2:0 166 0,242 242 242
P3:0 166 0,236 177 118,242 242 242
P4:0 166 0,230 230 0,236 177 118,242 242 242
P5:0 166 0,230 230 0,234 182 78,238 185 159,242 242 242
P6:0 166 0,99 198 0,230 230 0,234 182 78,238 185 159,242 242 242
P7:0 166 0,99 198 0,230 230 0,233 189 58,236 177 118,239 194 179,242 242 242
P8:0 166 0,62 187 0,139 208 0,230 230 0,233 189 58,236 177 118,239 194 179,242 242 242
P9:0 166 0,62 187 0,139 208 0,230 230 0,232 195 46,235 178 94,237 180 142,240 201 192,242 242 242
P10:0 166 0,45 182 0,99 198 0,160 214 0,230 230 0,232 195 46,235 178 94,237 180 142,240 201 192,242 242 242
P11:0 166 0,45 182 0,99 198 0,160 214 0,230 230 0,232 199 39,234 182 78,236 177 118,238 185 159,240 207 200,242 242 242
P12:0 166 0,36 179 0,76 191 0,122 204 0,173 217 0,230 230 0,232 199 39,234 182 78,236 177 118,238 185 159,240 207 200,242 242 242
P13:0 166 0,36 179 0,76 191 0,122 204 0,173 217 0,230 230 0,231 203 33,233 186 67,235 177 101,237 179 135,239 190 170,240 211 206,242 242 242
P14:0 166 0,29 176 0,62 187 0,99 198 0,139 208 0,182 219 0,230 230 0,231 203 33,233 186 67,235 177 101,237 179 135,239 190 170,240 211 206,242 242 242
P15:0 166 0,29 176 0,62 187 0,99 198 0,139 208 0,182 219 0,230 230 0,231 206 29,233 189 58,234 179 88,236 177 118,237 182 148,239 194 179,241 214 211,242 242 242
P16:0 166 0,25 175 0,53 184 0,83 193 0,116 202 0,151 211 0,189 220 0,230 230 0,231 206 29,233 189 58,234 179 88,236 177 118,237 182 148,239 194 179,241 214 211,242 242 242
* {smcl}
* {title:spmap topological}{asis}
n:spmap topological
c:sequential
d:topological color scheme from the spmap package by Pisati (2007)
s:spmap_color.ado from https://ideas.repec.org/c/boc/bocode/s456812.html
P2:76 0 255,0 229 255
P3:76 0 255,0 255 77,255 255 0
P4:76 0 255,0 229 255,0 255 77,255 255 0
P5:76 0 255,0 76 255,0 229 255,0 255 77,255 255 0
P6:76 0 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178
P7:76 0 255,0 76 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178
P8:76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,230 255 0,255 255 0,255 224 178
P9:76 0 255,0 76 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178
P10:76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178
P11:76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,77 255 0,230 255 0,255 255 0,255 222 89,255 224 178
P12:76 0 255,0 25 255,0 128 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178
P13:76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178
P14:76 0 255,15 0 255,0 46 255,0 107 255,0 168 255,0 229 255,0 255 77,26 255 0,128 255 0,230 255 0,255 255 0,255 229 59,255 219 119,255 224 178
P15:76 0 255,0 0 255,0 76 255,0 153 255,0 229 255,0 255 77,0 255 0,77 255 0,153 255 0,230 255 0,255 255 0,255 234 45,255 222 89,255 219 134,255 224 178
P16:76 0 255,15 0 255,0 46 255,0 107 255,0 168 255,0 229 255,0 255 77,0 255 0,77 255 0,153 255 0,230 255 0,255 255 0,255 234 45,255 222 89,255 219 134,255 224 178
* {smcl}
* {title:sfso blue}{asis}
n:sfso blue
c:sequential
d:dark blue to light blue color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#1c3259,#374a83,#6473aa,#8497cf,#afbce2,#d8def2,#e8eaf7
N:,,,BFS-Blau,,,BFS-Blau 20%
n:sfso blue cmyk
c:sequential
d:CMYK variant of dark blue to light blue color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.83 .45 0 .7,.85 .55 0 .4,.7 .45 0 .2,.63 .36 0 0,.43 .22 0 0,.22 .1 0 0,.13 .07 0 0
N:,,,BFS-Blau,,,BFS-Blau 20%
* {smcl}
* {title:sfso brown}{asis}
n:sfso brown
c:sequential
d:dark brown to light brown color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#6b0616,#a1534e,#b67d6c,#cca58f,#ddc3a8,#eee3cd
n:sfso brown cmyk
c:sequential
d:CMYK variant of dark brown to light brown color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:0 1 .7 .6,0 .74 .57 .32,0 .56 .5 .24,0 .4 .4 .16,0 .27 .35 .1,0 .12 .22 .05
* {smcl}
* {title:sfso orange}{asis}
n:sfso orange
c:sequential
d:dark orange to light orange color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#92490d,#ce6725,#d68c25,#e2b224,#eccf76,#f6e7be
n:sfso orange cmyk
c:sequential
d:CMYK variant of dark orange to light orange color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:0 .75 1 .4,0 .75 1 0,0 .59 1 0,0 .4 1 0,0 .26 .68 0,0 .13 .35 0
* {smcl}
* {title:sfso red}{asis}
n:sfso red
c:sequential
d:dark red to light red color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#6d0724,#a61346,#c62a4f,#d17477,#dea49f,#efd6d1
n:sfso red cmyk
c:sequential
d:CMYK variant of dark red to light red color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.1 1 .6 .55,.1 1 .6 .15,0 .95 .64 0,0 .71 .48 0,0 .5 .34 0,0 .25 .16 0
* {smcl}
* {title:sfso pink}{asis}
n:sfso pink
c:sequential
d:dark pink to light pink color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#7c0051,#a4006f,#c0007c,#cc669d,#da9dbf,#efd7e5
n:sfso pink cmyk
c:sequential
d:CMYK variant of dark pink to light pink color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.12 1 .12 .45,.09 1 .09 .18,0 1 .09 .04,0 .75 .07 .03,0 .53 .04 .02,0 .25 .02 0
* {smcl}
* {title:sfso purple}{asis}
n:sfso purple
c:sequential
d:dark purple to light purple color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#5e0059,#890883,#a23392,#bf64a6,#d79dc5,#efd7e8
n:sfso purple cmyk
c:sequential
d:CMYK variant of dark purple to light purple color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.45 1 0 .45,.45 1 0 .05,.32 .9 0 0,.15 .75 0 0,.05 .53 0 0,0 .25 0 0
* {smcl}
* {title:sfso violet}{asis}
n:sfso violet
c:sequential
d:dark violet to light violet color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#3a0054,#682b86,#8c58a3,#a886bc,#c5b0d5,#e1d7eb
n:sfso violet cmyk
c:sequential
d:CMYK variant of dark violet to light violet color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.75 1 0 .5,.65 .9 0 .12,.51 .75 0 0,.38 .56 0 0,.25 .38 0 0,.12 .2 0 0
* {smcl}
* {title:sfso ltblue}{asis}
n:sfso ltblue
c:sequential
d:lighter version of blue color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#076e8d,#1b9dc9,#76b8da,#abd0e7,#c8e0f2,#edf5fd
n:sfso ltblue cmyk
c:sequential
d:CMYK variant of lighter version of blue color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.98 0 .14 .45,.98 0 .14 .05,.72 0 .1 .03,.49 0 .07 .02,.35 0 .04 0,.12 0 0 0
* {smcl}
* {title:sfso turquoise}{asis}
n:sfso turquoise
c:sequential
d:dark turquoise to light turquoise color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#005046,#107a6d,#3aa59a,#95c6c3,#cbe1df,#e9f2f5
n:sfso turquoise cmyk
c:sequential
d:CMYK variant of dark turquoise to light turquoise color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:1 0 .55 .65,1 0 .55 .35,.94 0 .5 0,.6 0 .3 0,.33 0 .17 0,.15 0 .05 0
* {smcl}
* {title:sfso green}{asis}
n:sfso green
c:sequential
d:dark green to light green color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#3b6519,#68a239,#95c15b,#b3d17f,#d3e3af,#ecf2d1
n:sfso green cmyk
c:sequential
d:CMYK variant of dark green to light green color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.75 0 1 .6,.75 0 1 .15,.6 0 .85 0,.45 0 .68 0,.28 0 .45 0,.12 0 .28 0
* {smcl}
* {title:sfso olive}{asis}
n:sfso olive
c:sequential
d:dark olive to light olive color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#6f6f02,#a3a20a,#c5c00c,#e3df86,#eeecbc,#fefde6
n:sfso olive cmyk
c:sequential
d:CMYK variant of dark olive to light olive color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.05 0 1 .7,.05 0 1 .45,0 0 1 .3,0 0 .6 .15,0 0 .35 .09,0 0 .17 0
* {smcl}
* {title:sfso black}{asis}
n:sfso black
c:sequential
d:dark gray to light gray color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#3f3f3e,#838382,#b2b3b3,#d4d5d5,#e6e6e7,#f7f7f7
n:sfso black cmyk
c:sequential
d:CMYK variant of dark gray to light gray color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:0 0 0 .9,0 0 0 .65,0 0 0 .43,0 0 0 .25,0 0 0 .15,0 0 0 .05
* {smcl}
* {title:sfso parties}{asis}
n:sfso parties
c:qualitative
d:Swiss parties color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#6268af,#f39f5e,#ea546f,#547d34,#cbd401,#ffff00,#26b300,#792a8f,#9fabd9,#f0da9d,#bebebe
N:FDP,CVP,SP,SVP,GLP,BDP,Grüne,small leftwing parties,small middle parties,small rightwing parties,other parties
n:sfso parties cmyk
c:qualitative
d:CMYK variant of Swiss parties color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.76 .6 .02 0,0 .57 .78 0,0 .85 .58 0,.8 .3 1 .2,.28 .01 .96 0,.01 0 .96 0,.72 0 1 0,.6 .92 0 0,.5 .29 0 0,0 .2 .5 0,0 0 0 .35
N:FDP,CVP,SP,SVP,GLP,BDP,Grüne,small leftwing parties,small middle parties,small rightwing parties,other parties
* {smcl}
* {title:sfso languages}{asis}
n:sfso languages
c:qualitative
d:Swiss language region color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#c73e31,#4570ba,#4ca767,#ecce42,#7f5fa9
N:German,French,Italian,Rhaeto-Romanic,English
n:sfso languages cmyk
c:qualitative
d:CMYK variant of Swiss language region color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:0 .9 .9 0,.9 .5 0 0,.9 0 .8 0,0 .25 .9 0,.6 .7 0 0
N:German,French,Italian,Rhaeto-Romanic,English
* {smcl}
* {title:sfso votes}{asis}
n:sfso votes
c:diverging
d:vote share color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:#6d2a83,#6d2a83*.8,#6d2a83*.6,#6d2a83*.4,#6d2a83*.2,#45974d*.2,#45974d*.4,#45974d*.6,#45974d*.8,#45974d
N:No,,,,,,,,,Yes
n:sfso votes cmyk
c:diverging
d:CMYK variant of vote share color scheme by the Swiss Federal Statistical Office
s:Bundesamt für Statistik 2017. Layoutrichtlinien. Gestaltungs und Redaktionsrichtlinien für Publikationen, Tabellen und grafische Assets. Version 1.1.1. Neuchâtel
P:.6 .9 0 .15,.6 .9 0 .15*.8,.6 .9 0 .15*.6,.6 .9 0 .15*.4,.6 .9 0 .15*.2,.9 0 .9 .15*.2,.9 0 .9 .15*.4,.9 0 .9 .15*.6,.9 0 .9 .15*.8,.9 0 .9 .15
N:No,,,,,,,,,Yes
* {smcl}
* {title:w3 amber}{asis}
n:w3 amber
c:sequential
d:Color Theme Amber from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-amber.css
P:#fffbf0,#fff3cd,#ffe69b,#ffda69,#ffcd37,#ffc107,#eab000,#d09c00,#b68900,#9c7500,#826200
N:w3-amber-l5,w3-amber-l4,w3-amber-l3,w3-amber-l2,w3-amber-l1,w3-amber,w3-amber-d1,w3-amber-d2,w3-amber-d3,w3-amber-d4,w3-amber-d5
* {smcl}
* {title:w3 black}{asis}
n:w3 black
c:sequential
d:Color Theme Black from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-black.css
P:#f0f0f0,#cccccc,#999999,#666666,#333333,#000000,#000000,#000000,#000000,#000000,#000000
N:w3-black-l5,w3-black-l4,w3-black-l3,w3-black-l2,w3-black-l1,w3-black,w3-black-d1,w3-black-d2,w3-black-d3,w3-black-d4,w3-black-d5
* {smcl}
* {title:w3 blue}{asis}
n:w3 blue
c:sequential
d:Color Theme Blue from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-blue.css
P:#f2f9fe,#d2eafd,#a6d4fa,#79bff8,#4daaf6,#2196f3,#0c87eb,#0b78d1,#0a69b7,#085a9d,#074b83
N:w3-blue-l5,w3-blue-l4,w3-blue-l3,w3-blue-l2,w3-blue-l1,w3-blue,w3-blue-d1,w3-blue-d2,w3-blue-d3,w3-blue-d4,w3-blue-d5
* {smcl}
* {title:w3 blue-grey}{asis}
n:w3 blue-grey
c:sequential
d:Color Theme Blue Grey from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-blue-grey.css
P:#f5f7f8,#dfe5e8,#becbd2,#9eb1bb,#7d97a5,#607d8b,#57707d,#4d636f,#435761,#3a4b53,#303e45
N:w3-blue-grey-l5,w3-blue-grey-l4,w3-blue-grey-l3,w3-blue-grey-l2,w3-blue-grey-l1,w3-blue-grey,w3-blue-grey-d1,w3-blue-grey-d2,w3-blue-grey-d3,w3-blue-grey-d4,w3-blue-grey-d5
* {smcl}
* {title:w3 brown}{asis}
n:w3 brown
c:sequential
d:Color Theme Brown from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-brown.css
P:#f8f4f3,#e7dcd7,#d0b8b0,#b89588,#a07261,#795548,#6d4d41,#61443a,#553c33,#49332c,#3d2b24
N:w3-brown-l5,w3-brown-l4,w3-brown-l3,w3-brown-l2,w3-brown-l1,w3-brown,w3-brown-d1,w3-brown-d2,w3-brown-d3,w3-brown-d4,w3-brown-d5
* {smcl}
* {title:w3 cyan}{asis}
n:w3 cyan
c:sequential
d:Color Theme Cyan from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-cyan.css
P:#edfdff,#c4f8ff,#89f1ff,#4eeaff,#12e3ff,#00bcd4,#00aac1,#0097ab,#008496,#007281,#005f6b
N:w3-cyan-l5,w3-cyan-l4,w3-cyan-l3,w3-cyan-l2,w3-cyan-l1,w3-cyan,w3-cyan-d1,w3-cyan-d2,w3-cyan-d3,w3-cyan-d4,w3-cyan-d5
* {smcl}
* {title:w3 dark-grey}{asis}
n:w3 dark-grey
c:sequential
d:Color Theme Dark Grey from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-dark-grey.css
P:#f6f6f6,#dfdfdf,#c0c0c0,#a0a0a0,#818181,#616161,#575757,#4e4e4e,#444444,#3a3a3a,#303030
N:w3-dark-grey-l5,w3-dark-grey-l4,w3-dark-grey-l3,w3-dark-grey-l2,w3-dark-grey-l1,w3-dark-grey,w3-dark-grey-d1,w3-dark-grey-d2,w3-dark-grey-d3,w3-dark-grey-d4,w3-dark-grey-d5
* {smcl}
* {title:w3 deep-orange}{asis}
n:w3 deep-orange
c:sequential
d:Color Theme Deep Orange from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-deep-orange.css
P:#fff5f2,#ffddd3,#ffbca7,#ff9a7b,#ff7850,#ff5722,#ff4107,#e93600,#cb2f00,#ae2900,#912200
N:w3-deep-orange-l5,w3-deep-orange-l4,w3-deep-orange-l3,w3-deep-orange-l2,w3-deep-orange-l1,w3-deep-orange,w3-deep-orange-d1,w3-deep-orange-d2,w3-deep-orange-d3,w3-deep-orange-d4,w3-deep-orange-d5
* {smcl}
* {title:w3 deep-purple}{asis}
n:w3 deep-purple
c:sequential
d:Color Theme Deep Purple from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-deep-purple.css
P:#f6f3fb,#e0d6f2,#c1ade5,#a384d8,#845bcb,#673ab7,#5d34a4,#532e92,#482880,#3e236d,#341d5b
N:w3-deep-purple-l5,w3-deep-purple-l4,w3-deep-purple-l3,w3-deep-purple-l2,w3-deep-purple-l1,w3-deep-purple,w3-deep-purple-d1,w3-deep-purple-d2,w3-deep-purple-d3,w3-deep-purple-d4,w3-deep-purple-d5
* {smcl}
* {title:w3 green}{asis}
n:w3 green
c:sequential
d:Color Theme Green from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-green.css
P:#f4faf4,#dbefdc,#b7dfb8,#93cf95,#6ec071,#4caf50,#459c48,#3d8b40,#357a38,#2e6830,#265728
N:w3-green-l5,w3-green-l4,w3-green-l3,w3-green-l2,w3-green-l1,w3-green,w3-green-d1,w3-green-d2,w3-green-d3,w3-green-d4,w3-green-d5
* {smcl}
* {title:w3 grey}{asis}
n:w3 grey
c:sequential
d:Color Theme Grey from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-grey.css
P:#f9f9f9,#ececec,#d8d8d8,#c5c5c5,#b1b1b1,#9e9e9e,#8e8e8e,#7e7e7e,#6f6f6f,#5f5f5f,#4f4f4f
N:w3-grey-l5,w3-grey-l4,w3-grey-l3,w3-grey-l2,w3-grey-l1,w3-grey,w3-grey-d1,w3-grey-d2,w3-grey-d3,w3-grey-d4,w3-grey-d5
* {smcl}
* {title:w3 indigo}{asis}
n:w3 indigo
c:sequential
d:Color Theme Indigo from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-indigo.css
P:#f3f4fb,#d8dcf1,#b1b8e3,#8995d6,#6271c8,#3f51b5,#3949a3,#334191,#2d397f,#26316d,#20295b
N:w3-indigo-l5,w3-indigo-l4,w3-indigo-l3,w3-indigo-l2,w3-indigo-l1,w3-indigo,w3-indigo-d1,w3-indigo-d2,w3-indigo-d3,w3-indigo-d4,w3-indigo-d5
* {smcl}
* {title:w3 khaki}{asis}
n:w3 khaki
c:sequential
d:Color Theme Khaki from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-khaki.css
P:#fefef8,#fcfae8,#f9f5d2,#f6f0bb,#f3eba5,#f0e68c,#ecdf6c,#e8d84a,#e3d029,#cbb91a,#a99b16
N:w3-khaki-l5,w3-khaki-l4,w3-khaki-l3,w3-khaki-l2,w3-khaki-l1,w3-khaki,w3-khaki-d1,w3-khaki-d2,w3-khaki-d3,w3-khaki-d4,w3-khaki-d5
* {smcl}
* {title:w3 light-blue}{asis}
n:w3 light-blue
c:sequential
d:Color Theme Light Blue from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-light-blue.css
P:#f8fcfe,#e7f5fb,#d0ecf7,#b8e2f3,#a1d9ef,#87ceeb,#69c2e6,#4ab6e0,#2aa9db,#2092bf,#1b7a9f
N:w3-light-blue-l5,w3-light-blue-l4,w3-light-blue-l3,w3-light-blue-l2,w3-light-blue-l1,w3-light-blue,w3-light-blue-d1,w3-light-blue-d2,w3-light-blue-d3,w3-light-blue-d4,w3-light-blue-d5
* {smcl}
* {title:w3 light-green}{asis}
n:w3 light-green
c:sequential
d:Color Theme Light Green from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-light-green.css
P:#f8fbf4,#e8f3db,#d1e7b7,#b9db93,#a2cf6f,#8bc34a,#7eb63d,#70a236,#628e2f,#547a29,#466522
N:w3-light-green-l5,w3-light-green-l4,w3-light-green-l3,w3-light-green-l2,w3-light-green-l1,w3-light-green,w3-light-green-d1,w3-light-green-d2,w3-light-green-d3,w3-light-green-d4,w3-light-green-d5
* {smcl}
* {title:w3 lime}{asis}
n:w3 lime
c:sequential
d:Color Theme Lime from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-lime.css
P:#fcfdf3,#f5f8d7,#eaf1af,#e0ea87,#d6e35f,#cddc39,#c1d325,#acbb21,#96a41d,#818c19,#6b7515
N:w3-lime-l5,w3-lime-l4,w3-lime-l3,w3-lime-l2,w3-lime-l1,w3-lime,w3-lime-d1,w3-lime-d2,w3-lime-d3,w3-lime-d4,w3-lime-d5
* {smcl}
* {title:w3 orange}{asis}
n:w3 orange
c:sequential
d:Color Theme Orange from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-orange.css
P:#fff9f0,#ffebcc,#ffd699,#ffc266,#ffad33,#ff9800,#e68a00,#cc7a00,#b36b00,#995c00,#804d00
N:w3-orange-l5,w3-orange-l4,w3-orange-l3,w3-orange-l2,w3-orange-l1,w3-orange,w3-orange-d1,w3-orange-d2,w3-orange-d3,w3-orange-d4,w3-orange-d5
* {smcl}
* {title:w3 pink}{asis}
n:w3 pink
c:sequential
d:Color Theme Pink from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-pink.css
P:#fef2f6,#fbd2e0,#f6a6c1,#f279a1,#ed4d82,#e91e63,#d91557,#c1134d,#a91143,#910e3a,#790c30
N:w3-pink-l5,w3-pink-l4,w3-pink-l3,w3-pink-l2,w3-pink-l1,w3-pink,w3-pink-d1,w3-pink-d2,w3-pink-d3,w3-pink-d4,w3-pink-d5
* {smcl}
* {title:w3 purple}{asis}
n:w3 purple
c:sequential
d:Color Theme Purple from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-purple.css
P:#faf0fc,#efcef4,#de9eea,#ce6ddf,#be3dd4,#9c27b0,#8c239e,#7c1f8d,#6d1b7b,#5d1769,#4e1358
N:w3-purple-l5,w3-purple-l4,w3-purple-l3,w3-purple-l2,w3-purple-l1,w3-purple,w3-purple-d1,w3-purple-d2,w3-purple-d3,w3-purple-d4,w3-purple-d5
* {smcl}
* {title:w3 red}{asis}
n:w3 red
c:sequential
d:Color Theme Red from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-red.css
P:#fef4f3,#fdd9d6,#fbb3ae,#f98d85,#f6665c,#f44336,#f32617,#e11a0c,#c5170a,#a91409,#8d1007
N:w3-red-l5,w3-red-l4,w3-red-l3,w3-red-l2,w3-red-l1,w3-red,w3-red-d1,w3-red-d2,w3-red-d3,w3-red-d4,w3-red-d5
* {smcl}
* {title:w3 teal}{asis}
n:w3 teal
c:sequential
d:Color Theme Teal from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-teal.css
P:#e9fffd,#b7fff8,#6efff1,#26ffe9,#00dcc6,#009688,#008578,#00766a,#00685d,#005950,#004a43
N:w3-teal-l5,w3-teal-l4,w3-teal-l3,w3-teal-l2,w3-teal-l1,w3-teal,w3-teal-d1,w3-teal-d2,w3-teal-d3,w3-teal-d4,w3-teal-d5
* {smcl}
* {title:w3 yellow}{asis}
n:w3 yellow
c:sequential
d:Color Theme Yellow from www.w3schools.com/w3css/w3css_color_themes.asp
s:https://www.w3schools.com/lib/w3-theme-yellow.css
P:#fffef3,#fffbd8,#fff7b1,#fff38b,#ffef64,#ffeb3b,#ffe81e,#fde400,#ddc700,#beab00,#9e8e00
N:w3-yellow-l5,w3-yellow-l4,w3-yellow-l3,w3-yellow-l2,w3-yellow-l1,w3-yellow,w3-yellow-d1,w3-yellow-d2,w3-yellow-d3,w3-yellow-d4,w3-yellow-d5
