program define cowsay

version 12.1

syntax anything(everything), [animal(string asis)]

* gettoken arg1 : anything
local arg1 `anything'

local arg1_len = strlen(`"`arg1'"')
local arg1_len = `arg1_len'+2

* Error handling: if animal not specified, set it to cow
if ( `"`animal'"' == "" ) local animal cow

local animals cow          ///
              pig          ///
              benny        ///
              clippy       ///
              hypnotoad    ///
              egret        ///
              chicken      ///
              poop         ///
              bigcat       ///
              ant          ///
              pumpkin      ///
              ghost        ///
              spider       ///
              rabbit       ///
              smallpig     ///
              snowman      ///
              frog         ///
              fish         ///
              signbunny    ///
              facecat      ///
              behindcat    ///
              stretchycat  ///
              anxiouscat   ///
              longtailcat  ///
              cat          ///
              trilobite    ///
              shark        ///
              buffalo      ///
              grumpycat    ///
              smallcat     ///
              yoda         ///
              mushroom     ///
              endlesshorse ///
              bat          ///
              bat2         ///
              turkey       ///
              monkey       ///
              daemon       ///
              duckling     ///
              duck         ///
              owl

* Error handling: if animal() specified, make sure that it is a valid choice
if ( ~`:list animal in animals' ) {
    di as error `"CRITICAL COWSAY ERROR: animal chosen (`animal') is not in the menagerie."'
    di as error `"Currently supported animals:"'
    foreach animal of local animals {
        di as error `"    `animal'"'
    }
    di as error `"Defaulting to cow."'
    local animal cow
}

if ( `"`animal'"' == "hypnotoad" ) {
    local arg1     = "All Glory to the HYPNO TOAD!"
    local arg1_len = strlen(`"`arg1'"')
    local arg1_len = `arg1_len'+2
}

* Call animal program
di as txt `"  {hline `arg1_len'}"'
di as txt `" < `arg1' >"'
di as txt `"  {hline `arg1_len'}"'
cowsay_`animal'

end

program cowsay_cow
    di "         \   ^__^"
    di "          \  (oo)\_______"
    di "             (__)\       )\/\"
    di "                 ||----w |"
    di "                 ||     ||"
end

program cowsay_pig
    di "    \                                    _"
    di "     \          _   _    __....._     _ '-)-'"
    di "      \        |_\_/ | .'        '.  '-)-'"
    di "       \      /      \/            \-'`"
    di "        \   _| 6 6    `             |"
    di "         \ /..\                     |"
    di "           \__/_,          |       /"
    di "             '--.___   \    \     \"
    di "                 / /  /`----`;-.   >"
    di "                / /  /       / /  /"
    di "               /_/__/       /_/__/"
end

program cowsay_benny
    di "    \"
    di "     \              .-'||'-."
    di "      \           .'   ||   '."
    di "       \         /   __||__   \"
    di "                 | / -    - \ |"
    di "                 | | 6    6 | |"
    di "                 \/\____7___/\/"
    di "         .--------:\:I:II:I:/;--------."
    di "        /          \ :I::I: /          \"
    di "       |            '------'            |"
    di "       |             \____/             |"
    di "       |      ,    __     ___    ,      |"
    di "       |======|   /  |   / _ \   |======|"
    di "       |======|   ^| |  | | | |  |======|"
    di "       |~~~~~|     | |  | |_| |   |~~~~~|"
    di "       |     |\   [___]  \___/   /|     |"
    di "        \    \|                  |/    /"
    di "         \    \  _ _.-=''=-._ _  /    /'"
    di "          '\   ' _)\\-++++-//(_ '   /'"
    di "            ;   (__||      ||__)   ;"
    di "             ;   ___\      /___   ;"
    di "              '. ---/-=..=-\--- .'"
    di "                `''          '' "
end

* ---------------------------------------------------------------------
* Animals from https://github.com/sckott/cowsay/blob/master/R/animals.r

program cowsay_clippy
    di "    \   "
    di "     \"
    di "   __"
    di "   / \"
    di "   | |"
    di "   @ @"
    di "  || ||"
    di "  || ||"
    di "  |\_/|"
    di "  \___/ GB"
