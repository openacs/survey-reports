# packages/bcms-ui-base/www/template/template-preview.tcl

ad_page_contract {
    
    previews a template
    
    @author Deds Castillo (deds@i-manila.com.ph)
    @creation-date 2004-10-19
    @arch-tag: dfad99ae-112a-4a91-bbf1-2acbab8754bf
    @cvs-id $Id$
} {
    {revision_id:notnull}
    {return_url:optional}
} -properties {
} -validate {
} -errors {
}

set title "Preview Template"

array set one_revision [bcms::revision::get_revision -revision_id $revision_id]
if {![exists_and_not_null return_url]} {
    set return_url $one_revision(name)
}
set content $one_revision(content)
