import Backbone from "backbone";
import User from "./User";

export default Backbone.Collection.extend({
  model: User,
  url: "/users"
});
