{smcl}
{* *! version 1.0  11/11/2014 Adrian Sayers}{...}
{cmd:help nysiis}
{hline}

{title:Title}

{phang}
{cmd:nysiis} {hline 2} Calculate the nysiis phonetic code.


{title:Syntax}

{p 8 17 2}
{cmd:nysiis}
{varname:1}
[{cmd:,} {opth gen:erate(newvar)}  
{opt n:oisily}    ]


{title:Description}


{pstd}{cmd:nysiis} calculates the NYSIIS phonetic code of a string variable according to the algorithm described by Taft 1970. {p_end}

{pstd} There are number of different variants of the algorithm hosted on websites. However, the most complete description i have found is in:{p_end}
		"Data Quality and Record Linkage Techniques" Herzog T.N., Scheuren F.J., Winkler W.E. 2007 pg 119-121.
{pstd} I have never seen the originally described algorithm. The majority of the discrepancies between algorithms occur in the iterative process in step 5, see below.{p_end}

{pstd} The algorithm consists of 7 Steps. In the first step, the initial letter(s) of a surname are examined and altered as necessary. In the second step, the same is done for the last letter(s) of the surname. In Step 3, the first
letter of the NYSIIS coded surname is established. Steps 5 and 6 constitute an iterative procedure for creating the remaining letters of the NYSIIS-coded surname. In this iterative scheme, we begin with the second letter of the altered
surname and scan each letter of the remaining letters of the surname using an imaginary pointer. In Step 5, one or more of the letters of the coded surname are established via a set of rules. The rules are reapplied each time
the pointer is moved to the next letter of the name. In Step 7, the end portion of the NYSIIS code just created is subjected to a further check and changed as necessary.

{pstd} {cmd:nysiis} accepts one arguments, which must be a string variable. Cases are lowered within the algorithm. {p_end}

{pstd} The nysiis phoenetic code is returned as a new variable with default name {bf:nysiis}.{p_end}

{title:Algorithm}
{p 4 12 2} {bf:Step 1:} Change the initial letter(s) of the surname as indicated (mac->mcc) (kn->nn) (k->c) (ph->ff) (pf->ff) (sch->sss). {p_end}
{p 4 12 2} {bf:Step 2:} Change the last letter(s) of the surname as indicated (ee->y) (ie->y) (dt->d) (rt->d) (rd->d) (nt->d) (nd->d). {p_end}
{p 4 12 2} {bf:Step 3:} The first character of the NYSIIS-coded surname is the first letter of the (possibly altered) surname.{p_end}
{p 4 12 2} {bf:Step 4:} Position the pointer at the second letter of the (possibly altered) surname.{p_end}
{p 4 12 2} {bf:Step 5:} (Change the current letter(s) of the surname  i.e., the one at the present position of the pointer.) Execute exactly one of the following operations, proceeding from top to bottom:{p_end}

{p 12 16 2}{bf:(a)} If blank, go to Step 7.{p_end}
{p 12 16 2}{bf:(b)} If the current letter is E and the next letter is V, then change EV to AF.{p_end}
{p 12 16 2}{bf:(c)} Change a vowel (AEIOU) to A.{p_end}
{p 12 16 2}{bf:(d)} Change Q to G.{p_end}
{p 12 16 2}{bf:(e)} Change Z to S.{p_end}
{p 12 16 2}{bf:(f)} Change M to N.{p_end}
{p 12 16 2}{bf:(g)} If the current letter is the letter K, then change K to C unless the next letter is N. If K is followed by N, then replace KN by N.{p_end}
{p 12 16 2}{bf:(h)} Change SCH to SSS.{p_end}
{p 12 16 2}{bf:(i)} Change PH to FF.{p_end}
{p 12 16 2}{bf:(j)} If H is preceded by or followed by a letter that is not a vowel (AEIOU), then replace the current letter in the surname by the preceding letter.{p_end}
{p 12 16 2}{bf:(k)} If "W" is preceded by a vowel, then replace the current letter in the surname with the preceding letter.{p_end}

{p 4 12 2} {bf:Step 6:} The next character of the NYSIIS code is the current position letter in the surname after completing Step 5 (but omitting a letter that is equal to the last character already placed in the code). After putting a character into the code, move the pointer forward to the next letter of the surname. Then return to Step 5. {p_end}
{p 4 12 2} {bf:Step 7:} (Change the last character(s) of the NYSIIS-coded surname.) If the last two characters of the NYSIIS-coded surname are AY, then replace AY by Y. If the last character of the NYSIIS-coded surname is either S or A, then delete it.{p_end} 

{title:Options}

{phang} {opth generate(newvar)} Create a new variable named {it:newvar} containing the NYSIIS phoentic code. If the {opt generate()} option is not used, a new variable will be created with default name {bf:nysiis}.{p_end}
{phang} {opt noisily} Switches on a timer and displays the position in the algorithm, probably only useful in very large files. {p_end}

{title:Examples}

{phang} {bf:{stata sysuse nysiis_names ,clear }} 

{phang}{bf:{stata nysiis name  , gen(nysiis_code) noisily }} 

{phang}{bf:{stata list name nysiis_code }}

{title:Saved results}

{pstd}
{cmd:nysiis} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(nysiis)}}name of new string  variable if created{p_end}
{p2colreset}{...}

{title:Disclaimer}
{p 4 4 2} {bf:nysiis} comes with no warranty intended or implied.  We recommend that users check their results with those obtained through other algorithms.  Users are also encouraged to check their results with those produced by other statistical software or name coding packages.

{title:Reference}
{pstd} "Data Quality and Record Linkage Techniques", Herzog T.N., Scheuren F.J., Winkler W.E. 2007 pg 119-121.{p_end}
{pstd} "Name Search Techniques", Taft RL., New York State Identification and Intelligence System, Special Report No. 1, Albany, New York, 1970.{p_end}

{title:Author}

{pstd} Adrian Sayers {p_end}
{pstd} University of Bristol{p_end}
{pstd} adrian.sayers@bristol.ac.uk {p_end}
{pstd}  {p_end}

{title:Acknowledgement}
{pstd} Matthew Curtis mjdcurtis@gmail.com  spotted and fixed unusual behaviour in how steps 5j and 5k are implmented 07/2018 {p_end}

{title:Also see}

{pstd}
{help strdist:strdist}, {help soundex:soundex}, {help jarowinkler:jarowinkler}
{p_end}
