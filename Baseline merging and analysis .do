
/*
merging BWP & BWN and demographic analysis
Date created: 06-16-2025
Created by: 
*/

//================================================================================
// PROJECT: Civic Engagement and Education Quality Survey Analysis
// REGIONS: Punjab(BWP, BWN)
// PURPOSE: 
// This do-file conducts a comprehensive analysis of survey data examining the 
// relationship between government support programs, education quality perceptions,
// civic engagement, and socioeconomic status across two regions in Punjab. 
//
//================================================================================
// TABLE OF CONTENTS
//================================================================================
// 1. DATA PREPARATION
//    - Load and clean BWP and BWN datasets
//    - Convert conflicting variable types
//    - Append regional data
//
// 2. DEMOGRAPHIC OVERVIEW
//    - Respondent age, gender, household income
//    - Number of children by household
//    - Summary statistics by region and gender
//
// 3. GOVERNMENT SUPPORT PROGRAMS
//    - BISP (Benazir Income Support Program) participation and amounts
//    - Zevar-e-Taleem conditional transfer receipt
//    - Vaseela e Taleem support
//
// 4. EDUCATION QUALITY ANALYSIS
//    - Teacher quality, curriculum, headteacher effectiveness
//    - Facility availability (textbooks, water, playground)
//    - Opinion index and facility index construction
//    - Combined education quality index
//
// 5. CIVIC ENGAGEMENT & OUTCOMES OF INTEREST
//    - Perceived influence on government officials
//    - Collective efficacy (individuals can work together)
//    - Citizen responsibility for government performance
//    - Personal agency and confidence
//    - Trust in bureaucratic and political responsiveness
//
//

// Load BWP data//


// Convert numeric variables that may conflict//
tostring highest_level_edu_other, replace
tostring s2_1q18_999_desc, replace
drop s2_1q4_desc
drop s2_1q12f_desc 
* for 'other options', the past six months description variable has no observations (comes out blank)

drop s2_1q15_desc 
drop s2_1q23b_999_desc 

tempfile bwp
save `bwp'

//Now load BWN data//
use , clear
gen region = "BWN"

//Convert s2_1q19_999_desc from numeric to string
tostring s2_1q19_999_desc, replace

//Append BWP to BWN
append using `bwp'

// Save final dataset


rename s1_1q3  resp_age

//OVERVIEW // 
*average age of respondent s1_1q11:
summarize resp_age if resp_gender ==0 
sum resp_age if resp_gender == 1 

*gender distribution 
replace resp_gender = 0 if resp_gender == 1
replace resp_gender = 1 if resp_gender == 2
label define gender 0 "Male" 1 "Female", replace
label values resp_gender gender

tabulate resp_gender, missing

* age 
replace resp_age = . if resp_age == 16 
sum resp_age if resp_gender == 0 
sum resp_age if resp_gender == 1

* Monthly HH income 
replace s6q2 = . if s6q2  == -99 
replace s6q2  = . if s6q2 ==-88 
tab s6q2
sum s6q2 

//support //
* unconditional cash trasnfer
tab s6q3a

* conditional girls attendence cash transfer
tab s6q4a

* most common occupation per gender
replace s6q1 =. if s6q1 == 999
tabulate s6q1 if resp_gender == 1, sort
tabulate s6q1 if resp_gender == 0, sort

* education level
tabulate highest_level_of_ed
tabulate highest_level_of_ed if resp_gender == 1, sort
tabulate highest_level_of_ed if resp_gender == 0, sort
tabulate highest_edu_spouse
tabulate highest_edu_spouse if resp_gender == 0, sort
tabulate highest_edu_spouse if resp_gender == 1, sort 
tabstat  highest_level_of_ed, by(region) stats(mean sd n)

* political affiliation 
replace s2_2q4b = . if s2_2q4b == 999 
tabulate s2_2q4b, missing
tab s2_2q4b if resp_gender == 1, sort missing 
tab s2_2q4b if resp_gender == 0, sort missing 


