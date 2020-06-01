//= require jquery.pjax
//= require jquery.cookie
//= require jquery.json.js
//= require jquery.linkify-1.0
//= require chat.jquery
//= require chat
//= require loading

var $pjaxLinks = $("a:not([data-remote]):not([href^='#']):not([rel='nofollow']):not([href^='javascript\:']):not([onClick])");;

var buildChat = (function(){
// Constrói um novo objeto Chat
var buildChat = function(opts){
  var config = opts;
  var client = new Faye.Client(config.url);
  var currentUser = config.currentUser;
  // Inicializando variaveis de template
  var $layout, $window, $presence, $channel, $friends;

  if(config.layout instanceof jQuery)
    $layout = config.layout;
  else
    $layout = $(config.layout);

  if(config.window instanceof jQuery)
    $window = config.windowPartial;
  else
    $window = $(config.windowPartial);

  if(config.presencePartial instanceof jQuery)
    $presence = config.presencePartial;
  else
    $presence = $(config.presencePartial);

  if(config.messagePartial instanceof jQuery)
    $message = config.messagePartial;
  else
    $message = $(config.messagePartial);

  $friends = config.friends;
  $channel = config.channel;

  var getCSSUserId = function(userId) {
    return "chat-user-" + userId;
  };
  var getCSSWindowId = function(userLiId) {
    return "window-" + userLiId;
  };

  var startsWith = function(check, startsWith){
    return (check.indexOf(startsWith) === 0);
  }

  // Minimiza lista de contatos
  $layout.find("#chat-contacts .minimize, #chat-contacts-bar").bind("click", function(){
      $layout.find("#chat-contacts").toggle();
      $layout.find("#chat-contacts-bar").toggleClass("opened").toggleClass("closed");
      if ($layout.find("#chat-contacts-bar").hasClass("opened")) {
        $.updateContactsState({ opened : true });
      } else {
        $.updateContactsState({ opened : false });
      }
  });

  var that = {
    // Inicializa o pusher e mostra a barra de chat
    init : function(){
      // Initicializando layout
      $("body").append($layout);
      $layout = $("#chat");

      $layout.find("#chat-contacts").scrollable();

      $.initStates();
      $layout.restoreStates({
          windowPartial : $window.clone(),
          messagePartial : $message.clone(),
          owner_id : config.owner_id,
      });

      client.subscribe('/online/server', function(data){
        var usersOnline = data.users
        for(var i = 0; i < $friends.length; i++){
          that.uiRemoveContact($friends[i]);
          for(var j = 0; j < usersOnline.length; j++){
            if($friends[i] === usersOnline[j].user_id){
              var member = usersOnline[j];
              member['owner_id'] = currentUser.user_id
              that.uiAddContact(member);
            }
          }
        }
      });

      client.subscribe($channel, function(message){
        $layout.addWindow({
            windowPartial : $window.clone(),
            messagePartial : $message.clone(),
            id : message.user_id,
            owner_id : config.owner_id,
            name : message.name,
            "status" : "online",
            state : "closed"
        });

        $layout.find("#" + getCSSWindowId(message.user_id)).addMessage({
            messagePartial : $message.clone(),
            thumbnail : message.thumbnail,
            text : message.text,
            time : message.time,
            name : message.name,
            id : message.user_id,
            owner_id : config.owner_id
        }).nodge();
      });

      $.get('/chat/online', function(success){
        client.publish('/online/client', currentUser);
      });
    },

    // Adiciona a lista de contatos
    uiAddContact : function(member){
      $layout.addContact({member : member
          , presencePartial : $presence.clone()
          , windowPartial : $window.clone()
          , messagePartial : $message.clone()
          , owner_id : config.owner_id
      });
      $.updateWindowState({ id : member.id, property : "status",
          value : "online" });
      that.uiUpdateCounter();
    },
    uiAddWindow : function(member){
      $layout.addWindow({
          windowPartial : $window.clone(),
          messagePartial : $message.clone(),
          id : member.user_id,
          owner_id : config.owner_id,
          name : member.name,
          "status" : "online",
          state : "closed"
      });
    },
    // Remove da lista de contatos
    uiRemoveContact : function(userId){
      $layout.removeContact({ id : userId });
      $.updateWindowState({ id : userId, property : "status",
          value : "offline" });
    },
    // Atualiza counter de usuários online
    uiUpdateCounter : function(){
      $layout.updateCounter();
    }
  };

  return that;
}

  return buildChat;
})();
