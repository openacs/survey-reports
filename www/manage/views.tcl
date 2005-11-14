# packages/forums/www/views.tcl

ad_page_contract {
    
    report on user views
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-08-03
    @arch-tag: 30272296-a2f7-4b46-a20e-94f75f572fb3
    @cvs-id $Id$
} {
    viewer_id:optional
    object_id:notnull
    {sortby viewer_name}
} -properties {
} -validate {
} -errors {
}

set title "User View Tracking"
set context {{User View Tracking}}
set header_stuff ""

set user_id [auth::require_login]
set package_id [ad_conn package_id]

set object_type content_item

set filter_url views

ad_return_template
