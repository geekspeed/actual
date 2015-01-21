jQuery(document).ready(function($){

  $(document).on('click', '.delTag', function(){
      $(this).parent().remove();
      return false;
  });

  $(document).on('click', '.addBadgeTag', function(){
    var value = $('.badgeTag').val();
    var field_name = $('.badgeTag').data("field-name");
    if(value != ""){
      $('#tagList').append('<div class="tagContainer"><a href="#" class="delTag">'+value+'</a><input type="hidden" value="'+value+'" name="'+ field_name +'" readonly="readonly" /></div>');
      $('.badgeTag').val('');
    }
    return false;
  });

  $(document).on('keypress keyup keydown', '.badgeTag', function(e){
    if (e.keyCode == 13 || e.keyCode == 9) {
      e.preventDefault();
      $('.addBadgeTag').trigger('click');
      return false;
    }
  })

});