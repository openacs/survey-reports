# packages/survey/www/admin/reports/manage/template-select-2.tcl

ad_page_contract {
    
    
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 3a00f507-46e9-4a08-8ed8-4b084cad50fc
    @cvs-id $Id$
} {
    survey_id:notnull
    template_id:notnull
    return_url:optional
} -properties {
} -validate {
} -errors {
}

if {![exists_and_not_null return_url]} {
    set return_url [export_vars -base survey {survey_id}]
}

db_transaction {
    db_dml assoc {
        update survey_reports_survey_map
        set survey_show_report_p = 'f'
        where survey_id=:survey_id
    }
    if {$template_id} {
        if {![db_0or1row get_template "select 1 from survey_reports_survey_map where survey_id=:survey_id and template_id=:template_id"]} {
            db_dml insert_it {
                insert into survey_reports_survey_map
                (template_id, survey_id,survey_variables_p,survey_show_report_p)
                values
                (:template_id, :survey_id,'f','t')
            }
        } else {
            db_dml update_it {
                update survey_reports_survey_map set survey_show_report_p = 't' where survey_id=:survey_id and template_id=:template_id
            }
        }
    }
}


ad_returnredirect $return_url
