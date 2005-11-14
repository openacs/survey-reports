ad_page_contract {
    publish this revision
} {
    revision_id:notnull,naturalnum
    return_url:notnull
}

array set revision [bcms::revision::get_revision -revision_id $revision_id]

if {[array size revision] > 0} {
    # publish it if the revision is not live, otherwise its has already been published
    if {$revision(live_revision) != $revision_id} {
        bcms::revision::set_revision_status -revision_id $revision_id -status live
    }
} else {
    error "revision does not exist"
}

ad_returnredirect $return_url
ad_script_abort
