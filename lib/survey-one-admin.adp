<tr class="even">
   <td>Report Creation (v2)</td>
   <td><a href="../reports/manage/">Manage Reports</a><br />
   <if @report_template_id@ ne 0><a href="../reports/@survey_id@">View Report</a> (note you must have responded to the survey first)</if><else><font color="red">No report associated.</font></else><br />
 <a href="../reports/manage/template-select?survey_id=@survey_id@">Associate a report to this survey</a> <if @report_template_name@ ne "">(currently associated report is: <a href="../reports/manage/@report_template_name@">@report_template_name@</a>)</if><br />
<i>Note:</i> Creating a new report does not automatically associate at this point.  After creating a new report, click on associate a report to this survey.</td>
 </tr>