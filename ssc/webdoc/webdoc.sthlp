{smcl}
{* 11nov2019}{...}
{hi:help webdoc}{...}
{right:Jump to: {help webdoc##syntax:Syntax}, {help webdoc##description:Description}, {help webdoc##options:Options}, {help webdoc##examples:Examples}, {help webdoc##remarks:Remarks}, {help webdoc##results:Stored results}}
{right: Also see: {browse "http://repec.sowi.unibe.ch/stata/webdoc"}}
{hline}

{title:Title}

{pstd}{hi:webdoc} {hline 2} Create a HTML or Markdown document including Stata output

{marker syntax}{...}
{title:Syntax}

{pstd}
    Process a do-file containing {cmd:webdoc} commands

{p 8 15 2}
    {cmd:webdoc} {opt do} {it:filename} [{it:arguments}] [{cmd:,} {help webdoc##doopts:{it:do_options}} ]

{pstd}
    Commands to be used within the do-file

{p2colset 9 50 50 2}{...}
{p2col:{cmd:webdoc} {opt i:nit} [{it:docname}] [{cmd:,} {help webdoc##initopts:{it:init_options}}]}initialize
    the HTML or Markdown output document; (re)set default behavior

{p2col:{cmd:/***} {it:...} {cmd:***/}}add a block of text

{p2col:{cmd:webdoc} {opt sub:stitute} [{it:from} {it:to} {it:...}]  [{cmd:,} {opt a:dd}]}substitutions to be applied within {cmd:/*** ***/} blocks

{p2col:{cmd:webdoc}  {opt w:rite} {it:...}}write a line of text (excluding new-line character)

{p2col:{cmd:webdoc}  {opt put} {it:...}}write a line of text (including new-line character)

{p2col:{cmd:webdoc} {opt a:ppend} {it:filename} [{cmd:,} {help webdoc##appopts:{it:append_opts}}]}add the contents of a file

{p2col:{cmd:webdoc}  {opt toc} [{it:levels}] [{it:offset}] [{cmd:,} {help webdoc##tocopts:{it:...}}]}add
a table of contents

{p2col:{cmd:webdoc} {opt s:tlog} [{it:name}] [{cmd:,} {help webdoc##stlogopts:{it:stlog_options}}]}start
    a Stata log

{p2col:{cmd:webdoc} {opt s:tlog} {opt o:om} {it:cmdline}}suppress output of {it:cmdline} and insert an output-omitted tag

{p2col:{cmd:webdoc} {opt s:tlog} {opt q:uietly} {it:cmdline}}suppress output without inserting an output-omitted tag

{p2col:{cmd:webdoc} {opt s:tlog} {opt cnp}}insert a page break in the Stata log

{p2col:{cmd:webdoc} {opt s:tlog} {opt c:lose}}stop the Stata log

{p2col:{cmd:webdoc} {opt s:tlog} [{it:name}] {cmd:using} {it:dofile} [{cmd:,} {help webdoc##stlogopts:{it:...}}]}include a log from the commands in {it:dofile}

{p2col:{cmd:webdoc} {opt s:tlog} [{it:name}] [{cmd:,} {help webdoc##stlogopts:{it:...}}] {cmd::} {it:command}}include the output from {it:command}

{p2col:{cmd:webdoc} {opt loc:al} {it:name} {it:definition}}define and backup a local macro

{p2col:{cmd:webdoc} {opt gr:aph} [{it:name}] [{cmd:,} {help webdoc##gropts:{it:graph_options}}]}include a graph

{p2col:{cmd:webdoc} {opt c:lose}}close the output document

{p2col:{cmd:// webdoc exit}}let {cmd:webdoc do} exit the do-file

{pstd}
    Advanced: change HTML tag settings

{p 8 15 2}
    {cmd:webdoc} {opt set} [{help webdoc##set:{it:setname}} [{it:definition}]]]

{pstd}
    Remove all {cmd:webdoc} commands from a do-file

{p 8 15 2}
    {cmd:webdoc} {opt strip} {it:filename} {it:newname} [, {opt r:eplace} {opt a:ppend} ]


{synoptset 25 tabbed}{...}
{marker doopts}{col 5}{help webdoc##dooptions:{it:do_options}}{col 32}Description
{synoptline}
{synopt:[{cmd:{ul:no}}]{opt i:nit}[{cmd:(}{it:docname}{cmd:)}]}initialize the
    HTML or Markdown output document
    {p_end}
{synopt:{help webdoc##initopts:{it:init_options}}}options to be passed through
    to {cmd:webdoc init}
    {p_end}
{synopt:{opt nostop}}do not stop execution on error (not recommended)
    {p_end}
{synopt:{opt cd}}process the do-file within its home directory
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker initopts}{col 5}{help webdoc##initoptions:{it:init_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt r:eplace}}allow overwriting an existing output document
    {p_end}
{synopt:{opt a:ppend}}append output to an existing output document
    {p_end}
{synopt:{opt md}}use {cmd:.md} instead of {cmd:.html} as default suffix for the
    output document
    {p_end}
{synopt:{opt head:er}[{cmd:(}{help webdoc##headopts:{it:header_opts}}{cmd:)}]}create
    a standalone HTML document including a header and a footer
    {p_end}

{syntab :Log and graph options}
{synopt:[{cmd:no}]{opt logall}}whether to log all Stata output;
    the default is {cmd:nologall}
    {p_end}
{synopt:{help webdoc##stlogopts:{it:stlog_options}}}options to be passed
    through to {cmd:webdoc stlog}
    {p_end}
{synopt:{opt gr:opts}{cmd:(}{help webdoc##gropts:{it:graph_options}}{cmd:)}}options
    to be passed through to {cmd:webdoc graph}
    {p_end}

{syntab :Filenames/paths}
{synopt:[{cmd:no}]{opt logdir}[{cmd:(}{it:path}{cmd:)}]}where to store the
    Stata log files
    {p_end}
{synopt:{opt grdir(path)}}where to store the graph files
    {p_end}
{synopt:{opt dodir(path)}}where to store the optional do-files
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt p:refix}[{cmd:(}{it:prefix}{cmd:)}]}prefix for the automatic
    names
    {p_end}
{synopt:[{cmd:no}]{cmd:stpath}[{cmd:(}{it:path}{cmd:)}]}include-path to be used
    in the output document
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker headopts}{col 5}{help webdoc##headoptions:{it:header_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt w:idth(width)}}set maximum width of the page
    {p_end}
{synopt:{opt nofoot:er}}omit the footer
    {p_end}

{syntab :Meta data}
{synopt:{opt t:itle(str)}}provide a title for the meta data; default is the
    name of the document
    {p_end}
{synopt:{opt a:thor(str)}}provide author information for the meta data
    {p_end}
{synopt:{opt date(str)}}provide a date for the meta data
    {p_end}
{synopt:{opt des:cription(str)}}provide a description for the meta data
    {p_end}
{synopt:{opt k:eywords(str)}}provide a (comma separated) list of keywords for
    the meta data
    {p_end}
{synopt:{opt l:anguage(str)}}specify the language of the document; default is
    {cmd:en}
    {p_end}
{synopt:{opt char:set(str)}}specify the character encoding of the document;
    default is {cmd:utf-8}
    {p_end}

{syntab :Stylesheets}
{synopt:{opt bs:theme}[{cmd:(}{help webdoc##bsoptions:{it:spec}}{cmd:)}]}include
    a theme from {browse "http://bootswatch.com":bootswatch.com}
    {p_end}
{synopt:{opt incl:ude(filename)}}include the contents of {it:filename} in the
    header
    {p_end}
{synopt:{opt st:scheme}{cmd:(}{help webdoc##stsopts:{it:stscheme_opts}}{cmd:)}}specify
    the look of Stata output
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker stsopts}{col 5}{help webdoc##stsoptions:{it:stscheme_options}}{col 32}Description
{synoptline}
{syntab :Stata scheme}
{synopt:{opt s:tandard}}use scheme "Standard"
    {p_end}
{synopt:{opt stu:dio}}use scheme "Studio"
    {p_end}
{synopt:{opt c:lassic}}use scheme "Classic"
    {p_end}
{synopt:{opt d:esert}}use scheme "Desert"
    {p_end}
{synopt:{opt m:ountain}}use scheme "Mountain"
    {p_end}
{synopt:{opt o:cean}}use scheme "Ocean"
    {p_end}
{synopt:{opt si:mple}}use scheme "Simple"
    {p_end}

{syntab :Manual settings}
{synopt:{opt bg(color)}}specify background color
    {p_end}
{synopt:{opt fg(color)}}specify foreground color (standard text)
    {p_end}
{synopt:{opt rfg(color)}}specify color for results
    {p_end}
{synopt:{opt cfg(color)}}specify color for input (commands)
    {p_end}
{synopt:{opt rbf}}use bold font for results
    {p_end}
{synopt:{opt cbf}}use bold font for input (commands)
    {p_end}
{synopt:{opt lc:om}}italicize/shade comments in Stata output
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker appopts}{col 5}{help webdoc##appoptions:{it:append_options}}{col 32}Description
{synoptline}
{synopt:{opt sub:stitute(subst)}}apply substitutions; {it:subst} is {it:from} {it:to} [{it:from} {it:to} ...]
    {p_end}
{synopt:{opth drop(numlist)}}omit the specified lines
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker tocopts}{col 5}{help webdoc##tocoptions:{it:toc_options}}{col 32}Description
{synoptline}
{synopt:{opt n:umbered}}add section numbers
    {p_end}
{synopt:{opt md}}also look for Markdown headings
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker stlogopts}{col 5}{help webdoc##stlogoptions:{it:stlog_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt li:nesize(#)}}set the line width to be used in the output log
    (number of characters)
    {p_end}
{synopt:[{cmd:no}]{opt do}}whether to run the Stata commands; default is {cmd:do}
    {p_end}
{synopt:[{cmd:no}]{opt log}}whether to create a log and include it in the
    output document; default is {cmd:log}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt cmdl:og}}whether to display the code
    instead of an output log; default is {cmd:nocmdlog}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt dos:ave}}whether to store a copy of the commands
    in a do-file; default is {cmd:nodosave}
    {p_end}

{syntab :Contents}
{synopt:[{cmd:{ul:no}}]{opt o:utput}}whether to suppress output; default is
    {cmd:output}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt m:atastrip}}whether to strip Mata opening and ending
    commands; default is {cmd:nomatastrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt cmds:trip}}whether to strip command lines; default
    is {cmd:nocmdstrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt lbs:trip}}whether to strip line break
    comments; default is {cmd:nolbstrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt gts:trip}}whether to strip continuation
    symbols; default is {cmd:nogtstrip}
    {p_end}
{synopt:[{cmd:no}]{opt ltrim}}whether to remove indentation; default is {cmd:ltrim}
    {p_end}

{syntab :Highlighting}
{synopt:{opt mark(strlist)}}apply <mark> tag to specified strings
    {p_end}
{synopt:{cmd:tag(}{help webdoc##tag:{it:matchlist}}{cmd:)}}apply custom tags to specified strings
    {p_end}

{syntab :Technical}
{synopt:[{cmd:no}]{opt plain}}whether to omit markup; default is {cmd:noplain}
    {p_end}
{synopt:[{cmd:no}]{opt raw}}whether to omit markup and character
    substitutions; default is {cmd:noraw}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt c:ustom}}whether to use custom code to include the log
    file; default is {cmd:nocustom}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt k:eep}}whether to erase the external log file;
    default is {cmd:keep}
    {p_end}
{synopt:[{cmd:no}]{opt cert:ify}}whether to compare results against previous
    version; default is {cmd:nocertify}
    {p_end}
{synopt:[{cmd:no}]{opt sthlp}[{cmd:(}{help webdoc##sthlp:{it:spec}}{cmd:)}]}({cmd:webdoc stlog using}
    only) whether to treat as a Stata help file
    {p_end}
{synopt:{opt nostop}}({cmd:webdoc stlog using} only) do not stop execution on error
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker gropts}{col 5}{help webdoc##groptions:{it:graph_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt as(fileformats)}}output format(s); default is {cmd:as(png)}
    {p_end}
{synopt:{opt name(name)}}name of graph window to be exported
    {p_end}
{synopt:{it:override_options}}override conversion defaults; see help
    {helpb graph export}
    {p_end}

{syntab :Attributes}
{synopt:{opt alt(string)}}provide an alternative text for the image; default is
    the graph name
    {p_end}
{synopt:{opt t:itle(string)}}provide a "tooltip" title for the image
    {p_end}
{synopt:{opt att:ributes(args)}}further attributes to be passed through to the
    {cmd:<img>} tag
    {p_end}

{syntab :Environment}
{synopt:[{cmd:{ul:no}}]{opt l:ink}[{cmd:(}{it:fileformat}{cmd:)}]}whether to add a link to the
    graph file; default is {cmd:link} (unless {cmd:hardcode} is specified)
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt f:igure}[{cmd:(}{it:id}{cmd:)}]}whether to use the
    figure tag; default is {cmd:figure}
    {p_end}
{synopt:{opt cap:tion(string)}}provide a caption for the figure
    {p_end}
{synopt:{opt ca:bove} or {opt cb:elow}}where to place the caption; default is
    {cmd:cbelow}
    {p_end}

{syntab :Technical}
{synopt:[{cmd:{ul:no}}]{opt h:ardcode}}whether to embed the graph in the output
    document (PNG, GIF, JPEG, and SVG only); default is {cmd:nohardcode}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt k:eep}}whether to erase the external graph file
    if {cmd:hardcode} is specified; default is {cmd:keep}
    {p_end}
{synopt:[{cmd:no}]{opt custom}}whether to use custom code to include the
    graph; default is {cmd:nocustom}
    {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
    {cmd:webdoc} provides tools to create a HTML or Markdown document from
    within Stata in a weaving fashion (also see
    {browse "http://ideas.repec.org/p/bss/wpaper/22.html":Jann 2015}). The
    basic procedure is to write a do-file including Stata commands and sections
    of HTML or Markdown code and then process the do-file by {cmd:webdoc do}.
    {cmd:webdoc do} will create the output document, possibly including graphs
    and sections of Stata output. {cmd:webdoc do} is similar to the regular
    {helpb do} command; {it:arguments}, if specified, will be passed to the do-file
    as local macros; see {manlink R do}.

{pstd}
    Within the do-file, use {cmd:webdoc init} {it:docname} to
    initialize the output document, where {it:docname} is the name
    document (possibly including a path; depending on option {cmd:md},
    default suffix ".html" or ".md" will be added to {it:docname} if no suffix
    is specified). Alternatively, if the do-file does
    not contain a {cmd:webdoc init} {it:docname} command, {cmd:webdoc do} will
    automatically initialize the document in the folder of the do-file
    using {it:basename}{cmd:.html} or {it:basename}{cmd:.md} as name for the
    document, where {it:basename} is the name of the do-file without
    suffix. Furthermore, {cmd:webdoc init} without {it:docname} can
    be used within the do-file to change settings after the document has been
    initialized.

{pstd}
    Thereafter, use the {cmd:/*** ***/} delimiter structure to include blocks
    of HTML or Markdown text. A block may span multiple lines. The opening tag
    ({cmd:/***}) must be at the beginning of a line (save white space); the
    closing tag ({cmd:***/}) must be at the end of a line (save white space).
    Macros in the text provided within {cmd:/*** ***/} will not be expanded.
    You can, however, use the {cmd:webdoc substitute} command to define text
    substitutions that will be applied (see
    {help webdoc##substitute:{it:webdoc substitute}} under
    {help webdoc##remarks:{it:Remarks}} below; furthermore, also see the remark
    on {help webdoc##local:{it:webdoc local}}).

{pstd}
    A single line of HTML/Markdown can also be provided by the
    {cmd:webdoc write} command or the {cmd:webdoc put} command.
    {cmd:webdoc put} includes a new-line character at the end of the line;
    {cmd:webdoc write} omits the new-line character, so that more text can be
    added to the same line later on. Stata macros in the provided text will be
    expanded before writing the line to the output document. Furthermore, to
    copy text from an external file into the output document, you can use the
    {cmd:webdoc append} command.

{pstd}
    The {cmd:webdoc toc} command creates a table of contents (TOC)
    from the HTML or Markdown headings in the document. The TOC will be inserted
    at the position where {cmd:webdoc toc} appears; only headings provided in
    subsequent {cmd:/*** ***/} blocks will be included in the TOC. Argument {it:levels}
    specifies the desired number of levels to be considered. For example
    {cmd:webdoc toc 3} will create a table of contents with three levels from {cmd:<h1>}
    to {cmd:<h3>}. Furthermore, the {it:offset} argument shifts the highest level
    to be taken into account. For example, {cmd:webdoc toc 3 1} will
    use {cmd:<h2>}, {cmd:<h3>}, and {cmd:<h4>} or {cmd:webdoc toc 2 4} will use
    {cmd:<h5>} and {cmd:<h6>}. {it:offset} must be an integer between 0 and 5;
    the default is 0. {it:levels} must be an integer between 1 and 6-{it:offset};
    the default is 3. To add section numbers to the headings specify the
    {cmd:numbered} option; to look for Markdown headings (lines starting with
    {cmd:#}, {cmd:##}, etc.) in addition to HTML headings, specify the {cmd:md} 
    option. In HTML headings, an id can be provided using the {cmd:id} 
    attribute, as in {cmd:<h3 id="}{it:myid}{cmd:">}. {cmd:webdoc toc} will then
    use {it:myid} to refer to the heading. If no id is specified, {cmd:webdoc toc}
    makes up an own id.

{pstd}
    To create a section containing Stata output, use the {cmd:webdoc stlog}
    command. {cmd:webdoc stlog} writes the Stata output to a
    log file and then copies the contents of the log file to the
    output document. {cmd:webdoc stlog} creates an automatic name for the
    output file, but you can also specify a custom name typing
    {bind:{cmd:webdoc stlog} {it:name}} (possibly including a relative
    path).

{pstd}
    Within a Stata output section
    {bind:{cmd:webdoc stlog oom} {it:cmdline}} can be used to suppress the
    output of a specific command and add an output-omitted note in the
    Stata output file. Alternatively, to suppress output without
    adding an output-omitted tag, type
    {bind:{cmd:webdoc stlog quietly} {it:cmdline}}. Furthermore,
    {cmd:webdoc stlog cnp} can be used to insert a page break within a Stata
    output section.

{pstd}
    {cmd:webdoc stlog close} marks the end of a Stata output section. To
    include the Stata output from an external do-file, use
    {cmd:webdoc stlog using} {it:filename}
    where {it:filename} is the name of the do-file. Furthermore, to include
    just the output of a single command (without input), you can type
    {cmd:webdoc stlog :} {it:command}. {cmd:webdoc stlog close} is not needed
    after the using-form or the colon-form of {cmd:webdoc stlog}.

{pstd}
    Instead of selecting the Stata output to be included in the document
    using {cmd:webdoc stlog}, you can also specify the {cmd:logall} option with
    {cmd:webdoc do} or {cmd:webdoc init}. In this case, all Stata output will be
    included in the document.

{pstd}
    {cmd:webdoc local} can be used within or after a Stata output section to define a local
    macro that will be backed up on disk. This is useful if you want include
    specific results in your text and want to ensure that the results will be available
    in later runs when suppressing the Stata commands using the {cmd:nodo}
    option. The syntax of {cmd:webdoc local} is the same as the syntax of
    Stata's regular {helpb local} command. Local macros defined by
    {cmd:webdoc local} will be expanded in subsequent {cmd:/*** ***/}
    blocks (up until the next {cmd:webdoc stlog} command). For further
    information, see {help webdoc##local:{it:webdoc local}} under
    {help webdoc##remarks:{it:Remarks}} below.

{pstd}
    {cmd:webdoc graph} exports the current graph and includes
    appropriate code in the output document to display graph. {cmd:webdoc graph}
    can be specified within a {cmd:webdoc stlog} section or directly after
    {cmd:webdoc stlog close}. If {cmd:webdoc graph} is specified within a
    {cmd:webdoc stlog} section, the graph is included in the document
    before the Stata output; if {cmd:webdoc graph} is specified after
    {cmd:webdoc stlog close}, the graph is included after the Stata output
    (furthermore, if {cmd:webdoc graph} is used outside a {cmd:webdoc stlog}
    section while {cmd:logall} is on, the graph will be placed at the
    position in the output where the {cmd:webdoc graph} command occurs). Unless
    a custom {it:name} is specified, the name of the {cmd:webdoc stlog} section is used
    to name the graph (possibly suffixed by a counter if the {cmd:webdoc stlog}
    section contains more than one {cmd:webdoc graph} command).

{pstd}
    {cmd:webdoc close} closes the HTML/Markdown document. This is not
    strictly needed as {cmd:webdoc do} closes the document automatically
    if the do-file does not contain a {cmd:webdoc close} command. Furthermore,
    to exit a do-file before the end of the file, add a line
    containing {cmd:// webdoc exit} (without anything else on the same line).
    {cmd:webdoc do} will only read the do-file up to this line.

{pstd}
    {cmd:webdoc} uses a specific set of HTML tags to include and format the
    Stata outputs and graphs. The definitions of these tags can be changed
    within the do-file by the {cmd:webdoc set} command. For details,
    see {help webdoc##set:{it:Changing the HTML settings}} under
    {help webdoc##remarks:{it:Remarks}} below. Specifying {cmd:webdoc set}
    without argument restores the default settings.

{pstd}
    {cmd:webdoc strip} removes all {cmd:webdoc} commands and all
    {cmd:/*** ***/} blocks from a do-file.


{marker options}{...}
{title:Options}

    {help webdoc##dooptions:Options for webdoc do}
    {help webdoc##initoptions:Options for webdoc init}
    {help webdoc##appoptions:Options for webdoc append}
    {help webdoc##tocoptions:Options for webdoc toc}
    {help webdoc##stlogoptions:Options for webdoc stlog}
    {help webdoc##groptions:Options for webdoc graph}
    {help webdoc##stripoptions:Options for webdoc strip}


{marker dooptions}{...}
{title:Options for webdoc do}

{phang}
    [{cmd:no}]{opt i:nit}[{cmd:(}{it:docname}{cmd:)}] specifies whether and how
    to initialize the output document. If the processed do-file contains an
    initialization command (i.e. if the do-file contains
    {cmd:webdoc init} {it:docname}) or if the document is already open
    (e.g. in a nested application of {cmd:webdoc do}), the default for
    {cmd:webdoc do} is not to initialize the document. Otherwise,
    {cmd:webdoc do} will automatically initialize the output document in the
    folder of the do-file using name {it:basename}{cmd:.html} (or, if option {cmd:md}
    is specified, {it:basename}{cmd:.md}), where {it:basename} is the
    name of the do-file without suffix. Use the {cmd:init} option to override
    these defaults: {cmd:noinit} will
    deactivate automatic initialization; {cmd:init} will enforce automatic
    initialization; {cmd:init(}{it:docname}{cmd:)} will enforce initialization
    using {it:docname} as name for the document ({it:docname} may include
    an absolute or relative path; the base folder is the current working
    directory or the folder of the do-file, depending on whether option
    {cmd:cd} is specified).

{phang}
    {help webdoc##initoptions:{it:init_options}} are options to specify defaults
    to be passed through to {cmd:webdoc init}. See below.

{phang}
    {cmd:nostop} allows continuing execution even if an error occurs. Use the
    {cmd:nostop} option if you want to make sure that {cmd:webdoc do} runs the
    do-file all the way to the end even if some of the commands return error.
    Usage of this option is not recommended. Use the {cmd:nostop} option with
    {cmd:webdoc stlog using} if you want to log output from a command that
    returns error.

{phang}
    {opt cd} changes the working directory to the directory of the specified
    do-file for processing the do-file and restores the current working directory
    after termination. The default is not to change the working directory.


{marker initoptions}{...}
{title:Options for webdoc init}

{dlgtab:Main}

{phang}
    {opt replace} allows overwriting an existing output document.

{phang}
    {opt append} appends results to an existing output document.

{phang}
    {opt md} specifies that ".md" instead of ".html" is to be used as default
    suffix for the output document.

{marker headoptions}{...}
{phang}
    {opt header}[{cmd:(}{it:header_opts}{cmd:)}] causes a HTML header (and a footer)
    to be added to the output document. {it:header_opts} are as follows.

{phang2}
    {opt width(width)} sets the maximum width of the HTML page, where {it:width}
    is a width specification in
    {browse "http://www.w3schools.com/cssref/css_units.asp":CSS units},
    such as {cmd:800px} or {cmd:50em}. If you use the {cmd:bstheme()} option,
    an alternative approach is to include the body of your page in a container,
    e.g. type {cmd:<div class="container-fluid" style="max-width:800px">} on
    the first line and {cmd:</div>} on the last line.

{phang2}
    {cmd:nofooter} omits the footer. This is useful if you want to append
    more material to the same document later on.

{phang2}
    {opt title(str)} provides a title for the meta data of the page. The default is to
    use the name of the document as title.

{phang2}
    {opt author(str)}, {opt date(str)}, {opt description(str)}, and
    {opt keywords(str)} provide author information, a date, a description and a
    (comma separated) list of keywords to be included in the meta data of the page.

{phang2}
    {opt language(str)} specifies the language of the document, where {it:str}
    is a
    {browse "https://www.w3.org/International/articles/language-tags/":HTML language}
    specification. The default is {cmd:language(en)}.

{phang2}
    {opt charset(str)} specifies the character encoding of the document, where
    {it:str} is a {browse "http://www.w3schools.com/html/html_charset.asp":HTML charset}
    specification. The default depends on the Stata version. If you use Stata 13 or
    older, the default is {cmd:charset(iso-8859-1)} (Windows, Unix) or
    {cmd:charset(mac)} (MacOSX). If you use Stata 14 or newer, the default is
    {cmd:charset(utf-8)}.

{marker bsoptions}{...}
{phang2}
    {opt bstheme}[{cmd:(}{it:spec}{cmd:)}] includes a
    {browse "http://getbootstrap.com/":Bootstrap} CSS file in the
    header. {it:spec} is

                [{it:theme}] [, {opt js:cript} {opt s:elfcontained} ]

{pmore2}
    where {it:theme} is either equal to {cmd:default} (for the default
    Bootstrap CSS) or equal to the name (in lowercase letters) of a
    {browse "http://bootswatch.com":Bootswatch} theme (such as {cmd:cerulean},
    {cmd:cosmo}, {cmd:simplex}, {cmd:united}, etc.; see
    {browse "http://bootswatch.com":bootswatch.com} or
    {browse "https://www.bootstrapcdn.com/bootswatch/":www.bootstrapcdn.com/bootswatch}
    for the list of available themes). If {it:theme} is omitted, the default
    Bootstrap CSS is used. In addition to the Bootstrap CSS, {cmd:webdoc} will
    append a few additional CSS definitions to sightly modify the display of
    images and code. Furthermore, if you use the {cmd:bstheme()} option, you
    should consider specifying a maximum page width using the {cmd:width()}
    option or including the body of your page in a container, e.g. typing
    {cmd:<div class="container-fluid" style="max-width:800px">} on the first
    line and {cmd:</div>} on the last line. In general, for more information on
    Bootstrap, see {browse "http://getbootstrap.com/":getbootstrap.com}.

{pmore2}
    By default, {cmd:webdoc} does not load Bootstrap's JavaScript plugins.
    Specify suboption {cmd:jscript} if you want to use Bootstrap elements that
    require JavaScript. {cmd:webdoc} will then add code at the end of the
    document to load the relevant plugins (also see
    {browse "http://getbootstrap.com/getting-started/#template":getbootstrap.com/getting-started/#template}).

{pmore2}
    Unless suboption {cmd:selfcontained} is specified, {cmd:webdoc} includes
    the Bootstrap CSS and JavaScript plugins using links pointing to the minified
    files at {browse "https://www.bootstrapcdn.com/":bootstrapcdn.com}. Specify
    {cmd:selfcontained} to copy the (non-minified versions of
    the) files into you document (this will increase the file size of your
    document by about 150 KB or, if {cmd:jscript} is specified, by about
    500 KB). For larger projects it may make sense to provide a copy of the CSS
    and JavaScript files at your website and include them in your HTML pages
    using local links.

{pmore2}
    If the {cmd:bstheme} option is omitted, a minimum set of CSS definitions
    resulting in a plain look will be included in the header of the document.

{phang2}
    {opt include(filename)} adds the contents of {it:filename} the the HTML
    header. The contents of {it:filename} will be included within the
    {cmd:<head>} tag after the definitions requested by the {cmd:bstheme()}
    option.

{marker stsoptions}{...}
{phang2}
    {cmd:stscheme(}{it:stscheme_options}{cmd:)} specifies the look of the Stata
    output sections. This has only an effect on sections containing
    Stata output, but not on sections containing Stata code. That is, sections
    created by the {helpb webdoc##cmdlog:cmdlog} option (see below) will not be
    affected by {cmd:stscheme()}. Note that, currently, {cmd:webdoc} does not
    tag errors and links in the Stata logs, so that these elements will appear
    as regular output. {it:stscheme_options} are as follows.

{phang3}
    {cmd:standard}, {cmd:studio}, {cmd:classic}, {cmd:desert}, {cmd:mountain},
    {cmd:ocean}, or {cmd:simple} select one of Stata's built-in color
    schemes (see the preferences dialog of Stata's Results window; you can
    right-click on the Results window to open the dialog).

{phang3}
    {opt bg(color)}, {opt fg(color)}, {opt rfg(color)}, {opt cfg(color)}, {opt rbf}, and
    {opt cbf} affect the appearance of the different elements in the
    Stata output, where {it:color} is a
    {browse "http://www.w3schools.com/colors/default.asp":CSS color}
    specification. These options override the corresponding settings from the built-in
    schemes. {cmd:bg()} specifies the background color, {cmd:fg()}
    the default foreground color (i.e. the color of standard output),
    {cmd:rfg()} the color of results (typically the numbers in the output), and
    {cmd:cfg()} the color of input (the commands). Furthermore, use {opt rbf} and
    {opt cbf} to request bold font for results and input/commands, respectively.

{phang3}
    {opt lcom} italicizes and shades comments in the Stata output.

{dlgtab:Log and graph options}

{phang}
    [{cmd:no}]{cmd:logall} specifies whether to include the output of all Stata
    commands in the output document. The default is {cmd:nologall}, that is, to
    include only the output selected by {cmd:webdoc stlog}. Specify
    {cmd:logall} if you want to log all output. When {cmd:logall}
    is specified, {cmd:webdoc do} will insert appropriate {cmd:webdoc stlog}
    and {cmd:webdoc stlog close} commands automatically at each
    {cmd:/*** ***/} block and each {cmd:webdoc} command (but not at
    {cmd:webdoc stlog oom} and {cmd:webdoc stlog cnp}). Empty lines (or lines
    that only contain white space) at the beginning and end of each
    section of commands will be omitted.

{phang}
    {help webdoc##stlogoptions:{it:stlog_options}} are options to set the default
    behavior of {cmd:webdoc stlog}. See below.

{phang}
    {opt gropts}{cmd:(}{help webdoc##groptions:{it:graph_options}}{cmd:)}
    specifies default options to be passed through to {cmd:webdoc graph}. See
    below. Updating {cmd:gropts()} in repeated calls to {cmd:webdoc init} will
    replace the option as a whole.

{dlgtab:Filenames/paths}

{phang}
    [{cmd:no}]{opt logdir}[{cmd:(}{it:path}{cmd:)}] specifies where to store
    the Stata output log files. The default is {cmd:nologdir}, in which case
    the log files are stored in the same directory as the output document, using
    the name of the output document as a prefix for the names of the log files;
    also see the {cmd:prefix()} option. Option {cmd:logdir} without argument
    causes the log files to be stored in a subdirectory with the same name as
    the output document. Option {opt logdir(path)} causes the log files to be
    stored in subdirectory {it:path}, where {it:path} is a relative path starting
    from the folder of the output document.

{phang}
    {opt grdir(path)} specifies an alternative subdirectory to be used by
    {cmd:webdoc graph} for storing the graph files, where {it:path} is a relative
    path starting from the folder of the output document. The default is to
    store the graphs in the same directory as the log files.

{phang}
    {opt dodir(path)} specifies an alternative subdirectory to be used by
    {cmd:webdoc stlog} for storing the do-files requested by the {cmd:dosave}
    option (see below), where {it:path} is a relative path starting from the
    folder of the output document. The default is to store the do-files
    in the same directory as the log files.

{phang}
    [{cmd:no}]{opt prefix}[{cmd:(}{it:prefix}{cmd:)}] specifies a prefix for
    the automatic names of the Stata output log files and graphs. The names are
    constructed as "{it:prefix}#", where # is a counter (i.e., {cmd:1},
    {cmd:2}, {cmd:3}, etc.). Option {cmd:noprefix} omits the prefix; option
    {cmd:prefix} without argument causes "{it:basename}{cmd:_}" to be used as
    prefix, where {it:basename} is the name of the output document (without
    path); option {opt prefix(prefix)} causes {it:prefix} to be used as prefix.
    The default prefix is empty if {cmd:logdir} or {opt logdir(path)} is
    specified; otherwise the default prefix is equal to "{it:basename}{cmd:_}"
    (note that reinitializing {cmd:logdir} may reset the prefix).
    Furthermore, the prefix will be ignored if a custom {it:name} is provided
    when calling {cmd:webdoc stlog}. The suffix of the physical log files on
    disk is always ".log".

{phang}
    [{cmd:no}]{cmd:stpath}[{cmd:(}{it:path}{cmd:)}] specifies how the path for
    linking files in the output document is to be constructed
    ({cmd:stpath()} has no effect on where the log files and graphs are stored
    in the file system). If {cmd:stpath} is specified without argument, then
    the path of the output document (to be precise, the path specified
    in {it:docname} when initializing the output document) is added to
    the include-path. Alternatively, specify {opt stpath(path)} to add a custom
    path. The default is {cmd:nostpath}.


{marker appoptions}{...}
{title:Options for webdoc append}

{phang}
    {opt substitute(subst)} causes the specified substitutions to be applied
    before copying the file into the output document, where {it:subst} is

            {it:from} {it:to} [{it:from} {it:to} {it:...}]

{pmore}
    All occurrences of {it:from} will be replaced by {it:to}. Include {it:from}
    and {it:to} in double quotes if they contain spaces. For example, to
    replace "{cmd:@title}" by "{cmd:My Title}" and "{cmd:@author}" by
    "{cmd:My Name}", you could type
    {cmd:substitute(@title "My Title" @author "My Name")}.

{phang}
    {opth drop(numlist)} causes the specified lines to be omitted when
    copying the file.


{marker tocoptions}{...}
{title:Options for webdoc toc}

{phang}
    {cmd:numbered} causes section numbers be added to the headings and
    the entries in table of contents. The numbers added to the headings will
    be tagged by {cmd:<span class="heading-secnum">}; the numbers in the
    table of contents will be tagged by {cmd:<span class="toc-secnum">}.

{phang}
    {cmd:md} specifies that Markdown headings are to be taken into account. By
    default, only HTML headings, that is, lines starting with {cmd:<h1>} to
    {cmd:<h6>}, are collected. If {cmd:md} is specified, lines starting with
    {cmd:#} to {cmd:######} are also treated as headings. In any case, a
    heading will only be detected if the heading tag is at the beginning of the
    line (save white space in case of HTML tags). To construct the entry in the
    table of contents, only the text that follows on the same line will be used.


{marker stlogoptions}{...}
{title:Options for webdoc stlog}

{dlgtab:Main}

{phang}
    {opt linesize(#)} sets the line width (number of characters) to be used
    in the output log. {it:#} must be an integer between between 40 and 255. The
    default is to use the current {helpb set linesize} setting.

{phang}
    [{cmd:no}]{cmd:do} specifies whether to run the Stata commands. The
    default is {cmd:do}, i.e. to run the commands. Type {cmd:nodo} to skip
    the commands and not write a new log file. {cmd:nodo} is useful if the
    Stata commands have been run before and did not change. For example, specify
    {cmd:nodo} if all Stata output sections are complete and you want to work
    on the text without having to re-run the Stata commands. Note that the
    automatic names of Stata output sections change
    if the order of Stata output sections changes. That is, {cmd:nodo} should only be
    used as long as the order did not change or if fixed names were assigned
    to the Stata output sections. An exception is if {cmd:nodo} is used together with
    the {cmd:cmdlog} option (see below). In this case the log file
    will always be recreated (as running the commands is not necessary to
    recreate the log file).

{phang}
    [{cmd:no}]{cmd:log} specifies whether the Stata output is to be logged and
    included in the output document. The default is {cmd:log}, i.e. to log and
    include the Stata output. If you type {cmd:nolog}, the commands will be run
    without logging. {cmd:nolog} does not appear to be particularly useful as
    you could simply include the corresponding Stata commands in the do-file
    without using {cmd:webdoc stlog}. However, {cmd:nolog} may be helpful in
    combination with the {cmd:nodo} option. It provides a way to include
    unlogged commands in the do-file that will not be executed if
    {cmd:nodo} is specified. Furthermore, {cmd:nolog} can be
    used to deselect output if the {cmd:logall} option has been specified.

{marker cmdlog}{...}
{phang}
    [{cmd:no}]{cmd:cmdlog} specifies whether to print a plain copy of the Stata
    code instead of using a Stata output log. The default is {cmd:nocmdlog},
    i.e. to include a Stata output log. If you type {cmd:cmdlog} then only a
    copy of the commands without output will be included (note that the
    commands will still be executed; add the {cmd:nodo} option if you want to
    skip running the commands). {cmd:cmdlog} is similar to {cmd:nooutput} (see
    below). A difference is that {cmd:nooutput} prints ". " at the beginning of
    each command, whereas {cmd:cmdlog} displays a plain copy of the commands.
    Furthermore, {cmd:<pre id="}{it:id}{cmd:" class="stcmd"><code>} will be
    used to start a {cmd:cmdlog} section in the HTML file, whereas other Stata
    output sections will be started by
    {cmd:<pre id="}{it:id}{cmd:" class="stlog"><samp>}. Note that
    {cmd:cmdlog} can be combined with {cmd:nodo} to include a copy of the
    commands without executing the commands. {cmd:cmdlog} is not allowed with
    the colon-form of {cmd:webdoc stlog}.

{phang}
    [{cmd:no}]{opt dosave} specifies whether to store a copy of the commands
    in an external do-file. The default is {cmd:nodosave}, i.e. not to store a
    do-file. The name of the Stata output section is used as name for the
    do-file (with suffix ".do"). The do-files will be stored in the same location
    as the log files, unless an alternative location is specified using the
    {cmd:dodir()} option. All {cmd:webdoc} commands will be stripped from
    the do-file.

{dlgtab:Contents}

{phang}
    [{cmd:no}]{cmd:output} specifies whether to suppress command output in the
    log. The default is {cmd:output}, i.e. to display the output. If
    {cmd:nooutput} is specified, {cmd:set output inform} is applied before
    running the commands and, after closing the log, {cmd:set output proc} is
    applied to turn output back on (see {helpb set output}). {cmd:nooutput} has no
    effect if {cmd:cmdlog} is specified. Furthermore, {cmd:nooutput} has no
    effect if specified with the using-form or the colon-form of {cmd:webdoc stlog}.

{phang}
    [{cmd:no}]{cmd:matastrip} specifies whether to strip Mata opening and ending
    commands from the Stata output. The default is {cmd:nomatastrip},
    i.e. to retain the Mata opening and ending commands. If you type
    {cmd:matastrip}, the {cmd:mata} or {cmd:mata:} command invoking Mata
    and the subsequent {cmd:end} command exiting Mata will be removed
    from the log. {cmd:matastrip} only has an effect if the Mata opening
    command is on the first line of the output section.

{phang}
    [{cmd:no}]{cmd:cmdstrip} specifies whether to strip command lines (input) from the
    Stata output. The default is {cmd:nocmdstrip}, i.e. to retain the
    command lines. Specify {cmd:cmdstrip} to delete the command lines. Specifically,
    all lines starting with ". " (or ": " in Mata) and subsequent lines
    starting with "> " will be removed. {cmd:cmdstrip} has no effect if
    {cmd:cmdlog} is specified.

{phang}
    [{cmd:no}]{cmd:lbstrip} specifies whether to strip line break comments
    from command lines in the Stata output. The default is
    {cmd:nolbstrip}, i.e. not to strip the line break comments. Specify
    {cmd:lbstrip} to delete the line break comments. Specifically, " ///..." at the
    end of command lines will be removed.

{phang}
    [{cmd:no}]{cmd:gtstrip} specifies whether to strip continuation symbols
    from command lines in the Stata output. The default is {cmd:nogtstrip},
    i.e. not to strip the continuation symbols. Specify {cmd:gtstrip} to delete
    the continuation symbols. Specifically, "> " at the beginning of
    broken command lines will be replaced by white space. {cmd:gtstrip} has
    no effect if {cmd:cmdlog} is specified.

{phang}
    [{cmd:no}]{cmd:ltrim} specifies whether to remove indentation of
    commands (i.e. whether to remove white space on the left of
    commands) before running the commands and creating the log. The default
    is {cmd:ltrim}, that is, to remove indentation. The amount of white space
    to be removed is determined by the minimum indentation in the block of
    commands. {cmd:ltrim} has no effect on commands
    called from an external do-file by {cmd:webdoc stlog using}.

{dlgtab:Highlighting}

{phang}
    {opt mark(strlist)} applies the <mark> tag to all occurrences of the
    specified strings, where {it:strlist} is

            {it:string} [{it:string} ...]

{pmore}
    Enclose {it:string} in double quotes if it contains blanks; use compound
    double quotes if {it:string} contains double quotes.

{marker tag}{...}
{phang}
    {opt tag(matchlist)} applies custom tags to all occurrences of the
    specified strings, where {it:matchlist} is

            {it:strlist} {cmd:=} {it:begin} {it:end} [ {it:strlist} {cmd:=} {it:begin} {it:end} ... ]

{pmore}
    and {it:strlist} is

            {it:string} [{it:string} ...]

{pmore}
    {it:strlist} specifies the strings to be tagged, {it:begin} specifies the
    start tag, {it:end} specifies the end tag. Enclose an element in double
    quotes if it contains blanks; use compound double quotes if the element
    contains double quotes.

{dlgtab:Technical}

{phang}
    [{cmd:no}]{opt plain} specifies whether to omit markup in the log
    file. The default is {cmd:noplain}, that is, to annotate the log file with
    HTML tags. In particular, input (commands) will be tagged using
    {cmd:<span class="stinp">}, results will be tagged using
    {cmd:<span class="stres">}, and comments will be tagged using
    {cmd:<span class="stcmt">} (if {cmd:cmdlog} is specified, only
    comments will be tagged). Specify {cmd:plain} to omit the HTML tags.

{phang}
    [{cmd:no}]{opt raw} specifies whether to omit markup in the log
    file and retain special characters. The default is {cmd:noraw}, that is,
    to annotate the log file with HTML tags (see the {cmd:plain} option
    above) and to replace characters "<", ">", and "&" by their HTML equivalents
    "&lt;", "&gt;", and "&amp;". Specify {cmd:raw} to omit the HTML tags and
    retain the special characters.

{phang}
    [{cmd:no}]{cmd:custom} specifies whether to use custom code to include the log
    file in the output document. The default is {cmd:nocustom}, i.e. to use
    standard code to include the log. Specify {cmd:custom} if you want to skip
    the standard code and take care of including the log yourself.

{phang}
    [{cmd:no}]{cmd:keep} specifies whether the external log file will be
    kept. The default is {cmd:keep}, i.e. to keep the log file so that
    {cmd:nodo} can be applied later on. Type {cmd:nokeep} if you want to erase
    the external log file.

{phang}
    [{cmd:no}]{opt certify} specifies whether to compare the current results
    to the previous version of the log file (if a previous version exists). The
    default is {cmd:nocertify}. Specify {cmd:certify} if you want to confirm
    that the output did not change. In case of a difference, {cmd:webdoc} will
    stop execution and display an error message. {cmd:certify} has no effect if
    {cmd:nolog} or {cmd:cmdlog} is specified or if a help file is processed
    (see the {cmd:sthlp} option below).

{marker sthlp}{...}
{phang}
    [{cmd:no}]{cmd:sthlp}[{cmd:(}{it:spec}{cmd:)}] specifies whether to treat
    the provided file as a Stata help file. This is only allowed with
    {cmd:webdoc stlog using}. By default, files with a {cmd:.hlp} or
    {cmd:.sthlp} suffix are treated as help files; all other files are treated
    as do-files. Type {cmd:nosthlp} or {cmd:sthlp} to override these
    defaults. Files treated as help files are translated by undocumented
    {cmd:log webhtml} (or, if {cmd:plain} or {cmd:raw} is specified, by
    {helpb translate} with the {cmd:smcl2log} translator) and are not submitted
    to Stata for execution. Unless {cmd:plain} or {cmd:raw} is specified,
    text markup and help links are preserved. Internal help links (i.e. links
    pointing to the processed help file) will be converted to appropriate
    internal links in the output document; other help links will be converted
    to links pointing to the corresponding help file at
    {browse "http://www.stata.com":www.stata.com}. In addition, you may provide
    a custom list of substitutions in {opt sthlp(spec)}, where {it:spec} is

            [{it:from} {it:to} [{it:from} {it:to} {it:...}]] [{cmd:,} {opt noid} ]

{pmore}
    The custom substitutions will be applied before converting the internal links
    and the stata.com links (unless {cmd:plain} or {cmd:raw} is specified, in which
    case no substitutions will be applied). The help links written by {cmd:log webhtml} are
    constructed as {cmd:<a href="/help.cgi?}{it:...}{cmd:">}. Hence, you could,
    for example, type {cmd:sthlp(/help.cgi?mycommand mycommand.html)} convert
    the help links for {cmd:mycommand} to links pointing to the local
    page {cmd:mycommand.html}. Suboption {cmd:noid} requests that no log-id
    be included in internal links. The default is to include a log-id to prevent
    name conflicts.

{pmore}
    Options {cmd:nolog}, {cmd:cmdlog}, and {cmd:dosave} are not allowed
    in help-file mode. Furthermore, contents options such as {cmd:nooutput},
    {cmd:cmdstrip}, or {cmd:matastrip} will have no effect. However, you may use
    {cmd:nodo} to prevent re-processing the help file or {cmd:custom} to use custom
    inclusion code. By default, the included help file will be wrapped by
    a {cmd:<pre class="sthlp">} tag.

{phang}
    {cmd:nostop} allows continuing execution even if an error occurs. Use the
    {cmd:nostop} option if you want to log output from a command that returns
    error. The {cmd:nostop} option is only allowed with {cmd:webdoc stlog using}.


{marker groptions}{...}
{title:Options for webdoc graph}

{dlgtab:Main}

{phang}
    {opt as(fileformats)} sets the output format(s). The default is
    {cmd:as(png)}. See help {helpb graph export} for available formats. Multiple 
    formats may be specified, e.g. {cmd:as(png pdf)}, in which case 
    {cmd:webdoc graph} will create multiple graph files. The first format will
    be used for the image in the output document.

{phang}
    {opt name(name)} specifies the name of the graph window to be
    exported. The default is to export the topmost graph.

{phang}
    {it:override_options} are format-dependent options to modify how the
    graph is converted. See help {helpb graph export} for details. For
    PNG, TIFF, GIF, and JPG, a default graph width of 500 pixels is used, unless 
    {cmd:width()} or {cmd:height()} is specified.

{dlgtab:Attributes}

{phang}
    {opt alt(string)} provides an alternative text for the image to be added
    to the {cmd:<img>} tag using the {cmd:alt} attribute. The default is to use the
    name of the graph as alternative text. The {cmd:alt()} option has no effect
    if embedding an SVG using the {cmd:hardcode} option.

{phang}
    {opt title(string)} provides a "tooltip" title for the image to be added to
    the {cmd:<img>} tag using the {cmd:title} attribute.

{phang}
    {opt attributes(args)} provides further attribute definitions to be added
    to the {cmd:<img>} tag. For example, to set the display width of the graph to
    50%, type {cmd:attributes(width="50%")}.

{dlgtab:Environment}

{phang}
    [{cmd:no}]{opt link}[{cmd:(}{it:fileformat}{cmd:)}] specifies whether to
    add a link to the image pointing to the graph file. Clicking the image in
    the browser will then open the graph file. The default is {cmd:link},
    i.e. to add a link, unless {cmd:hardcode} is specified, in which case
    {cmd:nolink} is the default. Argument {it:fileformat} may be used to select
    the file for the link if multiple output formats have been requested by
    the {cmd:at()} option. For example, specifying {cmd:link(pdf)} together with
    {cmd:as(svg pdf)} will display the SVG image and use the PDF for the
    link. The default is to use the first format for both the image and the link.

{phang}
    [{cmd:no}]{opt figure}[{cmd:(}{it:id}{cmd:)}] specifies whether to enclose
    the image in a {cmd:<figure>} environment. The default is {cmd:figure},
    i.e. to use the figure tag. Type {cmd:nofigure} to omit the figure tag. To
    add a custom ID to the figure tag, type {opt figure(id)}. If {it:id}
    is omitted, {cmd:webdoc} will ad an automatic ID (constructed as {cmd:fig-}{it:name},
    where {it:name} is the base name of the graph).

{phang}
    {opt caption(string)} provides a caption for the figure using the
    {cmd:<figcaption>} tag.

{phang}
    {opt cabove} or {opt cbelow} specify whether the caption is added
    above or below the figure. Only one of {cmd:cabove} and {cmd:cbelow} is
    allowed. {cmd:cbelow} is the default.

{dlgtab:Technical}

{phang}
    [{cmd:no}]{cmd:hardcode} specifies whether to embed the graph source in the
    output document. This is only supported for PNG, GIF, JPEG, and SVG. In case of
    PNG, GIF, and JPEG, the graph file will be embedded using Base64 encoding. In 
    case of SVG, the SVG code will be copied into the output document. The default is
    {cmd:nohardcode}, i.e. to include the graph using a link to the external graph file.

{phang}
    [{cmd:no}]{cmd:keep} specifies whether the external graph file (and its
    Base64 variant) will be kept. This is only relevant if {cmd:hardcode} has
    been specified. The default is {cmd:keep}, i.e. to keep the graph files so
    that {cmd:nodo} can be applied later on. Type {cmd:nokeep} if you want to
    erase the external graph files.

{phang}
    [{cmd:no}]{cmd:custom} specifies whether to use custom code to include the
    graph in the output document. The default is {cmd:nocustom}, in which case
    {cmd:webdoc graph} uses standard code to include the
    graph. Specify {cmd:custom} if you want to skip the standard code and take
    care of including the graph yourself.


{marker stripoptions}{...}
{title:Options for webdoc strip}

{phang}
    {cmd:replace} allows overwriting an existing file.

{phang}
    {cmd:append} appends results to an existing file.


{marker examples}{...}
{title:Examples}

{pstd}
    A typical do-file containing {cmd:webdoc} commands might look as follows:

        --- example1.do ---
        webdoc init example1, replace logall plain
        /***
        <!DOCTYPE html>
        <html><body>
        <h1>Exercise 1</h1>
        <p>Open the 1978 Automobile Data and summarize price and milage.</p>
        ***/
        sysuse auto
        summarize price mpg
        /***
        <h1>Exercise 2</h1>
        <p>Run a regression of price on milage and display the relation in a scatter
        plot.</p>
        ***/
        regress price mpg
        twoway (scatter price mpg) (lfit price mpg)
        webdoc graph
        /***
        </body></html>
        ***/
        --- end of file ---

{pstd}
    In the example, option {cmd:logall} is specified so that all Stata output
    is included in the HTML document (in addition, option {cmd:plain} is specified
    to omit HTML tags from the Stata output so that the display of the HTML file
    below is more readable). To process the file, type

        {com}. webdoc do example1.do
        {txt}{...}

{pstd}
    This will create the following HTML file:

        --- example1.html ---
        <!DOCTYPE html>
        <html><body>
        <h1>Exercise 1</h1>
        <p>Open the 1978 Automobile Data and summarize price and milage.</p>
        <pre id="stlog-1" class="stlog"><samp>. sysuse auto
        (1978 Automobile Data)

        . summarize price mpg

            Variable |        Obs        Mean    Std. Dev.       Min        Max
        -------------+---------------------------------------------------------
               price |         74    6165.257    2949.496       3291      15906
                 mpg |         74     21.2973    5.785503         12         41
        </samp></pre>
        <h1>Exercise 2</h1>
        <p>Run a regression of price on milage and display the relation in a scatter
        plot.</p>
        <pre id="stlog-2" class="stlog"><samp>. regress price mpg

              Source |       SS           df       MS      Number of obs   =        74
        -------------+----------------------------------   F(1, 72)        =     20.26
               Model |   139449474         1   139449474   Prob &gt; F        =    0.0000
            Residual |   495615923        72  6883554.48   R-squared       =    0.2196
        -------------+----------------------------------   Adj R-squared   =    0.2087
               Total |   635065396        73  8699525.97   Root MSE        =    2623.7

        ------------------------------------------------------------------------------
               price |      Coef.   Std. Err.      t    P&gt;|t|     [95% Conf. Interval]
        -------------+----------------------------------------------------------------
                 mpg |  -238.8943   53.07669    -4.50   0.000    -344.7008   -133.0879
               _cons |   11253.06   1170.813     9.61   0.000     8919.088    13587.03
        ------------------------------------------------------------------------------

        . twoway (scatter price mpg) (lfit price mpg)
        </samp></pre>
        <figure id="fig-2">
        <a href="example1_2.png"><img alt="example1_2.png" src="example1_2.png"/></a>
        </figure>
        </body></html>
        --- end of file ---

{pstd}
    If you are not familiar with HTML, you can also type your text in
    {browse "https://en.wikipedia.org/wiki/Markdown":Markdown} format. An
    example do-file might look as follows:

        --- example2.do ---
        webdoc init example2, md replace logall plain
        /***
        # Exercise 1

        Open the 1978 Automobile Data and summarize price and milage.

        ***/
        sysuse auto
        summarize price mpg
        /***

        # Exercise 2

        Run a regression of price on milage and display the relation in a scatter plot.

        ***/
        regress price mpg
        twoway (scatter price mpg) (lfit price mpg)
        webdoc graph
        --- end of file ---

{pstd}
    Typing

        {com}. webdoc do example2.do
        {txt}{...}

{pstd}
    will create file "example2.md", which can then be converted to HTML using
    a Markdown converter. For example, if {browse "http://pandoc.org":Pandoc}
    is installed on your system, you could type

        {com}. !pandoc example2.md -s -o example2.html
        {txt}{...}

{pstd}
    to create the HTML file. Argument {cmd:-s} (standalone) has been specified
    so that a basic header and footer is added to the document.

{pstd}
    For further examples see {cmd:webdoc}'s website at
    {browse "http://repec.sowi.unibe.ch/stata/webdoc"} or the
    {browse "http://ideas.repec.org/p/bss/wpaper/22.html":working paper}.


{marker remarks}{...}
{title:Remarks}

    {help webdoc##substitute:webdoc substitute}
    {help webdoc##local:webdoc local}
    {help webdoc##set:Changing the HTML settings}
    {help webdoc##limitations:Limitations}
    {help webdoc##globals:Global macros}

{marker substitute}{...}
{dlgtab:webdoc substitute}

{pstd}
    After the output document has been initialized, the {cmd:webdoc substitute}
    command can be used to define text substitutions that will be applied to
    all subsequent {cmd:/*** ***/} blocks. For example, type

        webdoc substitute "some text" "SOME TEXT" "more text" "MORE TEXT"

{pstd}
    to replace all instances of "some text" by "SOME TEXT" and
    all instances of "more text" by "MORE TEXT". To change the
    substitution definitions in a later part of the document, specify
    {cmd:webdoc substitute} again with new definitions. To add definitions to the
    existing definitions, specify {cmd:webdoc substitute} with the {cmd:add}
    option. To deactivate the substitutions, specify {cmd:webdoc substitute}
    without arguments.

{marker local}{...}
{dlgtab:webdoc local}

{pstd}
    The {cmd:webdoc local} command can be used to define local macros that will
    be backed up on disk. It may only be applied within or after a {cmd:webdoc stlog}
    section. The locals will be backed up in a library that has the same name as
    the Stata output section (using file suffix ".stloc"). Each output section
    has its own library, so that the names of the locals can be reused between
    sections. The syntax of {cmd:webdoc local} is the same as the syntax of
    Stata's regular {cmd:local} command; see help {helpb local}.

{pstd}
    Use the {cmd:webdoc local} command if you want to include results from an
    output section in the text body. {cmd:webdoc local} provides a way to store
    the elements you want to include in your text so that they are still
    available in later runs when you suppress computations using the {cmd:nodo}
    option. The local macros defined by {cmd:webdoc local} will be expanded in
    subsequent {cmd:/*** ***/} blocks up until the next {cmd:webdoc stlog}
    command. Alternatively, you may use {cmd:webdoc write} or {cmd:webdoc put}
    to write the locals to the output document (there is a slight difference
    between the two approaches: expansion in {cmd:/*** ***/} blocks is based on
    the locals as stored in the library file; {cmd:webdoc write}
    and {cmd:webdoc put} use the current values of the locals). For example,
    to cite the point estimate and standard error of a regression coefficient,
    you could type:

        webdoc stlog
        regress y x1 x2 ...
        webdoc stlog close
        webdoc local b = strofreal(_b[x1], "%9.3f")
        webdoc local se = strofreal(_se[x1], "%9.3f")

        /*** <p>As can be seen in the output above, the estimate for the effect
        of x1 on y is equal to `b' (with a standard error of `se').</p> ***/

{pstd}
    Alternatively, you could also type:

        webdoc put <p> As can be seen in the output above, the estimate for
        webdoc put the effect of x1 on y is equal to `b' (with a standard
        webdoc put error of `se').</p>

{marker set}{...}
{dlgtab:Changing the HTML settings}}

{pstd}
    Parts of the HTML code written by {cmd:webdoc} can be customized by the
    {cmd:webdoc set} command. The syntax of {cmd:webdoc set} is

{p 8 15 2}
    {cmd:webdoc} {opt set} [{it:setname} [{it:definition}]]

{pstd}
    where {it:setname} is the name of the element you want to change. To
    restore the default settings for all elements, type {cmd:webdoc set}
    without argument. {cmd:webdoc set} only has an effect if applied within a
    do-file processed by {cmd:webdoc do}. Furthermore, all settings will be removed when
    {cmd:webdoc do} terminates. The elements you can modify, and their default
    definitions, are as follows.

{p2colset 8 32 43 2}{...}
{col 8}Description{col 32}{it:setname}{col 42}Default definition
{p2line}
{p2col:Stata output section}{cmd:stlog}{space 5}<pre id="\`id'" class="stlog"><samp>{p_end}
{p2col:}{cmd:_stlog}{space 4}</samp></pre>{p_end}
{p2col:Stata code section}{cmd:stcmd}{space 5}<pre id="\`id'" class="stcmd"><code>{p_end}
{p2col:}{cmd:_stcmd}{space 4}</code></pre>{p_end}
{p2col:Stata help section}{cmd:sthlp}{space 5}<pre id="\`id'" class="sthlp">{p_end}
{p2col:}{cmd:_sthlp}{space 4}</pre>{p_end}
{p2col:Stata input tag}{cmd:stinp}{space 5}<span class="stinp">{p_end}
{p2col:}{cmd:_stinp}{space 4}</span>{p_end}
{p2col:Stata result tag}{cmd:stres}{space 5}<span class="stres">{p_end}
{p2col:}{cmd:_stres}{space 4}</span>{p_end}
{p2col:Stata comment tag}{cmd:stcmt}{space 5}<span class="stcmt">{p_end}
{p2col:}{cmd:_stcmt}{space 4}</span>{p_end}
{p2col:Output-omitted tag}{cmd:stoom}{space 5}<span class="stoom">(output omitted)</span>{p_end}
{p2col:Cont-on-next-page tag}{cmd:stcnp}{space 5}<span class="stcnp" style="page-break-after:always"><br/>(continued on next page)<br/></span>{p_end}
{p2col:Figure tag}{cmd:figure}{space 4}<figure id="\`macval(id)'">{p_end}
{p2col:}{cmd:_figure}{space 3}</figure>{p_end}
{p2col:Figure caption}{cmd:fcap}{space 6}<figcaption>\`macval(caption)'</figcaption>{p_end}
{p2col:Figure link tag}{cmd:flink}{space 5}<a href="\`webname'\`suffix'">{p_end}
{p2col:}{cmd:_flink}{space 4}</a>{p_end}
{p2col:Image tag}{cmd:img}{space 7}<img alt="\`macval(alt)'"\`macval(title)' src="{p_end}
{p2col:}{cmd:_img}{space 6}"\`macval(attributes)'/>{p_end}
{p2col:Embedded SVG}{cmd:svg}{space 7}<span\`macval(title)'\`macval(attributes)'>{p_end}
{p2col:}{cmd:_svg}{space 6}</span>{p_end}
{p2line}

{pstd}
    Names without underscore refer to opening tags (or opening and closing
    tags), names with underscore refer to closing tags. As illustrated by the
    default settings, some of the elements make use of local macros, with a
    leading backslash for delayed expansion. An interesting additional macro
    that can be used in [{cmd:_}]{cmd:stlog} and [{cmd:_}]{cmd:stcmd}
    is {cmd:\`doname'}, containing the name of the do-file
    that is generated if the {cmd:dosave} option has been
    specified. For example, to provide a download link for the do-file in the
    upper right corner of each output section, you could type

{phang2}
    {com}. webdoc set stlog <pre id="\`id'" class="stlog"
    style="position:relative;"><a href="\`doname'"
    style="position:absolute;top:5px;right:5px">[code]</a><samp>{txt}

{pstd}
    SVG images embedded in the output document using the {cmd:hardcode} option
    will be tagged by [{cmd:_}]{cmd:svg}. For all other graphs,
    [{cmd:_}]{cmd:img} will be used.

{marker limitations}{...}
{dlgtab:Limitations}

{pstd}
    The {cmd:$} character is used for global macro expansion in Stata. If you
    use {cmd:webdoc write} or {cmd:webdoc put} to write text containing
    {cmd:$}, type {cmd:\$} instead of {cmd:$}.

{pstd}
    {cmd:webdoc do} only provides limited support for the semicolon command
    delimiter (see {helpb #delimit}). For example, do not use semicolons to
    delimit {cmd:webdoc} commands. The semicolon command delimiter
    should work as expected as long as it is turned on and off between
    {cmd:/*** ***/} blocks and between {cmd:webdoc} commands.

{pstd}
    In general, {cmd:webdoc} commands should always start on a new line with
    {cmd:webdoc} being the first (non-comment) word on the line (for example,
    do not use {cmd:quietly webdoc ...} or similar).

{pstd}
    {cmd:webdoc stlog} cannot be nested. Furthermore, do not use
    {cmd:webdoc do} or {cmd:webdoc init} within a {cmd:webdoc stlog} section.

{pstd}
    When processing a do-file, {cmd:webdoc do} does not parse the contents
    of do-files that may be called from the main do-file using the {helpb do}
    command. As a consequence, for example, {cmd:/*** ***/} blocks in such a file
    will be ignored. Use {cmd:webdoc do} instead of {cmd:do} to include such
    do-files.

{pstd}
    {cmd:webdoc} tries to create missing subdirectories using Mata's
    {helpb mf_mkdir:mkdir()} function. Usually, this only works if all
    intermediate directories leading to the target subdirectory already
    exist. If {helpb mf_mkdir:mkdir()} fails, you will need to create the
    required directories manually prior to running {cmd:webdoc}.

{marker globals}{...}
{dlgtab:Global macros}

{pstd}
    {cmd:webdoc} maintains a number of global macros for communication between
    {cmd:webdoc} commands. Do not change or erase these global macros while
    working with {cmd:webdoc}.

{pstd}
    Global macros maintained by {cmd:webdoc do} (will be cleared when
    {cmd:webdoc do} terminates):
    {cmd:WebDoc_dofile}, {cmd:WebDoc_do_snippets}, {cmd:WebDoc_do_replace},
    {cmd:WebDoc_do_append}, {cmd:WebDoc_do_md}, {cmd:WebDoc_do_header},
    {cmd:WebDoc_do_header2}, {cmd:WebDoc_do_logall}, {cmd:WebDoc_do_linesize},
    {cmd:WebDoc_do_nodo}, {cmd:WebDoc_do_nolog}, {cmd:WebDoc_do_cmdlog},
    {cmd:WebDoc_do_dosave}, {cmd:WebDoc_do_plain}, {cmd:WebDoc_do_raw},
    {cmd:WebDoc_do_nooutput}, {cmd:WebDoc_do_matastrip},
    {cmd:WebDoc_do_cmdstrip}, {cmd:WebDoc_do_lbstrip}, {cmd:WebDoc_do_gtstrip},
    {cmd:WebDoc_do_noltrim}, {cmd:WebDoc_do_mark}, {cmd:WebDoc_do_tag},
    {cmd:WebDoc_do_custom}, {cmd:WebDoc_do_nokeep}, {cmd:WebDoc_do_certify},
    {cmd:WebDoc_do_gropts}, {cmd:WebDoc_do_logdir}, {cmd:WebDoc_do_logdir2},
    {cmd:WebDoc_do_grdir}, {cmd:WebDoc_do_dodir}, {cmd:WebDoc_do_noprefix},
    {cmd:WebDoc_do_prefix}, {cmd:WebDoc_do_prefix2}, {cmd:WebDoc_do_stpath},
    {cmd:WebDoc_do_stpath2}

{pstd}
    Global macros maintained by {cmd:webdoc set} (will be cleared when
    {cmd:webdoc do} terminates):
    {cmd:WebDoc_set_stlog}, {cmd:WebDoc_set__stlog}, {cmd:WebDoc_set_stcmd},
    {cmd:WebDoc_set__stcmd}, {cmd:WebDoc_set_sthlp}, {cmd:WebDoc_set__sthlp},
    {cmd:WebDoc_set_stinp}, {cmd:WebDoc_set__stinp}, {cmd:WebDoc_set_stres},
    {cmd:WebDoc_set__stres}, {cmd:WebDoc_set_stcmt}, {cmd:WebDoc_set__stcmt},
    {cmd:WebDoc_set_stoom}, {cmd:WebDoc_set_stcnp}, {cmd:WebDoc_set_figure},
    {cmd:WebDoc_set__figure}, {cmd:WebDoc_set_fcap}, {cmd:WebDoc_set_flink},
    {cmd:WebDoc_set__flink}, {cmd:WebDoc_set_img}, {cmd:WebDoc_set__img},
    {cmd:WebDoc_set_svg}, {cmd:WebDoc_set__svg}

{pstd}
    Global macros maintained by {cmd:webdoc init} (will be cleared by
    {cmd:webdoc close}):
    {cmd:WebDoc_docname}, {cmd:WebDoc_docname_FH}, {cmd:WebDoc_docname0},
    {cmd:WebDoc_basename}, {cmd:WebDoc_path}, {cmd:WebDoc_path0},
    {cmd:WebDoc_stcounter}, {cmd:WebDoc_md}, {cmd:WebDoc_nofooter},
    {cmd:WebDoc_logall}, {cmd:WebDoc_linesize}, {cmd:WebDoc_nodo},
    {cmd:WebDoc_nolog}, {cmd:WebDoc_cmdlog}, {cmd:WebDoc_dosave},
    {cmd:WebDoc_plain}, {cmd:WebDoc_straw}, {cmd:WebDoc_nooutput},
    {cmd:WebDoc_matastrip}, {cmd:WebDoc_cmdstrip}, {cmd:WebDoc_lbstrip},
    {cmd:WebDoc_gtstrip}, {cmd:WebDoc_noltrim}, {cmd:WebDoc_mark},
    {cmd:WebDoc_tag}, {cmd:WebDoc_custom}, {cmd:WebDoc_nokeep},
    {cmd:WebDoc_certify}, {cmd:WebDoc_gropts}, {cmd:WebDoc_logdir},
    {cmd:WebDoc_do_grdir}, {cmd:WebDoc_dodir}, {cmd:WebDoc_prefix},
    {cmd:WebDoc_prefix0}, {cmd:WebDoc_stpath}

{pstd}
    Global macro maintained by {cmd:webdoc substitute} (will be cleared by
    {cmd:webdoc close}): {cmd:WebDoc_substitute}

{pstd}
    Global macros maintained by {cmd:webdoc stlog} (will be cleared by
    {cmd:webdoc close}):
    {cmd:WebDoc_ststatus}, {cmd:WebDoc_stname}, {cmd:WebDoc_stname0},
    {cmd:WebDoc_stid}, {cmd:WebDoc_stfilename}, {cmd:WebDoc_stfilename0},
    {cmd:WebDoc_stwebname}, {cmd:WebDoc_stwebname0}, {cmd:WebDoc_stgrcounter},
    {cmd:WebDoc_stlinesize}, {cmd:WebDoc_stlinesize0}, {cmd:WebDoc_stnodo},
    {cmd:WebDoc_stnolog}, {cmd:WebDoc_stcmdlog}, {cmd:WebDoc_stdosave},
    {cmd:WebDoc_stplain}, {cmd:WebDoc_straw}, {cmd:WebDoc_stnooutput},
    {cmd:WebDoc_stmatastrip}, {cmd:WebDoc_stcmdstrip}, {cmd:WebDoc_stlbstrip},
    {cmd:WebDoc_stgtstrip}, {cmd:WebDoc_stnoltrim}, {cmd:WebDoc_stmark},
    {cmd:WebDoc_sttag}, {cmd:WebDoc_stcustom}, {cmd:WebDoc_stnokeep},
    {cmd:WebDoc_stcertify}

{pstd}
    Global macro maintained by {cmd:webdoc local} (will be cleared by
    {cmd:webdoc stlog} or {cmd:webdoc close}): {cmd:WebDoc_stloc}

{pstd}
    In addition, {cmd:webdoc do} maintains an external Mata global called
    {cmd:WebDoc_do_snippets}. Do not modify the contents of this external
    global. If the external global is deleted (e.g. because the processed
    do-file contains a {cmd:clear all} command), {cmd:webdoc do} automatically
    restores it. The external global will be removed when {cmd:webdoc do}
    terminates.


{marker results}{...}
{title:Stored results}

{pstd}
    {cmd:webdoc close} stores the following in {cmd:s()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2:Macros}{p_end}
{synopt:{cmd:s(docname)}}name of output document (including absolute path)
    {p_end}
{synopt:{cmd:s(basename)}}base name of output document (excluding path)
    {p_end}
{synopt:{cmd:s(path)}}(absolute) path of output document
    {p_end}
{synopt:{cmd:s(md)}}{cmd:md} or empty
    {p_end}
{synopt:{cmd:s(logall)}}{cmd:logall} or empty
    {p_end}
{synopt:{cmd:s(linesize)}}specified line width or empty
    {p_end}
{synopt:{cmd:s(nodo)}}{cmd:nodo} or empty
    {p_end}
{synopt:{cmd:s(nolog)}}{cmd:nolog} or empty
    {p_end}
{synopt:{cmd:s(cmdlog)}}{cmd:cmdlog} or empty
    {p_end}
{synopt:{cmd:s(dosave)}}{cmd:dosave} or empty
    {p_end}
{synopt:{cmd:s(plain)}}{cmd:plain} or empty
    {p_end}
{synopt:{cmd:s(raw)}}{cmd:raw} or empty
    {p_end}
{synopt:{cmd:s(nooutput)}}{cmd:nooutput} or empty
    {p_end}
{synopt:{cmd:s(matastrip)}}{cmd:matastrip} or empty
    {p_end}
{synopt:{cmd:s(cmdstrip)}}{cmd:cmdstrip} or empty
    {p_end}
{synopt:{cmd:s(lbstrip)}}{cmd:lbstrip} or empty
    {p_end}
{synopt:{cmd:s(gtstrip)}}{cmd:gtstrip} or empty
    {p_end}
{synopt:{cmd:s(noltrim)}}{cmd:noltrim} or empty
    {p_end}
{synopt:{cmd:s(mark)}}contents of {cmd:mark()} option
    {p_end}
{synopt:{cmd:s(tag)}}contents of {cmd:tag()} option
    {p_end}
{synopt:{cmd:s(custom)}}{cmd:custom} or empty
    {p_end}
{synopt:{cmd:s(nokeep)}}{cmd:nokeep} or empty
    {p_end}
{synopt:{cmd:s(certify)}}{cmd:certify} or empty
    {p_end}
{synopt:{cmd:s(gropts)}}default graph export options
    {p_end}
{synopt:{cmd:s(logdir)}}subdirectory used for Stata log files
    {p_end}
{synopt:{cmd:s(grdir)}}subdirectory used for graphs (if different from {cmd:s(logdir)})
    {p_end}
{synopt:{cmd:s(dodir)}}subdirectory used for do-files (if different from {cmd:s(logdir)})
    {p_end}
{synopt:{cmd:s(prefix)}}prefix for automatic names
    {p_end}
{synopt:{cmd:s(stpath)}}include-path to be used in the output document
    {p_end}

{pstd}
    {cmd:webdoc stlog close} stores the following in {cmd:s()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2:Macros}{p_end}
{synopt:{cmd:s(name)}}name of the Stata output log, including {cmd:logdir()} path
    {p_end}
{synopt:{cmd:s(name0)}}{cmd:s(name)} without {cmd:logdir()} path
    {p_end}
{synopt:{cmd:s(id)}}id of the log in the output document
    {p_end}
{synopt:{cmd:s(filename)}}name of log file on disk (including absolute path and suffix)
    {p_end}
{synopt:{cmd:s(filename0)}}{cmd:s(filename)} without suffix
    {p_end}
{synopt:{cmd:s(webname)}}name of log file with include-path for use in output document
    {p_end}
{synopt:{cmd:s(webname0)}}{cmd:s(webname)} without suffix
    {p_end}
{synopt:{cmd:s(doname)}}name (and include-path) of do-file
    {p_end}
{synopt:{cmd:s(linesize)}}line width used for the output log
    {p_end}
{synopt:{cmd:s(indent)}}size of indentation
    {p_end}
{synopt:{cmd:s(nodo)}}{cmd:nodo} or empty
    {p_end}
{synopt:{cmd:s(nolog)}}{cmd:nolog} or empty
    {p_end}
{synopt:{cmd:s(cmdlog)}}{cmd:cmdlog} or empty
    {p_end}
{synopt:{cmd:s(dosave)}}{cmd:dosave} or empty
    {p_end}
{synopt:{cmd:s(plain)}}{cmd:plain} or empty
    {p_end}
{synopt:{cmd:s(raw)}}{cmd:raw} or empty
    {p_end}
{synopt:{cmd:s(nooutput)}}{cmd:nooutput} or empty
    {p_end}
{synopt:{cmd:s(matastrip)}}{cmd:matastrip} or empty
    {p_end}
{synopt:{cmd:s(cmdstrip)}}{cmd:cmdstrip} or empty
    {p_end}
{synopt:{cmd:s(lbstrip)}}{cmd:lbstrip} or empty
    {p_end}
{synopt:{cmd:s(gtstrip)}}{cmd:gtstrip} or empty
    {p_end}
{synopt:{cmd:s(noltrim)}}{cmd:noltrim} or empty
    {p_end}
{synopt:{cmd:s(mark)}}contents of {cmd:mark()} option
    {p_end}
{synopt:{cmd:s(tag)}}contents of {cmd:tag()} option
    {p_end}
{synopt:{cmd:s(custom)}}{cmd:custom} or empty
    {p_end}
{synopt:{cmd:s(nokeep)}}{cmd:nokeep} or empty
    {p_end}
{synopt:{cmd:s(certify)}}{cmd:certify} or empty
    {p_end}

{pstd}
    {cmd:webdoc init} clears {cmd:s()}.


{marker author}{...}
{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch

{pstd}
    Thanks for citing this software in one of the following ways:

{pmore}
    Jann, Ben (2016). Creating HTML or Markdown documents from within Stata
    using webdoc. University of Bern Social Sciences Working Papers
    No. 22. Available from
    {browse "http://ideas.repec.org/p/bss/wpaper/22.html"}.

{pmore}
    Jann, B. (2016). webdoc: Stata module to create a HTML or Markdown document
    including Stata output. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s458209.html"}.


{marker alsosee}{...}
{title:Also see}

{psee}
    Online:  help for
    {helpb file},
    {helpb log},
    {helpb texdoc} (if installed)

