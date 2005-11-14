# packages/survey/www/admin/reports/manage/survey-delete.tcl

ad_page_contract {
    
    
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 7efe0a32-068e-4b40-895a-4de7a3fcafb7
    @cvs-id $Id$
} {
    survey_id:optional,notnull,multiple
    item_id:notnull
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

if {![info exists survey_id]} {
    ad_returnredirect $return_url
}

if {[llength $survey_id] == 1} {
    set survey_id [split [lindex $survey_id 0]]
}

foreach one_survey $survey_id {
    db_dml delete {
        delete 
        from survey_templates_survey_map
        where survey_id = :one_survey
        and template_id = :item_id
    }
}

ad_returnredirect $return_url