end

* http://chris.com/ascii/index.php?art=television/futurama
program cowsay_hypnotoad
    local tick = "`"
    di `"    \          ,'\`\`.._   ,'\`\`."'
    di `"     \        :,--._:)\,:,._,.:"'
    di `"      \       :\`--,''   :\`...';\"'
    di `"               \`,'       \`---'  \`."'
    di `"               /                 :"'
    di `"              /                   \"'
    di `"            ,'                     :\.___,-."'
    di `"           \`...,---'\`\`\`\`\`\`-..._    |:       \"'
    di `"             (                 )   ;:    )   \  _,-."'
    di `"              \`.              (   //          \`'    \"'
    di `"               :               \`.//  )      )     , ;"'
    di `"             ,-|\`.            _,'/       )    ) ,' ,'"'
    di `"            (  :\`.\`-..____..=:.-':     .     _,' ,'"'
    di `"             \`,'\ \`\`--....-)='    \`._,  \  ,') _ '\`\`._"'
    di `"          _.-/ _ \`.       (_)      /     )' ; / \ \\`macval(tick)'-.'"'
    di `"         \`--(   \`-:\`.     \`' ___..'  _,-'   |/   \`.)"'
    di `"             \`-. \`.\`.\`\`-----\`\`--,  .'"'
    di `"               |/\`.\\`macval(tick)''        ,','); SSt"'
    di `"                   \`         (/  (/"'
end

* https://twitter.com/BoingBoing/status/465170473194512384
program cowsay_shortcat
    di `"    \   "'
    di `"     \"'
    di `"    .ﾊ,,ﾊ"'
    di `"    ( ﾟωﾟ)"'
    di `"    |つ  つ"'
    di `"    U " U"'
    di `"        [BoingBoing]"'
end

* egret by Joan Stark from http://www.chris.com/ascii/joan/www.geocities.com/SoHo/7373/birds.html#egret 
program cowsay_egret
    local tick = "`"
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"       \   _,"'
    di `"      -==<' \` "'
    di `"          ) /"'
    di `"         / (_."'
    di `"        |  ,-,\\`macval(tick)'\"'
    di `"         \\   \ \"'
    di `"          \`\,  \ \"'
    di `"           ||\  \\`macval(tick)'|,"'
    di `" jgs      _|| \`=\`-'"'
    di `"         ~~\`~\`"'
end

program cowsay_chicken
    di "    \   "
    di "     \"
    di "         _"
    di "       _/ }"
    di "      \`>' \"
    di "      \`|   \"
    di "       |   /'-.     .-."
    di "        \'     ';\`--' .'"
    di "         \'.    \`'-./"
    di "          '.\`-..-;\`"
    di "            \`;-..'"
    di "            _| _|"
    di "            /\` /\` "
end

program cowsay_poop
    di `"    \   "'
    di `"     \"'
    di `"     (   )"'
    di `"  (   ) ("'
    di `"   ) _   )"'
    di `"    ( \_"'
    di `"  _(_\ \)__"'
    di `" (____\ ___))"'
end

program cowsay_bigcat
    local tick = "`"
    di `"    \   "'
    di `"     \"'
    di `"                \\`macval(tick)'*-."'
    di `"                 )  _\`-."'
    di `"                .  : \`. ."'
    di `"                : _   '  \"'
    di `"                ; *\` _.   \`*-._"'
    di `"                \`-.-'          \`-."'
    di `"                  ;       \`       \`."'
    di `"                  :.       .       \"'
    di `"                  .\  .   :   .-'   ."'
    di `"                  '  \`+.;  ;  '      :"'
    di `"                  :  '  |    ;       ;-."'
    di `"                  ; '   : :\`-:     _.\`* ;"'
    di `"               .*' /  .*' ; .*\`- +'  \`*'"'
    di `"     [bug]     \`*-*   \`*-*  \`*-*'"'
end

program cowsay_ant
    di `"    \   "'
    di `"     \"'
    di `"       '\__"'
    di `"      (o )     ___"'
    di `"      <>(_)(_)(___)"'
    di `"        < < > >"'
    di `"        ' ' \` \`  "'
end

