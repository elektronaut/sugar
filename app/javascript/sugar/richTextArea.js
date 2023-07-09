import $ from "jquery";
import Sugar from "../sugar";

import HtmlDecorator from "./richTextArea/HtmlDecorator";
import MarkdownDecorator from "./richTextArea/MarkdownDecorator";
import { getSelection, replaceSelection } from "./richTextArea/selection";
import { bindUploads, uploadImage } from "./richTextArea/upload";

import { putJson } from "../lib/request";

function undoEmbeds(html) {
  let elem = document.createElement("div");
  elem.innerHTML = html;
  Array.prototype.slice
    .call(elem.querySelectorAll("div.embed[data-oembed-url]"))
    .forEach(function (embed) {
      embed.parentNode.insertBefore(
        document.createTextNode(embed.dataset.oembedUrl),
        embed
      );
      embed.parentNode.removeChild(embed);
    });
  return elem.innerHTML;
}

export default function richTextArea(textarea) {
  if (textarea.richtext) {
    return this;
  }
  textarea.richtext = true;

  let decorator = () => new MarkdownDecorator();
  let formatButton = $('<li class="formatting"><a>Markdown</a></li>');
  let emojiBar = $('<ul class="emojiBar clearfix"></ul>');
  let icons = Sugar.Configuration.emoticons;

  var formats = ["markdown"];
  var format = undefined;

  $('<ul class="richTextToolbar clearfix"></ul>')
    .append(formatButton)
    .insertBefore(textarea);
  emojiBar.insertBefore(textarea);
  emojiBar.hide();

  if ($(textarea).data("formats")) {
    formats = $(textarea).data("formats").split(" ");
  }

  if ($(textarea).data("format-binding")) {
    format = $(textarea)
      .closest("form")
      .find($(textarea).data("format-binding"))
      .val();
  }
  if ($(textarea).data("remember-format")) {
    if (Sugar.Configuration.preferredFormat) {
      format = Sugar.Configuration.preferredFormat;
    }
  }
  format || (format = formats[0]);

  function setFormat(newFormat, skipUpdate) {
    var label;
    format = newFormat;

    if (format === "markdown") {
      label = "Markdown";
      decorator = () => new MarkdownDecorator();
    } else if (format === "html") {
      label = "HTML";
      decorator = () => new HtmlDecorator();
    }

    formatButton.find("a").html(label);
    if ($(textarea).data("format-binding")) {
      $(textarea)
        .closest("form")
        .find($(textarea).data("format-binding"))
        .val(format);
    }

    if ($(textarea).data("remember-format") && !skipUpdate) {
      if (Sugar.Configuration.currentUserId) {
        putJson(`/users/${Sugar.Configuration.currentUserId}.json`, {
          user: { preferred_format: newFormat }
        });
      }
    }
  }

  function nextFormat() {
    return setFormat(formats[(formats.indexOf(format) + 1) % formats.length]);
  }

  setFormat(format, true);

  formatButton.find("a").click(() => nextFormat());

  function performAction(callback) {
    let result = callback(getSelection(textarea));
    if (result) {
      let [prefix, replacement, postfix] = result;
      replaceSelection(textarea, prefix, replacement, postfix);
    }
  }

  function addButton(name, className, callback) {
    let link = $(
      `<a title="${name}" class="${className}">` +
        `<i class="fa-solid fa-${className}"></i></a>`
    );
    link.click(() => performAction(callback));
    $('<li class="button"></li>').append(link).insertBefore(formatButton);
  }

  function addHotkey(hotkey, callback) {
    textarea.addEventListener("keydown", (evt) => {
      var key;
      if (evt.which >= 65 && evt.which <= 90) {
        key = String.fromCharCode(evt.keyCode).toLowerCase();
      } else if (evt.keyCode === 13) {
        key = "enter";
      }

      if ((evt.metaKey || evt.ctrlKey) && key === hotkey) {
        evt.preventDefault();
        performAction(callback);
      }
    });
  }

  const bold = (s) => decorator().bold(s);
  const italic = (s) => decorator().emphasis(s);
  const blockquote = (s) => decorator().blockquote(s);
  const spoiler = (s) => decorator().spoiler(s);

  const link = (s) => {
    let name = s.length > 0 ? s : "Link text";
    var url = prompt("Enter link URL", "");
    url = url.length > 0 ? url : "http://example.com/";
    url = url.replace(/^(?!(f|ht)tps?:\/\/)/, "http://");
    return decorator().link(url, name);
  };

  const imageTag = (s) => {
    let url = s.length > 0 ? s : prompt("Enter image URL", "");
    return url ? decorator().image(url) : false;
  };

  const uploadImageAction = () => uploadImage(textarea);

  const code = (selection) => {
    let lang = prompt(
      "Enter language (leave blank for no syntax highlighting)",
      ""
    );
    return decorator().code(selection, lang);
  };

  const showEmojiBar = (selection) => {
    emojiBar.slideToggle(100);
    return ["", selection, ""];
  };

  const submit = () => {
    $(textarea).closest("form").submit();
  };

  addButton("Bold", "bold", bold);
  addButton("Italics", "italic", italic);
  addButton("Link", "link", link);
  addButton("Image", "image", imageTag);
  addButton("Upload Image", "upload", uploadImageAction);
  addButton("Block Quote", "quote-left", blockquote);
  addButton("Code", "code", code);
  addButton("Spoiler", "warning", spoiler);
  addButton("Emoticons", "face-smile", showEmojiBar);

  addHotkey("b", bold);
  addHotkey("i", italic);
  addHotkey("k", link);
  addHotkey("enter", submit);

  document.addEventListener("quote", (event) => {
    let [prefix, replacement, postfix] = decorator().quote(
      undoEmbeds(event.detail.html),
      event.detail.username,
      event.detail.permalink
    );
    replaceSelection(textarea, prefix, replacement, postfix);
    textarea.scrollTop = textarea.scrollHeight;
  });

  function addEmojiButton(name, image) {
    let link = $(
      `<a title="${name}"><img alt="${name}" class="emoji" ` +
        `src="${image}" width="16" height="16"></a>`
    );
    link.click(function () {
      replaceSelection(textarea, "", ":" + name + ": ", "");
    });
    $('<li class="button"></li>').append(link).appendTo(emojiBar);
  }

  for (var j = 0; j < icons.length; j++) {
    addEmojiButton(icons[j].name, icons[j].image);
  }

  if (Sugar.Configuration.uploads) {
    bindUploads(textarea, decorator);
  }
}

export function applyRichTextArea() {
  $("textarea.rich").each(function () {
    richTextArea(this);
  });
}
