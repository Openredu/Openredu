$(document).ready(function(){
    $.fn.removeLazyAssets = function(options){
      return this.each(function(){
          for(var i in options.paths) {
            var $this = $(this);
            $this.find("script[src='" + options.paths[i] + "'], link[href='" + options.paths[i] + "']", "head").remove();
          }
      });
    };
});
