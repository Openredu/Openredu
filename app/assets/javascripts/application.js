//= require jquery
//= require rails
//= require modernizr
//= require jquery.tipTip.minified
//= require folders
//= require exercises
//= require lectures
//= require jquery.remotipart
//= require lazy-load
//= require jquery.fcbkcomplete.min
//= require jquery.tokeninput-instant-search
//= require jquery.tokeninput
//= require jquery.filestyle.mini
//= require jquery.placeholder
//= require form.redu.jquery
//= require users
//= require ytpreview.jquery
//= require subjects
//= require admin
//= require jquery.nested-fields
//= require jquery.noisy
//= require underscore
//= require embedly
//= require timeago
// Somente para a nav global: início
//= require bootstrap-redu-dropdown
//= require bootstrap-nav-global
//= require bootstrap-redu-search-form
// Somente para a nav global: fim
//= require search
//= require ckeditor/init

jQuery(function(){

    $.refreshSubtabs();

    $.refreshDOMEffects();

    // Dropdown de usuário
    $("#nav-account").live("hover", function(){
        $(this).find(".username").toggleClass("hover");
        $(this).find("ul").toggle();
    });

    // Efeitos do form de status
    $(".inform-my-status textarea").live("focus", function(e){
        $(this).parents("form").find(".status-buttons, .char-limit").fadeIn();
    });
    $(".inform-my-status .status-buttons .cancel").live("click", function(){
        $(this).parents("form").find(".status-buttons, .char-limit").fadeOut();
    });

    // gerador do path do environmet e course
    jQuery.fn.slug = function() {
      var $this = $(this);
      var slugcontent = stripAccent($this.val());
      var slugcontent_hyphens = slugcontent.replace(/\s+/g,'-');
      return slugcontent_hyphens.replace(/[^a-zA-Z0-9\-]/g,'').toLowerCase();
    };

    // Itens da listagem de cursos
    $("#global-courses .courses .expand").live("click", function(){
        $(this).toggleClass("unexpand");
        $(this).parents(":first").next().slideToggle();
    });

    // Mostra campo de confirmação de e-mail
    $("#user_email").live("click", function(){
       $("#user_email_confirmation").slideDown();
       $("#user_email_confirmation").prev().slideDown();
    });

    /* Spinner em links remotos */
    $("a[data-remote=true]").live('ajax:before', function(){
        $(this).css('width', $(this).width());
        $(this).loadingStart({ "className" : "link-loading" });
    });

    $("a[data-remote=true]").live('ajax:complete', function(){
        $(this).css('width', 'auto');
        $(this).loadingComplete({ "className" : "link-loading" });
    });

    /* Links remotos com estilo de botão */
    $("a[data-remote=true].concave-button, a[data-remote=true].concave-important").live('ajax:before', function(){
      // Remove spinner padrão para links
      $(this).css('width', 'auto');
      $(this).removeClass("link-loading");
      $(this).loadingStart();
    });

    $("a[data-remote=true].concave-button, a[data-remote=true].concave-important").live('ajax:complete', function(){
      $(this).loadingComplete();
    });

    /* Impede que links desabilitados tenham funcionem quando clicados */
    $("a.disabled").live('click', function(e){
      e.preventDefault();
    });

    /* Mostra o spinner e desabilita o elemento */
    $.fn.loadingStart = function(options){
      var config = {
        "className" : "concave-loading",
        "disabledClass" : "disabled"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.addClass(config.className);
          $bt.addClass(config.disabledClass);

          if($bt.is("input[type=submit]") || $bt.is("button")){
            $bt.attr("disabled", true)
          }
      });
    };

    /* Esconde o spinner e habilita o elemento */
    $.fn.loadingComplete = function(options){
      var config = {
        "className" : "concave-loading",
        "disabledClass" : "disabled"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);
          $bt.removeClass(config.className);
          $bt.removeClass(config.disabledClass);

          if($bt.is("input[type=submit]") || $bt.is("button")){
            $bt.attr("disabled", false)
          }
      });
    };

    /* Mostra o spinner e desabilita o elemento
     * ou
     * esconde o spinner e habilita o elemento */
    $.fn.loadingToggle = function(options){
      var config = {
        "className" : "concave-loading",
        "disabledClass" : "disabled"
      }
      $.extend(config, options);

      return this.each(function(){
          $bt = $(this);

          if( $bt.hasClass(config.className) ) {
            $bt.loadingComplete(config);
          } else {
            $bt.loadingStart(config);
          }
      });
    };

    $(document).ajaxComplete(function(){
        $.refreshSubtabs();
        $.refreshDOMEffects();
    });
});

/* Limita a quantidade de caracteres de um campo */
function limitChars(textclass, limit, infodiv){
  var text = $('.' + textclass).val();
  var textlength = text.length;
  if (textlength > limit) {
    $('.' + textclass).val(text.substr(0, limit));
    return false;
  } else {
    $('.' + infodiv).html(limit - textlength);
    return true;
  }
}

