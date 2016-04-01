$(Sugar).bind('ready', function() {
  $("#search form").each(function() {
    let form = this;
    $(form).find("#search_mode").change(function() {
      this.parentNode.action = this.value;
    });
    $(form).submit(function() {
      let query = encodeURIComponent($(form).find(".query").val());
      var action = form.action;
      if (!action.match(/^https?:\/\//)) {
        let baseDomain = document.location
                                 .toString()
                                 .match(/^(https?:\/\/[\w\d\-\.]+)/)[1];
        action = baseDomain + action;
      }
      document.location = action + "?q=" + query;;
      return false;
    });
  });
});
