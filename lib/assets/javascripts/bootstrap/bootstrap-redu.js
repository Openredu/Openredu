// Retorna uma string com as classes de ícones identificadas.
//
// Dado uma string "classes", encontra todas as classes de ícones nela.
var findIconClasses = function(classes) {
  var iconClasses = [];

  if (classes) {
    classes = classes.split(' ');
    $.each(classes, function(index, value) {
      if (value.indexOf('icon-') !== -1) {
        iconClasses.push(value);
      }
    });
  }

  return iconClasses.join(' ');
};
/* ===================================================
 * bootstrap-transition.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  $(function () {

    "use strict";


    /* CSS TRANSITION SUPPORT (http://www.modernizr.com/)
     * ======================================================= */

    $.support.transition = (function () {

      var transitionEnd = (function () {

        var el = document.createElement('bootstrap')
          , transEndEventNames = {
               'WebkitTransition' : 'webkitTransitionEnd'
            ,  'MozTransition'    : 'transitionend'
            ,  'OTransition'      : 'oTransitionEnd'
            ,  'msTransition'     : 'MSTransitionEnd'
            ,  'transition'       : 'transitionend'
            }
          , name

        for (name in transEndEventNames){
          if (el.style[name] !== undefined) {
            return transEndEventNames[name]
          }
        }

      }())

      return transitionEnd && {
        end: transitionEnd
      }

    })()

  })

}(window.jQuery);
/* ==========================================================
 * bootstrap-alert.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#alerts
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict";


 /* ALERT CLASS DEFINITION
  * ====================== */

  var dismiss = '[data-dismiss="alert"]'
    , Alert = function (el) {
        $(el).on('click', dismiss, this.close)
      }

  Alert.prototype.close = function (e) {
    var $this = $(this)
      , selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)

    e && e.preventDefault()

    $parent.length || ($parent = $this.hasClass('alert') ? $this : $this.parent())

    $parent.trigger(e = $.Event('close'))

    if (e.isDefaultPrevented()) return

    $parent.removeClass('in')

    function removeElement() {
      $parent
        .trigger('closed')
        .remove()
    }

    $.support.transition && $parent.hasClass('fade') ?
      $parent.on($.support.transition.end, removeElement) :
      removeElement()
  }


 /* ALERT PLUGIN DEFINITION
  * ======================= */

  $.fn.alert = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('alert')
      if (!data) $this.data('alert', (data = new Alert(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.alert.Constructor = Alert


 /* ALERT DATA-API
  * ============== */

  $(function () {
    $('body').on('click.alert.data-api', dismiss, Alert.prototype.close)
  })

}(window.jQuery);
/* ============================================================
 * bootstrap-dropdown.js v2.1.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict";


 /* DROPDOWN CLASS DEFINITION
  * ========================= */

  var toggle = '[data-toggle=dropdown]'
    , Dropdown = function (element) {
        var $el = $(element).on('click.dropdown.data-api', this.toggle)
        $('html').on('click.dropdown.data-api', function () {
          $el.parent().removeClass('open')
        })
      }

  Dropdown.prototype = {

    constructor: Dropdown

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
        $parent.toggleClass('open')
        $this.focus()
      }

      return false
    }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) return $this.click()

      $items = $('[role=menu] li:not(.divider) a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (!~index) index = 0

      $items
        .eq(index)
        .focus()
    }

  }

  function clearMenus() {
    getParent($(toggle))
      .removeClass('open')
  }

  function getParent($this) {
    var selector = $this.attr('data-target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)
    $parent.length || ($parent = $this.parent())

    return $parent
  }


  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  $.fn.dropdown = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('dropdown')
      if (!data) $this.data('dropdown', (data = new Dropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.dropdown.Constructor = Dropdown


  /* APPLY TO STANDARD DROPDOWN ELEMENTS
   * =================================== */

  $(function () {
    $('html')
      .on('click.dropdown.data-api', clearMenus)
    $('body')
      .on('click.dropdown', '.dropdown form', function (e) { e.stopPropagation() })
      .on('click.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
      .on('keydown.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)
  })

}(window.jQuery);
/* =========================================================
 * bootstrap-modal.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */


!function ($) {

  "use strict";


 /* MODAL CLASS DEFINITION
  * ====================== */

  var Modal = function (content, options) {
    this.options = options
    this.$element = $(content)
      .delegate('[data-dismiss="modal"]', 'click.dismiss.modal', $.proxy(this.hide, this))
  }

  Modal.prototype = {

      constructor: Modal

    , toggle: function () {
        return this[!this.isShown ? 'show' : 'hide']()
      }

    , show: function () {
        var that = this
          , e = $.Event('show')

        this.$element.trigger(e)
        this.$element.trigger('fitContent.redu')

        if (this.isShown || e.isDefaultPrevented()) return

        $('body').addClass('modal-open')

        this.isShown = true

        escape.call(this)
        backdrop.call(this, function () {
          var transition = $.support.transition && that.$element.hasClass('fade')

          if (!that.$element.parent().length) {
            that.$element.appendTo(document.body) //don't move modals dom position
          }

          that.$element
            .show()

          if (transition) {
            that.$element[0].offsetWidth // force reflow
          }

          that.$element.addClass('in')

          transition ?
            that.$element.one($.support.transition.end, function () { that.$element.trigger('shown') }) :
            that.$element.trigger('shown')

        })
      }

    , hide: function (e) {
        e && e.preventDefault()

        var that = this

        e = $.Event('hide')

        this.$element.trigger(e)

        if (!this.isShown || e.isDefaultPrevented()) return

        this.isShown = false

        $('body').removeClass('modal-open')

        escape.call(this)

        this.$element.removeClass('in')

        $.support.transition && this.$element.hasClass('fade') ?
          hideWithTransition.call(this) :
          hideModal.call(this)
      }

  }


 /* MODAL PRIVATE METHODS
  * ===================== */

  function hideWithTransition() {
    var that = this
      , timeout = setTimeout(function () {
          that.$element.off($.support.transition.end)
          hideModal.call(that)
        }, 500)

    this.$element.one($.support.transition.end, function () {
      clearTimeout(timeout)
      hideModal.call(that)
    })
  }

  function hideModal(that) {
    this.$element
      .hide()
      .trigger('hidden')

    backdrop.call(this)
  }

  function backdrop(callback) {
    var that = this
      , animate = this.$element.hasClass('fade') ? 'fade' : ''

    if (this.isShown && this.options.backdrop) {
      var doAnimate = $.support.transition && animate

      this.$backdrop = $('<div class="modal-backdrop ' + animate + '" />')
        .appendTo(document.body)

      if (this.options.backdrop != 'static') {
        this.$backdrop.click($.proxy(this.hide, this))
      }

      if (doAnimate) this.$backdrop[0].offsetWidth // force reflow

      this.$backdrop.addClass('in')

      doAnimate ?
        this.$backdrop.one($.support.transition.end, callback) :
        callback()

    } else if (!this.isShown && this.$backdrop) {
      this.$backdrop.removeClass('in')

      $.support.transition && this.$element.hasClass('fade')?
        this.$backdrop.one($.support.transition.end, $.proxy(removeBackdrop, this)) :
        removeBackdrop.call(this)

    } else if (callback) {
      callback()
    }
  }

  function removeBackdrop() {
    this.$backdrop.remove()
    this.$backdrop = null
  }

  function escape() {
    var that = this
    if (this.isShown && this.options.keyboard) {
      $(document).on('keyup.dismiss.modal', function ( e ) {
        e.which == 27 && that.hide()
      })
    } else if (!this.isShown) {
      $(document).off('keyup.dismiss.modal')
    }
  }


 /* MODAL PLUGIN DEFINITION
  * ======================= */

  $.fn.modal = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('modal')
        , options = $.extend({}, $.fn.modal.defaults, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('modal', (data = new Modal(this, options)))
      if (typeof option == 'string') data[option]()
      else if (options.show) data.show()
    })
  }

  $.fn.modal.defaults = {
      backdrop: true
    , keyboard: true
    , show: true
  }

  $.fn.modal.Constructor = Modal


 /* MODAL DATA-API
  * ============== */

  $(function () {
    $('body').on('click.modal.data-api', '[data-toggle="modal"]', function ( e ) {
      var $this = $(this), href
        , $target = $($this.attr('data-target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
        , option = $target.data('modal') ? 'toggle' : $.extend({}, $target.data(), $this.data())

      e.preventDefault()
      $target.modal(option)
    })
  })

}(window.jQuery);
/* ===========================================================
 * bootstrap-tooltip.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict";


 /* TOOLTIP PUBLIC CLASS DEFINITION
  * =============================== */

  var Tooltip = function (element, options) {
    this.init('tooltip', element, options)
  }

  Tooltip.prototype = {

    constructor: Tooltip

  , init: function (type, element, options) {
      var eventIn
        , eventOut

      this.type = type
      this.$element = $(element)
      this.options = this.getOptions(options)
      this.enabled = true

      if (this.options.trigger != 'manual') {
        eventIn  = this.options.trigger == 'hover' ? 'mouseenter' : 'focus'
        eventOut = this.options.trigger == 'hover' ? 'mouseleave' : 'blur'
        this.$element.on(eventIn, this.options.selector, $.proxy(this.enter, this))
        this.$element.on(eventOut, this.options.selector, $.proxy(this.leave, this))
      }

      this.options.selector ?
        (this._options = $.extend({}, this.options, { trigger: 'manual', selector: '' })) :
        this.fixTitle()
    }

  , getOptions: function (options) {
      options = $.extend({}, $.fn[this.type].defaults, options, this.$element.data())

      if (options.delay && typeof options.delay == 'number') {
        options.delay = {
          show: options.delay
        , hide: options.delay
        }
      }

      return options
    }

  , enter: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (!self.options.delay || !self.options.delay.show) return self.show()

      clearTimeout(this.timeout)
      self.hoverState = 'in'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'in') self.show()
      }, self.options.delay.show)
    }

  , leave: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (this.timeout) clearTimeout(this.timeout)
      if (!self.options.delay || !self.options.delay.hide) return self.hide()

      self.hoverState = 'out'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'out') self.hide()
      }, self.options.delay.hide)
    }

  , show: function () {
      var $tip
        , inside
        , pos
        , actualWidth
        , actualHeight
        , placement
        , tp

      if (this.hasContent() && this.enabled) {
        $tip = this.tip()
        this.setContent()

        if (this.options.animation) {
          $tip.addClass('fade')
        }

        placement = typeof this.options.placement == 'function' ?
          this.options.placement.call(this, $tip[0], this.$element[0]) :
          this.options.placement

        inside = /in/.test(placement)

        $tip
          .remove()
          .css({ top: 0, left: 0, display: 'block' })
          .appendTo(inside ? this.$element : document.body)

        pos = this.getPosition(inside)

        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight

        switch (inside ? placement.split(' ')[1] : placement) {
          case 'bottom':
            tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
            // No caso especifico do popover2.
            if (this.$element.attr('data-original-title') === '' && this.$element.attr('rel') === 'popover') {
              tp = {top: pos.top + pos.height, left: pos.left + pos.width - actualWidth + 20}
              $tip.find('.arrow').css({ left: '92%' })
            }
            break
          case 'top':
            tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'left':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
            break
          case 'right':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
            break
        }

        $tip
          .css(tp)
          .addClass(placement)
          .addClass('in')
      }
    }

  , isHTML: function(text) {
      // html string detection logic adapted from jQuery
      return typeof text != 'string'
        || ( text.charAt(0) === "<"
          && text.charAt( text.length - 1 ) === ">"
          && text.length >= 3
        ) || /^(?:[^<]*<[\w\W]+>[^>]*$)/.exec(text)
    }

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()

      $tip.find('.tooltip-inner')[this.isHTML(title) ? 'html' : 'text'](title)
      $tip.removeClass('fade in top bottom left right')
    }

  , hide: function () {
      var that = this
        , $tip = this.tip()

      $tip.removeClass('in')

      function removeWithAnimation() {
        var timeout = setTimeout(function () {
          $tip.off($.support.transition.end).remove()
        }, 500)

        $tip.one($.support.transition.end, function () {
          clearTimeout(timeout)
          $tip.remove()
        })
      }

      $.support.transition && this.$tip.hasClass('fade') ?
        removeWithAnimation() :
        $tip.remove()
    }

  , fixTitle: function () {
      var $e = this.$element
      if ($e.attr('title') || typeof($e.attr('data-original-title')) != 'string') {
        $e.attr('data-original-title', $e.attr('title') || '').removeAttr('title')
      }
    }

  , hasContent: function () {
      return this.getTitle()
    }

  , getPosition: function (inside) {
      return $.extend({}, (inside ? {top: 0, left: 0} : this.$element.offset()), {
        width: this.$element[0].offsetWidth
      , height: this.$element[0].offsetHeight
      })
    }

  , getTitle: function () {
      var title
        , $e = this.$element
        , o = this.options

      title = $e.attr('data-original-title')
        || (typeof o.title == 'function' ? o.title.call($e[0]) :  o.title)

      return title
    }

  , tip: function () {
      return this.$tip = this.$tip || $(this.options.template)
    }

  , validate: function () {
      if (!this.$element[0].parentNode) {
        this.hide()
        this.$element = null
        this.options = null
      }
    }

  , enable: function () {
      this.enabled = true
    }

  , disable: function () {
      this.enabled = false
    }

  , toggleEnabled: function () {
      this.enabled = !this.enabled
    }

  , toggle: function () {
      this[this.tip().hasClass('in') ? 'hide' : 'show']()
    }

  }


 /* TOOLTIP PLUGIN DEFINITION
  * ========================= */

  $.fn.tooltip = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tooltip')
        , options = typeof option == 'object' && option
      if (!data) $this.data('tooltip', (data = new Tooltip(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tooltip.Constructor = Tooltip

  $.fn.tooltip.defaults = {
    animation: true
  , placement: 'bottom'
  , selector: false
  , template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
  , trigger: 'hover'
  , title: ''
  , delay: 0
  }

}(window.jQuery);

$(function() {
  $('[rel="tooltip"]').tooltip()
})
/* ===========================================================
 * bootstrap-popover.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#popovers
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================================================== */


!function ($) {

  "use strict";


 /* POPOVER PUBLIC CLASS DEFINITION
  * =============================== */

  var Popover = function ( element, options ) {
    this.init('popover', element, options)
  }


  /* NOTE: POPOVER EXTENDS BOOTSTRAP-TOOLTIP.js
     ========================================== */

  Popover.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: Popover

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()
        , content = this.getContent()

      if (title === "") {
        $tip.find('.popover-title').remove()
        $tip.addClass('popover-no-title')
      } else {
        $tip.find('.popover-title')[this.isHTML(title) ? 'html' : 'text'](title)
      }
      $tip.find('.popover-content > *')[this.isHTML(content) ? 'html' : 'text'](content)

      $tip.removeClass('fade top bottom left right in')
    }

  , hasContent: function () {
      return this.getTitle() || this.getContent()
    }

  , getContent: function () {
      var content
        , $e = this.$element
        , o = this.options

      content = $e.attr('data-content')
        || (typeof o.content == 'function' ? o.content.call($e[0]) :  o.content)

      return content
    }

  , tip: function () {
      if (!this.$tip) {
        this.$tip = $(this.options.template)
      }
      return this.$tip
    }

  })


 /* POPOVER PLUGIN DEFINITION
  * ======================= */

  $.fn.popover = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('popover')
        , options = typeof option == 'object' && option
      if (!data) $this.data('popover', (data = new Popover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.popover.Constructor = Popover

  $.fn.popover.defaults = $.extend({} , $.fn.tooltip.defaults, {
    placement: 'right'
  , content: ''
  , template: '<div class="popover"><div class="arrow"></div><div class="popover-inner"><h4 class="popover-title"></h4><div class="popover-content"><p></p></div></div></div>'
  })

}(window.jQuery);

$(function() {
  $('[rel="popover"][data-original-title]').popover()
  $('[rel="popover"]').popover({placement: 'bottom'})
})
!(function($) {

  "use strict";

  var methods = {

    // Verifica os irmãos do checkbox.
    checkSiblings: function(checked, el) {
      var parent = el.parent().parent()
        , all = true

      el.siblings().each(function() {
        return all = ($(this).children('input[type="checkbox"]').prop('checked') === checked)
      })

      if (all && checked) {
        parent.children('input[type="checkbox"]').prop({
          indeterminate: false,
          checked: checked
        })
        methods.checkSiblings(checked, parent)

      } else if (all && !checked) {
        parent.children('input[type="checkbox"]').prop('checked', checked)
        parent.children('input[type="checkbox"]').prop('indeterminate', (parent.find('input[type="checkbox"]:checked').length > 0))
        methods.checkSiblings(checked, parent)

      } else {
        el.parents('li').children('input[type="checkbox"]').prop({
          indeterminate: true,
          checked: false
        })
      }
    },

    // Responsável pela parte de hierarquia de checkboxes.
    // Fonte: http://css-tricks.com/indeterminate-checkboxes/
    changeCheckBox: function(event) {
      var checked = $(this).prop('checked')
        , container = $(this).parent()

      container.find('input[type="checkbox"]').prop({
        indeterminate: false,
        checked: checked
      })

      methods.checkSiblings(checked, container)

      // Adiciona a classe que escurece o texto dos itens marcados.
      event.data.filterGroup.find('input[type="checkbox"]').each(function() {
        var checkbox = $(this)

        if (checkbox.prop('checked') || checkbox.prop('indeterminate')) {
          checkbox.parent().addClass(event.data.settings.filterCheckedClass)
        } else {
          checkbox.parent().removeClass(event.data.settings.filterCheckedClass)
        }
      })

      // Substitui o sub título do filtro.
      $(this).trigger('replaceSubTitle', [event.data.filterGroup])
    },

    // Desmarca totalmente um filtro.
    uncheckFilter: function(filterGroup, settings) {
      filterGroup.find('.' + settings.filterClass).removeClass(settings.filterActiveClass)
      filterGroup.find('.' + settings.filterSubTitleClass).text('')
      filterGroup.find('li').removeClass(settings.filterCheckedClass)
      filterGroup.find('input[type="checkbox"]').prop({
        checked: false,
        indeterminate: false
      })
    },

    // Substitui o sub título de um filtro de acordo com os checkboxes marcados.
    replaceSubTitle: function(event, filterGroup) {
      var checkedBoxes = filterGroup.find('input[type="checkbox"]:checked')
        , filter = filterGroup.find('.' + event.data.settings.filterClass)
        , subTitleText = ''

      if (checkedBoxes.length === 1) {
        subTitleText = checkedBoxes.siblings('label').text()
      } else if (checkedBoxes.length > 1) {
        // Subtrai um pois não conta a opção "Todos".
        subTitleText = (checkedBoxes.length - 1) + ' opções selecionadas'
      }

      // Caso especial para o filtro de cursos e disciplinas.
      if (filter.hasClass(event.data.settings.filterCoursesClass)) {
        var coursesCheckBoxes = filterGroup.find('.' + event.data.settings.filterLevel2ItemClass + ' > input[type="checkbox"]')
          , coursesCheckedBoxes = coursesCheckBoxes.filter(':checked')
          , coursesUnCheckedBoxes = coursesCheckBoxes.filter(function(index) {
            return $(this).prop('indeterminate')
          })

        // Cursos.
        if (coursesCheckedBoxes.length === 1) {
          subTitleText = coursesCheckedBoxes.siblings('label').text()
        } else if (coursesCheckedBoxes.length > 1) {
          subTitleText = coursesCheckedBoxes.length + ' cursos selecionados'
        }

        // Disciplinas.
        if (coursesUnCheckedBoxes.length >= 1) {
          var disciplinesCheckedBoxes = filterGroup.find('.' + event.data.settings.filterLevel3ItemClass + ' > input[type="checkbox"]:checked')

          if (disciplinesCheckedBoxes.length === 1) {
            subTitleText = disciplinesCheckedBoxes.siblings('label').text()
          } else if (disciplinesCheckedBoxes.length > 1) {
            subTitleText = disciplinesCheckedBoxes.length + ' disciplinas selecionadas'
          }
        }
      }

      // Adiciona a classe de filtro ativado.
      if (checkedBoxes.length >= 1) {
        filter.addClass(event.data.settings.filterActiveClass)
        // Desmarca os outros filtros.
        filterGroup.siblings().each(function() {
          methods.uncheckFilter($(this), event.data.settings)
        })
      } else {
        filter.removeClass(event.data.settings.filterActiveClass)
      }

      // Trata os nomes grandes.
      if (subTitleText.length > 28) {
        subTitleText = subTitleText.substring(0, 24) + '...'
      }

      filterGroup.find('.' + event.data.settings.filterSubTitleClass).text(subTitleText)
    },

    init: function(options) {
      var settings = $.extend({
          filterEverythingClass: 'filter-everything',
          filterActiveClass: 'filter-active',
          filterDropdownMenuClass: 'dropdown-menu',
          filterClass: 'filter',
          filterCoursesClass: 'filter-courses',
          filterLevel2ItemClass: 'filter-level-2-item',
          filterLevel3ItemClass: 'filter-level-3-item',
          filterSubTitleClass: 'filter-sub-title',
          filterCheckedClass: 'filter-checked'
        }, options)

      return this.each(function() {
        var reduFilter = $(this)
          , filterEverything = reduFilter.find('.' + settings.filterEverythingClass)
          , dropdownFilters = filterEverything.parent().siblings()

        // O filtro "Tudo" começa ativo.
        filterEverything.addClass(settings.filterActiveClass)
        // No estado ativado, desabilita todos os outros filtros.
        filterEverything.on('click', function(e) {
          dropdownFilters.each(function() {
            methods.uncheckFilter($(this), settings)
          })
        })

        // Para cada filtro.
        dropdownFilters.each(function() {
          var filterGroup = $(this)
          // Para cada checkbox.
          filterGroup.find('input[type="checkbox"]').each(function() {
            var checkbox = $(this)
            // Inicia desmarcado.
            checkbox.prop('checked', false)
            // Vincula o evento de substituir o sub título do filtro.
            checkbox.on('replaceSubTitle.reduFilter', {settings: settings}, methods.replaceSubTitle)
            checkbox.on('change', {settings: settings, filterGroup: filterGroup}, methods.changeCheckBox)
          })
        })

        // Impede que o dropdown feche ao ser clicado.
        reduFilter.find('.' + settings.filterDropdownMenuClass).on('click', function(e) {
          e.stopPropagation()
        })
      })
    }
  }

  $.fn.reduFilter = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduFilter')
    }
  }

}) (window.jQuery)

