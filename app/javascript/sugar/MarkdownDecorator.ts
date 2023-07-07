export default class MarkdownDecorator {
  blockquote(str: string) {
    return [
      "",
      str
        .split("\n")
        .map((l) => `> ${l}`)
        .join("\n"),
      ""
    ];
  }

  bold(str: string) {
    return ["**", str, "**"];
  }

  code(str: string, language: string) {
    return ["```" + language + "\n", str, "\n```"];
  }

  emphasis(str: string) {
    return ["_", str, "_"];
  }

  image(url: string) {
    return ["![](", url, ")"];
  }

  link(url: string, name: string) {
    return ["[", name, "](" + url + ")"];
  }

  quote(text: string, html: string, username: string, permalink: string) {
    const wrapInBlockquote = (str: string) =>
      str
        .split("\n")
        .map((l) => `> ${l}`)
        .join("\n");
    let cite = `Posted by ${username}:`;
    if (permalink) {
      cite = `Posted by [${username}](${permalink}):`;
    }
    return [
      wrapInBlockquote("<cite>" + cite + "</cite>\n\n" + html) + "\n\n",
      "",
      ""
    ];
  }

  spoiler(str: string) {
    return ['<div class="spoiler">', str, "</div>"];
  }
}