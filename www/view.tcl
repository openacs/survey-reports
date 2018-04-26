# packages/survey/www/views/view.tcl

ad_page_contract {
    
    
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 83ec419b-54be-454f-9432-ffb15586332b
    @cvs-id $Id$
} {
    template_item
    survey_id
    {rtf "f"}
} -properties {
} -validate {
} -errors {
}

set user_id [auth::require_login]
set package_id [ad_conn package_id]

array set item $template_item
set item_id $item(item_id)

# Roel 03/25, Prevent barfing when the report isn't live
if { [empty_string_p [item::get_live_revision $item_id]] } {
    ad_return_complaint "Page Not Available" "This page is not currently live."
    ad_script_abort
}

if {[array size item] == 0} {
    ns_returnnotfound
}

acs_user::get -user_id $user_id -array user
set username $user(username)
set first_names $user(first_names)
set last_name $user(last_name)
set full_name $user(name)
set email $user(email)
set url $user(url)
set screen_name $user(screen_name)
set current_date [ns_fmttime [ns_time] "%B %e, %Y"]

set var_names {}

set used_list {}
set orig_survey_id $survey_id

db_multirow surveys_used surveys_used {
    select s.survey_id,
    s.name as survey_name
    from surveys s,
    survey_reports_survey_map m
    where m.template_id = :item_id
    and m.survey_id = s.survey_id
    and m.survey_variables_p = 't'
} {
    lappend used_list $survey_id
}