$(function() {
  // Adiciona os eventos dos filtros da visão geral.
  $('.filters-general-view').reduFilter()
})
!(function($) {

  "use strict";

  var methods = {

    // Adiciona a classe indicativa de controle em foco.
    focusLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está me foco.
        controlFocusedClass: 'control-focused'
        // Classe que identifica o container do controle.
      , controlGroupClass: 'control-group'
      }, options)

      $(this).parents('.' + settings.controlGroupClass).addClass(settings.controlFocusedClass)
    },

    // Remove a classe indicativa de controle em foco.
    removeFocusLabel: function(options) {
      var settings = $.extend({
        // Classe adicionada quando o controle está me foco.
        controlFocusedClass: 'control-focused'
        // Classe que identifica o container do controle.
      , controlGroupClass: 'control-group'
      }, options)

      $(this).parents('.' + settings.controlGroupClass).removeClass(settings.controlFocusedClass)
    },

    // Ajusta a altura do textarea de acordo com seu atributo rows.
    resizeByRows: function(options) {
      return this.each(function() {
        var $textarea = $(this)
          , rowsTemp = $textarea.attr('rows')
          , rows = (rowsTemp !== '' ? parseInt(rowsTemp, 10) : 0)

        if (rows !== 0) {
          var pxToInt = function(value) {
            if (typeof value !== 'undefined') {
              return parseInt(value.replace('px', ''), 10)
            } else {
              return 0;
            }
          }

          var lineHeight = pxToInt($textarea.css('line-height'))
            , borderTop = pxToInt($textarea.css('border-top-width'))
            , borderBottom = pxToInt($textarea.css('border-bottom-width'))
            , marginTop = pxToInt($textarea.css('margin-top'))
            , marginBottom = pxToInt($textarea.css('margin-bottom'))
            , paddingTop = pxToInt($textarea.css('padding-top'))
            , paddingBottom = pxToInt($textarea.css('padding-bottom'))

          $textarea.height((rows * lineHeight) + borderTop + borderBottom + marginTop + marginBottom + paddingTop + paddingBottom)
        }
      })
    },

    styleInputFile: function(options) {
      var settings = $.extend({
        buttonDefault: 'button-default'
      , buttonText: 'Escolher arquivo'
      , filePath: 'control-file-text'
      , filePathText: 'Nenhum arquivo selecionado.'
      , controlFile: 'control-file'
      , wrapper: 'control-file-wrapper'
      }, options)

      return this.each(function() {
        var $input = $(this).css({
            'opacity': 0
          })
          , inputVal = $input.val()
          , $wrapper = $(document.createElement('div')).addClass(settings.wrapper)
          , $controlFile = $(document.createElement('div')).addClass(settings.controlFile)
          , $button = $(document.createElement('button')).addClass(settings.buttonDefault).text(settings.buttonText).attr('type', 'button')
          , $filePath = $(document.createElement('span')).addClass(settings.filePath).text($input.data('legend') || settings.filePathText)

        $input.wrap($wrapper)
        $controlFile.append($button).append($filePath).insertAfter($input)

        // No FF, se um arquivo for escolhido e der refresh, o input mantém o valor.
        if (inputVal !== '') {
          $filePath.text(inputVal)
        }

        if (!$.browser.msie) {
          // Repassa o clique pro input file.
          $button.on('click', function(e) {
            $input.trigger('click')
          })
        } else {
          // No IE, põe o input file original na frente.
          $input.css({
            'position': 'absolute',
            'width': $button.width(),
            'height': $button.height(),
            'z-index': 2
          })
        }

        // Repassa o nome do arquivo para o span.
        $input.on('change', function() {
          var value = $input.val()

          if (value === '') {
            value = settings.filePathText
          } else {
            // Remove o 'C:\fakepath\' que alguns navegadores adicionam.
            value = value.replace('C:\\fakepath\\', '')
          }

          $filePath.text(value)
        })
      })
    },

    // Encontra o label correspondente de um checkbox/radio.
    findLabel: function($control) {
      // Primeiro tenta o label que encapsula o controle.
      var $label = $control.closest('label')
        , controlId = $control.attr('id')

      // Depois tenta achar o label se ele estiver ligado por controle[id] e label[for].
      if (typeof controlId !== 'undefined') {
        var $possibleLabel = $('label[for="' + controlId + '"]')

        if ($possibleLabel.length === 1) {
          $label = $possibleLabel
        }
      }

      return $label
    },

    init: function() {}
  }

  $.fn.reduForm = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduForm")
    }
  }

}) (window.jQuery)

