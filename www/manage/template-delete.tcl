ad_page_contract {
    delete templates
} {
    item_id:notnull,naturalnum,multiple
    {confirm_p:optional,boolean 0}
    return_url:notnull
}

set context {}

if {$confirm_p} {

    db_transaction {
        foreach one_item $item_id {
            set template_name [item::get_element -item_id $one_item -element name]
            content::item::delete -item_id $one_item
            # also delete from fs
            set template_file "[acs_root_dir]/packages/survey-reports/lib/${one_item}.adp"
            file delete -force $template_file
        }
    }
    ad_returnredirect $return_url
    ad_script_abort

} else {

    template::list::create \
        -name delete_list \
        -multirow delete_list \
        -key item_id \
        -elements [subst {
            title {
                label "Item"
            }
        }]

    set template_ids [join $item_id ", "]
    db_multirow delete_list get_to_be_deleted "
                        select  i.item_id, 
                                i.name, 
                                i.live_revision, 
                                i.latest_revision, 
                                i.publish_status, 
                                i.content_type, 
                                i.storage_type,
                                i.tree_sortkey,
                                r.title
                        from cr_items i, cr_revisions r
                        where
                                i.item_id in ($template_ids)
                                and r.revision_id = i.latest_revision"

    set confirm_link [export_vars -base template-delete {item_id return_url {confirm_p 1}}]

    set title "Delete"

}
