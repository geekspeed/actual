jQuery(document).ready(function($){
	
 $('.eventRow').click(function(){
    var col = $('#event_col').html().replace(/-1-/g, new Date().getTime());
    $(this).parents('.titleLine').next().append("<tr>"+col+"</tr>");
    $('.timepicker').timepicker();
    return false;
  });

$(document).on('click', '.manage_participent', function(event){
    event.preventDefault();
    program_id = $("#program_id").val();
    event_id = $("#event_id").val();
    session_id = $(this).attr("data-target");
    $.ajax({
        url: "/programs/"+program_id+"/events/"+event_id+"/manage_participant?event_session="+session_id+"",
        async: false,
        type: 'get',
        success: function(data, status){
                $("#template_area").html("");
                $("#template_area").html(data);
                $("#manage_participant").modal('toggle');
        },
        error: function(error){
                alert("Request failed. Sorry, we are analyzing the cause of this problem");
        },
        beforeSend: function(){
          $(this).prop('disabled',true);
        },
        complete: function(){
          $(this).prop('disabled',false);
        }
    });
});

$(document).on('click', '.reject_participant_button', function(event){
    event.preventDefault();
    program_id = $("#program_id").val();
    session_id = $(this).attr("data-target");
    $.ajax({
        url: "/programs/"+program_id+"/events/reject_participant",
        async: false,
        type: 'post',
        data: $("form#form_"+session_id+"").serialize(),
        dataType: "JSON",
        success: function(data){
                $("#reject_"+data.event_record_id+"").modal('toggle');
                $("#manage_participant").modal('toggle');
                $('body').find('.modal-backdrop').remove();
                $("#template_area").html("");
                $("#manage_link_"+data.event_session_id+"").click();
        },
        error: function(error){
                alert("Request failed. Sorry, we are analyzing the cause of this problem");
        },
        beforeSend: function(){
          $(this).prop('disabled',true);
        },
        complete: function(){
          $(this).prop('disabled',false);
        }
    });
});

	$('.collapses').collapsiblePanel();
	$(".ui-expander").click(function(e){
  		e.preventDefault(); 
	});

  $(document).on('change', '.confirmed_at', function(e){
    e.preventDefault();
    var record_id = $(this).data('record-id');
    checked = $(this).is(':checked');
    $.ajax({
      url: $(this).data('url'),
      type: 'get',
      data: {record_id: record_id, confirmed: checked},
      success: function(data){
      },
      error: function(error){
        alert("Request failed. Sorry, we are analyzing the cause of this problem");
      }
    })
  });

  $('.summernote').summernote();

  $('.timepicker').timepicker();
  $( ".radioset" ).buttonset();

})
