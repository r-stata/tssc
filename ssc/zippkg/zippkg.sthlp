{smcl}
{* *! version 1.0 26 March 2019}{...}
{vieweralsosee "[R] net" "help net"}{...}
{vieweralsosee "[R] ssc" "help ssc"}{...}
{vieweralsosee "[D] checksum" "help checksum"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] net" "mansection R net"}{...}
{vieweralsosee "[R] ssc" "mansection R ssc"}{...}
{vieweralsosee "[D] checksum" "mansection D checksum"}{...}
{viewerjumpto "Syntax" "zippkg##syntax"}{...}
{viewerjumpto "Description" "zippkg##description"}{...}
{viewerjumpto "Options" "zippkg##options"}{...}
{viewerjumpto "Remarks" "zippkg##remarks"}{...}
{viewerjumpto "Examples" "zippkg##examples"}{...}
{viewerjumpto "Author" "zippkg##author"}{...}
{viewerjumpto "Also see" "zippkg##alsosee"}{...}
help for {cmd:zippkg}{right:version 1.0 (26 March 2019)}
{hline}


{title:Title}

{phang}
{bf:zippkg} {hline 2} A Stata module to create ZIP archives of
 community-contributed content for offline distribution{p_end}


{title:Table of contents}

        {help zippkg##syntax:Syntax}
        {help zippkg##description:Description}
        {help zippkg##options:Options}
        {help zippkg##remarks:Remarks}
        {help zippkg##examples:Examples}
        {help zippkg##author:Author}
        {help zippkg##alsosee:Also see}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:zippkg}
{it:pgkspec}
[{cmd:,}
{help zippkg##zippkgopts:zippkg_options}]

{phang}where the syntax of {it:pkgspec} is

{pin}
[{cmd:(}]
{it:pkglist} {cmd:,}
{help zippkg##pkgspecopts:pkgspec_options}
[{cmd:)}] [{cmd:||}]

{phang}and {it:pkglist} is a list of packages names

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{marker zippkgopts}{...}
{syntab:{cmd:zippkg} options}

{synopt:{opt f:rom(directory_or_url)}} requests to use {it:directory_or_url} as
installation source; the special keyword {input:"ssc"} is allowed (and used as
default if the option is omitted), any other content will be passed through to
{help net##options_net_install:net install}{p_end}
{synopt:{opt all}}also download ancillary files; will be passed through to
{help net##options_net_install:net install} or
{help ssc##options_ssc_install:ssc}, respectively{p_end}
{synopt:{opt notrack:file}}do not include ({it:stata.trk}) in the archive
file{p_end}
{synopt:{opt fl:at}}requests that the archive file(s) created should not
contain a directory structure{p_end}
{synopt:{opt s:ingle}}instead of creating a joint archive file for all packages
requested, create a single archive file for each {it:pkglist}{p_end}
{synopt:{opt sav:ing}{bf:(}{it:{help filename}}{bf:)}}save output archive as
{it:{help filename}}; if {it:filename} is specified without a file extension,
{input:.zip} is assumed{p_end}
{synopt:{opt replace}}replace the output archive file(s), if already
present{p_end}
{synopt:{opt checksum:s}}activate Stata's checksum mechanism before downloading
files{p_end}
{synopt:{opt v:erbose}}give verbose output{p_end}

{marker pkgspecopts}{...}
{syntab:{it:pgkspec} options}{...}

{synopt:{opt f:rom(directory_or_url)}} requests to use {it:directory_or_url} as
installation source; the special keyword {input:"ssc"} is allowed (and used as
default if the option is omitted), any other content will be passed through to
{help net##options_net_install:net install}{p_end}
{synopt:{opt all}}also download ancillary files; will be passed through to
{help net##options_net_install:net install} or
{help ssc##options_ssc_install:ssc}, respectively{p_end}
{synopt:{opt notrack:file}}do not include ({it:stata.trk}) in the archive
file{p_end}
{synopt:{opt fl:at}}requests that the archive file(s) created should not
contain a directory structure{p_end}
{synopt:{opt sav:ing}{bf:(}{it:{help filename}}{bf:)}}save output archive as
{it:{help filename}}; if {it:filename} is specified without a file extension,
{input:.zip} is assumed{p_end}
{synopt:{opt replace}}replace the output archive file(s), if already
present{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:zippkg} is a tool to download community-contributed content from the
internet, and create a ZIP archive from it. Its purpose is to ease the
distribution of such content to machines not connected to the internet, be it
in data centers, secure enclaves, or any other scenario.{break}Also, it may help
in equipping new Stata installations with a set of preinstalled packages.
{p_end}

{pstd}
Downloading several packages from different sources is supported via a syntax
mechanism similar to the one of {help graph twoway##remarks2:graph twoway}; both
variants ({input:||}-separator notation and {input:()}-binding notation) are
supported.{break}When using {cmd:zippkg} this way, some options are available as
{it:"global"} options to {cmd:zippkg} only, while others are available as in the
scope of each {it:pkgspec} as well. See {help zippkg##options:section options}
for a detailed description of the options, and an overview table showcasing
option availibility.{p_end}


{marker options}{...}
{title:Options}

{phang}Availability of options:{p_end}

{pmore}option name{bind:      }{cmd:zippkg} option{bind:      }{it:pkgspec}
option{p_end}
{p2line}
{pmore}from(){bind:           }yes{bind:                }yes{p_end}
{pmore}all{bind:              }yes{bind:                }yes{p_end}
{pmore}saving(){bind:         }yes{bind:                }yes{p_end}
{pmore}notrackfile{bind:      }yes{bind:                }yes{p_end}
{pmore}flat{bind:             }yes{bind:                }yes{p_end}
{pmore}replace{bind:          }yes{bind:                }yes{p_end}
{pmore}single{bind:           }yes{bind:                }no{p_end}
{pmore}checksums{bind:        }yes{bind:                }no{p_end}
{pmore}verbose{bind:          }yes{bind:                }no{p_end}

{phang}If an option is specified both as {cmd:zippkg} option and {it:pkgspec}
option, the {it:pkgspec} option always takes precedence.{p_end}

{dlgtab:downloading}

{pstd} Options for downloading content:{p_end}

{phang}{opt from(directory_or_url)} requests to use {it:directory_or_url} as
installation source for the packages in {it:pkglist}. It will be passed through
to {help net##options_net_install:net install}, unless the special keyword
{input:"ssc"} is specified.{break}The special keyword {input:"ssc"}, which is
the default if the option is omitted, makes {cmd:zippkg} use the command
{help ssc:ssc install} for package installation instead of
{help net:net install} in order to use the
{browse "https://ideas.repec.org/s/boc/bocode.html":Statistical Software Components}
(SSC) archive as installation source.{p_end}

{phang}
{opt all} requests to also download ancillary files (and include in the
resulting archive file). It will be passed through to
{help net##options_net_install:net install} or
{help ssc##options_ssc_install:ssc} (if SSC is the installation source).{break}
Note that ancillary files that have been downloaded that way always are placed
at the top-level directory of the created archive file, regardless of the option
{opt flat}. This may induce errors in creating the archive file in case two
packages ship ancillary files with the same name.{p_end}

{phang}
{opt checksums} requests to activate Stata's checksum (see
{help checksum:help checksum}) mechanism before downloading files. When
specified, {cmd:zippkg} will "{input:set checksum on}" before downloading files,
and reset the setting afterwards.{p_end}

{dlgtab:ZIP options}

{pstd} Options creating the ZIP archive:{p_end}

{phang}{opt saving(filename)} requests the archive file created to be named
{it:filename}. If {it:filename} is specified without a file extension,
{input:.zip} is assumed.{break}If the option is omitted (and the {cmd:zippkg}
option {opt single} is not specified), {input:"./zippkg.zip"} will be used as
the default. This will create a file named {bf:zippkg.zip} in the current
working directory of Stata.{break}If the option is omitted and option
{opt single} {it:is} specified, the default is to create archives named
{bf:zippkg{it:#}.zip} in the Stata's working directory, where {it:#} denotes a
running integer.{break} Options {opt single} and
{opt saving(filename)} are mutually exclusive as {cmd:zippkg} options, with
{opt single} taking precedence if both are specified.{p_end}

{phang}{opt notrackfile} specifies that Stata's internal tracking file of
installed packages ({it:stata.trk}) not be included in the archive file(s).
{p_end}

{phang}{opt flat} requests that the archive file(s) created should not contain a
directory structure. By default, the archive file(s) will contain the typical
directory structure Stata uses in the PLUS directory (see {help sysdir}). When
the option {opt flat} is specified, all files will be saved in the top-level
directory of the archive(s).{p_end}

{phang}{opt replace} requests to overwrite existing archive, instead of aborting
with an error message.{p_end}

{phang}{opt single} requests that single archive files will be created for each
{it:pkglist} downloaded, instead of a joint archive file for all packages. Each
of the single archive files will be named {input:zippkg{it:#}.zip}, and saved
to Stata's current working directory. In the archive name, {it:#} denotes a
running integer for the {it:pkglist}{break}This option literally is a shortcut
to manually specifying {input:saving(zippkg{it:#}.zip)} in each {it:pkgspec}
manually.{break}Options {opt single} and {opt saving(filename)}, when specified
as global {cmd:zippkg} options, are mutually exclusive, with {opt single} taking
precedence if both are specified.{break}In the scope of {it:pkgspec} options,
{opt saving} implies {opt single}.{p_end}

{dlgtab:advanced}

{phang}{opt verbose} gives verbose output during the process. This may be
desired to identify downloading problems.{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:zippkg} will reset the installation directories for {help net } to its
factory defaults (i.e. it executes "{input:net set ado PLUS}" and
"{input:net set other}" after downloading files). This may modify user settings,
if the default paths have been changed. Please contact the author if you have a
good idea on how to prevent this.
{p_end}

{pstd}
The source code of the program is licensed under the
GNU General Public License version 3 or later.
The corresponding license text can be found on the internet at
{browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker examples}{...}
{title:Examples}

{phang}Download packages {it:fre} and {it:catplot} from SSC:{p_end}
{phang}{input:. zippkg fre catplot}{p_end}

{phang}Download packages {it:fre} and {it:catplot} from SSC , and {it:sjlatex}
from {browse "https://www.stata-journal.com/production"}:{p_end}
{phang}{input}. zippkg (fre catplot) (sjlatex ,
from("https://www.stata-journal.com/production")){reset}{p_end}

{phang}Do the same, but using the {input:||}-separator notation rather than
the {input:()}-binding notation:{p_end}
{phang}{input}. zippkg fre catplot || sjlatex ,
from("https://www.stata-journal.com/production"){reset}{p_end}

{phang}Download the same packages, but place each in its single archive
file:{p_end}
{phang}{input}. zippkg (fre catplot) (sjlatex ,
from("https://www.stata-journal.com/production")) , single{reset}{p_end}

{phang}Do the same, but using the {input:||}-separator notation rather than
the {input:()}-binding notation:{p_end}
{phang}{input}. zippkg fre catplot || sjlatex ,
from("https://www.stata-journal.com/production") || , single{reset}{p_end}

{phang}Download the same packages, but use a custom file name for the resulting
(joint) archive:{p_end}
{phang}{input}. zippkg (fre catplot) (sjlatex ,
from("https://www.stata-journal.com/production")) , 
saving(my_packages.zip){reset}{p_end}

{phang}Download four packages from SSC, but save separate archive files with
their authors' names:{p_end}
{phang}{input}. zippkg (fre estout , saving(jann_pkgs.zip)) (catplot missings,
saving(cox_pkgs.zip)){reset}{p_end}


{marker author}{...}
{title:Author}

{pstd}
Daniel Bela ({browse "mailto:daniel.bela@lifbi.de":daniel.bela@lifbi.de}),
Leibniz Institute for Educational Trajectories (LIfBi), Germany.{break}
Support via {browse "https://github.com/dirtyhawk/stata-zippkg"}.
{p_end}


{marker alsosee}{...}
{title:Also see}

{psee}
{help net}, {help ssc}, {help checksum}
{p_end}
