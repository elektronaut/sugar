class MarkdownDecorator {
  blockquote(str) {
    return ["", str.split("\n").map(l => `> ${l}`).join("\n"), ""];
  }

  bold(str) {
    return ["**", str, "**"];
  }

  code(str, language) {
    return ["```" + language + "\n", str, "\n```"];
  }

  emphasis(str) {
    return ["_", str, "_"];
  }

  image(url) {
    return ["![](", url, ")"];
  }

  link(url, name) {
    return ["[", name, "](" + url + ")"];
  }

  quote(text, html, username, permalink) {
    var cite;
    let wrapInBlockquote = (str) =>
      str.split("\n").map(l => `> ${l}`).join("\n");
    var cite = `Posted by ${username}:`;
    if (permalink) {
      cite = `Posted by [${username}](${permalink}):`;
    }
    return [
      "",
      wrapInBlockquote("<cite>" + cite + "</cite>\n\n" + html) + "\n\n",
      ""
    ];
  };

  spoiler(str) {
    return ["<div class=\"spoiler\">", str, "</div>"];
  }
}
