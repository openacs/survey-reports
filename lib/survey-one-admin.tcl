# include for report administration inline in survey/www/admin/one
# @param survey_id

set report_template_id [survey::report::get_template -survey_id $survey_id]
if {$report_template_id} {
    set report_template_name [item::get_element -item_id $report_template_id -element name]
} else {
    set report_template_name ""
}