$(function() {
  // Contador de caracteres.
  var characterCounterSelector = 'input[type="text"][maxlength], input[type="password"][maxlength], textarea[maxlength]'
    , remainingCharsText = function(maxLength, charCount, control) {
      var charDifference = maxLength - charCount

      if (charDifference <= 0) {
        if (control.is('textarea')) {
          // No IE o maxlength não funciona para as áreas de texto.
          control.text(control.text().substring(0, maxLength))
        }

        return 'Nenhum caracter restante.'
      } else if (charDifference === 1) {
        return '1 caracter restante.'
      } else {
        return charDifference + ' caracteres restantes.'
      }
    }

  $(document)
    .on("focusin", characterCounterSelector, function() {
      var $control = $(this)
        , maxLength = $control.attr("maxlength")
        , $counter = $('<span class="character-counter legend"></span>')

      $counter.text(remainingCharsText(maxLength, $control.val().length, $control))
      $counter.insertAfter($control)
    })
    .on("focusout", characterCounterSelector, function() {
      var $control = $(this)
        , $counter = $control.next()

      if ($counter.hasClass("character-counter")) {
        $counter.remove()
      }
    })
    .on("keyup", characterCounterSelector, function() {
      var $control = $(this)
        , maxLength = $control.attr("maxlength")
        , $counter = $control.next()

      if ($counter.hasClass("character-counter")) {
        $counter.text(remainingCharsText(maxLength, $control.val().length, $control))
      }
    })

  var focusInputSelectors = 'input[type="text"], input[type="password"], input[type="file"], textarea, select';
  $(document)
    .on('focus', focusInputSelectors, function(e) {
      $(this).reduForm('focusLabel')
    })
    .on('blur', focusInputSelectors, function(e) {
      $(this).reduForm('removeFocusLabel')
    })

  // Comportamento de escurer texto do checkbox/radio selecionado.

  var reduFormRadioCheckboxSettings = {
    // Classe adicionada quando o controle está marcado.
    controlCheckedClass: 'control-checked'
  }

  $(document).on('change', 'input:radio, input:checkbox', function(e) {
    var $control = $(this)
      , $label = $.fn.reduForm('findLabel', $control)

    if ($label.length > 0) {
      $label.toggleClass(reduFormRadioCheckboxSettings.controlCheckedClass)

      // Se for um radio.
      if ($control.is('input:radio')) {
        // Procura o label dos outros radios para remover a classe.
        var $form = $control.closest('form')
          , controlName = $control.attr('name')
          , $otherControls = $form.find('[name="' + controlName + '"]:radio').filter(function(index) {
              return this !== $control[0]
            })

        $otherControls.each(function() {
          var $control = $(this)
            , $label = $.fn.reduForm('findLabel', $control)

          $label.removeClass(reduFormRadioCheckboxSettings.controlCheckedClass)
        })
      }
    }
  })

  // Caso de refresh da página o checkbox/radio marcado.
  $('input:radio, input:checkbox').each(function() {
    var $control = $(this)
      , $label = $.fn.reduForm('findLabel', $control)

    if ($control.prop('checked')) {
      $label.addClass(reduFormRadioCheckboxSettings.controlCheckedClass)
    }
  })


  // No elemento de opção com texto e formulários de busca, quando o campo ou
  // área de texto estiverem selecionados, mudar a cor da borda e os ícones dos
  // botões de cinza para azul. O inverso acontece quando deselecionado.
  var colorBlue2 = '#73C3E6'
    , selectorControlArea = '.control-area.area-infix'
    , classesFixedArea = '.area-suffix, .form-search-filters-button'
    , classIcon = "[class^='icon-'],[class*=' icon-']"
  $(document)
    .on('focusin', selectorControlArea, function(e) {
      var $fixedAreas = $(this).parent().find(classesFixedArea)
        , $buttonsIcons = $fixedAreas.find(classIcon)
      // Troca a cor da borda.
      $fixedAreas.css('border-color', colorBlue2);

      // Troca a cor do ícone.
      $buttonsIcons.each(function() {
        var $button = $(this)
          , iconClasses = findIconClasses($button.attr('class'))
        $button
          .removeClass(iconClasses)
          .addClass(iconClasses.replace('gray', 'lightblue'))
      })
    })
    .on('focusout', selectorControlArea, function(e) {
      var $fixedAreas = $(this).parent().find(classesFixedArea)
        , $buttonsIcons = $fixedAreas.find(classIcon)
      // Troca a cor da borda.
      $fixedAreas.css('border-color', '');

      // Troca a cor do ícone.
      $buttonsIcons.each(function() {
        var $button = $(this)
          , iconClasses = findIconClasses($button.attr('class'))
        $button
          .removeClass(iconClasses)
          .addClass(iconClasses.replace('lightblue', 'gray'))
      })
    })
    .on('change', '.form-search-filters input:radio', function(e) {
      var $radio = $(this)
        , $legendIcon = $radio.siblings('.legend')
        , newIconClass = findIconClasses($legendIcon.attr('class'))
        , $buttonIcon = $radio.closest('.form-search-filters').find('.form-search-filters-button .control-search-icon')
        , currentIconClass = findIconClasses($buttonIcon.attr('class'))

      $buttonIcon.removeClass(currentIconClass).addClass(newIconClass.replace('-before', ''))
    })

  $('textarea[rows]').reduForm('resizeByRows')

  $('input[type="file"]').reduForm('styleInputFile')

  // Plugins.

  $('.controls textarea').autosize()

  placeHolderConfig = {
    // Nome da classe usada para estilizar o placeholder.
    className: 'placeholder'
    // Mostra o texto do placeholder para leitores de tela ou não.
  , visibleToScreenreaders : false
    // Classe usada para esconder visualmente o placeholder.
  , visibleToScreenreadersHideClass : 'placeholder-hide-except-screenreader'
    // Classe usada para esconder o placeholder de tudo.
  , visibleToNoneHideClass : 'placeholder-hide'
    // Ou esconde o placeholder no focus ou na hora de digitação.
  , hideOnFocus : false
    // Remove esta classe do label (para consertar labels escondidos).
  , removeLabelClass : 'visuallyhidden'
    // Substitui o label acima com esta classe.
  , hiddenOverrideClass : 'visuallyhidden-with-placeholder'
    // Permite a substituição do removeLabelClass com hiddenOverrideClass.
  , forceHiddenOverride : true
    // Aplica o polyfill até mesmo nos navegadores com suporte nativo.
  , forceApply : false
    // Inicia automaticamente.
  , autoInit : true
  }
})
!(function($) {

  'use strict';

  var methods = {

    init: function(options) {
      var settings = $.extend({
          'linkTargetClass': 'link-target'
        }, options)

      return this.each(function() {
        var container = $(this)
          , link = container.find('.' + settings.linkTargetClass)

          container.on('click', function(e) {
            if (!$(e.target).is('input[type="checkbox"]')) {
              window.location = link.attr('href')
            }
          })
        })
      }

  }

  $.fn.reduLinks = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduLinks')
    }
  }

}) (window.jQuery)

