// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import Sugar from "./sugar";
window.Sugar = Sugar;

import readyHandler from "./lib/readyHandler";
import { applyRichTextArea } from "./sugar/richTextArea";

import "./sugar/exchanges/conversations";
import "./sugar/exchanges/newDiscussion";
import "./sugar/facebook";
import "./sugar/hotkeys";
import "./sugar/posts/buttons";
import "./sugar/posts/embeds";
import "./sugar/posts/newPosts";
import "./sugar/posts/preview";
import "./sugar/posts/submit";
import "./sugar/search";
import "./sugar/style";
import "./sugar/timestamps";
import "./sugar/users/editProfile";

readyHandler.start(() => {
  Sugar.init();
  applyRichTextArea();
});

// React
import { FC } from "react";
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
declare class ReactRailsUJS {
  getConstructor: (name: string) => FC;
}
ReactRailsUJS.getConstructor = (className: string) =>
  Components[className] as FC;