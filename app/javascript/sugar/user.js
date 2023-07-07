import User from "../models/User";
import Sugar from "../sugar";

export function currentUser() {
  if (Sugar.Configuration.currentUser) {
    return new User(Sugar.Configuration.currentUser);
  } else {
    return null;
  }
}
