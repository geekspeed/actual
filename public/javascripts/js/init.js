jQuery(function($){

var TENTERED = window.TENTERED || {};

/* ==================================================
	Contact Form Validations
================================================== */
	TENTERED.ContactForm = function(){
		$('.contact-form').each(function(){
			var formInstance = $(this);
			formInstance.submit(function(){
		
			var action = $(this).attr('action');
		
			$("#message").slideUp(750,function() {
			$('#message').hide();
		
			$('#submit')
				.after('<img src="images/assets/ajax-loader.gif" class="loader" />')
				.attr('disabled','disabled');
		
			$.post(action, {
				name: $('#name').val(),
				email: $('#email').val(),
				phone: $('#phone').val(),
				subject: $('#subject').val(),
				comments: $('#comments').val()
			},
				function(data){
					document.getElementById('message').innerHTML = data;
					$('#message').slideDown('slow');
					$('.contact-form img.loader').fadeOut('slow',function(){$(this).remove()});
					$('#submit').removeAttr('disabled');
					if(data.match('success') != null) $('.contact-form').slideUp('slow');
		
				}
			);
			});
			return false;
		});
		});
	}

/* ==================================================
	Search Bar
================================================== */
	TENTERED.SearchBar = function(){
		$(".search-icon #open").click(function(){
			$(".search-icon #open").hide();
			$(".search-icon #close").css("display","block");
			$("#search-box").show();
			return false;
		});
		$(".search-icon #close").click(function(){
			$(".search-icon #close").hide();
			$(".search-icon #open").css("display","block");
			$("#search-box").hide();
			return false;
		});
	}

/* ==================================================
	Responsive Nav Menu
================================================== */
	TENTERED.navMenu = function() {
		  // Responsive Menu Events
		  $("#main-menu").clone().appendTo(".mobile-menu > div > div");
		  $(".mmenu-toggle").click(function(){
			  $(".mobile-menu").slideToggle();
		  });
		  $(".one-pager.header-style5 .mmenu-toggle").click(function(){
			  $("#main-menu").slideToggle();
		  });
		  $(".one-pager-alt.header-style6 .mmenu-toggle").click(function(){
			  $("#main-menu").slideToggle();
		  });
		  $(".landing-page.header-style6 .mmenu-toggle").click(function(){
			  $("#main-menu").slideToggle();
		  });
	}
/* ==================================================
	Sticky Animated Nav Menu
================================================== */		
	TENTERED.stickyanimated = function() {

			if($("body").hasClass("boxed"))
				return false;
			var header = $(".stickyanimated .site-header"),
				headerHeight = header.height(),
				logoWrapper = header.find(".logo"),
				logo = header.find(".logo img"),
				logoWidth = logo.width(),
				logoHeight = logo.height(),
				$this = this,
				logoPaddingTop = 28,
				logoSmallHeight = 50;

			logo
				.css("height", logoSmallHeight);

			var logoSmallWidth = logo.width();

			logo
				.css("height", "auto")
				.css("width", "auto");


			$this.checkStickyMenu = function() {

				if($(window).scrollTop() > ((headerHeight - 15) - logoSmallHeight) && $(window).width() > 291) {

					if($("body.stickyanimated").hasClass("sticky-menu-active"))
						return false;

					logo.stop(true, true);

					$("body.stickyanimated").addClass("sticky-menu-active").css("padding-top", headerHeight);

					logoWrapper.addClass("logo-sticky-active");

					logo.animate({
						width: logoSmallWidth,
						height: logoSmallHeight,
						top: logoPaddingTop + "px"
					}, 200, function() {});

				} else {

					if($("body.stickyanimated").hasClass("sticky-menu-active")) {

						$("body.stickyanimated").removeClass("sticky-menu-active").css("padding-top", 0);

						logoWrapper.removeClass("logo-sticky-active");

						logo.animate({
							width: logoWidth,
							height: logoHeight,
							top: "0px"
						}, 200, function() {

							logo.css({
								width: "auto",
								height: "auto"
							});

						});

					}

				}

			}

			$(window).on("scroll", function() {
				$this.checkStickyMenu();
			});
		}
/* ==================================================
	Scroll to Top
================================================== */
	TENTERED.scrollToTop = function(){
		var windowWidth = $(window).width(),
			didScroll = false;
	
		var $arrow = $('#back-to-top');
	
		$arrow.click(function(e) {
			$('body,html').animate({ scrollTop: "0" }, 750, 'easeOutExpo' );
			e.preventDefault();
		})
	
		$(window).scroll(function() {
			didScroll = true;
		});
	
		setInterval(function() {
			if( didScroll ) {
				didScroll = false;
	
				if( $(window).scrollTop() > 800 ) {
					$arrow.fadeIn();
				} else {
					$arrow.fadeOut();
				}
			}
		}, 250);
	}
/* ==================================================
   Accordion
================================================== */
	TENTERED.accordion = function(){
		var accordion_trigger = $('.accordion-heading.accordionize');
		
		accordion_trigger.delegate('.accordion-toggle','click', function(event){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).addClass('inactive');
			}
			else{
				accordion_trigger.find('.active').addClass('inactive');          
				accordion_trigger.find('.active').removeClass('active');   
				$(this).removeClass('inactive');
				$(this).addClass('active');
			}
			event.preventDefault();
		});
	}
