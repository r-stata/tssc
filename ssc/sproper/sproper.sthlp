{smcl}
{* 25apr2012}{...}
{hline}
help for {hi:sproper}
{hline}

{title:Proper name case for foreign names in variables}

{title:Syntax}

{p 6 16 2}
{cmd:sproper} [{vars}] {ifin}
[{cmd:,} {cmdab:g:enerate(}{it:stubname}{cmd:)} {cmd:replace} {cmd:oe} ]

{p 6 16 2}
{cmd:supper} [{vars}] {ifin}
[{cmd:,} {cmdab:g:enerate(}{it:stubname}{cmd:)} {cmd:replace} {cmd:oe} ]

{p 6 16 2}
{cmd:slower} [{vars}] {ifin}
[{cmd:,} {cmdab:g:enerate(}{it:stubname}{cmd:)} {cmd:replace} {cmd:oe} ]

{marker description}{dlgtab:Description}

{p}The {help proper()}, {help upper()}, and {help lower()} string functions do not include foreign letters in their definition of letters, 
but {cmd:sproper}, {cmd:supper}, and {cmd:slower} will treat foreign names correctly if the ASCII encoding is
such that codes 065 to 090 map to A to Z (add 32 to get lowercase versions), codes 192 to 222 map to characters with diacritical marks 
(add 32 to get lowercase versions) as shown below in {help smcl##ascii:charset latin1 (ISO-8859-1)}.
The problem was posed by a
{browse "http://www.stata.com/statalist/archive/2012-04/msg01176.html":a question on Statalist}.
Note that this package operates on variables, as a program, not on strings, as would a function.  However, the Mata functions
included with the programs may be of use in other contexts. {help viewsource} the programs to see the Mata functions.{p_end}

{p}Option  {cmd:oe} adds to the definitions of letters by specifying that ASCII codes
138 (S hachek), 140 (OE), 142 (Z hachek), and 159 (Y double dot) are also letters with lowercase versions at 154, 156, 158, and 255 respectively 
(not officially part of {help smcl##ascii:charset} latin1, but represented on many Stata user's charsets).{p_end}

{hline}
{p 4 16 2}The natural way to display the 256-character latin1 (ISO-8859-1) character set is in a 16 by 16 hexadecimal grid, 0 to F in each dimension,
but skipping the first 32 reserved characters numbered 0 to 31, starting with the space character at position 0x20 (32 in hexadecimal):{p_end}

  0123456789ABCDEF
2  !"#$%&'()*+,-./
3 0123456789:;<=>?
4 @ABCDEFGHIJKLMNO
5 PQRSTUVWXYZ[\]^_
6 `abcdefghijklmno
7 pqrstuvwxyz{|}~
8 €‚ƒ„…†‡ˆ‰Š‹Œ
9 ‘’“”•–—˜™š›œŸ
A  ¡¢£¤¥¦§¨©ª«¬­®¯
B °±²³´µ¶·¸¹º»¼½¾¿
C ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏ
D ĞÑÒÓÔÕÖ×ØÙÚÛÜİŞß
E àáâãäåæçèéêëìíîï
F ğñòóôõö÷øùúûüışÿ

{p 4 16 2}Here you can see adding 16 as a displacement of one line from  to  () and adding 32 as a displacement of 2 lines from Ñ to ñ () 
 You can reproduce this mapping on your own Stata with this code:{p_end}

  forv i=2/15 {
   if `i'==2 di "  0123456789ABCDEF"
   if `i'<10 di %1.0f `i' " " _c
   if `i'>9 di in smcl "{c `=55+`i''} " _c
   forv j=0/15 {
    di in smcl "{c `=`i'*16+`j''}" _c
    }
   di
   }

{p 4 16 2}A less natural way but perhaps more intuitive to display the latin1 (ISO-8859-1) character set is in a 23 by 10 decimal grid, 0 to 9 in the x dimension,
again skipping the first 32 reserved characters, and starting with the space at position 32:

   0123456789
03    !"#$%&'
04 ()*+,-./01
05 23456789:;
06 <=>?@ABCDE
07 FGHIJKLMNO
08 PQRSTUVWXY
09 Z[\]^_`abc
10 defghijklm
11 nopqrstuvw
12 xyz{|}~€
13 ‚ƒ„…†‡ˆ‰Š‹
14 Œ‘’“”•
15 –—˜™š›œŸ
16  ¡¢£¤¥¦§¨©
17 ª«¬­®¯°±²³
18 ´µ¶·¸¹º»¼½
19 ¾¿ÀÁÂÃÄÅÆÇ
20 ÈÉÊËÌÍÎÏĞÑ
21 ÒÓÔÕÖ×ØÙÚÛ
22 ÜİŞßàáâãäå
23 æçèéêëìíîï
24 ğñòóôõö÷øù
25 úûüışÿ


{p 4 16 2}You can reproduce this table on your own system (to see any differences) with this code:{p_end}

  forv i=3/25 {
   if `i'==3 di "   0123456789"
   di %02.0f `i' _c
   loc s=cond(`i'==3,2,0)
   loc e=cond(`i'==25,5,9)
   forv j=0/`s' {
    di " " _c
    }
   forv j=`s'/`e' {
    di in smcl "{c `=`i'*10+`j''}" _c
    }
   di
   }


{hline}

{marker examples}{dlgtab:Example}

clear 
set charset latin1
set obs 5
g p="ZUÑIGA RODRÍGUEZ "+char(86)+char(85)+char(138)+char(159)+char(223)+char(142)+char(68)
list
replace p=proper(p)
list
sproper p in 1, replace
supper p in 2/3, replace
list
slower p in 3, replace
slower p in 4, replace oe
g t="sproper"
replace t="supper" in 2
replace t="slower" in 3
replace t="slower, oe" in 4
replace t="proper()" in 5
list


{marker options}{dlgtab:Options}

{phang}
{cmdab:g:enerate(}{it:stubname}{cmd:)} specifies a stubname, to prefix nealy created proper case versions of variables.

{phang}
{cmd:replace} specifies that variables should be overwritten by proper case versions.

{title:Author}

    Austin Nichols
    Urban Institute
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 10}On-line: help for {help set charset}, {browse "http://www.stata.com/support/faqs/unix/charset.html":FAQ on charset} {help proper()}, {help lower()}, {help upper()}, {help char()}, {help string functions}, {help [M-4] string}, {help asciiplot} (if installed; {stata "findit asciiplot":findit asciiplot} if not).
{p_end}
