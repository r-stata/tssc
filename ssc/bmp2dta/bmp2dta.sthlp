{smcl}
{* 14jul2017}{...}
{hline}
help for {hi:bmp2dta}
{hline}

{title:Module for converting bitmap files to Stata datasets}

{title:Syntax}

{p 6 16 2}
{cmd:bmp2dta} {cmd:using} {it:filename}, {cmdab:p:icture(}{it:filename}{cmd:)} [ {cmd:stub(}{it:string}{cmd:)} replace]{p_end}

{marker description}{dlgtab:Description}

{p}Since the advent of satellite imagery, researchers have turned images into data and processed it. This program makes the first step easier in Stata,
by turning a Windows 24-bit bitmap file into a Stata dataset with variables i and j (row and column of each pixel), r (red), g (green), and b (blue) on a scale of 0 to 255.{p_end}

{p}Examples of uses for satellite images include projecting fishing productivity (Kemmerer et al. 1976), estimating economic
growth (Henderson, Storeygard, and Weil 2012), and predicting poverty rates (Jean et al. 2016).{p_end}

{p}Techniques for processing, filtering, or otherwise manipulating image data can also be used on any photograph.{p_end}

{marker examples}{dlgtab:Examples}

{hline}
{p}You will need to get the image files referred to below in order to use them in the following examples.{p_end}

{p 6 16 2}{stata "net describe bmp2dta, from(http://fmwww.bc.edu/RePEc/bocode/b)": net describe bmp2dta, from(http://fmwww.bc.edu/RePEc/bocode/b)}{p_end}
{p 6 16 2}{stata "net get bmp2dta": net get bmp2dta}{p_end}

{hline}
{p 6 16 2}{stata "bmp2dta using bmore, pic(bm500.bmp)": bmp2dta using bmore, pic(bm500.bmp)}{p_end}
{p 6 16 2}u bmore, clear{p_end}
{p 6 16 2}sc i j if r<39&g<39&b<39, m(S) mcol(edkblue)msize(small) m(S) xsize(5) ysize(5) yla(1/200 ,nogrid) xsc(off) ysc(off) leg(off) xla(1/200) graphr(fc(white) margin(zero) lw(none)) plotr(margin(zero)) scale(.3){p_end}
{p 6 16 2}forv i=1/3 {{p_end}
{p 8 16 2}su r if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`=round(r(mean))'" {p_end}
{p 8 16 2}su g if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`c`i'' `=round(r(mean))'" {p_end}
{p 8 16 2}su b if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`c`i'' `=round(r(mean))'" {p_end}
{p 8 16 2}}{p_end}
{p 6 16 2}sc i j if c==1, msize(small) m(S) mcol("`c1'")||sc i j if c==2, msize(small) m(S) mcol("`c2'%40")||sc i j if c==3, msize(vtiny) m(S) mcol("`c3'%20") xsize(5) ysize(5) yla(1/200 ,nogrid) xsc(off) ysc(off) leg(off) xla(1/200) graphr(fc(white) margin(zero) lw(none)) plotr(margin(zero)) scale(.2) {p_end}

{hline}
{p 6 16 2}{stata "bmp2dta using dc276, pic(bmdc276.bmp)": bmp2dta using dc276, pic(bmdc276.bmp)}{p_end}
{p 6 16 2}u dc276, clear{p_end}
{p 6 16 2}cluster kmeans r g b, k(3) gen(c){p_end}
{p 6 16 2}forv i=1/3 {{p_end}
{p 8 16 2}su r if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`=round(r(mean))'" {p_end}
{p 8 16 2}su g if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`c`i'' `=round(r(mean))'" {p_end}
{p 8 16 2}su b if c==`i', mean{p_end}
{p 8 16 2}loc c`i' "`c`i'' `=round(r(mean))'" {p_end}
{p 8 16 2}}{p_end}
{p 6 16 2}sc i j if c==1, msize(small) m(S) mcol("`c1'")||sc i j if c==2, msize(small) m(S) mcol("`c2'%40")||sc i j if c==3, msize(vtiny) m(S) mcol("`c3'%20")||sc i j if c==4, msize(vtiny) m(S) mcol("`c4'%20")  xsize(5) ysize(5) yla(1/200 ,nogrid) xsc(off) ysc(off) leg(off) xla(1/200) graphr(fc(white) margin(zero) lw(none)) plotr(margin(zero)) scale(.2)   {p_end}

{hline}
{p 6 16 2}{stata "bmp2dta using putin, pic(bmputin.bmp)": bmp2dta using putin, pic(bmputin.bmp)}{p_end}
{p 6 16 2}u putin, clear{p_end}
{p 6 16 2}loc i 1{p_end}
{p 6 16 2}foreach c in "29 82 97" "86 151 163" "245 255 201" "161 30 34" "97 10 29" {{p_end}
{p 6 16 2}g d`i'=(r-real(word("`c'",1)))^2+(g-real(word("`c'",2)))^2+(g-real(word("`c'",3)))^2{p_end}
{p 6 16 2}loc i=`i'+1{p_end}
{p 6 16 2}}{p_end}
{p 6 16 2}g color=1 if d1==min(d1,d2,d3,d4,d5){p_end}
{p 6 16 2}qui forv i=2/5 {{p_end}
{p 6 16 2} replace color=`i' if d`i'==min(d1,d2,d3,d4,d5){p_end}
{p 6 16 2} }{p_end}
{p 6 16 2}keep if inrange(j,250,1600){p_end}
{p 6 16 2}sc i j if color==2, msize(vtiny) m(S) mcol("86 151 163")||sc i j if color==1, msize(vtiny) m(S) mcol("29 82 97")||sc i j if color==3, msize(vtiny) m(S) mcol("245 255 201")||sc i j if color==4, msize(vtiny) m(S) mcol("161 30 34")||sc i j if color==5, msize(vtiny) m(S) mcol("97 10 29") xsize(5) ysize(4) yla(1/500,nogrid) xsc(off) ysc(off) leg(off) xla(250/500) graphr(fc(white) margin(zero)){p_end}

{marker options}{dlgtab:Options summary}

{phang}
{cmdab:p:icture({it:filename})} specifies the picture file to be turned into a dataset.

{phang}
{cmd:stub({it:string})} specifies that variables i, j, r, g, and b in the {cmd:using} dataset should all be prefixed {string}.

{phang}
{opt replace} specifies that the {cmd:using} dataset may be overwritten.


{marker refs}{title:References}

{phang}Henderson, J. Vernon, Adam Storeygard, and David N. Weil. 2012. "Measuring Economic Growth from Outer Space." American Economic Review, 102(2): 994–1028.{p_end}

{phang}Jean, Neal, Marshall Burke, Michael Xie, W. Matthew Davis, David B. Lobell, and Stefano Ermon. 2016. "Combining satellite imagery and machine learning to predict poverty." Science, 353(6301): 790-4. {p_end}

{phang}Kemmerer, Andrew J., Kenneth J. Savastano, and Kenneth Faller. 1976. "LANDSAT Menhaden and Thread Herring Resources Investigation."  Slidell, Louisiana: NASA.{p_end}

{marker citation}{title:Citation of {cmd:bmp2dta}}

{p}{cmd:bmp2dta} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Nichols, Austin. 2007.
bmp2dta: Module for converting bitmap files to datasets.
{browse "http://ideas.repec.org/c/boc/bocode/s456890.html":http://ideas.repec.org/c/boc/bocode/s456890.html}{p_end}

{title:Author}

    Austin Nichols
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual: {help discrim} and {help cluster} commands}{p_end}

{p 1 10}On-line: help for (if installed) {help tddens}.
{p_end}
