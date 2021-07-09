{smcl}
{cmd:help mata distinctrowsof()}
{hline}

{title:Title}

{phang}
{cmd:distinctrowsof()} {hline 2} Distinct rows of matrix


{title:Syntax}

{p 8 12 2}
{it:transmorphic matrix} 
{cmd:distinctrowsof(}{it:transmorphic matrix X}{cmd:)}

{p 8 12 2}{bind:    }
{it:real colvector} 
{cmd:_distinctrowsof(}{it:transmorphic matrix X}{cmd:)}

{p 8 12 2}
{it:transmorphic matrix} 
{cmd:duplicaterowsof(}{it:transmorphic matrix X}{cmd:)}


{title:Description}

{pstd}
{cmd:distinctrowsof()} selects the distinct rows of {it:X}; the function 
is similar to Mata's {helpb mf_uniqrows:uniqrows()} but preserves the 
sort order. For any duplicate rows, only the first row is selected.

{pstd}
{cmd:_distinctrowsof()} returns a column vector indicating the distinct 
rows of {it:X}.

{pstd}
{cmd:duplicaterowsof()} returns all duplicate rows of {it:X}, 
excluding the first occurrence of each row.


{title:Remarks}

	: {cmd:x}
	{res}       {txt}1   2   3
	    {c TLC}{hline 13}{c TRC}
	  1 {c |}  {res}4   5   7{txt}  {c |}
	  2 {c |}  {res}4   5   6{txt}  {c |}
	  3 {c |}  {res}1   2   3{txt}  {c |}
	  4 {c |}  {res}4   5   6{txt}  {c |}
	    {c BLC}{hline 13}{c BRC}

	: {cmd:distinctrowsof(x)}
	{res}       {txt}1   2   3
	    {c TLC}{hline 13}{c TRC}
	  1 {c |}  {res}4   5   7{txt}  {c |}
	  2 {c |}  {res}4   5   6{txt}  {c |}
	  3 {c |}  {res}1   2   3{txt}  {c |}
	    {c BLC}{hline 13}{c BRC}


{title:Conformability}

    {cmd:distinctrowsof(}{it:X}{cmd:)}
            {it:X}: {it:r1 x c1}
       {it:result}: {it:r2 x c1}, {it:r2}<={it:r1}
		
    {cmd:_distinctrowsof(}{it:X}{cmd:)}
            {it:X}: {it:r x c}
       {it:result}: {it:r x} 1

    {cmd:duplicaterowsof(}{it:X}{cmd:)}
            {it:X}: {it:r1 x c1}
       {it:result}: {it:r2 x c1}, {it:r2}<={it:r1}
	   
		
{title:Diagnostics}

{pstd}
{cmd:_distinctrowsof()}, if {it:X} is scalar, returns {cmd:1}. If 
{opt rows(X)}==0, the function returns {cmd:J(0, 1, 0)}; if 
{opt cols(X)}==0, the function returns {cmd:(1\ J(rows(X)-1, 1, 0))}.

{pstd}
{cmd:distinctrowsof()} returns {helpb mf_select:select(}{it:X}{cmd:,}
{opt _distinctrowsof(X)}{helpb mf select:)}.

{pstd}
{cmd:duplicaterowsof()} returns {helpb mf_select:select(}{it:X}{cmd:,}
{opt !_distinctrowsof(X)}{helpb mf select:)}.


{title:Source code}

{pstd}
Distributed with the {cmd:elabel} package.
{p_end}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb mata}, {helpb mata uniqrows:uniqrows()}
{p_end}
