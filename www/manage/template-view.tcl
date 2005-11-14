ad_page_contract {
    view a template revision, if no revision_id is passed then latest revision is used
} {
    item
    {revision_id ""}
    {return_url:optional "[ad_conn url]"}
}


set package_id [ad_conn package_id]
set package_url [ad_conn package_url]

#if {![exists_and_not_null revision_id]} {
#set revision_id [item::get_best_revision $item_id]
#}

set root_id [survey::report::get_root_folder -package_id [ad_conn package_id]]
array set content $item
set item_id $content(item_id)
if {[empty_string_p $revision_id]} {
	if {![empty_string_p $content(live_revision)]} {
		set revision_id $content(live_revision)
	} elseif {![empty_string_p $content(latest_revision)]} {
		set revision_id $content(latest_revision)
	} else {
		ns_returnnotfound
	}
}

set from_url "$content(name)"

# TODO DAVEB replace with CR PROC
db_1row get_revision "select *, content_revision__get_number(cr.revision_id) as version_number, content_revision__get_number(ci.live_revision) as live_version_number from cr_revisionsx cr, cr_items ci where cr.revision_id=:revision_id and cr.item_id=ci.item_id" -column_array template_revision

template::multirow create actions url label title

set publish_url [export_vars -base "template-write" {revision_id {return_url "[ad_conn url]"}}]

set title "View Template"
# TODO replace with get paths for context
lappend context "$template_revision(title)"

set parent_id $template_revision(parent_id)

template::list::create \
    -name surveys_used \
    -multirow surveys_used \
    -key survey_id \
    -bulk_actions {"Remove" survey-delete "Remove"} \
    -bulk_action_export_vars {item_id return_url} \
    -elements {
        survey_id {
            label "Survey ID"
        }
        survey_name {
            label "Name"
	    link_url_col link_url
        }
    }

set used_list [list]

db_multirow -extend {link_url} surveys_used surveys_used {
    select s.survey_id,
           s.name as survey_name
    from surveys s,
         survey_reports_survey_map m
    where m.template_id = :item_id
          and m.survey_id = s.survey_id
          and m.survey_variables_p = 't'
} {
    lappend used_list $survey_id
    set link_url [export_vars -base "../../admin/one" {survey_id}]
}

if {[llength $used_list]} {
    set no_surveys_associated_p 0
} else {
    set no_surveys_associated_p 1
}

lappend used_list 0
set survey_package_id [site_node::closest_ancestor_package -node_id [ad_conn node_id] -package_key survey]
set unused_surveys_list [db_list_of_lists get_unused "
    select s2.name as survey_name,
           s2.survey_id
    from surveys s2
    where s2.package_id = :survey_package_id
    and s2.survey_id not in ([join $used_list ","])
"]

set unused_count [llength $unused_surveys_list]

ad_form \
    -name survey_form \
    -action survey-add \
    -method post \
    -export {item_id {return_url $from_url}} \
    -form {
        {survey_id:text(select) {label "Available Surveys"} {options $unused_surveys_list}}
        {submit:text(submit) {label "Add this survey's variables to this report"}}
    }


set template_info "
<b>This Version</b>: $template_revision(version_number)<br>
<b>Live Version</b>: $template_revision(live_version_number)"

set link_to_this_url "[ad_url][ad_conn package_url]reports/template?template_id=$item_id"
