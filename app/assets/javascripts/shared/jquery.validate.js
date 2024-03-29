(function($) {
  var preloadable = [ "/images/assets/general/white_check.png", 
                      "/images/assets/general/white_cross.png", 
                      "/images/assets/general/black_check.png", 
                      "/images/assets/general/black_cross.png", 
                      "/images/assets/loading/white-chasing30x30.gif" ],
    emailRegex = /\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,4}\b/i,
    invalid = function(input, message) {
      $(input).parents('li').removeClass('valid').removeClass('loading').addClass('invalid');
      $(input).parents('li').find('.validity .message').html(message || '');
    },
    loading = function(input) {
      $(input).parents('li').removeClass('valid').removeClass('invalid').addClass('loading');
      $(input).parents('li').find('.validity .message').html('checking');
      $(input).valid(false);
    },
    valid = function(input) {
      $(input).parents('li').removeClass('loading').removeClass('invalid').addClass('valid');
      $(input).parents('li').find('.validity .message').html('');
    },
    validity = function(input, val, message) {
      if ($(input).valid() || val || $(input).parent('li').is('.loading')) {
        $(input).valid(val);
        return val ? valid(input) : invalid(input, message);        
      }
    },
    testTelephone = function(input){
      validity(input, true, "doesn't look right");
    },
    testRequired = function(input) {
      var select;
      if ($(input).is('input, textarea')) {
        validity(input, $.trim($(input).val()).length > 0, "required");        
      } else if ($(input).is('select')) {
        select = $(input)[0];
        validity(input, $.trim(select.options[select.selectedIndex].value), "required");
      }
    },
    testPattern = function(input) {
      validity(input, $(input).val().length == 0 || $(input).pattern().test($(input).val()), "doesn't look right");
    },
    testValue = function(input) {
      var floatVal = $(input).floatVal(),
        msg = ["between", $(input).minValue(), "and", $(input).maxValue()].join(' ');
      validity(input, floatVal <= $(input).maxValue() && floatVal >= $(input).minValue(), msg);
    },
    testLength = function(input) {
      var length = $.trim($(input).val()).length,
        msg = [$(input).minLength(), "to", $(input).maxLength(), "characters"].join(' ');
      validity(input, length <= $(input).maxLength() && length >= $(input).minLength(), msg);
    },
    testAgainstServer = function(input) {
      var url = $(input).attr('data-validate-url');
      if ($(input).valid()) {
        loading(input);
        $.ajax({
          url: url,
          data: {value: $(input).val()},
          success: function(data) {
            var msg = $(input).attr('data-invalid-msg') || data.message;
            validity(input, data.valid, msg);
          },
          dataType: 'json'
        });
      }
    }, preload = function() {
      var img, src;
      while (preloadable.length > 0) {
        src = preloadable.pop();
        img = new Image();
        img.src = src;
      }
    };
  $.extend($.fn, {
    clear: function() {
      $(this).filter('ul.form').each(function() {
        $(this).find('input.text').not('.placeholder').val('').blur().valid(true);
        $(this).find('li').removeClass('invalid').removeClass('focus').removeClass('valid');
      });
    },
    valid: function(val) {
      if (val !== undefined && val !== null) {
        $(this).attr('aria-invalid', val ? 'false' : 'true');
        return this;
      } else {
        return $(this).is(':not([aria-invalid])') || $(this).attr('aria-invalid') == 'false';
      }
    },
    floatVal: function(val) {
      if (val) {
        $(this).val(val);
        return this;
      } else {
        val = parseFloat($(this).val(), 10);
        return val ? val : 0;
      }
    },
    minValue: function(val) {
      if (val) {
        $(this).attr('min', val);
        return this;
      } else {
        val = parseFloat($(this).attr('min'), 10);
        return val ? val : 0;
      }
    },
    maxValue: function(val) {
      if (val) {
        $(this).attr('max', val);
        return this;
      } else {
        val = parseFloat($(this).attr('max'), 10);
        return val ? val : Infinity;
      }
    },
    minLength: function(val) {
      if (val) {
        $(this).attr('minlength', val);
        return this;
      } else {
        val = parseInt($(this).attr('minlength'), 10);
        return val ? val : 0;
      }
    },
    maxLength: function(val) {
      if (val) {
        $(this).attr('maxlength', val);
        return this;
      } else {
        val = parseInt($(this).attr('maxlength'), 10);
        return val ? val : Infinity;
      }
    },
    pattern: function(regex) {
      if (regex) {
        $(this).attr('pattern', regex.source);
        return this;
      } else if ($(this).filter('[type=email]').length > 0) {
        return emailRegex;
      } else if ($(this).filter('[type=tel]').length > 0) {
        return telRegex;
      } else {
        return new RegExp($(this).attr('pattern'));
      }
    },
    autovalidate: function() {
      preload();
      $(this).filter('form').each(function(i) {
        var form = $(this),
          required = form.find('input[required]:not([formnovalidate]), textarea[required]:not([formnovalidate]), select[required]:not([formnovalidate])'),
          patterned = form.find('input[type=email]:not([formnovalidate]), input[pattern]:not([formnovalidate])'),
          telephone = form.find('input[type=tel]:not([formnovalidate])'),
          value = form.find('input[type=number][min]:not([formnovalidate]), input[type=number][max]:not([formnovalidate]):not([min])'),
          length = form.find('input[minlength]:not([formnovalidate]), input[maxlength]:not([formnovalidate]):not([minlength])'),
          server = form.find('input[data-validate-url]:not([formnovalidate])');

        form.attr('novalidate', 'novalidate');
        form.find('input').valid(true);
        required.bind('change', function() { testRequired(this); });
        patterned.bind('change', function() { testPattern(this); });
        value.bind('change', function() { testValue(this); });
        length.bind('change', function() { testLength(this); });
        server.bind('change', function() { testAgainstServer(this); });
      
        form.bind('submit', function(e) {
          if (!form.data('validity')) {
            e.preventDefault();
            
            if (form.validate({submit: true})) {
              form.data('validity', true);
              form.submit();
              form.data('validity', false);
            }
          }
        });
      });
    },
    validate: function(options) {
      options = options || {};
      var validity = true;
      $(this).filter('form').each(function(i) {
        
        var form = $(this),
          required = form.find('input[required]:not([formnovalidate]), textarea[required]:not([formnovalidate]), select[required]:not([formnovalidate])'),
          patterned = form.find('input[type=email]:not([formnovalidate]), input[pattern]:not([formnovalidate])'),
          telephone = form.find('input[type=tel]:not([formnovalidate])'),
          value = form.find('input[min]:not([formnovalidate]), input[max]:not([formnovalidate]):not([min])'),
          length = form.find('input[minlength]:not([formnovalidate]), input[maxlength]:not([formnovalidate]):not([minlength])'),
          server = form.find('input[data-validate-url]:not([formnovalidate])');
          
        form.find('input, textarea').attr('aria-invalid', 'false');
        
        required.each(function(i) { testRequired(this); }); 
        patterned.each(function(i) { testPattern(this); }); 
        value.each(function(i) { testValue(this); }); 
        length.each(function(i) { testLength(this); }); 
        if (!options.submit) { server.each(function(i) { testAgainstServer(this); }); }
        // telephone.each(function(i) { testTelephone(this); }); 
        
        validity = validity && form.find('input[aria-invalid=true], textarea[aria-invalid=true]').length === 0;
      });
      return validity;
    }
  });
}(jQuery));