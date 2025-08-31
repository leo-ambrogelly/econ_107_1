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
* It seems like educ and empl are missing values that should be there, though 'decline to respond' likely accounts for this.