program cowsay_pumpkin
    di `"    \   "'
    di `"     \"'
    di `"                  ___"'
    di `"               ___)__|_"'
    di `"          .-*'          '*-,"'
    di `"         /      /|   |\     \"'
    di `"        ;      /_|   |_\     ;"'
    di `"        ;   |\           /|  ;"'
    di `"        ;   | ''--...--'' |  ;"'
    di `"         \  ''---.....--''  /"'
    di `"          ''*-.,_______,.-*'  "'
end

program cowsay_ghost
    di `"    \   "'
    di `"     \"'
    di `"     .-."'
    di `"    (o o)"'
    di `"    | O \"'
    di `"     \   \"'
    di `"      \`~~~'"'
end

program cowsay_spider
    di `"    \   "'
    di `"     \"'
    di `"              |"'
    di `"              |"'
    di `"              |"'
    di `"             __"'
    di `"          | /  \ |"'
    di `"         \_\\  //_/"'
    di `"          .'/()\'."'
    di `"           \\  //  "'
end

program cowsay_rabbit
    di `"    \   "'
    di `"     \"'
    di `"      ( )_( )"'
    di `"      (='.'=)"'
    di `"      (^)_(^) "'
end

program cowsay_smallpig
    di `"    \   "'
    di `"     \"'
    di `"       _//| .-~~~-."'
    di `"     _/oo  }       }-@"'
    di `"    ('')_  }       |"'
    di `"     \`--'| { }--{  }"'
    di `"          //_/  /_/ "'
end

program cowsay_snowman
    di `"    \   "'
    di `"     \"'
    di `"     _[_]_"'
    di `"      (")"'
    di `"  >--( : )--<"'
    di `"    (__:__) "'
end

program cowsay_frog
    di `"    \   "'
    di `"     \"'
    di `"        (.)_(.)"'
    di `"     _ (   _   ) _"'
    di `"    / \/\`-----'\/ \"'
    di `"  __\ ( (     ) ) /__"'
    di `"  )   /\ \._./ /\   ("'
    di `"   )_/ /|\   /|\ \_(  [nosig]"'
end

program cowsay_fish
    di `"    \   "'
    di `"     \"'
    di `"  ><((((º>  ><((((º>  ><((((º>  ><((((º>  ><((((º>"'
    di `"      Kiyoko Gotanda"'
end

program cowsay_signbunny
    di `"       ||"'
    di `"(\__/) ||"'
    di `"(•ㅅ•) ||"'
    di `"/   づ"'
end

program cowsay_facecat
    di `"    \"'
    di `"      \"'
    di `"         /\ /\"'
    di `"         (O o)"'
    di `"        =(:^:)="'
    di `"           U  "'
end

program cowsay_behindcat
    di `"      \"'
    di `"        \"'
    di `"          \"'
    di `"            |\___/|"'
    di `"            )     ("'
    di `"           =\     /="'
    di `"             )===("'
    di `"            /     \"'
    di `"            |     |"'
    di `"           /       \"'
    di `"           \       /"'
    di `"      jgs   \__  _/"'
    di `"              ( ("'
    di `"               ) )"'
    di `"              (_("'
end

program cowsay_stretchycat
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"                        ,/|         _.--‛‛^\`\`-...___.._.,;"'
    di `"                      /, \‛.     _-‛          ,--,,,--‛‛‛"'
    di `"                     {  \    \`_-‛‛       ‛    /}‛"'
    di `"Jill                    \`;;‛             ;   ; ;"'
    di `"                  ._.--‛‛     ._,,, _..‛  .;.‛"'
    di `"                  (,_....----‛‛‛     (,..--‛‛"'
end

program cowsay_anxiouscat
    local tick  = "`"
    local quote = `"""'
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"        /\_/\         _"'
    di `"       /\`\`   \       / )"'
    di `"       |n n   |__   ( ("'
    di `"      =(Y =.‛\`   \`\  \ \"'
    di `"      {\``quote'\`        \  ) )`macval(\`)' "'
    di `"      {       /    |/ /"'
    di `"       \\   ,(     / /"'
    di `"        ) ) /-‛\  ,_.‛"'
    di `"  jgs  (,(,/ ((,,/"'
