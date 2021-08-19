

{smcl}
{* *! version 1.1 Anna Reuter 18mar2021}{...}
{title:Title}

{phang}
{cmd:odk2doc} {hline 2} Convert an xlsForm questionnaire written in xls/xlsx into a readable questionnaire in Word.


{marker syntax}{...}
{title:Syntax}

{p 8 27 2}
{cmd:odk2doc}	
{cmd:using}
{it:{help filename}}{cmd:,}
{cmd: to(}{it:{help filename:outputfile}}{cmd:)}
[{it:{help odk2doc##options:options}}]



{synoptset 32 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{p2coldent:* {cmd: to(}{it:{help filename:outputfile}}{cmd:)}}name of the resulting docx file {p_end}

{syntab:Item and column options}
{synopt :{opt keep(colnames)}}keep columns {it:colname_1}, ..., {it:colname_k} {p_end}
{synopt :{cmdab:dropt:ype(}{it:types}{cmd:)}}drop questions of type {it:type_1}, ..., {it:type_k} {p_end}
{synopt :{cmdab:dropv:ar(}{it:items}{cmd:)}}drop question items named {it:item_1}, ..., {it:item_k} {p_end}
{synopt :{cmd: max(}{it:{help data_types:int}}{cmd:)}}only keep answer lists with length {it:int} (default: 30){p_end}
{synopt :{opt fill}}display requested input type below open-ended questions{p_end}

{syntab:Label options}
{synopt :{cmdab:del:ete(}{it:string}{cmd:)}}delete substrings from questions and answers{p_end}
{synopt :{opt clean}}clean Markdown and xlsForm code{p_end}
{synopt :{opt mark(multiple|single|both)}}mark questions as multiple or single select {p_end}

{syntab:Output options}
{synopt :{cmd: doc(}{it:{help putdocx_begin##beginopts:begin_options}}{cmd:)}}format document{p_end}
{synopt :{cmd: fmt(}{it:{help putdocx_table##tabopts:table_options}}{cmd:)}}format table{p_end}
{synopt :{cmd: tfmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)}}format table header{p_end}
{synopt :{cmd: qfmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)}}format questions{p_end}
{synopt :{cmd: afmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)}}format answers{p_end}
{synopt :{opt replace}}replace existing file{p_end}
{synoptline}
{pstd}* {opt to} is required.
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:odk2doc} transfers xlsForm-based questionnaires written in xls/xlsx into readable questionnaires and stores them as docx files. 
It was developed and tested for xlsForms written for ODK. 
Note that the formatting options might increase the computation time for larger questionnaires, especially if cells should be colored. 
See odk2xls for a conversion into xlsx files.


{marker options}{...}
{title:Options}

{phang}
{opt to(outputfile)} specifies the destination file of the resulting questionnaire.

{phang}
{opt keep(colnames)} specifies which xlsForm columns should be kept (based on their names in the xlsForm). The columns
{it:type}, {it:name} and {it:label*} are always kept. {it:colnames} might be abbreviated, e.g. 
"constr" to display column {it:constraint} and all existing {it:constraint_message} 
columns. Columns will be displayed in the order they were entered.

{phang}
{opt droptype(types)} specifies which question types should be dropped. Groups 
and repeats can be dropped by entering "group" and "repeat".

{phang}
{opt dropvars(items)} specifies which items (as specified in column “name”) should 
be dropped. Abbreviations (e.g. food*) are supported, but not namelists (e.g. food1-food5).

{phang}
{opt max(int)} specifies the maximum length of answer lists, i.e. the maximum number of elements such a list can contain. 
Answer lists which are longer are dropped. The default maximum length is 30.

{phang}
{opt fill} adds a row below questions of type integer, decimal, range, text, image, and geopoint, 
as well as below select questions with trailing "or_other" to display the requested input type. 
If the question is of type integer, decimal, or range, and constraints or parameters were specified, these will be displayed below the question. 
If the question contains a trailing "or_other", "Other, specify" will be displayed as an additional answer. 
In all other cases, the requested input type will be displayed instead of an answer, e.g. "[Text]" for questions of type text.

{phang}
{opt delete(string)} specifies which substrings in labels (i.e. questions and answers) should be deleted. Put 
the substrings in double quotes if the style attributes contain quotes. Note that
option {opt clean} already deletes Markdown language.

{phang}
{opt clean} deletes Markdown and xlsForm language from question and answer labels. More specifically,
all “#”, ”*”, “_”, and spans (e.g. <span style="color:red"> and </span>) will be
deleted from the questions and answers. Item referrals (${item_name}) will be replaced by "____" to simulate
a fill-in gap.

{phang}
{opt mark(multiple|single|both)} adds to all labels of multiple select options the phrase "[Multiple select]", 
respectively to all labels of single select options the phrase "[Single select]".

{phang}
{cmd: fmt(}{it:{help putdocx_begin##beginopts:begin_options}}{cmd:)} formats the docx document according to the 
{it: begin_options} provided by the {help putdocx_begin:putdocx} command.

{phang}
{cmd: fmt(}{it:{help putdocx_table##tabopts:table_options}}{cmd:)} formats the docx table according to the 
{it: table_options} provided by the {help putdocx_table:putdocx} command.

{phang}
{cmd: tfmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)} formats the table header (i.e. the first row)
according to the {it: row_col_options} (and {it: cell_fmt_options}) provided by the {help putdocx_table:putdocx} command.

{phang}
{cmd: qfmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)} formats all questions
according to the {it: row_col_options} (and {it: cell_fmt_options}) provided by the {help putdocx_table:putdocx} command.

{phang}
{cmd: afmt(}{it:{help putdocx_table##rowcolopts:row_col_options}}{cmd:)} formats all answers
according to the {it: row_col_options} (and {it: cell_fmt_options}) provided by the {help putdocx_table:putdocx} command.

{phang}
{opt replace} specifies that the output file should be replaced, if such a file already exists.


{marker examples}{...}
{title:Example}

{pstd}Create a plain docx questionnaire from the xlsForm "Example_xlsForm"{p_end}
{phang2}{cmd:. odk2doc using "Example_xlsForm", to("Example_converted.docx") }{p_end}

{pstd}Keep the columns "relevant", "constraint_message::English (en)" and "constraint_message::Deutsch (de)". 
Drop the question named "comments". 
Replace the existing file. {p_end}
{phang2}{cmd:. odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) replace}{p_end}

{pstd}Display required output below open-ended questions. 
Delete the words "Introduction" and "Vorstellung" from every question and answer. 
Clean the mark-up language and mark multiple-select questions. {p_end}
{phang2}{cmd:. odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple) replace}{p_end}

{pstd}Create a fully formatted questionnaire using the formatting options provided by the putdocx command.{p_end}
{p 8 12 2}{cmd:. odk2doc using "Example_xlsForm", to("Example_converted.docx") keep(relevant constraint_m) dropv(comments) fill del("Introduction" "Vorstellung") clean mark(multiple)}
{cmd: doc(land) fmt(border(all,nil)) tfmt(border(top,single) border(bottom,single) bold) qfmt(shading(lightsteelblue)) afmt(italic) replace}{p_end}



{title:Author}

Anna Reuter
