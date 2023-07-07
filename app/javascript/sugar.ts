import Backbone from "backbone";

import Application from "./views/Application";

interface SugarConfiguration {
  authToken: string;
}

const Sugar = {
  Configuration: {} as SugarConfiguration,

  init() {
    this.Application = new (Application as Backbone.View)() as Backbone.View;
  },

  authToken(): string {
    return this.Configuration.authToken;
  }
};

export default Sugar;