end

program cowsay_longtailcat
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"     /\-/\"'
    di `"    /a a  \                                 _"'
    di `"   =\ Y  =/-~~~~~~-,_______________________/ )"'
    di `"     ‛^--‛          ________________________/"'
    di `"       \           /"'
    di `"       ||  |---‛\  \"'
    di `"  jgs  (_(__|   ((__|"'
end

program cowsay_cat
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"            |\___/|"'
    di `"          ==) ^Y^ (=="'
    di `"            \  ^  /"'
    di `"             )=*=("'
    di `"            /     \"'
    di `"            |     |"'
    di `"           /| | | |\"'
    di `"           \| | |_|/\"'
    di `"      jgs  //_// ___/"'
    di `"               \_)"'
end

program cowsay_trilobite
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"          _____"'
    di `"       .'\` ,-. \`'."'
    di `"      /   ([ ])   \"'
    di `"     /.-""\`(\`)\`""-.\\` "'
    di `"      <'\`\`\`(.)\`\`\`'>"'
    di `"      <'\`\`\`(.)\`\`\`'>"'
    di `"       <'\`\`(.)\`\`'>"'
    di `"   sk   <\`\`\_/\`\`>"'
    di `"         \`'---'\` "'
end

program cowsay_shark
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"              /""-._"'
    di `"              .       '-,"'
    di `"               :          '',"'
    di `"                ;      *     '."'
    di `"                 ' *         () '."'
    di `"                   \               \"'
    di `"                    \      _.---.._ '."'
    di `"                    :  .' _.--''-''  \ ,'"'
    di `"        .._           '/.'             . ;"'
    di `"        ; \`-.          ,                \'"'
    di `"         ;   \`,         ;              ._\"'
    di `"          ;    \     _,-'                ''--._"'
    di `"          :    \_,-'                          '-._"'
    di `"          \ ,-'                       .          '-._"'
    di `"          .'         __.-'';            \...,__       '."'
    di `"        .'      _,-'        \              \   ''--.,__  '\"'
    di `"        /    _,--' ;         \              ;           \^.}"'
    di `"        ;_,-' )     \  )\      )            ;"'
    di `"             /       \/  \_.,-'             ;"'
    di `"            /                              ;"'
    di `"         ,-'  _,-'''-.    ,-.,            ;      PFA"'
    di `"      ,-' _.-'        \  /    |/'-._...--'"'
    di `"     :--\`\`             )/"'
    di `"  '"'
end

program cowsay_buffalo
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"                   _.-\`\`\`\`'-,_"'
    di `"         _,.,_ ,-'\`           \`'-.,_"'
    di `"       /)     (                   '\`\`-."'
    di `"      ((      ) )                      \`\"'
    di `"        \)    (_/                        )\"'
    di `"        |       /)           '    ,'    / \"'
    di `"        \`\    ^'            '     (    /  ))"'
    di `"          |      _/\ ,     /    ,,\`\   (  "\` "'
    di `"          \Y,   |   \  \  | \`\`\`\`| / \_ \"'
    di `"            \`)_/      \  \  )    ( >  ( >"'
    di `"                       \( \(     |/   |/"'
    di `"          mic & dwb  /_(/_(    /_(  /_("'
end

program cowsay_grumpycat
    di `"    \"'
    di `"      \"'
    di `"        \"'
    di `"      ﾊ _ ﾊ"'
    di `"      ಠ X ಠ"'
end

program cowsay_smallcat
    di `"    \"'
    di `"     \"'
    di `"      \"'
    di `"         /\_/\"'
    di `"        ( o.o )"'
    di `"         > ^ <  "'
end

