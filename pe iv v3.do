

/*******************************************************************************

Title: 		CGD & GU Capstone - Instrumental Variables (IV)
Author:		sanaa kashif 
Last Modified: Mar 24, 2026

********************************************************************************/


global raw_data "/Users/sanaakashif/Downloads" 
global outputs  "/Users/sanaakashif/Desktop/capstone" 

use "$outputs/PE_round2-3_round5-6.dta", clear



//7 missing generated// 

global controls_OLSbaseline ///
	mumed_juniorplus careed_juniorplus daded_juniorplus ///
	math_r3 ppvt_r3  score_cog ///
	male CHCMSTR5 wi agency_index_R3 ///
	agemon hhsize

global controls_OLSwithclusterFE ///
	mumed_juniorplus careed_juniorplus daded_juniorplus ///
	math_r3  ppvt_r3 score_cog ///
	dad_primary male CHCMSTR5 wi agency_index_R3 ///
	ln_totalexp

global controls_OLSwithmaleFE ///
	mumed_juniorplus careed_juniorplus daded_juniorplus ///
	math_r3 score_cog ///
	dad_primary CHCMSTR5 wi agency_index_R3 ///
	agemon hhsize

global controls_OLSwithurbanFE ///
	careed_juniorplus daded_juniorplus mumed_juniorplus ///
	math_r3 ppvt_r3 score_cog ///
	ln_totalexp wi hhsize dad_primary male ///
	agemon agency_index_R3
	
global outcomes_R5 math_r5  ppvt_r5 agency_index_r5 ///
	   shame_index_r5 self_efficacy_index_r5 self_esteem_index_r5 anderson_index
	   
global outcomes_R6 gad7_avg phq8_avg enrol_avg work_avg

********************************************************************************
*			1. Check Assumption
********************************************************************************
			
* Construct IV from leave-one-out average cp_others reported in community j
			
* Construct IV from leave-one-out average cp_others reported in community j
	sort clustid 
	bysort clustid : egen total_cp = total(tcphothr3)
	bysort clustid : gen n_comm = _N
	gen avg_cp_others = (total_cp - tcphothr3 ) / (n_comm - 1)
	drop total_cp n_comm
	
* Check instrument relevance
	reg tcphyur3 avg_cp_others 
	
	/*
		  Source |       SS           df       MS      Number of obs   =     1,805
	-------------+----------------------------------   F(1, 1803)      =     34.36
		   Model |  5.33331857         1  5.33331857   Prob > F        =    0.0000
		Residual |  279.846737     1,803  .155211723   R-squared       =    0.0187
	-------------+----------------------------------   Adj R-squared   =    0.0182
		   Total |  285.180055     1,804  .158082071   Root MSE        =    .39397

	-------------------------------------------------------------------------------
		  cp_self | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
	--------------+----------------------------------------------------------------
	avg_cp_others |   .3431642   .0585417     5.86   0.000     .2283475    .4579809
			_cons |  -.0071163   .0359812    -0.20   0.843    -.0776855    .0634528
	-------------------------------------------------------------------------------

	*/
	
	
********************************************************************************
* 			2. Generate OLS & IV Tables: Round 5 Outcomes
********************************************************************************
* Variable labels
	label variable tcphyur3 "Corporal Punishment"
	
	* --- Child Characteristics ---
	label variable agemon "Child Age (Months)"
	label variable male "Male"
	label variable math_r3 "Math Score (R3)"
	label variable ppvt_r3 "PPVT Score (R3)"
	label variable score_cog "Cognitive Score, CDA (R2)"
	label variable agency_index_R3 "Agency Index (R3)"
	
	* --- Household Characteristics ---
	label variable CHCMSTR5 "Urban"
	label variable wi "Wealth Index"
	label variable hhsize "Household Size"
	label variable mumed_juniorplus "Mother Education: Junior plus"
	label variable careed_juniorplus "Caregiver Education: Junior plus"
	label variable daded_juniorplus "Father Education: Junior plus"
	label variable dad_primary "Primary Caregiver: Father"
	label variable ln_totalexp "Log of Total Expenditure"
	
	* --- R5 Outcomes ---
	label variable math_r5 "Math Score (Raw)"
	label variable ppvt_r5 "PPVT Score (Raw)"
	label variable agency_index_r5 "Agency Index"
	label variable shame_index_r5 "Shame Index"
	label variable self_efficacy_index_r5 "Self-Efficacy Index"
	label variable self_esteem_index_r5 "Self-Esteem Index"
	label variable anderson_index "Anderson Index"
	
	* --- R6 Outcomes ---
	label variable gad7_avg "Anxiety Assessment (GAD-7)"
	label variable phq8_avg "Depression Assessment (PHQ-8)"
	label variable enrol_avg "Education Enrollment Status"
	label variable work_avg "Employment Status"
	

