ad_page_contract {
    unpublish this revision
} {
    revision_id:notnull,naturalnum
    return_url:notnull
}

bcms::revision::set_revision_status -revision_id $revision_id -status production

set template_name [item::get_element -item_id [item::get_item_from_revision $revision_id] -element name]
set template_filename "[acs_root_dir]/packages/survey/www/admin/reports/${template_name}.adp"
if {[file exists $template_filename]} {
    file delete -force $template_filename
}

ad_returnredirect $return_url
ad_script_abort