/* ==================================================
   Toggle
================================================== */
	TENTERED.toggle = function(){
		var accordion_trigger_toggle = $('.accordion-heading.togglize');
		
		accordion_trigger_toggle.delegate('.accordion-toggle','click', function(event){
			if($(this).hasClass('active')){
				$(this).removeClass('active');
				$(this).addClass('inactive');
			}
			else{
				$(this).removeClass('inactive');
				$(this).addClass('active');
			}
			event.preventDefault();
		});
	}
/* ==================================================
   Tooltip
================================================== */
	TENTERED.toolTip = function(){ 
		$('a[data-toggle=tooltip]').tooltip();
	}
/* ==================================================
   Pricing Tables
================================================== */
	var $tallestCol;
	TENTERED.pricingTable = function(){
		$('.pricing-table').each(function(){
			$tallestCol = 0;
			$(this).find('> div .features').each(function(){
				($(this).height() > $tallestCol) ? $tallestCol = $(this).height() : $tallestCol = $tallestCol;
			});	
			if($tallestCol == 0) $tallestCol = 'auto';
			$(this).find('> div .features').css('height',$tallestCol);
		});
	}

/* ==================================================
   IsoTope Portfolio
================================================== */
		TENTERED.IsoTope = function() {

			$("ul.sort-source").each(function() {
				var source = $(this);
				var destination = $("ul.sort-destination[data-sort-id=" + $(this).attr("data-sort-id") + "]");

				if(destination.get(0)) {

					var minParagraphHeight = 0;
					var paragraphs = $("span.thumb-info-caption p", destination);

					paragraphs.each(function() {
						if($(this).height() > minParagraphHeight)
							minParagraphHeight = ($(this).height() + 10);
					});

					paragraphs.height(minParagraphHeight);

					$(window).load(function() {

				$(".portfolio-item").show();
						destination.isotope({
							itemSelector: "li",
							layoutMode: 'sloppyMasonry'
						});

						source.find("a").click(function(e) {

							e.preventDefault();

							var $this = $(this),
								filter = $this.parent().attr("data-option-value");

							source.find("li.active").removeClass("active");
							$this.parent().addClass("active");

							destination.isotope({
								filter: filter
							});

							self.location = "#" + filter.replace(".","");

							return false;

						});

						$(window).bind("hashchange", function(e) {

							var hashFilter = "." + location.hash.replace("#",""),
								hash = (hashFilter == "." || hashFilter == ".*" ? "*" : hashFilter);

							source.find("li.active").removeClass("active");
							source.find("li[data-option-value='" + hash + "']").addClass("active");

							destination.isotope({
								filter: hash
							});

						});

						var hashFilter = "." + (location.hash.replace("#","") || "*");

						var initFilterEl = source.find("li[data-option-value='" + hashFilter + "'] a");

						if(initFilterEl.get(0)) {
							source.find("li[data-option-value='" + hashFilter + "'] a").click();
						} else {
							source.find("li:first-child a").click();
						}

					});

				}

			});

		}

