        file open fh using example.tex, replace write
        file write fh       "\documentclass{article}"
        file write fh _n    "\begin{document}"
        file write fh _n    "\section{My Tables}"
        file write fh _n(2) "\input{_example1.tex}"
        file write fh _n(2) "\input{_example2.tex}"
        file write fh _n(2) "\end{document}"
        file close fh
        type example.tex
