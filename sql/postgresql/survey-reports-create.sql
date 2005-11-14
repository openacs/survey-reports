-- 
-- packages/survey/sql/postgresql/survey-reports-create.sql
-- 
-- @author Deds Castillo (deds@i-manila.com.ph)
-- @creation-date 2004-10-21
-- @arch-tag: 3e2487d0-6986-4257-ba5e-a352d23a0c8e
-- @cvs-id $Id$
--

create table survey_reports_survey_map (
    template_id integer
                constraint surv_rep_surv_map_template_id_fk
                references cr_items
                on delete cascade,
    survey_id   integer
                constraint surv_rep_surv_map_survey_id_fk
                references surveys
                on delete cascade,
                primary key (template_id, survey_id),
    survey_variables_p boolean,
    survey_show_report_p boolean
);