$(function() {
  $('.link-container').reduLinks()
})
!(function($) {

  "use strict";

  var methods = {

    // Expande/colapsa o dropdown.
    // Esconde a legenda, notificações e mostra a lista de disciplinas.
    toggleDropdown: function(options) {
      var settings = $.extend({}, $.fn.reduList.defaults, options)

      var $dropdown = $(this)
        , $listMixItem = $dropdown.closest("." + settings.classes.listMixItem)
        , $listMixHeaderLegend = $listMixItem.find("." +
          settings.classes.listMixHeaderLegend)
        , $listMixBody = $listMixItem.find("." + settings.classes.listMixBody)
        , $listMixInfoClass = $listMixItem.find("." +
          settings.classes.listMixInfo)

      if ($listMixItem.hasClass(settings.classes.openState)) {
        $listMixHeaderLegend.css("visibility", "visible")
      } else {
        $listMixHeaderLegend.css("visibility", "hidden")
      }

      $listMixInfoClass.toggle()
      $listMixItem.toggleClass(settings.classes.openState)
      $listMixBody.toggle(150, "swing")

      return $dropdown
    },

    init: function(options) {

    }
  }

  $.fn.reduList = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments,
        1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduList")
    }
  }

  $.fn.reduList.defaults = {
    classes: {
      listMixItem: "list-mix-item"
    , listMixHeaderLegend: "list-mix-header .legend"
    , listMixBody: "list-mix-body"
    , listMixInfo: "list-mix-info"
    , openState: "open"
    }
  }

  $(function() {
    $(document).on("click", ".list-mix .button-dropdown:not(.button-disabled)",
      function(e) {
      $(this).reduList("toggleDropdown")
    })
  })

}) (window.jQuery)
$(function() {
  //Desabilita href dos links com estilo de botão, quando no estado desabilidado.
  $(".button-disabled").live("click", function(e) {
    e.preventDefault()
  });
});
!(function($) {

  "use strict";

  var methods = {

    // Altera o estado de seleção da linha do checkbox.
    toggleState: function(options) {
      var settings = $.extend({}, $.fn.reduTables.defaults, options)

      var $checkbox = $(this)
        , $row = $checkbox.closest("tr")
        , $form = $checkbox.closest(settings.selectors.form)

      $row.toggleClass(settings.classes.checkboxSelected)
      $form.trigger("verifySubmit")

      return $checkbox
    }

    // Verifica se o botão de submissão deve ser ativado ou não.
  , verifySubmit: function(options) {
    var settings = $.extend({}, $.fn.reduTables.defaults, options)

    var $form = $(this)
      , $submit = $form.find('input[type="submit"]')
      , $checkboxes = $form.find('input[type="checkbox"]')

    $checkboxes.each(function() {
      var $checkbox = $(this)

      // Se o checkbox foi selecionado, abilita o submit.
      if ($checkbox.is(":checked")) {
        $submit.removeAttr("disabled")
        return false
      } else {
        // Se foi o último a ser desmarcado, desabilita o submit.
        if ($checkboxes.filter(":checked").length === 0) {
          $submit.attr("disabled", "disabled")
        }
      }
    })

    return $form
  }

  , init: function(options) {

    }
  }

  $.fn.reduTables = function(method) {
    if (methods[method]) {
      return methods[method].apply(this,
        Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.reduTables")
    }
  }

  $.fn.reduTables.defaults = {
    classes: {
      checkboxSelected: "table-checkbox-selected"
    }
  , selectors: {
      form: ".form-checklist"
    }
  }

  $(function() {
    var checkboxSelector = $.fn.reduTables.defaults.selectors.form +
        ' td input[type="checkbox"]'
      , $submit = $($.fn.reduTables.defaults.selectors.form +
        ' input[type="submit"]').attr("disabled", "disabled")
      , enableSubmit = false

    $(document)
      .on("change", checkboxSelector, function(e) {
        $(this).reduTables("toggleState")
      })
      .on("verifySubmit", $.fn.reduTables.defaults.selectors.form,
        function(e) {
        $(this).reduTables("verifySubmit")
      })

    // FF caches os checkboxes selecionados após o page refresh.
    $(checkboxSelector).filter(":checked").each(function() {
      $(this).reduTables("toggleState")
      enableSubmit = true
    })

    if (enableSubmit) {
      $submit.removeAttr("disabled")
    }
  })

}) (window.jQuery)
!(function($) {

  'use strict';

  var settings = {
    originalInput: 'control-autocomplete-input'
  , tokenInputPrefix: 'token-input-'
  , triggerInviteByMail: 'inviteByMail.reduAutocomplete'
  , dropdown: 'control-autocomplete-dropdown'
  , name: 'control-autocomplete-name'
  , mail: 'control-autocomplete-mail legend'
  , suggestion: 'control-autocomplete-suggestion'
  , inviteClickText: 'Clique aqui para convidar este endereço de e-mail'
  , buttonStyle: 'button-primary'
  , listMix: 'list-mix'
  , listMixItem: 'list-mix-item'
  , listMixInner: 'list-mix-inner'
  , close: 'control-autocomplete-close'
  , iconClose: 'icon-close-gray_16_18 show'
  , addedInfo: 'control-autocomplete-added-info'
  , inviteText: '(Convidar para o Redu)'
  , invites: 'control-autocomplete-invites'
  }

  var methods = {
    // Cria um elemento usado para convidar alguém para o Openredu por e-mail.
    createInvite: function(mail) {
      return $('<li class="' + settings.listMixItem + '"><div class="' + settings.listMixInner + '"><span class="' + settings.close + '"><span class="' + settings.iconClose + '"></span></span><div class="' + settings.addedInfo + '"><span class="' + settings.name + '">' + mail + '</span><span class="' + settings.mail + '">' + settings.inviteText + '</span></div></div></li>')
    }

    // Quando um e-mail é digitado, sugere o envio do convite ao Redu.
  , inviteByMail: function(options) {
      settings = $.extend(settings, options)

      return this.each(function() {
        var control = $(this)
          , originalInput = control.find('.' + settings.originalInput)

        // Este evento será lançado quando nenhum resultado for encontrado.
        originalInput.on(settings.triggerInviteByMail, function() {
          var input = $.trim(control.find('#' + settings.tokenInputPrefix + originalInput.attr('id')).val())
            , emailRegex = /^([a-zA-Z0-9])+@([a-zA-Z0-9])+\.([a-zA-Z])+([a-zA-Z])+/

          // Verifica se é um e-mail.
          if (emailRegex.test(input)) {
            var dropdown = control.find('.' + settings.dropdown)
              , inviteButton = $(document.createElement('button')).addClass(settings.buttonStyle).text(settings.inviteClickText)
              , listMix = control.find('.' + settings.listMix)

            // Incli o botão de adicionar.
            dropdown.html(inviteButton)
            inviteButton.on('click', function(e) {
              e.preventDefault()
              var isAlreadyIn = false
                , inputInvites = control.find('.' + settings.invites)

              // Verifica se o e-mail já está incluso.
              if (inputInvites.val().indexOf(input) >= 0) {
                isAlreadyIn = true
              }

              // Adiciona se não estiver.
              if (!isAlreadyIn) {
                var inviteChosen = methods.createInvite(input)
                  , close = inviteChosen.find('.' + settings.close)

                // Adiciona o remover para o ícone de fechar.
                close.on('click', function(e) {
                  e.preventDefault
                  var item = $(this).parents('.' + settings.listMixItem)

                  item.remove()
                  // Remove o e-mail dos valores do input hidden.
                  inputInvites.val($.trim(inputInvites.val().replace(',', ' ').replace(input, '')).replace(' ', ',').replace(',,', ','))
                })

                // Adiciona o e-mail aos valores do input hidden.
                var mails = $.trim(inputInvites.val() + ' ' + input)
                inputInvites.val((mails.split(' ')).join(','))

                // Adiciona a lista.
                listMix.append(inviteChosen)
              }
            })
          }
        })
      })
    }

  , init: function(options) {
      methods.inviteByMail(options)
    }
  }

  $.fn.reduAutocomplete = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduAutocomplete')
    }
  }

}) (window.jQuery)

