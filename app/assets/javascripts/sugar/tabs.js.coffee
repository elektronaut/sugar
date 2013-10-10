Sugar.Tabs = (controls, options) ->
  controls.tabs = []
  settings = jQuery.extend(
    showFirstTab: true
  , options)
  controls.hideAllTabs = ->
    jQuery(@tabs).each ->
      jQuery(@tabId).hide()
      jQuery(@parentNode).removeClass "active"

  controls.showTab = (tab) ->
    jQuery(@tabs).each ->
      unless this.tabId == tab.tabId
        jQuery(@tabId).hide()
        jQuery(@parentNode).removeClass "active"
    jQuery(tab.tabId).show()
    jQuery(tab.parentNode).addClass "active"

  jQuery(controls).find("a").each ->
    @container = controls
    @tabId = @href.match(/(#[\w\d\-_]+)$/)[1]
    controls.tabs.push this
    jQuery(this).click ->
      @container.showTab this
      false

  controls.hideAllTabs()
  anchorTab = false
  tabShown = false
  if document.location.toString().match(/(#[\w\d\-_]+)$/)
    anchorTab = document.location.toString().match(/(#[\w\d\-_]+)$/)[1]
    a = 0

    while a < controls.tabs.length
      if controls.tabs[a].tabId is anchorTab
        controls.showTab controls.tabs[a]
        tabShown = true
      a += 1
  controls.showTab controls.tabs[0]  if not tabShown and settings.showFirstTab
  @controls = controls
  @tabs = @controls.tabs
  this
