# packages/survey/www/admin/reports/manage/template-select.tcl

ad_page_contract {
    
    associates a template
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: aee27b3f-be28-4c2e-949c-4ffe9d8c05d3
    @cvs-id $Id$
} {
    survey_id:notnull
    return_url:optional
} -properties {
} -validate {
} -errors {
}

set title "Associate report"

if {![exists_and_not_null return_url]} {
    set return_url [export_vars -base "template-select" {survey_id}]
}

set current_template_id $item(item_id)

set folder_id [survey::report::get_root_folder]

template::list::create \
    -name item_list \
    -multirow item_list \
    -pass_properties { package_url current_template_id survey_id return_url } \
    -actions [list "Manage Reports" "./" "Manage Report" "Main Survey Admin" "../../" "Main Survey Admin" Back "../../one?survey_id=$survey_id" Back] \
    -elements {
        name {
            label "Name"
            link_url_col name
        }
        last_modified_pretty {
            label "Last Modified"
            html { style "width:180px" }
        }
        publish_status {
            label "Status"
        }
        actions {
            label ""
            display_template {<if @item_list.item_id@ eq @current_template_id@><a href="template-select-2?survey_id=@survey_id@&template_id=0">Don't Use</a></if><else><a href="template-select-2?survey_id=@survey_id@&template_id=@item_list.item_id@&return_url=@return_url@">Use</a></else>}
        }
    } 

db_multirow -extend {last_modified_pretty} item_list get_items "select *, ci.name from cr_revisionsx cr, cr_items ci where cr.revision_id=ci.latest_revision and ci.parent_id=:folder_id" {
    set last_modified_pretty [lc_time_fmt $last_modified %c]
}

content::item::get -item_id $folder_id -array_name folder
lappend context $folder(label)

