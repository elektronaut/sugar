export default class HtmlDecorator {
  blockquote(str) {
    return ["<blockquote>", str, "</blockquote>"];
  }

  bold(str) {
    return ["<b>", str, "</b>"];
  }

  code(str, language) {
    return ["```" + language + "\n", str, "\n```"];
  }

  emphasis(str) {
    return ["<i>", str, "</i>"];
  }

  image(url) {
    return ["<img src=\"", url, "\">"];
  }

  link(url, name) {
    return ["<a href=\"" + url + "\">", name, "</a>"];
  }

  quote(text, html, username, permalink) {
    let content = html.replace(/\n/g, "").replace(/<br[\s/]*>/g, "\n");
    var cite = `Posted by ${username}:`;
    if (permalink) {
      cite = `Posted by <a href="${permalink}">${username}</a>:`;
    }
    return [
      "",
      "<blockquote><cite>" + cite + "</cite> " + content + "</blockquote>" +
      "\n\n",
      ""
    ];
  }

  spoiler(str) {
    return ["<div class=\"spoiler\">", str, "</div>"];
  }
}
