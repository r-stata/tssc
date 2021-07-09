{smcl}
{* *! version 0.9  24jul2018}{...}
{viewerjumpto "Syntax" "cowsay##syntax"}{...}
{viewerjumpto "Description" "cowsay##description"}{...}
{viewerjumpto "Options" "cowsay##options"}{...}
{viewerjumpto "Examples" "cowsay##examples"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:cowsay} {hline 2}}Cowsay functionality for Stata{p_end}
{p2colreset}{...}



{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:cowsay}
string or expression in quotations
[{cmd:}{it:options}]


{synoptset 30 tabbed}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt animal(type)}}{it:type} may be {bf:cow} (default) or one of 40 other animals (see below).{p_end}

{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{opt cowsay} implements essential cowsay functionality in Stata.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth animal(type)} Choose an animal. The default is animal(cow). You can also choose:

{p 8 16 2}pig          {p_end}
{p 8 16 2}benny        {p_end}
{p 8 16 2}clippy       {p_end}
{p 8 16 2}hypnotoad    {p_end}
{p 8 16 2}egret        {p_end}
{p 8 16 2}chicken      {p_end}
{p 8 16 2}poop         {p_end}
{p 8 16 2}bigcat       {p_end}
{p 8 16 2}ant          {p_end}
{p 8 16 2}pumpkin      {p_end}
{p 8 16 2}ghost        {p_end}
{p 8 16 2}spider       {p_end}
{p 8 16 2}rabbit       {p_end}
{p 8 16 2}smallpig     {p_end}
{p 8 16 2}snowman      {p_end}
{p 8 16 2}frog         {p_end}
{p 8 16 2}fish         {p_end}
{p 8 16 2}signbunny    {p_end}
{p 8 16 2}facecat      {p_end}
{p 8 16 2}behindcat    {p_end}
{p 8 16 2}stretchycat  {p_end}
{p 8 16 2}anxiouscat   {p_end}
{p 8 16 2}longtailcat  {p_end}
{p 8 16 2}cat          {p_end}
{p 8 16 2}trilobite    {p_end}
{p 8 16 2}shark        {p_end}
{p 8 16 2}buffalo      {p_end}
{p 8 16 2}grumpycat    {p_end}
{p 8 16 2}smallcat     {p_end}
{p 8 16 2}yoda         {p_end}
{p 8 16 2}mushroom     {p_end}
{p 8 16 2}endlesshorse {p_end}
{p 8 16 2}bat          {p_end}
{p 8 16 2}bat2         {p_end}
{p 8 16 2}turkey       {p_end}
{p 8 16 2}monkey       {p_end}
{p 8 16 2}daemon       {p_end}
{p 8 16 2}duckling     {p_end}
{p 8 16 2}duck         {p_end}
{p 8 16 2}owl          {p_end}

{marker examples}{...}
{title:Examples}

{pstd}See the Github page.{p_end}