/* ==================================================
   IsoTope Full Width
================================================== */
	TENTERED.IsoTopeFull = function() {
		$('.isotope').each(function(){
			var isotopeInstance = $(this);
			var container = $(isotopeInstance).find('.portfolio-container');
			isotopeColumns = container.attr("data-columns") ? container.attr("data-columns") : "1"
			container.addClass('portfolio-wrap-' + isotopeColumns);
			$(window).load(function() { 
			$(".portfolio-item").show();
		  $('.portfolio-filter a').click(function(){
			  $('.portfolio-filter a').parent("li").removeClass('active');
			  $(this).parent("li").addClass('active');
			  var selector = $(this).attr('data-filter');
			  container.isotope({ filter: selector });
			  setProjects();		
			  return false;
		  });
			   
			  function splitColumns() { 
				  var winWidth = $(window).width(), 
					  columnNumb = 1;
				  
				  
				  if (winWidth > 1024) {
					  columnNumb = isotopeColumns;
				  } else if (winWidth > 900) {
					  columnNumb = isotopeColumns;
				  } else if (winWidth > 479) {
					  columnNumb = 2;
				  } else if (winWidth < 479) {
					  columnNumb = 1;
				  }
				  
				  return columnNumb;
			  }		
			  
			  function setColumns() { 
				  var winWidth = $(window).width(), 
					  columnNumb = splitColumns(), 
					  postWidth = Math.floor(winWidth / columnNumb);
				  
				  container.find('.portfolio-item').each(function () { 
					  $(this).css( { 
						  width : postWidth + 'px' 
					  });
				  });
			  }		
			  
			  function setProjects() { 
				  setColumns();
				  container.isotope('reLayout');
			  }		
			  
			  container.imagesLoaded(function () { 
				  setColumns();
			  });
				container.isotope({
			  animationEngine : 'best-available',
			  animationOptions: {
				  duration: 200,
				  queue: false
			  },
			  layoutMode: 'fitRows'
		  	});
		
			$(window).bind('resize', function () { 
				setProjects();			
			});
			});
		});
	}
/* ==================================================
   Flickr Widget
================================================== */
	TENTERED.FlickrWidget = function() {
		$('.flickr-widget').each(function(){
			var flickrInstance = $(this); 
			flickrImages = flickrInstance.attr("data-images-count") ? flickrInstance.attr("data-images-count") : "1",
			flickrUserid = flickrInstance.attr("data-flickr-userid") ? flickrInstance.attr("data-flickr-userid") : "1"
			flickrInstance.jflickrfeed({
				limit: flickrImages,
				qstrings: {
					id: flickrUserid
				},
				itemTemplate: '<a href="{{image_b}}"><li><img alt="{{title}}" src="{{image_s}}" /></li></a>'
			});
		});
	}

/* ==================================================
   Twitter Widget
================================================== */
	TENTERED.TwitterWidget = function() {
		$('.twitter-widget').each(function(){
			var twitterInstance = $(this); 
			twitterTweets = twitterInstance.attr("data-tweets-count") ? twitterInstance.attr("data-tweets-count") : "1"
			twitterInstance.twittie({
            	dateFormat: '%b. %d, %Y',
            	template: '<li>{{tweet}} <span class="date">{{date}}</span></li>',
            	count: twitterTweets,
            	hideReplies: true
        	});
		});
	}
