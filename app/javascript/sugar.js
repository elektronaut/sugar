import $ from "jquery";

import Application from "./views/Application";

const Sugar = {
  Configuration: {},

  stopwords: [
    "i", "a", "about", "an", "and", "are", "as", "at", "by", "for", "from",
    "has", "have", "how", "in", "is", "it", "la", "my", "of", "on", "or",
    "that", "the", "this", "to", "was", "what", "when", "where", "who",
    "will", "with", "the"
  ],

  init() {
    this.Application = new Application();
  },

  extend(extension) {
    $.extend(Sugar, extension);
  },

  log() {
    if (this.Configuration.debug && (typeof console !== "undefined")) {
      if (arguments.length === 1) {
        return console.log(arguments[0]);
      } else {
        return console.log(arguments);
      }
    }
  },

  authToken() {
    return this.Configuration.authToken;
  }
};

export default Sugar;
