{smcl}
{* July 2019}{...}
      _____    _______  _______     ______     _   _______
     / _   )  / _____/ / ______)  / ______)   / \ \  _____\
    / (_) )  / /____  /	/  ____  / / _____   / _ \ \ \_____
   /   _ )  / /____/ ( ( (___  )( ( (___  ) / /_\ \ \  ____\
  / / \ \  / /____   \  \___/ /  \ \___/ / /  _ _  \ \ \_____
 /_/   \_\/______/    \______/    \_____/ /_/     \_\ \______\ 
 
{hline}
Help for {hi:reggae_music} version 0.1
{hline}


{p}{cmdab:reggae_music} is the first music package for rasta Stata users. It randomly picks a reggae song to release any coding stress. Blessing!

{marker syntax}
{title:Syntax}

{p 2 4}{cmd:reggae_music} , [{it:options}]

{synoptset 20 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{it:    Display Options}
{synopt:{opt  br:owse}}Directly open the link in your web browser.{p_end}
{synopt:{opth num:ber(#)}}Choose number of songs to be selected; default is 1.{p_end}
{synopt:{opt  play:list}}Display full playlist instead of song(s).{p_end}
{synopt:{opt  platform(string)}}Specify music platform ({it:YouTube} or {it:Spotify}); default is {it:Youtube}.{p_end}
{break}
{it:    Music Options}
{synopt:{opt  artist(string)}}Specify artist name (see list below).{p_end}
{synopt:{opt  country(string)}}Specify artist country of origin (see list below).{p_end}
{synopt:{opt  sex(string)}}Specify artist sex ({it:male} or {it:female}).{p_end}
{synoptline}
{p 4 6 2}{p_end}

{marker overview}
{title:Overview}

{text}{p 2} After {cmdab:regress}, {cmdab:ivreg}, {cmdab:xtreg}, {cmdab:areg},
{cmdab:reghdfe}, and {cmdab:qreg}, it's time for you to try the
{cmdab:reggae_music} package. Fill in your Stata breaks, celebrate the smooth
run of your code, or just relax with some reggae music. You only need to type
{inp} {stata reggae_music} {text} on your command window, or insert the command
in the right place of your do-file, and the reggae package will select some
song for you. And now, enjoy the tune!

{marker example}
{title:Examples}

{phang}{text} 1. Generate a clickable link to a reggae song on your computer.{p_end}

{phang}{inp} {stata reggae_music}

{phang}{text} 2. Open the link created on your web browser, instead of displaying it on the result window.{p_end}

{phang}{inp} {stata reggae_music, browse}

{phang}{text} 3. Generate 5 clickable links with different songs.{p_end}

{phang} {inp} {stata reggae_music, number(5)}

{phang}{text} 4. Open the Youtube playlist link (instead of picking a song).{p_end}

{phang}{inp} {stata reggae_music, browse playlist}

{phang}{text} 5. Open link to Spotify.{p_end}

{phang}{inp} {stata reggae_music, browse playlist platform(Spotify)}

{phang}{text} 6. Randomly select a song by {it:Protoje}.{p_end}

{phang}{inp} {stata reggae_music, artist(Protoje)}

{phang}{text} 7. Randomly select a song by Jamaican artists.{p_end}

{phang}{inp} {stata reggae_music, country(Jamaica)}

{phang}{text} 8. Randomly select a song by a female reggae artist.{p_end}

{phang}{inp} {stata reggae_music, sex(Female)}{break}

{hline}

{marker artists}
{title:List of Artists and Countries}

{text}{p 2} The current version of the package contains songs from: 99 Posse,
Alborosie, Anthony B, Bob Marley & The Wailers, Busy Signal, Chronixx,
Collie Buddz, Damian Marley, Diplomatico e il Collettivo Ninco Nanco, Dub Inc,
Etana, Forelock, Gentleman, Hempress Sativa, Jah Cure, Jimmy Cliff, Junior
Kelly, Kabaka Pyramid, Kathryn Aria, Ky-Mani Marley, Koffee, Mama Marjas,
Mellow Mood, Morgan Heritage, Mortimer, Naâman, Nas, Protoje, Queen Ifrica,
Raging Fyah, Randy Valentine, RC, Richie Campbell, Richie Spice, Rita Marley,
Sara Lugo, SOJA, Stephen Marley, Sud Sound System, Tarrus Riley, Terroni Uniti,
and Tribal Seeds.{p_end}

{text}{p 2} Countries available in the playlists are Brazil, Canada, France,
Germany, Italy, Portugal, United States, and, indeed, di motherland island
Jamaica! :)

{marker acknowledgements}
{title:Acknowledgements}

{text}{p 2}We would like to acknowledge the constant guidance of Selassie I and
the spiritual support of Jah in developing this command.{p_end}

{text}{p 2}Also, Luiza Andrade, Camila Ayala, Julie Bousquet, and Jonas Guthoff
provided valuable comments and feedback.{p_end}

{marker author}
{title:Author}

{p 2}Matteo Ruzzante{p_end}
{p 2}ruzzante.matteo@gmail.com{p_end}

{marker contributing}
{title:Contributing}

{p 2}{bf: reggae_music} is open for development on {browse "https://github.com/MRuzzante/Jah-referencing/tree/reggae_music":GitHub}.
Submit bugs and feature requests {browse "https://github.com/MRuzzante/Jah-referencing/issues":here}.
The full playlist is available here ({browse "https://www.youtube.com/playlist?list=PLC-aST3UH2m5tfv3RALnUA-z753ZDYSm7&disable_polymer=true":Youtube})
and here ({browse "https://open.spotify.com/user/ruzzante.matteo/playlist/100XebrUHtUthBEoaKo0Ge?si=d592jMbFRl2EDf9w0QlPLA":Spotify}).
Feel free to suggest any song, artist, or country, which is missing in our
current selection, and we will try to expand the choices for you.{p_end}

