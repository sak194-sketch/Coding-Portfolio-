
set seed 123
//saving all generated folders and data sets to a specific folder// 
* Set working directory where all files will be saved/loaded


//question 1.1.1 (d)//
set more off 
clear 
//a//
// setting the world and the probabilities// 
set obs 6 
local n = 5
local p = 0.1
gen x = _n - 1
gen prob = binomialp(`n', x, `p')
//table of values//
list x prob
//graph of values// 
twoway bar prob x, ytitle("Probability") xtitle("Number of red balloons (x)") title("Binomial(5, 0.1) distribution")

//b//

local cutoff = .
forvalues k = 0/5 {
    quietly su prob if x>=`k'
    if r(sum) <= 0.05 {
        local cutoff = `k'
        di "Critical value cutoff = " `cutoff'
        continue, break
    }
}

//1.1.2 (d)//
set more off 
clear 
//a- same code as above but with the probability changed//
// setting the world and the probabilities// 
set obs 6 
local n = 5
local p = 0.2
gen x = _n - 1
gen prob = binomialp(`n', x, `p')
//table of values//
list x prob

//b//

local cutoff = .
forvalues k = 0/5 {
    quietly su prob if x>=`k'
    if r(sum) <= 0.05 {
        local cutoff = `k'
        di "Critical value cutoff = " `cutoff'
        continue, break
    }
}


//1.1.4 (d)//

set more off 
clear 
//a//
// setting the world and the probabilities// 
set obs 6
local n = 2000
local p = 0.2
gen x = _n - 1
gen prob = binomialp(`n', x, `p')
//table of values//
list x prob

//b//

local cutoff = .
forvalues k = 0/5 {
    quietly su prob if x>=`k'
    if r(sum) <= 0.05 {
        local cutoff = `k'
        di "Critical value cutoff = " `cutoff'
        continue, break
    }
}

//this code was just adjusted and run to find values for the table //

set more off
clear
set seed 123

cap prog drop balloon_power
prog def balloon_power, rclass
    args n pA pB
    clear
    set obs 1
    gen worldA = rbinomial(`n', `pA')
    gen worldB = rbinomial(`n', `pB')
    return scalar reds_wA = worldA
    return scalar reds_wB = worldB
end

cap postclose handle
tempfile results
postfile handle int n int crit_high float type1 type2 power using `results'

foreach n in 5 10 20 2000 {
    quietly {
        simulate grpA=r(reds_wA) grpB=r(reds_wB), reps(10000) nodots: balloon_power `n' 0.10 0.20
        
        forvalues k = 0/`n' {
            count if grpA >= `k'
            if r(N)/_N <= 0.05 {
                local crit = `k'
                continue, break
            }
        }
        
        count if grpA >= `crit'
        local type1 = r(N)/_N
        count if grpB < `crit'
        local type2 = r(N)/_N
        
        post handle (`n') (`crit') (`type1') (`type2') (`=1-`type2'')
    }
}

postclose handle
use `results', clear
list, clean

//1.2.1 // 
 
//Timestamp: 2025-09-16 18:50:18 UTC : n = 37 //
//a//
clear 
cap prog drop cointoss     // Drop any previous program named "cointoss"
prog define cointoss, rclass  // Begin defining a new program called "cointoss"

	args n prob             // Define the parameters for sample size (n) and probability of heads (prob)
	
	clear                  // Clear your workspace after each iteration to avoid data contamination
	
	set obs `n'            // Set the number of observations equal to the sample size (n)
	
	gen heads = runiform() > `prob'  // Generate a variable "heads" which is 1 if a random number is greater than the given probability
	
	count if heads == 1    // Count the number of heads (i.e., the number of times "heads" is 1)
	return scalar heads = r(N) // Store the count of heads in a scalar called "heads"
	
end 
simulate /// 
	heads = r(heads) ///  // Simulate the heads count returned by the "cointoss" program
	, reps(10000) ///      // Repeat the simulation 10,000 times
	nodots: cointoss 37 0.5 // Run the "cointoss" program with 1000 observations and a fair coin (probability = 0.5)
 

//tabulate // 
	
tab heads

//1.2.2//

//Timestamp: 2025-09-16 20:09:57 UTC//
//N = 42// 
//15 heads were present// 
*a 
set seed 123 
clear 
cap prog drop cointoss     // Drop any previous program named "cointoss"
prog define cointoss, rclass  // Begin defining a new program called "cointoss"

	args n prob             // Define the parameters for sample size (n) and probability of heads (prob)
	
	clear                  // Clear your workspace after each iteration to avoid data contamination
	
	set obs `n'            // Set the number of observations equal to the sample size (n)
	
	gen heads = runiform() > `prob'  // Generate a variable "heads" which is 1 if a random number is greater than the given probability
	
	count if heads == 1    // Count the number of heads (i.e., the number of times "heads" is 1)
	return scalar heads = r(N) // Store the count of heads in a scalar called "heads"
	
end 
simulate /// 
	heads = r(heads) ///  // Simulate the heads count returned by the "cointoss" program
	, reps(10000) ///      // Repeat the simulation 10,000 times
	nodots: cointoss 42 0.5  
	// Run the "cointoss" program with 1000 observations and a fair coin- this can be changed for all three values of p //

//tabulate // 
	
tab heads

//1.2.3//
clear
set more off
local n     = 42
local x     = 15
local alpha = 0.05

set obs 99
gen p0   = _n/100  // Test p from 0.01 to 0.99
gen pval = .

forvalues j = 1/99 {
    local p = `j'/100
    quietly bitesti `n' `x' `p'
    replace pval = r(p) in `j'
}

* Nulls we do NOT reject (CI)
gen byte keep = pval >= `alpha'

format p0 %4.2f pval %9.6f
list p0 pval if keep, noobs

* endpoints of the CI (the "set of nulls not rejected")
quietly summarize p0 if keep, detail
display as text "95% CI (nulls not rejected): [" %4.2f r(min) ", " %4.2f r(max) "]"

//1.2.4//

clear
set more off
local n = 42
local x = 15
local p_hat = `x'/`n'

* Part 4: CI using observed proportion
bitesti `n' `x' `p_hat'
local ci_lower = r(lb)
local ci_upper = r(ub)
di "Part 4 CI: [" %4.2f `ci_lower' ", " %4.2f `ci_upper' "]"

* Part 3: Set of non-rejected nulls
set obs 99
gen p0 = _n/100
gen pval = .
forvalues j = 1/99 {
    quietly bitesti `n' `x' `=`j'/100'
    replace pval = r(p) in `j'
}
qui sum p0 if pval >= 0.05
di "Part 3 CI: [" %4.2f r(min) ", " %4.2f r(max) "]"

//1.3.1//
* Drop program if it exists
clear 
cap program drop month_claims
program define month_claims, rclass
    args n   // number of people in the month
    clear
    set obs `n'
    * Generate monthly claims using probabilities: 0 (97%), 1 (2%), 2 (1%)
    gen u = runiform()
    gen claims = .
    replace claims = 0 if u < 0.97
    replace claims = 1 if u >= 0.97 & u < 0.99
    replace claims = 2 if u >= 0.99
    * Return sum of claims in this month
    summarize claims
    return scalar total_claims = r(sum)
end

* Run 10,000 simulations with n = 100 people per month
simulate total_claims = r(total_claims), reps(10000) : month_claims 100

* Add month number
gen month = _n  

* Reorder columns 
order month total_claims
save "months.dta", replace

//1.3.2//


use "months.dta", clear

* Find 95% CI bounds
_pctile total_claims, p(2.5 97.5)
di "95% CI: [" r(r1) ", " r(r2) "]"

* For one-tailed test (upper tail)
_pctile total_claims, p(95)
di "Critical value (95th percentile): " r(r1)

tab total_claims 
//find p value from here// 


//1.3.3//


local N = 10      
tab total_claims 
// changing the value of observations // 


//2.2.1//

set seed 123 
cap prog drop p221
prog def p221, rclass        
    args alpha prior
    clear  
    set obs 1
    * Hypothesis truth based on prior
    gen true = runiform() < `prior'
    return scalar true = true[1]
    * Effect size if true
    gen effect = runiform()*0.1   
    replace effect = 0 if true == 0  
    * Create individual-level data
    local n = ceil(runiform()*900 + 100)  // Fixed: generates number between 100-1000
    expand `n'
    gen pass = runiform() + effect > 0.5  
    count if pass
    local pass_count = r(N)
    * P-value (binomial test)
    qui bitesti `c(N)' `pass_count' 0.5
    return scalar significant = (`r(p)' < `alpha')
end

//run simulation//

local reps   10000
local priors 0.05 0.10 0.25 0.50 0.95
local alpha 0.05  // Alpha constant at 5%

foreach prior of local priors {
    
    di in red "Prior = `prior' | Alpha = `alpha'"
    simulate true = r(true) significant = r(significant), reps(`reps') nodots: ///
        p221 `alpha' `prior'
    
    * Compute required probabilities using tab
    qui tab true significant, matcell(m)
    
    * Calculate all probabilities from the contingency table
    scalar total = m[1,1] + m[1,2] + m[2,1] + m[2,2]
    scalar P_true = (m[2,1] + m[2,2]) / total
    scalar P_signif = (m[1,2] + m[2,2]) / total
    
    * Conditionals
    scalar P_signif_given_true = m[2,2] / (m[2,1] + m[2,2])
    scalar P_notsig_given_nottrue = m[1,1] / (m[1,1] + m[1,2])
    scalar P_notsig_given_true = m[2,1] / (m[2,1] + m[2,2])
    scalar P_signif_given_nottrue = m[1,2] / (m[1,1] + m[1,2])
    scalar P_nottrue_given_signif = m[1,2] / (m[1,2] + m[2,2])
    
    * Display nicely
    di "P(true) = " %6.3f P_true
    di "P(significant) = " %6.3f P_signif
    di "P(significant | true) = " %6.3f P_signif_given_true
    di "P(not significant | not true) = " %6.3f P_notsig_given_nottrue
    di "P(not significant | true) = " %6.3f P_notsig_given_true
    di "P(significant | not true) = " %6.3f P_signif_given_nottrue
    di "P(not true | significant) = " %6.3f P_nottrue_given_signif
    di "---------------------------------------"
}

//2.2.2//
set seed 123

cap prog drop p221
prog def p221, rclass        
args  alpha                      
clear  
		
set obs 1
*`true' percent of hypothesis have any effect
gen true = runiform() < 0.05
return scalar true = true[1]
*If true, effect sizes from 0-10pp
gen effect = runiform()* 0.1   
replace effect = 0 if true == 0  // If not true, no effect

*Create individual-level results within study
expand `=ceil(runiform(100, 1000))' // Integer sample sizes from 100-1000
*Generate data with 50+effect% success rate
gen pass = runiform() + effect > 0.5  

count if pass

*Get p-value and significance (using analytical approach)
qui bitesti `c(N)' `r(N)' 0.5 , d
*This is where we change alpha level 
return scalar significant = `r(p)' < `alpha'
end

//run simulation// 

foreach alpha in 0.5 0.25 0.1 0.05 0.01 0.001 0.0001 {
	simulate true = r(true) significant = r(significant), reps(1000) nodots: p221 `alpha'
	
	di in red "Alpha is `alpha'"
		
	*Row add ups to 100 so conditional on the row var so here conditional on true, look at percentage
	tab true significant, row
	tab true significant, column //means each column adds to 100	
}





//3.1.1//

clear 
set seed 123 
cap program drop sample_mean_height
program define sample_mean_height, rclass
    args n mu sigma // sample size

    clear                  // remove any existing data
    set obs `n'            // set number of observations

    * Generate heights from Normal(177,7)
    gen height = rnormal(`mu', `sigma')

    * Calculate mean height
    summarize height, meanonly
    return scalar mean_height = r(mean)


end
sample_mean_height 100 177 7 
    * Display mean height
    di "Sample mean height = " r(mean_height)
	
//3.1.2//

// N = 52   (timestamp: 2025-09-26 17:30)//
local n = 52
local mu = 177
local sigma = 7
 
* Simulate 10,000 sample means

simulate mean=r(mean_height), reps(10000) nodots : sample_mean_height `n' `mu' `sigma'

* Save the simulation results to a dataset called sim_men
gen id = _n
rename mean mean_height
order id mean_height
save sim_men, replace
use sim_men, clear

* Histogram of sampling distribution
histogram mean_height, width(0.1) percent ///
    title("Sampling Distribution of Mean Heights (US Men)") ///
    xtitle("Sample Mean") ytitle("Percent") color(blue)

* Add vertical lines for 95% confidence interval 2 
sum mean_height
scalar mean_us = r(mean)
scalar sd_us = r(sd)
scalar cv_lower = mean_us - invnormal(0.975)*sd_us
scalar cv_upper = mean_us + invnormal(0.975)*sd_us

twoway histogram mean_height, width(0.1) percent color(blue) ///
    xline(`=cv_lower' `=cv_upper', lpattern(dash) lcolor(red)) ///
    title("Sampling Distribution with 95% CI") ///
    legend(off)

	
//3.1.3//

clear
cap program drop sample_mean_height_fr
program define sample_mean_height_fr, rclass
    args n mu sigma // sample size, mean, standard deviation
    clear                  // remove any existing data
    set obs `n'            // set number of observations
    * Generate heights from Normal(179,7)
    gen height_fr = rnormal(`mu', `sigma')
    * Calculate mean height
    summarize height, meanonly
    return scalar mean_height = r(mean)
end

sample_mean_height_fr 52 179 7
    * Display mean height
    di "Sample mean height (France) = " r(mean_height)


//3.1.4// 
set seed 123 

* Hypothesis test: French sample vs US distribution
sample_mean_height_fr 52 179 7
local french_mean = r(mean_height)
use sim_men, clear
sum mean_height, meanonly
count if abs(mean_height - r(mean)) >= abs(`french_mean' - r(mean))
di "p-value = " r(N)/_N



//3.1.5//

//3.1.5//
* Power calculation
cap program drop power_test
program define power_test, rclass
    sample_mean_height_fr 52 179 7
    local french_mean = r(mean_height)
    use sim_men, clear
    sum mean_height, meanonly
    count if abs(mean_height - r(mean)) >= abs(`french_mean' - r(mean))
    return scalar reject = (r(N)/_N < 0.05)
end

simulate reject = r(reject), reps(1000) : power_test
sum reject
di "Power = " r(mean)
di "Type II errors = " (1-r(mean))*1000


//3.1.6//
//redoing step 3 //
clear
cap program drop sample_mean_height_in
program define sample_mean_height_in, rclass
    args n mu sigma // sample size, mean, standard deviation
    clear                  // remove any existing data
    set obs `n'            // set number of observations
    * Generate heights from Normal(179,7)
    gen height_in = rnormal(`mu', `sigma')
    * Calculate mean height
    summarize height, meanonly
    return scalar mean_height = r(mean)
end

sample_mean_height_in 52 165 7
    * Display mean height
    di "Sample mean height (India) = " r(mean_height)
	
//redoing step 4// 

* Hypothesis test: Indian sample vs US distribution

local indian_mean = r(mean_height)
use sim_men, clear
sum mean_height, meanonly
count if abs(mean_height - r(mean)) >= abs(`indian_mean' - r(mean))
di "p-value = " r(N)/_N

//redoing step 5//

cap program drop power_test
program define power_test, rclass
    sample_mean_height_in 52 179 7
    local india_mean = r(mean_height)
    use sim_men, clear
    sum mean_height, meanonly
    count if abs(mean_height - r(mean)) >= abs(`indian_mean' - r(mean))
    return scalar reject = (r(N)/_N < 0.05)
end

simulate reject = r(reject), reps(1000) : power_test
sum reject
di "Power = " r(mean)
di "Type II errors = " (1-r(mean))*1000



//3.1.7//

set seed 123 
clear 

* Set local for sample size
local LOCAL_N = 52

* Define global scalars for CI bounds from step 3.1.2
use sim_men, clear
sum mean_height
scalar mean_us = r(mean)
scalar sd_us = r(sd)
global lb = mean_us - invnormal(0.975)*sd_us
global ub = mean_us + invnormal(0.975)*sd_us

cap program drop lit_exag_test
program define lit_exag_test, rclass
    args n mu_alt sigma
    sample_mean_height `n' `mu_alt' `sigma'
    scalar m = r(mean_height)
    return scalar significant = (m < $lb | m > $ub)
    return scalar diff        = m - 177
    return scalar absdiff     = abs(m - 177)
end

*==============================
* FRANCE: True effect
*==============================
simulate significant=r(significant) diff=r(diff) absdiff=r(absdiff), reps(1000) nodots: ///
    lit_exag_test `LOCAL_N' 179 7

quietly summarize diff if significant
local fr_pub_diff = r(mean)
quietly summarize absdiff if significant
local fr_pub_abs  = r(mean)
count if significant
local fr_power = r(N)/_N

display "========== FRANCE =========="
display "FR: published mean(diff) = " `fr_pub_diff' "  (true = +2)"
display "FR: published mean(|diff|) = " `fr_pub_abs'  "  (|true| = 2)"
display "FR: exaggeration ratio = " (`fr_pub_abs'/2)
display "FR: power = " `fr_power'

*==============================
* INDIA: True effect 
*==============================
simulate significant=r(significant) diff=r(diff) absdiff=r(absdiff), reps(1000) nodots: ///
    lit_exag_test `LOCAL_N' 165 7

quietly summarize diff if significant
local in_pub_diff = r(mean)
quietly summarize absdiff if significant
local in_pub_abs  = r(mean)
count if significant
local in_power = r(N)/_N

display "========== INDIA =========="
display "IN: published mean(diff) = " `in_pub_diff' "  (true = -12)"
display "IN: published mean(|diff|) = " `in_pub_abs'  "  (|true| = 12)"
display "IN: exaggeration ratio = " (`in_pub_abs'/12)
display "IN: power = " `in_power'
