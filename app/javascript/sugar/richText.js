import $ from "jquery";
import Dropzone from "dropzone";
import Sugar from "../sugar";
import HtmlDecorator from "./HtmlDecorator";
import MarkdownDecorator from "./MarkdownDecorator";

import { csrfToken, putJson } from "../lib/request";

(function() {
  function getSelection(elem) {
    let { selectionStart, selectionEnd, value } = elem;
    return value.substr(selectionStart, (selectionEnd - selectionStart));
  }

  function replaceSelection(textarea, prefix, replacement, postfix) {
    let { selectionStart, selectionEnd, value } = textarea;

    textarea.value =
      value.substr(0, selectionStart) +
      prefix + replacement + postfix +
      value.substr(selectionEnd, value.length);

    textarea.focus({ preventScroll: true });
    textarea.setSelectionRange(
      selectionStart + prefix.length,
      selectionStart + prefix.length + replacement.length
    );
  }

  function undoEmbeds(html) {
    let elem = document.createElement("div");
    elem.innerHTML = html;
    Array.prototype.slice.call(
      elem.querySelectorAll("div.embed[data-oembed-url]")
    ).forEach(function (embed) {
      embed.parentNode.insertBefore(
        document.createTextNode(embed.dataset.oembedUrl),
        embed
      );
      embed.parentNode.removeChild(embed);
    });
    return elem.innerHTML;
  }

  function uploadBanner(file) {
    return "[Uploading \"" + file.name + "\"...]";
  }

  function startUpload(elem, file) {
    replaceSelection(elem, uploadBanner(file) + "\n", "", "");
  }

  function uploadError(response) {
    if (typeof(response) === "object" && response.error) {
      alert("There was an error uploading the image: " + response.error);
    }
  }

  function finishUpload(elem, file, response) {
    uploadError(response);
    if (response && response.embed) {
      $(elem).val(
        $(elem).val().replace(uploadBanner(file) + "\n", response.embed)
      );
    }
  }

  function failedUpload(elem, file, response) {
    uploadError(response);
    $(elem).val($(elem).val().replace(uploadBanner(file), ""));
  }

  function uploadImageFile(textarea, file, callback) {
    let reader = new FileReader();
    reader.onload = function () {
      startUpload(textarea, file);
      var formData = new FormData();
      formData.append("upload[file]", file);
      $.ajax({
        url: "/uploads.json",
        type: "POST",
        headers: { "X-CSRF-Token": csrfToken() },
        data: formData,
        processData: false,
        contentType: false,
        success: (json) => finishUpload(textarea, file, json),
        error: (r) => failedUpload(textarea, file, r.responseJSON)
      });
      if (callback) {
        callback();
      }
    };
    reader.readAsDataURL(file);
  }

  function uploadImage(textarea) {
    let fileInput = $(
      "<input type=\"file\" name=\"file\" " +
      "accept=\"image/gif, image/png, image/jpeg, image/webp\" " +
      "style=\"display: none;\"/>"
    );
    fileInput.insertBefore(textarea);
    fileInput.get(0).addEventListener("change", function () {
      let file = fileInput.get(0).files[0];
      uploadImageFile(textarea, file, () => {
        fileInput.remove();
      });
    }, false);
    fileInput.click();
  }

  function bindUploads(elem) {
    const dropzone = new Dropzone(elem, {
      url: "/uploads.json",
      paramName: "upload[file]",
      headers: { "X-CSRF-Token": csrfToken() },
      acceptedFiles: "image/jpeg,image/png,image/gif,image/tiff,image/webp",
      clickable: false,
      createImageThumbnails: false
    });

    dropzone.on("addedfile", file => startUpload(elem, file));
    dropzone.on("success",
                file => finishUpload(elem, file, JSON.parse(file.xhr.responseText)));
    dropzone.on("error", (file, message) => failedUpload(elem, file, message));

    elem.addEventListener("paste", (evt) => {
      const items = (evt.clipboardData || evt.originalEvent.clipboardData).items;
      for (var i in items) {
        const item = items[i];
        if (item.kind == "file" && item.type.match(/^image\//)) {
          uploadImageFile(elem, item.getAsFile());
        }
      }
    });
  }

  Sugar.RichTextArea = function(textarea) {
    if (textarea.richtext) {
      return this;
    }
    textarea.richtext = true;

    let decorator = () => new MarkdownDecorator;
    let formatButton = $("<li class=\"formatting\"><a>Markdown</a></li>");
    let emojiBar = $("<ul class=\"emojiBar clearfix\"></ul>");
    let icons = Sugar.Configuration.emoticons;

    var formats = ["markdown"];
    var format = undefined;

    $("<ul class=\"richTextToolbar clearfix\"></ul>")
      .append(formatButton)
      .insertBefore(textarea);
    emojiBar.insertBefore(textarea);
    emojiBar.hide();

    if ($(textarea).data("formats")) {
      formats = $(textarea).data("formats").split(" ");
    }

    if ($(textarea).data("format-binding")) {
      format = $(textarea).closest("form")
                          .find($(textarea)
                          .data("format-binding"))
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
        decorator = () => new MarkdownDecorator;
      } else if (format === "html") {
        label = "HTML";
        decorator = () => new HtmlDecorator;
      }

      formatButton.find("a").html(label);
      if ($(textarea).data("format-binding")) {
        $(textarea).closest("form")
                   .find($(textarea)
                   .data("format-binding"))
                   .val(format);
      }

      if ($(textarea).data("remember-format") && !skipUpdate) {
        if (Sugar.Configuration.currentUserId) {
          putJson(`/users/${Sugar.Configuration.currentUserId}.json`,
                  { user: { preferred_format: newFormat }});
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
        `<i class="fa fa-${className}"></i></a>`
      );
      link.click(() => performAction(callback));
      $("<li class=\"button\"></li>").append(link).insertBefore(formatButton);
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
    addButton("Image", "picture-o", imageTag);
    addButton("Upload Image", "upload", uploadImageAction);
    addButton("Block Quote", "quote-left", blockquote);
    addButton("Code", "code", code);
    addButton("Spoiler", "warning", spoiler);
    addButton("Emoticons", "smile-o", showEmojiBar);

    addHotkey("b", bold);
    addHotkey("i", italic);
    addHotkey("k", link);
    addHotkey("enter", submit);

    $(Sugar).on("quote", function(event, data) {
      let [prefix, replacement, postfix] = decorator().quote(
        data.text,
        undoEmbeds(data.html),
        data.username,
        data.permalink
      );
      replaceSelection(textarea, prefix, replacement, postfix);
      textarea.scrollTop = textarea.scrollHeight;
    });

    function addEmojiButton(name, image) {
      let link = $(
        `<a title="${name}"><img alt="${name}" class="emoji" ` +
        `src="${image}" width="16" height="16"></a>`
      );
      link.click(function() {
        replaceSelection(textarea, "", ":" + name + ": ", "");
      });
      $("<li class=\"button\"></li>").append(link).appendTo(emojiBar);
    }

    for (var j = 0; j < icons.length; j++) {
      addEmojiButton(icons[j].name, icons[j].image);
    }

    if (Sugar.Configuration.uploads) {
      bindUploads(textarea, decorator);
    }
  };

  $(Sugar).bind("ready modified", function() {
    $("textarea.rich").each(function() {
      new Sugar.RichTextArea(this);
    });
  });
}).call(this);