$(function() {
  $('.control-invite-by-mail').reduAutocomplete('inviteByMail')
})
!(function($) {

  "use strict";

  var methods = {
    checkLabel: function(checkbox) {
      var label = checkbox.siblings("label")
      if (checkbox.prop("checked")) {
        label.addClass("local-nav-checked icon-confirm-green_16_18-after")
      } else {
        label.removeClass("local-nav-checked icon-confirm-green_16_18-after")
      }
    },

    init: function() {
      return this.each(function() {
        var localNav = $(this)

        localNav.find("li").click(function(e) {
          window.location = $(this).children("a").first().attr("href")
        })

        var checkboxes = localNav.find('input[type="checkbox"]')
        checkboxes.filter(":checked").each(function() {
          methods.checkLabel($(this))
        })

        checkboxes.change(function(e) {
          methods.checkLabel($(this))
        })
      })
    }
  }

  $.fn.localNav = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === "object" || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error("O método " + method + " não existe em jQuery.localNav")
    }
  }

}) (window.jQuery)

$(function() {
  $(".local-nav").localNav();
})
!(function($) {

  'use strict';

  var classes = {
    // Wrapper.
    modal: 'modal'
    // Conteúdo.
  , modalBody: 'modal-body'
    // Seta.
  , scrollArrow: 'modal-scroll-arrow'
  }

  var methods = {
    // Usado para conseguir o tamanho de um elemento com display none.
    displayHidden: function($element) {
      var wasVisible = true

      if ($element.css('display') === 'none') {
        $element.css({
          'visibility': 'hidden'
        , 'display': 'block'})
        wasVisible = false
      }

      return wasVisible
    }

    // Retorna o elemento para display none.
  , displayVisible: function($element) {
      $element.css({
        'visibility': 'visible'
      , 'display': 'none'})
    }

  , fitContent: function($modal, settings) {
    var $modalBody = $modal.find('.' + classes.modalBody)
      , wasVisible
      , isMaxHeight = true

    wasVisible = methods.displayHidden($modal)

    // O novo tamanho do corpo é: tamanho atual + (altura visível do navegador - espaçamento inferior - topo do modal - altura do modal)
    var newHeight = $modalBody.height() + $(window).height() - (settings.verticalMargin * 2) - $modal.height() + "px"

    var innerHeight = $modalBody[0].scrollHeight - (parseInt($modalBody.css('padding-top'), 10) + parseInt($modalBody.css('padding-bottom'), 10))

    if (innerHeight <= parseInt(newHeight, 10)) {
      newHeight = innerHeight
      isMaxHeight = false
    }

    $modalBody.css('max-height', newHeight)
    $modalBody.css('height', newHeight)

    if (isMaxHeight) {
      $modal.css('top', settings.verticalMargin)
    }

    if (!wasVisible) {
      methods.displayVisible($modal)
    }
  }

    // Preenche verticalmente a janela modal.
  , fillHeight: function(options) {
      var settings = $.extend({
          // Margem inferior.
          verticalMargin: 20
        }, options)

      return this.each(function() {
        var $modal = $(this)
        $modal.on('fitContent.redu', function(e) {
          methods.fitContent($modal, settings)
        })
        $modal.trigger('fitContent.redu')
      })
    }

    // Ajusta a largura do modal para se adequar a largura do conteúdo interno.
    // Caso a largura do conteúdo interno seja maior que a largura visível do navegador, extende o modal horizontalmente para acomodar a máxima largura visível.
  , fillHorizontal: function(options) {
    var settings = $.extend({
        // Margens laterais.
        horizontalMargin: 20
      }, options)

    return this.each(function() {
      var $modal = $(this)
        , maxWidth = $(window).width() - 2 * settings.horizontalMargin

      $modal.css('left', 0)

      var modalWidth = $modal.outerWidth()

      if (modalWidth <= maxWidth) {
        maxWidth = modalWidth
      }

      $modal.css('marginLeft', (-1) * (maxWidth / 2))
      $modal.css('width', maxWidth)

      $modal.css('left', '50%')
    })
  }

    // Verifica se um elemento apresenta a barra de scroll vertical.
  , hasScrollBar: function($element) {
      var element = $element.get(0)
      return (element.scrollHeight > element.clientHeight)
    }

    // Controla a seta mostrada quando há barra de scroll vertical.
  , scrollArrow: function(options) {
      var settings = $.extend({
        // Caractere simbolizando uma seta para cima.
        arrowUp: '↑'
        // Caractere simbolizando uma seta para baixo.
      , arrowDown: '↓'
        // Largura da seta.
      , arrowWidth: 9
      }, options)

      return this.each(function() {
        var $modalBody = $(this)
          , $modal = $modalBody.parent('.' + classes.modal)

        methods.displayHidden($modal)

        if (methods.hasScrollBar($modalBody)) {
          var $scrollArrow =
                $(document.createElement('span'))
                  .addClass(classes.scrollArrow)
                  .html(settings.arrowDown)
            , modalBodyOffset = $modalBody.offset()
            , margin = (parseInt($modalBody.css('padding-left'), 10) - settings.arrowWidth) / 2
            , arrowUpPosition = modalBodyOffset.top - $(window).scrollTop() + 5
            , arrowDownPosition = arrowUpPosition + $modalBody.height()

          $scrollArrow.css({
            'top': arrowDownPosition
          , 'left': modalBodyOffset.left + margin
          })

          $modalBody.append($scrollArrow)
          $modalBody.scroll(function() {
            var scrollTop = $modalBody.scrollTop()

            if (scrollTop === 0) {
              // Barra de rolagem no topo, exibe seta para baixo.
              $scrollArrow.css('top', arrowDownPosition).html(settings.arrowDown)
            } else if (scrollTop + $modalBody.innerHeight() >= $modalBody.get(0).scrollHeight) {
              // Barra de rolagem no fundo, exibe seta para cima.
              $scrollArrow.css('top', arrowUpPosition).html(settings.arrowUp)
            }
          })
        }

        methods.displayVisible($modal)
      })
    }
  }

  $.fn.reduModal = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduModal')
    }
  }

}) (window.jQuery)

