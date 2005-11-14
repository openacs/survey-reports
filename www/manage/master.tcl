# packages/survey/www/admin/reports/manage/master.tcl

ad_page_contract {
    
    master template
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-21
    @arch-tag: 65a1e87d-e753-436b-a44a-3ca53452b2e2
    @cvs-id $Id$
} {
    
} -properties {
} -validate {
} -errors {
}

set package_url [ad_conn package_url]
set current_url [ad_return_url]

set context {}