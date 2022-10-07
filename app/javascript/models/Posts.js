import Backbone from "backbone";
import Post from "./Post";

export default Backbone.Collection.extend({
  model: Post,
  url: "/posts"
});
