{smcl}
{* *! version 3.3.1 05Aug2019 MLB}{...}
{title:Title}

{phang}
{cmd:smclpres} {hline 2} Create a .smcl presentation from a .do file

{title:Syntax}

{p 8 17 2}
{cmd:smclpres}
{cmd:using} {it:{help filename}} [{cmd:,}
{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}files created by {cmd:smclpres} will replace files with the
        same name if they already exist{p_end}
{synopt:{opt dir(directory_name)}}specifies the directory in which the presentation
        is to be stored. The default is the current working directory.{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
Commands that can be used in the .do file. These commands have to be the first 
word on their line. 

{synoptset 34 tabbed}{...}
{synopthdr:commands}
{synoptline}
{syntab:Main}
{synopt:{opt //slide}}start a new slide{p_end}
{synopt:{opt //endslide}}ends that slide{p_end}
{synopt:{opt //titlepage}}start a titlepage{p_end}
{synopt:{opt //endtitlepage}}ends that titlepage{p_end}
{synopt:{opt //anc}}start an ancillary slide, a slide that is not part of the regular
flow of the presentation, but can only be accessed through the index slide{p_end}
{synopt:{opt //endanc}}end the ancillary slide{p_end}
{synopt:{opt //digr}}start a digression slide, a slide that is not part of the 
regular flow of the presentation, but can be accessed through a special link in 
a textblock on the previous slide{p_end}
{synopt:{opt //enddigr}}ends that digression slide{p_end}
{synopt:{opt /*digr*/}}will put a link to the next slide if it is a digression 
slide. it has to appear in a textblock and does not have to be the first word on
the line.{p_end}
{synopt:{opt //bib}}start a bibliography slide{p_end}
{synopt:{opt //endbib}}ends that bibliography slide{p_end}
{synopt:{opt //title} {it:title}}The title that appears on currently open 
slide{p_end}
{synopt:{opt //txt} {it:text}}will write {it:text} on the current slide{p_end}
{synopt:{opt /*txt} and {opt txt*/}}lines between these two commands will be 
written on the currently open slide.{p_end}
{synopt:{opt /*cite} {it:key} [{it:key}] [...] {cmd:*/}}adds a reference of style 
"(last_name year)". The {it:key}s refer to the entries in the bibtex file 
specified in {cmd://layout bib bibfile()}{p_end}
{synopt:{opt //ex }[{it:label}] and {opt //endex}}Lines between these two commands are an 
example. They will appear on the current slide bold and indented. In addition, a 
.do file will be created containing those lines. On the slide below the example
a link will be shown that wil do that .do file. If a label is specified, it will
be used to label that .do file in the index when specifying {cmd://layout tocfiles on}.{p_end}
{synopt:{opt //label} {it:label}}Each slide will contain a link to the next slide.
{it:label} will be used to refer to the currently open slide, when 
{cmd://layout bottombar label} has been specified. The default is "next".{p_end}
{synopt:{opt //section} {it:section_name}}Start a new section called 
{it:section_name}{p_end}
{synopt:{opt //subsection} {it:subsection_name}}Starts a new sub-section called
{it:subsection_name}{p_end}
{synopt:{opt //toctitle} {it:title}}The title that appears on the index slide,
which also contains the table of contents{p_end}
{synopt:{opt /*toctitle} and {opt toctitle*/}}lines between these two commands 
will appear as the title on the index slide.{p_end}
{synopt:{opt /*toctxt} and {opt toctxt*/}}lines between these two commands will 
be written on the index slide.{p_end}
{marker tocfile}{...}
{synopt:{opt //tocfile} {it:mark filename label}}adds {it:filename} to the index slide
when {cmd://layout tocfiles on} is specified in the group of files {it:mark} and 
the label {it:label}{p_end}
{synopt:{opt //file} {it:filename}}looks for {it:filename} in the source directory
and copies it to the directory specified in the {cmd:dir()} option.{p_end}
{synopt:{opt //dir} {it:directory}}adds {it:directory} to the destination directory.{p_end}
{synopt:{opt //bib_here}}adds the bibliography at that place on the bibliography slide{p_end}
{synopt:{opt /*bib} {it:library in bibtex format} {cmd:bib*/}}enables one to 
write the bibtex library inside the presentation instead of refering to an external 
bibtex library using {cmd://layout bib bibfile()} {p_end}


{syntab:Options for including content from other .do files}
{synopt:{opt //dofile} {it:filename} ["]{it:label}["]}adds a link in the .smcl
presentation that opens file {it:filename} in the do file editor and called 
{it:label} and adds output from runing {it:filename} to the .html handout{p_end}
{synopt:{opt //apdofile} {it:filename} ["]{it:label}["]}adds a link to .smcl 
presentation opening {it:filename} in the do file editor and called {it:label}. 
In the .html handout it adds an appendix slide at the end of the presentation 
containing output from runing {it:filename} and adds a link in the html with
label {it:label}.{p_end}
{synopt:{opt //codefile} {it:filename} ["]{it:label}["]}adds link that opens 
{it:filename} called {it:label} in the do file editor and adds content of 
{it:filename} to the .html handout{p_end}
{synopt:{opt //apcodefile} {it:filename} ["]{it:label}["]} adds a link to .smcl 
presentation opening {it:filename} in the do file editor and called {it:label}. 
In the .html handout it adds an appendix slide at the end of the presentation 
containing the content of {it:filename} and adds a link in the html with
label {it:label}.{p_end}
{synopt:{opt //db} {it:dbname} {it:filename} ["]{it:label}["]} adds a link to 
the .smcl presentation opening the dialog box {it:dbname} and called it {it:label}.
It adds the output from running {it:filename} to the .html handout.

{syntab:Options for the .html handout}
{synopt:{opt //graph} {help name_option:name}}adds the graph {it:name} to the 
.html handout{p_end}
{synopt:{opt //ho_ignore}} ignores this line in the .html handout{p_end}

{syntab:Setting the overall layout}
{synopt:{opt //layout title} {it:options}}options determining the layout of the 
titles{p_end}
{synopt:{opt //layout topbar} {it:options}}options determining the layout of the 
top bar on each slide{p_end}
{synopt:{opt //layout bottombar} {it:options}}options determining the layout of 
the bottom bar on each slide{p_end}
{synopt:{opt //layout toc} {it:options}}options determining the layout of the 
index slide{p_end}
{synopt:{opt //layout tocfiles} {it:options}}options determining whether or not 
and how additional files used in the presentation are listed on the index slide{p_end}
{synopt:{opt //layout bib} {it:options}}options governing the bibliography{p_end}
{synopt:{opt //layout digress} {it:options}}options determining the layout of the 
link to digression slides{p_end}
{synopt:{opt //layout example} {it:options}}option determining the layout of the
link that runs the examples{p_end}
{synopt:{opt //layout tabs} {it:option}}option how to treat tabs{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 20 tabbed}{...}
{synopthdr:layout options}
{synoptline}
{syntab://layout title}
{synopt:{opt left}}title is left justified{p_end}
{synopt:{opt center}}title is centered, the default{p_end}
{synopt:{opt thline}}display a horizontal line at the top of the 
title{p_end}
{synopt:{opt bhline}}display a horizontal line at the bottom of the 
title{p_end}
{synopt:{opt nobold}}title is not in bold font{p_end}
{synopt:{opt italic}}title is in italic font{p_end}

{syntab://layout topbar}
{synopt:{opt off}}suppress the bar at the top of the slide{p_end}
{synopt:{opt on}}display the bar at the top of the slide, the default{p_end}
{synopt:{opt nosubsec}}only display the section name{p_end}
{synopt:{opt nothline}}do not display a horizontal line at the top of the top 
bar{p_end}
{synopt:{opt nobhline}}do not display a horizontal line at the bottom of the top 
bar{p_end}
{synopt:{opt nosecbold}}section title is not bold{p_end}
{synopt:{opt secitalic}}section title is italic{p_end}
{synopt:{opt subsecbold}}sub-section title is bold{p_end}
{synopt:{opt subsecitalic}}sub-section title is italic{p_end}
{synopt:{opt sep(string)}}separator between the section and subsection, default 
is " {c -(}hline 2{c )-} "{p_end}

{syntab://layout bottombar}
{marker arrow}{...}
{synopt:{opt arrow}}the bottom bar will contain three links: back, index slide, 
and forward in the form {help smclpres##arrow:<<} {help smclpres##arrow:index} 
{help smclpres##arrow:>>}. This is the default.{p_end}
{marker label}{...}
{synopt:{opt label}}the bottom bar will contain two links index slide, and forward
in the form {help smclpres##label:index}     {help smclpres##label:next}{p_end}
{synopt:{cmd:next(}{it:left}|{it:right}{cmd:)}}specifies whether the link to the
nextslide will apear left or right if {cmd://layout bottombar label} has been 
specified.{p_end}
{synopt:{opt nextname(name)}}specifies the default label used for the link to the next
slide if {cmd://layout bottombar label} has been specified. The default is 
"next".{p_end}
{synopt:{opt index(name)}}specifies the label used for the link to the index 
slide{p_end}
{synopt:{opt toc}}display the bottombar on the index slide{p_end}
{synopt:{opt nothline}}do not display a horizontal line at the top of the bottom 
bar{p_end}
{synopt:{opt nobhline}}do not display a horizontal line at the bottom of the 
bottom bar{p_end}

{syntab://layout toc}
{synopt:{cmd:link(}{it:section}|{it:subsection}|{it:subsubsection}{cmd:)}}specifies 
whether on the index slide the section names, the subsection names, or the 
subsubsection names are links to the appropriate place in the presentation.{p_end}
{synopt:{cmd:title(}{it:subsection}|{it:subsubsection}|{it:notitle}{cmd:)}}specifies that 
the slide title is also a subsection, subsubsection, or neither. 
{cmd:title(}{it:subsection}{cmd:)} will also set {cmd://layout topbar nosubsec}.{p_end}
{synopt:{opt itemize}}specifies that on the index slide the section names are 
preceded by a "{cmd:o }", the subsection names are preceded by a "{cmd:- }", and the 
subsubsection by a "{cmd:. }".{p_end}
{synopt:{opt anc(name)}}ancillary slides will always appear as a link in the index,
with the title of the ancillary slide. additionally, they will be marked with
({it:name}). The default {it:name} is "ancillary".{p_end}
{synopt:{cmd:nodigr}}do not display digression slides in the table of content{p_end}
{synopt:{opt secthline}}draw a horizontal line above each section on the index 
slide. If this is specified in combination with {cmd:itemize}, then the section will 
not be preceded by a marker, and all markers are moved one level down.{p_end}
{synopt:{opt secbhline}}draw a horizontal line below each section on the index 
slide. If this is specified in combination with {cmd:itemize}, then the section 
will not be preceded by a marker, and all markers are moved one level down.{p_end}
{synopt:{opt secbold}}section name on index slide is in bold font{p_end}
{synopt:{opt secitalic}}section name on index slide in in italic font{p_end}
{synopt:{opt subsecbold}}subsection name on index slide is in bold font{p_end}
{synopt:{opt subsecitalic}}subsection name on index slide in in italic font{p_end}
{synopt:{opt subsubsecbold}}subsubsection name on index slide is in bold font{p_end}
{synopt:{opt subsubsecitalic}}subsubsection name on index slide in in italic font{p_end}
{synopt:{opt subsubsubsecbold}}subsubsubsection name on index slide is in bold font{p_end}
{synopt:{opt subsubsubsecitalic}}subsubsubsection name on index slide in in italic font{p_end}
{synopt:{opt subtitle(string)}}if {cmd://layout tocfiles on} is specified, then the index
slide will consist of two parts: the index of slides followed by an index of 
files used in the presentation. {it:string} will be used as a title for the index
of slides. The default is "Slide table of contents"{p_end}
{synopt:{cmd:subtitlepos(}{it:left}|{it:center}{opt )}}specifies whether the subtitle
will be left justified or centered{p_end}
{synopt:{opt nosubtitlebold}}specifies that the subtitle will not be bold{p_end}
{synopt:{opt subtitleitalic}}specifies that the subtitle will be italic{p_end}
{synopt:{opt nosubtitlethline}}specifies that there is no horizontal line above
the subtitle{p_end}
{synopt:{opt nosubtitlebhline}}specifies that there is no horizontal line below
the subtitle{p_end}

{syntab://layout tocfiles}
{synopt:{opt off}}do not display a list of files used in the presentation in the 
index slide, the default{p_end}
{synopt:{opt on}}display a list of files used in the presentation in the index 
slide{p_end}
{synopt:{opt name(string)}}{it:string} will be used as a subtitle on the index 
slide for the part displaying files. The default is "Supporting materials"{p_end}
{synopt:{opt exname(string)}}if no label was specified for an example then the 
default will be to display "example #; on slide #". with this option you can
change "example" to the string of your choice.{p_end}
{synopt:{opt where(string)}}all file labels will include an indication on which
slide the file is used, the default is "; on slide #". with this option you can
change "; on slide " to the string of your choice.{p_end}
{synopt:{opt doname(string)}}all example .do files and files who got the {it:mark} 
"do" at {help smclpres##tocfile://tocfile}  will be displayed together and 
will get the section heading {it:string}. The default is "Do files"{p_end} 
{synopt:{opt adoname(string)}}all files that got the {it:mark} "ado" at 
{help smclpres##tocfile://tocfile} will be displayed together and will
get the section heading {it:string}. The default is "Ado files"{p_end}
{synopt:{opt dataname(string)}}all files that got the {it:mark} "data" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Datasets"{p_end}
{synopt:{opt classname(string)}}all files that got the {it:mark} "class" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Classes"{p_end}
{synopt:{opt stylename(string)}}all files that got the {it:mark} "style" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Styles"{p_end}
{synopt:{opt graphname(string)}}all files that got the {it:mark} "graph" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Graphs"{p_end}
{synopt:{opt grecname(string)}}all files that got the {it:mark} "grec" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Graph editor recordings"{p_end}
{synopt:{opt irfname(string)}}all files that got the {it:mark} "irf" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Impulse-response function datasets"{p_end}
{synopt:{opt mataname(string)}}all files that got the {it:mark} "mata" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Mata files"{p_end}
{synopt:{opt bcname(string)}}all files that got the {it:mark} "bc" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Business calendars"{p_end}
{synopt:{opt stername(string)}}all files that got the {it:mark} "ster" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Saved estimates"{p_end}
{synopt:{opt tracename(string)}}all files that got the {it:mark} "trace" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Parameter-trace files"{p_end}
{synopt:{opt semname(string)}}all files that got the {it:mark} "sem" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "SEM builder files"{p_end}
{synopt:{opt swmname(string)}}all files that got the {it:mark} "swm" at 
{help smclpres##tocfile://tocfile} will be displayed together and will get the 
section heading {it:string}. The default is "Spatial weighting matrices"{p_end}
{synopt:{cmd:customname(}{it:mark label} [; {it:mark label}]{cmd:)}}specify a 
custom mark or marks with their section headings.{p_end}
{synopt:{opt doedit(string)}}all {it:filenames} with an extension that appears in
{it:string} will be displayed as a link that will open the file in the 
{help doedit:do file editor}. The default is "do ado dct class scheme style"{p_end}
{synopt:{opt view(string)}}all {it:filenames} with an extension that appears in
{it:string} will appear as a link that will open the file in the {help view:viewer}. The 
default is "smcl log hlp sthlp".{p_end}
{synopt:{opt gruse(string)}}all files with {it:filenames} with an extension that
appears in {it:string} will appear as a link which will open a 
{help graph use:Stata graph}. The default is "gph"{p_end}
{synopt:{opt euse(string)}}all files with {it:filenames} with an extension that
appears in {it:string} will appear as a link which will open 
{help estimates_save:saved estimates}. the default is "ster"{p_end}
{synopt:{opt use(string)}}all files with {it:filenames} with an extension that
appears in {it:string} will appear as alink which will open it as a 
{help use:Stata data set}. The default is "dta"{p_end}
{synopt:{opt p2(# # # #)}}sets column spacing for the table of files.
The first {it:#} specifies the beginning position of the first column, the
second {it:#} specifies the placement of the second column, the third {it:#}
specifies the placement for subsequent lines of the second column, and the
last {it:#} specifies the number to indent from the right-hand side for the
second column. The default is "5 25 26 0"{p_end}

{syntab://layout bib}
{synopt:{opt bibfile(filename)}}specifies the bibtex library that is to be used 
for the bibliography{p_end}
{synopt:{opt stylefile(filename)}}specifies the style file file that governs the
way the bibliography is formatted{p_end}
{synopt:{opt and(string)}}specifies what is to be used for the word "and" when 
a reference contains multiple authors. The default is "and"{p_end}
{synopt:{opt authorstyle("first last" | "last first")}}specifies whether the 
authors in the bibliography are writen as "first_name last_name" or 
"last_name, first_name". The default is "first last"{p_end}
{synopt:{opt write("cited" | "all")}}specifies whether the bibliography contains
only the references cited in the presentation or all references present in the 
bibtex library. The default is "cited"{p_end}

{syntab://layout digress}
{synopt:{opt name(string)}}name used for the link to the digression slide when //label 
has not been specified. The default is "digression"{p_end}
{synopt:{opt prefix(string)}}prefix to the name used for the link. The default 
is ">> "{p_end}

{syntab://layout example}
{synopt:{opt name(string)}}name used for the link that runs the example. The 
default is "{c -(}it:click to run{c )-}"{p_end}

{syntab://layout tabs}
{synopt:{opt spaces(#)}}number of spaces used for each tab, default is 4{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
A .smcl presentation is a series of linked {help smcl:.smcl} files that open in 
the {help view:viewer} inside Stata (like help-files). They are interactive. Click
on links to execute .do files or move from one slide to the next. They are 
particularly useful for talks that focus on how to do things in Stata, like a 
lecture on graphs in Stata or a talk at a Stata Users' Group meeting. Preparing
for such a talk typically starts with preparing the examples using a .do file. 
The purpose of {cmd:smclpres} is to streamline the process of turning that .do 
file into a .smcl presentation. 

{pstd}
Once a .smcl presentation is created it can be turned into a .html handout using 
{helpb pres2html}. 

{pstd}
A typical slide created by {cmd:smclpres} will start with a bar at the top showing
the section and subsection to which that slide belongs. This is followed by the 
title of that slide. After that the actual contents of the slide starts. This could
be any combination of text and examples. An example is a set of commands shown 
in bold text, with below it a link that will execute a .do file with those exact 
same commands. So one can discuss the commands in the example, click on that link,
and show the output of those commands. The slide ends with a bar at the bottom,
which will contain a link to the next slide, a link to index slide, and the 
previous slide.
 
{pstd}
{cmd:smclpres} knows 6 different types of slides:

{phang}
the {it:titlepage} is the first slide. It does not contain a topbar, and the bottombar only
points to the index slide and the first regular slide. 

{phang}
the {it:index slide} is the second slide if a titlepage is defined, or the first slide
otherwise. It contains a list of sections and subsections and optionally all 
slides. Either the section, subsection, or individual slide listings are links. So
one can use the index slide to jump around in the presentation. 

{pmore}
The index slide may also contain a listing of files used in the presentation. The 
.do files created for the examples are automatically included, all other files 
have to be explicitly mentioned using the {cmd://tocfile} command. 

{pmore}
The index slide does not contain a topbar, and by default, no bottombar. One can
add a textblock to the index slide, which can be useful when the index slide also
functions as the titlepage. 

{phang}
The {it:regular slides} are there for the main content of the presentation. The order
of the slides is determined by the order in which they appear in the master .do file.

{phang}
The {it:digression slides} are there for a side thought. They are not part of the main 
flow of the presentation. A regular slide may contain a link in a text block to 
a digression slide. The link to the next slide in the bottom bar will link to the
next regular slide, and will thus skip the digression slide. So during the 
presentation, the presenter can easily decide whether or not to skip the digression
slide. The bottom bar of the digression only contains a link back to the regular slide 
that linked to it and the index slide. The topbar will not contain the section 
and subsection, but "Digression" or whatever has been specified in 
{cmd://layout digr name()}.

{phang}
The {it:ancillary slides} are the appendix. They are also not part of the main flow of
the presentation. They can only be accessed through the index slide.

{phang}
The {it:bibliography slide} contains the bibliography. A reference on another slide
will create a link to this slide, and the bibliography slide can be accessed via 
the index slide. 


{title:Options}

{dlgtab 4 2:options for the smclpres command}

{phang}
{opt replace} files created by {cmd:smclpres} will replace files with the
        same name if they already exist. 

{pmore}
        If the .do file is called 
        {cmd:presentation.do} then the following files will be created: 
        presentation.smcl, slide1.smcl, slide2.smcl, etc. presentation.smcl will
        be the first slide and contain the title page, or when no titlepage was
		defined, the table of content. If a titlepage was defined, the index slide
		will also be created and called index.smcl. In addition, if slide2.smcl 
		contains two examples, then the following files will also be created: 
		slide2ex1.do and slide2ex2.do.

{phang}
{opt dir(directory_name)} specifies the directory in which the presentation is to 
        be stored. The default is the current working directory. 


{dlgtab 4 2:Commands in .do file}

{phang}
{opt //slide} Starts a new slide. Anything appearing afterwards will be ignored.
        So one can specify {cmd://slide ------------} to indicate more clearly 
        in the .do file  where the new slides begin. However, notice the space 
        between {cmd://slide} and {cmd:-------}.

{phang}
{opt //endslide} Ends the slide. As with {cmd://slide} everything afterwards will
        be ignored.

{phang}
{opt //titlepage} starts the first slide, the titlepage. If this is not specified
        the index slide will be the first slide.
		
{phang}
{opt //endtitlepage} ends the titlepage.

{phang}
{opt //anc} starts an ancillary slide, that is, a slide that is not part of the 
        regular flow of the presentation, but can only be accessed through the
		index slide. 

{phang}
{opt //endanc} ends the ancillary slide

{phang}
{opt //digr} starts a digression slide. Such a slide is not part of the regular flow
        of the presentation, but can be accessed from a link inside a textblock
		on the previous slide. Once on a digression slide one can only return to
		the previous slide (or the index slide).

{phang}
{opt //enddigr} ends the digression slide

{marker /*digr*/}{...}
{phang}
{opt /*digr*/} puts a link to the next slide, which has to be a digression slide.
        This has to appear in a textblock, but unlike other commands does not 
		have to be the first word on a line. If the digression slide has a 
		{cmd://label} then the link will appear as 
		{help smclpres##/*digr*/:>>{it:label}}, otherwise as 
		{help smclpres##/*digr*/:>>digression}. The prefix and the default label
		can be changed using {cmd://layout digress name() prefix()}.
	
{phang}
{opt //bib} starts the bibliography slide.

{phang}
{opt //endbib} ends the bibliography slide.

{phang}
{opt //bib_here} specifies that the bibliography is to appear here. This can only
be used on a bibliography slide. This is necessary when using an external bibtex
file, i.e. using {cmd://layout bib bibfile} {it: some_bibtex_file.bib}. 

{phang}
{cmd:/*bib} {it:bibliography in bibtex format} {cmd:bib*/} enables one to type 
bibtex file in the presentation instead of an external file. This also indicates
the place where the bibliography will appear on the bibliography slide. As a 
consequence, this has to appear on a bibliography slide.
	
{phang}
{opt //title} {it:title} specifies the title that appears on the current slide

{phang}
{opt //txt} {it:text} will write {it:text} on the current slide. This text may 
       contain {help smcl:smcl directives}.

{marker textblock}{...}	   
{phang}
{opt /*txt} and {opt txt*/} lines between these two commands will be written on 
        the currently open slide. This text may contain {help smcl:smcl directives}.

{phang}
{cmd:/*cite} [{c -(}{it:prefix}{c )-}] {it:key} [{c -(}{it:postfix}{c )-}] 
[[{c -(}{it:prefix}{c )-}] {it:key} [{c -(}{it:postfix}{c )-}]] [...] {cmd:*/} 
Adds a reference in the style ({it:prefix} last_name year {it:postfix}). 
The {it:key}s refer to entries in the bibtex file. The {it:prefix} could be 
something like e.g. and the postfix something like p. 12. 

{pmore}
If you cite multiple
references, then between the keys the first matching pair of curly braces (which
could contain nothing) is the postfix for the left key and the second pair of 
matching braces contains the prefix of the right key.
		
{phang}
{opt //ex} [{it:label}] and {opt //endex} Lines between these two commands are 
        an example. They will appear on the current slide bold and indented. In
		addition, a .do file will be created containing those lines. On the 
		slide below the example a link will be shown that wil do that .do file.
		If {cmd://layout tocfiles on} is specified, then the .do files will be
		automatically included with the {help smclpres##tocfile:{it:mark}} "do".
		{it:label} will be used to describe the .do file. The default label is 
		determined by {cmd://layout tocfiles exname() where()}.

{phang}
{opt //label} {it:label} each slide will contain a link to the next slide. If 
       {cmd://layout bottombar label} is specified {it:label} will 
        be used to refer to the current slide. The default is "next". Regardless 
		of what is specified in {cmd://layout bottombar}, {it:label} will be used
		to refer to digression slides. In that case the default is specified in
		{cmd://layout digress name()}.

{phang}
{opt //section} {it:section_name} Starts a new section named {it:section_name}. 
        This will appear in the table of content and on top of the slides in that
        section.

{phang}
{opt //subsection} {it:subsection_name} Starts a new subsection named 
        {it:subsection_name}. This will appear in the table of content and on 
        top of the slides in that section. The sub-sections will be ignored if 
		{cmd://layout toc title(subsection)} was specified, as in that case the 
		slide titles are the sub-sections.

{phang}
{opt //toctitle} {it:title} The title that appears on the index slide

{phang}
{opt /*toctxt} and {opt toctxt*/} lines between these two commands will appear on
        the index slide

{phang}
{opt //tocfile} {it:mark filename label} specifies a file that will be listed in
       the index slide if {cmd://layout tocfiles on} has been specified. All files
	   with the same {it:mark} will be listed together in the order in which they
	   appear in the master do-file. {it:label} will appear after the filename in
	   the index slide to describe that file.

{phang}	   
{opt //file} {it:filename} looks for {it:filename} in the source directory
and copies it to the directory specified in the {cmd:dir()} option. This does 
nothing	when the {cmd:dir()} option is not specified. Specifying {cmd://file} 
can be useful to make sure that for example datasets used in examples are 
available to the presentation.
	   
{synopt:{opt //dir} {it:directory}}adds {it:directory} to the destination 
directory. By default, the destination directory is the source directory, unless 
the {cmd:dir()} option has been specified. Working with directories is something 
many students have trouble with, so showing how to work with them is often part 
of a course. So I often want a given directorystructure to illustrate that in my 
course material.{p_end}	   
	   
{phang}
{opt //dofile} {it:filename} ["]label["] adds a link to the .smcl presentation 
that opens {it:filename} in the do file editor called {it:label} and adds output 
from runing {it:filename} to the .html handout. {it:filename} is assumed to be 
in the source directory. If the {cmd:dir()} option is specified, then 
{it:filename} will be copied into that directory. This has to appear inside a 
{help smclpres##textblock:textblock}.

{phang}
{opt //apdofile} {it:filename} ["]label["] adds a link to the .smcl presentation 
that opens {it:filename} in the do file editor called {it:label} and adds an 
appendix slide at the end of the .html handout containing output from runing 
{it:filename}. {it:filename} is assumed to be in the source directory. If the 
{cmd:dir()} option is specified, then {it:filename} will be copied into that
directory. This has to appear inside a {help smclpres##textblock:textblock}.

{phang}
{opt //codefile} {it:filename} ["]label["] adds a link to the .smcl presentation 
that opens {it:filename} in the do file editor called {it:label} and adds 
content of {it:filename} to the .html handout. {it:filename} is assumed to be in 
the source directory. If the {cmd:dir()} option is specified, then {it:filename} 
will be copied into that directory. This has to appear inside a 
{help smclpres##textblock:textblock}.

{phang}
{opt //apcodefile} {it:filename} ["]label["] adds a link to the .smcl presentation 
that opens {it:filename} in the do file editor called {it:label} and adds an 
appendix slide at the end of the .html handout containing the content of 
{it:filename}.  {it:filename} is assumed to be in the source directory. If the 
{cmd:dir()} option is specified, then {it:filename} will be copied into that
directory. This has to appear inside a {help smclpres##textblock:textblock}.

{phang}
{opt //db} {it:dbname} {it:filename} ["]label["] adds a link to the .smcl presentation 
that opens the dialog box {it:dbname} and calls that link {it:label}. It adds output 
from runing {it:filename} to the .html handout. {it dbname}.dlg and {it:filename} 
are assumed to be in the source directory. If the {cmd:dir()} option is specified, then 
{it:dbname}.dlg and {it:filename} will be copied into that directory. This has 
to appear inside a {help smclpres##textblock:textblock}.

{phang}
{opt //graph} {help name_option:name} specifies the graph(s) that will be added 
at this point in the .html handout.

{phang}
{opt //ho_ignore} ignores this line in the .html handout
	   
{phang}
{opt //layout} {it:what options} specifies global options determining how various
       elements will appear in the smcl presentation. {it:what} can be {cmd:title},
	   {cmd:topbar}, {cmd:bottombar}, {cmd:toc}, {cmd:tocfiles}, {cmd:digress}, 
	   {cmd:example}, {cmd:tabs}, or {cmd:bib}. The available options are listed below.

	   
{dlgtab 4 2://layout title options}

{phang}
{opt left} slide title is left justified

{phang}
{opt center} slide title is centered

{phang}
{opt thline} display a horizontal line at the top of the title

{phang}
{opt bhline} display a horizontal line at the bottom of the title

{phang}
{opt nobold} title is not in bold font

{phang}
{opt italic} title is in italic font

{dlgtab 4 2://layout topbar options}

{phang}
{opt off} suppress the bar displaying the section and subsection at the top of 
     the slide
	 
{phang}
{opt on} show a bar on top of each slide displaying the section and subsection, 
      the default.
	  
{phang}
{opt nosubsec} only display the section name

{phang}
{opt nothline} do not draw a horizontal line above the topbar

{phang}
{opt nobhline} do not draw a horizontal line below the topbar

{phang}
{opt nosecbold} do not display the section in bold font

{phang}
{opt secitalic} section is in italic font

{phang}
{opt subsecbold} subsection is in bold font

{phang}
{opt subsecitalic} subsection is in italic font

{phang}
{opt sep(string)} a string that separates the section from the subsection. The 
       the default is " {c -(}hline 2{c )-} ". Examples of possible alternatives 
	   would be "; " or " | "

{dlgtab 4 2://layout bottombar options}

{marker optarrow}{...}
{phang}
{opt arrow} specifies that the bottombar, which is used to navigate throught the
smcl presentation looks like this:

{center:{help smclpres##optarrow:<<}   {help smclpres##optarrow:index}   {help smclpres##optarrow:>>}}

{pmore}
this is the default

{marker optlabel}{...}
{phang}
{opt label} specifies that the bottombar, which is used to navigate throught the
smcl presentation looks like this:

{help smclpres##optlabel:index} {right:{help smclpres##optlabel:{it:label}}}

{pmore}
{it:label} is the label for the next slide as specified by {cmd://label}

{phang}
{cmd:next(}{it:left}|{it:right}{cmd:)} specifies whether the link to the next 
slide will appear on the left or the right. The default is right.

{phang}
{opt nextname(name)} specifies the label for the next slide when {cmd://label} 
       has not been specified. The default is "next".

{phang}
{opt index(name)} specifies the name used for the index slide. The default is "index".

{phang}
{opt toc} specifies that the bottombar will also appear on the indexslide

{phang}
{opt nothline} do not draw a horizontal line above the bottombar

{phang}
{opt nobhline} do not draw a horizontal line above the bottombar

{dlgtab 4 2://layout toc options}

{phang}
{cmd:link(}{it:section}|{it:subsection}|{it:subsubsection}{cmd:)} The index will
       contain links to slides. This option determines whether these links will 
	   be the first slide in each section, subsection or subsubsection. The default is
	   {opt link(section)}

{phang}
{cmd:title(}{it:subsection}|{it:subsubsection}|{it:notitle}{cmd:)} specifies whether
       the titles of individual slides will appear as subsections, subsubsections, 
	   or not at all. The default is {opt title(notitle)}. If 
	   {opt title(subsection)} has been specified, then all subsections specified
	   with {cmd://subsection} will be ignored. This will also set 
	   {cmd://layout topbar nosubsec}.

{phang}
{opt itemize} specifies that on the index slide the section names are preceded by 
a "{cmd:o }", the subsection names are preceded by a "{cmd:- }", and the 
subsubsection by a "{cmd:. }". If the {opt secthline} or {opt secbhline} options
have been specified, then the sections will not be preceded by anything, the 
subsections will be preceded by a "{cmd:o }", etc.

{phang}
{opt anc(name)} ancillary slides will always appear as a link in the index,
with the title of the ancillary slide. additionally, they will be marked with
({it:name}). The default {it:name} is "ancillary".

{phang}
{opt nodigr} digression slides do not appear in the index.

{phang}
{opt secthline} draw a horizontal line above each section on the index slide.

{phang}
{opt secbhline} draw a horizontal line below each section on the index slide.

{phang}
{opt secbold} section name on index slide is in bold font

{phang}
{opt secitalic} section name on index slide is in italic font

{phang}
{opt subsecbold} subsection name on index slide is in bold font

{phang}
{opt subsectitalic} subsection name on index slide is in italic font

{phang}
{opt subsubsecbold} subsubsection name on index slide is in bold font

{pmore}
A subsubsections will be the titles of individual slides when the option 
       {opt title(subsubsection)} has been specified.

{phang}
{opt subsubsecitalic} subsubsection name on index slide is in italic font

{phang}
{opt subsubsubsecbold} subsubsubsection name on index slide is in bold font

{pmore}
A subsubsubsection will be a digression slide when the {opt title(subsubsection)} 
options has been specified

{phang}
{opt subsubsubsecitalic} subsubsubsection name on index slide is in italic font

{phang}
{opt subtitle(string)} if {cmd://layout tocfiles on} is specified, then the index 
       slide will consist of two parts: the index of slides followed by an index of 
	   files used in the presentation. {it:string} will be used as a title for 
	   the index of slides. The default is "Slide table of contents"


{phang}
{cmd:subtitlepos(}{it:left}|{it:center}{cmd:)} specifies whether the subtitle 
       will be left justified or centered

{phang}
{opt nosubtitlebold} specifies that the subtitle will not be bold

{phang}
{opt subtitleitalic} specifies that the subtitle be italic

{phang}
{opt nosubtitlethline} suppresses a horizontal line above the subtitle

{phang}
{opt nosubtitlebhline} suppresses a horizontal line below the subtitle


{dlgtab 4 2://layout tocfiles options}

{phang}
{opt off} do not display a list of files used in the presentation, the default.

{phang}
{opt on} show a list of files used in the presentation.

{phang}
{opt name(title)} the subtitle used on the index slide. The default is 
"Supporting materials"

{phang}
{opt exname(string)} The do-files for examples are automatically included in the 
list of files under the mark do. If no label label was specified in {cmd://ex} 
then the default label for that do file is "example #; on slide #". With this 
option the "example" can be changed.

{phang}
{opt where(string)} all file labels will include an indication on which
slide the file is used, the default is "; on slide #". with this option you can
change "; on slide " to the string of your choice.

{phang}
{it:what}{cmd:name(}{it:string}{cmd:)} Files will be grouped together depending 
       on the {it:mark} given to them at {cmd://tocfile}. This option specifies
	   the section heading for each group. {it:what} is the {it:mark} and can be 
	   {cmd:do}, {cmd:ado}, {cmd:data}, {cmd:class}, {cmd:style}, {cmd:graph}, 
	   {cmd:grec}, {cmd:irf}, {cmd:mata}, {cmd:bc}, {cmd:ster}, {cmd:trace}, 
	   {cmd:sem}, or {cmd:swm}. The defaults are:

{p2colset 9 19 20 0}{...}
{p2col:do}"Do files"{p_end}
{p2col:ado}"Ado files"{p_end}
{p2col:data}"Datasets"{p_end}
{p2col:class}"Classes"{p_end}
{p2col:style}"Styles"{p_end}
{p2col:graph}"Graphs"{p_end}
{p2col:grec}"Graph editor recordings"{p_end}
{p2col:irf}"Impulse-response function datasets"{p_end}
{p2col:mata}"Mata files"{p_end}
{p2col:bc}"Business calendars"{p_end}
{p2col:ster}"Saved estimates"{p_end}
{p2col:trace}"Parameter-trace files"{p_end}
{p2col:sem}"Sem builder files"{p_end}
{p2col:swm}"Spatial weighting matrices"{p_end}

{phang}
{cmd:customname(}{it:mark label} [; {it:mark label}{cmd:)} allows the specification
of custom {it:marks} and their section headings. 

{pmore}
For example, your presentation contains excercises and you include .do files with 
the solutions. In that case you could write 
{cmd://layout tocfiles customname(sol Solutions)} to define the mark sol and its
section heading. In the presentation you can include the solutionfile sol1.do in 
the index with {cmd://tocfile sol sol1.do}

{phang}
{opt doedit(extensions)} all {it:filenames} with an extension that appears in
{it:extensions} will be displayed as a link that will open the file in the 
{help doedit:do file editor}. The default is "do ado dct class scheme style"

{phang}
{opt view(extensions)} all {it:filenames} with an extension that appears in
{it:estensions} will be displayed as a link that will open the file in the 
{help view:viewer}. The default is "smcl log hlp sthlp"

{phang}
{opt gruse(extensions)} all {it:filenames} with an extension that appears in
{it:extensions} will be displayed as a link that will open that file as a  
{help graph_use:Stata graph}. The default is "gph"

{phang}
{opt euse(extensions)} all {it:filenames} with an extension that appears in
{it:extentions} will be displayed as a link that will open the file a  
{help estimates save:saved result}. The default is "ster"

{phang}
{opt use(extensions)} all {it:filenames} with an extension that appears in
{it:extensions} will be displayed as a link that will open the file as a  
{help use:Stata dataset}. The default is "dta"

{phang}
{opt p2(# # # #)} sets column spacing for the table of files.  The first # 
specifies the beginning position of the first column, the second # specifies the 
placement of the second column, the third # specifies the placement for subsequent 
lines of the second column, and the last # specifies the number to indent from 
the right-hand side for the second column. The default is "5 25 26 0"

{dlgtab 4 2://layout bib options}

{phang}
{opt bibfile(filename)} 

{phang}
{opt stylefile(filename)} specifies the style file file that governs the way the
bibliography is formatted. The style file contains an entry for each type of 
reference. Each entry starts with a @ followed by the type of entry (a book or
an article) and than in curly brackets the style for that type. The style is just 
a smcl text, but replacing fields from the reference by the name of that field in
square brackets. 

{pmore}
For example the default style for a book is:

{pmore}
{cmd:@book{c -(}{c -(}p 4 8 2{c )-}[author] ([year]), {c -(}it:[title]{c )-}.  [address]: [publisher].{c -(}p_end{c )-}{c )-}}

{phang}
{opt and(string)} specifies what is to be used for the word "and" when a 
reference contains multiple authors. The default is "and".

{phang}
{cmd:authorstyle(} {it:"first last"} | {it:"last first"} {cmd:)} specifies whether 
the authors in the bibliography are writen as "John Doe" or "Doe, John". The 
default is "first last"

{phang}
{cmd:write(} {it:"cited"} | {it:"all"} {cmd:)} specifies whether only the cited
references are included in the bibliography or all references present in the 
bibtex file.

{dlgtab 4 2://layout digress options}

{phang}
{opt name(string)} name used for the link to the digression slide when {cmd://label} 
has not been specified. The default is "digression". This name will also be used 
in the top bar of the digression slide.

{phang}
{opt prefix(string)} prefix to the name used for the link. The default is ">> "

{dlgtab 4 2://layout example options}

{phang}
{opt name(string)} name used for the link that runs the example. The default is 
"{c -(}it:click to run{c )-}"

{dlgtab 4 2://layout tabs options}

{phang}
{opt spaces(#)} number of spaces used for each tab, default is 4.


{title:Example}

{pstd}
Say if have a .do file called {cmd:minimalist.do} which contains the content 
below. We can now type {cmd: smclpres using minimalist.do}, to turn that into a 
.smcl presentation. 

{hline}
// This .do-file is intended to be compiled into a smcl presentation using:
// smclpres using minimalist.do
// ============================================================================

//toctitle A minimalist example presentation

/*toctxt

{c -(}center:Maarten Buis{c )-}
{c -(}center:maarten.buis@uni.kn{c )-}
toctxt*/

//section First section
//subsection First subsection

//slide -----------------------------------------------------------------------
//title First slide

/*txt
{c -(}pstd{c )-}Some interesting text about {c -(}help regress{c )-}{c -(}p_end{c )-}
txt*/

//ex
sysuse auto, clear
sum price
//endex
//endslide --------------------------------------------------------------------

//subsection Second subsection
//slide -----------------------------------------------------------------------
//title Second slide

/*txt
{c -(}phang{c )-}Kwaak, kwaak, kikker kwaak. Als ik grote sprongen maak. Doe ik 
net zo gek als jij, en ik kwaak er ook nog bij.{c -(}p_end{c )-}
{c -(}phang{c )-}Kwaak, kwaak, kwaak maar door. Kom maar in het kikker koor. 
Kwaak van dit en kwaak van dat. Kikkers kwaken altijd wat.{c -(}p_end{c )-}
txt*/
//endslide --------------------------------------------------------------------

//section Second section
//slide -----------------------------------------------------------------------
//title Third slide

/*txt
{c -(}phang{c )-}
Ia zegt het ezeltje, klim maar op mijn rug. Ik draag jou de hele weg, heen
end weer terug.

{c -(}phang{c )-}
Ia zegt het ezeltje. Ik loop van hier naar daar, en als je met me mee 
wil hoor ik graag, ia ia.
txt*/

//ex
reg price i.rep78 
//endex
//endslide --------------------------------------------------------------------
{hline}

{pstd}
The ancillary files contain two further examples that illustrate more advanced options.
{p_end}


{title: Also see}

{pstd}
{help pres2html}


{title:Author}

{pstd}Maarten Buis, University of Konstanz{break} 
      maarten.buis@uni.kn	  
	  
	  
{title:Acknowledgements}	  

{pstd}
Danae Roumis provided a helpful bug report.
