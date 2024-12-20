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

import "./sugar/exchanges/newDiscussion";
import "./sugar/hotkeys";
import "./sugar/embeds";
import "./sugar/posts/buttons";
import "./sugar/posts/newPosts";
import "./sugar/posts/preview";
import "./sugar/posts/submit";
import "./sugar/referrals";
import "./sugar/search";
import "./sugar/style";
import "./sugar/timestamps";
import "./sugar/users/editProfile";

readyHandler.start(() => {
  Sugar.init();
  applyRichTextArea();
});

// React
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
ReactRailsUJS.getConstructor = (className: string) =>
  Components[className] as React.FC;
