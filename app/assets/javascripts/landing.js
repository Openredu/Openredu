//= require bootstrap-scrollspy


// Carrega a imagem da modal do tipo de aula quando ela é aberta.
$(document).on("shown", ".modal-multimedia", function(e) {
  var $modal = $(this);
  var $image = $modal.find("img.lazy");

  if (!$image.data("loaded")) {
    $image.attr("src", $image.data("original"));
    $image.data("loaded", true);
  }
});

// Deixa o menu dos filtros fixos
$(function() {

  var $win = $(window);

  var $landingFilters = $(".landing-filters");

  var landingFiltersFixed = 0;
  var landingFiltersTop = $landingFilters.length && $landingFilters.offset().top;

  var scrolllandingFilters = function() {
    var _, scrollTop = $win.scrollTop();
    if (scrollTop >= landingFiltersTop && !landingFiltersFixed) {
      landingFiltersFixed = 1;
      $landingFilters.addClass("landing-filters-fixed");
    }
    else if (scrollTop <= landingFiltersTop && landingFiltersFixed) {
      landingFiltersFixed = 0;
      $landingFilters.removeClass("landing-filters-fixed");
    }
  }

  // Faz com que o menu dos filtros fique com top e fixo, quando o usuário estiver logado.
  scrolllandingFilters();

  $win.bind("scroll", scrolllandingFilters);

  $(".nav-global").each(function() {
    $landingFilters.css('marginTop', '42px')
  });

  // Faz com que os títulos das navegações apareçam
  $(".landing-scroll").click( function(event) {
    event.preventDefault();
    var offset = $($(this).attr('href').replace('/', '')).offset().top;
    var height = 120;

    if ($landingFilters.css('top') === "0px") {
      height = 60;
    }

    $('html, body').animate({scrollTop: (offset - height)}, 500);
  });

  $('.facebook-sign-in-button, .header-sign-in-recover').click( function(e) {
    e.stopPropagation();
  });

  // Abre as modais que devem ser abertas após carregar a página
  $("#modal-sign-up.open-me").modal("show");

  // Ativa o Scrollspy do Twitter.
  (function() {
    var filtersScrollspyTarget = '.js-filters-scrollspy';
    var filtersScrollspyOffset = $(filtersScrollspyTarget).outerHeight();

    $(document.body).scrollspy({
      target: filtersScrollspyTarget,
      offset: filtersScrollspyOffset,
      activeClass: 'filter-active',
      selector: '.filter',
      applyActiveToParent: false
    });
  })();
});