* avg kids per HH. Here a value of 0 doesnt not mean no kids but rather kids outside of the age range 
tab s1_1q7  
sum s1_1q7

 
* top three issues by region 

tab most_imp_issue if region == "BWN", sort
tab second_imp_issue if region == "BWN", sort
tab third_imp_issue if region == "BWN", sort

tab most_imp_issue if region == "BWP", sort
tab second_imp_issue if region == "BWP", sort
tab third_imp_issue if region == "BWP", sort



// top issue per tehsil// 
tab most_imp_issue tehsil_code 
tab second_imp_issue tehsil_code 
tab third_imp_issue tehsil_code 

* recoded main issue 
gen main_issue_clean = . 
gen flag_any_issue_desc = 0

replace flag_any_issue_desc = 1 if ///
    (!missing(trim(most_imp_issue_desc)) & trim(most_imp_issue_desc) != "") | ///
    (!missing(trim(second_imp_issue_desc)) & trim(second_imp_issue_desc) != "") | ///
    (!missing(trim(third_most_imp_issue_desc)) & trim(third_most_imp_issue_desc) != "")

* creates a flag if the description variable has a value. This variable only has a response when the main 'issue variable' is coded as 'other'
* View all non-missing entries from the three variables

list most_imp_issue_desc if !missing(trim(most_imp_issue_desc)) & trim(most_imp_issue_desc) != "", noobs sep(0)
list second_imp_issue_desc if !missing(trim(second_imp_issue_desc)) & trim(second_imp_issue_desc) != "", noobs sep(0)
list third_most_imp_issue_desc if !missing(trim(third_most_imp_issue_desc)) & trim(third_most_imp_issue_desc) != "", noobs sep(0)

gen most_imp_issue_cleaned = most_imp_issue

//recoding the 'other' issue - note here that 22 = full or partial absenteeism ( also being late )

replace most_imp_issue_cleaned = 4 in 6
replace most_imp_issue_cleaned = 4 in 14 
replace most_imp_issue_cleaned = 4 in 197 
replace most_imp_issue_cleaned = 9 in 224 
replace most_imp_issue_cleaned = 6 in 257 
replace most_imp_issue_cleaned = 9 in 318 
replace most_imp_issue_cleaned = 222 in 375 
replace most_imp_issue_cleaned = 9 in 426 
replace most_imp_issue_cleaned = 24 in 444 
replace most_imp_issue_cleaned = 24 in 531 
replace most_imp_issue_cleaned = 2 in 753 
replace most_imp_issue_cleaned = 24 in 1341 
replace most_imp_issue_cleaned = 9 in 1499
replace most_imp_issue_cleaned = 14 in 1509 
replace most_imp_issue_cleaned = 9 in 1809 
replace most_imp_issue_cleaned = 25 in 2034 
replace most_imp_issue_cleaned = 2 in 2632 
replace most_imp_issue_cleaned = 24 in 2684 
replace most_imp_issue_cleaned = 24 in 2690 
replace most_imp_issue_cleaned = 6 in 2707 
replace most_imp_issue_cleaned = 6 in 2727 
replace most_imp_issue_cleaned = 6 in 3239 
replace most_imp_issue_cleaned = 4 in 3054 
replace most_imp_issue_cleaned = 24 in 3114 
replace most_imp_issue_cleaned = 27 in 3154 
replace most_imp_issue_cleaned = 20 in 3157 
replace most_imp_issue_cleaned = 4 in 3197 
replace most_imp_issue_cleaned = 14 in 3238 
replace most_imp_issue_cleaned = 4 in 3750 
replace most_imp_issue_cleaned = 4 in 3751 
replace most_imp_issue_cleaned = 14 in 4670 
replace most_imp_issue_cleaned = 5 in 4897 
replace most_imp_issue_cleaned = 20 in 5200 


*creating a category about f/m teachers needed - start by creating a new label for the most important issues category 


label define most_imp_lbl 30 "f/m teacher needed", add modify

label values most_imp_issue_cleaned most_imp_lbl