$(function() {
  $('.modal').reduModal('fillHeight')
  $('.modal-scroll').reduModal('scrollArrow')
  $('.modal-fill-horizontal').reduModal('fillHorizontal')

  // Abre uma modal caso seu id esteja na URL.
  var modalId = /#[a-zA-Z\-_\d]*/.exec(document.URL)
  if (modalId !== null) {
    var $modal = $(modalId[0])
    $modal.length !== 0 && $modal.hasClass("modal") && $modal.modal("show")
  }
})
/*global findIconClasses */

!(function($) {

  'use strict';

  var settings = {
    buttonDefault: 'button-default'
  , buttonPrimary: 'button-primary'
  , buttonDanger: 'button-danger'
  , buttonSuccess: 'button-success'
  , buttonDisabled: 'button-disabled'
  , linkSecondary: 'link-secondary'
  , spinnerHorizontalBlue: 'spinner-horizontal-blue'
  , spinnerCircularGray: 'spinner-circular-gray'
  , spinnerCircularBlue: 'spinner-circular-blue'
  , imgPath: '/assets/'
  , spinnerCircularBlueGif: 'spinner-blue.gif'
  , spinnerCircularGrayGif: 'spinner-grey.gif'
  , spinnerCSS: {
      'display': 'inline-block'
    , 'vertical-align': 'middle'
    }
  }

  var methods = {
    // Verifica se o elemento tem alguma classe de botão.
    hasButtonClass: function($element) {
      return ($element.hasClass(settings.buttonDefault)
            || $element.hasClass(settings.buttonPrimary)
            || $element.hasClass(settings.buttonDanger)
            || $element.hasClass(settings.buttonSuccess))
    }

    // Chamado antes da requesição AJAX.
  , ajaxBefore: function(options) {
      settings = $.extend(settings, options)

      var $this = $(this)

      // Se for um formulário.
      if ($this.is('form')) {
        var $submit = $this.find('input:submit, button[type="submit"]')
          , spinnerClass = settings.spinnerCircularGray
          , submitIconClasses = findIconClasses($submit.attr('class'))
          , submitWidth = $submit.outerWidth()
          , submitHeight = $submit.outerHeight()

        if ($submit.hasClass(settings.buttonDefault)) {
          spinnerClass = settings.spinnerCircularBlue
        }

        $submit
          .addClass(spinnerClass)
          .prop('disabled', true)
          .data('spinnerClass', spinnerClass)
          .data('content', $submit.val())
          .data('class', submitIconClasses)
          .removeClass(submitIconClasses)
          .css({ 'width': submitWidth, 'height': submitHeight })
          .val('')
      }

      // Se for um botão.
      if (methods.hasButtonClass($this)) {
        // Botão padrão usa o spinner azul e os outros cinza.
        var spinnerImg = settings.imgPath
        if ($this.hasClass(settings.buttonDefault)) {
          spinnerImg += settings.spinnerCircularBlueGif
        } else {
          spinnerImg += settings.spinnerCircularGrayGif
        }

        var content = $this.html()
          , width = $this.width()
          , height = $this.height()
          , iconClasses = findIconClasses($this.attr('class'))
          , $spinner = $(document.createElement('img')).attr('src', spinnerImg).css(settings.spinnerCSS)

        $this
          .addClass(settings.buttonDisabled)
          .removeClass(iconClasses)
          .data('content', content)
          .data('class', iconClasses)
          .html($spinner)
          .css({'width': width, 'height': height})
      } else if ($this.is('a')) {
        // Link secundário usa o spinner horizontal azul, o normal usa o circular cinza.
        var linkSpinnerClass = settings.spinnerCircularGray
        if ($this.hasClass(settings.linkSecondary)) {
          linkSpinnerClass = settings.spinnerHorizontalBlue
        }

        $this.data('spinnerClass', linkSpinnerClass)
        $this.addClass(linkSpinnerClass)
      }
    }

    // Chamado depois da requisição AJAX.
  , ajaxComplete: function(options) {
      settings = $.extend(settings, options)

      var $this = $(this)

      if ($this.is('form')) {
        var $submit = $this.find('input:submit, button[type="submit"]')

        $submit
          .removeClass($submit.data('spinnerClass'))
          .addClass($submit.data('class'))
          .prop('disabled', false)
          .val($submit.data('content'))
      }

      // Se for um botão.
      if (methods.hasButtonClass($this)) {
        $this
          .removeClass(settings.buttonDisabled)
          .addClass($this.data('class'))
          .html($this.data('content'))
      } else if ($this.is('a')) {
        $this.removeClass($this.data('spinnerClass'))
      }
    }
  }

  $.fn.reduSpinners = function(method) {
    if (methods[method]) {
      return methods[method].apply(this, Array.prototype.slice.call(arguments, 1))
    } else if (typeof method === 'object' || !method) {
      return methods.init.apply(this, arguments)
    } else {
      $.error('O método ' + method + ' não existe em jQuery.reduSpinners')
    }
  }

}) (window.jQuery)

