<master>
  <property name="title">@title@</property>
  <property name="header_stuff">@header_stuff@</property>
  <property name="context">@context@</property>

<if @viewer_id@ nil>
<include src="/packages/views/lib/views-chunk"
    package_id="@package_id@"
    object_type="@object_type@"
    object_id="@object_id@"
    sortby="@sortby@"
    filter_url="@filter_url@"
>
</if>
<else>
<include src="/packages/views/lib/views-chunk"
    package_id="@package_id@"
    object_type="@object_type@"
    object_id="@object_id@"
    sortby="@sortby@"
    filter_url="@filter_url@"
    viewer_id="@viewer_id@"
>
</else>

