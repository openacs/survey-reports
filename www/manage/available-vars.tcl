ad_page_contract {
    Get the variables that are valid for the report
} {
    name
}

set report_folder_id [survey::report::get_root_folder ]
set item_id [content::item::get_id -root_folder_id $report_folder_id -item_path $name]
#ad_return_complaint 1 "folder_id '${report_folder_id}' item_id '${item_id}'"
content::item::get -item_id $item_id -array_name content -revision latest

if {[array size content] == 0} {
	ns_returnnotfound
}

set revision_id $content(latest_revision)
set package_id [ad_conn package_id]
set used_list [list]

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

if {[llength $used_list]} {
    get_survey_info -survey_id $survey_id

    if {![info exists survey_info(survey_id)]} {
        ad_return_complaint 1 "[_ survey.lt_Requested_survey_does]"
        ad_script_abort
    }

    set survey_name $survey_info(name)

    set duplicate_pretty_ids [db_list duplicate_pretty_ids {
        select distinct(q1.pretty_id) 
        from survey_questions q1 
             right outer join survey_sections s 
             on q1.section_id = s.section_id
        where survey_id = :survey_id
              and 1 < (select count(*) 
                       from survey_questions q2 
                       right outer join 
                       survey_sections s 
                       on q2.section_id = s.section_id
                       where survey_id = :survey_id
                       and q2.pretty_id = q1.pretty_id)
    }]

    # get all the questions and make variables for them based on their pretty_ids
    db_multirow -extend {short_id full_id possible_values} vars survey_q_and_a "
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
        (select 1 
         from survey_question_choices sqc 
         where sqc.question_id=q.question_id 
         and numeric_value is not null 
         limit 1) as median_p,
        coalesce(q.pretty_id,(question_id::varchar)) as question_pretty_id, 
        coalesce(s.pretty_id,(s.section_id::varchar)) as section_pretty_id
        from survey_questions q right outer join survey_sections s
        on (q.section_id = s.section_id)
        where survey_id in ([join $used_list ","])
        and abstract_data_type in ('text','shorttext','boolean','number','integer','choice')
        order by survey_id,
        s.sort_key,
        s.section_id,
        sort_order
    " {
        #The goal of this section is to list for the user all the variables he has available when he makes his template and the possible answers.
        set full_id [util_text_to_url -text "${section_pretty_id}_${question_pretty_id}"]
        if { [lsearch $question_pretty_id $duplicate_pretty_ids] == -1 } {
            set short_id [util_text_to_url -replacement _ -text "$question_pretty_id"]
        }
        switch $abstract_data_type {
            "choice" {
		set answer_list [list]
		foreach choice [db_list_of_lists answers {select sort_order, label from survey_question_choices where question_id = :question_id order by sort_order}] {
		    set sort_order [lindex $choice 0]
		    set label [lindex $choice 1]
                    lappend answer_list " ${label}<br />@${full_id}_cid_${sort_order}@<br />@${full_id}_cid_${sort_order}_percent@<br />@${full_id}_cid_${sort_order}_label@<br />"
		}
                set possible_values "[join $answer_list "<br>"]"
            } 
            "text" -
            "shorttext" {
                set possible_values "<em>text string</em>"
            }
            "boolean" {
                set possible_values "<em>boolean (use &lt;if &#64;var&#64; true> or &lt;if &#64;var&#64; false&gt;)</em>"
            }
            default {
                set possible_values "<em>$abstract_data_type</em>"
            }
        }

    }
} else {
    set no_surveys_associated_p 1
}
