<master src="../../../master">
  <property name="title">@title@</property>
  <if @header_stuff@ not nil><property name="header_stuff">@header_stuff;noquote@</property></if>
  <property name="context">@context;noquote@</property>
  <if @focus@ not nil><property name="focus">@focus@</property></if>
  
<div id="main">
    <div id="contentpane">
        <slave>
    </div>
</div>
