clear all
set more off

cap mkdir "logs"
cap mkdir "figures"
use "cepr_march_2018_course.dta", clear

* 3A. Summary statistics (N, Mean, Median, SD, Min, Max)
capture log close _all
log using "logs/problem3_3a.log", replace text name(q3a)

quietly dtable age educ empl hrwage married, ///
    continuous(, statistics(count mean sd min max)) ///
    nolistwise nosample

collect layout (var) (result[count mean sd min max])
collect label levels result count "Obs" mean "Mean" sd "Std. Dev." min "Min" max "Max", modify
collect style tex, nobegintable nocentering
collect export "problem_3a_table.tex", tableonly replace

log close q3a

* 3B. Box plot of hourly wages by education category (main figure) + Appendix A1
log using "logs/problem3_3b.log", replace text name(q3b)

display as text "Problem 3B: Box plot of hrwage by educ (nooutsides) — Main Figure"
graph box hrwage, over(educ) nooutsides ///
    title("Hourly wage by education category") ///
    ytitle("Hourly wage (US$/hour)")
graph export "figures/problem_3b_boxplot.png", replace
graph close

display as text "Appendix A1: Cleaned-sample box plot (age>=16, employed, hrwage>0 & <=500)"
preserve
    keep if age>=16 & empl==1
    replace hrwage = . if hrwage==0
    drop if hrwage>500
    graph box hrwage, over(educ) nooutsides ///
        title("Appendix A1: Hourly wage by education (cleaned sample)") ///
        ytitle("Hourly wage (US$/hour)")
    graph export "figures/appendix_3b_boxplot_clean.png", replace
	graph close
restore

log close q3b

* 3C. Inspect variables and identify at least two problems
log using "logs/problem3_3c.log", replace text name(q3c)

display as text "Problem 3C: Inspecting variables and documenting issues"
misstable summarize age educ empl hrwage married ind2d_03

* Finding #1: hrwage contains zeros and very large outliers
quietly count if empl==1
local Nemp = r(N)
quietly count if empl==1 & hrwage==0
local Nzero = r(N)
quietly count if empl==1 & hrwage>0 & hrwage<.
local Npos  = r(N)
quietly count if empl==1 & hrwage>500 & hrwage<.
local Nhi   = r(N)

display as result "Finding #1 - hrwage: Among employed (N = `Nemp'), `Nzero' cases have hrwage==0 and `Nhi' cases have hrwage>500."
display as text   "Interpretation: Zeros are likely pseudo-missing and should be recoded to missing; extreme values suggest trimming before analysis."

* Finding #2: ind2d_03 is structurally missing for children and the non-employed
quietly count if age>=16 & empl==1
local Nwork = r(N)
quietly count if age>=16 & empl==1 & missing(ind2d_03)
local Nmiss_ind = r(N)

display as result "Finding #2 - ind2d_03: For working-age employed (age>=16 & empl==1; N=`Nwork'), missing industry codes = `Nmiss_ind'."
display as text   "Interpretation: Industry is undefined for those <16 and not employed; restrict industry-based analyses to age>=16 & empl==1."

log close q3c

* 3D. Convert hhid2 (string with leading zeros) to a new numeric variable
log using "logs/problem3_3d.log", replace text name(q3d)

display as text "Problem 3D: Converting string household id (hhid2) to numeric"
destring hhid2, generate(hhid2_num)
label variable hhid2_num "Household ID (numeric, from hhid2)"
format hhid2_num %12.0f
display as result "Created hhid2_num from hhid2 via destring."

log close q3d

exit
