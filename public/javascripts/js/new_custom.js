jQuery(document).ready(function($){ 

/*Feedback and question*/
	jQuery('body').on('click', '#feedbacker_link', function(){
		jQuery('#feedbacker_link').hide();
		jQuery('#feedback_container').show();
		return false;
	});

	jQuery('body').on('click', '.feedback_cancel', function(){
		jQuery('#feedback_container').hide();
		jQuery('#feedbacker_link').show();
	});

	jQuery('#feedback_form').bind('submit', function() {  
        var form = jQuery('#feedback_form');  
        var data = form.serialize();
		jQuery.ajax($(this).attr('action'), {action:'jfeedbacker', type: "POST", data: data}, function(datahtml) {
		});
	  jQuery('#feedback_container').hide();
		jQuery('#feedbacker_link').hide();
		jQuery('#feedback_container_ok').show();
		jQuery('#feedback_form .description').val('');
		jQuery('#feedback_form .title').val('');
		return false;
  });  

	jQuery('body').on('click', '.closefeedback', function(){
		jQuery('#feedback_container_ok').hide();
		jQuery('#feedbacker_link').show();
		return false;
	});

  $('.container_tags').on('click', '.delTag', function(){
      $(this).parent().remove();
      return false;
  });
  $('.addPitchTag').click(function(e){
    var value = $('.pitchTag').val();
    var field_name = $('.pitchTag').data("field-name");
    if(value != ""){
      $('#tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+ field_name +'" readonly="readonly" /></div>');
      $('.pitchTag').val('');
    }
    e.preventDefault();
  });
    
  $('.container_add_tag').on('click', '.delTag', function(){
    $(this).parent().remove();
    return false;
  });
	
	jQuery('body').on('click', '#question_link', function(){
		jQuery('#question_link').hide();
		jQuery('#question_container').show();
		return false;
	});

	jQuery('body').on('click', '.question_cancel', function(){
		jQuery('#question_container').hide();
		jQuery('#question_link').show();
	});

	jQuery('#question_form').bind('submit', function() {  
    var form = jQuery('#question_form');  
    var data = form.serialize();
		jQuery.ajax($(this).attr('action'), {action:'jquestion', type: "POST", data: data}, function(datahtml) {

		});
        jQuery('#question_container').hide();
		jQuery('#question_link').hide();
		jQuery('#question_container_ok').show();
		jQuery('#question_form .description').val('');
		jQuery('#question_form .title').val('');
		return false;
    }); 
     
	jQuery('body').on('click', '.closequestion', function(){
		jQuery('#question_container_ok').hide();
		jQuery('#question_link').show();
		return false;
	});

	jQuery('#main').on('click', '.addImage', function(){
		var cl = jQuery(this).attr('name');
		jQuery(this).parent().parent().find(".link_box").find("span").hide();
		jQuery(this).parent().parent().find(".link_box").fadeIn().find("."+cl).fadeIn();
		jQuery(this).parent().parent().find(".link_box").find('input').val('');
		return false;
	});

	jQuery('#main').on('click', '.showNewTagCont', function(){
		jQuery(this).parent().find('.newTag').show();
		jQuery(this).hide();
		return false;
	})

	jQuery('#main').on('click', '.commentFeed', function(){
		jQuery(this).parent().parent().find('.comments').fadeIn();
		jQuery(this).parent().parent().find('.new-comment-box').fadeIn();
		return false;
	});

	/*Feed Likes*/
  $(".actions").on("ajax:success", ".likeFeed", function(evt, data, status, response){
  	if(data.success == "OK")
  	{
  		$(this).removeClass('likeFeed').addClass('unlikeFeed');
  		var href_val = $(this).attr('href').replace(/like/g, 'unlike');
  		$(this).attr('href',href_val);
  		$(this).html("<span class='hearthbox'></span> UnLike");
			var likes = jQuery(this).parent().find('.showLikes>.anzahl');
			$(likes).html(data.likes_count);
  	}
  });

  $(".actions").on("ajax:success", ".unlikeFeed", function(evt, data, status, response){
  	if(data.success == "OK")
  	{
  		$(this).removeClass('unlikeFeed').addClass('likeFeed');
  		var href_val = $(this).attr('href').replace(/unlike/g, 'like');
  		$(this).attr('href',href_val);
  		$(this).html("<span class='hearthbox'></span> Like");
			var likes = jQuery(this).parent().find('.showLikes>.anzahl');
			$(likes).html(data.likes_count);
  	}
  });
  /*Feed Likes*/

  /*Feed Likes*/
  $(".feed-events").on("ajax:success", ".likeFeed", function(evt, data, status, response){
    if(data.success == "OK")
    {
      $(this).removeClass('likeFeed').addClass('unlikeFeed');
      var href_val = $(this).attr('href').replace(/like/g, 'unlike');
      $(this).attr('href',href_val);
      $(this).html("<i class='glyphicon glyphicon-heart user_defined_color'></i> UnLike");
      var likes = jQuery(this).parent().parent().find('.anzahl');
      $(likes).html(data.likes_count);
    }
  });

  $(".feed-events").on("ajax:success", ".unlikeFeed", function(evt, data, status, response){
    if(data.success == "OK")
    {
      $(this).removeClass('unlikeFeed').addClass('likeFeed');
      var href_val = $(this).attr('href').replace(/unlike/g, 'like');
      $(this).attr('href',href_val);
      $(this).html("<i class='glyphicon glyphicon-heart-empty user_defined_color'></i> Like");
      var likes = jQuery(this).parent().parent().find('.anzahl');
      $(likes).html(data.likes_count);
    }
  });

  $(".profile_feed-events").on("ajax:success", ".likeFeed", function(evt, data, status, response){
    if(data.success == "OK")
    {
      $(this).removeClass('likeFeed').addClass('unlikeFeed');
      var href_val = $(this).attr('href').replace(/like/g, 'unlike');
      $(this).attr('href',href_val);
      $(this).html("<i class='glyphicon glyphicon-heart'></i> UnLike");
      var likes = jQuery(this).parent().parent().find('.update_anzahl');
      $(likes).html(data.likes_count);
    }
  });

  $(".profile_feed-events").on("ajax:success", ".unlikeFeed", function(evt, data, status, response){
    if(data.success == "OK")
    {
      $(this).removeClass('unlikeFeed').addClass('likeFeed');
      var href_val = $(this).attr('href').replace(/unlike/g, 'like');
      $(this).attr('href',href_val);
      $(this).html("<i class='glyphicon glyphicon-heart-empty'></i> Like");
      var likes = jQuery(this).parent().parent().find('.update_anzahl');
      $(likes).html(data.likes_count);
    }
  });
  /*Feed Likes*/

  /*Fancy box*/
  $("a.fancy_img").fancybox({
		helpers: {
			overlay: {
			  locked: false
			}
		  }
		}
	);
	
	$(".fancybox").fancybox({
		fitToView	: false,
		width		: '650px',
		height		: 'auto',
		autoSize	: false,
		closeClick	: false,
		openEffect	: 'fade',
		closeEffect	: 'fade',
		openSpeed	: 200,
		closeSpeed	: 200
	});
	
	$(".fancybox_small").fancybox({
		fitToView	: false,
		width		: '480px',
		height		: 'auto',
		autoSize	: false,
		closeClick	: false,
		openEffect	: 'fade',
		closeEffect	: 'fade',
		openSpeed	: 200,
		closeSpeed	: 200
	});

	$(".fancybox_large").fancybox({
		fitToView	: false,
		width		: '70%',
		height		: 'auto',
		autoSize	: false,
		closeClick	: false,
		openEffect	: 'fade',
		closeEffect	: 'fade',
		openSpeed	: 200,
		closeSpeed	: 200,
		padding     : 0
	});

  /*Fancy box*/

  /*Panel*/
  $('#accordion').collapse({
	  toggle: false
	})
  // $(".glyphicon").click(function(){
  	// var field_id = $(this).data('field-id');	
    // var panel_class = $(".panel-collapse").hasClass("in");
    // if(panel_class == false) {
    	// $(".glyphicon-arrow-"+field_id).removeClass("glyphicon-chevron-up");
      // $(".glyphicon-arrow-"+field_id).addClass("glyphicon-chevron-down");
    // }
    // if ($(".glyphicon-arrow-"+field_id).hasClass("glyphicon-chevron-down")) {
    	// $(".glyphicon-arrow-"+field_id).removeClass("glyphicon-chevron-down");
      // $(".glyphicon-arrow-"+field_id).addClass("glyphicon-chevron-up");
    // }
    // else {
      // $(".glyphicon-arrow-"+field_id).removeClass("glyphicon-chevron-up");
      // $(".glyphicon-arrow-"+field_id).addClass("glyphicon-chevron-down");
    // }
  // });

  /*Panel arrows*/

  /*Edit form*/
  jQuery('#main').on('click', '.editFormLink', function(){
		jQuery('.editForm').addClass('editactive');
		// jQuery(this).hide();
		return false;
	})

  jQuery('#main').on('click', '.editFormImageLink', function(){
    jQuery('.editForm').addClass('editactive');
    jQuery("#image-edit").show();
    jQuery('.editAvatar').click();
    // jQuery(this).hide();
    return false;
  })  

  jQuery(document).on('change', ".editAvatar", function(e){
    input = this
    if(input.files && input.files[0]){
      var reader = new FileReader();
      reader.onload = function (e) {
        $('.pitch_image').attr('src', e.target.result);
      }
      reader.readAsDataURL(input.files[0]);
    }
  });

  jQuery('#main').on('click', '.editFormTitleLink', function(){
    jQuery('.editForm').addClass('editactive');    
    jQuery('.pitch_title').hide();
    jQuery('.editTitle').show();
    // jQuery(this).hide();
    return false;
  })
  /*Edit form*/

  jQuery("#main").on('click','.editTagList', function(){
    jQuery('.tag-area-of-pitch').show();
    // jQuery(this).hide();
    return false;
  })

  $("body").on("focus", ".datepicker_std", function(e){
    $(this).datepicker({
      changeMonth: true,
      changeYear: true,
      // minDate: 0,
      dateFormat: 'dd-mm-yy'
    });
  })

  jQuery('#main').on('click', '.expand', function(e){
    var id = $(this).attr("id");
    $(".expand_hidden").hide();
    
    if($(this).hasClass("opened_expand")){
      $(this).html("+");
      $(this).removeClass("opened_expand");
    } else {
      $(".opened_expand").removeClass("opened_expand").html("+");
      $(this).html("-");
      $(this).addClass("opened_expand");
      $("#expand_"+id).show();
    }

    e.preventDefault();
  });

  jQuery('.open_div').click(function(e){
    var cont = $(this).attr("name");
    var has = $(this).hasClass("link_opened_div");
    $(".link_opened_div").removeClass("link_opened_div");
    $(".closable_div").hide();
    if(has != true){
      $(this).addClass("link_opened_div");
      $("."+cont).show();
      $("#"+cont).show();
    }
    e.preventDefault();
  });

  jQuery('.showDiv').click(function(e){
    var cont = jQuery(this).attr('name');
    jQuery(this).hide();
    jQuery('#'+cont).show();
    e.preventDefault();
  });

  $(".radioset").buttonset();

  jQuery('.reqForm').submit(function() {
    var fehler = 0;
    jQuery('.req_error').removeClass('req_error');
    jQuery('.req_error_check').removeClass('req_error_check');
    
    jQuery('.error_form_req').remove();
    jQuery(this).find('.required').each(function(index) {
      if(jQuery(this).val() == "" || jQuery(this).val() == "Choose Program Title *" || jQuery(this).val() == "Company Name *") {
        jQuery(this).addClass('req_error');
        if(fehler==0){ 
          jQuery('html, body').animate({ scrollTop: "+=100" }, 50);
        }
        fehler++;
      }
      
    });
    jQuery(this).find('.required-checkbox').each(function(index) {
      jQuery(this).parent().find('.error_msg').remove();
          if(jQuery(this).is(':checked') != true){
            if(fehler==0){ 
              jQuery(this).focus();
              jQuery('html, body').animate({ scrollTop: "+=100" }, 50);
            }
            jQuery(this).parent().addClass('req_error_check');
            fehler++;
      }
    });
    if(jQuery('#password').val() != ""){
      if(jQuery('#password').val() != jQuery('#confirm_password').val()){
        jQuery('#password').addClass('req_error');
        jQuery('#confirm_password').addClass('req_error');
        fehler++;
      }
    }
    if(fehler > 0){
      jQuery(this).append('<div class="error_form_req">please check that you have filled out all the mandatory fields (marked with a star)</div>');
      return false;
    }
  });

  $("[data-auto-options]").each(function(i, elem){
    $(elem).on("keydown", function(){
      $(this).autocomplete({
        source: $(this).data("auto-options")
      });
    });
  });
  
  $(function(){
		$("#mainnavi").sticky({topSpacing:0});
	});

  $("body").on("focus", ".time-picker", function(e){
		$(this).timepicker();
	})
        
        
        
    var offset = 120;
    var duration = 500;
    jQuery(window).scroll(function() {
        if (jQuery(this).scrollTop() > offset) {
            jQuery('.back-to-top').fadeIn(duration);
        } else {
            jQuery('.back-to-top').fadeOut(duration);
        }
    });
    
    jQuery('.back-to-top').click(function(event) {
        event.preventDefault();
        jQuery('html, body').animate({scrollTop: 0}, duration);
        return false;
    })
jQuery(document).ready(function($){
function rgb2hex(rgb){
 rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
 return "#" +
  ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[3],10).toString(16)).slice(-2);
}
var hex = rgb2hex($('#mainnavi').css('background-color'));
var lum = 0.8;

hex = String(hex).replace(/[^0-9a-f]/gi, '');

if (hex.length < 6) {
hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
}
lum = lum || 0;
// convert to decimal and change luminosity
var rgb = "#", c, i;
for (i = 0; i < 3; i++) {
c = parseInt(hex.substr(i*2,2), 16);
c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);
rgb += ("00"+c).substr(c.length);
}
$(".col-md-4 .panel-group .panel .panel-pitch-detail").css( "background", rgb );
});
  
    $(function(){
				$('#fd_b').autosize({append: "\n"});
			});

  $(document).on('change', ".check_mentor_filter", function(e){
    checked = $(this).parents("ul.mentor_custom_checkbox").find("input:checked");
    data = new Array();
    for(i = 0; i < checked.length; i++){
      data.push(checked[i].dataset["optionCode"]);
    }
    //unchecked = $(this).parents("ul.mentor_custom_checkbox").find("input:not(:checked)");
    $.ajax({
      url: $(this).data("url"),
      type: 'get',
      data: {options: data},
      success: function(data){
        if(data["status"] != "no"){
          $('#rightcontent').html(data);
        }
        else{
          window.location.reload();
        }
      },
      error: function(){
        alert('Request failed. Sorry, we are analyzing the cause of this problem');
      }
    })
  });

  $(document).ready(function(e){
    //data = $(location).attr('pathname');
    data = $('#page_name').val();
    $.ajax({
      url: "/users/show_faq",
      type: 'get',
      data: {data: data},
      success: function(data){
        if(data){
          $('.faq_pop').trigger('click');
          $('.checkbox_div').show();
        }
      },
      error: function(){
      }
    })
  });
  
  $(document).on('change', '.check_visited_page', function(e){
    //data = $(location).attr('pathname');
    data = $(this).data('page');
    $.ajax({
      url: "/users/pages_visited",
      type: 'get',
      data: {data: data},
      success: function(data){
      },
      error: function(){
      }
    })
  });

  $(document).on('click', '.toggle_div', function(e){
    $('.checkbox_div').hide();
  });

  function reload_and_show_message(){
    $('#rightcontent').load(window.location + " .innercontent");
    if($('.alert_top_spacing').length){
      $('.alert_top_spacing').html('<button type="button" data-dismiss="alert" class="close">×</button>User Successfully deleted');
    }
    else{
      $('#main').prepend('<div class="alert alert-info alert_top_spacing"><button type="button" data-dismiss="alert" class="close">×</button>User Successfully deleted</div>')
    }
  }

  $(document).on('click', '.delete_user_account', function(e){
    if (confirm("Are you sure you want to delete this account")){
      del_path = $(this).data('del-url');
      $.ajax({
        url: $(this).data('url'),
        type: 'get',
        success: function(data){
          if(data['pitch_count'] > 0){
            if (confirm(" This account is associated with "+ data['pitch_count'] + " pitch(s), you still wants to delete it")){
              $.ajax({
                url: del_path,
                type: 'delete',
                success: function(data){
                  reload_and_show_message();
                }
              });
            }
          }
          else if(data['pitch_count'] == 0){
            $.ajax({
                url: del_path,
                type: 'delete',
                success: function(data){
                  reload_and_show_message();
                }
              });
          }
        },
        error: function(){
          alert("error");
        }
      })
    }
  });

  $(document).on('keypress keyup keydown', '.pitchTag', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addPitchTag').trigger('click');
      return false;
    }
  })

