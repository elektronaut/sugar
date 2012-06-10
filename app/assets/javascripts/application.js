//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink

//= require_tree ./vendor
//= require ./syntaxhighlighter/shCore
//= require_tree ./syntaxhighlighter/brushes

//= require backbone/sugar
//= require sugar
//= require_tree ./sugar

window.relativeTime = function (timeString) {
  var parsedDate = Date.parse(timeString);
  var delta = (Date.parse(Date()) - parsedDate) / 1000;
  var r = '';
  if (delta < 60) {
    r = 'a moment ago';
  } else if (delta < 120) {
    r = 'a couple of minutes ago';
  } else if (delta < (45 * 60)) {
    r = (parseInt(delta / 60, 10)).toString() + ' minutes ago';
  } else if (delta < (90 * 60)) {
    r = 'an hour ago';
  } else if (delta < (24 * 60 * 60)) {
    r = '' + (parseInt(delta / 3600, 10)).toString() + ' hours ago';
  } else if (delta < (48 * 60 * 60)) {
    r = 'a day ago';
  } else {
    r = (parseInt(delta / 86400, 10)).toString() + ' days ago';
  }
  return r;
};

/* Dead simple tabs */
function SugarTabs(controls, options) {
  controls.tabs = [];

  var settings = jQuery.extend({
    showFirstTab: true
  }, options);

  controls.hideAllTabs = function () {
    jQuery(this.tabs).each(function () {
      jQuery(this.tabId).hide();
      jQuery(this.parentNode).removeClass('active');
    });
  };

  controls.showTab = function (tab) {
    this.hideAllTabs();
    jQuery(tab.tabId).show();
    jQuery(tab.parentNode).addClass('active');
  };

  // Set up the links
  jQuery(controls).find('a').each(function () {
    this.container = controls;
    this.tabId = this.href.match(/(#[\w\d\-_]+)$/)[1];
    controls.tabs.push(this);
    jQuery(this).click(function () {
      this.container.showTab(this);
      return false;
    });
  });

  controls.hideAllTabs();

  var anchorTab = false;
  var tabShown  = false;
  if (document.location.toString().match(/(#[\w\d\-_]+)$/)) {
    anchorTab = document.location.toString().match(/(#[\w\d\-_]+)$/)[1];
    for (var a = 0; a < controls.tabs.length; a += 1) {
      if (controls.tabs[a].tabId === anchorTab) {
        controls.showTab(controls.tabs[a]);
        tabShown = true;
      }
    }
  }

  if (!tabShown && settings.showFirstTab) {
    controls.showTab(controls.tabs[0]);
  }

  // Delegates
  this.controls = controls;
  this.tabs = this.controls.tabs;
}

/* Rich text editing */
function JRichTextArea(textArea, options) {
  this.textArea = textArea;

  // Default options
  var settings = jQuery.extend({
    className: "richTextToolbar"
  }, options);

  this.toolbar = {
    settings: settings,
    textArea: textArea,
    listElement: false,
    buttons: [],
    addButton: function (name, callback, options) {
      // Default options
      settings = jQuery.extend({
        className: name.replace(/[\s]+/, '') + "Button"
      }, options);
      var li = document.createElement("li");
      var a = document.createElement("a");
      a.title = name;
      a.textArea = this.textArea;
      //callback.this = this;
      jQuery(a).click(callback);
      jQuery(a).addClass(settings.className);
      jQuery(li).append(a).appendTo(this.listElement);
      this.buttons.push(li);
      return this;
    },
    create: function () {
      if (!this.listElement) {
        this.listElement = document.createElement("ul");
        jQuery(this.listElement).addClass(this.settings.className);
        jQuery(this.listElement).insertBefore(this.textArea);
      }
    }
  };

  this.textArea.selectedText = function () {
    return jQuery(this).getSelection().text;
  };
  this.textArea.replaceSelection = function (replacement) {
    return jQuery(this).replaceSelection(replacement);
  };
  this.textArea.wrapSelection = function () {
    var prepend = arguments[0];
    var append = (arguments.length > 1) ? arguments[1] : prepend;
    return this.replaceSelection(prepend + this.selectedText() + append);
  };

  // Delegates
  this.textArea.toolbar = this.toolbar;
  this.toolbar.create();
}


jQuery(document).ready(function () {
  Sugar.init();
});