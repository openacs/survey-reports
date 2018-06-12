ad_page_contract {

    Set up template and see variables for a report based on a given survey.
    WARNING: This page has a file storage proc in it that will need to be moved if this goes into the standard survey package\
.

    @param   survey_id   section we're adding a template to

    @author  Caroline@Meekshome.com
    @date    Feb 2004
    @cvs-id  $Id$
} {
    survey_id:integer
    {user_id "[ad_conn user_id]"}
    {rtf "f"}
}

ad_require_permission $survey_id read


if [catch {acs_user::get -user_id $user_id -array user} errmsg] {
    if { $user_id } {
        ad_return_complaint 1 "[_ survey.Not_Found] [_ survey.lt_Could_not_find_user_u]"
        return
    } else {
        ad_maybe_redirect_for_registration
    }
}

#Check to see if there is a report. If there isn't show the the view one-respondant) page instead.

ns_log debug "CM [acs_root_dir]/packages/survey/www/admin/reports/$survey_id"
if { ![file exists "[acs_root_dir]/packages/survey/www/admin/reports/$survey_id.adp"] } {
    ad_returnredirect "../one-respondent?survey_id=$survey_id"
}


#Now set prettier variables for the user to use.

set username $user(username)
set first_names $user(first_names)
set last_name $user(last_name)
set full_name $user(name)
set email $user(email)
set url $user(url)
set screen_name $user(screen_name)
set current_date [ns_fmttime [ns_time] "%B %e, %Y"]

#For now we will only use the oldest response.
db_0or1row last_response "select response_id, to_char(creation_date,'Month DD, YYYY') as response_date from survey_responses,\
 acs_objects
                  where response_id = object_id
and creation_user = :user_id
and survey_id=:survey_id
order by creation_date DESC
LIMIT 1"

if { ![exists_and_not_null response_id] } {
    #Has not yet taken the survey. Send the user to the survey
    ad_returnredirect "../respond?survey_id=$survey_id&return_url=reports/"
    ad_script_abort
}

ad_require_permission $response_id read

#Set all the variables.
set duplicate_pretty_ids [db_list duplicate_pretty_ids {select distinct(q1.pretty_id)
       from survey_questions q1 right outer join survey_sections s on q1.section_id = s.section_id
where survey_id = :survey_id
and 1 < (select count(*) from survey_questions q2 right outer join survey_sections s on q2.section_id = s.section_id
     where survey_id = :survey_id
	 and q2.pretty_id = q1.pretty_id)}]

