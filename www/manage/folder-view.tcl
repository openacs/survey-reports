# packages/survey/www/admin/reports/manage/folder-view.tcl

ad_page_contract {
    
    views a folder
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: ef91384f-9bb6-455a-9f3a-db28b35434ba
    @cvs-id $Id$
} {
    item
    {orderby:optional}
    {page:optional}
    {return_url "[ad_conn url]"}
} -properties {
} -validate {
} -errors {
}

if {![regexp {/$} [ad_conn url]]} {
	ad_returnredirect "[ad_conn url]/"
	ad_script_abort
}

set root_id [survey::report::get_root_folder]
array set current_item $item
set folder_id $current_item(item_id)
# TODO make a CR proc?

set package_url [ad_conn package_url]

set type_options {{Report template-add}}

ad_form -name add-item -export {return_url} -form {
	{submit:text(submit) {label "Add New"} {value "Add New"}}
	{item_type:text(select) {label ""} {options $type_options } }
	{parent_id:text(hidden) {value $folder_id}}
} -on_submit {
	ad_returnredirect "${item_type}?[export_vars {parent_id return_url}]"
}

template::list::create \
    -name item_list \
    -multirow item_list \
    -pass_properties { package_url } \
    -key item_id \
    -bulk_actions [list "Delete" "template-delete" "Delete checked items"] \
    -bulk_action_export_vars {
        return_url
    } \
    -elements {
        name {
            label "Name"
            link_url_col name
        }
        title {
            label "Title"
        }
        publish_status {
            label "Status"
        }
    }

# TODO replace multirow proc with a db_multirow DAVEB
db_multirow item_list get_item_list "select ci.publish_status,* from cr_revisionsx cr, cr_items ci where cr.parent_id=:folder_id and cr.item_id=ci.item_id and cr.revision_id=ci.latest_revision"

set title "View Folder"

# TODO get paths for folder to feed to context DAVEB
#set context [bcms::widget::item_context -item_id $folder_id -root_id $root_id -root_url [ad_conn package_url]manage/ ]
#set context [lrange $context 0 [expr [llength $context] - 2]]
set context [list "Manage Reports"]
lappend context $current_item(label)