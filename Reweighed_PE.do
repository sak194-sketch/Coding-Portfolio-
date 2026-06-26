/*******************************************************************************

Title: 		CGD Capstone - Inverse Probability Weighting, India
Last Modified:	Mar 2026

OVERVIEW:
	This do file constructs inverse probability weights (IPW) to account for 
	attrition between Round 3 (baseline) and Rounds 5 and 6. The weights 
	upweight children who are similar to those who dropped out, so that the 
	analysed sample remains representative of the original baseline sample.

PROCESS:
	1. For each round, we run a logit model predicting dropout using baseline 
	   characteristics: math score, PPVT score, agency index, shame index, 
	   sex, and corporal punishment.
	2. Each child's predicted probability of being observed is used to 
	   construct a weight: 1 / P(observed). Children who look like dropouts 
	   but stayed in the sample receive a higher weight.
	3. Weights are trimmed at the 1st and 99th percentile to prevent extreme 
	   values from destabilising estimates.

FLAG - PPVT MISSINGNESS:
	342 children in India are missing their baseline PPVT score (rppvt_co). 
	Because Stata drops any observation missing a covariate from the logit, 
	these children end up with no IPW weight. I checked and these children are 
	no more likely to have dropped out than the rest of the sample, so the 
	missingness appears random. For now, rppvt_co is kept in the model and 
	these 342 children will have missing weights. 

	ACTION FOR OTHER COUNTRIES: Please check whether the same issue exists in 
	Vietnam, Peru, and Ethiopia by running:
	
		foreach var in rmath_co rppvt_co agency_index_R3 shame_index_R3 cp_binary {
			count if missing(`var')
			display "^ missing in `var'"
		}
	
	If PPVT missingness is widespread across countries, it may make sense to 
	drop rppvt_co from the logit model consistently so the IPW approach is 
	comparable across all four countries.

RESULTS:
	Attrition in India is very low — 1.5% by Round 5 and 3.5% by Round 6 — 
	and largely random. IPW weights are close to 1 for almost everyone, so 
	the correction is modest. Both weighted and unweighted regressions should 
	be reported as a robustness check.

********************************************************************************/


use "/Users/sanaakashif/Desktop/capstone/round2_3_4_5_6.dta", clear


********************************************************************************
**#                   1.  Agency Index
********************************************************************************	

* 1. Recode: keep positive direction; reverse the negative items
foreach var in ctryhdr3 cftrwrr3 cbrjobr3 {
       clonevar pos_`var' = `var'
       recode pos_`var' (77 79 88 99 = .)
   }

foreach var in cpldecr3 cnochcr3  {
    recode `var' (1=5) (2=4) (3=3) (4=2) (5=1) (77 79 88 99=.), gen(pos_`var')
}

* 2. Construct index
* Calculate the mean across agency variables for each child
egen agency_index_raw = rowmean(pos_ctryhdr3 pos_cftrwrr3  pos_cpldecr3 ///
						pos_cbrjobr3 pos_cnochcr3) 
* Standardize: (value-mean)/sd
egen agency_index_R3 = std(agency_index_raw)

* Inspect
summarize agency_index_R3

/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
agency_index |      1,822   -8.35e-09           1  -5.083423   3.692393
*/			


********************************************************************************
**#                   2.  Shame Index- coded for indivisual analysis 
********************************************************************************
												 
* 1. Reverse-code each item and set DK/refused (77, 79, 88, 99) to missing
foreach var in cashshr3  ccltrgr3 cashclr3 cembbkr3 cwrunir3 cashwkr3   {
    recode `var' (1=5) (2=4) (3=3) (4=2) (5=1) (77 79 88 99=.), gen(rev_`var')
}

* 2. Construct index
* Calculate the mean across shame variables for each child
egen shame_index_raw = rowmean(rev_cashshr3  rev_ccltrgr3 rev_cashclr3 rev_cembbkr3 rev_cwrunir3 rev_cashwkr3)
						
* Standardize: (value-mean)/sd
egen shame_index_R3 = std(shame_index_raw)

* Inspect
summarize shame_index_R3

/*
    Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
 shame_index |      1,822   -4.44e-09           1  -2.165689   5.562105
*/




********************************************************************************
**#             0. Diagnose missing covariates
********************************************************************************

gen missing_covars = missing(rmath_co, rppvt_co, agency_index_R3, shame_index_R3, cp_binary)
tab missing_covars

// Check whether missingness is related to attrition — should not be systematic
tab missing_covars attrite_R5
tab missing_covars attrite_R6

// Identify which variable is driving missingness
foreach var in rmath_co rppvt_co agency_index_R3 shame_index_R3 cp_binary {
	count if missing(`var')
	display "^ missing in `var'"
}


********************************************************************************
**#             1. IPW for Round 5
********************************************************************************

// 1. Logit: predict probability of attriting at Round 5
logit attrite_R5 rmath_co rppvt_co agency_index_R3 shame_index_R3 male cp_binary

// 2. Predict probability of being observed (1 - P(attrite))
predict p_obs_R5, pr
replace p_obs_R5 = 1 - p_obs_R5

// 3. Construct IPW weight: 1 / P(observed)
gen ipw_R5 = 1 / p_obs_R5

// 4. Inspect weights
summarize ipw_R5, detail
histogram ipw_R5, title("IPW Weights - Round 5") percent

// 5. Trim at 1st and 99th percentile
egen p1_R5  = pctile(ipw_R5), p(1)
egen p99_R5 = pctile(ipw_R5), p(99)

gen ipw_R5_trim = ipw_R5
replace ipw_R5_trim = p1_R5  if ipw_R5 < p1_R5  & !missing(ipw_R5)
replace ipw_R5_trim = p99_R5 if ipw_R5 > p99_R5 & !missing(ipw_R5)
drop p1_R5 p99_R5

summarize ipw_R5_trim, detail

// 6. Confirm no missing-covariate children were incorrectly assigned a weight
count if !missing(ipw_R5_trim) & missing_covars == 1
// ^ should be 0


********************************************************************************
**#             2. IPW for Round 6
********************************************************************************

// 1. Logit: predict probability of attriting at Round 6
logit attrite_R6 rmath_co rppvt_co agency_index_R3 shame_index_R3 male cp_binary

// 2. Predict probability of being observed
predict p_obs_R6, pr
replace p_obs_R6 = 1 - p_obs_R6

// 3. Construct IPW weight
gen ipw_R6 = 1 / p_obs_R6

// 4. Inspect weights
summarize ipw_R6, detail
histogram ipw_R6, title("IPW Weights - Round 6") percent

// 5. Trim at 1st and 99th percentile
egen p1_R6  = pctile(ipw_R6), p(1)
egen p99_R6 = pctile(ipw_R6), p(99)

gen ipw_R6_trim = ipw_R6
replace ipw_R6_trim = p1_R6  if ipw_R6 < p1_R6  & !missing(ipw_R6)
replace ipw_R6_trim = p99_R6 if ipw_R6 > p99_R6 & !missing(ipw_R6)
drop p1_R6 p99_R6

summarize ipw_R6_trim, detail

// 6. Confirm no missing-covariate children were incorrectly assigned a weight
count if !missing(ipw_R6_trim) & missing_covars == 1
// ^ should be 0


********************************************************************************
**#             3. Save
********************************************************************************

save "/Users/aneysharoy/Desktop/Capstone/IN_round2-3_round5-6_ipw.dta", replace