foreach one_survey_id $used_list {
    db_0or1row last_response {
        select response_id, 
        to_char(creation_date,'Month DD, YYYY') as response_date from survey_responses,
        acs_objects
        where response_id = object_id
        and creation_user = :user_id
        and survey_id=:one_survey_id
        order by creation_date DESC
        LIMIT 1
    }

    if { ![exists_and_not_null response_id] } {
        #Has not yet taken the survey. Send the user to the survey
#        ad_returnredirect "../respond?survey_id=$survey_id&return_url=reports/"
	set return_url [ad_return_url]
	ad_returnredirect [export_vars -base "need-respond" {survey_id return_url}]
        ad_script_abort
    }

    ad_require_permission $response_id read

    #Set all the variables.
    set duplicate_pretty_ids [db_list duplicate_pretty_ids {
        select distinct(q1.pretty_id)
        from survey_questions q1 
        right outer join survey_sections s 
        on q1.section_id = s.section_id
        where survey_id = :one_survey_id
        and 1 < (select count(*) 
                 from survey_questions q2 
                 right outer join survey_sections s 
                 on q2.section_id = s.section_id
                 where survey_id = :one_survey_id
                 and q2.pretty_id = q1.pretty_id)
    }]

    # get all the questions and make variables for them based on their pretty_ids
    db_foreach survey_questions {      
        select s.name as name, 
        question_id, 
        question_text, 
        presentation_type, 
        sort_order, 
        active_p,
        required_p,
        abstract_data_type,
        s.section_id as section_id,
        branch_p,
	(select 1 from survey_question_choices sqc where sqc.question_id=q.question_id and numeric_value is not null limit 1) as median_p,
        coalesce(q.pretty_id,(question_id::varchar)) as question_pretty_id,
        coalesce(s.pretty_id,(s.section_id::varchar)) as section_pretty_id
        from survey_questions q right outer join survey_sections s
        on (q.section_id = s.section_id)
        where survey_id=:one_survey_id
        and abstract_data_type in ('text','shorttext','boolean','number','integer','choice')
        order by s.sort_key,s.section_id, sort_order} {
            # The goal of this section is to list for the user all the 
            # variables he has available when he makes his template and the possible answers.

	    #I'm being lazy here and not getting the responses at the same time I get all the questions.
	    #For now I'm not expecting a preformance issue but this may need to be rewritten at some time.
	    #If you ever do rewrite it remember to set unanswered questions to empty string.
            set full_id [util_text_to_url -replacement _ -text "${section_pretty_id}_${question_pretty_id}"]
            set full_section_id [util_text_to_url -replacement _ -text "${section_pretty_id}"]
            lappend var_names $full_id
	    # Compute total points for multiple choice questions
	    # KSG Ticket #341
	    if { [lsearch $var_names ${full_section_id}_total] == -1 } {
		set ${full_section_id}_total 0
		lappend var_names ${full_section_id}_total
	    }
            
            ns_log debug "\n-----\nDB full_id '${full_id}' \n ---- \n"
            switch $abstract_data_type {
                "choice" {
                    set answer [db_list choice_answer {
                        select label 
                        from survey_question_choices c, 
                        survey_question_responses r
                        where r.choice_id = c.choice_id
                        and r.response_id = :response_id
                        and r.question_id = :question_id
                        and c.question_id = :question_id
                    }]
                    
                    set ctr 0
                    foreach one_label $answer {
                        incr ctr
                        set ${full_id}_choice_${ctr} "$one_label"
                        lappend var_names ${full_id}_choice_${ctr}
                    }
                    
                    db_foreach get_counts "select sqc.sort_order,tr.total_responses, count(sqr.choice_id) as choice_count, to_char(((count(sqr.choice_id) / tr.total_responses :: float) * 100), '999.99%') as p ,sqc.choice_id, sqc.label, sqc.numeric_value from (select count(*) as total_responses from survey_question_responses where question_id=:question_id) as tr, survey_question_choices sqc left join survey_question_responses sqr on sqc.choice_id=sqr.choice_id where sqc.question_id=:question_id group by sqc.choice_id, sqc.label, sqc.numeric_value, sqc.sort_order,  tr.total_responses order by sqc.sort_order" {
                        set ${full_id}_cid_${choice_id}_percent "${p}"
			set ${full_id}_cid_${sort_order}_percent "${p}"
                        set ${full_id}_cid_${choice_id}_label "${label}"
                        set ${full_id}_cid_${sort_order}_label "${label}"
                        lappend var_names "${full_id}_cid_${choice_id}_percent"
                        lappend var_names "${full_id}_cid_${choice_id}_label"
                        lappend var_names "${full_id}_cid_${sort_order}_percent"
                        lappend var_names "${full_id}_cid_${sort_order}_label"
                    }

                    set ${full_id}_cp ""
		    set ${full_id}_c ""
		    set ${full_id}_d ""
		    set ${full_id}_mean ""
		    set ${full_id}_qt $question_text
		    lappend var_names "${full_id}_qt"
                    if {[llength $answer] == 1} {
                        set answer [lindex $answer 0]
                        # DAVEB add median support to report
                        #                       ns_log debug "\n-----\nDB Choice Question full_id '${full_id}' \n ---- \n"
                        set ${full_id}_the_choice [db_string get_c "select sqc.numeric_value from survey_question_responses sqr, survey_question_choices sqc where sqc.question_id=:question_id and sqr.choice_id=sqc.choice_id and sqr.question_id=:question_id and sqr.response_id=:response_id"]
                        set stats [db_list get_stats "select sqc.numeric_value from survey_question_responses sqr , survey_question_choices sqc where sqr.question_id=:question_id and sqc.question_id=:question_id and sqr.choice_id=sqc.choice_id"]
                        ns_log debug "\n------\nDAVEB Debugging survey/www/reports/index.tcl\nquestion_id='${question_id}'\nstats='${stats}'\n-----\n"
                        if {![string equal "" [set ${full_id}_the_choice]]} {
                            #                            ns_log debug "\n-----\nDB median '${full_id}_median' \n ---- \n"
                            set ${full_id}_median [format %0.2f [expr 1.0 * [math::statistics::BasicStats mean $stats]]]
                            lappend var_names ${full_id}_median
                            set ${full_id}_numeric_value [set ${full_id}_the_choice]
                            lappend var_names ${full_id}_numeric_value
                        }
                        set mode_values ""
                        set mode_choice_ids ""
                        set mode_indexes ""
                        set mode_ids ""
                        set mode_labels ""
                        if {[array exists choice_percent_array]} {
                            array unset choice_percent_array
                        }
			set ${full_id}_c "<ul>"
			set ${full_id}_mean 0
			set n 0
			set points 0
                        db_foreach get_counts "select tr.total_responses, count(sqr.choice_id) as choice_count, to_char(((count(sqr.choice_id) / tr.total_responses :: float) * 100), '999.99%') as p ,sqr.choice_id, sqc.label, sqc.numeric_value from (select count(*) as total_responses from survey_question_responses where question_id=:question_id) as tr, survey_question_responses sqr left join survey_question_choices sqc on sqr.choice_id=sqc.choice_id where sqr.question_id=:question_id group by sqr.choice_id, sqc.label, sqc.numeric_value, sqc.sort_order,  tr.total_responses order by sqc.sort_order" {
                            lappend mode_values $choice_count
                            lappend mode_choice_ids $choice_id
                            set choice_percent_array(${p}_${choice_id}) "${label}: ${p}"

			    if { [empty_string_p $numeric_value] } {
				set numeric_value 0
			    }
			    
			    if {![empty_string_p $label] && ![string equal $choice_count 0]} {
			    append ${full_id}_c "<li>$label: $choice_count</li>"
			    incr n $choice_count
			    set points [expr $points + $choice_count * $numeric_value]
			    set ${full_id}_mean [expr [set ${full_id}_mean] + $choice_count * $numeric_value]
				append ${full_id}_d "$numeric_value: $choice_count<br />"
			    }
			    lappend var_names "${full_id}_d"
                        }
			append ${full_id}_c "</ul>"
			set ${full_section_id}_total [expr [set ${full_section_id}_total] + $points]
			if { $n } {
			    set ${full_id}_mean [format %0.2f [expr 1.0 * [set ${full_id}_mean] / $n]]
			} else {
			    set ${full_id}_mean 0
			}

                        set choice_percents [array names choice_percent_array]
                        set choice_percents [lsort -decreasing $choice_percents]
                        if {[llength $choice_percents]} {
                            append ${full_id}_cp "<ul>"
                            foreach c $choice_percents {
                                append ${full_id}_cp "<li>$choice_percent_array($c) </li>"
                            }
                            append ${full_id}_cp "</ul>"
                        }

                        set mode_indexes [lsearch -all $mode_values [f::lmax $mode_values]]
                        foreach i $mode_indexes {
                            lappend mode_ids [lindex $mode_choice_ids $i]
                        }
                        if {[llength $mode_ids]} {
                            set mode_labels [join [db_list get_labels "select label from survey_question_choices where choice_id in ([template::util::tcl_to_sql_list $mode_ids])"] " and "]
                        }
                        ns_log debug "\nDAVEB: survey report setting mode '${full_id}_mode' \n max = '[f::lmax $mode_values]' \n mode_values = '${mode_values} \n mode_choice_ids = '${mode_choice_ids}' \n mode_labels='${mode_labels}' \n mode_ids = '${mode_ids}'\n"
                        set ${full_id}_mode $mode_labels
                        
                    } else {
                        if {[array exists choice_percent_array]} {
                            array unset choice_percent_array
                        }
			set ${full_id}_c "<ul>"
			set ${full_id}_mean 0
			set n 0
			set points 0
                        db_foreach get_counts "select tr.total_responses, count(sqr.choice_id) as choice_count, to_char(((count(sqr.choice_id) / tr.total_responses :: float) * 100), '999.99%') as p ,sqr.choice_id, sqc.label, sqc.numeric_value from (select count(*) as total_responses from survey_question_responses where question_id=:question_id) as tr, survey_question_responses sqr left join survey_question_choices sqc on sqr.choice_id=sqc.choice_id where sqr.question_id=:question_id group by sqr.choice_id, sqc.label, sqc.numeric_value, sqc.sort_order,  tr.total_responses order by sqc.sort_order" {
                            set choice_percent_array(${p}_${choice_id}) "${label}: ${p}"
			    set choice_count_array(${choice_count}_${choice_id}) "${label}: ${choice_count}"

			    if { [empty_string_p $numeric_value] } {
				set numeric_value 0
			    }

			    append ${full_id}_c "<li>$label: $choice_count</li>"
			    incr n $choice_count
			    set points [expr $points + $choice_count * $numeric_value]
			    set ${full_id}_mean [expr [set ${full_id}_mean] + $choice_count * $numeric_value]
                        }
			append ${full_id}_c "</ul>"
			set ${full_section_id}_total [expr [set ${full_section_id}_total] + $points]
			if { $n } {
			    set ${full_id}_mean [format %0.2f [expr 1.0 * [set ${full_id}_mean] / $n]]
			} else {
			    set ${full_id}_mean 0
			}

                        set choice_percents [array names choice_percent_array]
                        set choice_percents [lsort -decreasing $choice_percents]

                        if {[llength $choice_percents]} {
				append ${full_id}_cp "<ul>"
				foreach c $choice_percents {
				    append ${full_id}_cp "<li>$choice_percent_array($c) </li>"
				}
				append ${full_id}_cp "</ul>"

                            set ctr 0
                            foreach c $choice_percents {
                                incr ctr
                                set ${full_id}_cp_top_${ctr} "$choice_percent_array($c)"
                                lappend var_names ${full_id}_cp_top_${ctr}
                            }
                        }
                        set ${full_id}_mode ""
                        set answer [join $answer ", "]
                    }
                    lappend var_names "${full_id}_cp"
		    lappend var_names "${full_id}_mean"
                }
                "boolean" {
                    set answer [db_string boolean_answer "select boolean_answer from survey_question_responses where response_id \
= :response_id and question_id = :question_id" -default ""]
                }
                "number" - "integer" {
                    set answer [db_string number_answer "select number_answer from survey_question_responses where response_id =\
 :response_id and question_id = :question_id" -default ""]
                }
                "text" {
                    set answer [db_string varchar_answer "select clob_answer from survey_question_responses where response_id\
 = :response_id and question_id = :question_id" -default ""]
                }
                default {
                    set answer [db_string varchar_answer "select varchar_answer from survey_question_responses where response_id\
 = :response_id and question_id = :question_id" -default ""]
                }
            }
            
            
            set $full_id $answer
            
            if { [lsearch $question_pretty_id $duplicate_pretty_ids] == -1 } {
                set short_id [util_text_to_url -replacement _ -text "$question_pretty_id"]
                set $short_id $answer
                lappend var_names $short_id
            }

        }

    # Compute delta per section
    db_foreach sections {
	select pretty_id as section_pretty_id, (select pretty_id 
			    from survey_sections 
			    where survey_id = :survey_id
			    and sort_key > s.sort_key 
			    order by sort_key limit 1) as next_section_pretty_id
	from survey_sections s
	where survey_id = :survey_id
    } {
	set delta_id [util_text_to_url  -replacement _ -text "${section_pretty_id}_${next_section_pretty_id}"]
	if { ! [empty_string_p $next_section_pretty_id] } {
	    set ${delta_id}_delta_positive 0
	    set ${delta_id}_delta_negative 0
	}
    }
    
    db_foreach section_points_delta {
	select count(*), section_pretty_id, next_section_pretty_id, ((next_section_score - section_score) > 10) as direction

	from (
	      select coalesce(sum(qc.numeric_value), 0) as section_score, r.response_id, q.section_id, s.pretty_id as section_pretty_id,
	      
	      (select coalesce(sum(sqc.numeric_value), 0)
	       from survey_responses sr, survey_question_responses sqr, survey_questions sq, survey_question_choices sqc
	       where sr.response_id = sqr.response_id 
	       and sqr.question_id = sq.question_id
	       and sq.question_id = sqc.question_id
	       and sr.response_id = r.response_id
	       and sqr.choice_id = sqc.choice_id
	       and sq.section_id = (select section_id 
				    from survey_sections 
				    where survey_id = :survey_id
				    and sort_key > s.sort_key 
				    order by sort_key limit 1)) as next_section_score,
	      (select pretty_id 
	       from survey_sections 
	       where survey_id = :survey_id
	       and sort_key > s.sort_key 
	       order by sort_key limit 1) as next_section_pretty_id

	      from survey_responses r, survey_question_responses qr, survey_question_choices qc, survey_questions q, survey_sections s

	      where r.response_id = qr.response_id 
	      and qr.choice_id = qc.choice_id 
	      and qr.question_id = q.question_id 
	      and q.section_id = s.section_id
	      and r.survey_id = :survey_id

	      group by r.response_id, q.section_id, s.sort_key, section_pretty_id
	      order by r.response_id, s.sort_key

	      ) scores

	where abs(section_score - next_section_score) > 10
	group by response_id, section_pretty_id, next_section_pretty_id, (next_section_score - section_score) > 10;
    } {
	ns_log debug "DEBUG:: $section_pretty_id - $next_section_pretty_id - $direction"
	if { ! [empty_string_p $next_section_pretty_id] } {
	    set delta_id [util_text_to_url -replacement _ -text "${section_pretty_id}_${next_section_pretty_id}"]
	    if { $direction == "f" } {
		incr ${delta_id}_delta_negative
	    } else {
		incr ${delta_id}_delta_positive
	    }
	}
    }
    
    
    set edit_url "../respond?[export_vars -url {response_id survey_id {edit_p 1}}]"
    
    set edit_link "<a href=$edit_url>Edit your response</a>"
    
}

