//= require vendor/underscore.js
//= require vendor/backbone.js
//= require vendor/mustache.js

(function(global, window) {
  var clientId,
    apiRoot = "https://api.instagram.com/v1/";
  
  Backbone.instaSync = function(method, model, options) {
    options.timeout = 10000;
    options.dataType = 'jsonp';
    options.data = options.data || {};
    options.data.access_token = global.user.get("token");
    return Backbone.sync(method, model, options);
  };
  
  global.InstagramUser = Backbone.Model.extend({
    initialize: function(options) {
      options = options || {}
      if (options && options.token) {
        this.attributes = options;
      }
      this.gallery = new global.Gallery();
    },
    loadFromHash: function() {
      var hash = window.location.hash.substring(1);
      if (hash && hash.length > 0) {
        this.set({token: hash.replace("access_token=", "")});
      }
      if (this.token) {
        this.fetch();
        return true;
      } else {
        return false;
      }
    },
    authenticate: function() {
      if (!this.loadFromHash()) {
        window.location.href = "https://instagram.com/oauth/authorize/?client_id=" + clientId + "&redirect_uri=" + window.location + "&response_type=token";
      }
    },
    sync: Backbone.instaSync,
    url: function() {
      return apiRoot + "users/self?access_token=" + this.get('token');
    },
    parse: function(response) {
      return response.data;
    },
    save: function() {
      $.ajax({
        url: "/galleria/users/save",
        data: {user: this.attributes},
        type: "POST",
        success: function(data) {
        }
      })
    }
  });
  
  global.Media = Backbone.Model.extend({
    lowRes: function() {
      return this.get("images").low_resolution;
    }
  })

  global.Gallery = Backbone.Collection.extend({
    model: this.Media,
    parse: function(response) {
      return response.data;
    },
    sync: Backbone.instaSync,
    url: function() {
      var url = apiRoot + "users/self/media/recent";
      return url;
    },
    comparator: function(media) {
      return -1 * (media.get("created_time") - 0);
    },
    load: function() {
      var data = {count: 9}, 
        self = this;
      if (!this.loading && !this.fullyLoaded) {
        this.trigger("loading");
        this.loading = true;
        data.max_timestamp = (_.min(this.pluck("created_time")) || "0") - 10;

        this.fetch({
          add: true,
          data: data,
          success: function(model, response) {
            self.loading = false;
            self.fullyLoaded = response.data && response.data.length == 0;
            self.trigger("change");
          }
        });
      }
    }
  })
  
  global.ui = {};
  global.ui.Profile = Backbone.View.extend({
    initialize: function(data) {
      var self = this;
      Backbone.View.prototype.initialize.apply(this, arguments);
      this.user = data.user;
      this.current = data.current;
      this.user.bind("change", function() { self.render(); });
      this.current.bind("change", function() { self.render(); });
    },
    el: '#user',
    render: function() {
      var tpl = $('#userTpl').html(),
        params = { user: this.user.attributes, 
                   current: this.current.attributes,
                   curViewer: this.current.get("id") == this.user.get("id")
                 };
                 
      $(this.el).html(Mustache.to_html(tpl, params));
    }
  });
  global.ui.Gallery = Backbone.View.extend({
    initialize: function() {
      var self = this;
      Backbone.View.prototype.initialize.apply(this, arguments);
      this.user = arguments[0].user;
      this.model.bind("change", function() { 
        self.render(); 
      });
      this.model.bind("loading", function() { 
        self.$('.loading').show();
      });
      $(window).unbind('scroll.gallery-load').bind('scroll.gallery-load', function(e) {
        if ($(window).scrollTop() > self.lastScroll || 0) {
          self.model.load();
        }
        self.lastScroll = Math.max($(window).scrollTop(), self.lastScroll || 0);
      });
    },
    events: {
      "change .styleswitch select"    : "updateTheme",
      "click .authenticate"           : "authenticate"
    },
    updateTheme: function() {
      this.user.set({preferred_theme: this.$(".styleswitch select").val()});
      this.renderTheme();
    },
    theme: function() {
      return this.user.get("preferred_theme");
    },
    authenticate: function() {
      this.user.authenticate();
    },
    el: '#gallery',
    renderTheme: function() {
      var theme = this.theme();
      $(this.el).attr('class', theme);
      this.$(".styleswitch select").val(theme);
      switch(theme) {
        case "museum": 
        break;
      }
    },
    render: function() {
      var self = this;
      self.$('.loading').hide();
      this.renderTheme();
      this.model.each(function(media) {
        if (this.$('#media_' + media.get("id")).length == 0) {
          self.$('ul').append(Mustache.to_html($('#photoTpl').html(), media.attributes));          
        }
      });
    }
  });
  
  
  global.init = function(options) {
    options = options || {}
    clientId = options.client_id;
    global.user = new this.InstagramUser(options.user);
    global.current = new this.InstagramUser();
    global.ui.profile = new this.ui.Profile({ user: global.user, current: global.current });
    global.ui.gallery = new this.ui.Gallery({ model: global.user.gallery, user: global.user });
    global.current.loadFromHash();
    global.user.fetch();
    global.user.bind("change", function() {
      global.user.save();
    });
    global.user.gallery.load();
  }
  
  window.Galleria = global;
}({}, window));