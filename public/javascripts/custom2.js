jQuery(document).ready(function($){

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
		height		: '450px',
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

	$('.contact_us').click(function(){
		var name = $('.contactname').val();
		var email = $('.email').val();
		var sub = $('.subject').val();
		var msg = $('.message').val();
		var comp = $('.company_name').val();
		var cont_name_valid = $('.contactname').hasClass('valid');
		var email_valid = $('.email').hasClass('valid');
		var sub_valid = $('.subject').hasClass('valid');
		var msg_valid = $('.message').hasClass('valid');
		var comp_valid = $('.company_name').hasClass('valid');
		if(cont_name_valid != false && email_valid != false && sub_valid != false && msg_valid != false && comp_valid != false) {
			jQuery.post(admin_url, {action:'sendContactInfo',ajax:'true',name:name,email:email,sub:sub,msg:msg,comp:comp}, function(data){
				window.location.reload();
			});
		}
	});
});