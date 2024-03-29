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
      $.stretcher.init();
      $('[data-toggle-class]').bind('click', function(e) {
        var $this = $(this);
        e.preventDefault();
        $this.parents($this.attr('rel')).toggleClass($this.attr('data-toggle-class'));
      });
    },
    site_blog: function() {
    },
    site_home_twitter: function() {
      var handle = "jessereiss",
        url = "http://twitter.com/status/user_timeline/"+handle+".json?callback=?"
      
      $.getJSON(url, {count: 50}, function(data) { 
        var user = data[0].user;
        $('.profoto').html($('<img></img>').attr('src', user.profile_image_url));
        $.logger.debug(data);
        $('#timeline').append($( "#tweetTpl" ).tmpl( data )).removeClass('loading');
      });
    },
    site_projects_index: function() {
      var items = $('#projects').find('.project');
      $('#projects').masonry({
        itemSelector: '.project',
        isAnimated: true
      });
      $('#controls').find('.control').unbind('click').bind('click', function(e) {
        e.preventDefault();
        var css = $(this).attr('id').split('_')[0],
          newItems = items.remove().filter('.' + css);
        $('#controls').find('.control').removeClass('active');
        $(this).addClass('active');
        $('#projects').append( newItems ).masonry( 'reload');
      });
    },
    site_projects_autovalidator: function() {
      window.hljs.initHighlighting();
      $('.line-by-line').each(function(i) {
        language = $(this).attr('data-lang');
        $(this).find('code').each(function(i) {
          var code = $(this).text(),
            highlight = hljs.highlight(language, code);
          $(this).addClass(highlight.language);
          $(this).html(highlight.value);
        });
      });
      $('form#example1').autovalidator();

      $('form#example2').autovalidator({
        change: function(event, validator) {
          var container = $(event.target).parent();
          container.removeClass('invalid').removeClass('valid').removeClass('loading').addClass(event.status);
          container.find('.errors').html(event.status == "loading" ? "loading..." : event.message || "");
        }
      });

      $('form#example3').autovalidator();
      $('form#example3').autovalidator("option", "change", function(event, validator) {
        var container = $(event.target).parent(),
          errors = validator.errors();            
        container.removeClass('invalid').removeClass('valid').removeClass('loading').addClass(event.status);

        if (errors.length > 0) {
          $(this).addClass("invalid");
          $(this).find('.error-messages').html(errors[0]);
        } else {
          $(this).removeClass("invalid");
          $(this).find('.error-messages').html('');
        }
      });
      
      $.Validation.Global.register({
        name: 'luhn',
        selector: '[name=credit-card-number]',
        message: "please double check your ${name}",
        test: function(element) {
          var sum = 0, flip = true, i, digit, value = element.val();
          for (i = value.length - 1; i >=0; i--) {
            digit = parseInt(value.charAt(i), 10);
            sum += (flip = flip ^ true) ? Math.floor((digit * 2)/10) + Math.floor(digit * 2 % 10) : digit;
          }
          this.validity(element, sum % 10 === 0);
        }
      });
      
      $('form#example4').autovalidator({
        change: function(event, validator) {
          var container = $(event.target).parent();
          container.removeClass('invalid').removeClass('valid').removeClass('loading').addClass(event.status);
          container.find('.errors').html(event.status == "loading" ? "loading..." : event.message || "");
        }
      });

      $('form#example4').autovalidator('register', {
        name: 'expiration',
        selector:'[name^=expiration-]',
        message: function() {
          return "looks like your card is expired?";
        },
        onChange: false,
        test: function(element) {
          var yearField, monthField, year, month, validity, now = (new Date());
          if (element.attr('name') == 'expiration-month') {
            yearField = element.siblings('[name=expiration-year]');
            monthField = element;
          } else if (element.attr('name') == 'expiration-year') {
            monthField = element.siblings('[name=expiration-month]');
            yearField = element;
          }
          year = yearField.val() - 0;
          month = monthField.val() - 0;
          validity = year > now.getFullYear() || (year === now.getFullYear() && month > now.getMonth() + 1);
          this.validity(monthField, validity);
          this.validity(yearField, validity);
        }
      });
            
      $('form#example5').autovalidator({
        name: 4,
        change: function(event, validator) {
          var container = $(event.target).parent();
          container.removeClass('invalid').removeClass('valid').removeClass('loading').addClass(event.status);
          container.find('.errors').html(event.status == "loading" ? "loading..." : event.message || "");
        }
      });
  
      $('form#example5').autovalidator('register', {
        name: "server_check",
        selector: "#artist-name",
        onSubmit: false,
        message: "cannot find ${name} '${val}'",
        test: function(element) {
          var val = element.val(),
            self = this,
            error = function() {
              self.validity(element, false);
            };
          this.loading(element);
          $.ajax({
            data: {q: "select * from music.artist.search where keyword='" + val + "'", format: "json"},
            url: "http://query.yahooapis.com/v1/public/yql",
            dataType: 'jsonp',
            success: function(data) {
              if (data.query.count - 0 > 0) {
                self.validity(element, true);
              } else {
                error();
              }
            }, error: error
          });
        }
      });

      $('form#example6').autovalidator({
        change: function(event, validator) {
          var container = $(event.target).parent();
          container.removeClass('invalid').removeClass('valid').removeClass('loading').addClass(event.status);
          container.find('.errors').html(event.status == "loading" ? "loading..." : event.message || "");
        }
      });
      
      $('form').submit(function(e) {
        e.preventDefault();
        if ($(this).data('autovalidator').validate()) {
          alert("Form was submitted successfully!");
        }
        return false;
      });
    },
    site_projects_simulation: function() {
      PhysicsSimulations.init($('#simulation'));
    }
  });
}(Gorgon));