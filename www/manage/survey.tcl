# packages/survey/www/admin/reports/manage/survey.tcl

ad_page_contract {
    
    
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: e745b049-e46c-49b2-ae1e-612b5cf08fac
    @cvs-id $Id$
} {
    survey_id:notnull
} -properties {
} -validate {
} -errors {
}

set template_id [survey::report::get_template -survey_id $survey_id]

if {$template_id} {
    array set template [bcms::item::get_item -item_id $template_id]
    ad_returnredirect $template(name)
} else {
    ad_returnredirect "./"
}
