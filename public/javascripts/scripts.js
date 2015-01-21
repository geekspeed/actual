(function($) {
	'use strict';
	//Used in Twiter feed & Testimonial
	$(".cbp-qtrotator").cbpQTRotator();
	
	$('.mapCon').height($('.interionMap').height());
	
	//Tabs	
	$('.myTab li:first-child').addClass('active');
	$('.tab-pane:first-child').addClass('active');
			
	$('.myTab a').click(function (e) {
		e.preventDefault();
		$(this).tab('show');
	});
	
	// validate form on keyup and submit
	$("#contactform").validate({
		rules: {
			contactname: {
				required: true,
				minlength: 2
			},
			email: {
				required: true,
				email: true
			},
			subject: {
				required: true,
				minlength: 2
			},
			message: {
				required: true,
				minlength: 10
			}
		},
		messages: {
			contactname: {
				required: "Please enter your name" ,
				minlength: jQuery.format("Your name needs to be at least {0} characters")
			},
			email: {
				required: "Please enter a valid email address",
				minlength: "Please enter a valid email address"
			},
			subject: {
				required: "You need to enter a subject!",
				minlength: jQuery.format("Enter at least {0} characters")
			},
			message: {
				required: "You need to enter a message!",
				minlength: jQuery.format("Enter at least {0} characters")
			}
		},
		// set this class to error-labels to indicate valid fields
		success: function(label) {
			label.addClass("checked");
		},
		submitHandler: function() {
			
			$('#contactform').prepend('<p class="loaderIcon"><img src="'+ interionAjax.templateurl +'/library/img/ajax-loader.gif" alt="Loading..."></p>');
			var name = $('input#contactname').val();
			var email = $('input#email').val();
			var subject = $('input#subject').val();
			var message = $('textarea#message').val();

			$.ajax({
				type: 'post',
				url: interionAjax.ajaxurl,
				//data: 'contactname=' + name, + '&email=' + email + '&subject=' + subject + '&message=' + message,
				data: {
					action		: 'interion_submit_form',
					contactname	: name,
					email		: email,
					subject		: subject,
					message 	: message,
					sendto		: interionAjax.email,
					nonce		: interionAjax.nonce
				},
			}).done(function(results) {
					$('#contactform p.loaderIcon').fadeOut(1000);
					$('#contactform div.response').html(results);
				});	

			$(':input','#contactform').not(':button, :submit, :reset, :hidden').val('');

		}
	});
	
	



	//OnePage Navigation
    $('.mainNav').onePageNav({
    	currentClass: 'active',
		scrollOffset: 120
	});

	//Added Animation for logo scroll
	$("#mainHeader .logo a").click(function(e){
		e.preventDefault();
		$("body,html").animate({scrollTop:0},800);
		return false;
	});
	
	var $container = $('#container');

	$container.isotope({
		itemSelector : '.element'
	});
      
      
    var $optionSets = $('#options .option-set'),
        $optionLinks = $optionSets.find('a');

    $optionLinks.click(function(){
        var $this = $(this);
        // don't proceed if already selected
        if ( $this.hasClass('selected') ) {
          return false;
        }
        var $optionSet = $this.parents('.option-set');
        $optionSet.find('.selected').removeClass('selected');
        $this.addClass('selected');
  
        // make option object dynamically, i.e. { filter: '.my-filter-class' }
        var options = {},
            key = $optionSet.attr('data-option-key'),
            value = $this.attr('data-option-value');
        // parse 'false' as false boolean
        value = value === 'false' ? false : value;
        options[ key ] = value;
        if ( key === 'layoutMode' && typeof changeLayoutMode === 'function' ) {
          // changes in layout modes need extra logic
          changeLayoutMode( $this, options );
        } else {
          // otherwise, apply new options
          $container.isotope( options );
        }
        
        return false;
    });

$( window ).load(function() {
  	//Affix Navigation	
       var pos = $('#mainHeader').position();
	$('#mainHeader').affix({
		offset: {
			top: pos.top - $('#mainHeader').height()
		}
	});
});

$( window ).resize(function() {
  //Affix Navigation	
       var pos = $('#mainHeader').position();
	$('#mainHeader').affix({
		offset: {
			top: pos.top - $('#mainHeader').height()
		}
	});
});
  
})(jQuery);