clear all
set more off

cap mkdir "logs"
cap mkdir "figures"
cap mkdir "tables"

set seed 47
use "allbmps_class.dta", clear

* 4A. Correlation between costbmp and gallons
capture log close _all
log using "logs/problem4_4a.log", replace text name(q4a)

display as text "Problem 4A: Correlation between costbmp and gallons"

quietly count if costbmp<. & gallons<.
local Npairs = r(N)

quietly corr costbmp gallons if costbmp<. & gallons<.
matrix C = r(C)
scalar rho_full = C[1,2]
display as result "Full-sample corr(costbmp, gallons) = " %9.4f rho_full
display as text "The above returns a correlation coefficient of 0.4619, indicating a moderately strong (in economics) positive relationship."

log close q4a

* 4B. Five 20% random samples; correlation in each, compare each to full-sample correlation from (4A)
log using "logs/problem4_4b.log", replace text name(q4b)

display as text "Problem 4B: Five 20 percent random samples; corr(costbmp, gallons) vs full sample"

matrix M = J(5,4,.)
matrix colnames M = sample Npairs rho delta_vs_full

forvalues r = 1/5 {
    preserve
        sample 20
        quietly count if costbmp<. & gallons<.
        local Npairs = r(N)
        quietly corr costbmp gallons if costbmp<. & gallons<.
        matrix C = r(C)
        scalar rho_r = C[1,2]
        matrix M[`r',1] = `r'
        matrix M[`r',2] = `Npairs'
        matrix M[`r',3] = rho_r
        matrix M[`r',4] = rho_r - rho_full
        display as result "Sample `r': N=`Npairs', rho=" %9.4f rho_r ", distance from full=" %9.4f (rho_r - rho_full)
    restore
}

matrix list M, format(%9.4f)

log close q4b

* 4C. Average cost per gallon by 20 bins of capacity (gallons)
log using "logs/problem4_4c.log", replace text name(q4c)

display as text "Problem 4C: Average cost per gallon by 20 bins of capacity (gallons)"

gen double cost_per_gallon = .
replace cost_per_gallon = costbmp / gallons if costbmp<. & gallons>0
label variable cost_per_gallon "Cost per gallon (USD per gallon)"

preserve
    keep if cost_per_gallon<. & gallons>0
    egen gallon_bins = cut(gallons), group(20)
    collapse (mean) avg_cpg = cost_per_gallon, by(gallon_bins)
    sort gallon_bins
    gen bin_index = _n

    twoway bar avg_cpg bin_index, ///
        xlabel(none) ///
        ytitle("Average cost per gallon (USD)") ///
        xtitle("Capacity (20 bins)") ///
        title("Average cost per gallon by capacity (20 bins)")
	graph export "figures/problem_4c_cpg_by_bin.png", replace
	graph close
restore

log close q4c

exit
