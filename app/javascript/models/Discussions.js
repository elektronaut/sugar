import Backbone from "backbone";
import Discussion from "./Discussion";

export default Backbone.Collection.extend({
  model: Discussion,
  url: "/discussions"
});
