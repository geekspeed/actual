$(document).ready(function(e){

  $('.collapses').collapsiblePanel();
  $(".ui-expander").click(function(e){
      e.preventDefault(); 
  });

  $(document).on('change', '.element_option', function(e){
    e.preventDefault();
    val = $(this).val();
    next_div = $(this).parent().parent().next().next();
    graph_select = $('.select_graph_value');
    table_select = $('.select_table_value');
    field_select = $('.select_field_value');
    switch (val) {
      case "Text":
        next_div.find('.label_field').html("Text");
        $input = next_div.find('.input_text').find('input, select, textarea');
        $textarea = $("<textarea></textarea>").attr({id: $input.prop('id'), name: $input.prop('name'), class: $input.prop('class') + " summernote"});
        $input.after($textarea).remove();
        if(next_div.find('.input_text').find('.note-editor').length){
          next_div.find('.input_text').find('.note-editor').remove();
        }
        $('.summernote').summernote();
        next_div.show();
        break;
      case "Graph":
        next_div.find('.label_field').html("Graph");
        field = next_div.find('.input_text').find('input, select, textarea');
        select = graph_select.clone().find('select').attr('id', field.prop('id')).attr('class', field.prop('class')).attr('name', field.prop('name'))
        field.after(select).remove();
        if(next_div.find('.input_text').find('.note-editor').length){
          next_div.find('.input_text').find('.note-editor').remove();
        }
        next_div.show();
        break;
      case "Table":
        next_div.find('.label_field').html("Table");
        field = next_div.find('.input_text').find('input, select, textarea');
        select = table_select.clone().find('select').attr('id', field.prop('id')).attr('class', field.prop('class') +" table_element").attr('name', field.prop('name'))
        field.after(select).remove();
        if(next_div.find('.input_text').find('.note-editor').length){
          next_div.find('.input_text').find('.note-editor').remove();
        }
        next_div.show();
        break;
      case "Field":
        next_div.find('.label_field').html("Field");
        field = next_div.find('.input_text').find('input, select, textarea');
        select = field_select.clone().find('select').attr('id', field.prop('id')).attr('class', field.prop('class') + " field_element").attr('name', field.prop('name'))
        field.after(select).remove();
        if(next_div.find('.input_text').find('.note-editor').length){
          next_div.find('.input_text').find('.note-editor').remove();
        }
        next_div.show();
        break;
    }
  })

  $('.summernote').summernote();

  sortable_div();
  
  $('div.main-column, div.column').sortable({
    stop: function(event, div) {
      divs = $("div.portlet");
      i =1;
      ids = new Array();
      divs.each(function() {
      ids.push($(this).attr('id'));
      $(this).find('.panel-title').text("Element " + i);
      i++;
      })
      var order_list = ids;
        $("#custom_report_custom_report_order_attributes_order").val(order_list)
      },
  });
})
function sortable_div(){
  $( ".column, .main-column" ).sortable({
    connectWith: ".main-column",
    handle: ".portlet-header",
    cancel: ".portlet-toggle",
    placeholder: "portlet-placeholder ui-corner-all"
  });
  $( ".portlet" )
  .addClass( "ui-widget ui-widget-content ui-helper-clearfix ui-corner-all" )
  .find( ".portlet-header" )
  .addClass( "ui-widget-header ui-corner-all" )
  .prepend( "<span class='ui-icon ui-icon-minusthick portlet-toggle'></span>");
  $( ".portlet-toggle" ).click(function() {
    var icon = $( this );
    icon.toggleClass( "ui-icon-minusthick ui-icon-plusthick" );
    icon.closest( ".portlet" ).find( ".portlet-content" ).toggle();
  });
};

function sort_div(ele){
  if(ele==undefined){
    divs = $('.portlet');
  }
  else{
    divs = ele.parents().find('.portlet');
  }
  i =1;
  ids = new Array();
  divs.each(function() {
    $(this).attr('id', "element_"+i+"-"+i);
    $(this).find('.panel-title').text("Element " + i);
    i++;
  });
}

$(document).on('click', "#add_new_element", function(e){
  sortable_div();
  sort_div($(this));
  divs = $("div.portlet");
  i =1;
  ids = new Array();
  divs.each(function() {
  ids.push($(this).attr('id'));
  $(this).find('.panel-title').text("Element " + i);
  i++;
  })
  var order_list = ids;
  $("#custom_report_custom_report_order_attributes_order").val(order_list);
})

$(document).on('change', '.new_report', function(e){
  e.preventDefault();
  val = $(this).val();
  switch(val){
    case "Participant":
      $('.table_element option[value="Team"]').remove();
      $('.table_element option[value="Action list"]').remove();
      if($('.table_element option[value="Events attended"]').length == 0){
        $('.table_element').append('<option value="Events attended">Events attended</option>');
      }
    break;
    case "Project":
      $('.table_element option[value="Events attended"]').remove();
    case "Program":
      if($('.table_element option[value="Team"]').length == 0){
        $('.table_element').append('<option value="Team">Team</option><option value="Action list">Action list</option>');
      }
    break;
  }
})

  $(document).on('click', '.delete_report_element', function(e){
    e.preventDefault();
    if($(this).data("url") != ""){
      $.ajax({
        url: $(this).data("url"),
        type: 'delete',
        success: function(data){
          window.location.reload();
        },
        error: function(){
          alert('Request failed. Sorry, we are analyzing the cause of this problem');
        }
      })
      }
      else{
        $(this).parents('.fields').remove();
        sort_div();
      }
  })
