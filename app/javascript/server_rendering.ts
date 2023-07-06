// By default, this pack is loaded for server-side rendering.
// It must expose react_ujs as `ReactRailsUJS` and prepare a require context.
import { FC } from "react";
import * as Components from "./components";
import ReactRailsUJS from "react_ujs";
declare class ReactRailsUJS {
  getConstructor: (name: string) => FC;
}
ReactRailsUJS.getConstructor = (className: string) =>
  Components[className] as FC;
