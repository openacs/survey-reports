# this file is meant to be included with the following parameters

# parent_id - if you are creating a new template
# revision_id - if you are editing a template revision
# return_url - requires a return_url, so after creating or editing a folder it redirect to this url
# form_mode - either "edit" or "display"

ad_form -name simpleform -mode display -has_edit 1 -has_submit 1 -form {
    revision_id:key
    {submit1:text(submit) {label "Edit"}}
    {name:text(text) {label "Name"} {help_text "Allowed characaters are: alphanumeric, _, -"}}
    {title:text(text) {label "Title"}}
    {description:text(textarea),optional {html {rows 5 cols 80}} {label "Description"}}
    {content:richtext,optional {html {rows 40 cols 100}} {label "Content"} {htmlarea_p 1}}
    {parent_id:integer(hidden),optional {value $parent_id}}
    {item_id:integer(hidden),optional}
    {return_url:text(hidden) {value $return_url}}
    {submit2:text(submit) {label "Edit"}}
} -validate {
    {name
        {[expr {[set existing_item [content::item::get_id -root_folder_id $parent_id -item_path $name]] eq "" || $existing_item == $item_id}]} 
        "Template Name already exists, <br /> please use another Template Name"
    }
    {name 
	{![regexp {[^a-zA-z0-9\-_]} $name]}
	"Illegal characters in name"
    }
} -edit_request {
    if {[ns_queryget "form:mode"] eq "display"} {
	element set_properties simpleform submit1 label "OK"
	element set_properties simpleform submit2 label "OK"
    }
    db_1row get_revision "select cr.*, ci.name, ci.parent_id from cr_revisions cr, cr_items ci where cr.item_id=ci.item_id and cr.revision_id=:revision_id" -column_array one_revision
    set item_id $one_revision(item_id)
    set name $one_revision(name)
    set title $one_revision(title)
    set description $one_revision(description)
    set folder_id $one_revision(parent_id)

    # For now, just show the template thats in the database
    # DAVEB
    
    #    set template_dir [parameter::get -parameter TemplateRoot]
    #    set template_root_id [parameter::get -parameter template_folder_id]
    #    set template_path [db_string get_url "select content_item__get_path(:item_id,:template_root_id)"]
    #    set template_root "[acs_root_dir]/${template_dir}"
    #set template_filename "${template_root}/${template_path}.adp"
    #ns_log notice "DAVEB: template-form template_filename $template_filename"
    #    # read the file contents from the file system
    #    if {[file exists $template_filename]} {
    #        set content [template::util::read_file $template_filename]
    #    } else {
    set content [template::util::richtext::create $one_revision(content) "text/html"]
    #    }

} -edit_data {
    set content [template::util::richtext::get_property contents $content]
    set new_revision_id [content::revision::new -item_id $item_id -title $title -content $content -description $description]

#    bcms::item::set_item -item_id $item_id -name $name

    content::item::get -item_id $item_id -array_name item
    ad_returnredirect [export_vars -base [ad_conn url] {{revision_id $new_revision_id}}]
} -new_data {

    set template_filename "[acs_root_dir]/packages/survey/www/reports/${name}.adp"
    # read the file contents from the file system
    if {[file exists $template_filename] && [empty_string_p $content]} {
        set content [template::util::read_file $template_filename]
    }
    
#    set content [demoronise $content]

    # create the template and revision
    db_transaction {
        set item_id [content::item::new -name $name -parent_id $parent_id]
        set revision_id [content::revision::new -item_id $item_id \
                             -title $title -content $content -description $description]
    }
    
} -after_submit {
    ad_returnredirect $return_url
    ad_script_abort
}

ad_return_template "/packages/survey-reports/lib/simple-form"