upvar #[template::adp_level] __adp_master master
set master "[acs_root_dir]/packages/survey-reports/lib/report-master"
upvar #[template::adp_level] __adp_properties properties

if {$orig_survey_id} {
    set properties(download_url) "[ad_conn package_url]$orig_survey_id?rtf=t"
} else {
    set properties(download_url) "[ad_conn package_url]/template?template_id=$item(item_id)&rtf=t"
}
set properties(survey_id) $orig_survey_id
set properties(manage_url) "[ad_conn package_url]manage/${item(name)}"
set properties(admin_p) [permission::permission_p -object_id $package_id -privilege admin]

set vars {}
foreach var $var_names {
    lappend vars $var [set $var]
}

if {[string equal "t" $rtf]} {
    set master "[acs_root_dir]/packages/survey-reports/lib/print-report-master"

    foreach var {username first_names last_name email url screen_name full_name response_date current_date} {
	if {![info exists $var]} {
	    set $var ""
	}
	lappend vars $var [set $var]
    }

    upvar #[template::adp_level] __adp_master master
    set master ""
    set html [template::adp_parse "[acs_root_dir]/packages/survey-reports/lib/${item(item_id)}" $vars]



#    ns_log debug "BEFORE: \n $html \n"
#    set html [decruft $html]
#    set html [demoronise $html]
#    ns_log debug "AFTER: \n $html \n"

    set filename_base [ns_mktemp "/var/tmp/htmlXXXXXX"]
    set fd [open "${filename_base}.html" w]
    puts $fd $html
    close $fd
    ns_log debug "\nDAVEB!!!!! filename_base='${filename_base}'\n"
#    ad_return_complaint 1 "TESTING"
#    ad_script_abort
    set rtf_filename [html_to_rtf::convert_file -html_filename ${filename_base}.html]
    ns_log debug "RTF FILENAME = '$rtf_filename'"
    file delete ${filename_base}.html
    
    if {$rtf_filename ne ""} {
	if {[llength $used_list]} {
	    get_survey_info -survey_id $survey_id
	} else {
	    set survey_info(name) "survey_report_${item_id}"
	}
	set download_filename "${item(name)}.rtf"
	ns_log debug "DAVEB: download_filename='$download_filename'"
	ns_set update [ns_conn outputheaders] Content-Disposition "attachment; filename=\"$download_filename\""
	ns_returnfile 200 "text/rtf" $rtf_filename
	file delete $rtf_filename
	ad_script_abort
    } else {
	ad_returnredirect "/"
	ad_script_abort
    }
}
views::record_view -object_id $item_id -viewer_id $user_id

ad_return_template "../lib/${item(item_id)}"
