* purpose
* hh dataset labeling 

* PN_HH_Survey_FINAL

lab var svy_date "survey date"
lab var starttime "start time"
lab var endtime "end time"
lab var cluster_cat "Cluster type"
lab var geo_town "Township Name"
lab var geo_vt "Village tract name"
lab var geo_vill "Village name"
lab var org_team "Organization name"
lab var svy_team "Survey Team Number. "
lab var superv_name "Supervisor Name"
lab var interv_name "Interviewer Name"
lab var intrv_date "Interview date"
lab var quest_num "Questionnaires No."
lab var respd_id "Respondent ID"
lab var will_participate "Do you understand these conditions and are you still willing to participate?"
lab var respd_who "Who is the main respondent of this questionnaires, mothers (herself) or main caregiver of the children?"
lab var respd_name "Respondent's name "
lab var respd_sex "Respondent's sex"
lab var respd_age "Respondent's age (in years) "
lab var respd_status "What is your marital status?"
lab var respd_preg "Are you pregnant now? "
lab var respd_child "Do you have children?"
lab var respd_1stpreg_age "Maternal age at 1st time pregnancy"
lab var respd_chid_num "If Yes, how many children do you have?"
lab var respd_phone "Is there any phone number we can reach you at? "
lab var respd_phonnum "If yes, please record the phone number."
lab var hh_tot_num "Total number of HH members:"
lab var hhmem_flag "Total HH member (${hh_tot_num}) is less than number of respondent ${respd_name} children (${respd_chid_num})"
lab var u5_num_flag "Mothers from the HH roster report they have total (${calc_u5report_num}) U5 (0-4 years) children, but only (${cal_list_u5all_tot}) U5 children were listed in the roster."
lab var u2_num_flag "Mothers from the HH roster report they have total ${calc_u2child_num} U2 (0-1 years) children, but only (${cal_list_u2_tot}) U2 children were listed in the roster."
lab var u3to5_num_flag "Mothers from the HH roster report they have total ${calc_u5child_num} (2-4 years) children, but only (${cal_list_u3_5_tot}) 2 to 4 children were listed in the roster."
lab var u5_num_flag_check "Does it mean the mothers of some children from the household members list were not from this household? "
lab var u5_num_flag_check1 "Does it mean the mothers of some children from the household members list were not from this household? "
lab var u5_num_flag_check0 "Does it mean the mothers of some children from the household members list were not from this household? "
lab var hh_child_nomom "Who are those children?"
lab var hh_head_more_flag "This household has more than one hosuehold head (${cal_hh_head}), please go back and check."
lab var hh_head_no_flag "This household did not have any hosuehold head, please go back and check."
lab var resp_child_flag_why "Respondent (${respd_name}) report she has ${respd_chid_num} children. And, in the rooster, she reported ${cal_resp_u3_5} number of U3 to 5 children and ${cal_resp_u2} number of U2 children. Which is less then the number of children she report. Is it because some of her children were 5 years or older (Or) not part of this household?"
lab var resp_child_flag_why1 "Respondent (${respd_name}) report she has ${respd_chid_num} children. And, in the rooster, she reported ${cal_resp_u3_5} number of U3 to 5 children and ${cal_resp_u2} number of U2 children. Which is less then the number of children she report. Is it because some of her children were 5 years or older (Or) not part of this household?"
lab var resp_child_flag_why2 "Respondent (${respd_name}) report she has ${respd_chid_num} children. And, in the rooster, she reported ${cal_resp_u3_5} number of U3 to 5 children and ${cal_resp_u2} number of U2 children. Which is less then the number of children she report. Is it because some of her children were 5 years or older (Or) not part of this household?"
lab var resp_child_flag_why888 "Respondent (${respd_name}) report she has ${respd_chid_num} children. And, in the rooster, she reported ${cal_resp_u3_5} number of U3 to 5 children and ${cal_resp_u2} number of U2 children. Which is less then the number of children she report. Is it because some of her children were 5 years or older (Or) not part of this household?"
lab var resp_child_flag_oth "Please specify other reason."
lab var mom_covid "Did you (${respd_name}) get Covid-19 vaccination?"
lab var mom_covid_doses "If yes, how many doses did you (${respd_name}) get Covid-19 vaccination?"
lab var house_roof "What is the predominant roof material of the main dwelling unit?"
lab var house_roof_oth "Other (specify)"
lab var house_wall "What is the predominant wall material of the main dwelling unit?"
lab var house_wall_oth "Other (specify)"
lab var house_floor "What is the predominant floor material of the main dwelling unit?"
lab var house_floor_oth "Other (specify)"
lab var house_room "How many rooms does your house have?"
lab var house_light "What is your source of light at night?"
lab var house_light1 "Electricity (government/public)"
lab var house_light2 "Private Generator"
lab var house_light3 "Solar Panels"
lab var house_light4 "Kerosene/Candles"
lab var house_light666 "REFUSED TO ANSWER"
lab var house_light888 "OTHER, SPECIFY"
lab var house_light999 "DO NOT KNOW"
lab var house_light_oth "Other (specify)"
lab var house_electric "Does your house have electricity?"
lab var house_electric_check "Does it mean your house has electricity (at G.10), but your household is not used them as the main source of light at night (at G.8)?"
lab var house_electric_perday "How long do you have electricity per day?"
lab var house_electric_source "What is the source of electricity?"
lab var house_electric_perday_oth "Other (specify) - have electricity per day"
lab var house_electric_oth "Other (specify) - source of electricity"
lab var house_cooking "What is your main source of cooking fuel?"
lab var house_cooking_oth "Other (specify)"
lab var hhitems_tv "Television"
lab var hhitems_phone "Mobile phone"
lab var hhitems_refrigerator "Refrigerator"
lab var hhitems_table "Table"
lab var hhitems_chair "Chair"
lab var hhitems_bed "Bed"
lab var hhitems_cupboard "Cupboard"
lab var hhitems_fan "Electric fan"
lab var hhitems_computer "Computer"
lab var hhitems_watch "Does any member of your household own a watch?"
lab var hhitems_bankacc "Does any member of your household have a bank account?"
lab var hhitems_check "Does it mean the household has none of the items listed before?"
lab var wempo_childcare "Who in the household is involved in decisionmaking about feeding the child/ren on a daily basis?"
lab var wempo_mom_health "Who is the primary decision maker for maternal health in your household?"
lab var wempo_child_health "Who is the primary decision maker for child health in your household?"
lab var wempo_women_wages "In the household, who has control over the woman's earnings?"
lab var wempo_major_purchase "Who makes decisions about major household purchases?"
lab var wempo_visiting "Who makes decisions about visits to family or relatives?"
lab var wempo_women_health "Who is the primary decision maker about the woman's health care?"
lab var wempo_child_wellbeing "Who is the primary decision maker about the well-being of children in the household?"
lab var wempo_group "Are you an active member of the following groups? (Check all that apply.)"
lab var wempo_group1 "None"
lab var wempo_group2 "Religious group"
lab var wempo_group3 "Mother's support group"
lab var wempo_group4 "Community development group"
lab var wempo_group5 "Village savings and loan group"
lab var wempo_group888 "Other"
lab var wempo_group777 "Don't know/Don't remember"
lab var wempo_group999 "Refused"
lab var phq9_1 "Little interest or pleasure in doing things"
lab var phq9_2 "Feeling down, depressed or hopeless"
lab var phq9_3 "Trouble falling asleep, staying asleep, or sleeping too much"
lab var phq9_4 "Feeling tired or having little energy"
lab var phq9_5 "Poor appetite or overeating"
lab var phq9_6 "Feeling bad about yourself - or that you're a failure or have let yourself or your family down"
lab var phq9_7 "Trouble concentrating on things, such as reading the newspaper or watching television"
lab var phq9_8 "Moving or speaking so slowly that other people could have noticed. Or, the opposite - being so fidgety or restless that you have been moving around a lot more than usual"
lab var phq9_9 "Thoughts that you would be better off dead or of hurting yourself in some way"
lab var water_sum "Summer"
lab var water_time "Travel time to collect drinking water from the [${cal_water_source1}]."
lab var water_sum_treat "Do you treat your water in any way to make it safer to drink?"
lab var water_sum_treatmethod "What do you usually do to the water to make it safer to drink? Record all items mentioned."
lab var water_sum_treatmethod1 "Boil"
lab var water_sum_treatmethod2 "Add bleach/chlorine"
lab var water_sum_treatmethod3 "Add iodine"
lab var water_sum_treatmethod4 "Strain it through a cloth"
lab var water_sum_treatmethod5 "Use a water filter (ceramic, sand, etc.)"
lab var water_sum_treatmethod6 "Composite filters - a combination of ceramic, sand, charcoal, pebbles etc."
lab var water_sum_treatmethod7 "Solar disinfection"
lab var water_sum_treatmethod8 "Let it stand and settle"
lab var water_sum_treatmethod888 "Others (specify)"
lab var water_sum_oth "Main source of drinking-water other specify"
lab var water_sum_treatmethod_oth "Water treatment method other specify"
lab var water_rain "Rainy"
lab var water_time_rain "Travel time to collect drinking water from the [${cal_water_source2}]."
lab var water_rain_treat "Do you treat your water in any way to make it safer to drink?"
lab var water_rain_treatmethod "What do you usually do to the water to make it safer to drink? Record all items mentioned."
lab var water_rain_treatmethod1 "Boil"
lab var water_rain_treatmethod2 "Add bleach/chlorine"
lab var water_rain_treatmethod3 "Add iodine"
lab var water_rain_treatmethod4 "Strain it through a cloth"
lab var water_rain_treatmethod5 "Use a water filter (ceramic, sand, etc.)"
lab var water_rain_treatmethod6 "Composite filters - a combination of ceramic, sand, charcoal, pebbles etc."
lab var water_rain_treatmethod7 "Solar disinfection"
lab var water_rain_treatmethod8 "Let it stand and settle"
lab var water_rain_treatmethod888 "Others (specify)"
lab var water_rain_oth "Main source of drinking-water other specify"
lab var water_rain_treatmethod_oth "Water treatment method other specify"
lab var water_winter "Winter"
lab var water_time_winter "Travel time to collect drinking water from the [${cal_water_source3}]."
lab var water_winter_treat "Do you treat your water in any way to make it safer to drink?"
lab var water_winter_treatmethod "What do you usually do to the water to make it safer to drink? Record all items mentioned."
lab var water_winter_treatmethod1 "Boil"
lab var water_winter_treatmethod2 "Add bleach/chlorine"
lab var water_winter_treatmethod3 "Add iodine"
lab var water_winter_treatmethod4 "Strain it through a cloth"
lab var water_winter_treatmethod5 "Use a water filter (ceramic, sand, etc.)"
lab var water_winter_treatmethod6 "Composite filters - a combination of ceramic, sand, charcoal, pebbles etc."
lab var water_winter_treatmethod7 "Solar disinfection"
lab var water_winter_treatmethod8 "Let it stand and settle"
lab var water_winter_treatmethod888 "Others (specify)"
lab var water_winter_oth "Main source of drinking-water other specify"
lab var water_winter_treatmethod_oth "Water treatment method other specify"
lab var waterpot_yn "Do you have water pot/container for water storage? (for drinking water)"
lab var waterpot_capacity "Capacity of storage pots (for drinking water)"
lab var waterpot_condition "Water storage condition (for drinking water)"
lab var waterpot_condition1 "The drinking water pot/container is clean"
lab var waterpot_condition2 "The drinking water pot/container is covered"
lab var waterpot_condition3 "The pot has clean cup with handle"
lab var waterpot_condition4 "Not meet any of the above conditions"
lab var waterpot_condition0 "Not allow to observe the drinking water pot/container"
lab var latrine_type "What is the main type of latrine used by your household?"
lab var latrine_type_oth "Other (specify)"
lab var latrine_share "Is your main latrine/toilet shared with other households?"
lab var latrine_observe "Could I see the main type of latrine/toilet used by your household?"
lab var soap_yn "Do you ever use soap to wash your hands?"
lab var soap_why "Why do you not use soap to wash your hands?"
lab var soap_why1 "Financial difficulties to buy soap"
lab var soap_why2 "Soap is not available"
lab var soap_why3 "I don't think it is important"
lab var soap_why888 "Other (specify)"
lab var soap_why666 "Refuse to answer"
lab var soap_why999 "Don't know"
lab var soap_why_oth "Other (specify)"
lab var soap_tiolet "After using toilet?"
lab var soap_before_eat "Before eating?"
lab var soap_after_eat "After eating?"
lab var soap_handle_child "Before or after handling children?"
lab var soap_before_cook "Before cooking/preparing food?"
lab var soap_feed_child "Before feeding children?"
lab var soap_clean_baby "After cleaning baby?"
lab var soap_child_faeces "After disposing of child faeces?"
lab var observ_washplace "Can you please show me where members of your household most often wash their hands?"
lab var observ_washplace0 "Not observed"
lab var observ_washplace1 "Observed sink/tap in dwelling"
lab var observ_washplace2 "Observed sink/tap in yard/plot"
lab var observ_washplace3 "Mobile facility observed (bucket/jug/kettle)"
lab var observ_washplace4 "No handwashing place in dwelling/yard/plot"
lab var observ_washplace888 "Other (specify)"
lab var observ_water "Observe presence of water for handwashing"
lab var soap_present "Is soap present at the place for handwashing?"
lab var observ_washplace_oth "Other (specify)"
lab var md_intro "READ TO THE RESPONDENT: Next, I would like to ask you some information about recent changes in your income sources. "
lab var d0_per_std "Please imagine a ladder with steps numbered from zero at the bottom to ten at the top. Suppose we say that the top of the ladder represents the best possible life for you and the bottom of the ladder represents the worst possible life for you. If the top step is 10 and the bottom step is 0, on which step of the ladder do you feel you personally stand at the present time?"
lab var d3_inc_lmth "What is your household's total income in the last 30 days. (MMK) (Now what I want to think about all forms of income you received in the last month from all sources, including food or cash transfers and remittances. )"
lab var d4_inc_status "Was your income in the last month lower than it usually is at this time of the year?"
lab var d5_reason "List the reasons for the changes in your household's income now?"
lab var d5_reason1 "Could not work due to travel/movement restrictions"
lab var d5_reason2 "Unsafe to go to work (or agricultural fields) "
lab var d5_reason3 "Disruptions in markets (not able to sell products or buy inputs)"
lab var d5_reason4 "Lower prices for products"
lab var d5_reason5 "Less customers/clients"
lab var d5_reason6 "Declining in agricultural yield"
lab var d5_reason7 "Job changes"
lab var d5_reason8 "Loss of employment (or had to close shop/business)"
lab var d5_reason9 "Reduced salary/wage"
lab var d5_reason10 "Daily labor opportunities reduced"
lab var d5_reason11 "Support/assistance has been reduced"
lab var d5_reason12 "Less remittances from household members overseas or elsewhere in Myanmar"
lab var d5_reason13 "Problems in accessing banking or finance"
lab var d5_reason14 "The livestockes have not been sold out."
lab var d5_reason15 "Pregnancy, childbirth, childcare"
lab var d5_reason16 "Health condition of household member"
lab var d5_reason17 "My spouse passed away"
lab var d5_reason18 "My spouse was detained."
lab var d5_reason99 "Other (specify)_____________"
lab var d5_reason_oth "Other - specify "
lab var d6_cope "How did your household cope with this income loss (Main)?"
lab var d6_cope1 "Used bank savings"
lab var d6_cope2 "Used cash savings"
lab var d6_cope3 "Reduced non-food consumption/expenditure"
lab var d6_cope4 "Reduced food consumption"
lab var d6_cope5 "Borrowed money"
lab var d6_cope6 "Bought food and/or household necessities on credit "
lab var d6_cope7 "Sold off assets (e.g., jewellery, mobile, furniture) "
lab var d6_cope8 "Did nothing"
lab var d6_cope9 "Reduced savings"
lab var d6_cope10 "Taking collateral loan"
lab var d6_cope11 "Requesting provision from parents (or) relatives"
lab var d6_cope12 "Taking the cash advance from the work"
lab var d6_cope13 "Relying on the compensation from the losing job"
lab var d6_cope14 "Street vendors"
lab var d6_cope15 "Causal worker"
lab var d6_cope16 "Fishing"
lab var d6_cope17 "Hunting"
lab var d6_cope18 "collection of wild fruit/vegetables"
lab var d6_cope19 "Relying on the donation of employers"
lab var d6_cope20 "Donations from charities, monasteries, or other institutions"
lab var d6_cope99 "Other (Specify)"
lab var d6_cope_oth "Other - specify "
lab var jan_incom_status "Compared to before February 2021 how has your household's monthly income changed?"
lab var thistime_incom_status "Compared to this time last year, how has your household's monthly income changed?"
lab var d7_inc_govngo "Did your household receive any regular income from government/or other NGO programs in the past month?"
lab var d7_inc_govngo_nm "If yes, please specify the name of organization or institution supporting this regular income."
lab var d7_inc_govngo_nm1 "Gov: Retirement pension"
lab var d7_inc_govngo_nm2 "Gov: MCCT"
lab var d7_inc_govngo_nm3 "Gov: Older age pension"
lab var d7_inc_govngo_nm4 "Gov: Disable pension"
lab var d7_inc_govngo_nm5 "Charity organizations"
lab var d7_inc_govngo_nm98 "don't know"
lab var d7_inc_govngo_nm99 "Other (specify)"
lab var d7_inc_govngo_nm_oth "Other - specify "
lab var health_visit "Has anyone from your household used medical services (both formal or informal) over the last 12 months? "
lab var health_exp "If yes, was any of the costs associated with those usages?"
lab var health_exp_cope "If yes, did the cost requires you (your HH) to take any of the following coping mechanisms?"
lab var health_exp_cope1 "Used bank savings"
lab var health_exp_cope2 "Used cash savings"
lab var health_exp_cope3 "Reduced non-food consumption/expenditure"
lab var health_exp_cope4 "Reduced food consumption"
lab var health_exp_cope5 "Borrowed money"
lab var health_exp_cope6 "Sold off assets (e.g., jewellery, mobile, furniture) "
lab var health_exp_cope7 "Did nothing, although it was required"
lab var health_exp_cope8 "Did nothing, because it was not required"
lab var health_exp_cope9 "Reduced savings"
lab var health_exp_cope10 "Taking collateral loan"
lab var health_exp_cope11 "Requesting provision from parents (or) relatives"
lab var health_exp_cope12 "Taking the cash advance from the work"
lab var health_exp_cope13 "Relying on the donation of employers"
lab var health_exp_cope14 "Donations from charities, monasteries, or other institutions"
lab var health_exp_cope888 "Other (specify)"
lab var health_exp_cope666 "Refused"
lab var health_exp_cope_oth "Please specify other coping mechanism."
lab var gfi2_unhnut "gfi-2.Still thinking about the last 30 days, was there a time when you or others in your household were unable to eat healthy and nutritious food because of a lack of money or other resources?"
lab var gfi3_fewfd "gfi-3.Was there a time when you or others in your household ate only a few kinds of foods because of a lack of money or other resources?"
lab var gfi4_skp_ml "gfi-4.Was there a time when you or others in your household had to skip a meal because there was not enough money or other resources to get food?"
lab var gfi5_less "gfi-5.Still thinking about the last 30 days, was there a time when you or others in your household ate less than you thought you should because of a lack of money or other resources?"
lab var gfi6_rout_fd "gfi-6.Was there a time when your household ran out of food because of a lack of money or other resources?"
lab var gfi7_hunger "gfi-7.Was there a time when you or others in your household were hungry but did not eat because there was not enough money or other resources for food?"
lab var gfi8_wout_eat "gfi-8.Was there a time when you or others in your household went without eating for a whole day because of a lack of money or other resources?"
lab var prgexpo_pn "Do you know Project Nourish?"
lab var prgexpo_join "If yes, have you ever participated (benefited from) in the following activities implemented by Project Nourish?"
lab var prgexpo_join1 "Food support to Covid-19 patients"
lab var prgexpo_join2 "Covid-19 kits distribution"
lab var prgexpo_join3 "Food basket/Cash for food."
lab var prgexpo_join4 "WASH infrastructure support "
lab var prgexpo_join5 "SBCC session (nutrition promotion, hygiene and environmental sanitation, cooking demonstration, cooking training) "
lab var prgexpo_join6 "Mother support group"
lab var prgexpo_join7 "Home gardening"
lab var prgexpo_join8 "MUAC screening"
lab var prgexpo_join0 "Don't Know "
lab var prgexpo_join888 "Other (specify)"
lab var prgexpo_join_oth "Others Specify"
lab var prgexp_freq_1 "How many times do you participate in the [Food support to Covid-19 patients]?"
lab var prgexp_monthly_1 "Does it usually happen in your village (every month)?"
lab var prgexp_why_1 "If not, why does it not occur/organise every month? "
lab var prgexp_why_11 "It is not designed to implement a monthly basis. "
lab var prgexp_why_12 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_13 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_1888 "Other (specify)  "
lab var prgexp_why_oth_1 "Others Specify"
lab var prgexp_freq_2 "How many times do you participate in the [Covid-19 kits distribution]?"
lab var prgexp_monthly_2 "Does it usually happen in your village (every month)?"
lab var prgexp_why_2 "If not, why does it not occur/organise every month? "
lab var prgexp_why_21 "It is not designed to implement a monthly basis. "
lab var prgexp_why_22 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_23 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_2888 "Other (specify)  "
lab var prgexp_why_oth_2 "Others Specify"
lab var prgexp_freq_3 "How many times do you participate in the [Food basket/Cash for food]?"
lab var prgexp_monthly_3 "Does it usually happen in your village (every month)?"
lab var prgexp_why_3 "If not, why does it not occur/organise every month? "
lab var prgexp_why_31 "It is not designed to implement a monthly basis. "
lab var prgexp_why_32 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_33 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_3888 "Other (specify)  "
lab var prgexp_why_oth_3 "Others Specify"
lab var prgexp_freq_4 "How many times do you participate in the [WASH infrastructure support]?"
lab var prgexp_monthly_4 "Does it usually happen in your village (every month)?"
lab var prgexp_why_4 "If not, why does it not occur/organise every month? "
lab var prgexp_why_41 "It is not designed to implement a monthly basis. "
lab var prgexp_why_42 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_43 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_4888 "Other (specify)  "
lab var prgexp_why_oth_4 "Others Specify"
lab var prgexp_freq_5 "How many times do you participate in the [SBCC session (nutrition promotion, hygiene and environmental sanitation, cooking demonstration, cooking training)]?"
lab var prgexp_monthly_5 "Does it usually happen in your village (every month)?"
lab var prgexp_why_5 "If not, why does it not occur/organise every month? "
lab var prgexp_why_51 "It is not designed to implement a monthly basis. "
lab var prgexp_why_52 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_53 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_5888 "Other (specify)  "
lab var prgexp_why_oth_5 "Others Specify"
lab var prgexp_freq_6 "How many times do you participate in the [Mother support group]?"
lab var prgexp_monthly_6 "Does it usually happen in your village (every month)?"
lab var prgexp_why_6 "If not, why does it not occur/organise every month? "
lab var prgexp_why_61 "It is not designed to implement a monthly basis. "
lab var prgexp_why_62 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_63 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_6888 "Other (specify)  "
lab var prgexp_why_oth_6 "Others Specify"
lab var prgexp_freq_7 "How many times do you participate in the [Home gardening]?"
lab var prgexp_monthly_7 "Does it usually happen in your village (every month)?"
lab var prgexp_why_7 "If not, why does it not occur/organise every month? "
lab var prgexp_why_71 "It is not designed to implement a monthly basis. "
lab var prgexp_why_72 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_73 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_7888 "Other (specify)  "
lab var prgexp_why_oth_7 "Others Specify"
lab var prgexp_freq_8 "How many times do you participate in the [MUAC screening]?"
lab var prgexp_monthly_8 "Does it usually happen in your village (every month)?"
lab var prgexp_why_8 "If not, why does it not occur/organise every month? "
lab var prgexp_why_81 "It is not designed to implement a monthly basis. "
lab var prgexp_why_82 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_83 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_8888 "Other (specify)  "
lab var prgexp_why_oth_8 "Others Specify"
lab var prgexp_freq_9 "How many times do you participate in the [${prgexpo_join_oth}]?"
lab var prgexp_monthly_9 "Does it usually happen in your village (every month)?"
lab var prgexp_why_9 "If not, why does it not occur/organise every month? "
lab var prgexp_why_91 "It is not designed to implement a monthly basis. "
lab var prgexp_why_92 "Project staff cannot travel to the village for non-security-related reasons. "
lab var prgexp_why_93 "Project staff cannot travel to the village for security-related reasons."
lab var prgexp_why_9888 "Other (specify)  "
lab var prgexp_why_oth_9 "Others Specify"
lab var prgexp_iec "Did you see this IEC material before (for posters and billboards)? "
lab var prgexp_iec1 "Stunting infograph"
lab var prgexp_iec2 "Wasting infograph"
lab var prgexp_iec3 "Low-birth-weight infograph"
lab var prgexp_iec4 "Anaemia infograph"
lab var prgexp_iec5 "Breastfeeding infograph"
lab var prgexp_iec6 "IYCF poster"
lab var prgexp_iec7 "Power of 1000 days infograph"
lab var prgexp_iec0 "Never seem those items before"
lab var svy_visit_num "Number of visit to this household to finish survey"
lab var svy_interview_mode "Mode of interview"
lab var enu_svyend_note "Enumerator note (at the end of survye)"
lab var submission_time "submission time"
lab var submitted_by "Submitted by (user account)"
lab var org_name "Organization name"
lab var township_name "Township Name"
lab var geo_eho_vt_name "EHO Village Tract Name"
lab var geo_eho_vill_name "EHO Village Name"
lab var stratum "Stratum"
lab var num_cluster "Cluster number"
lab var vill_samplesize "Village Sample size"
lab var sample_check "Sample Check (enough U5 or not)"
lab var township_name "Township Name"
lab var geo_eho_vt_name "EHO Village Tract Name"
lab var cluster_cat_str "Cluster type"
lab var geo_eho_vill_name "EHO Village Name"
lab var stratum "Stratum"
lab var num_cluster "Cluster number"
lab var vill_samplesize "Village Sample size"
lab var sample_check "Sample Check (enough U5 or not)"
