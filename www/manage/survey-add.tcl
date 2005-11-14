# packages/survey/www/admin/reports/manage/survey-add.tcl

ad_page_contract {
    
    associates a survey to template
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 1fafaa35-f25d-4734-86c7-07bacca70e8e
    @cvs-id $Id$
} {
    item_id:notnull
    survey_id:notnull
    return_url:notnull
} -properties {
} -validate {
} -errors {
}

set exists_p [db_string get_exists {
    select count(*)
    from survey_reports_survey_map
    where template_id = :item_id
          and survey_id = :survey_id
}]

if {!$exists_p} {
    db_dml insert_it {
        insert into survey_reports_survey_map
        (template_id, survey_id, survey_variables_p, survey_show_report_p)
        values
        (:item_id, :survey_id,'t','f')
    }
}

ad_returnredirect $return_url
