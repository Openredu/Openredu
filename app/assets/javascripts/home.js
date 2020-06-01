$(document).ready(function(){

  // Desabilita scroll ao iniciar o Tour
  $('.home-tour .modal').on('show', function () {
    $('body').css('overflow', 'hidden');
  });

  // Ativa novamente o scroll ao fechar o Tour
  $('.home-tour .modal').on('hide', function () {
    $('body').css('overflow', 'auto');
  });

  // Tour do Início
  $('#tour-1').on('show', function () {
    $("html, body").animate({ scrollTop: 0 }, "slow");
    $('#modal-what-is-missing').modal('hide');
  });

  // Menu de Navegação Global
  $('#tour-2').on('show', function () {
    $('.nav-global').css('z-index', 1060);
  });

  $('#tour-2').on('hide', function () {
    $('.nav-global').css('z-index', 1020);
  });

  // Início
  $('#tour-3').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button-active').css('position', 'relative');
    $('.nav-global-button-active').css('z-index', 1060);
  });

  $('#tour-3').on('hide', function () {
    $('.nav-global-button-active').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
  });

  // Ensine
  $('#tour-4').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Ensine"]').css('position', 'relative');
    $('.nav-global-button[title="Ensine"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-4').on('hide', function () {
    $('.nav-global-button[title="Ensine"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });

  // Ambientes
  $('#tour-5').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Ambientes"]').css('position', 'relative');
    $('.nav-global-button[title="Ambientes"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-5').on('hide', function () {
    $('.nav-global-button[title="Ambientes"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });


  // Aplicativos Educacionais
  $('#tour-6').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button[title="Aplicativos"]').css('position', 'relative');
    $('.nav-global-button[title="Aplicativos"]').css('z-index', 1060);
    $('.nav-global-button').css('background-color', '#F7F7F7');
    $('.nav-global-button').css('border-radius', '5px');
    $('.nav-global-button').css('-moz-border-radius', '5px');
  });

  $('#tour-6').on('hide', function () {
    $('.nav-global-button[title="Aplicativos"]').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
    $('.nav-global-button').css('background-color', 'transparent');
  });

  // Busca
  $('#tour-7').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.form-search').css('position', 'relative');
    $('.form-search').css('z-index', 1060);
  });

  $('#tour-7').on('hide', function () {
    $('.form-search').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
  });

  // Suas Configurações
  $('#tour-8').on('show', function () {
    $('.nav-global').css('position', 'static');
    $('.nav-global').css('margin-bottom', '0');
    $('.main-wrapper').css('padding-top', '0');
    $('.nav-global-button-dropdown').css('position', 'relative');
    $('.nav-global-button-dropdown').css('z-index', 1060);
  });

  $('#tour-8').on('hide', function () {
    $('.nav-global-button-dropdown').css('z-index', 1020);
    $('.nav-global').css('position', 'fixed');
    $('.nav-global').css('margin-bottom', '18px');
    $('.main-wrapper').css('padding-top', '42px');
  });

  // Seu Perfil
  $('#tour-9').on('show', function () {
    $('.home-profile-area-photo').css('position', 'relative');
    $('.home-profile-area-photo').css('z-index', 1060);
  });

  $('#tour-9').on('hide', function () {
    $('.home-profile-area-photo').css('z-index', 1000);
  });

  // Menu de Navegação do Início
  $('#tour-10').on('show', function () {
    $('.nav-local').css('position', 'relative');
    $('.nav-local').css('z-index', 1060);
    $('.nav-local').css('background-color', '#F7F7F7');
    $('.nav-local').css('border-radius', '5px');
    $('.nav-local').css('-moz-border-radius', '5px');
  });

  $('#tour-10').on('hide', function () {
    $('.nav-local').css('z-index', 1000);
    $('.nav-local').css('background-color', 'transparent');
  });

  // Seção ativa do Início
  $('#tour-11').on('show', function () {
    var position = $('.nav-local-item-active').position();
    $(this).css('top', position.top + 77);
    $('.nav-local').css('z-index', 'auto');
    $('.nav-local-item-active').css('position', 'relative');
    $('.nav-local-item-active').css('z-index', 1060);
  });

  $('#tour-11').on('hide', function () {
    $('.nav-local-item-active').css('z-index', 1000);
  });

  // Convide seus amigos
  $('#tour-12').on('show', function () {
    var position = $('#home-invite-friends').position();
    $(this).css('top', position.top - 50);
    $(this).css('left', position.left - 360);
    $('#home-invite-friends').css('position', 'relative');
    $('#home-invite-friends').css('z-index', 1060);
    $('#home-invite-friends').css('background-color', '#F7F7F7');
    $('#home-invite-friends').css('border-radius', '5px');
    $('#home-invite-friends').css('-moz-border-radius', '5px');
  });

  $('#tour-12').on('hide', function () {
    $('#home-invite-friends').css('z-index', 1000);
    $('#home-invite-friends').css('background-color', 'none');
  });

  /* Envia requisição para identificar itens como explorados
   *
   * Caso o elemento possua um href com url para outro domínio,
   * o usuário só será redirecionado após o final da requisição.
   *
   * O identificador do elemento do tour será o do attributo data-tour;
   * caso este não tenha sido especificado, será o href do elemento após
   * a retirada do #.
   */
  $.fn.exploreTour = function(url){
    return this.each(function(){
      var $this = $(this);
      $this.click(function(){
        var dataTour = $this.attr('data-tour');
        var href =  $this.attr('href');

        if (href && href.indexOf('http://') != -1) {
          $.post(url, { id : dataTour } , function(){
            window.location = href;
          });

          return false;
        } else {
          var identifier = dataTour || href.split("#")[1];
          $.post(url, { id : identifier });

          if (dataTour === "search-courses") {
            $("#modal-what-is-missing").modal("hide");

            setTimeout(function() {
              $(".form-search-filters-dropdown input[value=ambientes]:radio")
                .change()
                .prop('checked', true);
              $('#token-input-q').focus();
            }, 100);

            return false;
          }
        }
      });
    });
  };


  // Liga os links aos respectivos boxes da primeira experiência
  $.slideToggleFirstExperienceBoxes = function(selectorBegin) {
    var linkSelector = '#' + selectorBegin + '-link';
    var boxSelector = '#' + selectorBegin + '-box';
    var modalSelector = '#' + 'modal-' +  selectorBegin;

    // Ao clicar no link, o box é aberto e o link escondido
    $(linkSelector).on('click', function(){
      $(boxSelector).slideDown(150, 'swing');
      $(this).slideUp(150, 'swing');
      if ($('#explore-redu-sidebar li span:visible').length <= 1) {
        $('#explore-redu-sidebar').slideUp(150, 'swing');
      }
    });

    // Ao clicar no x, o box é escondido e o link é mostrado
    $(boxSelector + ' [data-dismiss=alert]').on('click', function(){
      $(linkSelector).slideDown(150, 'swing');
      $('#explore-redu-sidebar').slideDown(150, 'swing');
    });

    // Ao clicar no close, apenas esconde (não remove da DOM)
    $(boxSelector).on('close', function(){
      $(this).slideUp(150, 'swing');
      return false;
    });

    // Ao clicar no x dentro da modal, esconde a modal, ao invés
    // de tentar remover/esconder o data-target.
    $(modalSelector + ' [data-dismiss=alert]').on('click', function(){
      $(this).closest('.modal').modal('hide');
      return false;
    });

    // Evita que a modal apareça, caso o box esteja presente
    $(modalSelector).on('show', function(){
      if ($(boxSelector).length == 1) {
        return false;
      }
    })

    // Ao esconder a modal, mostra o link do sidebar direito
    $(modalSelector).on('hidden', function(){
      $(linkSelector).slideDown(150, 'swing');
      $('#explore-redu-sidebar').slideDown(150, 'swing');
    })
  };

  $.slideToggleFirstExperienceBoxes('what-is-missing')
  $.slideToggleFirstExperienceBoxes('learn-environments')
});
