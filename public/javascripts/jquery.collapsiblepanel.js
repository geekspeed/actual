(function ($) {
    $.fn.extend({
        collapsiblePanel: function () {
            $(this).each(function () {
                var indicator = $(this).find('.ui-expander').first();
                var header = $(this).find('.panel-heading').first();
                var content = $(this).find('.panel-body').first();
                if (content.is(':visible')) {
                    indicator.removeClass('gn-icon gn-icon-chevron-down gn-icon-chevron-up').addClass('gn-icon gn-icon-chevron-down');
                } else {                                       
                    indicator.removeClass('gn-icon gn-icon-chevron-down gn-icon-chevron-up').addClass('gn-icon gn-icon-chevron-up');
                }

                indicator.click(function (e) {
                    content.slideToggle(500, function () {
                        console.log(content.is(':visible'));
                        if (content.is(':visible')) {
                            indicator.removeClass('gn-icon gn-icon-chevron-down gn-icon-chevron-up').addClass('gn-icon gn-icon-chevron-down');
                        } else {                                       
                            indicator.removeClass('gn-icon gn-icon-chevron-down gn-icon-chevron-up').addClass('gn-icon gn-icon-chevron-up');
                        }
                    });
                e.preventDefault();
                });
            });
        }
    });
})(jQuery);