import { startPosts } from "./sugar/post";

interface Icon {
  name: string;
  image: string;
}

interface SugarConfiguration {
  authToken: string;
  emoticons: Icon[];
  currentUser?: UserAttributes;
  preferredFormat?: string;
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
