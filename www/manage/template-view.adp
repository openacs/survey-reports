<master>
<property name="title">@title@</property>
<property name="context">@context@</property>

<p />
<if @unused_count@ gt 0>
<formtemplate id="survey_form" style="inline"></formtemplate>
</if>
<h4>Variables from these surveys are available in this report</h4>
<listtemplate name="surveys_used"></listtemplate>
<p />
<ul>
<li><a href="views?object_id=@item_id@">View all users who viewed this report</a>
<li><a href="#revisions">See list of all revisions</a><br />
<if @no_surveys_associated_p@ nil>
<li><a href="available-vars?name=@content.name@" target="_new">View available page variables</a> (opens in a new window)<br />
</if>
<li>Link to this report: @link_to_this_url;noquote@<br />
</ul>
<p><b>This Version</b>: @template_revision.version_number@ <if @template_revision.version_number@ eq @template_revision.live_version_number@> (This version is live)</if><else> <b>Live Version</b>: @template_revision.live_version_number@ <a href="@publish_url@" title="Publish this version of the report" class="button">Publish this version</a></else></p>
<include src="/packages/survey-reports/lib/template-form" revision_id="@revision_id@" return_url="@return_url@" parent_id="@parent_id@">

<p />
Revision List:<br />
<a name="revisions"></a>
<include src="/packages/survey-reports/lib/revision-list" item_id="@template_revision.item_id@" publish_url="@publish_url@" version="@template_revision.version_number@">
