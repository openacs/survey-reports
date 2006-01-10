# packages/bcms-ui-base/lib/revision-list.tcl
#
# revisions
#
# @author Deds Castillo (deds@i-manila.com.ph)
# @creation-date 2004-10-18
# @arch-tag: f9bc2802-3c4a-4289-a692-9aba860c67a4
# @cvs-id $Id$

foreach required_param {item_id current_revision_id} {
    if {![info exists $required_param]} {
        return -code error "$required_param is a required parameter."
    }
}

set package_url [ad_conn package_url]

set current_url "${package_url}manage/[ad_conn path_info]"

template::list::create \
    -name revision_list \
    -multirow revision_list \
    -key revision_id \
    -pass_properties {version} \
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
            display_template {<a href="@revision_list.preview_url@">Preview</a> | <a href="@revision_list.manage_url@">Manage</a> | <if @revision_list.live_revision_id@ eq @revision_list.revision_id@><b><a href="@revision_list.unpublish_url@">Unpublish</a></b></if><else><a href="@revision_list.publish_url@">Publish</a></else>}
        }
        
    }

set return_url [export_vars -base "$current_url" {{revision_id $current_revision_id}}]
db_multirow -extend { publish_url unpublish_url preview_url manage_url } revision_list get_revisions "select ci.live_revision as live_revision_id, cr.*, content_revision__get_number(cr.revision_id) as version_number, u.first_names, u.last_name from cr_revisionsx cr, cr_items ci, acs_users_all u where cr.item_id=ci.item_id and cr.item_id=:item_id and cr.creation_user=u.user_id order by version_number desc" {
    set creation_date [lc_time_fmt $creation_date "%c"]
    set manage_url [export_vars -base "$current_url" {revision_id}]
    set preview_url [export_vars -base "${package_url}manage/template-preview" {revision_id return_url}]
    set publish_url [export_vars -base "${package_url}manage/template-write" {revision_id return_url}]
    set unpublish_url [export_vars -base "${package_url}manage/template-unpublish" {revision_id return_url}]
}


