{smcl}
{* *! version 0.0.3  3mar2017}{...}
{viewerjumpto "Syntax" "ngram##syntax"}{...}
{viewerjumpto "Description" "ngram##description"}{...}
{viewerjumpto "Options" "ngram##options"}{...}
{* {viewerjumpto "Stored results" "ngram##results"} }{...}
{viewerjumpto "Examples" "ngram##examples"}{...}
{viewerjumpto "Remarks" "ngram##remarks"}{...}
{viewerjumpto "Copyright" "ngram##copyright"}{...}
{viewerjumpto "Authors" "ngram##authors"}{...}
{viewerjumpto "References" "ngram##references"}{...}
{...}{* NB: these hide the newlines }
{...}
{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:ngram} {hline 2}}n-gram feature extractor{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:ngram} {varname} {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opth deg:ree(ngram##degree:#)}}The degree of n-grams to extract. Default: {cmd:degree(1)}.{p_end}
{synopt :{opth thresh:old(ngram##threshold:#)}}The minimum number of occurrences required across all observations to count a particular n-gram. Default: {cmd:threshold(5)}.{p_end}
{synopt :{opth p:refix(ngram##prefix:prefix)}}A string to prepend to output n-gram columns. Default: {cmd:prefix(t_)}.{p_end}
{synopt :{opt bin:arize}}Instead of counting occurrences, only report whether or not each n-gram appeared in the text, 1 for appeared and 0 for did not appear. Default: disabled.{p_end}

{synopt :{opth lo:cale(ngram##locale:locale)}}The {help ngram##locale:locale} of the text.
Default: read from c(locale_functions). Avoid direct use: this only exists for pre-Stata 14 compatibility.

{synopt :{opth stop:words(ngram##stopwords:...)}}List of words to filter out before counting n-grams. Default: loaded from a list determined by {opt locale}, if found, else empty.{p_end}

{synopt :{opt stem:mer}}Whether to normalize words with the stemmer for {opt locale}.
Stemmers are available for da, de, en, es, fr, it, nl, no, pt, ro, ru, sv. Default: disabled.{p_end}
{synopt :{opt l:ower}}Whether to normalize words by lower-casing them.
Default: enabled. Disable with {opt nolower}.{p_end}

{synopt :{opt punct:uation}}Whether to consider punctuation (as defined by {opt locale}) as delimiters. Default: disabled.{p_end}

{synopt :{opt n_token: }}Whether to report the number of tokens in each text
in a column named {opt n_token}. Default: enabled. Disable with {opt non_token}.{p_end}

{synoptline}
{pstd}{varname} must be a string variable.

{marker description}{...}
{title:Description}

{pstd}
{cmd:ngram} extracts n-gram counts, for text-mining applications, from string variable {varname}.

{pstd}
An n-gram is an {opt n}-long sequence of words.
For example, "sheep" is a unigram (1-gram), "black sheep" is a bigram (2-gram),
and "the black sheep is happy" is a 5-gram, although by default {cmd:ngram}'s {help ngram##stopwords:stopwords}
will filter this to the trigram "black sheep happy".
What counts as a word to {cmd:ngram} is defined by the set of active delimiters.
To this command, a word is a sequence of characters separated by whitespace and/or punctuation; some applications 
--- for example DNA mining and password generation --- build n-grams from other kinds of tokens, 
like single characters or single syllables,
but this is not directly possible with this command.

{pstd}
n-gram counts can be used to produce markov models which emulate speech,
such as those used in autocorrect software,
 can be used as features in machine learning / data mining algorithms,
such as sentiment analysis.
For a survey of the theory see {help ngram##patterntheory:Desolneux (2010)}, Chapter 1.
For a practical introduction to text-mining,
though unfortunately grounded in a non-Stata platform,
see {help ngram##pynltk:Bird (2009)}.

{pstd}
{cmd:ngram} finds all n-grams in each given piece of text and counts them.
Each distinct n-gram is recorded in a new column, named after it; for example,
"black sheep happy" will be counted in a column named "t_black_sheep_happy"
(though the "t_" part can be {help ngram##prefix:changed} if needed).

{pstd}
As a special feature, {cmd:ngram} adds special tokens from the ASCII table
STX and ETX to mark the start and end of the text.
These are reported as part of multigrams, so "we looked in the empty box."
will produce, in addition to bigrams "we looked" and "empty box",
the trigrams "STX we looked" and "empty box ETX". {p_end}

{title:Remarks related to LINUX}
{pstd}
In Linux, when setting a locale ({help set locale_functions}) other than your default locale 
you may get an error asserting that the locale functions is not installed. 
This is an LINUX problem. For the locale "de", for example, this can be remedied as follows:

{phang2}{cmd:sudo locale-gen "de_DE.UTF-8" }{p_end}

{phang2}{cmd:sudo dpkg-reconfigure locales}{p_end}

{marker options}{...}
{title:Options}

{phang}
{marker degree}{...}
{opt deg:ree} determines the size of n-grams to extract. 
All n-grams from degree 1 (unigrams) through {opt degree} ({opt degree}-grams) are extracted.{p_end}

{phang}
{marker threshold}{...}
{opt thresh:old} specifies the rarity threshold required to report an n-grams.
An n-gram must appear in {opt threshold} distinct observations to become a part of the output table.{p_end}

{pmore2}For example, suppose {opt threshold(10)}, and a single respondent is very enthusiastic
about their "sheep dog", say, mentioning it sixteen times, and on the other hand
sixteen different texts mention "potato pie" once or twice; "sheep dog" would
count as rare and be ignored and "potato pie" would be counted as common and included.{p_end}
{pmore}This option drastically affects the size of the output, making the usually sparse dataset denser.{p_end}

{phang}
{marker prefix}{...}
{opt p:refix} gives a string which is prepended to n-grams before they are made into columns.
For example, "sheep dog" by default becomes "t_sheep_dog" and the processed text columns can referenced by "t_*".
This option lets you change the default prefix in the rare cases that need to avoid name collisions.{p_end}

{phang}
{marker binarize}{...}
{opt bin:arize} instructs the algorithm to only report whether or not each n-gram
appeared in each text, instead of counting occurrences.
1 means appeared and 0 means did not.
This loses fidelity, but makes the dataset simpler for data-mining algorithms
like {help svm} to handle.{p_end}

{phang}
{marker locale}{...}
{opt lo:cale} gives the {help unicode_locale:ICU} locale of the text. 
This determines the default stopwords, default stemming algorithm, and the way characters are tokenized.
Stata gained internal Unicode support via libicu in Stata 14,
and in Stata 14 and up you should specify the locale near the beginning of your script
with {help set locale_functions}.
{ul:This option only exists for pre-Stata 14 compatibility.}{p_end}

{pmore2}However, in order to make use of {cmd:ngram} with foreign languages ---
that is, any language which your operating system is not set to ---
you need to be aware of how to write a locale.{p_end}

{pmore2}Locale strings generally consist of an ISO language code and an optional ISO region code,
given as "lang" or "lang_Region". For example, "nl" is Dutch and "zh_TW" is Taiwanese Chinese.{p_end}
{pmore}On Stata 14 and up you can see the full list with {cmd:unicode locale list}.{p_end}

{phang}
{marker stopwords}{...}
{opt stop:words} is a whitespace-separated list of words to filter out before counting n-grams.
The intended purpose of stopwords is remove common words like prepositions and pronouns
which do not carry global meaning and just distract from the more meaningful nouns and verbs.{p_end}

{pmore} If not specified, the default stopwords are loaded from a file of
whitespace-separated words on the {help adopath}---in particular, it can be in the working directory---
named "stopwords_la.txt" where "la" is the 2-letter language code of the {help ngram##locale:current locale}. 
If the current language has no default file, a warning will be printed and no stopwords will be used, but the algorithm will still run.
Specifying {opt stopwords()} is equivalent to not specifying anything.{p_end}

{pmore}If {opt stopwords(.)} is specified, no stopwords will be used (this is different than {opt stopwords()}).{p_end}

{pmore} It is possible to add additional stopwords to the default file by specifying  + as the first word of {opt stopwords}. 
For example, {opt stopwords("+ jane austen")} appends these two additional words to the stopword file.{p_end}

{pmore}Stopwords are always case-insensitive.{p_end}

{pmore} The default stopword files that come with the distribution can be overridden by creating a different version of that file in the working directory. 
 For example, the stopword files for English, Dutch and German are called 
 "stopwords_en.txt", "stopwords_nl.txt" and "stopwords_de.txt", respectively.  If placed in the working directory, the default 
 stopword files supplied will be ignored.
{p_end}

{phang}
{marker stemmer}{...}
{opt stem:mer} instructs the tokenizer to attempt to construct the root of the word (the "stem").
The stemmer attempts to remove the prefixes, suffixes, and other transformations
that decline a root word into adjective, verb, or noun forms.{p_end}

{pmore} Which stemmer to use is determined by the language code in {opt locale}.{p_end}

{pmore}Stemming for the following locales are supported:
{opt da} (Danish), {opt de} (German), {opt en} (English), {opt es} (Spanish), {opt fr} (French), 
{opt it} (Italian), {opt nl} (Dutch), {opt no} (Norwegian), {opt pt} (Portuguese), {opt ro} (Romanian), 
{opt ru} (Russian), and {opt sv} (Swedish).
There is no user-level way to add more, unfortunately.
If your dataset is not in one of these languages, you cannot use this option.{p_end}

{phang}
{marker lower}{...}
{opt l:ower} instructs the tokenizer to normalize words by lower-casing them.
This has no effect for languages without the upper/lower case distinction.{p_end}

{phang}
{marker punctuation}{...}
{opt punct:uation} and instructs the tokenizer to include punctuation, as defined by {opt locale}, as tokens.

{phang}
{marker n_token}{...}
{opt n_token: } instructs {cmd:ngram} to report the number of tokens in each text in a column named {opt n_token}.
This is the pre-normalizing pre-stopwords count of tokens, which is also the number of unigrams.{p_end}
{pmore}Since this always produces a column named {opt n_token}, you must rename any pre-existing column with that name first, or disable this with {opt non_token}.{p_end}
{pmore2}
{* {marker results}{...} }{...}
{* {title:Stored results} }{...}
{* Currently no stored results, so nothing to document here }{...}


{marker results}{...}
{title:Stored results}
{synoptset 20 tabbed}{...}
{synopt:{cmd:r(words)}}String containing all ngram variables created{p_end}


{marker examples}{...}
{title:Examples}

INCLUDE help ngram_examples

{marker remarks}{...}
{title:Remarks}

{pstd}
{bf:Control characters}: control characters like ESC, ACK, Backspace are always considered delimiters by the tokenizer.
This avoids conflict with the STX/ETX feature.
If you do need to tokenize these characters, preprocess your text
replacing control characters by unique tokens of your own choosing.{p_end}

{marker copyright}{...}
{title:Copyright}

{pstd}
Copyright 2014-2017 Matthias Schonlau

{pstd}
This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

{pstd}
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

{pstd}
   For the GNU General Public License see <http://www.gnu.org/licenses/>.



{marker authors}{...}
{title:Authors}
{pmore} Matthias Schonlau <schonlau@uwaterloo.ca>{p_end}
{pmore} Nick Guenther <nguenthe@uwaterloo.ca>{p_end}
{pmore} Joey Zhao <y266zhao@uwaterloo.ca>{p_end}
{pmore} Ilia Sucholutsky <isucholu@uwaterloo.ca>{p_end}


{marker references}{...}
{title:References}
{...}

{marker patterntheory}{...}
{phang}
Desolneux, Agnès. {it:Pattern Theory}.
CRC Press, 2010.
{browse "http://dx.doi.org/10.1201/b10620"}
{p_end}

{phang}
{marker pynltk}{...}
Bird, Steven, Ewan Klein, and Edward Loper.
{it:Natural Language Processing with Python}.
O'Reilly, 2009.
{browse "http://www.nltk.org/book/"}
{p_end}
