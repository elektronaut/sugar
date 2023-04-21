import $ from "jquery";
import Backbone from "backbone";

import Application from "./views/Application";

interface SugarConfiguration {
  authToken: string
}

const Sugar = {
  Configuration: {} as SugarConfiguration,

  stopwords: [
    "i", "a", "about", "an", "and", "are", "as", "at", "by", "for", "from",
    "has", "have", "how", "in", "is", "it", "la", "my", "of", "on", "or",
    "that", "the", "this", "to", "was", "what", "when", "where", "who",
    "will", "with", "the"
  ],

  init() {
    this.Application = new (Application as Backbone.View)() as Backbone.View;
  },

  extend(extension) {
    $.extend(Sugar, extension);
  },

  authToken(): string {
    return this.Configuration.authToken;
  }
};

export default Sugar;