program cowsay_yoda
    local tick  = "`"
    local quote = `"""'
    di `"    \   "'
    di `"     \"'
    di `"                   ____"'
    di `"                _.' :  \`._"'
    di `"            .-.'\`.  ;   .'\`.-."'
    di `"   __      / : ___\ ;  /___ ; \      __"'
    di `"  ,'_ ""--.:__;".-.";: :".-.":__;.--"" _\`,"'
    di `"  :' \`.t""--.. '<@.\`;_  ',@>\` ..--""j.' \`;"'
    di `"       \`:-.._J '-.-'L__ \`-- ' L_..-;'"'
    di `"          `quote'-.__ ;  .-`quote'  `quote'-.  : __.-`quote'"'
    di `"             L ' /.------.\ ' J"'
    di `"             `quote'-.   `quote'--`quote'   .-`quote'"'
    di `"             __.l`quote'-:_JL_;-`quote';.__"'
    di `"         .-j/'.;  ;`quote'`quote'`quote'`quote'  / .'\"-."'
    di `"         .' /:\`. `quote'-.:     .-`quote' .';  \`."'
    di `"      .-`quote'  / ;  `quote'-. `quote'-..-`quote' .-`quote'  :    `quote'-."'
    di `"  .+`quote'-.  : :      `quote'-.__.-`quote'      ;-._   \"'
    di `"  ; \  \`.; ;                    : : `quote'+. ;"'
    di `"  :  ;   ; ;                    : ;  : \:"'
    di `"  ;  :   ; :                    ;:   ;  :"'
    di `"  : \  ;  :  ;                  : ;  /  ::"'
    di `"  ;  ; :   ; :                  ;   :   ;:"'
    di `"  :  :  ;  :  ;                : :  ;  : ;"'
    di `"  ;\    :   ; :                ; ;     ; ;"'
    di `"  : \`.`quote'-;   :  ;              :  ;    /  ;"'
    di `" ;    -:   ; :              ;  : .-`quote'   :"'
    di `"  :\     \  :  ;            : \.-`quote'      :"'
    di `"  ;\`.    \  ; :            ;.'_..--  / ;"'
    di `"  :  `quote'-.  `quote'-:  ;          :/.`quote'      .'  :"'
    di `"   \         \ :          ;/  __        :"'
    di `"    \       .-\`.\        /t-`quote'`quote'  `quote':-+.   :"'
    di `"     \`.  .-`quote'    \`l    __/ /\`. :  ; ; \  ;"'
    di `"       \   .-`quote' .-`quote'-.-`quote'  .' .'j \  /   ;/"'
    di `"        \ / .-`quote'   /.     .'.' ;_:'    ;"'
    di `"  :-`quote'`quote'-.\`./-.'     /    \`.___.'"'
    di `"               \ \`t  ._  /  bug"'
    di `"                "-.t-._:'"'
end

program cowsay_mushroom
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"                ________"'
    di `"           __--´      ° \`--__"'
    di `"       __-´     °      °     \`-__"'
    di `"     (´    °    °          °     \`)"'
    di `"     (° °|    |°         ° |    | )"'
    di `"      \`'''''''''\`|'''''|´''''''''´"'
    di `"                 |     |"'
    di `"                 |:::::|"'
    di `"               /:|:::::|:\"'
    di `"              /::|:::::|::\"'
    di `"                 |     |"'
    di `"                 |^   ^|"'
    di `"                 |  _  | [FK]"'
    di `"                 |_____|"'
end

program cowsay_endlesshorse
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"       ,"'
    di `"    _,,)\.~,,._"'
    di `"     (()\`  \`\`)\))),,_"'
    di `"      |     \ ''((\)))),,_          ____"'
    di `"      |6\`   |   ''((\())) "-.____.-"    \`-.-,"'
    di `"      |    .'\    ''))))'                  \)))"'
    di `"      |   |   \`.     ''                     (((("'
    di `"      \, _)     \/                          |))))"'
    di `"       \`'        |                          ((((("'
    di `"                 \                  |       ))))))"'
    di `"                  \`|    |           ,\     /(((((("'
    di `"                   |   / \`-.______.<  \   |  )))))"'
    di `"                   |   |  /         \`. \  \  (((("'
    di `"                   |  / \ |           \`.\  | ((("'
    di `"                   \  | | |             )| |  ))"'
    di `"                    | | | |             || |  '   [endless.horse]"'
    di `"                    | | | |             || |"'
end