$(function() {
  $(document)
    .on('ajax:before', '[data-remote="true"]', function(xhr, settings) {
      $(this).reduSpinners('ajaxBefore')
    })
    .on('ajax:complete', '[data-remote="true"]', function(xhr, status) {
      $(this).reduSpinners('ajaxComplete')
    })
})

!function ($) {

  "use strict";


 /* DEFINIÇÃO DE CLASSE DO CAMPO DE BUSCA.
  * ============================== */

  var SearchField = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.searchField.defaults, options)
  }

  SearchField.prototype.expand = function () {
    var $target = $(this.$element.data("toggle"))
      , isFocused = this.$element.data("isFocused")

    if (!isFocused) {
      $target.hide()

      this.$element
        .data("isFocused", true)
        .closest("." + this.options.classes.formSearchExpandable)
        .animate({ width: "+=" + this.options.increment }, 150)
    }
  }

  SearchField.prototype.collapse = function () {
    var $target = $(this.$element.data("toggle"))
      , isFocused = this.$element.data("isFocused")

    if (isFocused) {
      $target.show()

      this.$element
        .data("isFocused", false)
        .closest("." + this.options.classes.formSearchExpandable)
        .animate({ width: "-=" + this.options.increment }, 150)
    }
  }


 /* DEFINIÇÃO DO PLUGIN DO CAMPO DE BUSCA.
  * ======================== */

  $.fn.searchField = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data("searchField")
        , options = typeof option == "object" && option
      if (!data) $this.data("searchField", (data = new SearchField(this, options)))
      if (option == "expand") data.expand()
      else if (option == "collapse") data.collapse()
    })
  }

  $.fn.searchField.defaults = {
    increment: 100
  , classes: {
      // Padrão a todo formulário de busca.
      formSearch: "form-search"
      // Formulário de busca que expande/contrai.
    , formSearchExpandable: "form-search-expandable"
      // Formulário de busca com dropdown de filtros.
    , formSearchFilters: "form-search-filters"
      // Campo de texto onde o termo de busca é digitado.
    , inputField: "control-area"
    }
  }

  $.fn.searchField.Constructor = SearchField


 /* DATA-API DO CAMPO DE BUSCA.
  * =============== */

  $(function () {
    var formSearchExpandableInputSelector = "." + $.fn.searchField.defaults.classes.formSearchExpandable + " ." + $.fn.searchField.defaults.classes.inputField
      , formSearchFiltersInputSelector = "." + $.fn.searchField.defaults.classes.formSearchFilters + " ." + $.fn.searchField.defaults.classes.inputField

    $(document)
      .on("focusin", formSearchExpandableInputSelector, function (e) {
        $(this).searchField("expand")
      })
      .on("focusout", formSearchExpandableInputSelector, function (e) {
        $(this).searchField("collapse")
      })
      .on("keypress", formSearchFiltersInputSelector, function(e) {
        // Submete o formulário quando o Enter é pressionado ao invés de abrir o dropdown.
        if (e.which == 13) {
          $(this).closest("." + $.fn.searchField.defaults.classes.formSearch).submit()
          return false
        }
      })
  })

}(window.jQuery);
// Exibe formulário para criação de status.
$(document).on("focusin", ".status-tab textarea", function() {
  var $textArea = $(this);

  if (!$textArea.data("open")) {
    $textArea
      .animate({ height: "122px" }, 150, "swing", function() {
        var $buttons = $textArea.closest(".status-tab").find(".status-buttons");

        $buttons.slideDown(150, "swing");
      })
      .data("open", true);
  }
});

