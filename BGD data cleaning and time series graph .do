
//Per sector Time Series Min Wage Graph
clear 
* ── globals ──────────────────────────────────────────────────────────────────
global data    "/Users/sanaakashif/Downloads"
global output  "/Users/sanaakashif/Desktop/wb work "

//importing the data set into stata//

import excel "$data/BGD_sector_wage_final_updated-2.xlsx"

//renaming varibales to stata compatable format//

rename A wb_a3
rename B country_name
rename c date_start
rename D date_end
rename E confirmed_consecutive_change
rename F exact_date_or_approx
rename G industry
rename H worker_category
rename I work_day_duration
rename J work_week_duration
rename K currency_unit
rename L daily_rate
rename M monhtly_rate
rename N hourly_rate
rename O weekly_rate
rename P peice_rate
rename Q source
rename R notes
rename S still_enacted

rename date_start country
rename C date_start

sort industry date_start
//dropping rows where the numbers need to be manually checked and entered, they dissrupt analysis as they are empty values//
drop if strpos(notes, "needs manual entry") > 0
drop if strpos(notes, "NEEDS MANUAL ENTRY") > 0

//data cleaning//
//de stringing still_enacted so it becomes a binary//
replace still_enacted = "" if still_enacted == "still_enacted"
destring still_enacted, replace
rename monhtly_rate  monthly_rate
tab industry, sort
drop if industry == "industry"

//note garmet sector == garmet but broken down by levels of working. Garment is annual changes//


* clean monthly wage
destring monthly_rate, replace ignore(", BDT") force

* convert date
gen date2 = date(date_start, "DMY")
format date2 %td

drop date_start
rename date2 date_start

order wb_a3 country date_start date_end

* TOP five industries - looking at worker wages (over time)
// note: "Garmet sector" = garment broken down by grade levels (snapshot);
// "Garments Sector" = longitudinal worker/staff series used for time trends
// Industries with the most worker data points (≥3):
//   Garments Sector (4), Cold Storage (3), Fishing Trawler Industry (3),
//   Construction & Wood (3), Tannery (3)

* Workers only - all industries, grouped 6 per graph
preserve

keep if lower(trim(worker_category)) == "worker" & ///
	lower(trim(industry)) != "garmet sector"

* standardise industry name capitalisation to merge duplicates
replace industry = "Saw Mills" if lower(trim(industry)) == "saw mills"
replace industry = "Glass & Silicates" if lower(trim(industry)) == "glass and silicates" | lower(trim(industry)) == "glass & silicate"

* extend to 2025 for observations with no end date
gen date_end2 = date(date_end, "DMY")
format date_end2 %td
local today = date("31/12/2025", "DMY")

bysort industry (date_start): gen _last = (_n == _N)
expand 2 if _last & missing(date_end2), gen(_ext)
replace date_start = `today' if _ext
drop _last date_end2

* keep _ext as by-variable so it survives collapse
collapse (mean) monthly_rate, by(industry date_start _ext)
sort industry date_start

egen ind_id = group(industry)
quietly summarize ind_id
local n_inds = r(max)
local per_group = 6
local n_groups = int(ceil(`n_inds' / `per_group'))

forvalues g = 1/`n_groups' {
	display "Generating group `g' of `n_groups'..."
	local lo = (`g' - 1) * `per_group' + 1
	local hi = min(`g' * `per_group', `n_inds')
	local plots ""
	local leg   ""
	local k = 0
	forvalues i = `lo'/`hi' {
		local ++k
		levelsof industry if ind_id == `i', local(iname) clean
		* line draws through all points including 2025 extension; scatter only on real points
		local plots `"`plots'(line monthly_rate date_start if ind_id==`i', pstyle(p`k') lwidth(medthick)) (scatter monthly_rate date_start if ind_id==`i' & _ext==0, pstyle(p`k') msize(small)) "'
		local line_pos = 2 * `k' - 1
		local leg `"`leg'`line_pos' `"`iname'"' "'
	}
	twoway `plots', ///
		legend(order(`leg') size(small) cols(1)) ///
		xtitle("Year") ///
		ytitle("Monthly Minimum Wage (BDT)") ///
		title("Minimum Wages by Sector (Group `g' of `n_groups')") ///
		subtitle("Bangladesh - Workers") ///
		xlabel(, format(%tdCCYY)) ///
		ylabel(#5, labsize(small) angle(horizontal)) ///
		name(workers_group`g', replace)
	graph export "$output/bgd_workers_group`g'.png", name(workers_group`g') replace
}

restore
//point of note: garment sector has the most variation. Each increase can be pinned to a large shift nationally. 2013 spike was due toe Rana Plaza collapse wage increase and collapse in 2020 was due to covid. 2023 increase was following violent national protests// 

// note : salt crushing is not included in the graphs because for worker wages, it is a daily rate ( uncertain whether they work four full weeks out of the month )//


//2022 has the most baseline - Security Services, Saw Mills, Fishery Trawler , Shrimp Processing, Printing Press, Jute Mills//

// 2020 has the seoncd most - plastic, leather, rice, re rolling mills, private road stransoir, iron ofundry 
