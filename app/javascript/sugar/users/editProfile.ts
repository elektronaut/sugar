import $ from "jquery";
import readyHandler from "../../lib/readyHandler";

readyHandler.ready(() => {
  if (document.querySelector(".edit_user_profile")) {
    const checkAdmin = function () {
      if ($("#user_admin:checked").val()) {
        $("#user_moderator").prop("checked", true).prop("disabled", true);
        $("#user_user_admin").prop("checked", true).prop("disabled", true);
      } else {
        $("#user_moderator").prop("disabled", false);
        $("#user_user_admin").prop("disabled", false);
      }
    };

    const checkUserStatus = function () {
      const status = $("#user_status").val();
      const disabled = !(status == "hiatus" || status == "time_out");
      $(".banned-until select").prop("disabled", disabled);
    };

    $("#user_status").change(checkUserStatus);
    checkAdmin();
    checkUserStatus();
  }
});
