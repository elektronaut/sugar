// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import $ from "jquery";

import Sugar from "./sugar";
window.Sugar = Sugar;

import "./sugar/exchanges/conversations";
import "./sugar/exchanges/newDiscussion";
import "./sugar/facebook";
import "./sugar/hotkeys";
import "./sugar/posts/buttons";
import "./sugar/posts/embeds";
import "./sugar/posts/newPosts";
import "./sugar/posts/preview";
import "./sugar/posts/submit";
import "./sugar/richText";
import "./sugar/search";
import "./sugar/style";
import "./sugar/tabs";
import "./sugar/timestamps";
import "./sugar/user";
import "./sugar/users/editProfile";

// React
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
ReactRailsUJS.getConstructor = (className) => Components[className];

$(() => Sugar.init());
