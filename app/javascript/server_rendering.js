// React
import * as Components from "./components";
const ReactRailsUJS = require("react_ujs");
ReactRailsUJS.getConstructor = (className) => Components[className];
