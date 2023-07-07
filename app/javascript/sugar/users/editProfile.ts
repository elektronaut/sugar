import $ from "jquery";
import readyHandler from "../../lib/readyHandler";

readyHandler.ready(() => {
  $(".edit_user_profile").each(function () {
    const checkAdmin = function () {
      if ($("#user_admin:checked").val()) {
        $("#user_moderator").attr("checked", true).attr("disabled", true);
        $("#user_user_admin").attr("checked", true).attr("disabled", true);
      } else {
        $("#user_moderator").attr("disabled", false);
        $("#user_user_admin").attr("disabled", false);
      }
    };

    const checkUserStatus = function () {
      const status = $("#user_status").val();
      const disabled = !(status == "hiatus" || status == "time_out");
      $(".banned-until select").attr("disabled", disabled);
    };

    $("#user_status").change(checkUserStatus);
    checkAdmin();
    checkUserStatus();
  });
});
