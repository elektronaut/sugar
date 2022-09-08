// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import $ from "jquery";

import Sugar from "./sugar";
window.Sugar = Sugar;

require("./sugar/exchanges/conversations");
require("./sugar/exchanges/newDiscussion");
require("./sugar/facebook");
require("./sugar/hotkeys");
require("./sugar/posts/buttons");
require("./sugar/posts/embeds");
require("./sugar/posts/newPosts");
require("./sugar/posts/preview");
require("./sugar/posts/submit");
require("./sugar/richText");
require("./sugar/search");
require("./sugar/style");
require("./sugar/tabs");
require("./sugar/timestamps");
require("./sugar/user");
require("./sugar/users/editProfile");

$(() => Sugar.init());