/* ==================================================
   Owl Carousel
================================================== */
	TENTERED.OwlCarousel = function() {
		$('.owl-carousel').each(function(){
				var carouselInstance = $(this); 
				carouselColumns = carouselInstance.attr("data-columns") ? carouselInstance.attr("data-columns") : "1",
				carouselitemsDesktop = carouselInstance.attr("data-items-desktop") ? carouselInstance.attr("data-items-desktop") : "4",
				carouselitemsDesktopSmall = carouselInstance.attr("data-items-desktop-small") ? carouselInstance.attr("data-items-desktop-small") : "3",
				carouselitemsTablet = carouselInstance.attr("data-items-tablet") ? carouselInstance.attr("data-items-tablet") : "2",
				carouselitemsMobile = carouselInstance.attr("data-items-mobile") ? carouselInstance.attr("data-items-mobile") : "1",
				carouselAutoplay = carouselInstance.attr("data-autoplay") == 'yes' ? true : false,
				carouselPagination = carouselInstance.attr("data-pagination") == 'yes' ? true : false,
				carouselArrows = carouselInstance.attr("data-arrows") == 'yes' ? true : false,
				carouselSingle = carouselInstance.attr("data-single-item") == 'yes' ? true : false
				carouselStyle = carouselInstance.attr("data-style") ? carouselInstance.attr("data-style") : "fade",
				
				carouselInstance.owlCarousel({
					items: carouselColumns,
					autoPlay : carouselAutoplay,
					navigation : carouselArrows,
					pagination : carouselPagination,
					itemsDesktop:[1199,carouselitemsDesktop],
					itemsDesktopSmall:[979,carouselitemsDesktopSmall],
					itemsTablet:[768,carouselitemsTablet],
					itemsMobile:[479,carouselitemsMobile],
					singleItem:carouselSingle,
					navigationText: ["<i class='fa fa-chevron-left'></i>","<i class='fa fa-chevron-right'></i>"],
					stopOnHover: true,
					lazyLoad: true,
					transitionStyle: carouselStyle
				});
		});
	}
/* ==================================================
   Stellar Parallax
================================================== */
	TENTERED.Stellar = function() {
		if(!Modernizr.touch) {
			$.stellar({
				horizontalScrolling: false
			});
		}
	}
/* ==================================================
   Back to Top
================================================== */
	TENTERED.BackToTop = function() {
		$(function() {
			$('a#back-top').click(function () {
				$('html, body').stop().animate({
					scrollTop: 0
				}, 1500,'easeInOutExpo');
			});
		});
	}
/* ==================================================
   PrettyPhoto
================================================== */
	TENTERED.PrettyPhoto = function() {
		$(function(){
			$("a[data-rel^='prettyPhoto']").prettyPhoto({
				  opacity: 0.5,
				  social_tools: "",
				  deeplinking: false
			});
		});	
	}
/* ==================================================
   SuperFish menu
================================================== */
	TENTERED.SuperFish = function() {
		$('.sf-menu').superfish({
			  delay: 200,
			  animation: {opacity:'show', height:'show'},
			  speed: 'fast',
			  cssArrows: false,
			  disableHI: true
		});
	}
	
/* ==================================================
   Animated Counters
================================================== */
	TENTERED.Counters = function() {
		$('.counters').each(function () {
			$(".timer .count").appear(function() {
			var counter = $(this).html();
			$(this).countTo({
				from: 0,
				to: counter,
				speed: 2000,
				refreshInterval: 60,
				});
			});
		});
	}
/* ==================================================
   Sticky Navigation
================================================== */	
	TENTERED.StickyNav = function() {
		if($("body").hasClass("boxed"))
			return false;
		$("#sticky-nav").sticky({topSpacing:0});
	}
/* ==================================================
   Init Functions
================================================== */
$(document).ready(function(){
	TENTERED.ContactForm();
	TENTERED.scrollToTop();
	TENTERED.accordion();
	TENTERED.toggle();
	TENTERED.toolTip();
	TENTERED.pricingTable();
	TENTERED.navMenu();
	TENTERED.stickyanimated();
	TENTERED.SearchBar();
	TENTERED.FlickrWidget();
	TENTERED.TwitterWidget();
	TENTERED.OwlCarousel();
	TENTERED.Stellar();
	TENTERED.BackToTop();
	TENTERED.PrettyPhoto();
	TENTERED.SuperFish();
	TENTERED.Counters();
	TENTERED.IsoTope();
	TENTERED.IsoTopeFull();
	TENTERED.StickyNav();
});

// FITVIDS
$(".content").fitVids();