program cowsay_bat
    di `"              \   "'
    di `"               \  "'
    di `"                \"'
    di `"        __.--'\     \.__./     /'--.__"'
    di `"    _.-'       '.__.'    '.__.'       '-._"'
    di `"  .'                                      '."'
    di `" /                                          \"'
    di `"|                                            |"'
    di `"|                                            |"'
    di `" \         .---.              .---.         /"'
    di `"  '._    .'     '.''.    .''.'     '.    _.'"'
    di `"     '-./            \  /           \.-'"'
    di `"                      ''mrf"'
end

program cowsay_bat2
    di `"              \   "'
    di `"               \  "'
    di `"                \"'
    di `"_____________________                              _____________________"'
    di `"\`-._                 \           |\__/|           /                 _.-'"'
    di `"    \                 \          |    |          /                 /"'
    di `"     \                 \`-_______/      \_______-'                 /"'
    di `"      |                                                          |"'
    di `"      |                                                          |"'
    di `"      |                                                          |"'
    di `"      /                                                          \"'
    di `"     /_____________                                  _____________\"'
    di `"                   \`----._                    _.----'"'
    di `"                          \`--.            .--'"'
    di `"                              \`-.      .-'"'
    di `"                                 \    / :F_P:"'
    di `"                                  \  /"'
    di `"                                   \/"'
end

program cowsay_turkey
    di `"              \   "'
    di `"               \  "'
    di `"                \"'
    di `"               .--."'
    di `"              /} p \             /}"'
    di `"             \`~)-) /           /\` }"'
    di `"              ( / /          /\`}.' }"'
    di `"               / / .-'""-.  / ' }-'}"'
    di `"              / (.'       \/ '.'}_.}"'
    di `"             |            \`}   .}._}"'
    di `"             |     .-=-';   } ' }_.}"'
    di `"             \    \`.-=-;'  } '.}.-}"'
    di `"              '.   -=-'    ;,}._.}"'
    di `"                \`-,_  __.'\` '-._}"'
    di `"              jgs   \`|||"'
    di `"                   .=='=,"'
end

program cowsay_monkey
    local tick  = "`"
    local quote = `"""'
    di `"              \   "'
    di `"               \  "'
    di `"                \"'
    di `"                  .="=."'
    di `"                _/.-.-.\_     _"'
    di `"               ( ( o o ) )    ))"'
    di `"                |/  `quote'  \|    //"'
    di `"                 \'---'/    //"'
    di `"           jgs   /\``quote'`quote'`quote'\`\\  ((`macval(\`)' "'
    di `"                / /_,_\ \\  \\"'
    di `"                \_\_'__/  \  ))"'
    di `"                /\`  /\`~\   |//"'
    di `"               /   /    \  /"'
    di `"          ,--\`,--'\/\    /"'
    di `"          '-- "--'  '--'"'
end

program cowsay_daemon
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"            ,        ,"'
    di `"           /(        )\` "'
    di `"           \ \___   / |"'
    di `"            /- _  \`-/  '"'
    di `"           (/\/ \ \   /\"'
    di `"           / /   | \`    "'
    di `"           O O   ) /    |"'
    di `"           \`-^--'\`<     '"'
    di `"          (_.)  _  )   /"'
    di `"           \`.___/\`    /"'
    di `"             \`-----' /"'
    di `"<----.     __ / __   \"'
    di `"<----|====O)))==) \) /===="'
    di `"<----'    \`--' \`.__,' \"'
    di `"             |        |"'
    di `"              \       /"'
    di `"        ______( (_  / \______"'
    di `"      ,'  ,-----'   |        \"'
    di `"      \`--{__________)        \/ [nosig]"'
end

program cowsay_duckling
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"       \"'
    di `"        >o  ."'
    di `"         ===    [ab]"'
end

program cowsay_duck
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"         __"'
    di `"        /o \"'
    di `"      <=   |         =="'
    di `"        |__|        /==="'
    di `"        |   \______/  ="'
    di `"        \     ====   /"'
    di `"         \__________/     [ab]"'
end

program cowsay_owl
    di `"    \   "'
    di `"     \  "'
    di `"      \"'
    di `"       /\___/\"'
    di `"       {o}{o}|"'
    di `"       \ v  /|"'
    di `"       |    \ \"'
    di `"        \___/_/       [ab] "'
    di `"          | | "'
end