$('.collapses').collapsiblePanel();
$('[data-toggle="tooltip"]').tooltip({'placement': 'bottom'});

$(".stick_me").stick_in_parent({
	parent: $("#rightcontent"),
	offset_top: 80
});
//$('.task_master').rollbar({zIndex:80}); 
$('.dds').ddslick();

  $('.addUrl').click(function(){
    var value = $('.addUrlTag').val();
    var field_name = $('.addUrlTag').data("field-name");
    if(value != ""){
      $('#urlList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+ field_name +'" readonly="readonly" /></div>');
      $('.addUrlTag').val('');
    }
    return false;
  });

  $(document).on('keypress keyup keydown', '.addUrlTag', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addUrl').trigger('click');
      return false;
    }
  })
  
  $(".rating-kv").rating({
  	showCaption: false
  });

  $(".clear-rating").remove();

  $('.pittch_score_filter').on('change', function(e){
    e.preventDefault();
    $.ajax({
      url: $(this).data("url"),
      type: 'get',
      data: {option: $(this).val()},
      success: function(data){
        if(data["status"] != "no"){
          $('.masonry').html(data);
          $('.masonry').masonry().masonry( 'reloadItems' );
          $('.masonry').masonry().masonry( 'layout' );
          $('.rating-kv').rating('refresh', {'showCaption': false});
          
          var limit = 140;
        $( ".pitch_summary_limit" ).each(function() {
          var chars = $(this).html();
        if (chars.length > limit) {
            var visiblePart = $("<span> "+ chars.substr(0, limit-1) +"</span>");
            var dots = $("<span class='dots'>... </span>");
            var hiddenPart = $("<span class='pitch_more'>"+ chars.substr(limit-1) +"</span>");
            var readMore = $("<span class='read-more scx'>More <span class='glyphicon glyphicon-forward'></span></span>");
            var readLess = $("<span class='read-more scx'>Less <span class='glyphicon glyphicon-backward'></span>");
            var $container = $('#masonry_container');
            readLess.hide();
            readMore.click(function() {
                $(this).prev().hide(); // remove dots
                $(this).next().show();
                $(this).hide(); // remove 'read more'
                $(this).next().next().show();
                setTimeout(function(){ $container.masonry() }, 100);
            });
            readLess.click(function() {
                $(this).prev().hide(); // remove extra
                $(this).prev().prev().show(); //show more
                $(this).prev().prev().prev().show(); //show dots
                $(this).hide(); // remove 'less'
                setTimeout(function(){ $container.masonry() }, 100);
            });
            $(this).empty()
                .append(visiblePart)
                .append(dots)
                .append(readMore)
                .append(hiddenPart)
                .append(readLess);
                setTimeout(function(){ $container.masonry() }, 100);
              }
        });
          
        }
        else{
          $('.masonry').html('');
          //window.location.reload();
        }
      },
      error: function(){
        alert('Request failed. Sorry, we are analyzing the cause of this problem');
      }
    })
  });

  $(document).on('change', '.mark_task_completed', function(e){
    e.preventDefault();
    $.ajax({
      url: $(this).data("url"),
      type: 'get',
      success: function(data){
        window.location.reload(true);
      },
      error: function(){
      }
    })
  })

  $(document).on('click', '.milestone_create', function(e){
    e.preventDefault();
    $.ajax({
      url: $('.milestone_create_form').attr('action'),
      type: 'post',
      data: $('.milestone_create_form').serialize(),
      success: function(data){
        $.fancybox.close();
        $('#milestone_select_div').load(window.location + " #select_box_div");
      },
      error: function(){
        
      }
    })
  })

  $('.create_milestone').fancybox({
    afterClose: function() {
      setTimeout(function() {
      var count = ($('select#task_milestone_id')[0].options.length - 2)// Do something after 5 seconds
      $("select#task_milestone_id option:eq('"+count+"')").attr("selected", "selected");
      }, 500);
  }});
  
  $(document).mouseup(function (e) {
      if ($('.popover').has(e.target).length === 0) {
          $('.popover').toggleClass('in').remove();
          return;
      }
    });

  $(document).ready(function(){
    $(document).on('click', ".show_help_text_pitch", function(e){
      e.preventDefault();
      current_obj = $(this);
      $.ajax({
        url: $(this).data('url'),
        type: 'get',
        data: "field_name="+ $(this).data('field-name')+"&text_for="+$(this).data('text-for')+"&custom_id="+$(this).data('custom-field-id'),
        contentType: 'application/json; charser=utf-8',
        success: function(data){
          current_obj.data('content', data.content);
          current_obj.popover('show');
        },
        error: function(){
          alert('Request failed. Sorry, we are analyzing the cause of this problem');
        }
      })
    });
  });

  $(document).ready(function() {
    $("#feeds_div").infinitescroll({
      navSelector: "nav.pagination",
      nextSelector: "nav.pagination a[rel=next]",
      itemSelector: "#feeds_div .feed_obj"
    },
    function(){
      $(".sticky-post-link[rel=tooltip], .blog-post-link[rel=tooltip]").tooltip();
    }
    );
  });
 
 $(document).ready(function() {
    $(".already_rated").jRating({ 
      step:true,
      length : 5,
      rateMax: 5,
      showRateInfo:false,
      isDisabled: true,
      bigStarsPath: '/images/icons/stars_old.png',
      onSuccess : function(){

      }
    });
  });
  
  $('.autogrow').css('overflow', 'hidden').autogrow();
  
  jQuery("body").on('click', '.addSkill', function(){
    var value = $('#skills').val();
    var field_name = $('#skills').data('field-name');
    if(value!=""){
      $('#skillList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+field_name+'" readonly="readonly" /></div>');
      $('#skills').val('');
    }
    return false;
  });

  jQuery("body").on('click', '.addInterest', function(){
    var value = $('#interests').val();
    var field_name = $('#interests').data('field-name');
    if(value!=""){
      $('#interestsList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+field_name+'" readonly="readonly" /></div>');
      $('#interests').val('');
    }
    return false;
  });
  
  $(document).on('keypress keyup keydown', '.autoSkills', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addSkill').trigger('click');
      return false;
    }
  })

  $(document).on('keypress keyup keydown', '.autoInterests', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addInterest').trigger('click');
      return false;
    }
  })
  
  jQuery("body").on('click', '.delTag', function(){
    $(this).parent().remove();
    return false;
  });
});