foreach outcome of global outcomes_R5 {
    
    local vlabel : var label `outcome'
    if "`vlabel'" == "" local vlabel "`outcome'"
	
	* Model (1): OLS Baseline
	quietly regress `outcome' tcphyur3 $controls_OLSbaseline
	estadd local cluster_fe "No"
	estimates store m1

	* Model (2): OLS with Cluster FE
	quietly regress `outcome' tcphyur3 $controls_OLSwithclusterFE, ///
		vce(cluster clustid) 
	estadd local cluster_fe "Yes"
	estimates store m2
	
	* Model (3): IV Baseline
	quietly ivregress 2sls `outcome' (tcphyur3 = avg_cp_others) ///
		$controls_OLSbaseline
	estadd local cluster_fe "No"
	
	quietly estat firststage 
	matrix f_matrix = r(singleresults)
	estadd scalar cd_f = f_matrix[1,4]
	estimates store m3

	* Model (4): IV with Cluster FE
	quietly ivregress 2sls `outcome' (tcphyur3 = avg_cp_others) ///
			$controls_OLSwithclusterFE, vce(cluster clustid)
	estadd local cluster_fe "Yes"
	
	quietly  estat firststage 
	matrix f_matrix = r(singleresults)
	estadd scalar cd_f = f_matrix[1,4]
	estimates store m4

	esttab m1 m2 m3 m4 using "$tables/OLS_IV_`outcome'.tex", replace ///
		b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs alignment(c) ///
		title("Impact of Corporal Punishment on `vlabel', Peru") ///
		order(tcphyur3 ) ///
		nodepvars nomtitles noconstant /// 
		mgroups("OLS" "IV", pattern(1 0 1 0) ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
		scalars("cluster_fe Cluster Fixed Effects" ///
				"cd_f Cragg-Donald Wald F-statistic" ///
				"N No. of Observations") 
				
	estimates clear
	
	}
	
********************************************************************************
* 			3. Generate OLS & IV Tables: Round 6 Outcomes
********************************************************************************

foreach outcome of global outcomes_R6 {
    
    local vlabel : var label `outcome'
    if "`vlabel'" == "" local vlabel "`outcome'"
	
	* Model (1): OLS Baseline
	quietly regress `outcome' tcphyur3 $controls_OLSbaseline [pweight = ipw_R6_trim]
	estadd local cluster_fe "No"
	estimates store m1

	* Model (2): OLS with Cluster FE
	quietly regress `outcome' tcphyur3 $controls_OLSwithclusterFE /// 
	[pweight = ipw_R6_trim], vce(cluster clustid) 
	estadd local cluster_fe "Yes"
	estimates store m2
	
	* Model (3): IV Baseline
	quietly ivregress 2sls `outcome' (tcphyur3 = avg_cp_others) ///
		$controls_OLSbaseline [pweight = ipw_R6_trim]
	estadd local cluster_fe "No"
	
	quietly estat firststage 
	matrix f_matrix = r(singleresults)
	estadd scalar cd_f = f_matrix[1,4]
	estimates store m3

	* Model (4): IV with Cluster FE
	quietly ivregress 2sls `outcome' (tcphyur3 = avg_cp_others) ///
			$controls_OLSwithclusterFE [pweight = ipw_R6_trim], vce(cluster clustid)
	estadd local cluster_fe "Yes"
	
	quietly  estat firststage 
	matrix f_matrix = r(singleresults)
	estadd scalar cd_f = f_matrix[1,4]
	estimates store m4

	esttab m1 m2 m3 m4 using "$tables/OLS_IV_`outcome'.tex", replace ///
		b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) ///
		booktabs alignment(c) ///
		title("Impact of Corporal Punishment on `vlabel', Peru") ///
		order(cp_self) ///
		nodepvars nomtitles noconstant /// 
		mgroups("OLS" "IV", pattern(1 0 1 0) ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span) ///
		scalars("cluster_fe Cluster Fixed Effects" ///
				"cd_f Cragg-Donald Wald F-statistic" ///
				"N No. of Observations") 
				
	estimates clear
	
	}

