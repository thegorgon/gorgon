(function(go) {
  $.provide(go, 'Views', {
    run: function(url) {
      var body = $('body'),
        pageNS = body[0].id,
        pageClasses = body.attr('class').split(' ');
      $.logger.debug("Running page views for classes: ", pageClasses, "and namespace: ", pageNS, " and URL: ", url);
      this.layout.call(window, url);
      $.each(pageClasses, function(i) {
        if ($.isFunction(go.Views[this])) {
          go.Views[this].call(window, url);
        }
      });
      if ($.isFunction(go.Views[pageNS])){
        go.Views[pageNS].call(window, url);        
      }
    },
    layout: function(url) {
    },
    site_blog_show: function() {
      var comments = $('.comments'),
        list = comments.find('ul');
      comments.addClass('loading');
      $.get(comments.attr('data-src'), function(data) {
        comments.removeClass('loading');
        if (data.comments.length == 0) {
          comments.addClass('empty');
        }
        $.each(data.comments, function(i) {
          $('#commenttpl').tmpl(data.comments[i]).appendTo(list);
        })
      });
      $('#newcommentform form').ajaxForm({
        start: function() {
          if ($(this).validate()) {
            var params = $(this).serializeObject("comment");
            params.created_at = new Date();
            comments.removeClass('empty');
            $('#commenttpl').tmpl(params).addClass('pending').appendTo(list);
            $.popover.hide();
          } else {
            return false;
          }
        }, success: function(data) {
          if (data.success) {
            $(this).clear();
            list.find('.pending').replaceWith(data.html);            
          }
        }
      });
    },
    site_home_twitter: function() {
      var handle = "jessereiss",
        url = "http://twitter.com/status/user_timeline/"+handle+".json?callback=?"
      
      $.getJSON(url, {count: 50}, function(data) { 
        var user = data[0].user;
        $.logger.debug(data);
        $('.profoto').html($('<img></img>').attr('src', user.profile_image_url));
        $('#timeline').append($( "#tweetTpl" ).tmpl( data )).removeClass('loading');
      });
    }
  });
}(Gorgon));