# get all the questions and make variables for them based on their pretty_ids
db_foreach survey_questions {      select s.name as name, question_id, question_text, presentation_type, sort_order, active_p\
, required_p, abstract_data_type,
     s.section_id as section_id, branch_p,
          coalesce(q.pretty_id,(question_id::varchar)) as question_pretty_id,
     coalesce(s.pretty_id,(s.section_id::varchar)) as section_pretty_id
     from survey_questions q right outer join survey_sections s
     on (q.section_id = s.section_id)
     where survey_id=:survey_id
     and abstract_data_type in ('text','shorttext','boolean','number','integer','choice')
    order by s.sort_key,s.section_id, sort_order} {
    #The goal of this section is to list for the user all the variables he has available when he makes his template and the p\
ossible answers.

         #I'm being lazy here and not getting the responses at the same time I get all the questions.
         #For now I'm not expecting a preformance issue but this may need to be rewritten at some time.
         #If you ever do rewrite it remember to set unanswered questions to empty string.
set file_upload_name [ad_sanitize_filename -tolower "${section_pretty_id}_${question_pretty_id}"]

lappend var_names full_name
lappend var_names $full_id

ns_log notice "\n-----\nDB full_id '${full_id}' \n ---- \n"
switch $abstract_data_type {
    "choice" {
	set answer [db_list choice_answer "select label from survey_question_choices c, survey_question_responses \
r
                 where r.choice_id = c.choice_id
                               and r.response_id = :response_id
                               and r.question_id = :question_id
                               and c.question_id = :question_id"]
	if {[llength $answer] == 1} {
	    set answer [lindex $answer 0]
                 # DAVEB add median support to report

	    # ns_log notice "\n-----\nDB Choice Question full_id '${full_id}' \n ---- \n"

	    set ${full_id}_the_choice [db_string get_c "select sqc.numeric_value from survey_question_responses sqr, survey_question_choices sqc where sqc.question_id=:question_id and sqr.choice_id=sqc.choice_id and sqr.question_id=:question_id and sqr.response_id=:response_id"]
	    set stats [db_list get_stats "select sqc.numeric_value from survey_question_responses sqr , survey_question_choices sqc where sqr.question_id=:question_id and sqc.question_id=:question_id and sqr.choice_id=sqc.choice_id"]


	    if {![string equal "" [set ${full_id}_the_choice]]} {

		set ${full_id}_median [format %0.2f [expr 1.0 * [math::statistics::BasicStats mean $stats]]]
		lappend var_names ${full_id}_median
	    }
 			set mode_values ""
 			set mode_choice_ids ""
 			set mode_indexes ""
 			set mode_ids ""
 			set mode_labels ""
			set ${full_id}_cp ""
		db_foreach get_counts "select tr.total_responses, count(sqr.choice_id) as choice_count, to_char(((count(sqr.choice_id) / tr.total_responses :: float) * 100), '999.99%') as p ,sqr.choice_id, sqc.label, sqc.numeric_value from (select count(*) as total_responses from survey_question_responses where question_id=:question_id) as tr, survey_question_responses sqr left join survey_question_choices sqc on sqr.choice_id=sqc.choice_id where sqr.question_id=:question_id group by sqr.choice_id, sqc.label, sqc.numeric_value, sqc.sort_order, tr.total_responses order by sqc.sort_order" {
		    lappend mode_values $choice_count
		    lappend mode_choice_ids $choice_id
		    set choice_percent_array($p) "${label}: ${p}"
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


	    set ${full_id}_mode $mode_labels

	} else {
	    set ${full_id}_mode ""
	    set answer [join $answer ", "]
	}
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
    set short_id [ad_sanitize_filename -tolower $question_pretty_id]

    set $short_id $answer
    lappend var_names $short_id
}
}


set edit_url "../respond?[export_vars -url {response_id survey_id {edit_p 1}}]"

set edit_link "<a href=$edit_url>Edit your response</a>"

# DAVEB
upvar #[template::adp_level] __adp_master master
set master "[acs_root_dir]/packages/survey/lib/report-master"
upvar #[template::adp_level] __adp_properties properties

    set properties(download_url) "[ad_return_url]&rtf=t"
set properties(survey_id) $survey_id
if {[string equal "t" $rtf]} {
    set master "/home/prodcomp/openacs/packages/survey/lib/print-report-master"
    set vars [list]
    foreach var $var_names {
	lappend vars $var [set $var]
    }

    foreach var {username first_names last_name email url screen_name current_date} {
	lappend vars $var [set $var]
    }

    upvar #[template::adp_level] __adp_master master
    set master ""
    set html [template::adp_parse "/home/prodcomp/openacs/packages/survey/www/admin/reports/${survey_id}" $vars]
    set filename_base [ns_mktemp "/home/prodcomp/temp/htmlXXXXXX"]
    set fd [open "${filename_base}.html" w]
    puts $fd $html
    close $fd
    set rtf_filename [html_to_rtf::convert_file -html_filename ${filename_base}.html]
    ns_log notice "RTF FILENAME = '$rtf_filename'"
    file delete ${filename_base}.html
    if {$rtf_filename ne ""} {
	get_survey_info -survey_id $survey_id
	set download_filename "${survey_info(name)}.rtf"
ns_log debug "DAVEB: download_filename='$download_filename'"
	ns_set update [ns_conn outputheaders] Content-Disposition "attachment; filename=\"$download_filename\""
	ns_returnfile 200 "text/rtf" ${filename_base}.rtf
	file delete ${filename_base}.rtf
    } else {
    ad_returnredirect "/"
    ad_script_abort
    }
}

ad_return_template "../admin/reports/$survey_id"
