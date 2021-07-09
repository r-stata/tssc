program demotivate
version 10

syntax
local x = runiform()


if `x'<=0.05  {
   di as txt  "{c 39}All models are wrong but some are useful.{c 39} George Box"
   di as txt  "Indeed but its unclear that you can take much consolation from that"
   exit
 }

if `x'>0.05 & `x'<=0.10 {
   di as txt  "Those last set of results you got: not exactly AER material are they? "
   di as txt  "                                            "
   exit
 }

if `x'>0.10 & `x'<=0.15 {
   di as txt  "Have you thought of trying economic theory? It worked out well for Paul Krugman."
      exit
 }

if `x'>0.15 & `x'<=0.20 {
   di as txt  "Seriously, nobody believes your p values."
    exit
 }


if `x'>0.20 & `x'<=0.25 {
   di as txt  "Reviewer #2 is going to have fun if you include your latest results."
   di as txt  "                                            "
   exit
 }

if `x'>0.25 & `x'<=0.30 {
   di as txt  "You need to stop thinking like a graduate student. Especially if you are one."
   di as txt  "                                            "
   exit
 }

if `x'>0.30 & `x'<=0.35 {
   di as txt  "John Ioannidis has got you sussed out. All of us in fact. We're doomed I tell you."
   di as txt  "                                            "
   exit
 }

if `x'>0.35 & `x'<=0.40 {
   di as txt  "Best not to dwell on what your R-using colleagues really think of you."
   di as txt  "                                            "
   exit
 }

if `x'>0.40 & `x'<=0.45 {
   di as txt  "{c 39}Friends don't let friends use instrumental variables {c39}"
   di as txt  "                                            Unknown"
   exit
 }

if `x'>0.45 & `x'<=0.50 {
   di as txt  "This will be a lot easier to do in the next version of Stata. Kerching $$$$$ !"
     exit
 }

if `x'>0.50 & `x'<=0.55 {
   di as txt  "The fact is most papers are rejected"
    exit
 }

if `x'>0.55 & `x'<=0.60 {
   di as txt  "It's not too late to learn Python"
      exit
 }

if `x'>0.60 & `x'<=0.65 {
   di as txt  "If only you had taken a few more math courses you could have been someone. You could have been a contender."
   exit
 }

if `x'>0.65 & `x'<=0.70 {
   di as txt  "Life is full of emptiness"
   exit
 }

if `x'>0.70 & `x'<=0.75 {
   di as txt  "{c 39}Imagine how hard physics would be if electrons had feelings.{c 39} Richard Feynmann."
   di as txt  "Welcome to our world, Dick."
   exit
 }

if `x'>0.75 & `x'<=0.80 {
   di as txt  "{c 39}There are no routine statistical questions only questionable statistical routines.{c 39} David Cox."
   di as txt  "Here's looking at you, kid."
   exit
 }
if `x'>0.80 & `x'<=0.85 {
   di as txt  "{c 39}But our preferred model shows...{c 39}  lmao, gets me everytime"
     exit
 }

if `x'>0.85 & `x'<=0.90 {
   di as txt  "{c 39}Erode gormless sin{c 39} is an anagram for {c 39}regression models{c 39} curiously enough"
   exit
 }

if `x'>0.90 & `x'<=0.95 {
   di as txt  "Don't worry: there is a behavioral economics interpretation of your results."
    exit
 }

if `x'>0.95 & `x'<=1.00 {
   di as text "Have you ever considered letting Bayes into your life?"
   exit
 }

end




