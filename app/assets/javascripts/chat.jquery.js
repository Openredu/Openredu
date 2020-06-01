(function($){

    var getCSSUserId = function(userId) {
      return "chat-user-" + userId;
    };
    var getCSSWindowId = function(userLiId) {
      return "window-" + userLiId;
    };
    var getUserId = function(jQueryElement){
      var windowId = jQueryElement.attr("id");
      return windowId.charAt(windowId.length - 1);
    };

    // Minimiza todas as janelas, exceto a que invocou a função
    $.fn.minimizeOtherWindows = function(){
      var $this = $(this);
      var $chats = $this.parent("#chat-windows-list");

      var $otherWindows = $chats.find(".chat-window-bar.opened").not("#" + $this.attr("id") + " .chat-window-bar");
      $otherWindows.removeClass("opened").addClass("closed");
      $otherWindows.prev(".chat-window").hide();

      for (i = 0; i < $otherWindows.length; i++) {
        var userId = getUserId($otherWindows.parent());

        $.updateWindowState({ id : userId, property : "state",
            value : "closed" });
      }
    };

    // Remove a última janela, caso atinja o limite máximo de janelas
    $.fn.limitWindows = function(opts){
      $this = $(this);
      $chats = $this.find("#chat-windows-list");

      if ($chats.children().length >= opts.limit) {
        var $lastWindow = $chats.children(":last");
        $lastWindow.remove();

        var userId = getUserId($lastWindow);
        $.clearState({ id: userId });
      }
    };

    $.fn.addWindow = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $window = $this.find("#" + getCSSWindowId(opts.id));
          var messages_per_chat = 20;
          if($window.length > 0){
            if(opts.state == "opened" && $window.find(".chat-window-bar").hasClass("closed")){
              $window.find(".chat-window-bar .name").click();
              $.updateWindowState({ id : opts.id, property : "state", value : "opened" });
            }
          }else{
            $this.limitWindows({ limit : 3});

            $window = opts.windowPartial.clone();
            $window.attr("id", getCSSWindowId(opts.id));
            $window.find(".name").text(opts.name);
            $window.find(".online").text(opts["status"]);
            $window.find(".online").removeClass("online").addClass(opts["status"]);
            $window.find(".chat-window-bar").addClass(opts.state);
            if (opts.state == "closed") {
              $window.find(".chat-window").hide();
            }
            $window.find(".user-input .contact-id").val(opts.id);

            // minimizar e maximizar
            $window.find(".name").bind("click", function(e){
                var $bar = $window.find(".chat-window-bar");

                $window.unnodge();

                $window.find(".chat-window").toggle();
                $bar.toggleClass("opened");
                $bar.toggleClass("closed");
                $window.scrollBottom(0);

                $window.minimizeOtherWindows();

                if ($bar.hasClass("opened")) {
                  $.updateWindowState({ id : opts.id, property : "state",
                      value : "opened" });
                } else {
                  $.updateWindowState({ id : opts.id, property : "state",
                      value : "closed" });
                }

                e.preventDefault();
            });

            $window.find(".conversation").scroll(function(){
              $this = $window.find(".conversation");
              if($this.scrollTop() === 0){
                messages_per_chat += 20;
                $window.restoreConversation({
                  messagePartial : opts.messagePartial.clone(),
                  owner_id : opts.owner_id,
                  id : opts.id,
                  messages_per_chat : messages_per_chat,
                  restore_scroll : false
                });
              }
            });

            // fechar janela de chat
            $window.find(".close").bind("click", function(e){
                $window.remove();
                // Remove estado da janela do cookie
                $.clearState({ id: opts.id });

                e.preventDefault();
            });

            // Receber confirmação do envio da mensagem
            var $form = $window.find("form.user-input");
            $form.bind("ajax:beforeSend", function(){
                var $input = $form.find(".text");
                var text = $input.val();

                $input.val("");
                $window.addMessage({
                    messagePartial : opts.messagePartial.clone(),
                    text : text,
                    id : opts.owner_id,
                    owner_id : opts.owner_id
                });

                var $conversation = $window.find(".conversation");
                var $lastMessage = $conversation.find('> :last');
                $lastMessage.find(".messages > li:last").addClass("pending");
            });

            $form.bind("ajax:success", function(e, data, s){
                var $conversation = $window.find(".conversation");
                var $lastMessage = $conversation.find('> :last');
                if (data["status"] == 200) {
                  $lastMessage.find(".time").html(data.time);
                  $lastMessage.find(".messages > li:last").removeClass("pending");
                } else {
                  $lastMessage.find(".messages > li:last").removeClass("pending").addClass("error");
                }
            });

            // Remove o nodge quando o foco for para o input.message
            var $input = $form.find(".text");
            $input.bind("focus", function(){ $window.unnodge() });

            $window.restoreConversation({
                messagePartial : opts.messagePartial.clone(),
                owner_id : opts.owner_id,
                id : opts.id,
                messages_per_chat : 20,
                restore_scroll : true
            });

            $this.find("#chat-windows-list").prepend($window);

            // Guarda estado da janela no cookie
            $.storeState({ id: opts.id, name : opts.name,
                state : opts.state });
          }

          // Apenas minimiza as outras se ela for a janela aberta
          // (no restoreStates() as janelas fechadas também são inseridas e
          // chamar o minimize deixaria todas minimizadas)
          if (opts.state == "opened") {
            $window.minimizeOtherWindows();
          }
      });
    };

    // Adiciona uma mensagem enviada/recebida à janela
    $.fn.addMessage = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $conversation = $this.find(".conversation");
          var $lastBatch = $conversation.find("> :last");
          var $message = opts.messagePartial.clone();
          var sameUser = ($lastBatch.data("user-id") == opts.id);
          var empty = ($lastBatch.length == 0);

          if(!empty && sameUser){ // Nova mensagem é do mesmo dono que a anterior
            var $li = $("<li/>").text(opts.text).linkify();
            $lastBatch.data("user-id", opts.id);
            $lastBatch.find(".messages").append($li);
          } else { // Primeira msg ou de um dono diferente que a anterior
            $message.data("user-id", opts.id);
            $message.find(".messages > li").text(opts.text).linkify();

            if (opts.id != opts.owner_id) {
              var $thumbnail = $message.find(".avatar");
              $thumbnail.attr("src", opts.thumbnail);
              $thumbnail.attr("alt", opts.name);
              $message.find(".time").html(opts.time);
              $message.removeClass("me").addClass("other");
            } else if (opts.time) {
              // Mensagem do usuário no restore (precisa colocar a data)
              $message.find(".time").html(opts.time);
            }

            $conversation.append($message);
          }
          if(opts.restore_scroll){
            $this.scrollBottom(0);
          }else{
            $this.scrollBottom($conversation.scrollTop());
          }
      });
    };

    // Adiciona um contato à lista de contatos e mostra indicativo de online,
    // caso a janela esteja aberta
    $.fn.addContact = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $contacts = $this.find("#chat-contacts");
          var $presence = $(opts.presencePartial);
          var $role = $presence.find(".role");

          $presence.attr("id", getCSSUserId(opts.member.user_id));
          $presence.find("img").attr("src", opts.member.avatar);
          $presence.find(".name").text(opts.member.name);

          // Adicionando papel do usuário (o mais relevante será mostrado)
          $role.text("Amigo");
          // if(opts.member.info.roles["member"]){  }
          // if(opts.member.info.roles["tutor"]){ $role.text("Tutor"); }
          // if(opts.member.info.roles["teacher"]){ $role.text("Professor"); }
          // if(opts.member.info.roles["environment_admin"]){ $role.text("Administrador"); }
          // if(opts.member.info.roles["admin"]){ $role.text("Staff"); }

          $contacts.find("ul").append($presence);

          var $statusDiv = $("#" + getCSSWindowId(opts.member.user_id) + " .chat-window-bar .offline");
          $statusDiv.removeClass("offline").addClass("online");
          $statusDiv.text("online");

          $presence.bind("click", function(){
              $this.addWindow({ windowPartial : opts.windowPartial.clone()
                  , messagePartial : opts.messagePartial.clone()
                  , id : opts.member.user_id
                  , owner_id : opts.owner_id
                  , name : opts.member.name
                  , "status" : "online"
                  , state : "opened" });
          });
      });
    };

    // Remove contato da lista de contatos e mostra indicativo de offline na janela
    $.fn.removeContact = function(opts){
      var $statusDiv = $("#" + getCSSWindowId(opts.id) + " .chat-window-bar .online");
      var $removed = $("#" + getCSSUserId(opts.id)).remove();

      $statusDiv.removeClass("online").addClass("offline");
      $statusDiv.text("offline");
      $(this).updateCounter();

      return $removed;
    }

    // Atualiza contador de usuários online
    $.fn.updateCounter = function(){
      var count = $(this).find("#chat-contacts li").length;
      $(this).find("#chat-contacts-bar .count").text("Chat ("+ count +")");

      return $(this);
    };

    // Adiciona scroll
    $.fn.scrollable = function(config){
      var options = { offset : 10 };
      options = $.extend(options, config);

      return this.each(function(){
          var $this = $(this);

          $list = $this.find("ul");
          $list.css("overflow", "hidden");

          $this.find(".scroll .down").live("click", function(){
              $list.scrollTop($list.scrollTop() + options.offset);
          });

          $this.find(".scroll .up").live("click", function(){
              $list.scrollTop($list.scrollTop() - options.offset);
          });

      });
    };

    // Restauras janelas registradas no cookie
    $.fn.restoreStates = function(opts) {
      var $this = $(this);
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;

      for(i in cookie) {
        var storedWinState = cookie[i];
        $this.addWindow({ windowPartial : opts.windowPartial.clone(),
            messagePartial : opts.messagePartial.clone(),
            id : storedWinState.id,
            owner_id : opts.owner_id,
            name : storedWinState.name,
            "status" : storedWinState["status"],
            state : storedWinState.state });

        var $restoredWindow = $this.find("#" + getCSSWindowId(storedWinState.id));
        if (storedWinState.nodge) {
          $restoredWindow.nodge();
        } else {
          $restoredWindow.unnodge();
        }
      }

      var chatListOpen = chatInfos.listOpened;
      if (chatListOpen) {
        $this.find("#chat-contacts").toggle();
        $this.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
      }

      return $this;
    };

    // Remove janela do cookie
    $.clearState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;
      var itemToRemove;
      for(i in cookie) {
        if (cookie[i].id == opts.id) { itemToRemove = i; }
      }
      cookie.splice(itemToRemove, 1);

      if (cookie && cookie.length == 0) {
        chatInfos.windows = [];
      }

      $.cookie("chat_windows", $.toJSON(chatInfos), { path: "/" });
    };

    // Guarda o estado da janela no cookie
    $.storeState = function(opts) {
      var memberInfos = {
        "id" : opts.id,
        "name" : opts.name,
        "status" : "online",
        "state" : opts.state, // Estado da janela
        "nodge" : false // Indica se está com nova mensagem
      };
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var storedWindows = chatInfos.windows;
      var alreadyExists = false;

      for(i in storedWindows) {
        if (storedWindows[i].id == opts.id) { alreadyExists = true; }
      }

      if (!alreadyExists) {
        storedWindows.push(memberInfos);

        $.cookie("chat_windows", $.toJSON(chatInfos), { path: "/" });
      }
    };

    // Modificar o state, status ou nodge da janela no cookie
    $.updateWindowState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      var cookie = chatInfos.windows;
      for(i in cookie) {
        if (cookie[i].id == opts.id) { cookie[i][opts.property] = opts.value; }
      }

      $.cookie("chat_windows", $.toJSON(chatInfos), { path: "/" });
    };

    $.initStates = function() {
      var cookie = $.evalJSON($.cookie("chat_windows"));

      if (!cookie) {
        cookie = { listOpened : false, windows: [] };
      }
      var windowsEncoded = $.toJSON(cookie);
      $.cookie("chat_windows", windowsEncoded, { path: "/" });
    };

    $.updateContactsState = function(opts) {
      var chatInfos = $.evalJSON($.cookie("chat_windows"));
      chatInfos.listOpened = opts.opened;
      $.cookie("chat_windows", $.toJSON(chatInfos), { path: "/" });
    };

    // Alerta novas mensagens
    $.fn.nodge = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $bar = $this.find(".chat-window-bar .online");

          if (!$this.find(".chat-window").is(":visible")) {
            $bar.addClass("nodge");
          }

          $.updateWindowState({ id : getUserId($this),
              property : "nodge",
              value : true });
      });
    };

    // Remove Alerta de novas mensagens
    $.fn.unnodge = function(opts){
      return this.each(function(){
          var $this = $(this);
          var $bar = $this.find(".chat-window-bar .online");

          $bar.removeClass("nodge");
          $.updateWindowState({ id : getUserId($this),
              property : "nodge",
              value : false });
      });
    };

    $.fn.restoreConversation = function(opts){
      console.log(opts);
      return this.each(function(){
        var $this = $(this);
        $.getJSON('/chat/last_messages_with', { contact_id : opts.id, messages_per_chat : opts.messages_per_chat },
          function(logs){
            $this.find('.conversation').empty();
            for (i in logs) {
              var msg = logs[i];
              $this.addMessage({
                  messagePartial : opts.messagePartial.clone(),
                  text : msg.text,
                  id : msg.user_id,
                  owner_id : opts.owner_id,
                  name : msg.name,
                  thumbnail : msg.thumbnail,
                  time : msg.time,
                  restore_scroll : opts.restore_scroll
              });
            }

        });
      });
    };

    // Rolar janela
    $.fn.scrollBottom = function(offset){
      console.log(offset);
      return this.each(function(){
        var $conversation = $(this).find(".conversation");
        $conversation.scrollTop($conversation.scrollTop() + $conversation.height() - offset)
      });
    };

})(jQuery);
