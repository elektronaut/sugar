export default class HtmlDecorator {
  blockquote(str: string) {
    return ["<blockquote>", str, "</blockquote>"];
  }

  bold(str: string) {
    return ["<b>", str, "</b>"];
  }

  code(str: string, language: string) {
    return ["```" + language + "\n", str, "\n```"];
  }

  emphasis(str: string) {
    return ["<i>", str, "</i>"];
  }

  image(url: string) {
    return ['<img src="', url, '">'];
  }

  link(url: string, name: string) {
    return ['<a href="' + url + '">', name, "</a>"];
  }

  quote(text: string, html: string, username: string, permalink: string) {
    const content = html.replace(/\n/g, "").replace(/<br[\s/]*>/g, "\n");
    let cite = `Posted by ${username}:`;
    if (permalink) {
      cite = `Posted by <a href="${permalink}">${username}</a>:`;
    }
    return [
      "<blockquote><cite>" +
        cite +
        "</cite> " +
        content +
        "</blockquote>" +
        "\n\n",
      "",
      ""
    ];
  }

  spoiler(str: string) {
    return ['<div class="spoiler">', str, "</div>"];
  }
}
