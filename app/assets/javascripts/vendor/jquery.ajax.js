(function($) {
  $.extend($.fn, {
    ajaxForm: function(options) {
      options = options || {};
      this.filter('form').each(function() {
        var $this = $(this);
        $this.unbind('submit.ajaxForm');
        $this.bind('submit.ajaxForm', function(e) {
          e.preventDefault();
          $this.ajaxSubmit(options);
        });	    
      });
    },
    ajaxLink: function(options) {
      options = options || {};
      this.filter('a').each(function() {
        var $this = $(this);
        $this.unbind('click.ajaxLink');
        $this.bind('click.ajaxLink', function(e) {
          e.preventDefault();
          $this.ajaxClick(options);
        });
      });
    },  
    ajaxClick: function(options) {
      var $this = $(this), success, method, httpMethod, data, confirmMsg;
      options = options || {};
      options.start = $.isFunction(options.start) ? options.start : function() {};
      if (!$this.data('sending')) {
        confirmMsg = $this.attr('data-confirm') || '';
        if ((confirmMsg.length === 0 || window.confirm(confirmMsg)) && options.start.apply(this) !== false) {
          $this.data('sending', true);
          success = ($.isFunction(options.success) ? options.success: function() {});
          options.success = function() {
            $this.data('sending', false);
            success.apply($this, arguments);
          };
          method = ($this.attr('data-method') || 'GET').toUpperCase();
          httpMethod = method === "GET" ? method : "POST";
          data = {};
          if (httpMethod !== method) { data._method = method; }
          options = $.extend({
            type: httpMethod,
            url: $this.attr('href'),
            data: data,
            dataType: 'json'
          }, options);
          return $.ajax(options);
        } else {
          return false;
        }
      }
    },
    ajaxSubmit: function(options) {
      var $this = $(this), success, confirmMsg;
      options = options || {};
      options.start = $.isFunction(options.start) ? options.start : function() {};
      if (!$this.data('sending')) {
        confirmMsg = $this.attr('data-confirm') || '';
        if ((confirmMsg.length === 0 || window.confirm(confirmMsg)) && options.start.apply(this) !== false) {
          $this.data('sending', true);
          success = ($.isFunction(options.success) ? options.success: function() {});
          error = ($.isFunction(options.error) ? options.error: function() {});
          options.success = function() {
            $this.data('sending', false);
            success.apply($this, arguments);
          };
          options.error = function() {
            $this.data('sending', false);
            error.apply($this, arguments);
          };
          options = $.extend({
            dataType: 'json',
            url: $this.attr('action'),
            type: $this.attr('method').toUpperCase(),
            data: $this.serialize()
          }, options);
          return $.ajax(options);
        } else {
          return false;
        }
      }
    }
  });
}(jQuery));