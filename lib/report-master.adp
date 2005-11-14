<master>
<property name=current_survey_id>@survey_id@</property>
<property name="header_stuff"><style>.report-list { font-size: 75%; }</style></property>
<if @admin_p@ not nil and @admin_p@ eq 1>
<p><a href="@manage_url@" title="Edit" class="button">Edit report template</a></p>
</if>
<p><a href="@download_url@">Export Report</a>. (Please be patient, this may take 15-20 seconds.)</p>
<slave>