import Exchange from "./Exchange";

export default Exchange.extend({
  paramRoot: "conversation",

  urlRoot: function () {
    return "/conversations";
  }
});
