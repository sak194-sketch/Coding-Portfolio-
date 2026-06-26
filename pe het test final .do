

clear 
global raw_data "/Users/sanaakashif/Downloads" 
global outputs  "/Users/sanaakashif/Desktop/capstone" 


use "$outputs/PE_round2-3_round5-6.dta", clear

global controls_OLSwithclusterFE ///
	mumed_juniorplus careed_juniorplus daded_juniorplus ///
	math_r3 ppvt_r3 score_cog ///
	dad_primary male CHCMSTR5 wi agency_index_R3 ///
	ln_totalexp

* Interaction terms
gen tcp_male             = tcphyur3 * male
gen tcp_urban            = tcphyur3 * urban
gen tcp_caredu_juniorplus = tcphyur3 * careed_juniorplus

* Variable labels
label var tcphyur3             "Corporal Punishment"
label var tcp_male             "CP X Male"
label var tcp_urban            "CP X Urban"
label var tcp_caredu_juniorplus "CP X Caregiver: Junior plus"
label var math_r5              "Math Score (R5)"
label var ppvt_r5              "PPVT Score (R5)"
label var anderson_index       "Psychosocial Index (R5)"
label var gad7_avg             "Anxiety Assessment (GAD-7)"
label var phq8_avg             "Depression Assessment (PHQ-8)"
label var enrol_avg            "Education Enrollment"
label var work_avg             "Employment"

* Modified controls globals
global controls_het_male   = subinstr("$controls_OLSwithclusterFE", "male", "", .)
global controls_het_urban  = subinstr("$controls_OLSwithclusterFE", "urban", "", .)
global controls_het_caredu = subinstr("$controls_OLSwithclusterFE", "careed_juniorplus", "", .)


* Add this after your interaction terms section

*******************************************************************************
*		Table 1: Cognitive Outcomes (R5)
*******************************************************************************

quietly areg cog_r5 tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store cog_male

quietly areg cog_r5 tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store cog_urban

quietly areg cog_r5 tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store cog_careed

esttab cog_male cog_urban cog_careed ///
    using "$tables/HET_cognitive_r5.tex", replace ///
    b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) ///
    booktabs alignment(c) ///
    title("Heterogeneity Analysis: Cognitive Outcomes (R5), Peru") ///
    mtitles("Gender" "Urban" "Caregiver Education") ///
    keep(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    order(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    nocons nodepvars ///
    scalars("N Observations" "r2 R-squared" "clusterfe Cluster FE" "controls Controls") ///
    sfmt(%6.0fc %4.2f %s %s) ///
    addnotes("Heterogeneity by gender (reference = female), urban (reference = rural)," ///
             "and caregiver education (reference = None)." ///
             "Standard errors clustered at cluster level.")

estimates clear

*******************************************************************************
*		Table 2: Psychosocial Outcomes (R5)
*******************************************************************************

quietly areg anderson_index tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store psych_male

quietly areg anderson_index tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store psych_urban

quietly areg anderson_index tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store psych_careed

esttab psych_male psych_urban psych_careed ///
    using "$tables/HET_psychosocial_r5.tex", replace ///
    b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) ///
    booktabs alignment(c) ///
    title("Heterogeneity Analysis: Psychosocial Outcomes (R5), Peru") ///
    mtitles("Gender" "Urban" "Caregiver Education") ///
    keep(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    order(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    nocons nodepvars ///
    scalars("N Observations" "r2 R-squared" "clusterfe Cluster FE" "controls Controls") ///
    sfmt(%6.0fc %4.2f %s %s) ///
    addnotes("Heterogeneity by gender (reference = female), urban (reference = rural)," ///
             "and caregiver education (reference = None)." ///
             "Standard errors clustered at cluster level.")

estimates clear

*******************************************************************************
*		Table 3: Later Life Outcomes (R6)
*******************************************************************************

* GAD7
quietly areg gad7_avg tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store gad7_male

quietly areg gad7_avg tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store gad7_urban

quietly areg gad7_avg tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store gad7_careed

* PHQ8
quietly areg phq8_avg tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store phq8_male

quietly areg phq8_avg tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store phq8_urban

quietly areg phq8_avg tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store phq8_careed

* Enrollment
quietly areg enrol_avg tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store enrol_male

quietly areg enrol_avg tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store enrol_urban

quietly areg enrol_avg tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store enrol_careed

* Employment
quietly areg work_avg tcphyur3 tcp_male $controls_het_male, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store work_male

quietly areg work_avg tcphyur3 tcp_urban $controls_het_urban, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store work_urban

quietly areg work_avg tcphyur3 tcp_caredu_juniorplus $controls_het_caredu, ///
    absorb(clustid) vce(cluster clustid)
estadd scalar r2 = e(r2), replace
estadd local clusterfe "Yes"
estadd local controls "Yes"
estimates store work_careed

esttab gad7_male  gad7_urban  gad7_careed  ///
       phq8_male  phq8_urban  phq8_careed  ///
       enrol_male enrol_urban enrol_careed ///
       work_male  work_urban  work_careed  ///
       using "$tables/HET_laterlife_r6.tex", replace ///
    b(3) se(3) label star(* 0.10 ** 0.05 *** 0.01) ///
    booktabs alignment(c) ///
    title("Heterogeneity Analysis: Later Life Outcomes (R6), Peru") ///
    mgroups("Anxiety (GAD-7)" "Depression (PHQ-8)" "Enrollment" "Employment", ///
        pattern(1 0 0 1 0 0 1 0 0 1 0 0) ///
        prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
    mtitles("Gender" "Urban" "CareEd" "Gender" "Urban" "CareEd" ///
            "Gender" "Urban" "CareEd" "Gender" "Urban" "CareEd") ///
    keep(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    order(tcphyur3 tcp_male tcp_urban tcp_caredu_juniorplus) ///
    nocons nodepvars ///
    scalars("N Observations" "r2 R-squared" "clusterfe Cluster FE" "controls Controls") ///
    sfmt(%6.0fc %4.2f %s %s) ///
    addnotes("Heterogeneity by gender (reference = female), urban (reference = rural)," ///
             "and caregiver education (reference = None)." ///
             "Standard errors clustered at cluster level.")

estimates clear
