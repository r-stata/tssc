{smcl}
{* *! version 1.0  05jul2015}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "jcd##syntax"}{...}
{viewerjumpto "Description" "jcd##description"}{...}
{viewerjumpto "Setup" "jcd##setup"}{...}
{viewerjumpto "Plugin Interface" "jcd##interface"}{...}
{viewerjumpto "Remarks" "jcd##remarks"}{...}
{viewerjumpto "Dependencies" "jcd##dependencies"}{...}
{title:Title}

{phang}
{bf:jcd} {hline 2} Dynamically load and call Java plugins


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:jcd}
{it:class}
[{varlist}]
{ifin}
[{cmd:,} {opt args(argument_list)}]


{marker description}{...}
{title:Description}

{pstd}
The Stata {it:Dynamic Plugin Loader} (DPL) is Stata Java plugin to dynamically load other Java plugins. It thus allows developers to quickly iterate and debug their own plugins, without having to restart Stata for each new build.

{pstd}
{cmd:jcd} is a convenience method facilitating the use of DPL. It can be used just like {cmd:javacall} (except for the {it:method} part, which is obsolete). That is, invoking

	{com}. jcd your.company.your.Plugin varlist if in, args(your args){txt}

{pstd}
is equivalent to invoking

	{com}. javacall de.pbc.stata.PluginLoader start varlist if in , args(your.company.your.Plugin your args){txt}

{pstd}
Additionally, {cmd:jcd} maps post-estimation scalars and macros, which aren't accessible from within Java plugins, to general use scalars and macros, which are accessible from within Java plugins.
That is, all {cmd:e(X)} macros and scalars are accessible as {cmd:e_X}, e.g. {cmd:e(cmd)} as {cmd:e_cmd}; same for {cmd:r(X)}.

{pstd}
See below for how to set-up and use DPL.

{marker setup}{...}
{title:Setup}

{pstd}
In a first step, the {it:Dynamic Plugin Loader} (DPL) has to be configured. Think of it as setting up your IDE by configuring the CLASS_PATH to a 3rd party library. For this purpose, DPL expects config/dpl.xml in the current user.dir.
In the case of Stata, this is always the working directory ({cmd:pwd}) at the time the Java Virtual Machine (JVM) was started.

{pstd}
config/dpl.xml is expected to be a standard XML file as it is used by java.util.Properties. It should contain 2 properties:

{pstd}
CLASS_PATH: Semicolon (;) separated paths to all folders containing compiled Java .class files. The paths have to satisfy Paths.get(String, String...) naming conventions. The paths may be relative to user.dir.

{pstd}
JAR_PATH: Semicolon (;) separated paths to all folders containing JAR files. The paths have to satisfy Paths.get(String, String...) naming conventions. The paths may be relative to user.dir.

{pstd}
Conveniently, these paths can link directly to your IDE's workspace. For example, .../Eclipse/Your Project/bin for all compiled .class files in an Eclipse environment.

{pstd}
This is all the configuration you need to do. In order to use DPL, make sure the DPL JAR is on one of Stata's ADO paths.

{marker remarks}{...}
{title:Remarks}

{pstd}
See {browse "https://github.com/philippbc/java-stata-dpl":github.com/philippbc/java-stata-dpl}  for more documentation and help forums.

{pstd}
If your plugin class is on one of the ADO paths DPL will always use this version; it will not load your class from the resource paths specified in the configuration file.
That is, versions of classes on ADO paths supersede all versions on CLASS_PATHs and JAR_PATHs.

{pstd}
Any uncaught exception occurring during the execution of your plugin leads to DPL returning with error code 44. The exception and its stack trace are printed to the Stata console.
This also applies to all steps in preparation of your plugin's execution (e.g., reading config/dpl.xml).

{pstd}
You can run DPL with Java 8 (e.g., if your plugin needs Java 8).
To do so, {cmd:set java_vmpath "C:\Program Files\Java\jre1.8.0_XX\bin\server\jvm.dll"} will do the trick (replace XX with your current Java 8 version). For details, see {cmd:query java}.

{marker dependencies}{...}
{title:Dependencies}

{pstd}
Stata's SFI API for error logging ({browse "http://www.stata.com/java/api/index.html"})

{pstd}
Apache Commons IO 2.4 ({browse "https://commons.apache.org/proper/commons-io/"})

{pstd}
The simple java.util.Properties wrapper for the configuration file ({browse "https://github.com/philippbc/java-utils-properties"})

