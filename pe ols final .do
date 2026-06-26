

/*******************************************************************************

Title: 		CGD & GU Capstone - LASSO, OLS and Cluster Fixed Effect
Author:		Sanaa Kashif , built on Aasna code
Last Modified: Mar 22, 2026

********************************************************************************/

clear 

global raw_data "/Users/sanaakashif/Downloads" 
global outputs  "/Users/sanaakashif/Desktop/capstone" 


use "$outputs/PE_round2-3_round5-6.dta", clear


//dropping these var is permanently saved to data set so if you want them back you need to rebuild the data set // 

global outcomes_R5 math_r5    ppvt_r5 agency_index_r5 ///
	   shame_index_r5 self_efficacy_index_r5 self_esteem_index_r5  anderson_index
	   
global outcomes_R6 gad7_avg phq8_avg enrol_avg work_avg 

global full_controls ///
	csd3r3 math_r3 ppvt_r3 agency_index_R3	///
	shame_index_R3 agemon urban male hhsize ///
	ln_totalexp wi ownhser3 bghtr326 mom_primary dad_primary ///
	careed_juniorplus mumed_juniorplus daded_juniorplus score_cog


save "$outputs/PE_round2-3_round5-6.dta", replace
* Variable labels for outreg display
	label variable tcphyur3         "Corporal punishment (self-reported)"
	label variable tcphothr3        "Teacher unfriendliness"
	label variable math_r3    "Math score, raw (R3)"
	label variable score_ppvt      "PPVT score, raw (R3)"
	label variable agency_index_R3  "Agency index (R3)"
	label variable shame_index_R3    "Shame index (R3)"
	label variable agemon       	"Child age in months (R3)"
	label variable male             	"Male"
	label variable totalexp   	"Total monthly expenditure"
	
	label variable wi           "Wealth index"
	label variable hhsize         "Household size"
	label variable CHCMSTR5                "Urban"
	label variable ownhser3         "Owns home"
	label variable bghtr326          "Bought or Spent on Debt"
	label variable mom_primary    "Primary caregiver: Mother"
	label variable dad_primary      "Primary caregiver: Father"
	label variable careed_juniorplus "Caregiver education: Junior plus"
	label variable mumed_juniorplus  "Mother education: Junior plus"
	label variable daded_juniorplus  "Father education: Junior plus"
	
	label variable score_cog        "Cognitive score (R2)"


********************************************************************************
*		1. LASSO-selected Controls for Baseline OLS 
********************************************************************************

// 1.1 Cognitive and Psychosocial Outcomes (Round 5)
	
* Initialize a macro to store the Union of all selected controls
	local total_union_R5 ""
	
	foreach outcome of global outcomes_R5 {
	
* LASSO selection
	dsregress `outcome' tcphyur3, ///
        controls($full_controls) 	///
			 rseed(12345) vce(cluster clustid )

    local sel = e(controls_sel)
    local n : display %6.0fc e(N)
	
* Update the Union list 
    local total_union_R5 : list total_union_R5 | sel
	
* OLS with LASSO-selected controls
    quietly regress `outcome' tcphyur3 `sel', vce(cluster clustid)
    local r2 : display %4.2f e(r2)

    di "--- `outcome' ---"
    di "Selected controls : `sel'"
    di "N = `n'  |  R² = `r2'"
	}

* Display union of all selected controls
	di "UNION OF ALL LASSO-SELECTED CONTROLS (R5)"
	di "`total_union_R5'"
	
//daded_higher math_r3 ppvt_r3 score_cog shame_index_R3 agency_index_R3 careed_secondary daded_primary hhsize wi


//


// 1.2 Later-Life Outcomes (Round 6)						
* Initialize a macro to store the Union of all selected controls
	local total_union_R6 ""
		
* LASSO selection
	foreach outcome of global outcomes_R6 {
   dsregress `outcome' tcphyur3, ///
    controls($full_controls) ///
        rseed(12345) vce(cluster clustid)

    local sel = e(controls_sel)
    local n : display %6.0fc e(N)

* Update the Union list 
    local total_union_R6 : list total_union_R6 | sel
	
* OLS with LASSO-selected controls
 quietly regress `outcome' tcphyur3 `sel', vce(cluster clustid)
    local r2 : display %4.2f e(r2)

    di "--- `outcome' ---"
    di "Selected controls : `sel'"
    di "N = `n'  |  R² = `r2'"
	}
	
* Display union of all selected controls
	di "UNION OF ALL LASSO-SELECTED CONTROLS (R6)"
	di "`total_union_R6'"
	
	//male mumed_secondary shame_index_R3 daded_primary daded_higher math_r3 ppvt_r3 careed_secondary wi // 




* Combine R5 and R6 unions into one master list
	local grand_union : list total_union_R5 | total_union_R6

	di "GRAND UNION OF ALL LASSO-SELECTED CONTROLS (R5 + R6)"
	di "`grand_union'"

	local count : word count `grand_union'
	di "Total unique control variables: `count'"
	
	
/*12 Lasso controls selected. 

bghtr326 male math_r3 ppvt_r3 score_cog shame_index_R3 agency_index_R3 hhsize ln_totalexp urban wi dade
> d_juniorplus careed_juniorplus


*/
	