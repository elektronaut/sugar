import Exchange from "./Exchange";

export default Exchange.extend({
  paramRoot: "discussion",

  urlRoot: function () {
    return "/discussions";
  }
});