// Animation Appear
$("[data-appear-animation]").each(function() {

	var $this = $(this);
  
	$this.addClass("appear-animation");
  
	if(!$("html").hasClass("no-csstransitions") && $(window).width() > 767) {
  
		$this.appear(function() {
  
			var delay = ($this.attr("data-appear-animation-delay") ? $this.attr("data-appear-animation-delay") : 1);
  
			if(delay > 1) $this.css("animation-delay", delay + "ms");
			$this.addClass($this.attr("data-appear-animation"));
  
			setTimeout(function() {
				$this.addClass("appear-animation-visible");
			}, delay);
  
		}, {accX: 0, accY: -150});
  
	} else {
  
		$this.addClass("appear-animation-visible");
  
	}

});
// Animation Progress Bars
$("[data-appear-progress-animation]").each(function() {

	var $this = $(this);

	$this.appear(function() {

		var delay = ($this.attr("data-appear-animation-delay") ? $this.attr("data-appear-animation-delay") : 1);

		if(delay > 1) $this.css("animation-delay", delay + "ms");
		$this.addClass($this.attr("data-appear-animation"));

		setTimeout(function() {

			$this.animate({
				width: $this.attr("data-appear-progress-animation")
			}, 1500, "easeOutQuad", function() {
				$this.find(".progress-bar-tooltip").animate({
					opacity: 1
				}, 500, "easeOutQuad");
			});

		}, delay);

	}, {accX: 0, accY: -50});

});

/* Circular Bars */
if(typeof($.fn.knob) != "undefined") {
	$(".knob").knob({});
}

//Parallax	
if(!Modernizr.touch) {
	$(window).bind('load', function () {
		parallaxInit();						  
	});
}

	function parallaxInit() {
		$('.parallax1').parallax("50%", 0.1);
		$('.parallax2').parallax("50%", 0.1);
		$('.parallax3').parallax("50%", 0.1);
		$('.parallax4').parallax("50%", 0.1);
		$('.parallax5').parallax("50%", 0.1);
		$('.parallax6').parallax("50%", 0.1);
		$('.parallax7').parallax("50%", 0.1);
		$('.parallax8').parallax("50%", 0.1);
		/*add as necessary*/
	}

	

/* One Page Navigation */
$('.moveto-sec1').bind('click', function(){
    pageScroller.goTo(1);
});
$('.moveto-sec2').bind('click', function(){
    pageScroller.goTo(2);
});
$('.moveto-sec3').bind('click', function(){
    pageScroller.goTo(3);
});
$('.moveto-sec4').bind('click', function(){
    pageScroller.goTo(4);
});
$('.moveto-sec5').bind('click', function(){
    pageScroller.goTo(5);
});
$('.moveto-sec6').bind('click', function(){
    pageScroller.goTo(6);
});
$('.moveto-sec7').bind('click', function(){
    pageScroller.goTo(7);
});


/* List Styles */
$('ul.checks li').prepend('<i class="fa fa-check"></i> ');
$('ul.hearts li').prepend('<i class="fa fa-heart"></i> ');
$('ul.inline li').prepend('<i class="fa fa-check-circle-o"></i> ');
$('ul.chevrons li').prepend('<i class="fa fa-chevron-right"></i> ');
$('ul.nav-list-primary li a').prepend('<i class="fa fa-caret-right"></i> ');
$('ul.carets li, #recent_posts.footer-widget ul li').prepend('<i class="fa fa-caret-right"></i> ');

/* Window Height Getter Class */
	wheighter = $(window).height();
	$(".wheighter").css("height",wheighter);
	$(window).resize(function(){
		wheighter = $(window).height();
		$(".wheighter").css("height",wheighter);
	});
/* Any Button Scroll to section */	
	$('.scrollto').click(function(){
		$.scrollTo( this.hash, 800, { easing:'easeOutQuint' });
		return false;
	});

	
	$(window).load(function(){
		$(".portfolio-item").show();
	});
	$(window).resize(function(){
	if ($(window).width() > 992)
	  {
		  $(".mobile-menu").hide();
	  }
	});
	$(window).resize(function(){
	if ($(window).width() > 992)
	  {
		  $("#main-menu").show();
	  }
	});
});