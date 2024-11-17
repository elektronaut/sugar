// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import Sugar from "./sugar";
declare const window: Window & {
  Sugar: typeof Sugar;
};
window.Sugar = Sugar;

import readyHandler from "./lib/readyHandler";
import { applyRichTextArea } from "./sugar/richTextArea";

import "./sugar/embeds";
import "./sugar/referrals";
import "./sugar/timestamps";

import "./mobile/functions";

readyHandler.start(() => {
  Sugar.init();
  applyRichTextArea();
});

// React
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
ReactRailsUJS.getConstructor = (className: string) =>
  Components[className] as React.FC;
