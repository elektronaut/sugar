$(Sugar).bind('ready', function() {
  $('.edit_user_profile').each(function() {
    let checkAdmin = function() {
      if ($('#user_admin:checked').val()) {
        $('#user_moderator').attr('checked', true).attr('disabled', true);
        $('#user_user_admin').attr('checked', true).attr('disabled', true);
      } else {
        $('#user_moderator').attr('disabled', false);
        return $('#user_user_admin').attr('disabled', false);
      }
    };

    let checkUserStatus = function () {
      let status = $("#user_status").val();
      let disabled = !(status == "hiatus" || status == "time_out");
      $('.banned-until select').attr("disabled", disabled);
    }

    $('#user_status').change(checkUserStatus);
    checkAdmin();
    checkUserStatus();
  });
});
