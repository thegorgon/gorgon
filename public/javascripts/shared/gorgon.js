window.Gorgon = window.Gorgon || {};
(function($) {
  //jQuery Extensions
  $.extend($, {
    provide : function(object, name, features) {
      object[name] = object[name] || {};
      $.extend(object[name], features);
      return object;
    },
    twitterify: function(text) {
      text = text.replace(/(http:\/\/[\.\w\/]+)/gi, "<a href='$1' target='_blank'>$1</a>");
      text = text.replace(/\@(\w+)/gi, "<a href='http://www.twitter.com/#!/$1' target='_blank'>@$1</a>");
      text = text.replace(/\#(\w+)/gi, "<a href='https://twitter.com/#!/search?q=%23$1' target='_blank'>#$1</a>");
      return text;
    }
  });
  
  //jQuery Element Extensions
  $.extend($.fn, {
    clear: function() {
      var inputs = $(this).filter('form').find(':input').not(':button, :submit, :reset, [type=hidden], .placeholder');
      inputs.val('').removeAttr('checked').removeAttr('selected').blur(); 
      return $(this);
    },
    serializeObject: function(prefix) {
      var array = $(this).serializeArray(),
        object = {}, i, key, regexp = new RegExp(prefix + '\\[(.+)\\]', 'gi');
      for (i = 0; i < array.length; i++) {
        key = array[i].name;
        if (prefix) {
          key = key.replace(regexp, '$1');
        }
        object[key] = array[i].value;
      }
      return object;
    }    
  });
}(jQuery));
$(document).ready(function() {
  $.popover.init();
  $.popover.bind();
  $('.popover a.cancel').live('click', function(e) {
    e.preventDefault();
    $.popover.hide();
  });
    
  Gorgon.Views.run();
});