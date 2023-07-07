// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import Sugar from "./sugar";
window.Sugar = Sugar;

import readyHandler from "./lib/readyHandler";
import { applyRichTextArea } from "./sugar/richTextArea";

import "./sugar/facebook";
import "./sugar/posts/embeds";
import "./sugar/timestamps";

import "./mobile/functions";

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
