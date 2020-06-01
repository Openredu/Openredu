//= require jquery.tokeninput-invite-friend

$(function() {
  var config = {
    // Formulário de enviar convites.
    formInvitation: ".invite-friend-form",
    // Botão de submissão do formulário de enviar convites.
    buttonSubmit: ".invite-friend-form input:submit",
    // Campo com o autocomplete.
    fieldAutocomplete: ".user-invitation",
    // URL do autocomplete.
    autocompleteURL: "/pessoas/auto_complete.js",
    // Tokens de convite.
    invitationTokens: ".invite-friend-form input:submit",
    // Dropdown de resultados.
    dropdown: ".token-input-dropdown-redu"
  }

  // Ativa o botão de submeter (pelo menos 1 token adicionado).
  function enableSubmit() {
    var $submit = $(config.buttonSubmit);

    if ($submit.prop("disabled")) {
      $submit.prop("disabled", false);
    }
  };

  // Desativa o botão de submeter (nenhum token adicionado).
  function disableSubmit() {
    var $remainingTokens = $(config.invitationTokens);

    if ($remainingTokens.length === 0) {
      $(config.buttonSubmit).prop("disabled", true);
    }
  };

  // Aciona o jQuery Tokeninput.
  $(config.fieldAutocomplete).tokenInput(config.autocompleteURL,
    {
      crossDomain: false,
      hintText: "",
      searchingText: "Buscando...",
      noResultsText: "",
      minChars: 3,
      theme: "redu",
      preventDuplicates: true,
      searchDelay: 300,
      tokenFormatter: function(item) {
        // Template para o token de usuários cadastrados.
        return _.template('<li class="invitation-token clearfix"><a href="<%= profile_link %>" class="invitation-token-thumbnail-link pull-left"><img class="invitation-token-thumbnail" src="<%= avatar %>" alt="<%= name %>" title="<%= name %>" width="32" height="32"></a><div class="invitation-token-inner"><a href="<%= profile_link %>" class="invitation-token-title text-truncate" title="<%= name %>"><%= name %></a></div></li>', { avatar: item.avatar_32, name: item.name, profile_link: item.profile_link });
      },
      resultsFormatter: function(item) {
        // Template para os resultados de usuários encontrados.
        return _.template('<li class="portal-search-result-item control-autocomplete-suggestion"><img class="control-autocomplete-thumbnail" src="<%= avatar %>" width="32" height="32"/><div class="control-autocomplete-added-info"><span class="control-autocomplete-name text-truncate"><%= name %></span></div></li>', { avatar: item.avatar_32, name: item.name });
      },
      onAdd: function(item) { enableSubmit(); },
      onDelete: function(item) { disableSubmit(); }
    }
  );

  // Dropdown de convidar pessoas para o Openredu por e-mail.
  $(config.formInvitation).ajaxComplete(function() {
    if ($(config.dropdown).find("li").length == 0) {
      var emailRegex = /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/;
      var enteredValue = $.trim($("#token-input-user-invitation").val());

      if (emailRegex.test(enteredValue)) {
        $(config.dropdown).find("p").replaceWith(_.template('<li class="invite-by-email-dropdown clearfix"><p class="invite-by-email-dropdown-message"><strong id="invite-by-email-dropdown-email" class="invite-by-email-dropdown-email text-truncate" title="<%= email %>"><%= email %></strong> ainda não possui cadastro no Redu.</p><button id="invite-by-email-button" class="button-primary pull-right">Convidar</button></li>', { email: enteredValue }));
      } else {
        $(config.dropdown).find("p").html(_.template('Não achamos <strong><%= name %></strong>. Busque por outro nome ou um endereço de e-mail.', { name: enteredValue }));
      }
    }
  });

  $("body")
    // Adiciona o token de convidar pessoas para o Openredu por e-mail.
    .on("click", "#invite-by-email-button", function() {
      var email = $.trim($("#invite-by-email-dropdown-email").text());
      var $emails = $("#emails");

      $emails.val($emails.val() + "," + email);
      $("#token-input-user-invitation").val("");
      $(".invite-friend-form .token-input-input-token-redu").before(_.template('<li class="invitation-token"><div class="invitation-token-inner"><span class="invite-by-email-token-remove invitation-link-remove icon-close-gray_16_18 text-replacement link-fake">Remover</span><div class="invitation-token-title"><span class="invitation-token-email text-truncate" title="<%= email %>"><%= email %></span><span class="invitation-token-legend legend">(Convidar para o Redu)</span></div></div></li>', { email: email }));
      enableSubmit();
    })
    // Remove o token de convidar pessoas para o Openredu por e-mail.
    .on("click", ".invite-by-email-token-remove", function() {
      var $removeIcon = $(this);
      var $wrapper = $removeIcon.closest(".invitation-token");
      var removedEmail = $wrapper.find(".invitation-token-email").text();
      var $emails = $("#emails");
      $emails.val($emails.val().replace(removedEmail, ""));
      $wrapper.remove();
      disableSubmit();
    });
});
