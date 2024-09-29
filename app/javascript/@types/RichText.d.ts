declare namespace RichText {
  type Element = HTMLTextAreaElement & { richtext: boolean };
  type Replacement = [string, string, string];
  type Action = (str?: string) => Replacement | void;
  type Decoration = (str: string) => Replacement;

  interface Decorator {
    blockquote: Decoration;
    bold: Decoration;
    emphasis: Decoration;
    image: Decoration;
    spoiler: Decoration;
    code: (string: string, lang: string) => Replacement;
    link: (string: string, name: string) => Replacement;
    quote: (html: string, username: string, link: string) => Replacement;
  }
}
