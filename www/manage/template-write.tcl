ad_page_contract {
    write the template to the file system and set the revision to live
} {
    revision_id:notnull,naturalnum
    return_url:notnull
}

set cms_context public

db_1row get_revision "select cr.*, ci.* from cr_revisions cr, cr_items ci where ci.item_id=cr.item_id and cr.revision_id=:revision_id" -column_array template

if {[array size template] > 0} {
    content::item::set_live_revision -revision_id $revision_id
    set template_file "[acs_root_dir]/packages/survey-reports/lib/${template(item_id)}.adp"
    set filename_base [ns_mktemp "/tmp/htmlXXXXXX"]

    # TODO DAVEB this should be a tcl proc
    # convert unADP to ADP
    set content $template(content)

    # regsub legal adp tags from square to angle brackets
    foreach tag [list include if else switch case] {
	set re "\\\[\s*?${tag}(.*?)\\\]"
	set sub "<${tag}\\1>"
	regsub -all $re $content $sub content
	set re "\\\[/\s*?${tag}\s*?\\\]"
	set sub "</${tag}>"
	regsub -all $re $content $sub content
    }

    set template(content) $content

    template::util::write_file $filename_base $template(content)
    set recode_script "[acs_root_dir]/packages/survey/bin/recode"
    set demoronise_script "[acs_root_dir]/packages/survey/bin/demoroniser.pl"
    if {[catch {exec $demoronise_script $filename_base $template_file} err]} {
	ns_log error "template_write Error:'$err'"
	# fallback
	template::util::write_file $template_file $template(content)
    }
    file delete $filename_base

#    template::util::write_file $template_file [encoding convertto iso8859-1 $template(content)]
#    template::util::write_file $template_file [demoronise $template(content)]
} else {
    error "revision does not exist"
}

ad_returnredirect $return_url
ad_script_abort
