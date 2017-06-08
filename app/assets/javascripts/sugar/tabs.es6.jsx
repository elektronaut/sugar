Sugar.Tabs = function(controls, options) {
  controls.tabs = [];

  let settings = jQuery.extend({
    showFirstTab: true
  }, options);

  var anchorTab = false;
  var tabShown = false;

  controls.hideAllTabs = function() {
    $(this.tabs).each(function() {
      $(this.tabId).hide();
      return $(this.parentNode).removeClass("active");
    });
  };

  controls.showTab = function(tab) {
    $(this.tabs).each(function() {
      if (this.tabId !== tab.tabId) {
        $(this.tabId).hide();
        return $(this.parentNode).removeClass("active");
      }
    });
    $(tab.tabId).show();
    $(tab.parentNode).addClass("active");
  };

  $(controls).find("a").each(function() {
    this.container = controls;
    this.tabId = this.href.match(/(#[\w\d\-_]+)$/)[1];
    controls.tabs.push(this);
    return $(this).click(function() {
      this.container.showTab(this);
      return false;
    });
  });

  controls.hideAllTabs();

  if (document.location.toString().match(/(#[\w\d\-_]+)$/)) {
    anchorTab = document.location.toString().match(/(#[\w\d\-_]+)$/)[1];

    for (var a = 0; a < controls.tabs.length; a++) {
      if (controls.tabs[a].tabId === anchorTab) {
        controls.showTab(controls.tabs[a]);
        tabShown = true;
      }
    }
  }
  if (!tabShown && settings.showFirstTab) {
    controls.showTab(controls.tabs[0]);
  }

  this.controls = controls;
  this.tabs = this.controls.tabs;
  return this;
};
