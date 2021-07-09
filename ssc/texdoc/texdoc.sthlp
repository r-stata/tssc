{smcl}
{* 13apr2018}{...}
{hi:help texdoc}{...}
{right:Jump to: {help texdoc##syntax:Syntax}, {help texdoc##description:Description}, {help texdoc##options:Options}, {help texdoc##examples:Examples}, {help texdoc##remarks:Remarks}, {help texdoc##results:Stored results}}
{right: Also see: {browse "http://repec.sowi.unibe.ch/stata/texdoc"}}
{hline}

{title:Title}

{pstd}{hi:texdoc} {hline 2} Create a LaTeX document including Stata output

{marker syntax}{...}
{title:Syntax}

{pstd}
    Process a do-file containing {cmd:texdoc} commands

{p 8 15 2}
    {cmd:texdoc} {opt do} {it:filename} [{it:arguments}] [{cmd:,} {help texdoc##doopts:{it:do_options}} ]

{pstd}
    Commands to be used within the do-file

{p2colset 9 50 50 2}{...}
{p2col:{cmd:texdoc} {opt i:nit} [{it:docname}] [{cmd:,} {help texdoc##initopts:{it:init_options}}]}initialize
    the LaTeX document; (re)set default behavior

{p2col:{cmd:/*tex} {it:...} {cmd:tex*/}}add a block of text to the LaTeX document

{p2col:{cmd:/***} {it:...} {cmd:***/}}synonym for {cmd:/*tex} {it:...} {cmd:tex*/}

{p2col:{cmd:texdoc} {opt sub:stitute} [{it:from} {it:to} {it:...}]  [{cmd:,} {opt a:dd}]}substitutions to be applied within {cmd:/*tex tex*/} blocks

{p2col:{cmd:texdoc} {opt w:rite} {it:...} | {cmd:texdoc} {cmd:_}{opt w:rite} {it:...}}add a line of (interpreted) text to the LaTeX document

{p2col:{cmd:texdoc} {opt a:ppend} {it:filename} [{cmd:,} {help texdoc##appopts:{it:append_opts}}]}add the contents of a file to the LaTeX document

{p2col:{cmd:texdoc} {opt s:tlog} [{it:name}] [{cmd:,} {help texdoc##stlogopts:{it:stlog_options}}]}start
    a Stata output log to be included in the LaTeX document

{p2col:{cmd:texdoc} {opt s:tlog} {opt o:om} {it:cmdline}}suppress output of {it:cmdline} and insert an output-omitted tag

{p2col:{cmd:texdoc} {opt s:tlog} {opt q:uietly} {it:cmdline}}suppress output without inserting an output-omitted tag

{p2col:{cmd:texdoc} {opt s:tlog} {opt cnp}}insert a continued-on-next-page tag in the Stata output log

{p2col:{cmd:texdoc} {opt s:tlog} {opt c:lose}}stop the Stata output log

{p2col:{cmd:texdoc} {opt s:tlog} [{it:name}] {cmd:using} {it:dofile} [{cmd:,} {help texdoc##stlogopts:{it:...}}]}include an output log from the commands in {it:dofile}

{p2col:{cmd:texdoc} {opt s:tlog} [{it:name}] [{cmd:,} {help texdoc##stlogopts:{it:...}}] {cmd::} {it:command}}include the output from {it:command}

{p2col:{cmd:texdoc} {opt loc:al} {it:name} {it:definition}}define and backup a local macro

{p2col:{cmd:texdoc} {opt gr:aph} [{it:name}] [{cmd:,} {help texdoc##gropts:{it:graph_options}}]}include a graph

{p2col:{cmd:texdoc} {opt c:lose}}close the LaTeX document

{p2col:{cmd:// texdoc exit}}let {cmd:texdoc do} exit the do-file

{pstd}
    Remove all {cmd:texdoc} commands from a do-file

{p 8 15 2}
    {cmd:texdoc} {opt strip} {it:filename} {it:newname} [, {opt r:eplace} {opt a:ppend} ]


{synoptset 25 tabbed}{...}
{marker doopts}{col 5}{help texdoc##dooptions:{it:do_options}}{col 32}Description
{synoptline}
{synopt:[{cmd:{ul:no}}]{opt i:nit}[{cmd:(}{it:docname}{cmd:)}]}initialize the LaTeX document
    {p_end}
{synopt:{help texdoc##initopts:{it:init_options}}}options to be passed through
    to {cmd:texdoc init}
    {p_end}
{synopt:{opt nostop}}do not stop execution if a command returns error (not recommended)
    {p_end}
{synopt:{opt cd}}process the do-file within its home directory
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker initopts}{col 5}{help texdoc##initoptions:{it:init_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt r:eplace}}allow overwriting an existing LaTeX document
    {p_end}
{synopt:{opt a:ppend}}append output to an existing LaTeX document
    {p_end}
{synopt:{opt force}}enforce initialization even though {cmd:texdoc do} is not running
    {p_end}

{syntab :Log and graph options}
{synopt:[{cmd:no}]{opt logall}}whether to log all Stata output; the default is
    {cmd:nologall}
    {p_end}
{synopt:{help texdoc##stlogopts:{it:stlog_options}}}options to be passed through to
     {cmd:texdoc stlog}
     {p_end}
{synopt:{opt gr:opts}{cmd:(}{help texdoc##gropts:{it:graph_options}}{cmd:)}}options
    to be passed through {cmd:texdoc graph}
    {p_end}

{syntab :Filenames/paths}
{synopt:[{cmd:no}]{opt logdir}[{cmd:(}{it:path}{cmd:)}]}where to store the
    Stata output log files
    {p_end}
{synopt:{opt grdir(path)}}where to store the graph files
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt p:refix}[{cmd:(}{it:prefix}{cmd:)}]}prefix for the automatic
    names
    {p_end}
{synopt:[{cmd:no}]{cmd:stpath}[{cmd:(}{it:path}{cmd:)}]}include-path used
    in the LaTeX document
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker appopts}{col 5}{help texdoc##appoptions:{it:append_options}}{col 32}Description
{synoptline}
{synopt:{opt sub:stitute(subst)}}apply substitutions; {it:subst} is {it:from} {it:to} [{it:from} {it:to} ...]
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker stlogopts}{col 5}{help texdoc##stlogoptions:{it:stlog_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt li:nesize(#)}}set the line width to be used in the output log
    (number of characters)
    {p_end}
{synopt:[{cmd:no}]{opt do}}whether to run the Stata commands; default is {cmd:do}
    {p_end}
{synopt:[{cmd:no}]{opt log}}whether to create a log and include it in the
    LaTeX document; default is {cmd:log}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt cmdl:og}}whether to display a copy of the commands
    instead of an output log; default is {cmd:nocmdlog}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt verb:atim}}whether to use verbatim command log;
    default is {cmd:noverbatim}
    {p_end}

{syntab :Contents}
{synopt:[{cmd:{ul:no}}]{opt o:utput}}whether to suppress command output in
    the log; default is {cmd:output}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt m:atastrip}}whether to strip Mata opening and ending
    commands from the log; default is {cmd:nomatastrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt cmds:trip}}whether to strip command lines from the
    log; default is {cmd:nocmdstrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt lbs:trip}}whether to strip line break comments from the
    commands in the log; default is {cmd:nolbstrip}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt gts:trip}}whether to strip continuation symbols from the
    commands in the log; default is {cmd:nogtstrip}
    {p_end}
{synopt:[{cmd:no}]{opt ltrim}}whether to remove white space on the left
    of commands; default is {cmd:ltrim}
    {p_end}

{syntab :Highlighting}
{synopt:{opt alert(strlist)}}enclose specified strings in \alert{}
    {p_end}
{synopt:{cmd:tag(}{help texdoc##tag:{it:matchlist}}{cmd:)}}apply custom tags to
    specified strings
    {p_end}

{syntab :Technical}
{synopt:[{cmd:no}]{opt beamer}}whether to use code appropriate for the beamer 
    class; default is {cmd:nobeamer}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt h:ardcode}}whether to copy the log into the LaTeX
    document; default is {cmd:nohardcode}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt k:eep}}whether to erase the external log file
    if {cmd:hardcode} is specified; default is {cmd:keep}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt c:ustom}}whether to use custom code to include the log
    file in the LaTeX document; default is {cmd:nocustom}
    {p_end}
{synopt:[{cmd:no}]{opt cert:ify}}whether to compare results against previous
    version; default is {cmd:nocertify}
    {p_end}
{synopt:{opt nostop}}({cmd:texdoc stlog using} only) do not stop execution if
    a command returns error
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker gropts}{col 5}{help texdoc##groptions:{it:graph_options}}{col 32}Description
{synoptline}
{syntab :Main}
{synopt:{opt as(fileformats)}}the output format(s); default is {cmd:as(pdf)}
    {p_end}
{synopt:{opt name(name)}}name of graph window to be exported
    {p_end}
{synopt:{it:override_options}}override conversion defaults; see help
    {helpb graph export}
    {p_end}

{syntab :Environment}
{synopt:[{cmd:{ul:no}}]{opt c:enter}}whether to center the graph; default is
    {cmd:center}
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt f:igure}[{cmd:(}{it:args}{cmd:)}]}whether to use
    the figure environment; default is {cmd:nofigure}
    {p_end}
{synopt:{opt cap:tion(string)}}provide a caption for the
    figure
    {p_end}
{synopt:{opt l:abel(string)}}provide a label for the figure
    {p_end}
{synopt:{opt ca:bove} or {opt cb:elow}}where to place the caption; default is
    {cmd:cbelow}
    {p_end}

{syntab :Include command}
{synopt:{opt o:ptagrs(args)}}arguments passed through to \includegraphics (or
    \epsfig)
    {p_end}
{synopt:[{cmd:{ul:no}}]{opt s:uffix}}whether to type the file suffix
    in \includegraphics (or \epsfig)
    {p_end}
{synopt:[{cmd:no}]{opt epsfig}}whether to use \epsfig instead of
    \includegraphics; default is {cmd:noepsfig}
    {p_end}
{synopt:[{cmd:no}]{opt custom}}whether to use custom code to include graph
    in the LaTeX document; default is {cmd:nocustom}
    {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
    {cmd:texdoc} provides tools to create a LaTeX document from within Stata in
    a weaving fashion (on weaving with Stata also see
    {browse "http://www.stata.com/meeting/italy08/rising_2008.pdf":Rising 2008}). The
    basic procedure is to write a do-file including Stata commands and sections
    of LaTeX code and then process the do-file by {cmd:texdoc do}. {cmd:texdoc do}
    will create the LaTeX document, possibly including graphs and sections of Stata
    output. The LaTeX document can then be processed by a LaTeX compiler to
    produce the final document. {cmd:texdoc do} is similar to the regular
    {helpb do} command; {it:arguments}, if specified, will be passed to the do-file
    as local macros; see {manlink R do}.

{pstd}
    Within the do-file, use {cmd:texdoc init} {it:docname} to
    initialize the LaTeX document, where {it:docname} is the name of the LaTeX
    document (possibly including a path; default suffix ".tex" will be added to
    {it:docname} if no suffix is specified). Alternatively, if the do-file does
    not contain a {cmd:texdoc init} {it:docname} command, {cmd:texdoc do} will
    automatically initialize the LaTeX document in the folder of the do-file
    using {it:basename}{cmd:.tex} as name for the LaTeX document, where
    {it:basename} is the name of the do-file without suffix. Furthermore, note
    that {cmd:texdoc init} without {it:docname} can be used within the do-file
    to change settings after the LaTeX document has been initialized.

{pstd}
    Thereafter, use the {cmd:/*tex tex*/} delimiter structure to include blocks
    of LaTeX code. A block may span multiple lines. The opening tag
    ({cmd:/*tex}) must be at the beginning of a line (save white space); the
    closing tag ({cmd:tex*/}) must be at the end of a line (save white space).
    You may also type {cmd:/***} {it:...} {cmd:***/} instead of
    {cmd:/*tex} {it:...} {cmd:tex*/}. Macros in LaTeX
    code provided within {cmd:/*tex tex*/} or {cmd:/*** ***/} will not be
    expanded. You can, however, use the {cmd:texdoc substitute} command to define
    text substitutions that will be applied (see
    {help texdoc##substitute:{it:texdoc substitute}} under
    {help texdoc##remarks:{it:Remarks}} below; furthermore, also see the
    remark on {help texdoc##local:{it:texdoc local}}).

{pstd}
    A single line of LaTeX code can also be provided by the {cmd:texdoc write}
    command. Stata macros in a LaTeX line provided by {cmd:texdoc write} will
    be expanded before writing the line to the LaTeX document. {cmd:texdoc write} adds a
    new-line character at the end of the line. If you want to omit the new-line
    character, you can type {cmd:texdoc _write}. Furthermore, to copy text from
    an external file into the LaTeX document, you can use the
    {cmd:texdoc append} command.

{pstd}
    To create a section in the LaTeX document containing Stata output, use the
    {cmd:texdoc stlog} command. {cmd:texdoc stlog} writes the Stata output to a
    log file and includes appropriate code in the LaTeX document to display the
    contents of the file. The "{it:stata}" LaTeX package providing the
    "{it:stlog}" environment is required to display the output. To make the
    "{it:stlog}" environment available, add \usepackage{c -(}stata{c )-} in the
    preamble of the LaTeX document (after having downloaded the necessary
    Stata LaTeX files using {helpb sjlatex}; see below). {cmd:texdoc stlog}
    creates an automatic name for the output file, but you can also specify a
    custom name typing {bind:{cmd:texdoc stlog} {it:name}}
    (possibly including a relative path).

{pstd}
    Within a Stata output section
    {bind:{cmd:texdoc stlog oom} {it:cmdline}} can be used to suppress the
    output of a specific command and add an output-omitted tag (\oom) in the
    Stata output file. Alternatively, to suppress output without
    adding an output-omitted tag, type
    {bind:{cmd:texdoc stlog quietly} {it:cmdline}}. Furthermore,
    {cmd:texdoc stlog cnp} can be used to insert a continued-on-next-page tag
    (\cnp).

{pstd}
    {cmd:texdoc stlog close} marks the end of a Stata output section. To
    include the Stata output from an external do-file, use
    {cmd:texdoc stlog using} {it:filename} where {it:filename} is the name of
    the do-file. Furthermore, to include just the output of a single command
    (without input), you can type
    {cmd:texdoc stlog :} {it:command}. {cmd:texdoc stlog close} is not needed
    after the using-form or the colon-form of {cmd:texdoc stlog}.

{pstd}
    Instead of selecting the Stata output to be included in the LaTeX document
    using {cmd:texdoc stlog}, you can also specify the {cmd:logall} option with
    {cmd:texdoc do} or {cmd:texdoc init}. In this case, all output will be
    included in the LaTeX document.

{pstd}
    {cmd:texdoc local} can be used within or after a Stata output section to define a local
    macro that will be backed up on disk. This is useful if you want include
    specific results in your text and want to ensure that the results will be available
    in later runs when suppressing the Stata commands using the {cmd:nodo}
    option. The syntax of {cmd:texdoc local} is the same as the syntax of
    Stata's regular {helpb local} command. Local macros defined by
    {cmd:webdoc local} will be expanded in subsequent {cmd:/*tex tex*/} or
    {cmd:/*** ***/} blocks (up until the next {cmd:texdoc stlog} command). For
    further information, see {help texdoc##local:{it:texdoc local}} under
    {help texdoc##remarks:{it:Remarks}} below.

{pstd}
    {cmd:texdoc graph} can be used to export the current graph and include
    appropriate code in the LaTeX document to display graph. {cmd:texdoc graph}
    can be specified within a {cmd:texdoc stlog} section or directly after
    {cmd:texdoc stlog close}. If {cmd:texdoc graph} is specified within a
    {cmd:texdoc stlog} section, the graph is included in the LaTeX document
    before the Stata output; if {cmd:texdoc graph} is specified after
    {cmd:texdoc stlog close}, the graph is included after the Stata output
    (furthermore, if {cmd:texdoc graph} is used outside a {cmd:texdoc stlog}
    section while {cmd:logall} is on, the graph will be placed at the
    position in the output where the {cmd:texdoc graph} command occurs). The
    name of the {cmd:texdoc stlog} section is used
    to name the graph (possibly suffixed by a counter if the {cmd:texdoc stlog}
    section contains more than one {cmd:texdoc graph} command), unless a custom
    {it:name} is specified.

{pstd}
    {cmd:texdoc close} closes the LaTeX document. This is not strictly needed as
    {cmd:texdoc do} closes the document automatically if the do-file does not
    contain a {cmd:texdoc close} command. Furthermore, to exit a
    do-file before the end of the file, add a line containing
    {cmd:// texdoc exit} (without anything else on the same line).
    {cmd:texdoc do} will only read the do-file up to this line.

{pstd}
    {cmd:texdoc strip} removes all {cmd:texdoc} commands and all {cmd:/*tex tex*/}
    or {cmd:/*** ***/} blocks from a do-file.

{pstd}
    To be able to compile a LaTeX document containing Stata output you need to
    copy the Stata LaTeX files to your system and include
    \usepackage{c -(}stata{c )-} in the preamble of your LaTeX
    document. To obtain the Stata LaTeX files, first install the
    {helpb sjlatex} package typing

    {com}. {net "install sjlatex, from(http://www.stata-journal.com/production)":net install sjlatex, from(http://www.stata-journal.com/production)}{txt}

{pstd}
    After that, use command {cmd:sjlatex install} to download the
    Stata LaTeX files; see help {helpb sjlatex}. You may keep the files in
    the working directory of your LaTeX document or, alternatively, copy the
    files to the search tree of your LaTeX installation (consult
    the documentation of your LaTeX installation for information on the search
    tree; for example, in MacTeX, you may add the files to a subfolder
    in ~/Library/texmf/tex/latex).


{marker options}{...}
{title:Options}

    {help texdoc##dooptions:Options for texdoc do}
    {help texdoc##initoptions:Options for texdoc init}
    {help texdoc##appoptions:Options for texdoc append}
    {help texdoc##stlogoptions:Options for texdoc stlog}
    {help texdoc##groptions:Options for texdoc graph}
    {help texdoc##stripoptions:Options for texdoc strip}


{marker dooptions}{...}
{title:Options for texdoc do}

{phang}
    [{cmd:no}]{opt i:nit}[{cmd:(}{it:docname}{cmd:)}] specifies whether and how
    to initialize the LaTeX document. If the processed do-file contains a
    command to initialize the LaTeX document (i.e. if the do-file contains
    {cmd:texdoc init} {it:docname}) or if the LaTeX document is already open
    (e.g. in a nested application of {cmd:texdoc do}), the default for
    {cmd:texdoc do} is not to initialize the LaTeX document. Otherwise,
    {cmd:texdoc do} will automatically initialize the LaTeX document in the
    folder of the do-file using {it:basename}{cmd:.tex} as name for the LaTeX
    document, where {it:basename} is the name of the do-file without suffix.
    Use the {cmd:init} option to override these defaults: {cmd:noinit} will
    deactivate automatic initialization; {cmd:init} will enforce automatic
    initialization; {cmd:init(}{it:docname}{cmd:)} will enforce initialization
    using {it:docname} as name for the LaTeX document ({it:docname} may include
    an absolute or relative path; the base folder is the current working
    directory or the folder of the do-file, depending on whether option
    {cmd:cd} is specified; default suffix ".tex" will be added to {it:docname}
    if no suffix is specified).

{phang}
    {help texdoc##initoptions:{it:init_options}} are options to specify defaults
    to be passed through to {cmd:texdoc init}. See below.

{phang}
    {cmd:nostop} allows continuing execution even if an error occurs. Use the
    {cmd:nostop} option if you want to make sure that {cmd:texdoc do} runs the
    do-file all the way to the end even if some of the commands return error.
    Usage of this option is not recommended. Use the {cmd:nostop} option with
    {cmd:texdoc stlog using} if you want to log output from a command that
    returns error.

{phang}
    {opt cd} changes the working directory to the directory of the specified
    do-file for processing the do-file and restores the current working directory
    after termination. The default is not to change the working directory.


{marker initoptions}{...}
{title:Options for texdoc init}

{dlgtab:Main}

{phang}
    {cmd:replace} allows overwriting an existing LaTeX document.

{phang}
    {cmd:append} appends results to an existing LaTeX document.

{phang}
    {cmd:force} causes {cmd:texdoc init} to initialize the LaTeX document
    even though {cmd:texdoc do} is not running. By default
    {cmd:texdoc init} has no effect if typed in Stata's command
    window or if included in a do-file that is not processed by {cmd:texdoc do}.
    Specify {cmd:force} to enforce initialization in these cases. The
    LaTeX document will remain active until you type {cmd:texdoc close}. Note
    that {cmd:texdoc} has only limited functionality if {cmd:texdoc do}
    is not running (for example, {cmd:/*** ***/} blocks and
    {cmd:// texdoc exit} will be ignored and some of the options
    of {cmd:texdoc stlog} will not work). Specifying {cmd:force} is not
    recommended.

{dlgtab:Log and graph options}

{phang}
    [{cmd:no}]{cmd:logall} specifies whether to include the output of all Stata
    commands in the LaTeX document. The default is {cmd:nologall}, that is, to
    include only the output selected by {cmd:texdoc stlog}. Specify
    {cmd:logall} if you want to log all output. When {cmd:logall}
    is specified, {cmd:texdoc do} will insert appropriate {cmd:texdoc stlog}
    and {cmd:texdoc stlog close} commands automatically at each
    {cmd:/*tex tex*/} or {cmd:/*** ***/} block or {cmd:texdoc} command (but not at
    {cmd:texdoc stlog oom} and {cmd:texdoc stlog cnp}). Empty lines (or lines
    that only contain white space) at the beginning and end of each command
    section will be skipped.

{phang}
    {help texdoc##stlogoptions:{it:stlog_options}} are options to set the default
    behavior of {cmd:texdoc stlog}. See below.

{phang}
    {opt gropts}{cmd:(}{help texdoc##groptions:{it:graph_options}}{cmd:)}
    specifies default options to be passed through to {cmd:texdoc graph}. See
    below. Updating {cmd:gropts()} in repeated calls to {cmd:texdoc init} will
    replace the option as a whole.

{dlgtab:Filenames/paths}

{phang}
    [{cmd:no}]{opt logdir}[{cmd:(}{it:path}{cmd:)}] specifies where to store
    the Stata output log files. The default is {cmd:nologdir}, in which case
    the log files are stored in the same directory as the LaTeX document, using
    the name of the LaTeX document as a prefix for the names of the log files;
    also see the {cmd:prefix()} option. Option {cmd:logdir} without argument
    causes the log files to be stored in a subdirectory with the name of
    the LaTeX document. Option {opt logdir(path)} causes the log files to be
    stored in subdirectory {it:path}, where {it:path} is a relative path starting
    from the folder of the LaTeX document.

{phang}
    {opt grdir(path)} specifies an alternative subdirectory to be used by
    {cmd:texdoc graph} for storing the graph files, where {it:path} is a relative
    path starting from the folder of the LaTeX document. The default is to
    store the graphs in the same directory as the log files.

{phang}
    [{cmd:no}]{opt prefix}[{cmd:(}{it:prefix}{cmd:)}] specifies a prefix for
    the automatic names of the Stata output log files and graphs. The names are
    constructed as "{it:prefix}#", where # is a counter (i.e., {cmd:1},
    {cmd:2}, {cmd:3}, etc.). Option {cmd:noprefix} omits the prefix; option
    {cmd:prefix} without argument causes "{it:basename}{cmd:_}" to be used as
    prefix, where {it:basename} is the name of the LaTeX document (without
    path); option {opt prefix(prefix)} causes {it:prefix} to be used as prefix.
    The default prefix is empty if {cmd:logdir} or {opt logdir(path)} is
    specified; otherwise the default prefix is equal to "{it:basename}{cmd:_}".
    Furthermore, the prefix will be ignored if a custom {it:name} is provided
    when calling {cmd:texdoc stlog}. The suffix of the physical log files on
    disk is always ".log.tex".

{phang}
    [{cmd:no}]{cmd:stpath}[{cmd:(}{it:path}{cmd:)}] specifies how the path for
    including log files and graphs in the LaTeX document is to be constructed
    (i.e. the path used in the \input{c -(}{c )-} statements etc.; {cmd:stpath()}
    has no effect on where the log files and graphs are stored in the file
    system). If {cmd:stpath} is specified without argument, then the path of the
    LaTeX document (to be precise, the path specified in {it:docname} when
    initializing the LaTeX document) is added to the include-path for
    log files and graphs. Alternatively, specify {opt stpath(path)} to add
    a custom path. The default is {cmd:nostpath}. Specifying {cmd:stpath()}
    might be necessary if the LaTeX document is itself an input to a master
    LaTeX file somewhere else in the file system.


{marker appoptions}{...}
{title:Options for texdoc append}

{phang}
    {opt substitute(subst)} causes the specified substitutions to be applied
    before copying the file into the LaTeX document, where {it:subst} is

            {it:from} {it:to} [{it:from} {it:to} {it:...}]

{pmore}
    All occurrences of {it:from} will be replaced by {it:to}. Include {it:from}
    and {it:to} in double quotes if they contain spaces. For example, to
    replace "{cmd:@title}" by "{cmd:My Title}" and "{cmd:@author}" by
    "{cmd:My Name}", you could type
    {cmd:substitute(@title "My Title" @author "My Name")}.


{marker stlogoptions}{...}
{title:Options for texdoc stlog}

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
    on the text without having to re-run the Stata commands. {cmd:nodo}
    only works in non-interactive mode, that is, if the do-file is processed by
    {cmd:texdoc do}. Furthermore, note that the automatic names of Stata output sections change
    if the order of Stata output sections changes. That is, {cmd:nodo} should only be
    used as long as the order did not change or if fixed names were assigned
    to the Stata output sections. An exception is if {cmd:nodo} is used together with
    the {cmd:cmdlog} option (see below). In this case the log file
    will always be recreated (as running the commands is not necessary to
    recreate the log file).

{phang}
    [{cmd:no}]{cmd:log} specifies whether the Stata output is to be logged and
    included in the LaTeX document. The default is {cmd:log}, i.e. to log and
    include the Stata output. If you type {cmd:nolog}, the commands will be run
    without logging. {cmd:nolog} does not appear to be particularly useful as
    you could simply include the corresponding Stata commands in the do-file
    without using {cmd:texdoc stlog}. However, {cmd:nolog} may be helpful in
    combination with the {cmd:nodo} option. It provides a way to include
    unlogged commands in the do-file that will not be executed if
    {cmd:nodo} is specified.

{phang}
    [{cmd:no}]{cmd:cmdlog} specifies whether to print a plain copy of the
    commands instead of using a Stata output log. The default is
    {cmd:nocmdlog}, i.e. to include a Stata output log. If you type
    {cmd:cmdlog} then only a copy of the commands without output will be
    included (note that the commands will still be executed; add the {cmd:nodo}
    option if you want to skip running the commands). {cmd:cmdlog} is similar
    to {cmd:nooutput}. A difference is that {cmd:nooutput} prints ". " at the
    beginning of each command whereas {cmd:cmdlog} displays a plain copy of the
    commands. Furthermore, {cmd:cmdlog} can be combined with {cmd:nodo} to
    include a copy of the commands without executing the commands. {cmd:cmdlog}
    is not allowed with the colon-form of {cmd:texdoc stlog}.

{phang}
    [{cmd:no}]{cmd:verbatim} specifies whether the command log will be processed
    by {cmd:log texman}. This is only relevant if {cmd:cmdlog} has been
    specified. The default is {cmd:noverbatim}, i.e. to processes the command
    log by {cmd:log texman} and use the "{it:stlog}" environment in LaTeX. If you
    type {cmd:verbatim} then {cmd:log texman} will be skipped and the
    "{it:stverbatim}" environment will be used. Unless {cmd:hardcode} is
    specified, the log file will be included in the LaTeX document using command
    \verbatiminput{c -(}{c )-}, which requires \usepackage{c -(}verbatim{c )-}
    in the preamble of the LaTeX document.

{dlgtab:Contents}

{phang}
    [{cmd:no}]{cmd:output} specifies whether to suppress command output in the
    log. The default is {cmd:output}, i.e. to display the output. If
    {cmd:nooutput} is specified, {cmd:set output inform} is applied before
    running the commands and, after closing the log, {cmd:set output proc} is
    applied to turn output back on ({helpb set output}). {cmd:nooutput} has no
    effect if {cmd:cmdlog} is specified. Furthermore, {cmd:nooutput} has no effect if
    specified with the using-form or the colon-form of {cmd:texdoc stlog}.

{phang}
    [{cmd:no}]{cmd:matastrip} specifies whether to strip Mata opening and ending
    commands from the Stata output. The default is {cmd:nomatastrip},
    i.e. to retain the Mata opening and ending commands. If you type
    {cmd:matastrip}, the {cmd:mata} or {cmd:mata:} command invoking Mata
    and the subsequent {cmd:end} command exiting Mata will be removed
    from the log. {cmd:matastrip} only has an effect if the Mata opening
    command is the first command in the output section.

{phang}
    [{cmd:no}]{cmd:cmdstrip} specifies whether to strip command lines from the
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
    command lines that were broken by a line break comment will be replaced
    by white space.

{phang}
    [{cmd:no}]{cmd:ltrim} specifies whether to remove indentation of
    commands (i.e. whether to remove white space on the left of
    commands) before running the commands and creating the log. The default
    is {cmd:ltrim}, that is, to remove indentation. The amount of white space
    to be removed is determined by the minimum indentation in the block of
    commands. {cmd:ltrim} has no effect on commands
    called from an external do-file by {cmd:texdoc stlog using}.

{dlgtab:Highlighting}

{phang}
    {opt alert(strlist)} adds the \alert{} command to all occurrences of the
    specified strings, where {it:strlist} is

            {it:string} [{it:string} ...]

{pmore}
    Enclose {it:string} in double quotes if it contains blanks; use compound
    double quotes if it contains double quotes.

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
    [{cmd:no}]{opt beamer} specifies whether to include the beamer argument in the
    code displaying the log in the LaTeX document. The default is 
    {cmd:nobeamer}, i.e. to use \begin{c -(}stlog{c )-} ... \end{c -(}stlog{c )-}
    to display the log. If {cmd:beamer} is specified, the log file will be displayed using 
    \begin{c -(}stlog{c )-}[beamer] ... \end{c -(}stlog{c )-}.

{phang}
    [{cmd:no}]{cmd:hardcode} specifies whether the Stata output is copied into
    the LaTeX document. The default is {cmd:nohardcode}, i.e. to include
    a link to the log file using an \input{c -(}{c )-} statement in the LaTeX
    document. If {cmd:hardcode} is specified, the log file will be copied
    directly into the LaTeX document.

{phang}
    [{cmd:no}]{cmd:keep} specifies whether the external log file will be kept.
    This is only relevant if {cmd:hardcode} has been specified. The
    default is {cmd:keep}, i.e. to keep the log file so that {cmd:nodo} can be
    applied later on. Type {cmd:nokeep} if you want to erase the external log
    file.

{phang}
    [{cmd:no}]{cmd:custom} specifies whether to use custom code to include the log
    file in the LaTeX document. The default is {cmd:nocustom}, i.e. to use
    standard code to include the log. Specify {cmd:custom} if you want to skip
    the standard code and take care of including the log yourself.

{phang}
    [{cmd:no}]{opt certify} specifies whether to compare the current results
    to the previous version of the log file (if a previous version exists). The
    default is {cmd:nocertify}. Specify {cmd:certify} if you want to confirm
    that the output did not change. In case of a difference, {cmd:texdoc} will
    stop execution and display an error message. {cmd:certify} has no effect if
    {cmd:nolog} or {cmd:cmdlog} is specified.

{phang}
    {cmd:nostop} allows continuing execution even if an error occurs. Use the
    {cmd:nostop} option if you want to log output from a command that returns
    error. The {cmd:nostop} option is only allowed with {cmd:texdoc stlog using}.


{marker groptions}{...}
{title:Options for texdoc graph}

{dlgtab:Main}

{phang}
    {opt as(fileformats)} sets the output format(s). The default is
    {cmd:as(pdf)}. See help {helpb graph export} for available formats. Multiple
    formats may be specified, e.g. {cmd:as(pdf eps)}, in which case
    {cmd:texdoc graph} will create multiple graph files.

{phang}
    {opt name(name)} specifies the name of the graph window to be
    exported. The default is to export the topmost graph.

{phang}
    {it:override_options} are format-dependent options to modify how the
    graph is converted. See help {helpb graph export} for details.

{dlgtab:Environment}

{phang}
    [{cmd:no}]{opt center} specifies whether to center the graph horizontally
    in the LaTeX document. The default is {cmd:center}.

{phang}
    [{cmd:no}]{opt figure}[{cmd:(}{it:args}{cmd:)}] specifies whether to
    include the graph in a (floating) figure environment. The default is
    {cmd:nofigure}. Specify {opt figure(args)} to provide arguments to be passed
    through to the figure environment (as in \begin{c -(}figure{c )-}[{it:args}]).

{phang}
    {opt caption(string)} provides a caption for the figure. {cmd:caption()}
    implies {cmd:figure} (unless {cmd:nofigure} is specified).

{phang}
    {opt label(string)} provides a cross-reference label for the figure. {cmd:label()}
    implies {cmd:figure} (unless {cmd:nofigure} is specified).

{phang}
    {opt cabove} or {opt cbelow} specify whether the caption is printed
    above or below the figure. Only one of {cmd:cabove} and {cmd:cbelow} is
    allowed. {cmd:cbelow} is the default.

{dlgtab:Include command}

{phang}
    {opt optagrs(args)} specifies optional arguments to be passed through to
    \includegraphics (as in
    \includegraphics[{it:args}]{c -(}{it:filename}{c )-})
    or to \epsfig (as in
    \epsfig{c -(}file={it:filename},{it:args}{c )-}).

{phang}
    [{cmd:no}]{opt suffix} specifies whether to type the file suffix in
    \includegraphics or \epsfig. If only one output format is specified in
    {cmd:as()}, the default is to type the file suffix. If multiple output
    formats are specified in {cmd:as()}, the default is to omit the suffix. If
    option {cmd:suffix} is specified with multiple output formats,
    the suffix is determined by the first output format.

{phang}
    [{cmd:no}]{opt epsfig} specifies whether to use \epsfig instead of
    \includegraphics to include the graph in the LaTeX document. The default
    is {cmd:noepsfig}, i.e. to use \includegraphics. Option {cmd:epsfig}
    implies {cmd:as(eps)} (unless specified otherwise).

{phang}
    [{cmd:no}]{cmd:custom} specifies whether to use custom code to include the
    graph in the LaTeX document. The default is {cmd:nocustom}, in which case
    {cmd:texdoc graph} writes code to the LaTeX document to include the
    graph. Specify {cmd:custom} if you want to skip the standard code and take
    care of including the graph yourself.


{marker stripoptions}{...}
{title:Options for texdoc strip}

{phang}
    {cmd:replace} allows overwriting an existing file.

{phang}
    {cmd:append} appends results to an existing file.


{marker examples}{...}
{title:Examples}

    {help texdoc##basicexample:Basic example}
    {help texdoc##graphs:Graphs}
    {help texdoc##oom:Output-omitted tag}
    {help texdoc##fexmpl:Further examples}

{marker basicexample}{...}
{dlgtab:Basic example}

{pstd}
    A typical do-file containing {cmd:texdoc} commands might look as follows:

        --- myexample.texdoc ---
        texdoc init myexample.tex, replace

        /***
        \documentclass{c -(}article{c )-}
        \usepackage{c -(}graphicx{c )-}
        \usepackage{c -(}stata{c )-}
        \begin{c -(}document{c )-}

        \section{c -(}Exercise 1{c )-}
        Open the 1978 Automobile Data and summarize the variables.

        ***/

        texdoc stlog
        sysuse auto
        summarize
        texdoc stlog close

        /***

        \section{c -(}Exercise 2{c )-}
        Run a regression of price on milage and weight.

        ***/

        texdoc stlog
        regress price mpg weight
        texdoc stlog close

        /***

        \end{c -(}document{c )-}
        ***/
        --- end of file ---

{pstd}
    To process the file, type

        {com}. texdoc do myexample.texdoc
        {txt}{...}

{pstd}
    This will create file "myexample.tex" and two Stata output log files,
    "myexample_1.log.tex" and "myexample_2.log.tex", in the same directory. The
    contents of "myexample.tex" will be:

        --- myexample.tex ---
        \documentclass{c -(}article{c )-}
        \usepackage{c -(}graphicx{c )-}
        \usepackage{c -(}stata{c )-}
        \begin{c -(}document{c )-}

        \section{c -(}Exercise 1{c )-}
        Open the 1978 Automobile Data and summarize the variables.

        \begin{c -(}stlog{c )-}\input{c -(}myexample_1.log.tex{c )-}\end{c -(}stlog{c )-}

        \section{c -(}Exercise 2{c )-}
        Run a regression of price on milage and weight.

        \begin{c -(}stlog{c )-}\input{c -(}myexample_2.log.tex{c )-}\end{c -(}stlog{c )-}

        \end{c -(}document{c )-}
        --- end of file ---

{marker graphs}{...}
{dlgtab:Graphs}

{pstd}
    To include a graph along with the Stata output, you could add
    \usepackage{c -(}graphicx{c )-} to the preamble (as above) and type:

        /***
        \section{c -(}Exercise 3{c )-}
        Draw a scatter plot of price by milage.

        ***/

        texdoc stlog
        scatter price mpg
        texdoc stlog close
        texdoc graph

{pstd}
    This would create file "myexample_3.pdf" and insert the following code in
    the LaTeX document:

        \section{c -(}Exercise 3{c )-}
        Draw a scatter plot of price by milage.

        \begin{c -(}stlog{c )-}\input{c -(}myexample_3.log.tex{c )-}\end{c -(}stlog{c )-}
        \begin{c -(}center{c )-}
            \includegraphics{c -(}myexample_3{c )-}
        \end{c -(}center{c )-}

{pstd}
    If you only want to display the graph but not the log file,
    add the {cmd:nolog} option to {cmd:texdoc stlog}. Furthermore, to place the
    graph in a figure environment, you could type

        texdoc stlog, nolog
        scatter price mpg
        texdoc stlog close
        texdoc graph, figure caption(Scatter plot of price against mpg) label(figure1)

{pstd}
    which results in:

        \begin{c -(}figure{c )-}
            \centering
            \includegraphics{c -(}myexample_4{c )-}
            \caption{c -(}Scatter plot of price against mpg{c )-}
            \label{c -(}figure1{c )-}
        \end{c -(}figure{c )-}

{pstd}
    The {cmd:figure} option is not strictly required in the example since
    {cmd:caption()} and {cmd:label()} imply {cmd:figure}.

{marker oom}{...}
{dlgtab:Output-omitted tag}

{pstd}
    To suppress the output of a command in a Stata output section and add an
    "(output omitted)" message use the {cmd:texdoc stlog oom} command. Example:

        texdoc stlog
        sysuse auto
        texdoc stlog oom regress price mpg weight
        predict r, residuals
        summarize r
        texdoc stlog close

{pstd}
    "texdoc stlog oom " will be removed from the output and the results from
    {cmd:regress} will be replaced by "\oom", the LaTeX command from the "stata"
    package to create the "(output omitted)" message. You can also code

        texdoc stlog oom ///
        regress price mpg weight

{pstd}
    so that the full line width is available for the regress
    command. "texdoc stlog oom ///" and the line break will be removed from
    the output. To be precise {cmd:texdoc stlog oom} assumes the Stata command
    to start at the next non-blank character after {cmd:oom} that is not part
    of a comment; everything up to that point will be removed.

{marker fexmpl}{...}
{dlgtab:Further examples}

{pstd}
    For further examples see {cmd:texdoc}'s website at
    {browse "http://repec.sowi.unibe.ch/stata/texdoc"}, the
    {browse "http://ideas.repec.org/p/bss/wpaper/14.html":working paper}, or the
    {browse "http://www.stata-journal.com/article.html?article=pr0062":Stata Journal article}.


{marker remarks}{...}
{title:Remarks}

    {help texdoc##substitute:texdoc substitute}
    {help texdoc##local:texdoc local}
    {help texdoc##specialchars:Special characters}
    {help texdoc##limitations:Limitations}
    {help texdoc##globals:Global macros}

{marker substitute}{...}
{dlgtab:texdoc substitute}

{pstd}
    After the output document has been initialized, the {cmd:texdoc substitute}
    command can be used to define text substitutions that will be applied to
    all subsequent {cmd:/*tex tex*/} or {cmd:/*** ***/} blocks. For example, type

        texdoc substitute "some text" "SOME TEXT" "more text" "MORE TEXT"

{pstd}
    to replace all instances of "some text" by "SOME TEXT" and
    all instances of "more text" by "MORE TEXT". To change the
    substitution definitions in a later part of the document, specify
    {cmd:texdoc substitute} again with new definitions. To add definitions to the
    existing definitions, specify {cmd:texdoc substitute} with the {cmd:add}
    option. To deactivate the substitutions, specify {cmd:texdoc substitute}
    without arguments.

{marker local}{...}
{dlgtab:texdoc local}

{pstd}
    The {cmd:texdoc local} command can be used to define local macros that will
    be backed up on disk. It may only be applied within or after a {cmd:texdoc stlog}
    section. The locals will be backed up in a library that has the same name as
    the Stata output section (using file suffix ".stloc"). Each output section
    has its own library, so that the names of the locals can be reused between
    sections. The syntax of {cmd:texdoc local} is the same as the syntax of
    Stata's regular {cmd:local} command; see help {helpb local}.

{pstd}
    Use the {cmd:texdoc local} command if you want to include results from an
    output section in the text body. {cmd:texdoc local} provides a way to store
    the elements you want to include in your text so that they are still
    available in later runs when you suppress computations using the {cmd:nodo}
    option. The local macros defined by {cmd:texdoc local} will be expanded in
    subsequent {cmd:/*tex tex*/} or {cmd:/*** ***/} blocks up until the next
    {cmd:texdoc stlog} command. Alternatively, you may use {cmd:texdoc write}
    to write the locals to the output document (there is a slight difference
    between the two approaches: expansion in {cmd:/*tex tex*/} and
    {cmd:/*** ***/} blocks is based on the locals as stored in the library
    file; {cmd:texdoc write} uses the current values of the locals). For
    example, to cite the point estimate and standard error of a regression
    coefficient, you could type:

        texdoc stlog
        regress y x1 x2 ...
        texdoc stlog close
        texdoc local b = strofreal(_b[x1], "%9.3f")
        texdoc local se = strofreal(_se[x1], "%9.3f")

        /*** As can be seen in the output above, the estimate for the effect
        of x1 on y is equal to `b' (with a standard error of `se'). ***/

{pstd}
    Alternatively, you could also type:

        texdoc write As can be seen in the output above, the estimate for
        texdoc write the effect of x1 on y is equal to `b' (with a standard
        texdoc write error of `se').

{marker specialchars}{...}
{dlgtab:Special characters}

{pstd}
    The {cmd:$} character is used for global macro expansion in Stata. If you
    use the {cmd:texdoc write} command to write LaTeX code
    containing {cmd:$} math delimiters, type {cmd:\$} instead of
    {cmd:$}. For example, type

        {com}. texdoc write This is an inline equation: \$y = x^2\${txt}

{pstd}
    An alternative is to abandon {cmd:$} and use {cmd:\(} and {cmd:\)} as
    math delimiters. That is, type

        {com}. texdoc write This is an inline equation: \(y = x^2\){txt}

{pstd}
    No such precautions are required if you use the
    {cmd:/*tex tex*/} delimiter structure, since in this
    case an exact copy of the specified code is written to the LaTeX document.

{marker limitations}{...}
{dlgtab:Limitations}

{pstd}
    {cmd:texdoc} tries to create missing subdirectories using Mata's
    {helpb mf_mkdir:mkdir()} function. Usually, this only works if all
    intermediate directories leading to the target subdirectory already
    exist. If {helpb mf_mkdir:mkdir()} fails, you will need to create the
    required directories manually prior to running {cmd:texdoc}.

{pstd}
    {cmd:texdoc stlog} cannot be nested. Furthermore, do not use
    {cmd:texdoc do} or {cmd:texdoc init} within a {cmd:texdoc stlog} section.

{pstd}
    When processing a do-file, {cmd:texdoc do} does not parse the contents
    of do-files that may be called from the main do-file using the {helpb do}
    command. As a consequence, for example, {cmd:/*tex tex*/} blocks in such a file
    will be ignored and some of the {cmd:texdoc} options will not work. However,
    you can use {cmd:texdoc do} to include such do-files (i.e. {cmd:texdoc do} can be nested).

{pstd}
    In general, {cmd:texdoc} commands should always start on a new line with
    {cmd:texdoc} being the first (non-comment) word on the line (for example, do not use
    {cmd:quietly texdoc ...} or similar).

{pstd}
    {cmd:texdoc do} only provides limited support for the semicolon command
    delimiter (see {helpb #delimit}). The semicolon command delimiter should work
    as expected as long as it is turned on and off between {cmd:/*tex tex*/}
    blocks and between {cmd:texdoc} commands. Do not use semicolons to
    delimit {cmd:texdoc} commands.

{marker globals}{...}
{dlgtab:Global macros}

{pstd}
    {cmd:texdoc} maintains a number of global macros for communication between
    {cmd:texdoc} commands. Do not change or erase these global macros while
    working with {cmd:texdoc}.

{pstd}
    Global macros maintained by {cmd:texdoc do} (will be cleared when
    {cmd:texdoc do} terminates):
    {cmd:TeXdoc_dofile}, {cmd:TeXdoc_do_snippets}, {cmd:TeXdoc_do_replace},
    {cmd:TeXdoc_do_append}, {cmd:TeXdoc_do_logall}, {cmd:TeXdoc_do_linesize},
    {cmd:TeXdoc_do_nodo}, {cmd:TeXdoc_do_nolog}, {cmd:TeXdoc_do_cmdlog},
    {cmd:TeXdoc_do_verbatim}, {cmd:TeXdoc_do_nooutput},
    {cmd:TeXdoc_do_matastrip}, {cmd:TeXdoc_do_cmdstrip},
    {cmd:TeXdoc_do_lbstrip}, {cmd:TeXdoc_do_gtstrip}, {cmd:TeXdoc_do_noltrim},
    {cmd:TeXdoc_do_alert}, {cmd:TeXdoc_do_tag}, {cmd:TeXdoc_do_hardcode},
    {cmd:TeXdoc_do_nokeep}, {cmd:TeXdoc_do_custom}, {cmd:TeXdoc_do_certify},
    {cmd:TeXdoc_do_gropts}, {cmd:TeXdoc_do_logdir}, {cmd:TeXdoc_do_logdir2},
    {cmd:TeXdoc_do_grdir}, {cmd:TeXdoc_do_noprefix}, {cmd:TeXdoc_do_prefix},
    {cmd:TeXdoc_do_prefix2}, {cmd:TeXdoc_do_stpath}, {cmd:TeXdoc_do_stpath2},

{pstd}
    Global macros maintained by {cmd:texdoc init} (will be cleared by
    {cmd:texdoc close}):
    {cmd:TeXdoc_docname}, {cmd:TeXdoc_docname0}, {cmd:TeXdoc_basename},
    {cmd:TeXdoc_path}, {cmd:TeXdoc_path0}, {cmd:TeXdoc_stcounter},
    {cmd:TeXdoc_logall}, {cmd:TeXdoc_linesize}, {cmd:TeXdoc_nodo},
    {cmd:TeXdoc_nolog}, {cmd:TeXdoc_cmdlog}, {cmd:TeXdoc_verbatim},
    {cmd:TeXdoc_nooutput}, {cmd:TeXdoc_matastrip}, {cmd:TeXdoc_cmdstrip},
    {cmd:TeXdoc_lbstrip}, {cmd:TeXdoc_gtstrip}, {cmd:TeXdoc_noltrim},
    {cmd:TeXdoc_alert}, {cmd:TeXdoc_tag}, {cmd:TeXdoc_hardcode},
    {cmd:TeXdoc_nokeep}, {cmd:TeXdoc_custom}, {cmd:TeXdoc_certify},
    {cmd:TeXdoc_gropts}, {cmd:TeXdoc_logdir}, {cmd:TeXdoc_grdir},
    {cmd:TeXdoc_prefix}, {cmd:TeXdoc_prefix0}, {cmd:TeXdoc_stpath}

{pstd}
    Global macro maintained by {cmd:texdoc substitute} (will be cleared by
    {cmd:texdoc close}): {cmd:TeXdoc_substitute}

{pstd}
    Global macros maintained by {cmd:texdoc stlog} (will be cleared by
    {cmd:texdoc close}): {cmd:TeXdoc_ststatus}, {cmd:TeXdoc_stname},
    {cmd:TeXdoc_stname0}, {cmd:TeXdoc_stfilename}, {cmd:TeXdoc_stfilename0},
    {cmd:TeXdoc_sttexname}, {cmd:TeXdoc_sttexname0}, {cmd:TeXdoc_stgrcounter},
    {cmd:TeXdoc_stlinesize}, {cmd:TeXdoc_stlinesize0}, {cmd:TeXdoc_stnodo},
    {cmd:TeXdoc_stnolog}, {cmd:TeXdoc_stcmdlog}, {cmd:TeXdoc_stverbatim},
    {cmd:TeXdoc_stnooutput}, {cmd:TeXdoc_stmatastrip}, {cmd:TeXdoc_stcmdstrip},
    {cmd:TeXdoc_stlbstrip}, {cmd:TeXdoc_stgtstrip}, {cmd:TeXdoc_stnoltrim},
    {cmd:TeXdoc_stalert}, {cmd:TeXdoc_sttag}, {cmd:TeXdoc_sthardcode},
    {cmd:TeXdoc_stnokeep}, {cmd:TeXdoc_stcustom}, {cmd:TeXdoc_stcertify}

{pstd}
    Global macro maintained by {cmd:texdoc local} (will be cleared by
    {cmd:texdoc stlog} or {cmd:texdoc close}): {cmd:TeXdoc_stloc}

{pstd}
    In addition, {cmd:texdoc do} maintains an external Mata global called
    {cmd:TeXdoc_do_snippets}. Do not modify the contents of this external
    global. If the external global is deleted (e.g. because the processed
    do-file contains a {cmd:clear all} command), {cmd:texdoc do} automatically
    restores it. The external global will be removed when {cmd:texdoc do}
    terminates.


{marker results}{...}
{title:Stored results}

{pstd}
     {cmd:texdoc init} clears {cmd:s()}, and
     {cmd:texdoc close} stores the following in {cmd:s()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2:Macros}{p_end}
{synopt:{cmd:s(docname)}}name of LaTeX document (including absolute path)
    {p_end}
{synopt:{cmd:s(basename)}}base name of LaTeX document (excluding path)
    {p_end}
{synopt:{cmd:s(path)}}(absolute) path of LaTeX document
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
{synopt:{cmd:s(verbatim)}}{cmd:verbatim} or empty
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
{synopt:{cmd:s(alert)}}contents of {cmd:alert()} option
    {p_end}
{synopt:{cmd:s(tag)}}contents of {cmd:tag()} option
    {p_end}
{synopt:{cmd:s(hardcode)}}{cmd:hardcode} or empty
    {p_end}
{synopt:{cmd:s(nokeep)}}{cmd:nokeep} or empty
    {p_end}
{synopt:{cmd:s(custom)}}{cmd:custom} or empty
    {p_end}
{synopt:{cmd:s(certify)}}{cmd:certify} or empty
    {p_end}
{synopt:{cmd:s(gropts)}}default graph export options
    {p_end}
{synopt:{cmd:s(logdir)}}subdirectory used for Stata log files
    {p_end}
{synopt:{cmd:s(grdir)}}subdirectory used for graphs (if different from {cmd:s(logdir)})
    {p_end}
{synopt:{cmd:s(prefix)}}prefix for automatic Stata log names
    {p_end}
{synopt:{cmd:s(stpath)}}include-path to be used for Stata logs in
    LaTeX document
    {p_end}

{pstd}
    {cmd:texdoc stlog close} stores the following in {cmd:s()}:

{synoptset 18 tabbed}{...}
{p2col 5 18 22 2:Macros}{p_end}
{synopt:{cmd:s(name)}}name of the Stata output log, including {cmd:logdir()} path
    {p_end}
{synopt:{cmd:s(name0)}}{cmd:s(name)} without {cmd:logdir()} path
    {p_end}
{synopt:{cmd:s(filename)}}name of log file on disk (including absolute path and suffix)
    {p_end}
{synopt:{cmd:s(filename0)}}{cmd:s(filename)} without suffix
    {p_end}
{synopt:{cmd:s(texname)}}name of log file with include-path for use in LaTeX document
    {p_end}
{synopt:{cmd:s(texname0)}}{cmd:s(texname)} without suffix
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
{synopt:{cmd:s(verbatim)}}{cmd:verbatim} or empty
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
{synopt:{cmd:s(alert)}}contents of {cmd:alert()} option
    {p_end}
{synopt:{cmd:s(tag)}}contents of {cmd:tag()} option
    {p_end}
{synopt:{cmd:s(hardcode)}}{cmd:hardcode} or empty
    {p_end}
{synopt:{cmd:s(nokeep)}}{cmd:nokeep} or empty
    {p_end}
{synopt:{cmd:s(custom)}}{cmd:custom} or empty
    {p_end}
{synopt:{cmd:s(certify)}}{cmd:certify} or empty
    {p_end}


{marker references}{...}
{title:References}

{phang}
    Rising, Bill (2008). Reproducible Research: Weaving with Stata. Italian Stata
    Users Group Meeting 2008. Available from
    {browse "http://www.stata.com/meeting/italy08/rising_2008.pdf"}.


{marker author}{...}
{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@soz.unibe.ch

{pstd}
    The {cmd:append} option has been suggested by Jorge Eduardo P{c e'}rez. Uli
    Kohler suggested the {cmd:nostop} and {cmd:gtstrip} options.

{pstd}
    Thanks for citing this software in one of the following ways:

{pmore}
    Jann, Ben (2016). Creating LaTeX documents from within Stata using
    texdoc. The Stata Journal 16(2): 245-263.

{pmore}
    Jann, Ben (2015). Creating LaTeX documents from within Stata using
    texdoc. University of Bern Social Sciences Working Papers No. 14. Available
    from {browse "http://ideas.repec.org/p/bss/wpaper/14.html"}.

{pmore}
    Jann, B. (2009). texdoc: Stata module to create a LaTeX document
    including Stata output. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457021.html"}.


{marker alsosee}{...}
{title:Also see}

{psee}
    Online:  help for
    {helpb file},
    {helpb log};
    {helpb sjlatex} (if installed),
    {helpb webdoc} (if installed)

