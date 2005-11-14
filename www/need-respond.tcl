ad_page_contract {
} {
    survey_id:notnull
    {return_url "[dotlrn_community::get_url]"}
}

#CM HACK Return url is ending up with 2 survey_ids and right now we just want to go back the main page of the community.

set return_url [dotlrn_community::get_community_url "[dotlrn_community::get_community_id]"]

get_survey_info -survey_id $survey_id

set respond_url [export_vars -base "../respond" {survey_id return_url}]