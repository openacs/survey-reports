# packages/bcms-ui-base/lib/revision-list.tcl
#
# revisions
#
# @author Deds Castillo (deds@i-manila.com.ph)
# @creation-date 2004-10-18
# @arch-tag: f9bc2802-3c4a-4289-a692-9aba860c67a4
# @cvs-id $Id$

foreach required_param {item_id} {
    if {![info exists $required_param]} {
        return -code error "$required_param is a required parameter."
    }
}

set package_url [ad_conn package_url]

set current_url "${package_url}admin/reports/manage/[ad_conn path_info]"
set target_url $current_url
set preview_url "${package_url}admin/reports/manage/template-preview"
if {![exists_and_not_null publish_url]} {
    set publish_url "${package_url}admin/reports/manage/template-write"
}
if {![exists_and_not_null unpublish_url]} {
    set unpublish_url "${package_url}admin/reports/manage/template-unpublish"
}

template::list::create \
    -name revision_list \
    -multirow revision_list \
    -key revision_id \
    -pass_properties {publish_url unpublish_url version} \
    -elements {
        creation_date {label "Date Created"}
        last_name {
            label "Author"
            display_template {@revision_list.first_names@ @revision_list.last_name@}
        }
        version_number {
            label "Version Number / Status"
            display_template {@revision_list.version_number@ <if @revision_list.live_revision_id@ eq @revision_list.revision_id@> (<b>live</b>)</if> <if @revision_list.version_number@ eq @version@> (currently being managed)</if>}
        }
        revision_id {
            label "Version Actions"
            display_template {<a href="${preview_url}?revision_id=@revision_list.revision_id@&return_url=${current_url}">Preview</a> | <a href="${target_url}?revision_id=@revision_list.revision_id@">Manage</a> | <if @revision_list.live_revision_id@ eq @revision_list.revision_id@><b><a href="$unpublish_url?revision_id=@revision_list.revision_id@&return_url=${current_url}?revision_id=@revision_list.revision_id@">Unpublish</a></b></if><else><a href="$publish_url?revision_id=@revision_list.revision_id@&return_url=${current_url}?revision_id=@revision_list.revision_id@">Publish</a></else>}
        }
        
    }

db_multirow revision_list get_revisions "select ci.live_revision as live_revision_id, cr.*, content_revision__get_number(cr.revision_id) as version_number, u.first_names, u.last_name from cr_revisionsx cr, cr_items ci, acs_users_all u where cr.item_id=ci.item_id and cr.item_id=:item_id and cr.creation_user=u.user_id" {
    set creation_date [lc_time_fmt $creation_date "%c"]
}


