import { startPosts } from "./sugar/post";

interface SugarConfiguration {
  authToken: string;
  currentUser?: UserAttributes;
}

const Sugar = {
  Configuration: {} as SugarConfiguration,

  init() {
    startPosts();
  },

  authToken(): string {
    return this.Configuration.authToken;
  }
};

export default Sugar;
