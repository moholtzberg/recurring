var orders_table = null;
$(document).on('turbolinks:load', function() {
  if ($('#orders-table').length != 0) {
    var common_filters = [];
    orders_table = $('#orders-table').dataTable({
      "initComplete": function () {
        var self = this
        $('#orders-table').on('filters-update', function() {
          self.api().ajax.reload()
        })
      },
      "processing": true,
      "serverSide": true,
      "responsive": true,
      "sServerMethod": 'POST',
      "ajax": {
        "url": $('#orders-table').data('source'),
        "data": function ( d ) {
          d.filters = common_filters;
        }
      },
      stateSave: true,
      stateSaveCallback: function(settings,data) {
        data.filters = common_filters;
        key = 'DataTables_' + settings.sInstance + '_' + window.location.pathname
        localStorage.setItem( key, JSON.stringify(data) )
      },
      stateLoadCallback: function(settings) {
        key = 'DataTables_' + settings.sInstance + '_' + window.location.pathname
        data = localStorage.getItem( key );
        if (data.filters) { common_filters = data.filters; }
        $('#orders-table').trigger('filters-restore')
        return JSON.parse( data )
      },
      "pagingType": "full_numbers",
      "autoWidth": false,
      "sDom": 'rt<"row"<"col-sm-2"l><"col-sm-5"i><"col-sm-5"p>>',
      "columns": [
        {"data": "number", className: "all"},
        {"data": "account", className: "all"},
        {"data": "total", sortable: false, className: "all"},
        {"data": "sub_total", className: "all"},
        {"data": "shipped", sortable: false, className: "min-desktop"},
        {"data": "fulfilled", sortable: false, className: "min-desktop"},
        {"data": "balance_due", sortable: false, className: "min-desktop"},
        {"data": "submitted_at", className: "min-desktop"},
        {"data": "state", className: "all"},
        {"data": "dropdown", sortable: false, className: "all"}
      ]
    });
    $(function() {

      var FORMBUILDER = FORMBUILDER || {};

      FORMBUILDER.filters = common_filters;
      FORMBUILDER.saved_filters = [];
      FORMBUILDER.current_filter = {};
      FORMBUILDER.possible_column_filters = {
        number: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
        account: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
        state: ['Equal to', 'Contains', 'Begins with', 'Ends with', 'Not equal to'],
        submitted_at: ['Equal to', 'Greater than', 'Less than'],
        sub_total: ['Equal to', 'Greater than', 'Less than']
      }

      FORMBUILDER.actions = {

        init: function(){

          FORMBUILDER.actions.addFilter();
          FORMBUILDER.actions.removeFilter();
          FORMBUILDER.actions.validateForm();
          FORMBUILDER.actions.fieldValid(key);
          FORMBUILDER.actions.clearErrors();
          FORMBUILDER.actions.renderFilters();
          FORMBUILDER.actions.resetForm();
          FORMBUILDER.actions.updateCurrentFilter();

        },

        addFilter: function(){
          FORMBUILDER.actions.clearErrors();
          if (FORMBUILDER.actions.validateForm()) {
            FORMBUILDER.filters.push($.extend({}, FORMBUILDER.current_filter));
            FORMBUILDER.actions.resetForm();
            FORMBUILDER.actions.renderFilters();
          }
        },

        removeFilter: function(e){
          var index = parseInt($(e.target).closest('tr').data( "index" ));
          FORMBUILDER.filters.splice(index, 1);
          FORMBUILDER.actions.resetForm();
          FORMBUILDER.actions.renderFilters();
        },

        validateForm: function(){
          var valid = true;
          ['column_name', 'filter', 'value'].forEach(function(key){
            if (!FORMBUILDER.actions.fieldValid(key)) { 
              $('#add_filter_form #' + key).parent().addClass('has-error');
              valid = false;
            }
          })
          return valid;
        },

        fieldValid: function(key) {
          var value = FORMBUILDER.current_filter[key]
          switch(key) {
            case 'column_name':
              return value
              break;
            case 'filter':
              return value
              break;
            case 'value':
              return value
              break;
          }
        },

        clearErrors: function() {
          $('#add_filter_form td').removeClass('has-error');
        },

        renderFilters: function() {
          $('tr.filter_data').remove();
          FORMBUILDER.filters.forEach(function(el, i) {
            var item = document.createElement("tr");
            item.className = "filter_data";    
            item.setAttribute('data-index', i)
            $(item)
            .append(
              $("<td class='column_name'>")
              .append(
                el.column_name
              )
            )
            .append(
              $("<td class='filter'>")
              .append(
                el.filter
              )
            )
            .append(
              $("<td class='value'>")
              .append(
                el.value
              )
            )
            .append(
              $("<td span='10%' class='text-center'>")
              .append(
                $('<a href="#" class="remove-filter"><i class="fa fa-trash"></i></a>')
              )
            )
            $('.column-filters').prepend(item)
          })
          $('.remove-filter').click(function(e){
            e.stopPropagation();
            e.preventDefault();
            FORMBUILDER.actions.removeFilter(e);
          })
        },

        resetForm: function() {
          $('#add_filter_form :input').val('').trigger('change');
          FORMBUILDER.actions.updateCurrentFilter();
        },

        updateCurrentFilter: function() {
          var filter = FORMBUILDER.current_filter;
          filter.column_name = $('#add_filter_form :input#column_name').val();
          filter.filter = $('#add_filter_form :input#filter').val();
          filter.value = $('#add_filter_form :input#value').val();
        },

        setValueFieldType: function() {
          if (FORMBUILDER.current_filter['column_name'] == 'submitted_at') {
            $('#add_filter_form :input#value').datepicker();
          } else {
            $('#add_filter_form :input#value').datepicker('destroy');
          }
        }

      }

      $('.add-filter').click(function(e){
        e.stopPropagation();
        e.preventDefault();
        FORMBUILDER.actions.addFilter();
      })

      $('#add_filter_form :input').change(function(){
        FORMBUILDER.actions.updateCurrentFilter();
      })

      $("#add_filter_form :input#column_name").on('change', function(e){
        var column_name = $("#add_filter_form :input#column_name").val();
        var $el = $(":input#filter");
        $el.empty();
        $el.append($("<option value></option>"));
        var filters = FORMBUILDER.possible_column_filters[column_name]
        $.each(filters, function(index,value) {
          $el.append($("<option></option>")
             .attr("value", value).text(value));
        });
        $("#add_filter_form :input#value").val('');
        FORMBUILDER.actions.setValueFieldType();
      });

      $('button#update_filters').click(function(){
        common_filters = JSON.parse(JSON.stringify(FORMBUILDER.filters));
        $('#orders-table').trigger('filters-update')
        $('#filterModal').modal("toggle")
      })

      $('button#cancel_filters').click(function(){
        FORMBUILDER.filters = JSON.parse(JSON.stringify(common_filters));
        FORMBUILDER.actions.renderFilters();
        $('#filterModal').modal("toggle")
      })

      $('#orders-table').on('filters-restore', function() {
        FORMBUILDER.filters = JSON.parse(JSON.stringify(common_filters));
        FORMBUILDER.actions.renderFilters();
      })
    });
  }
});

$(document).on('turbolinks:before-cache', function() {
  if ($('#orders-table_wrapper').length != 0) {
    orders_table.fnDestroy();
    orders_table = null;
  }
})