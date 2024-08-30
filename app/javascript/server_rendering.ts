// By default, this pack is loaded for server-side rendering.
// It must expose react_ujs as `ReactRailsUJS` and prepare a require context.
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
ReactRailsUJS.getConstructor = (className: string) =>
  Components[className] as React.FC;
