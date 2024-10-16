import { startPosts } from "./sugar/post";

type Icon = {
  name: string;
  image: string;
};

type SugarConfiguration = {
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
  }
};

export default Sugar;