// Cancela a criação de status.
$(document).on("click", ".create-status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-status");
  var $statusButtons = $createStatus.find(".status-buttons");
  var $preview = $createStatus.find(".post-resource");
  var $textArea = $createStatus.find("textarea");

  $statusButtons.slideUp(150, "swing", function() {
    $textArea
      .animate({ height: 32 }, 150, "swing", function() {
        $preview.slideUp(150, "swing", function() {
          $preview.remove();
        });
      })
      .data("open", false);
  });
});

// Exibe formulário para criação de respostas.
$(document).on("click", ".status .reply-status .link-secondary", function() {
  var $subjectContent = $(this).closest(".subject-content");
  var $createResponse = $subjectContent.find(".create-response");
  var $textArea = $createResponse.find("textarea");

  $createResponse.slideToggle(150, "swing");
  $textArea.focus();
});

// Esconde formulário para criação de respostas.
$(document).on("click", ".status .cancel", function() {
  var $cancelButton = $(this);
  var $createStatus = $cancelButton.closest(".create-response");
  var $preview = $createStatus.find(".post-resource");

  $createStatus.slideUp(150, "swing", function() {
    $preview.remove();
  });
});

// Expande/minimiza as respostas dos comentários.
$(document).on("click", ".status .see-more", function() {
  var $link = $(this);
  var $status = $link.closest(".status");
  var $lastResponses = $status.find(".last-responses");
  var $responses = $status.find(".responses").children().filter(":not(.show-responses)");
  var totalResponses = $responses.length;

  if (!$link.data("open")) {
    // Mostra as respostas que estavam escondidas.
    $responses.filter(":hidden").slideDown(150, "swing");
    $link.html("Esconder as primeiras respostas")
    $lastResponses.html("Visualizando todas as respostas...");
    $link.data("open", true);
  } else {
    // Deixa somente as 3 últimas visíveis.
    $responses.filter(":lt(" + (totalResponses - 3) + ")").slideUp(150, "swing");
    $link.html("Mostrar todas as " + totalResponses + " respostas");
    $lastResponses.html("Visualizando as últimas respostas...");
    $link.data("open", false);
  }
});

// Expande/minimiza os membros.
$(document).on("click", ".status-list .see-all", function() {
  var $link = $(this);
  var $groupingElements = $link.closest(".status").find(".grouping-elements");

  if (!$link.data("open")) {
    $groupingElements.animate({ height: $groupingElements[0].scrollHeight }, 150, "swing");
    $link
      .html("- Esconder todos")
      .data("open", true);
  } else {
    $groupingElements.animate({ height: 40 }, 150, "swing");
    $link
      .html("+ Ver todos")
      .data("open", false);
  }
});

// Agrupa as respostas.
$.fn.groupResponses = function(opts) {
  return this.each(function() {
    var options = {
      maxResponses : 3
    }
    $.extend(options, opts)
    var $this = $(this);
    var $responses = $this.children(":not(.show-responses)");

    if ($responses.length > options.maxResponses) {
      $responses.filter(":lt(" + ($responses.length - options.maxResponses) + ")").slideUp(150, "swing");
      $(this).find(".show-responses").show();
     } else {
      $this.find(".show-responses").hide();
      $responses.first().find("hr").hide();
    }
  });
}

// Conta a quantidade de respostas de um status e atualiza a legenda.
$.fn.countComments = function() {
  return this.each(function() {
    var $responses = $(this);
    var quantity = $responses.find(".response").length;
    var $seeMore = $responses.find(".see-more");

    $seeMore.html("Mostrar todas as " + quantity + " respostas");
  });
};

$(function() {
  $(".responses").groupResponses();
});

$(document).ajaxComplete(function() {
  $(".responses").groupResponses();
});
$(function() {
  var settings = {
    // Engloba todo o botão dropdown e formulário de login.
    buttonSignInWrapper: ".header-button-sign-in"
    // O botão dropdown.
  , buttonDropdown: ".dropdown-toggle"
    // O campo de login (logicamente deve ser o primeiro).
  , inputLogin: "input:text:first"
  }

  // Foca no primeiro campo (de login) quando o botão dropdown "Entrar no Redu" é aberto.
  $("body").on("click", settings.buttonSignInWrapper + " " + settings.buttonDropdown, function() {
    setTimeout(function() {
      $(settings.buttonSignInWrapper).find(settings.inputLogin).focus()
    }, 100)
  })
})