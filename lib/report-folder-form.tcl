#a form to create or edit a folder
#
# this file is meant to be included with the following parameters
#
# folder_id - if you are editing a folder
# parent_id - if you are creating a folder
# create_index_p - if true will create a blank page named "index" on the new folder, defaults to true
# return_url - requires a return_url, so after creating or editing a folder it redirect to this url
# form_mode - either "edit" or "display"

# initialize the vars that don't exist
if {![info exists parent_id]} {
    if {![info exists folder_id]} {
        error "you are likely going to use this form to create a new folder, please include a parent_id parameter"
    }
    set parent_id ""
}
if {![info exists create_index_p]} {
    set create_index_p true
}
if {![info exists form_mode]} {
    set form_mode edit
}

ad_form -name simpleform -mode $form_mode -has_edit 1 -form {
    {folder_name:text(inform) {label "Folder Name"}}
    {folder_label:text(inform) {label "Folder Label"}}
    {description:text(inform),optional {label "Folder Description"}}
    {create_index_p:boolean(hidden),optional {value $create_index_p}}
    {parent_id:integer(hidden),optional {value $parent_id}}
    {return_url:text(hidden) {value $return_url}}
} -on_request {
    content::item::get -item_id $folder_id -array_name folder
    set folder_name $folder(name)
    set folder_label $folder(label)
    set description $folder(description)
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
} 


ad_return_template "/packages/survey-reports/lib/simple-form"

