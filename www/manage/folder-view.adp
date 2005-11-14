<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>

<fieldset class="formtemplate">
<legend>Folder Properties</legend>
<include src="/packages/survey-reports/lib/report-folder-form" folder_id="@current_item.item_id@" return_url="@return_url@" form_mode="display">
</fieldset>

<fieldset class="formtemplate">
<legend>Folder Contents</legend>
<formtemplate style="inline" id="add-item"></formtemplate>
<listtemplate name="item_list"></listtemplate>
</fieldset>