*replace the specific rows with the number 30 - which stands for f/m teachers needed 

foreach row in 701 853 902 1058 1059 1646 2472 2473 2490 2534 2768 3060 5980 5982 {
    replace most_imp_issue_cleaned = 30 in `row'
}

 
* key issues : lack of support - lack of wazifa , lack of free backpacks, uniforms, free meals, free trasnport, free textbooks
* also lack of professionalism - being on time, being well mannered with kids etc : 398 , 2752 , 4504  
* lack of complete facilities - lack of fan, lack of solar for when electricity runs out etc. 


* what type of policy maker was contacted
tab who_contact, sort 


* quality of education idex 

//cleaning data // 
replace teacher_quality = . if teacher_quality == -88
replace curriculum = . if curriculum == -88
replace headteacher = . if headteacher == -88
replace clean_drinking_water = . if clean_drinking_water == -88
replace clean_drinking_water = 0 if clean_drinking_water == 2
replace playground = . if playground == -88
replace playground = 0 if playground == 2 
replace free_textbooks = . if free_textbooks == -88
replace free_textbooks = 0 if free_textbooks == 2 
replace satisfried_with_schooling = . if satisfried_with_schooling == -88
replace consistant_teacher = . if consistant_teacher == -88
replace consistant_teacher = 0 if consistant_teacher == 2
replace school_facility = 0 if school_facility == -88 


// creating a rating//

* opinion index - rating of perseption of school quality
egen opinion_index = rowmean(teacher_quality curriculum headteacher school_facility satisfried)

* facility index. interpet as % of listed facilities available ( 1 = all available)
egen facility_index = rowmean(consistant_teacher clean_drinking_water playground free_textbooks) 

* joint index- interpret as mix of facility availability and opinion score: note this is a high number 
gen opinion_index_rescaled = (opinion_index - 1) / 4
gen edu_quality_index = (opinion_index_rescaled + facility_index)/2

* education and health as a top three issue 
gen edu_health_top_three = 1 if s2_2q5a1 == 1 | s2_2q5a2 == 1 | s2_2q5a3 == 1 | s2_2q5b1 == 6 | s2_2q5b2 == 6 | s2_2q5b3 == 6

replace edu_health_top_three = 0 if edu_health_top_three == . 

//regression// 

* creating a treatment regarding how early the option was ranked

gen treat_health_edu_early = .
replace treat_health_edu_early = 1 if !missing(s2_2q5a1)
replace treat_health_edu_early = 0 if !missing(s2_2q5b1)

ssc install estout, replace
reg edu_health_top_three treat_health_edu_early
esttab using "regression_table.tex", replace se label ///
title("Regression: Impact of Option Order on Choosing Health/Education") ///
mtitle("") ///
alignment(D{.}{.}{-1}) ///
star(* 0.1 ** 0.05 *** 0.01)

* talking about politics with your friends

* by gender  
tab s2_2q4e resp_gender 
* in general
tab s2_2q4e

 
* interaction term gender x facilitation  
replace s5q1  =. if s5q1  == -88 
reg s5q1 i.resp_gender


* smc present 
tab smc_present 

//outcomes of interest// 

* How you feel to influence Govt officials on issues that are important to you
tab s5q1 
sum s5q1  

* indivisuals can work together to eliminate problems in society
replace s5q2a = . if s5q2a == -88 
tab s5q2a , sort
sum s5q2a  

* avg citizen affect govs decsisions
replace s5q2b  = . if s5q2b  == -88 
tab s5q2b , sort 
sum s5q2b

* voters responsible for bad gov
replace s5q2c =. if s5q2c  == -88 
tab s5q2c , sort 
sum s5q2c

* change fate through efforts and actions
replace s5q2d = . if s5q2d ==-88
tab  s5q2d, sort 
sum s5q2d

* confident to change others attitude and behaviour 
replace s5q3a   =. if s5q3a  ==-88 
tab s5q3a  
sum s5q3a  


* confident to accomplish what you set out to do
replace s5q3b   = . if s5q3b   == -88 
tab s5q3b   
sort s5q3b   

* bureaucrats understand needs
replace burea_understands_needs= . if burea_understands_needs  == -88 
tab burea_understands_needs    
sum burea_understands_needs    

* politiciams understand needs
replace politicians_understands_needs = . if politicians_understands_needs == -88 
tab politicians_understands_needs
sum politicians_understands_needs


* HH wealth index 

// the wealth index is composed of assigning whether a respondnet is 'poor' or 'rich' considering if they have the asset in the HH or not. Once that clasification is assigned, these classifications are plugged into the PCA / factor model used in previouse analysis and then the quintile divides the populatio into 5 relative wealth groups// 


* List of all asset variables
local assets s6q6_0 s6q6_1 s6q6_2 s6q6_3 s6q6_4 s6q6_5 s6q6_6 s6q6_7 s6q6_8 s6q6_9 s6q6_10 s6q6_11

* Create binary variables: 0 = does not own, 1 = owns
foreach var of local assets {
    gen asset_`var' = 0 if missing(`var')
    replace asset_`var' = 1 if `var' == 1
    label define assetlab 0 "Poor" 1 "Non-poor", replace
    label values asset_`var' assetlab
}

factor asset_s6q6_0 asset_s6q6_1 asset_s6q6_2 asset_s6q6_3 asset_s6q6_4 asset_s6q6_5 asset_s6q6_6 asset_s6q6_7 asset_s6q6_8 asset_s6q6_9 asset_s6q6_10 asset_s6q6_11, pcf

predict asset_wealth_index
xtile asset_wealth_quintile = asset_wealth_index, nq(5)
tab asset_wealth_quintile
label define wealth 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest", replace
label values asset_wealth_quintile wealth

sum asset_wealth_quintile 

* histogram of wealth index 
histogram asset_wealth_index ,bin(30) frequency title("Distribution of Household Wealth Index") xtitle("Wealth Index") ytitle("Number of Households") lcolor(navy) fcolor(navy%60)
graph export "wealth_histogram.pdf", replace


//support from gov// 

* this was coded as binary (received/ not received) and a seperate variable for the amount. Firstly combine the two variables into one where non recipients are labelled as '.' and recipients have the monitary value listed. 

* BISP support 
gen bisp_support = .
replace bisp_support = 0 if s6q3a == 0
replace bisp_support = s6q3b if s6q3a == 1

* Zevar-e- Taleem support 
gen zevar_support = .
replace zevar_support = 0 if s6q4a == 0
replace zevar_support = s6q4b if s6q4a == 1

* Vaeela e Taleem support 
gen vaseela_support = .
replace vaseela_support = 0 if s6q5a == 0
replace vaseela_support = s6q5b if s6q5a == 1



//who takes care of the child ( newborn -5 years) during the day 
* combining all of these binary variables in to one categorical variable : note this formation assumes only one caregiver per day not multiple 

gen main_caregiver = .

replace main_caregiver = 1 if s1_1q8_1 == 1 // Mother
replace main_caregiver = 2 if s1_1q8_2 == 1 & missing(main_caregiver) // Father
replace main_caregiver = 3 if s1_1q8_3 == 1 & missing(main_caregiver) // Elder siblings
replace main_caregiver = 4 if s1_1q8_4 == 1 & missing(main_caregiver) // Daycare
replace main_caregiver = 5 if s1_1q8_5 == 1 & missing(main_caregiver) // Community center
replace main_caregiver = 6 if s1_1q8_6 == 1 & missing(main_caregiver) // Early childhood center
replace main_caregiver = 7 if s1_1q8_7 == 1 & missing(main_caregiver) // In school/kindergarten
replace main_caregiver = 88 if s1_1q8_88 == 1 & missing(main_caregiver) // Don't know
replace main_caregiver = 99 if s1_1q8_99 == 1 & missing(main_caregiver) // Refused
replace main_caregiver = 999 if s1_1q8_999 == 1 & missing(main_caregiver) // Any other

label define caregiver_lbl ///
1 "Mother" ///
2 "Father" ///
3 "Elder siblings" ///
4 "Daycare" ///
5 "Community center" ///
6 "Early childhood center" ///
7 "School/kindergarten" ///
88 "Don't know" ///
99 "Refused" ///
999 "Other"

label values main_caregiver caregiver_lbl


//how satisfied are you with your life these days// 
* this is seperated by gender and by region 

tab s1_1q11 resp_gender if region == "BWP"
tab s1_1q11 resp_gender if region == "BWN"
*bwp 
sum s1_1q11 if resp_gender == 0 & region == "BWP"
sum s1_1q11 if resp_gender == 1 & region == "BWP"

//how useful meeting// 
tab s1_1q12 resp_gender 


//main issue past six months 
tab main_issues_school_6_mo
tab  s2_1q13
tab s2_1q14 
tab s2_1q15
tab s2_1q16
tab s2_1q17
tab s2_1q18_999_desc 
tab s2_1q19_999_desc 
tab s2_1q20 
tab s2_1q22
tab s2_1q23

* exploring the 'other issue' in this variable 
label list problems

* any other issues = -999 - the variable that describes the 'other issue' is s2_1q12f_desc .
* However, the description variable is blank. 



//what type of action did you take in the past // 
gen action_taken = .

replace action_taken = 1 if s2_1q23b_1 == 1
replace action_taken = 2 if s2_1q23b_2 == 1 & missing(action_taken)
replace action_taken = 3 if s2_1q23b_3 == 1 & missing(action_taken)
replace action_taken = 4 if s2_1q23b_4 == 1 & missing(action_taken)
replace action_taken = 5 if s2_1q23b_5 == 1 & missing(action_taken)
replace action_taken = 6 if s2_1q23b_6 == 1 & missing(action_taken)
replace action_taken = 7 if s2_1q23b_7 == 1 & missing(action_taken)
replace action_taken = 8 if s2_1q23b_8 == 1 & missing(action_taken)
replace action_taken = 99 if s2_1q23b_999 == 1 & missing(action_taken)

label define action_lbl ///
1 "Protest" ///
2 "Posted on social media" ///
3 "Posted on portal" ///
4 "Contacted journalist" ///
5 "Petition/signatures" ///
6 "Letter/video message" ///
7 "Planned policy visit" ///
8 "Called policy actor" ///
99 "Other"

label values action_taken action_lbl
* who took action in the past six month 
tab take_action 

//who did you contact and how many hours did you spend// 
tab s2_2q1c_1 resp_gender 
tab s2_2q1c1_1 resp_gender 
tab s2_2q1c2_1 resp_gender 
tab issues_bureau_resolved resp_gender 
tab s2_2q1a_1 resp_gender 
tab burea_understands_needs resp_gender 

tab s2_2q1c_2 resp_gender 
tab s2_2q1c_2 resp_gender 
tab s2_2q1c1_2 resp_gender 
tab s2_2q1c2_2 resp_gender 
tab issue_politician_resolved resp_gender 
tab s2_2q1a_2 resp_gender 
tab politicians_understands_needs resp_gender 

//opinion//
tab s2_2q3

//last one week, gain info on politics and elections - how //
* this was made into one categorical variable  
gen info_source = .

replace info_source = 0 if s2_2q6_0 == 1
replace info_source = 1 if s2_2q6_1 == 1 & missing(info_source)
replace info_source = 2 if s2_2q6_2 == 1 & missing(info_source)
replace info_source = 3 if s2_2q6_3 == 1 & missing(info_source)
replace info_source = 4 if s2_2q6_4 == 1 & missing(info_source)
replace info_source = 5 if s2_2q6_5 == 1 & missing(info_source)
replace info_source = 6 if s2_2q6_6 == 1 & missing(info_source)
replace info_source = 7 if s2_2q6_7 == 1 & missing(info_source)
replace info_source = 8 if s2_2q6_8 == 1 & missing(info_source)
replace info_source = 9 if s2_2q6_9 == 1 & missing(info_source)
replace info_source = 10 if s2_2q6_10 == 1 & missing(info_source)
replace info_source = 11 if s2_2q6_11 == 1 & missing(info_source)

label define info_source_lbl ///
0 "None" ///
1 "ARY News" ///
2 "BOL News" ///
3 "GEO News" ///
4 "PTV News" ///
5 "Other News Channels" ///
6 "Newspaper/Books" ///
7 "Radio" ///
8 "YouTube" ///
9 "WhatsApp" ///
10 "Social Media Platforms" ///
11 "Family/Friends/Colleagues"

label values info_source info_source_lbl


//opinion on news channels // 
* gained information in the past week 
tab s2_2q6_11  

* each variableis ranked 1-5 so finding mean trustworthiness of each channel - exclude 'dont know' entries as it ruins the mean

foreach var in s2_2q7a s2_2q7b s2_2q7c s2_2q7d s2_2q7e ///
              s2_2q7f s2_2q7g s2_2q7h s2_2q7i s2_2q7j s2_2q7k {
    replace `var' = . if `var' == -88
}

