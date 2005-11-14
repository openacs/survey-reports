ad_page_contract {
} {
    {template_id:notnull}
    {rtf "f"}
}

set report_folder_id [survey::report::get_root_folder]

content::item::get -item_id $template_id -revision live -array_name item
set survey_id 0

rp_form_put template_item [array get item]
rp_form_put survey_id $survey_id

rp_internal_redirect view
