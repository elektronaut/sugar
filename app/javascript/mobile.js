// Entry point for the build script in your package.json

// Rails
import Rails from "@rails/ujs";
Rails.start();

import Sugar from "./sugar";
window.Sugar = Sugar;

require("./sugar/facebook");
require("./sugar/posts/embeds");
require("./sugar/richText");
require("./sugar/timestamps");
require("./sugar/user");

require("./mobile/functions");