foreach var in s2_2q7a s2_2q7b s2_2q7c s2_2q7d s2_2q7e s2_2q7f s2_2q7g s2_2q7h s2_2q7i s2_2q7j s2_2q7k {
    di "--------------------------------------------------"
    di "Tabulating `var' by resp_gender"
    tab `var' resp_gender, missing
}



//happy/angry with how things are going in the county// 
tab s2_2q8 resp_gender 
tab s2_2q9 resp_gender 


//how appropriate are interventions// 
tab s2_2q15a
tab s2_2q15b

//knowledge of current political appointment 
tab s3q1 resp_gender
tab s3q2 resp_gender 
tab s3q3 resp_gender
tab s3q3a resp_gender 
tab s3q4 resp_gender
tab s3q4a resp_gender 

//which apps have you used // 

*combining the binary app variables into a categorical variable 

gen main_app_used = ""

replace main_app_used = "WhatsApp" if s3q8_1 == 1
replace main_app_used = "Twitter"  if s3q8_2 == 1 & main_app_used == ""
replace main_app_used = "Facebook" if s3q8_3 == 1 & main_app_used == ""
replace main_app_used = "Instagram" if s3q8_4 == 1 & main_app_used == ""
replace main_app_used = "TikTok" if s3q8_5 == 1 & main_app_used == ""
replace main_app_used = "Snapchat" if s3q8_6 == 1 & main_app_used == ""
replace main_app_used = "Other" if s3q8_999 == 1 & main_app_used == ""
replace main_app_used = "Don't know" if s3q8_88 == 1 & main_app_used == ""
replace main_app_used = "Refused" if s3q8_99 == 1 & main_app_used == ""
replace main_app_used = "None" if s3q8_0 == 1 & main_app_used == ""

tab main_app_used resp_gender 
* this variable looks at whether or not any of these apps were used to follow or cotact a policy actor. 

tab s3q9 resp_gender 

//keeping track of childs education//
tab talk_to_teacher resp_gender 
tab s4q2 resp_gender
tab s4q3b resp_gender 


// contact distribution // 

* variable 'who_contact' was previously generated and combined all the variouse people contacted into one variable and assigned unique numbers for each person. First assign labels to the numbers and then tab by gender which gives an overview of the most frequently contacted per gender. 

label define contactlbl ///
    1 "Union councilor" ///
    2 "Religious leader" ///
    3 "NGO worker" ///
    4 "Govt agency" ///
    5 "Police" ///
    6 "Village leader" ///
    7 "Media" ///
    8 "Local party official" ///
    9 "MPA/MNA" ///
    10 "Head teacher" ///
    11 "School Council" ///
    12 "District Govt Rep" ///
    13 "Political party worker" ///
    14 "Community-based org" ///
    15 "Other" ///
    16 "Not specified"

tab who_contact resp_gender

*collapsing variable into top options 
label list who_contact_lbl
tab who_contact, missing

gen contact_group = .

* Politician
replace contact_group = 1 if inlist(who_contact, 2, 3, 5, 8)

* Local leader
replace contact_group = 2 if inlist(who_contact, 1, 6, 7, 9)

* Bureaucrat
replace contact_group = 3 if inlist(who_contact, 4, 11, 12, 13, 14, 10)

* Other
replace contact_group = 4 if inlist(who_contact, 15, 16, 17)

* Label groups
label define contact_group_lbl ///
    1 "Politician" ///
    2 "Local leader" ///
    3 "Bureaucrat" ///
    4 "Other"

label values contact_group contact_group_lbl


* next election voting plans 
replace s2_2q4d  = . if s2_2q4d == -999 
replace s2_2q4d  = . if s2_2q4d  == -99 
replace s2_2q4d = . if s2_2q4d  == -88 
tab s2_2q4d if resp_gender == 1 
tab s2_2q4d  if resp_gender == 0 






************************************************************
* Exporting summary stats and tables to Latex *
************************************************************

* Age
estpost summarize resp_age, detail
esttab using "demographics_age.tex", cells("count mean sd p50 p25 p75 min max") title("Demographics: Age") label nomtitle nonumber replace tex

* Respondent gender
estpost tabulate resp_gender
esttab using "demographics_gender.tex", cells("b(fmt(1))") title("Demographics: Gender (%)") label nomtitle nonumber replace tex

* Education
estpost tabulate highest_level_of_ed
esttab using "demographics_education.tex", cells("b(fmt(1))") title("Demographics: Education Level (%)") label nomtitle nonumber replace tex

* Quality of education
estpost summarize facility_index edu_quality_index, detail
esttab using "school_quality_1_4_part1.tex", cells("count mean sd p50 p25 p75 min max") label nomtitle nonumber title("1.4 Facility and Education Quality Index") replace tex

estpost tabulate smc_present
esttab using "school_quality_1_4_part2.tex", cells("b(fmt(0)) pct(fmt(1))") nonumber nomtitle noobs title("1.4 SMC Presence in Schools") replace tex

* Household size
estpost summarize s1_1q7, detail
esttab using "household_1_3.tex", cells("count mean sd p50 p25 p75 min max") label nomtitle nonumber title("1.3 Household Size: Children per Household") replace tex

* Talking about politics by gender
estpost tabulate s2_2q4e resp_gender
esttab using "talk_politics_by_gender_1_5.tex", cells("b(fmt(0)) colpct(fmt(1))") nonumber nomtitle noobs title("1.5 Talking About Politics with Friends by Gender") replace tex

* Female vote distribution
estpost tabulate s2_2q4b if resp_gender == 0
esttab using "vote_by_gender_female.tex", cells("b(fmt(1))") label nomtitle nonumber replace tex

* Male vote distribution
estpost tabulate s2_2q4b if resp_gender == 1
esttab using "vote_by_gender_male.tex", cells("b(fmt(1))") label nomtitle nonumber replace tex

* Confidence to influence government
estpost tabulate s5q1
esttab using "influence_government.tex", cells("b(fmt(0)) pct(fmt(1))") nonumber nomtitle noobs title("Confidence in Influencing Government") replace tex

* Bureaucrat understanding by gender
estpost tabulate burea_understands_needs resp_gender
esttab using "bureaucrat_understands_needs.tex", replace cells(b(fmt(0))) unstack noobs nonumber mtitles("Female" "Male" "Total") title("Bureaucrat Understands Needs by Gender") booktabs alignment(D{.}{.}{-1})

* Politician understanding by gender
estpost tabulate politicians_understands_needs resp_gender
esttab using "politician_understands_needs.tex", replace cells(b(fmt(0))) unstack noobs nonumber mtitles("Female" "Male" "Total") title("Politician Understands Needs by Gender") booktabs alignment(D{.}{.}{-1})