/* Create path */
function stripAccent(str) {
  var rExps = [{ re: /[\xC0-\xC6]/g, ch: 'A' },
    { re: /[\xE0-\xE6]/g, ch: 'a' },
    { re: /[\xC8-\xCB]/g, ch: 'E' },
    { re: /[\xE8-\xEB]/g, ch: 'e' },
    { re: /[\xCC-\xCF]/g, ch: 'I' },
    { re: /[\xEC-\xEF]/g, ch: 'i' },
    { re: /[\xD2-\xD6]/g, ch: 'O' },
    { re: /[\xF2-\xF6]/g, ch: 'o' },
    { re: /[\xD9-\xDC]/g, ch: 'U' },
    { re: /[\xF9-\xFC]/g, ch: 'u' },
    { re: /[\xE7]/g, ch: 'c' },
    { re: /[\xC7]/g, ch: 'C' },
    { re: /[\xD1]/g, ch: 'N' },
    { re: /[\xF1]/g, ch: 'n'}];

  for (var i = 0, len = rExps.length; i < len; i++)
    str = str.replace(rExps[i].re, rExps[i].ch);

  return str;
}

// Seta o tamanho correto das subtabs
$.refreshSubtabs = function() {
  var subtabsNav = $(".subtabs .ui-tabs-nav");
  subtabsNav.css("width", subtabsNav.find("li").length * 120);
};

// Efeitos na DOM que ocorrem após o carregamento da página
$.refreshDOMEffects = function(){
  // Flash message
  $(".flash-message").parent().next().css("marginTop", "10px");
  $(".flash-message .close-flash").click(function(e){
    $(this).parent().slideUp(150, "swing");
    $("#content").css("marginTop","20px");
    $("#home").css("marginTop","40px");
  });

  // Aumentar form de criação de Status
  $(".status-buttons, .char-limit", ".inform-my-status").hide();

  // Adicionar classe focus a um determinado label quando o seu campo
  // correspondente detectar o evento focus
  $("input[type=text], input[type=password], input[type=radio], input[type=checkbox]","form.highlightable").focus(function(){
    var label_for = $(this).attr("id") || null;

    if(label_for)
      $("label[for=" + label_for + "]").addClass("focus");
  }).blur(function(){
    var label_for = $(this).attr("id") || null;

    if(label_for)
      $("label[for=" + label_for + "]").removeClass("focus");
  });

  // Padrão de tabelas
  $("table.common tr:even:not(.invite):not(.message)").addClass("odd");

  // Form com tabelas
  $("#select_all").change(
    function(e){
      var pivot = $(this);

      if(pivot.is(":checked"))
        $("input[type=checkbox].autoCheck").attr('checked', true)
      else
        $("input[type=checkbox].autoCheck").attr('checked', false)

      return true;
    }
  );

  // Filtros da listagem de cursos
  $("#global-courses .filters .filter").each(function(){
    var checkbox = $(this).find("input");

    if(checkbox.is(":checked"))
      $(this).addClass("checked");

  });

  $("#global-courses .filters input[type=checkbox]").change(function(){
    var $wrapper = $(this).parent();
    $wrapper.toggleClass("checked");
  });

  $("#global-courses .filters .checked").each(function(){
    $(this).find("input").attr("checked", true);
  });

  // O elemento assume a altura do seu pai
  $(".parent-height").height(function(i, height){
    $(this).height($(this).parent().height());
  });

  // Verifica se os dois e-mails são iguais
  $("#user_email_confirmation").blur(function(){
    email_val = $("#user_email").val();
    confirmation_val = $(this).val();

    if (email_val != confirmation_val) {
      $("#user_email_confirmation-error").remove();
      $(this).next(".errors_on_field").append("<p id=\"user_email_confirmation-error\" class=\"errorMessageField\">Os e-mails digitados não são iguais.</p>");

    } else {
      $("#user_email_confirmation-error").remove();
    }
  });

  // Tooltips
  $(".tiptip").tipTip();
  $(".tiptip-right").tipTip({defaultPosition: "right"});
  $(".tiptip-left").tipTip({defaultPosition: "left"});
  $(document).ajaxComplete(function(){
    $(".tiptip").tipTip();
    $(".tiptip-right").tipTip({defaultPosition: "right"});
    $(".tiptip-left").tipTip({defaultPosition: "left"});
  });

  $(".form-common .tiptip").each(function(){
    var label = $(this).next("label");
    label.prepend($(this));
  });

  $(".tiptip-lite").each(function(){
    // Criando holder e adicionando conteúdo
      var $tip = $("<span class='tiptip question-blue_12_12'/>");
    $tip.attr("title", $(this).attr("title"));
    $tip.tipTip();

    $(this).after($tip);
    $tip.position({
      my: 'left center',
      at: 'right center',
      of: $(this),
      offset: "10px 0",
    });
  });
}
