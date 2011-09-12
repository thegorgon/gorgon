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
    site_home_twitter: function() {
      var handle = "jessereiss",
        url = "http://twitter.com/status/user_timeline/"+handle+".json?callback=?"
      
      $.getJSON(url, {count: 50}, function(data) { 
        var user = data[0].user;
        $('.profoto').html($('<img></img>').attr('src', user.profile_image_url));
        $('#timeline').append($( "#tweetTpl" ).tmpl( data )).removeClass('loading');
      });
    },
    site_projects_simulation: function() {
      PhysicsSimulations.init($('#simulation'));
    }
  });
}(Gorgon));