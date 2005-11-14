<if @list_properties.bulk_actions@ not nil>
  <script language="JavaScript" type="text/javascript">
    function ListFindInput() {
      if (document.getElementsByTagName) {
        return document.getElementsByTagName('input');
      } else if (document.all) {
        return document.all.tags('input');
      }
      return false;
    }

    function ListCheckAll(listName, checkP) {
      var Obj, Type, Name, Id;
      var Controls = ListFindInput(); if (!Controls) { return; }
      // Regexp to find name of controls
      var re = new RegExp('^' + listName + ',.+');

      checkP = checkP ? true : false;

      for (var i = 0; i < Controls.length; i++) {
        Obj = Controls[i];
        Type = Obj.type ? Obj.type : false;
        Name = Obj.name ? Obj.name : false;
        Id = Obj.id ? Obj.id : false;

        if (!Type || !Name || !Id) { continue; }

        if (Type == "checkbox" && re.exec(Id)) {
          Obj.checked = checkP;
        }
      }
    }

    function ListBulkActionClick(formName, url) {
      if (document.forms == null) return;
      if (document.forms[formName] == null) return;
    
      var form = document.forms[formName];

      form.action = url;
      form.submit();
    }
  </script>
</if>

<div class="@list_properties.class;noquote@">

    <form name="@list_properties.name@" method="get">

  <!-- actions start -->
  <if @actions:rowcount@ gt 0>
  <div class="list-actions">
      <multiple name="actions">
        <a href="@actions.url@" class="list-action" title="@actions.title;noquote@">@actions.label;noquote@</a>
      </multiple>
  </div>
  </if>
  <!-- actions edit -->

  <!-- bulk action start -->
  <if @list_properties.bulk_actions@ not nil>
    <div class="list-bulk-actions">
    @list_properties.bulk_action_export_chunk;noquote@

  <noparse><if \@@list_properties.multirow@:rowcount@ gt 0></noparse>
    <if @bulk_actions:rowcount@ gt 0>
          <multiple name="bulk_actions">
            <a href="#" id="@bulk_actions.label;noquote@-bulkaction" class="list-button" title="@bulk_actions.title;noquote@"
            onclick="ListBulkActionClick('@list_properties.name;noquote@', '@bulk_actions.url;noquote@')">@bulk_actions.label;noquote@</a>
          </multiple>
    </if>
  <noparse></if></noparse>

    </div>
  </if>
  <!-- bulk action end -->

  <!-- paginator start -->
  <if @list_properties.page_size@ not nil>
    <noparse>
      <if \@paginator.page_count@ gt 1>
        <div class="list-paginator">
            <if \@paginator.group_count@ gt 1>
              <if \@paginator.previous_group_url@ not nil>
                <a class="prev-group" href="\@paginator.previous_group_url;noquote@" title="\@paginator.previous_group_context;noquote@"><span class="img-alt">&lt;&lt;</span></a>
              </if>
            </if>

            <if \@paginator.previous_page_url@ not nil>
              <a class="prev-page" href="\@paginator.previous_page_url;noquote@" title="\@paginator.previous_page_context;noquote@"><span class="img-alt">&lt;</span></a>
            </if>

            <multiple name="paginator_pages">
                <if \@paginator.current_page@ ne \@paginator_pages.page@>
                  <a class="page" href="\@paginator_pages.url;noquote@" title="\@paginator_pages.context;noquote@">\@paginator_pages.page;noquote@</a>
                </if>
                <else>
                  <span class="current-page">\@paginator_pages.page;noquote@</span>
                </else>
            </multiple>

            <if \@paginator.next_page_url@ not nil>
              <a class="next-page" href="\@paginator.next_page_url;noquote@" title="\@paginator.next_page_context;noquote@"><span class="img-alt">&gt;</span></a>
            </if>
            <if \@paginator.group_count@ gt 1>
              <if \@paginator.next_group_url@ not nil>
                <a class="next-group" href="\@paginator.next_group_url;noquote@" title="\@paginator.next_group_context;noquote@"><span class="img-alt">&gt;&gt;</span></a>
              </if>
            </if>
        </div>
      </if>
    </noparse>
  </if>
  <!-- paginator end -->

  <!-- table data start -->
  <table class="list-data">

    <!-- table header start -->
    <multiple name="elements">
      <tr class="list-header">
        <group column="subrownum">
          <th class="@elements.class;noquote@"@elements.cell_attributes;noquote@>
            <if @elements.orderby_url@ not nil>
              <if @elements.ordering_p@ true>
                    <if @elements.orderby_direction@ eq "desc">
                        <a class="sort-desc" href="@elements.orderby_url;noquote@" title="@elements.orderby_html_title;noquote@"> <span class="img-alt">v</span>
                    </if>
                    <else>
                        <a class="sort-asc" href="@elements.orderby_url;noquote@" title="@elements.orderby_html_title;noquote@"> <span class="img-alt">^</span>
                    </else>
                @elements.label;noquote@</a>
              </if>
              <else>
                <a href="@elements.orderby_url;noquote@" title="@elements.orderby_html_title;noquote@">@elements.label;noquote@</a>
              </else>
            </if>
            <else>
              @elements.label;noquote@
            </else>
          </th>
        </group>
      </tr>
    </multiple>
    <!-- table header end -->

  <noparse>
    <if \@@list_properties.multirow@:rowcount@ eq 0>
      <tr class="list-odd">
        <td class="list" colspan="@elements:rowcount@">
          @list_properties.no_data;noquote@
        </td>
      </tr>
    </if>
    <else>
      <multiple name="@list_properties.multirow@">
  </noparse>

          <multiple name="elements">
    <noparse>
              <if \@@list_properties.multirow@.rownum@ odd>
                <tr class="list-odd">
              </if>
              <else>
                <tr class="list-even">
              </else>
    </noparse>

              <group column="subrownum">
                <td class="@elements.class@"@elements.cell_attributes;noquote@>
                  <listelement name="@elements.name;noquote@"> <noparse></noparse>
                </td>
              </group>
            </tr>
          </multiple>

    <noparse>
        </multiple>
      </else>
    </noparse>
  </table>
  <!-- table data end -->

  <!-- paginator start -->
  <if @list_properties.page_size@ not nil>
    <noparse>
      <if \@paginator.page_count@ gt 1>
        <div class="list-paginator">
            <if \@paginator.group_count@ gt 1>
              <if \@paginator.previous_group_url@ not nil>
                <a class="prev-group" href="\@paginator.previous_group_url;noquote@" title="\@paginator.previous_group_context;noquote@"><span class="img-alt">&lt;&lt;</span></a>
              </if>
            </if>

            <if \@paginator.previous_page_url@ not nil>
              <a class="prev-page" href="\@paginator.previous_page_url;noquote@" title="\@paginator.previous_page_context;noquote@"><span class="img-alt">&lt;</span></a>
            </if>

            <multiple name="paginator_pages">
                <if \@paginator.current_page@ ne \@paginator_pages.page@>
                  <a class="page" href="\@paginator_pages.url;noquote@" title="\@paginator_pages.context;noquote@">\@paginator_pages.page;noquote@</a>
                </if>
                <else>
                  <span class="current-page">\@paginator_pages.page;noquote@</span>
                </else>
            </multiple>

            <if \@paginator.next_page_url@ not nil>
              <a class="next-page" href="\@paginator.next_page_url;noquote@" title="\@paginator.next_page_context;noquote@"><span class="img-alt">&gt;</span></a>
            </if>
            <if \@paginator.group_count@ gt 1>
              <if \@paginator.next_group_url@ not nil>
                <a class="next-group" href="\@paginator.next_group_url;noquote@" title="\@paginator.next_group_context;noquote@"><span class="img-alt">&gt;&gt;</span></a>
              </if>
            </if>
        </div>
      </if>
    </noparse>
  </if>
  <!-- paginator end -->


  <!-- bulk action start -->
  <if @list_properties.bulk_actions@ not nil>
    <div class="list-bulk-actions">

  <noparse><if \@@list_properties.multirow@:rowcount@ gt 0></noparse>
    <if @bulk_actions:rowcount@ gt 0>
          <multiple name="bulk_actions">
            <a href="#" id="@bulk_actions.label;noquote@-bulkaction" class="list-button" title="@bulk_actions.title;noquote@"
            onclick="ListBulkActionClick('@list_properties.name;noquote@', '@bulk_actions.url;noquote@')">@bulk_actions.label;noquote@</a>
          </multiple>
    </if>
  <noparse></if></noparse>

    </div>
  </if>
  <!-- bulk action end -->

    </form>

  </div>


