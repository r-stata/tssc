{smcl}
{* *! version 1.0.0 09nov2009}{...}
{cmd:help bugwrite}
{hline}

{title:Title}

{phang}
{bf:bugwrite} {hline 2} Write data values to screen in a WinBUGS-readable format


{title:Syntax}
{p 8 17 2}
{cmdab:bugwrite}
{varlist}
{ifin}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth c:olumns(integer)}}number of columns to display data in{p_end}
{synopt:{opth s:pace(integer)}}number of spaces between comma and next data value{p_end}
{synopt:{opth w:idth(integer)}}overall width of displayed data{p_end}
{synopt:{opth f:ile(filename)}}specify a file to write data to{p_end}
{synopt:{opth l:eftpad(integer)}}specify number of blank spaces to the left of each row{p_end}
{synopt:{opth r:ightpad(integer)}}specify number of blank spaces between last data value and right parenthesis{p_end} 
{synoptline}
{p2colreset}{...}


{title:Options}
{dlgtab:Main}

{phang}
{opt columns(integer)} specifies the number of columns for the data.  This option overrides {cmd:width} 
	when a value >= 1 is specified for {cmd:columns}.  When {cmd:columns} is not specified, {cmd:width} is used, whether width 
	is specified or default.

{phang}
{opt space(integer)} specifies the number of spaces to pad each data entry with, i.e., minimum separation
	between data values and previous comma (or parenthesis for first data value).  The default is 
	{cmd:space(1)}.  Values of {cmd:space} <= 0 are equivalent to {cmd:space(0)}.

{phang}
{opt width(integer)} specifies the overall width of the displayed data.  This option overrides the {cmd:columns}
	option when {cmd:columns} is not specified or when specified <= 0.  Otherwise {cmd:columns} overrides 
	{cmd:width}.  The default is {cmd:width(88)}.  If {cmd:rightpad} is specified, the actual width can be as large
	as {cmd:width} + {cmd:rightpad}.
	
{phang}
{opt file(filename, [replace -or- append])} specifies a file to write the data to instead of writing to screen.  
	File names should include extensions (probably .txt, the program writes ASCII characters).  Either 
	{cmd:replace} or {cmd:append} should be specified if the target file already exists.  If the 
	location of the written-to file is different from the current location, then the address should be inclosed in 
	quotes.  For example, "..\data.txt".


{title:Description}

{pstd}
{cmd:bugwrite} displays data values formatted in a way that WinBUGS understands.


{title:Examples}

{cmd:. bugwrite isub in 1/25, width(30)}

isub = c(1, 1, 1, 1, 1, 1, 1,
         1, 2, 2, 2, 2, 2, 2,
         2, 2, 2, 2, 3, 3, 3,
         3, 3, 3, 4)
		 
{cmd:. bugwrite isub in 1/25, space(2) c(8)}

isub = c(1,  1,  1,  1,  1,  1,  1,  1,
         2,  2,  2,  2,  2,  2,  2,  2,
         2,  2,  3,  3,  3,  3,  3,  3,
         4)

{cmd:. bugwrite isub in 1/25, c(5) l(1) r(1)}

isub = c( 1, 1, 1, 1, 1,
          1, 1, 1, 2, 2,
          2, 2, 2, 2, 2,
          2, 2, 2, 3, 3,
          3, 3, 3, 3, 4 )

{cmd:. bugwrite isub z in 1/25, c(5)}

isub = c(1, 1, 1, 1, 1,
         1, 1, 1, 2, 2,
         2, 2, 2, 2, 2,
         2, 2, 2, 3, 3,
         3, 3, 3, 3, 4),

z = c(.1369841, .6432207, .5578017, .6047949,  .684176,
      .1086679, .6184582, .0610638, .5552388, .8714491,
      .2551499, .0445188, .4241557, .8983462, .5219247,
      .8414094, .2110077, .5644092, .2648021, .9477426,
      .2769154, .1180158, .4079702, .7219492,  .871691)

{pstd}
(Notice the comma after {it:isub}'s closing parenthesis.){p_end}


{title:Authors}

{pstd}
James Fiedler, Universities Space Research Association{break}
Email: {browse "mailto:james.fiedler-1@nasa.gov":james.fiedler-1@nasa.gov}

{pstd}
Alan H. Feiveson, National Aeronautics and Space Administration{break}
Email: {browse "mailto:alan.h.feiveson@nasa.gov":alan.h.feiveson@nasa.gov}
