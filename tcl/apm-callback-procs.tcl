# 

ad_library {
    
    Install and setup survey reports
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-11-01
    @arch-tag: 45462fee-df1c-408d-b84d-2206ebf59b76
    @cvs-id $Id$
}

namespace eval survey_reports::install {}

ad_proc -private survey_reports::install::after_instantiate {
    -package_id
} {

    Setup folder
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-11-01
    
    @return 
    
    @error 
} {
    set folder_id [content::folder::new \
                       -name "survey_reports_${package_id}_root_folder" \
                       -parent_id "-200" \
                       -package_id $package_id
                  ]

    content::folder::register_content_type \
        -folder_id $folder_id \
        -content_type "content_revision"
}

ad_proc -private survey_reports::install::before_uninstantiate {
    -package_id
} {
     Remove folder and contents
    
    @author Dave Bauer (dave@thedesignexperience.org)
    @creation-date 2005-11-01
    
    @param package_id

    @return 
    
    @error 
} {
    set folder_id [content::item::get_id -path "survey_reports_${package_id}_root_folder" -root_folder_id "-200"]
    content::folder::delete \
        -folder_id $folder_id \
        -cascade_p t
}
