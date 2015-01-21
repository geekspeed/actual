
jQuery(document).ready(function($){
	$('input, textarea').placeholder();
	$('.selectmenu').selectmenu();
	$( ".checkbox" ).button();

	$('.wysiwyg').redactor({
		buttons: ['formatting', '|', 'bold', 'italic', 'deleted', '|','unorderedlist', 'orderedlist', 'outdent', 'indent', '|', 'link', '|','fontcolor', 'backcolor', '|', 'alignment']
	});
	jQuery('.nolink').click(function(){
		return false;	
	});
	
	jQuery('body').on('click', '.show_details', function(){
		jQuery(this).parent().find(".show_detail_container").show();
		jQuery(this).removeClass('show_details').addClass('hide_details');
		return false;
	});
	jQuery('body').on('click', '.hide_details', function(){
		jQuery(this).parent().find(".show_detail_container").hide();
		jQuery(this).removeClass('hide_details').addClass('show_details');
		return false;
	});
	
	jQuery('.open_div').click(function(){
		var cont = $(this).attr("name");
		var has = $(this).hasClass("link_opened_div");
		$(".link_opened_div").removeClass("link_opened_div");
		$(".closable_div").hide();
		if(has != true){
			$(this).addClass("link_opened_div");
			$("."+cont).show();
			$("#"+cont).show();
		}
		return false;	
	});

	jQuery('.eliminateAccount').click(function(event){
		event.preventDefault();
		var cont = $(this).attr("name");
		var this_el = $(this);
		//~ jQuery.post(admin_url, {action:'eliminate_account',ajax:'true',cont:cont}, function(data) {
			//~ jQuery(this_el).parent().parent().fadeOut();
		//~ });
		jQuery.post(admin_url, {action:'delete_account',ajax:'true',cont:cont}, function(data) {
			jQuery(this_el).parent().parent().fadeOut();
		});
		return false;	
	});
	
	jQuery('.deleteAccount').click(function(event){
		event.preventDefault();
		var cont = $(this).attr("name");
		var this_el = $(this);
		jQuery.post(admin_url, {action:'delete_account',ajax:'true',cont:cont}, function(data) {
			jQuery(this_el).parent().parent().fadeOut();
		});
		return false;	
	});
	
	jQuery('body').on('click', '.saveIterationRelations', function(){
		var pitch_id = $(this).parent().find('.pitch_id').val();
		var iteration_id = $(this).parent().find('.iteration_id').val();
		var learning = $(this).parent().find('.learning').val();
		var problem = $(this).parent().find('.problem').val();
		var new_comment = $(this).parent().find('.new_comment').val();
		jQuery.post(admin_url, {action:'saveIterationRelations',ajax:'true',pitch_id:pitch_id,iteration_id:iteration_id,learning:learning,problem:problem,new_comment:new_comment}, function(data) {
			//document.location = document.location.replace(/[\?].*/,'');
			var old_url = document.location.href;
			var new_url = old_url.substring(0, old_url.indexOf('?'));
			document.location = new_url;
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.approveUser', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'approveUser',ajax:'true',entryID:eID}, function(data) {
			$(this_el).hide();
		});
		return false;	
	});
	jQuery('#main').on('click', '.declineUser', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'declineUser',ajax:'true',entryID:eID}, function(data) {
			$(this_el).hide();
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.featureentry', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featureentry',ajax:'true',entryID:eID,featured:'true'}, function(data) {
			location.reload();
		});
		return false;	
	});
	
	$('.autogrow').css('overflow', 'hidden').autogrow();
	
	jQuery('#main').on('click', '.unfeatureentry', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featureentry',ajax:'true',entryID:eID,featured:'false'}, function(data) {
			location.reload();
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.nudge_milestone', function(){
		var entryID = $(this).attr("name");
		$(this).parent().fadeOut();
		jQuery.post(admin_url, {action:'nudge_milestone',entryID:entryID}, function(data) {
			
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.featureperson', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featureperson',ajax:'true',entryID:eID,featured:'true'}, function(data) {
			location.reload();
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.switch_community', function(){
		var id = $(this).attr('id');
		$(this).parent().find(".active").removeClass("active");
		$(this).addClass("active");
		$(".sub_com").hide();
		$("."+id+"_container").fadeIn();
		
		return false;	
	});
	
	
	jQuery(".carouselCont").carouFredSel({
		width: 520,
		direction: "left",
		circular: false,
		pagination  : {
			container   : function() {
				return jQuery(this).parent().parent().find(".pagination");
			}
		},
		scroll : {
			items           : 1,
			duration        : 1000,
			pauseOnHover    : true
		}
	});
	
	jQuery('#main').on('click', '.unfeatureperson', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featureperson',ajax:'true',entryID:eID,featured:'false'}, function(data) {
			location.reload();
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.featurefeed', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featurefeed',ajax:'true',entryID:eID,featured:'1'}, function(data) {
			location.reload();
		});
		return false;	
	});
	
	jQuery('#main').on('click', '.unfeaturefeed', function(){
		var eID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'featurefeed',ajax:'true',entryID:eID,featured:'0'}, function(data) {
			//location.reload();
			this_el.fadeOut();
		});
		return false;	
	});
	
	$('#referthistoTeam').click(function(){
		var to = $("#refertoTeam").val();
		var msg = $("#refertoTeam_msg").val();
		var pid = $("#program_id").val();
		var user_id = $("#user_id").val();
		var link = $("#referto_link").val();
		if(to != "" && msg != "" && link != ""){
			jQuery(this).parent().find('.loader').show();
			var this_el = jQuery(this);
			jQuery.post(admin_url, {action:'referthistoTeam',to:to,msg:msg,link:link,pid:pid,user_id:user_id}, function(data) {
				jQuery('.loader').hide();
				$("#refertoTeam_msg").val("");
				jQuery(this_el).parent().find('.ok_ico').show().delay(500).fadeOut();
			});
		}
		return false;
	});
	
	$('#referthistoMentor').click(function(){
		var to = $("#refertoMentor").val();
		var msg = $("#refertoMentor_msg").val();
		var pid = $("#program_id").val();
		var pitch_id = $("#pitch_id").val();
		var link = $("#referto_link").val();
		if(to != "" && msg != "" && link != ""){
			jQuery(this).parent().find('.loader').show();
			var this_el = jQuery(this);
			jQuery.post(admin_url, {action:'referthistoMentor',to:to,msg:msg,link:link,pid:pid,pitch_id:pitch_id}, function(data) {
				jQuery('.loader').hide();
				$("#refertoMentor_msg").val("");
				jQuery(this_el).parent().find('.ok_ico').show().delay(500).fadeOut();
			});
		}
		return false;
	});
	
	$('#referthisto').click(function(){
		var to = $("#referto").val();
		var from = $("#referfrom").val();
		var msg = $("#referto_msg").val();
		var pid = $("#program_id").val();
		var link = $("#referto_link").val();
		if(to != "" && msg != "" && link != ""){
			jQuery(this).parent().find('.loader').show();
			var this_el = jQuery(this);
			jQuery.post(admin_url, {action:'referthisto',to:to,msg:msg,link:link,from:from,pid:pid}, function(data) {
				jQuery('.loader').hide();
				$("#referto").val("");
				$("#referfrom").val("");
				jQuery(this_el).parent().find('.ok_ico').show().delay(500).fadeOut();
			});
		}
		return false;
	});
	
	$('.markAsResolved').click(function(){
		var code = $(this).attr("name");
		var this_el = $(this);
		jQuery.post(admin_url, {action:'markAsResolved',code:code}, function(data) {
			$(this_el).fadeOut();
		});
		return false;
	});
	
	$("#main").on("click", '.hideQuest', function(){
		var code = $(this).attr("name");
		var this_el = $(this);
		jQuery.post(admin_url, {action:'hideQuest',code:code}, function(data) {
			$(this_el).addClass("unhideQuest").removeClass("hideQuest").html("unhide");
		});
		return false;
	});
	
	$("#main").on("click", '.unhideQuest', function(){
		var code = $(this).attr("name");
		var this_el = $(this);
		jQuery.post(admin_url, {action:'unhideQuest',code:code}, function(data) {
			$(this_el).addClass("hideQuest").removeClass("unhideQuest").html("hide");
		});
		return false;
	});
	
	
	jQuery('#main').on('click', '.referQuestTo', function(){
		jQuery(this).parent().parent().find('.referQuestTo-box').fadeToggle();
		return false;
	});
	jQuery('#main').on('click', '.submitReferQuest', function(){
		var this_el = jQuery(this);
		var email = jQuery(this_el).parent().find('.referToMail').val();
		var text = jQuery(this_el).parent().find('.referContent').val();
		var link = jQuery(this_el).parent().find('.page_link').val();
		var question_id = jQuery(this_el).parent().find('.question_id').val();
		
		if(email != "" && text != ""){
			jQuery(this).parent().find('.loader').show();
			jQuery.post(admin_url, {action:'submitReferQuest',email:email,text:text,link:link,question_id:question_id}, function(data) {
				jQuery('.loader').hide();
				jQuery(this_el).parent().parent().find('.referQuestTo-box').fadeOut();
				jQuery(this_el).parent().find('input').val("");
				jQuery(this_el).parent().find('textarea').val("");
			});
		}	
		
		return false;
	});
	
	jQuery('#main').on('click', '.closeReferQuest', function(){
		jQuery(this).parent().parent().find('.referQuestTo-box').fadeOut();
		jQuery(this).parent().find('input').val("");
		jQuery(this).parent().find('textarea').val("");
		return false;
	});
	
	jQuery("form").submit(function(e) {
		jQuery(this).find('.watermark').each(function(index) {
			var val = jQuery(this).val();
			jQuery(this).attr('watermark', val);
			jQuery(this).val('').removeClass('watermark').addClass('watermark_rmv');
		});
	});
	
	$(".tag_functionality").on("keydown", "input", function(e){
		var code = e.keyCode || e.which;
		//alert(code);
		if(code == 188){
			$(this).parent().find('.addTag').click();
			return false;
		}
	});
	
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
		closeSpeed	: 200,
		helpers: {
    overlay: {
      locked: false
    }
  }
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
		closeSpeed	: 200,
		helpers: {
    overlay: {
      locked: false
    	}
  	}
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
		padding     : 0,
		helpers: {
    overlay: {
      locked: false
    	}
  	}
	});
	
	jQuery('#main').on('click', '.editFormLink', function(){
		jQuery('.editForm').addClass('editactive');
		// jQuery(this).hide();
		return false;
	})
	
	jQuery('#main').on('click', '.showNewTagCont', function(){
		jQuery(this).parent().find('.newTag').show();
		jQuery(this).hide();
		return false;
	})
	
	jQuery('#main').on('click', '.delAdminTag', function(){
		var tag = jQuery(this).attr('name');
		jQuery(this).parent().hide();
		jQuery.post(admin_url, {action:'deleteAdminTag',ajax:'true',tag:tag}, function(data) {
			
		});
		return false;
	});
	
	function insertParam(key, value){
		key = escape(key); value = escape(value);

		var kvp = document.location.search.substr(1).split('&');

		var i=kvp.length; var x; while(i--) 
		{
			x = kvp[i].split('=');

			if (x[0]==key)
			{
				x[1] = value;
				kvp[i] = x.join('=');
				break;
			}
		}

		if(i<0) {kvp[kvp.length] = [key,value].join('=');}

		//this will reload the page, it's likely better to store this until finished
		document.location.search = kvp.join('&'); 
	}
	
	jQuery('body').on('click', '.delback', function(){
		var id = $(this).attr("name");
		$(this).parent().fadeOut();
		jQuery.post(admin_url, {action:'deleteBack',ajax:'true',id:id}, function(data) {
			//location.href = location.href + '?backFrame=1';
			insertParam("backFrame", "1");
		});
		return false;
	});
	
	jQuery('#main').on('click', '.saveAdminTag', function(){
		var tag = jQuery(this).parent().find('#newadmintag').val();
		var category = jQuery(this).parent().find('.category').val();
		var p_id = jQuery(this).attr('name');
		var this_el = jQuery(this);
		if(tag != ""){
			jQuery(this_el).parent().parent().find('.loader').show();
			jQuery.post(admin_url, {action:'saveAdminTag',ajax:'true',tag:tag,p_id:p_id,category:category}, function(data) {
				jQuery(this_el).parent().find('#newadmintag').val('');
				jQuery(this_el).parent().parent().find('.loader').hide();
				//jQuery(this_el).parent().parent().find('.ok_ico').show().delay(500).fadeOut();
				jQuery(this_el).parent().hide();
				jQuery(this_el).parent().parent().find('.showNewTagCont').show();
				jQuery(this_el).parent().parent().find('.tags').html(data);
			});
		}
		return false;
	});
	
	jQuery('#main').on('click', '.saveProgramTag', function(){
		var tag = jQuery(this).parent().find('.newtag').val();
		var category = jQuery(this).parent().find('.category').val();
		var p_id = jQuery(this).attr('name');
		var this_el = jQuery(this);
		if(tag != ""){
			jQuery(this_el).parent().parent().find('.loader').show();
			jQuery.post(admin_url, {action:'saveProgramTag',ajax:'true',tag:tag,p_id:p_id,category:category}, function(data) {
				jQuery(this_el).parent().find('.newtag').val('');
				jQuery(this_el).parent().parent().find('.loader').hide();
				//jQuery(this_el).parent().parent().find('.ok_ico').show().delay(500).fadeOut();
				jQuery(this_el).parent().hide();
				jQuery(this_el).parent().parent().find('.showNewTagCont').show();
				jQuery(this_el).parent().parent().find('.tags').html(data);
			});
		}
		return false;
	});
	
	jQuery('#main').on('click', '.saveAdminUserTag', function(){
		var tag = jQuery(this).parent().find('#newadmintag').val();
		var category = jQuery(this).parent().find('.category').val();
		var program_id = jQuery('#program_id').val();
		var u_id = jQuery(this).attr('name');
		var this_el = jQuery(this);
		if(tag != ""){
			jQuery(this_el).parent().parent().find('.loader').show();
			jQuery.post(admin_url, {action:'saveAdminUserTag',ajax:'true',tag:tag,u_id:u_id,category:category,program_id:program_id}, function(data) {
				jQuery(this_el).parent().find('#newadmintag').val('');
				jQuery(this_el).parent().parent().find('.loader').hide();
				//jQuery(this_el).parent().parent().find('.ok_ico').show().delay(500).fadeOut();
				jQuery(this_el).parent().hide();
				jQuery(this_el).parent().parent().find('.showNewTagCont').show();
				jQuery(this_el).parent().parent().find('.tags').html(data);
			});
		}
		return false;
	});
	
	jQuery('body').on("change", ".select_field_type", function(){
		var typ = $(this).val();
		$(this).parent().removeAttr('class');
		$(this).parent().addClass(typ);
	});
	
	jQuery('.tab_menu').change(function(){
		$('.tab_men_cont').hide();
		$('.'+$(this).attr('id')).show();
	})
	
	jQuery('.showDiv').click(function(){
		var cont = jQuery(this).attr('name');
		jQuery(this).hide();
		jQuery('#'+cont).show();
		return false;
	});
	
	jQuery('#notifications').on('click', '.nfc_counter_open', function(){
		jQuery(this).html('');
		jQuery(this).removeClass('nfc_counter_open').removeClass('active').addClass('nfc_counter_close');
		jQuery('#nfc_container').fadeIn();
		jQuery.post(admin_url, {action:'get_notifications',ajax:'true'}, function(data) {
			$('#nfc_container .inner').html(data);
		});
		return false;
	});
	jQuery('#notifications').on('click', '.nfc_counter_close', function(){
		jQuery(this).removeClass('nfc_counter_close').addClass('nfc_counter_open');
		jQuery('#nfc_container').fadeOut();
		return false;
	});
	jQuery('body').click(function(){
		jQuery('.nfc_counter_close').removeClass('nfc_counter_close').addClass('nfc_counter_open');
		jQuery('#nfc_container').fadeOut();
	});
	
	
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
	jQuery('.showLaunchpad').click(function(){
		jQuery('.programLaunchpad').slideDown();
		return false;
	});
	jQuery('#main').on('click', '.lightbox_sn_open', function(){
		jQuery('#lightbox_sn_dark').fadeIn();
		jQuery('#lightbox_sn').fadeIn();
		return false;
	})
	jQuery('#main').on('click', '#lightbox_sn_dark', function(){
		jQuery('#lightbox_sn').fadeOut();
		jQuery('#lightbox_sn_dark').fadeOut();
		return false;
	});
	jQuery('#main').on('click', '.lightbox_sn_close', function(){
		jQuery('#lightbox_sn').fadeOut();
		jQuery('#lightbox_sn_dark').fadeOut();
		return false;
	});
	
	jQuery('.page').on('focus', '.watermark', function(){
		var val = jQuery(this).val();
		jQuery(this).attr('watermark', val);
		jQuery(this).val('').removeClass('watermark').addClass('watermark_rmv');
	});
	
	$("body").on("focus", ".datepicker_std", function(e){
		$(this).datepicker({
			changeMonth: true,
			changeYear: true,
			// minDate: 0,
			dateFormat: 'dd-mm-yy'
		});
	})
	
	jQuery('.page').on('focusout', '.watermark_rmv', function(){
		var val = jQuery(this).val();
		if ($(this).hasClass('datepicker')) {
			
		} else {
			if(val == ""){
				var text = jQuery(this).attr('watermark');
				jQuery(this).val(text).removeClass('watermark_rmv').addClass('watermark');
			}
		}
	});
	
	
	jQuery('.loginBtn').mouseover(function(e){
		jQuery('.loginBox').show();
		e.preventDefault();
	});
	jQuery('.loginLi').mouseleave(function(e){
		jQuery('.loginBox').hide();
		e.preventDefault();
	});
	jQuery('body').on('click', '.send_message_put_to', function(){
		var to = $(this).attr("name");
		jQuery('#to').val(to);
	});
	jQuery('body').on('click', '.submitMessage', function(){
		var subject = $(this).parent().find('#subject').val();
		var message = $(this).parent().find('#message').val();
		var to = $(this).parent().find('#to').val();
		var entry = $('#entrymsgid').val();
		var email = $(this).parent().find('#email').val();
		var pgid = $('#pgid').val();
		var code = $(this).parent().find('#code').val();

		this_el = $(this);
		jQuery.post(admin_url, {action:'submitMessage',ajax:'true',subject:subject, message:message, to:to, email:email, entry:entry, pgid:pgid, code:code}, function(data) {
			if(to != "" && to != "undefined" && typeof to !== 'undefined'){
				$('#subject').val('');
				$('#message').val('');
			}
			
			parent.$.fancybox.close();
		});
		return false;
	});
	
	jQuery('#main').on('click', '.add_as_fav', function(){
		var favID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'add_as_fav',ajax:'true',favID:favID}, function(data) {
			$(this_el).removeClass('add_as_fav').addClass('remove_as_fav');
			$(this_el).html(data);
		});
		return false;
	});
	
	jQuery('#main').on('click', '.remove_as_fav', function(){
		var favID = $(this).attr('name');
		this_el = $(this);
		jQuery.post(admin_url, {action:'remove_as_fav',ajax:'true',favID:favID}, function(data) {
			$(this_el).removeClass('remove_as_fav').addClass('add_as_fav');
			$(this_el).html(data);
		});
		return false;
	});

	jQuery('#main').on('click', '#save-new-status', function(){
		if((jQuery(this).parent().find('#file').val() != "" && typeof jQuery(this).parent().find('#file').val() !== "undefined") || (jQuery(this).parent().find('.multiple_images_inp').val() != "" && typeof jQuery(this).parent().find('.multiple_images_inp').val() !== "undefined" ) ){
			jQuery(this).parent().find('.loader').show();
			jQuery(this).parent().parent().parent().submit();
		} else {
			var content = jQuery(this).parent().find('#new-status').val();
			var link = jQuery(this).parent().find('#file_url').val();
			var meeting = jQuery(this).parent().find("input[name='meeting']:checked").val();
			var showTo = jQuery(this).parent().find('#showTo').val();
			var feedtyp = jQuery(this).parent().find('#feedtyp').val();
			var as_milestone = jQuery(this).parent().find('#as_milestone:checked').val();
			var rated = jQuery(this).parent().find("input[name='rated']:checked").val();
			var pitch_parent = jQuery(this).parent().find('#pitch_parent').val();
			var this_link = jQuery(this);
			var custom_data = jQuery(this).parent().find('#custom_data').val();
			var sec = jQuery(this).parent().find('#section').val();
			
			if(meeting == "newMeeting"){
				$.fancybox({
					fitToView	: false,
					width		: '400px',
					height		: 'auto',
					autoSize	: false,
					closeClick	: false,
					openEffect	: 'fade',
					closeEffect	: 'fade',
					openSpeed	: 200,
					closeSpeed	: 200,
					href: "#newMeetingCont",
					target: "inline"
				});
			} else {
				/*
				if(feedtyp == "" || typeof feedtyp === "undefined"){
					var feedtyp = jQuery(this).parent().find("input[name='milestone_typ']:checked").val();
				}
				if(feedtyp == "" || typeof feedtyp === "undefined"){
					var feedtyp = jQuery(this).parent().find("input[name='milestone_typ_2']:checked").val();
				}
				*/
				if(feedtyp == "" || typeof feedtyp === "undefined"){
					var feedtyp = jQuery(this).parent().find("input.milestone_typ:checked").data("milestonetype");
				}
				
				//alert("t: "+feedtyp);
				
				var pgid = $(this).parent().find("#pgid").val();
				if(pgid == "" || typeof pgid === "undefined"){
					var pgid = jQuery('#pgid').val();
				}
				
				jQuery(this).parent().find('.loader').show();
				var this_el = jQuery(this);
				if(as_milestone == "true"){
					var run_action = "save_new_milestone";
				} else {
					var run_action = "save_feed_status";
				}
				
				jQuery.post(admin_url, {action:run_action,ajax:'true',content:content,pgid:pgid,link:link,showTo:showTo,feedtyp:feedtyp,meeting:meeting,rated:rated,pitch_parent:pitch_parent,custom_data:custom_data}, function(data) {
					jQuery('.loader').hide();
					if(data != "error"){
						jQuery(this_el).parent().find('#new-status').val('');
						jQuery(this_el).parent().find('#file_url').val('');
						jQuery(this_el).parent().parent().parent().parent().find('#community_stream').html(data);
					}
					jQuery(this_el).parent().find('.ok_ico').show().delay(500).fadeOut();
					if($(this_link).hasClass("reload-page")){
						var old_url = document.location.href;
						var new_url = old_url.substring(0, old_url.indexOf('?'));
						document.location = new_url + '?newIteration=true&sec='+sec;
					}
				});
			}
		}
		
		return false;
	});
	
	jQuery('#main').on('click', '.mark_as_complete', function(){
		var this_el = jQuery(this);
		var task_slug = jQuery(this_el).attr('id');
		jQuery.post(admin_url, {action:'mark_as_complete',ajax:'true',task_slug:task_slug}, function(data) {
			if(data != "error"){
				jQuery(this_el).fadeOut();
			}
		});
		return false;
	});
	
	jQuery('#main').on('click', '.save-new-comment', function(){
		var this_el = jQuery(this);
		var obj_typ = jQuery(this).attr('name');
		var content = jQuery(this_el).parent().find('.new-comment').val();
		var fid = jQuery(this_el).parent().find('.fid').val();
		jQuery(this_el).parent().find('.loader').show();
		jQuery.post(admin_url, {action:'save_feed_comment',ajax:'true',content:content,fid:fid,obj_typ:obj_typ}, function(data) {
			jQuery('.loader').hide();
			
			if(data != "error"){
				var content = jQuery('.new-comment').val('');
				jQuery(this_el).parent().parent().find('.comments').html(data);
			}
		});
		return false;
	});
	jQuery('#main').on('click', '.delFeed', function(){
		var this_el = jQuery(this);
		var commentID = jQuery(this_el).attr('name');
		jQuery.post(admin_url, {action:'delete_feed',ajax:'true',commentID:commentID}, function(data) {
			if(data != "error"){
				jQuery(this_el).parent().parent().parent().fadeOut();
			}
		});
		return false;
	});
	jQuery('#main').on('click', '.delComment', function(){
		var this_el = jQuery(this);
		var commentID = jQuery(this_el).attr('name');
		jQuery.post(admin_url, {action:'delete_comment',ajax:'true',commentID:commentID}, function(data) {
			if(data != "error"){
				jQuery(this_el).parent().parent().fadeOut();
			}
		});
		return false;
	});
	jQuery('#main').on('click', '.commentFeed', function(){
		jQuery(this).parent().parent().find('.comments').fadeIn();
		jQuery(this).parent().parent().find('.new-comment-box').fadeIn();
		return false;
	});
	jQuery('#main').on('click', '.showLikes', function(){
		var this_el = jQuery(this);
		//var obid = jQuery(this).attr('name');
		//jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"feed"}, function(data) {
		//	jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			jQuery(this_el).parent().parent().find('.feedLikes').fadeToggle();
		//});
		return false;
	});
	
	jQuery('#main').on('click', '.likePitch', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid,object_typ:'pitch'}, function(data) {
			jQuery(this_el).removeClass('likePitch').addClass('unlikePitch').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:'pitch'}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	jQuery('#main').on('click', '.unlikePitch', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid,l_action:'remove',object_typ:'pitch'}, function(data) {
			jQuery(this_el).removeClass('unlikePitch').addClass('likePitch').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:'pitch'}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	
	/*jQuery('#main').on('click', '.likeFeed', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid}, function(data) {
			jQuery(this_el).removeClass('likeFeed').addClass('unlikeFeed').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"feed"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	jQuery('#main').on('click', '.unlikeFeed', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid, l_action:"remove"}, function(data) {
			jQuery(this_el).removeClass('unlikeFeed').addClass('likeFeed').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"feed"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});*/
	/*jQuery('#main').on('click', '.likeFeed', function(){
		var obid = jQuery(this).attr('name');
		var data_typ = jQuery(this).data("typ");
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid,data_typ:data_typ}, function(data) {
			jQuery(this_el).removeClass('likeFeed').addClass('unlikeFeed').html(data);
			var likes = jQuery(this_el).parent().find('.showLikes>.anzahl');
			jQuery(likes).html(parseInt(jQuery(likes).html())+1);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"feed"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	jQuery('#main').on('click', '.unlikeFeed', function(){
		var obid = jQuery(this).attr('name');
		var data_typ = jQuery(this).data("typ");
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid, l_action:"remove",data_typ:data_typ}, function(data) {
			jQuery(this_el).removeClass('unlikeFeed').addClass('likeFeed').html(data);
			var likes = jQuery(this_el).parent().find('.showLikes>.anzahl');
			jQuery(likes).html(parseInt(jQuery(likes).html())-1);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"feed"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});*/
	
	jQuery('#main').on('click', '.likeComment', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid,object_typ:"comment"}, function(data) {
			jQuery(this_el).removeClass('likeComment').addClass('unlikeComment').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"comment"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	jQuery('#main').on('click', '.unlikeComment', function(){
		var obid = jQuery(this).attr('name');
		var this_el = jQuery(this);
		jQuery.post(admin_url, {action:'save_feed_like',ajax_like:'true',obid:obid, l_action:"remove",object_typ:"comment"}, function(data) {
			jQuery(this_el).removeClass('unlikeComment').addClass('likeComment').html(data);
			jQuery.post(admin_url, {action:'get_feed_likes',ajax_like:'true',obid:obid,object_typ:"comment"}, function(data) {
				jQuery(this_el).parent().parent().find('.feedLikes').html(data);
			});
		});
		return false;
	});
	jQuery('#main').on('click', '.addImage', function(){
		var cl = jQuery(this).attr('name');
		jQuery(this).parent().parent().find(".link_box").find("span").hide();
		jQuery(this).parent().parent().find(".link_box").fadeIn().find("."+cl).fadeIn();
		jQuery(this).parent().parent().find(".link_box").find('input').val('');
		return false;
	});
	jQuery('#main').on('click', '.expand', function(){
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

		return false;
	});

	jQuery('#main').on('click', '.expand_sub', function(){
		var id = $(this).attr("id");
		$(".expand_sub_hidden").hide();
		if($("#expand_"+id).hasClass("active_expand")){
			$("#expand_"+id).removeClass("active_expand");
		} else {
			$(".active_expand").removeClass("active_expand");
			$("#expand_"+id).show().addClass("active_expand");
		}
		return false;
	});
	
	jQuery('body').on('click', '#feedbacker_link', function(){
		jQuery('#feedbacker_link').hide();
		jQuery('#feedback_container').show();
		return false;
	});
	jQuery('body').on('click', '.feedback_cancel', function(){
		jQuery('#feedback_container').hide();
		jQuery('#feedbacker_link').show();
		//return false;
	});
	jQuery('#feedback_form').bind('submit', function() {  
        var form = jQuery('#feedback_form');  
        var data = form.serialize();
        //jQuery.post('modules/mod_feedbacker/ajax_feedback_form.php', data, function(response) {  
            //alert(response);  
        //});
		jQuery.ajax($(this).attr('action'), {action:'jfeedbacker', type: "POST", data: data}, function(datahtml) {
			//$('.activities').html(datahtml);
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
	
	
	jQuery('body').on('click', '#question_link', function(){
		jQuery('#question_link').hide();
		jQuery('#question_container').show();
		return false;
	});
	jQuery('body').on('click', '.question_cancel', function(){
		jQuery('#question_container').hide();
		jQuery('#question_link').show();
		//return false;
	});
	jQuery('#question_form').bind('submit', function() {  
        var form = jQuery('#question_form');  
        var data = form.serialize();
        //jQuery.post('modules/mod_feedbacker/ajax_feedback_form.php', data, function(response) {  
            //alert(response);  
        //});
		jQuery.ajax($(this).attr('action'), {action:'jquestion', type: "POST", data: data}, function(datahtml) {
			//$('.activities').html(datahtml);
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

  /*Uploadify js*/
  if(!FlashDetect.installed){
    jQuery('.avatar-handler').hide();
    jQuery('.no-flash').show();
  }

  jQuery('.user_logo_button').uploadify({
    'swf'  : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.swf',
    'uploader'    : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.php',
    'buttonText' : 'Upload image',
    'cancelImg' : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/cancel.png',
    'folder'    : '/wp-content/uploads/user_pics',
    'auto'      : true,
    'onUploadSuccess' : function(file, data, response) {
        jQuery('.avatar-handler img.logo').attr('src', 'http://dev.apptual.com/wp-content/uploads/user_pics/'+data);
        jQuery('.avatar-handler img.logo').attr('width', 200);
        jQuery('#user_logo').val(data);
    }
  });

  jQuery('.company_logo_button').uploadify({
    'swf'  : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.swf',
    'uploader'    : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.php',
    'buttonText' : 'Upload logo',
    'cancelImg' : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/cancel.png',
    'folder'    : '/wp-content/uploads/user_pics',
    'auto'      : true,
    'onUploadSuccess' : function(file, data, response) {
      jQuery('.avatar-handler img.logo').attr('src', 'http://dev.apptual.com/wp-content/uploads/user_pics/'+data);
      jQuery('.avatar-handler img.logo').attr('width', 240);
      jQuery('#company_logo').val(data);
    }
  });

  jQuery('.program_logo_button').uploadify({
    'swf'  : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.swf',
    'uploader'    : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.php',
    'buttonText' : 'Upload image',
    'cancelImg' : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/cancel.png',
    'folder'    : '/wp-content/uploads/user_pics',
    'auto'      : true,
    'onUploadSuccess' : function(file, data, response) {
    	jQuery('.avatar-handler img.logo').attr('src', 'http://dev.apptual.com/wp-content/uploads/user_pics/'+data);
      jQuery('.avatar-handler img.logo').attr('width', 200);
      jQuery('#program_logo').val(data);
    }
  });

  jQuery('.pitch_logo_button').uploadify({
    'swf'  : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.swf',
    'uploader'    : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.php',
    'buttonText' : 'Upload image',
    'cancelImg' : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/cancel.png',
    'folder'    : '/wp-content/uploads/user_pics',
    'auto'      : true,
    'onUploadSuccess' : function(file, data, response) {
    		jQuery('.avatar-handler img.logo').attr('src', 'http://dev.apptual.com/wp-content/uploads/user_pics/'+data);
        jQuery('.avatar-handler img.logo').attr('width', 200);
        jQuery('#pitch_logo').val(data);
    }
  });

  /*Uploadify js*/

  /*SKills tag and add tags*/
  var crit_tags = [
    " business development", " Business models", "3d design", "3D Modelling", "3d Studio Max", "A", "Accounting", "Acting", "Adaptability", "Administration", "Adobe Illustrator CS6", "Adobe Photoshop CS6", "Analytical and logical reasoning", "Application development ", "architectural design", "architectural theory", "Artificial Intelligence", "ASP", "Autocad", "awfawfawf", "behaviour change", "Biology", "blog writing", "Brand development", "Brand strategy", "Branding", "Business Analytics", "Business Canvas", "Business Cases", "Business development", "Business management", "Business Models", "Business Planning", "C", "C#", "C++", "CAD designs", "Campaigns", "Cantonese", "Chemistry", "Clinical development", "Clinical Research", "Clinical trials", "Coaching", "Cognitive Behavioural The", "Communication", "Communications", "communities", "Community Enabling", "Community management", "company law", "Computer Networking", "Computer Vision", "Computer-aided detection", "computing", "construction", "Consultancy", "Consultative Sales", "Consumer Insight", "Content Marketing", "copuing", "copying", "copyright", "Creative Design", "Creative thinking", "Creativity", "Critical Thinking", "CTO", "Curiosity", "Current Affairs", "Customer development", "Customer Service", "Data analysis", "Data analysis and integra", "Data-archiving", "Decision Making", "deduction reasoning", "Design", "design thinking", "Detection", "Developer Marketing", "Directing", "drhdrh", "drhdrhdrh", "drhrdh", "Due Diligence", "Early-Stage Finaning", "Education", "egsegse", "enabling others to achieve their goals", "Enterprise Software", "entrepreneurship", "esgsegseg", "evangelist", "Event management", "Executive Education", "Eye tracking", "film making", "Final Cut Pro", "Finance", "Financial Modelling", "FOB & CIF", "Forecasting", "French", "Fund-raising", "Funding", "Fundraising", "German", "Getting things done", "ghost writing", "GIS", "GNSS", "Graphic Design", "Great communicator", "Groovy", "Guerrilla Marketing", "hdrhdr", "hdrhdrh", "Hiring", "HTML5/CSS3", "Human Computer Interaction", "idea generation", "Ideation", "Illustrator", "Image enhancement", "Imagination", "InDesign", "Industrial Design", "Industry insight", "Information Systems", "Information Technology", "Innovation", "Insights", "Intellectual property", "Invention", "Investigating data", "Investments", "ios development ", "Ipsum", "Italian", "JAVA", "javascript", "Laboratory related", "Languages", "Languages - Arabic (Fluent)", "Languages - Bengali (Advanced)", "Languages - French (Advanced)", "Languages - Hindi (Fluent)", "Languages - Italian (Advanced)", "Languages - Spanish (Basic)", "Latvian language", "Law", "Leadership", "LISP", "Local Authority Tendering", "Lorem", "Machine learning", "making", "Management", "Managing a team", "Mandarin", "Mandarin (Basic)", "Marketing", "Marketing plans", "Mathematica", "maths", "Matlab", "Medical devices", "Medicine", "Mental Health Nursing", "Mentoring", "Miranda", "mobile", "music composition", "mySQL", "Negotiation", "Negotiations", "New product development", "One item at a time", "online engagement", "online marketing", "Operations", "Opportunity definition", "Partner collaboration", "Patient Safety", "People Management", "Pharmacoepidemiology", "Photo Realistic Rendering", "Photography", "Photoshop", "PHP", "Physics", "Pitching", "Portuguese", "Post-marketing analysis", "Presentation Skills", "Problem Solving", "Product Design", "Product Design & Vision", "Product development", "Product Market Fit", "Product Safety", "Product vision", "Programming", "Project Managemena", "Project Management", "projects", "Prolog", "Providing evidence based ", "Pro|Engineer", "Psychiatry", "Psychology", "Public Speaking", "python", "R", "R&D Strategy", "rdhdrhdh", "rdhrdh", "Recruitment", "Registration", "Regulatory fiilling strat", "Research", "Risk-management strategie", "Russian language", "Sales", "Sales & Marketing", "Scheduling", "Segmentation", "segseg", "segsegs", "segsegse", "segsegseg", "SEO", "Service Management", "sgseg", "Singing", "Sketching", "Social entrepreneurship", "Social Impact", "Social Innovation", "Social Media Marketing", "social network analysis", "Software development", "Software development (web)", "Software Strategy, Produc", "Solution Sales", "Some", "Sourcing", "Spanish", "Start-Ups", "Startups", "STATA", "Story telling", "Strategy", "Survey", "System design", "team work", "Teamwork", "Tech", "Tech packs", "Time management", "TMT", "Toxicology", "Trade marks and brands", "Transformation Leadership", "Trend forecasting", "Turbo Pascal", "Understanding both techno", "Understanding how people ", "Urban Design", "User Experience Design", "Valuation", "VB", "Visual Basic", "Visual Marketing Plans", "Web development", "WERT", "Wordpress", "Workshops", "Writing and Editing", "xasx"     ];
  jQuery( ".container_add_tag" ).on("keydown", ".autoSkills", function(){
    $(this).autocomplete({
      source: crit_tags
    });
  });
  
  var crit_interests = [
    " Skiing rugby rowing", "Accelerators", "Adherence", "Apps", "Apps that support health ", "Art", "Artificial Intelligence", "Assisted Living Tehcnologies and Services", "awfawf", "awfawga", "badminton", "Baking", "Basketball", "Bee Keeping", "Behaviour change", "Behavioural change", "Behavioural Science", "Biology Nanotechnology", "Bioscience", "Biotech", "Blasphemy", "Blogging", "Boxing", "Business", "Businsess Improvement Districts", "Child development", "children", "Chinese Classical Dance", "Cinema", "Citizen Science", "Cloud Technology", "Community engagement ", "Computer Science", "Consetetur", "Construction", "Content Marketing", "Cooking", "Creating new products and services ", "cricket", "Crowdfunding", "Cultures & Languages", "Current Affairs", "cutting edge tech", "Cycling", "Design", "dhdrh", "Diabetes", "Digital", "Digital Health", "digital marketing", "Disruptive Companies", "DIYbio", "drhdrh", "Economics", "Education", "Education!", "Entrepreneurship", "environment", "Evaluation", "Evidence-based policy and practice", "F1", "Fashion", "film making", "Finance", "Fitness", "Food and Beverage", "Football", "Fundraising ", "gaming", "Going Out", "gsegseg", "Gym", "hdrhdr", "Health", "health IT", "Health policy", "Health Self Management", "Health tech", "healthcare", "Healthcare - related soft", "Hiking", "Innovation", "Innovation in healthcare", "Interface design", "Internet", "Internet of Things", "Languages", "Law", "Literature", "Location Based Services", "Magic fm", "Malawi", "Marketing", "Mental Health", "Mobile", "Mobile Aps", "Mobile Devices", "Mobile healthcare", "More", "Mountain Biking", "Movies", "Music", "music production", "Native Advertising", "Net ball", "New business models", "New Economic Models", "Nutrition for health", "One item at a time", "Online Education", "Online Events", "Opera", "patient safety", "People", "Philosophy", "Photography", "Piano", "Play", "Playing piano", "Politics", "Project management", "Projects", "Property", "Psychological trauma", "Psychology", "Psychology and health beh", "Public funding", "rdhdrh", "rdhrdh", "Reading", "Real Estate", "Rebum", "Regenerating Communities", "Research ", "Restaurants and food", "Rock climbing", "Running", "Sailing", "segseg", "segsegseg", "segsegsegseg", "Sexual health", "Skiing", "Smart devices", "Smart Home", "Social Enterprise", "Social entrepreneurship", "Social Media", "Social science research methods", "Space", "Special Educational Needs", "Sports", "Squash", "Startup Business", "Startups", "Supporting young people with autism", "Swimming", "Synthetic Biology", "Technology", "Telehealth and telecare", "Tennis", "Testing", "Town Planning", "Travel", "Travelling", "Travelling with my family", "Unicycle Riding", "Unique Design", "Urban Computing", "Urban Regeneration", "User-led innovation", "Using Apptual for the competition management", "UX/UI", "Wearables", "Web Development", "Weightlifting", "Well-thought through solutions (software)", "WERT"     ];
  jQuery( ".container_add_tag" ).on("keydown", ".autoInterests", function(){
    $(this).autocomplete({
      source: crit_interests
    });
  });

	jQuery('.container_tags').on('click', '.delTag', function(){
    $(this).parent().remove();
    return false;
  });

  jQuery('.addSkill').click(function(){
    var value = $('#skills').val();
    var field_name = $('#skills').data('field-name');
    if(value!=""){
      $('#skillList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+field_name+'" readonly="readonly" /></div>');
      $('#skills').val('');
    }
    return false;
  });

  jQuery('.addInterest').click(function(){
    var value = $('#interests').val();
    var field_name = $('#interests').data('field-name');
    if(value!=""){
      $('#interestsList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+field_name+'" readonly="readonly" /></div>');
      $('#interests').val('');
    }
    return false;
  });
	/*SKills tag*/

	/*Color picker*/
  $('input.manubar_color').minicolors({defaultValue: '#4AB2C0'});
	$('input.background_color').minicolors({defaultValue: '#a4a4a4'});
	$(".radioset").buttonset();
	/*Color picker*/

	/*Program Summary => add activity*/
 	$('.newRow').click(function(){
    var col = $('#copy_col').html().replace(/-1-/g, new Date().getTime());
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr>"+col+"</tr>");
    return false;
  });
  $('.newCol').click(function(){
    var act_col = parseInt($("#act_col").val());
    $(".row"+act_col).show();
    $("#act_col").val(act_col+1);
    if(act_col+1 > 6){
      $(this).hide();
    }
    return false;
  });

  $('.addTag').click(function(){ 
      var value = $(this).parent().find('.inputTag').val();
      var code = $(this).parent().find('.code').val();
      if(value != ""){
        $(this).parent().parent().find('.tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="tags['+code+'][]" readonly="readonly" /></div>');
        $(this).parent().find('.inputTag').val('');
      }
      return false;
  });

  $('.container_tags').on('click', '.delTag', function(){
      $(this).parent().remove();
      return false;
   });
  $('.addResource').click(function(){
    var value = $('#inputResource').val();
    if(value!=""){
      $('#resourceList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="resources[]" readonly="readonly" /></div>');
      $('#inputResource').val('');
    }
    return false;
  });
  $('.addCriteria').click(function(){
    var elem = $(this).siblings("input")
    var value = elem.val()
    if(value!=""){
      $('#criteriaList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="tags[entry_criteria][]" readonly="readonly" /></div>');
      elem.val('');
    }
    return false;
  });
  /*Program Summary => add activity*/

  /*New Program*/
  $('.option_mentoring').change(function() {
    if($(this).val() != "false"){
      $('.show_people_who_peer_review_pitches_can_also_submit_pitches').show();
    } else {
      $('.show_people_who_peer_review_pitches_can_also_submit_pitches').hide();
      $('#people_who_peer_review_pitches_can_also_submit_pitches_yes').removeAttr('checked');
      $('#people_who_peer_review_pitches_can_also_submit_pitches_no').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_mentoring').change(function() {
    if($(this).val() != "false"){
      $('.show_option_match_mentors').show();
    } else {
      $('.show_option_match_mentors').hide();
      $('#program_system_match_allowed_true').removeAttr('checked');
      $('#program_system_match_allowed_false').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_light_program').change(function() {
    if($(this).val() != "LIGHT TOUCH"){
      $('.metric_driven_section').show();
    } else {
      $('.metric_driven_section').hide();
      $('#program_virtual_currency_true').removeAttr('checked');
      $('#program_virtual_currency_false').prop('checked', true);;
      
      $('#program_track_incentivise_true').removeAttr('checked');
      $('#program_track_incentivise_false').prop('checked', true);;
      
      $('#program_social_share_true').removeAttr('checked');
      $('#program_social_share_false').prop('checked', true);;
      
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_delete_not_selected').change(function() {
    if($(this).val() != "true"){
      $('.show_option_keep_data').show();
    } else {
      $('.show_option_keep_data').hide();
      $('#program_option_keep_data_true').removeAttr('checked');
      $('#program_option_keep_data_false').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_delete_not_selected').change(function() {
    if($(this).val() != "true"){
      $('.show_option_not_selected_can_continue').show();
    } else {
      $('.show_option_not_selected_can_continue').hide();
      $('#program_not_selected_can_continue_true').removeAttr('checked');
      $('#program_not_selected_can_continue_false').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_delete_not_selected').change(function() {
    if($(this).val() != "true"){
      $('.show_option_virtual_ment_for_not_selected').show();
    } else {
      $('.show_option_virtual_ment_for_not_selected').hide();
      $('#program_virtual_mentoring_true').removeAttr('checked');
      $('#program_virtual_mentoring_false').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.option_delete_not_selected').change(function() {
    if($(this).val() != "true"){
      $('.show_option_peer_to_peer_for_not_selected').show();
    } else {
      $('.show_option_peer_to_peer_for_not_selected').hide();
      $('#program_peer_to_peer_support_true').removeAttr('checked');
      $('#program_peer_to_peer_support_false').prop('checked', true);;
      $('.radioset').buttonset("refresh");
    }
  });

  $('.checkval').change(function() {
    var set_val = "high";
    $('.checkval:checked').each(function(index, value){
      if($(this).val() == "no"){
        set_val = "low";
      }
      if($(this).val() == "maybe" && set_val != "low"){
        set_val = "med";
      }
    });
    $("#engagement_rate").removeClass("low").removeClass("med").removeClass("high").addClass(set_val).html(set_val);
  });
  /*New Program*/

  /*Program Scope*/
  $('.add_pitch_tags').click(function(){
	  var value = $(this).parent().find('#inputTag').val();
	  if(value != ""){
	    $('#pitch_tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="tags[pitch_tags][]" readonly="readonly" /></div>');
	    $(this).parent().find('#inputTag').val('');
	  }
	  return false;
	});

	$('.add_mentor_tags').click(function(){
    var value = $(this).parent().find('#inputTag').val();
    if(value != ""){
      $('#mentor_tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="tags[mentor_tags][]" readonly="readonly" /></div>');
      $(this).parent().find('#inputTag').val('');
    }
    return false;
  });
  /*Program Scope*/

  /*Due Deligence Phase*/
  var v = $('.dd_system_stars').attr("checked");
  var v1 = $('.dd_system_points').attr("checked");
  
  $('.dd_system_stars').click(function() {
      $('.dd_system_stars').attr("checked",true);
      $('.dd_system_points').attr("checked",false);
      $('.system_points').hide();
      $('.system_stars').show();
  });
  $('.dd_system_points').click(function() {
      $('.dd_system_points').attr("checked",true);
      $('.dd_system_stars').attr("checked",false);
      $('.system_stars').hide();
      $('.system_points').show();
  });
  /*Due Deligence Phase*/

  /*Pitch*/
  jQuery('.pitch_logo_button').uploadify({
    'swf'  : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.swf',
    'uploader'    : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/ul_sn.php',
    'buttonText' : 'Upload image',
    'cancelImg' : 'http://dev.apptual.com/wp-content/themes/apptual/uploader/cancel.png',
    'folder'    : '/wp-content/uploads/user_pics',
    'auto'      : true,
    'onUploadSuccess' : function(file, data, response) {
    		jQuery('.avatar-handler img.logo').attr('src', 'http://dev.apptual.com/wp-content/uploads/user_pics/'+data);
        jQuery('.avatar-handler img.logo').attr('width', 200);
        jQuery('#pitch_logo').val(data);
    }
  });

  $('.container_tags').on('click', '.delTag', function(){
			$(this).parent().remove();
			return false;
	});
	$('.addPitchTag').click(function(){
		var value = $('.pitchTag').val();
		var field_name = $('.pitchTag').data("field-name");
		if(value != ""){
			$('#tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+ field_name +'" readonly="readonly" /></div>');
			$('.pitchTag').val('');
		}
		return false;
	});

	jQuery('.editFormLink').click(function(){
		jQuery('.editForm').addClass('editactive');
		// jQuery(this).hide();
		return false;
	});

  /*Pitch*/
 
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
  /*Feed Likes*/

 	
  /*Feed Likes*/
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
    

$('#texteditor').find('div').css('width','100%');
	// filter
	$(".filter-head ul li").click(function(){
	  if (!$(this).hasClass("active-f")) {
	    $("li.active-f").removeClass("active-f");
	    $(this).addClass("active-f");
	  }
	});
	
jQuery(document).ready(function($){
function rgb2hex(rgb){
 rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
 return "#" +
  ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[3],10).toString(16)).slice(-2);
}
var hex = rgb2hex($('#mainnavi').css('background-color'));
var lum = 2;

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
$(".faq_title p").css( "color", rgb );
$(".question_no").css( "color", rgb );
});

jQuery(document).ready(function($){
function rgb2hex(rgb){
 rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
 return "#" +
  ("0" + parseInt(rgb[1],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[2],10).toString(16)).slice(-2) +
  ("0" + parseInt(rgb[3],10).toString(16)).slice(-2);
}
var hex = rgb2hex($('#masthead').css('background-color'));
var lum = 2;

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
//$(".navbar-brand, .navbar-nav > li.active > a").css( "color", rgb );
});

	/*Program Summary => add partner*/
 $('.partnerRow').click(function(){
    var col = $('#partner_col').html().replace(/-1-/g, new Date().getTime());
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr>"+col+"</tr>");
    return false;
  });
/*
$(document).on('click', '.upload_doc_local', function(event){
    event.preventDefault();
    $('#partner_doc_'+$(this).attr('id')+'_locally').attr("disabled",false);
	$('#partner_doc_'+$(this).attr('id')+'_remote').attr("disabled",true);
    return false;
  });

$(document).on('click', '.upload_doc_remote', function(event){
    event.preventDefault();
    $('#partner_doc_'+$(this).attr('id')+'_locally').attr("disabled",true);
    $('#partner_doc_'+$(this).attr('id')+'_remote').attr("disabled",false);
	$('#partner_doc_'+$(this).attr('id')+'_remote').focus();
    return false;
  });

$(document).on('click', '.upload_logo_local', function(event){
    event.preventDefault();
    $('#partner_logo_'+$(this).attr('id')+'_locally').attr("disabled",false);
    $('#partner_logo_'+$(this).attr('id')+'_remote').attr("disabled",true);
    return false;
  });

$(document).on('click', '.upload_logo_remote', function(event){
    event.preventDefault();
    $('#partner_logo_'+$(this).attr('id')+'_locally').attr("disabled",true);
    $('#partner_logo_'+$(this).attr('id')+'_remote').attr("disabled",false);
    $('#partner_logo_'+$(this).attr('id')+'_remote').focus();
    return false;
  });
*/
  /*Program Case Study => add case study*/
  $('.caseStudyRow').click(function(){
    var col = $('#case_study_col').html().replace(/-1-/g, new Date().getTime());
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr>"+col+"</tr>");
    return false;
  });

	/*Program Summary => add quote*/
 $('.quoteRow').click(function(){
    var col = $('#quote_col').html().replace(/-1-/g, new Date().getTime());
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr>"+col+"</tr>");
    return false;
  });

	/*Program Summary => add freeform*/
 $('.freeformRow').click(function(){
 	var time = new Date().getTime()
    var col = $('#freeform_col').html().replace(/-1-/g, time);
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr id=fields_"+time+">"+col+"</tr>");
    $("#program_summary_program_free_forms_attributes_"+time+"_section_id").val(time)
    return false;
  });

  $('.freeformRowEco').click(function(){
 	var time = new Date().getTime()
    var col = $('#freeform_col').html().replace(/-1-/g, time);
    $(this).parent().parent().parent().parent().find("table>tbody").append("<tr id=fields_"+time+">"+col+"</tr>");
    $("#eco_summary_eco_free_forms_attributes_"+time+"_section_id").val(time)
    return false;
  });

  $('.freeformfieldsRowDynamic').click(function(){
  	var time = new Date().getTime()
	if ($("#sub_title_check_"+parseInt(this.id)+":checked").length ==1)
	  {
	  var col_sub_title = $('#freeform_fields_col_sub_title').html().replace(/-2-/g, time);
	   $("#free_form_fields_append_"+parseInt(this.id)).append(col_sub_title);
	    $("#program_summary_program_free_forms_attributes_sub_title_"+time+"_section_id").val(parseInt(this.id))
	 }
	 if ($("#body_check_"+parseInt(this.id)+":checked").length ==1) {
	  var col_body = $('#freeform_fields_col_body').html().replace(/-2-/g, time);
	   $("#free_form_fields_append_"+parseInt(this.id)).append(col_body);
	  new nicEditor().panelInstance("program_summary_program_free_forms_attributes_"+time+"_body");
	$("#program_summary_program_free_forms_attributes_body_"+time+"_section_id").val(parseInt(this.id))
	}
	   return false;
  });

	/*Program Summary => add freeform*/
 $("[data-auto-options]").each(function(i, elem){
    $(elem).on("keydown", function(){
      $(this).autocomplete({
        source: $(this).data("auto-options")
      });
    });
  });
  
  	// $(function(){
				// $('textarea').autosize();
			// });

  $(document).ready(function(e){
    //data = $(location).attr('pathname');
    data = $('#page_name').val();
    if(data){
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
      });
    };
    
    $(".rating-kv").rating({
      showCaption: false
    });
    
    $(".clear-rating").remove(); 
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
  })

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

  function readURL(input) {
    if(input.files && input.files[0]){
      var reader = new FileReader();
      reader.onload = function (e) {
          $('#show_img').attr('src', e.target.result);
      }
      reader.readAsDataURL(input.files[0]);
    }
  }

  $(document).on('change', ".upload_img", function(e){
    readURL(this);
  });
 
  $(document).on('change', ".upload_badge_img", function(e){
    var val = $(this).val();
   if(val.substring(val.lastIndexOf('.') + 1) == "png"){
    readURL(this);
   }
   else{
     $(this).val("");
     $('#show_img').attr('src', "/images/icons/image-missing.png");
     alert('Use only Png format image');
   }
  });

  $(document).on('click', '.upload_doc_local', function(event){
    event.preventDefault();
    $('#partner_doc_'+$(this).attr('id')+'_locally').attr("disabled",false);
	$('#partner_doc_'+$(this).attr('id')+'_remote').attr("disabled",true);
    return false;
  });

$(document).on('click', '.upload_doc_remote', function(event){
    event.preventDefault();
    $('#partner_doc_'+$(this).attr('id')+'_locally').attr("disabled",true);
    $('#partner_doc_'+$(this).attr('id')+'_remote').attr("disabled",false);
	$('#partner_doc_'+$(this).attr('id')+'_remote').focus();
    return false;
  });

$(document).on('click', '.upload_logo_local', function(event){
    event.preventDefault();
    $('#partner_logo_'+$(this).attr('id')+'_locally').attr("disabled",false);
    $('#partner_logo_'+$(this).attr('id')+'_remote').attr("disabled",true);
    return false;
  });

$(document).on('click', '.upload_logo_remote', function(event){
    event.preventDefault();
    $('#partner_logo_'+$(this).attr('id')+'_locally').attr("disabled",true);
    $('#partner_logo_'+$(this).attr('id')+'_remote').attr("disabled",false);
    $('#partner_logo_'+$(this).attr('id')+'_remote').focus();
    return false;
  });

  $(document).on('keypress keyup keydown', '.autoSkills', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addKeyword').trigger('click');
      return false;
    }
  })
  // $('.collapses').collapsiblePanel();
  // $('[data-toggle="tooltip"]').tooltip({'placement': 'bottom'});
//   
   // $(".stick_me").stick_in_parent({
  	 // parent: $("#rightcontent"),
  	 // offset_top: 80
   // });
  // $('.task_master').rollbar({zIndex:80}); 
  // $('.dds').ddslick();

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

  $('.modal').on('hidden.bs.modal', function (e) {
    $('body').removeClass('modal-open');
  });

});

//Survey Form JS
  $(document).ready(function(){
    $(".add_new_question").on("click", function(e){
      e.preventDefault();
      var latest_index = parseInt($("#main_question_div").attr('data-latest_index')) +1;
      $(".custom_field_duplicate").find('.row').attr('id', "question_row_"+latest_index+"-"+latest_index);
      $("#main_question_div").attr('data-latest_index', latest_index);
      var text = $(".custom_field_duplicate").html();
      $(this).prev().append(text);
      var i = 1;
      $('.column').find('.panel-title').each(function() {
        $(this).html("Question " + i);
        i++;
      });
    });

    $("form").on("change", "#question__question_type", function(e){
      var parent_tr = $(this).parents('.ques_select');
      if($(this).val() == "dropdown" || $(this).val() == "dropdown_with_other" || $(this).val() == "dropdown_with_multiple_select" || $(this).val() == "branch_field" || $(this).val() == "file_upload"){
        parent_tr.next().show();
        if ($(this).val() == "file_upload")
          {
            parent_tr.find(".not_in_file_upload").hide();
            parent_tr.find(".chg_file_upload").text("File Type");
          }
      }else{
        parent_tr.next().hide();
      }
      next_tr = parent_tr.next().next()
      if( next_tr.hasClass("options")) {
        next_tr.remove();
      }
      else{
         while( next_tr.hasClass("option_row")) {
          next_tr.remove();
          next_tr = parent_tr.next().next('tr')
        }
      }
    });

    $("form").on("change", "select[name='question[][option_fields][][question_type]']", function(e){
      var parent_tr = $(this).parents("tr");
      if($(this).val() == "dropdown" || $(this).val() == "dropdown_with_other"  || $(this).val() == "dropdown_with_multiple_select" || $(this).val() == "branch_field" || $(this).val() == "file_upload" ){
        parent_tr.next(".options").show();
      }else{
        parent_tr.next(".options").hide();
      }
    });

    $('body').on("change", ".options_field_area", function(e){
      var parent_tr = $(this).parents("tr");
      var parent_tr = $(this).parents('.answer_div');
      if (parent_tr.prev().find('#question__question_type').val() == "branch_field") {
        next_tr = parent_tr.next()
        if( next_tr.hasClass("options")) {
          next_tr.remove();
        }
        while( next_tr.hasClass("option_row")) {
          next_tr.remove();
          next_tr = parent_tr.next()
        }
        var option_values = $(this).val().split(",").reverse()
        for (var i = 0; i < option_values.length; i++) {
          $(".duplicate_options tbody").find('.option_name').html("Options for "+option_values[i]);
          $(".option_field_duplicate tbody").find('.option_name_field').attr("value", option_values[i])
          $(".duplicate_options tbody").find('.insert_option_field').attr("data_option_name", option_values[i])
          var text = $(".duplicate_options tbody").html();
          $(parent_tr).after(text);
          e.preventDefault();
        }
      }
    });

    $(document).on("click", ".insert_option_field", function(e){
      $(".option_field_duplicate tbody").find('.option_name_field').attr("value", $(this).attr("data_option_name"))
      var text = $(".option_field_duplicate tbody").html();
      $(this).parents('tr').before(text)
      e.preventDefault();
    });
  });
  
  $(document).on("click", ".hide_custom_field", function(e){
    e.preventDefault();
    $(this).parents(".row").remove();
    var i = 1;
    $('.column').find('.panel-title').each(function() {
      $(this).html("Question " + i);
      i++;
    });
  });
  $(document).on("click", ".copy_custom_field", function(e){
    e.preventDefault();
    var latest_index = parseInt($("#main_question_div").attr('data-latest_index')) +1;
    $("#main_question_div").attr('data-latest_index', latest_index);
    var latest_row_id = "question_row_"+latest_index+"-"+latest_index;
    var static = "<div id='"+latest_row_id+"' class='row portlet ui-widget ui-widget-content ui-helper-clearfix ui-corner-all'>"
    var original = $(this).parents(".row");
    var text = static + original.html() + "</div>"
    original.after(text);
    $('#'+latest_row_id).find('.delete_ques').addClass('hide_custom_field').removeAttr('data-method').attr('href', '#');
    $('#'+latest_row_id).find('.ques_id_field').removeAttr('value');
    var i = 1;
    $('.column').find('.panel-title').each(function() {
      $(this).html("Question " + i);
      i++;
    });
  });
  $(document).on("click", '.question_required', function(e){
    $(this).next().attr('value', $(this).is(":checked"));
  });

  $(document).ready(function(e){
    var limit = 140;
        $(".desc_div").each(function() {
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
  })

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
  
  function reload_and_show_message(){
    $('#rightcontent').load(window.location + " .innercontent");
    if($('.alert_top_spacing').length){
      $('.alert_top_spacing').html('<button type="button" data-dismiss="alert" class="close">×</button>User Successfully deleted');
    }
    else{
      $('#main').prepend('<div class="alert alert-info alert_top_spacing"><button type="button" data-dismiss="alert" class="close">×</button>User Successfully deleted</div>')
    }
  }

// Javascript for username functionality in the application if anonymous features is enabled for program
$(document).ready(function(){
  $("#username").keyup(function() {
    $("#user_first_name").val($(this).val())
    $("#user_last_name").val("")
  });
  $("#user_anonymous").change(function() {
    if ($("#"+this.id+":checked").length ==  "1"){        
      user_anonymous_fields()
    }
    else{      
      user_normal_fields()
    }
  });

  function user_normal_fields() {
    $("#username_fields").hide()
    $("#username").removeClass("required")
    f_name_hidden = $("#user_first_name_hidden").val()
    l_name_hidden = $("#user_last_name_hidden").val()
    $("#user_first_name").addClass("required").val(f_name_hidden).show()
    $("#user_last_name").addClass("required").val(l_name_hidden).show()
    $("#user_first_name_hidden").hide()
    $("#user_last_name_hidden").hide()
    $("#user_first_name_hidden").removeClass("required")
    $("#user_last_name_hidden").removeClass("required")
  }
  function user_anonymous_fields() {
    $("#username_fields").show()
    $("#username").addClass("required")
    f_name = $("#user_first_name").val()
    l_name = $("#user_last_name").val()
    $("#user_first_name_hidden").addClass("required").val(f_name).show()
    $("#user_last_name_hidden").addClass("required").val(l_name).show()
    $("#user_first_name").hide()
    $("#user_last_name").hide()
    $("#user_last_name").val("")
    $("#user_first_name").removeClass("required")
    $("#user_last_name").removeClass("required")
  }
  if ($("#user_anonymous:checked").length ==  "1"){        
    user_normal_fields()
    user_anonymous_fields()    
  }
  else{
    $("#username").val("").removeClass("required")
  }
});
// end
