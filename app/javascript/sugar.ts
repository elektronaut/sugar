import { startPosts } from "./sugar/post";

type Icon = {
  name: string;
  image: string;
};

type SugarConfiguration = {
  authToken: string;
  emoticons: Icon[];
  amazonAssociatesId?: string;
  currentUser?: UserAttributes;
  currentUserId?: number;
  preferredFormat?: string;
  uploads?: boolean;
};

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
