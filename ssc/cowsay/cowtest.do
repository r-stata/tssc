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

cowsay "Hello, world!"
log close _all
log using animals.txt, text name(animals) replace
foreach animal of local animals {
    disp `""'
    disp `"`animal'"'
    cowsay "Hello, world!", animal(`animal')
}
log close animals
