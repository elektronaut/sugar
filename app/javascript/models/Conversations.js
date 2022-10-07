import Backbone from "backbone";
import Conversation from "./Conversation";

export default Backbone.Collection.extend({
  model: Conversation,
  url: "/conversations"
});
