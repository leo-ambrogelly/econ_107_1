* Boilerplate and Load Dataset
cls
use cepr_march_2018.dta, clear

* Problem A: summary statistics for requested columns, export to LaTeX.
* 1. Build dtable to resemble summarize
quietly dtable age educ empl hrwage married, continuous(, statistics(count mean sd min max)) sformat("%s" sd)

* 2. Collect those stats into separate columns and name the headers, export table fragment.
collect layout (var) (result[count mean sd min max])
collect label levels result count "Obs" mean "Mean" sd "Std. Dev." min "Min" max "Max", modify
collect style header result, level(label)
collect export "problem_3a_table.tex", tableonly replace

* Problem B: Constuct a box plot of wages by education level.
graph box hrwage, over(educ) title("Wages by Level of Education") nooutsides
graph export problem_3b_boxplot.png, replace

* Problem C: Inspection of variables.
misstable summarize age educ empl hrwage married
tab indly3d_14 if hrwage==0, sort
* The above tab command returns 5,030 instances of 0-wages, which should not be possible.
* The fact that this is a low proportion of the population makes it difficult to believe that these 0s represent salaried workers.
tab empl if hrwage==0
misstable summarize hrwage if empl==0
* The above tab command shows that 0-wages are far more common with people marked as employed.
* The above misstable command seems to suggest that coding unemployment with missing values in wages is far more common.
* I can only conclude that 0-wages are an error of some kind.
