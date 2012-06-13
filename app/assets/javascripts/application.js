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

jQuery(document).ready(function () {
  Sugar.init();
});
