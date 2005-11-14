<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
  <html>
    <head>
      <title>View Template</title>
      <link rel="stylesheet" type="text/css" href="/resources/acs-templating/lists.css" media="all">
      <link rel="stylesheet" type="text/css" href="/resources/acs-templating/forms.css" media="all">
      <link rel="stylesheet" type="text/css" href="/resources/acs-subsite/site-master.css" media="all">
      <link rel="stylesheet" type="text/css" href="/resources/dotlrn/dotlrn-master.css" media="all">
      <link rel="stylesheet" type="text/css" href="/styles/zebra.css" media="all">

      <link rel="stylesheet" type="text/css" href="/resources/acs-subsite/new-ui.css" media="all">
      <script src="/resources/acs-subsite/core.js" language="javascript"></script>
      <script src="/scripts/zebra.js" language="javascript"></script>
    
      
<STYLE TYPE="text/css">

H3 {
   FONT-FAMILY: Arial, Helvetica, sans-serif;
   FONT-SIZE: small;
   COLOR: #5182B6; 
   FONT-WEIGHT: bold;
   MARGIN-BOTTOM: 0px;
}


TD.dark-line {
}

TD.light-line {

}

.header-text {
    FONT-SIZE: ; 
    BACKGROUND: white; 
    WIDTH: 100px; 
    COLOR: ; 
    FONT-FAMILY: verdana;
    WHITE-SPACE: nowrap;
    font-weight: bold;
}

.element-header-text {
    COLOR: #5182B6; 
}

TD.element-header-buttons {
    BACKGROUND: white; 
    COLOR: #5182B6; 
    WHITE-SPACE: nowrap;
}
IMG.element-header-button {
    BACKGROUND: #5182B6; 
    COLOR: #5182B6;
}

TR.table-header {
    BACKGROUND: #5182B6;
    FONT-SIZE: small;
    FONT-FAMILY: Arial, Helvetica, sans-serif; 
}

STRONG.table-header {
    BACKGROUND: #5182B6; 
    COLOR: FFFFFF; 
    FONT-FAMILY: Arial, Helvetica, sans-serif; 
    FONT-SIZE: small;
}

TD.selected {
    BACKGROUND: #5182B6; 
    COLOR: FFFFFF; 
    FONT-FAMILY: Arial, Helvetica, sans-serif; 
    font-weight: bold;
    BORDER-RIGHT: medium none; BORDER-TOP: medium none; BORDER-LEFT: medium none; BORDER-BOTTOM: medium none;
}

TABLE.z_light {
    BACKGROUND: white;
}

TABLE.z_dark {
    BACKGROUND: #E6EBF0;
}

TR.even {
    BACKGROUND: white;
}

TR.odd {
    BACKGROUND: #E6EBF0;
}

HR.main_color {
    COLOR: #5182B6;
}

TR.table-title {
    BACKGROUND: #E6EBF0;
}

TD.cal-week {
    BACKGROUND: white;
    VALIGN: top;
}

TD.cal-week-event {
    BACKGROUND: #E6EBF0;
}

TD.cal-month-day {
    BACKGROUND: #E6EBF0;
   BORDER: 1px c0c0c0 solid; padding-top: 1px; padding-right: 1px; padding-bottom: 1px; padding-left: 1px ;
}

TD.cal-month-today {
    BACKGROUND: white;
    BORDER-RIGHT: grey 1px solid; BORDER-TOP: grey 1px solid; BORDER-LEFT: grey 1px solid; BORDER-BOTTOM: grey 1px solid;
}

.navbar A {
    COLOR: #5182B6; 
    TEXT-DECORATION: none; 
    text-weight: bold;
}

.navbar A:visited {
    COLOR: #5182B6; 
    TEXT-DECORATION: none; 
    text-weight: bold;
}

TD.navbar {
    COLOR: #5182B6; 
    TEXT-DECORATION: none; 
    font-weight: bold;
    FONT-FAMILY: Arial, Helvetica, sans-serif; 
    text-align: center; 
    FONT-SIZE: x-small;
}

TD.navbar-selected {
    background-color: #5182B6; 
    COLOR: FFFFFF; 
    FONT-FAMILY: Arial, Helvetica, sans-serif; 
    FONT-SIZE: x-small; 
    text-align: center; 
    font-weight: bold;
    TEXT-DECORATION: none; 
}

TABLE.table-display {
    BORDER-RIGHT: #5182B6 1px solid; BORDER-TOP: #5182B6 1px solid; BORDER-LEFT: #5182B6 1px solid; BORDER-BOTTOM: #5182B6 1px solid;
}

TABLE.portal-page-config {
    BACKGROUND: #E6EBF0;
    WIDTH: 700px;
    CELLPADDING: 5;
}


TD.bottom-border {

}

TR.bottom-border {

}

TD.center {
    ALIGN: center;
}


</STYLE>


    </head>
<body>

<table class="table-display">
<tr class="odd">
<td colspan="3">
This page lets you write a template for displaying a report on the above surveys.  In the template you can have HTML, 
variable references, and conditional text.  Variable references consist of putting '@' around the variable name.  Below is
a table of the names defined for this survey.  If there was no response to a particular question, then the corresponding
variable will contain an empty string. Conditional text consists of text surrounded by &lt;if&gt;, 
&lt;elseif&gt;, &lt;else&gt;, &lt;switch&gt;, 
&lt;case&gt;, or &lt;default&gt; tags.  See the 
<a href="http://openacs.org/doc/acs-templating/tagref/if">if, elseif, and else tag</a> and 
<a href="http://openacs.org/doc/acs-templating/tagref/switch">switch, case, and default tag</a> references for more details.
</td>
</tr>

<tr class="even"><th colspan="3">Standard for all Reports</th></tr>
<tr class="odd"><td>User Info<br>These are standard variables defined for the user viewing the report.</td><td colspan="2">
<ul>
<li>&#64;user_id&#64; 
<li>&#64;username&#64; 
<li>&#64;first_names&#64; 
<li>&#64;last_name&#64; 
<li>&#64;full_name&#64; = "first_names last_name"
<li>&#64;email&#64; 
<li>&#64;url&#64; 
<li>&#64;screen_name&#64; 
<li>&#64;member_state&#64; 
<li>&#64;current_date&#64; 
</td>
</tr>
<tr class="odd">
<td>Survey Info</td>
<td>&#64;response_date&#64;</td>
<td>Date the user last took the survey</td>
</tr>
<tr class="odd">
<td></td>
<td><ul>
<li>&#64;edit_url&#64;</li>
<li>&#64;edit_link&#64;</li>
</ul>
</td>
<td>Edit this response</td>
</tr>

<multiple name="vars">
<tr class="even"><th>Section: @vars.name@ (@vars.section_pretty_id@)</th>
<th>Variable Names</th>
<th>Possible Answers (<em>type</em> or choices)</th>
</tr>

<group column="section_id">
<tr class="odd">
<td>Question<if @vars.required_p@ false> (optional)</if>: @vars.question_text@</td>
<td>@@vars.full_id@@<if @vars.short_id@ not nil> or @@vars.short_id@@</if><if @vars.median_p@ eq 1><br />\@@vars.full_id@_median\@</if></td>
<td>@vars.possible_values;noquote@</td>
</tr>
</group>

</multiple>
</table>
</body>
</html>