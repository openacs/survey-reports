# packages/survey/tcl/survey-report-procs.tcl

ad_library {
    
    survey report library
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 3bb8b8a0-8149-465b-8820-42e08b817693
    @cvs-id $Id$
}

namespace eval survey::report {}

ad_proc -public survey::report::get_root_folder_name {
    -package_id:required
} {
    gets the root folder name for a particular survey note that this 
    assumes a specific name.
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    
    @param package_id

    @return 
    
    @error 
} {
    return "survey_reports_${package_id}_root_folder"
}


ad_proc -public survey::report::get_root_folder {
    -package_id
} {
    gets the root template folder of a survey package.  returns empty
    string if none found.
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    
    @param package_id

    @return 
    
    @error 
} {
    if {![exists_and_not_null package_id]} {
        set package_id [ad_conn package_id]
    }

    set folder_name [get_root_folder_name -package_id $package_id]
    
    set template_root_id -200 

    set root_folder_id [db_string get_root_folder {
        select f.folder_id
        from cr_items i,
             cr_folders f
        where f.folder_id = i.item_id
              and i.parent_id = :template_root_id
              and i.name = :folder_name
    } -default ""]
    
    return $root_folder_id
}

ad_proc -public survey::report::init_root_folder {
    -package_id
} {
    creates a root folder for a survey package if there is none
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    
    @param package_id

    @return 
    
    @error 
} {
    if {![exists_and_not_null package_id]} {
        set package_id [ad_conn package_id]
    }
    
    set root_folder_id [get_root_folder -package_id $package_id]
    if {[empty_string_p $root_folder_id]} {
        set root_folder_id [bcms::folder::create_folder \
                                -name [get_root_folder_name -package_id $package_id] \
                                -folder_label "Survey Reports" \
                                -parent_id [bcms::template::get_cr_root_template_folder] \
                                -description "Survey Report Templates for survey package $package_id" \
                                -package_id $package_id \
                                -context_id $package_id \
                                -content_types "content_template" 
                  ]
    } 
        
    return $root_folder_id
}

ad_proc -public survey::report::get_template {
    -survey_id:required
} {
    gets the associated template for a survey. 0 if none.
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    
    @param survey_id

    @return 
    
    @error 
} {
    set template_id [db_string get_report {
        select template_id
        from survey_reports_survey_map
        where survey_id = :survey_id
        and survey_show_report_p = 't'
        limit 1
    } -default 0]
    
    return $template_id
}
