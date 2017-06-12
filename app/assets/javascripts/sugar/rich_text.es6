(function() {
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

    youtube(url) {
      return ["!y[Video title](", url, ")"];
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

  class HtmlDecorator {
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

    youtube(url) {
      let regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/;
      let match = url.match(regExp);
      if (match && match[7].length === 11) {
        let code = match[7];
        return [
          "<iframe src=\"https://www.youtube.com/embed/",
          code,
          "\" frameborder=\"0\" allowfullscreen></iframe>"
        ];
      } else {
        return ["", "", ""];
      }
    }

    link(url, name) {
      return ["<a href=\"" + url + "\">", name, "</a>"];
    }

    quote(text, html, username, permalink) {
      let content = html.replace(/\n/g, "").replace(/<br[\s\/]*>/g, "\n");
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

  let getSelection = (elem) =>
    $(elem).getSelection().text;

  let getSelectionRange = (elem) => {
    if (typeof elem.selectionStart !== "undefined") {
      return [elem.selectionStart, elem.selectionEnd];
    } else {
      return [0, 0];
    }
  };

  let setSelectionRange = (elem, start, end) => {
    if (typeof elem.setSelectionRange !== "undefined") {
      return elem.setSelectionRange(start, end);
    }
  };

  let adjustSelection = (elem, callback) => {
    let selectionLength = getSelection(elem).length;
    let [start, end] = getSelectionRange(elem);
    let [replacementLength, prefixLength] = callback();
    let newEnd = end + (replacementLength - selectionLength) + prefixLength;
    let newStart = start === end ? newEnd : start + prefixLength;
    return setSelectionRange(elem, newStart, newEnd);
  };

  let replaceSelection = (elem, prefix, replacement, postfix) => {
    return adjustSelection(elem, () => {
      $(elem).replaceSelection(prefix + replacement + postfix);
      $(elem).focus();
      return [replacement.length, prefix.length];
    });
  };

  let uploadBanner = (file) =>
    "[Uploading \"" + file.name + "\"...]";

  let startUpload = (elem, file) =>
    replaceSelection(elem, "", uploadBanner(file) + "\n", "");

  let uploadError = (response) => {
    if (typeof(response) === "object" && response.error) {
      alert("There was an error uploading the image: " + response.error);
    }
  }

  let finishUpload = (elem, file, response) => {
    uploadError(response);
    if (response.embed) {
      $(elem).val(
        $(elem).val().replace(uploadBanner(file) + "\n", response.embed)
      );
    }
  };

  let failedUpload = (elem, file, response) => {
    console.log(typeof(response));
    console.log(response);
    uploadError(response);
    $(elem).val($(elem).val().replace(uploadBanner(file), ""));
  }

  let uploadImage = (textarea) => {
    let fileInput = $(
      "<input type=\"file\" name=\"file\" " +
      "accept=\"image/gif, image/png, image/jpeg\" " +
      "style=\"display: none;\"/>"
    );
    fileInput.insertBefore(textarea);
    fileInput.get(0).addEventListener('change', function () {
      let file = fileInput.get(0).files[0];
      let reader = new FileReader();
      reader.onload = function () {
        startUpload(textarea, file);
        var formData = new FormData();
        formData.append("upload[file]", file);
        $.ajax({
          url: "/uploads.json",
          type: "POST",
          data: formData,
          processData: false,
          contentType: false,
          success: (json) => finishUpload(textarea, file, json),
          error: (r) => failedUpload(textarea, file, r.responseJSON)
        });
        fileInput.remove();
      }
      reader.readAsDataURL(file);
    }, false)
    fileInput.click();
  };

  let bindUploads = (elem) => {
    $(elem).filedrop({
      allowedfiletypes: ['image/jpeg', 'image/png', 'image/gif', 'image/tiff'],
      maxfiles: 25,
      maxfilesize: 20,
      paramname: "upload[file]",
      url: "/uploads.json",
      headers: { "X-CSRF-Token": Sugar.authToken() },
      uploadStarted: (i, file) => startUpload(elem, file),
      uploadFinished: (i, file, response) => finishUpload(elem, file, response),
      error: (error, file, i, status) => failedUpload(elem, file, error)
    });
  };

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

    if ($(textarea).data('formats')) {
      formats = $(textarea).data('formats').split(" ");
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

    let setFormat = (newFormat, skipUpdate) => {
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
        let currentUser = Sugar.getCurrentUser();
        if (currentUser) {
          currentUser.save("preferred_format", newFormat, { patch: true });
        }
      }
    };

    let nextFormat = () =>
      setFormat(formats[(formats.indexOf(format) + 1) % formats.length]);

    setFormat(format, true);

    formatButton.find("a").click(() => nextFormat());

    let addButton = (name, className, callback) => {
      let link = $(
        `<a title="${name}" class="${className}">` +
        `<i class="fa fa-${className}"></i></a>`
      );
      link.click(function() {
        let result = callback(getSelection(textarea));
        if (result) {
          let [prefix, replacement, postfix] = result;
          replaceSelection(textarea, prefix, replacement, postfix);
        }
      });
      $("<li class=\"button\"></li>").append(link).insertBefore(formatButton);
    };

    addButton("Bold", "bold", (s) => decorator().bold(s));
    addButton("Italics", "italic", (s) => decorator().emphasis(s));

    addButton("Link", "link", (s) => {
      let name = s.length > 0 ? s : "Link text";
      var url = prompt("Enter link URL", "");
      url = url.length > 0 ? url : "http://example.com/";
      url = url.replace(/^(?!(f|ht)tps?:\/\/)/, 'http://');
      return decorator().link(url, name);
    });

    addButton("Image", "picture-o", (s) => {
      let url = s.length > 0 ? s : prompt("Enter image URL", "");
      return !!url ? decorator().image(url) : false;
    });

    addButton("Upload Image", "upload", (s) => {
      uploadImage(textarea);
    });

    addButton("Youtube", "youtube", (s) => {
      let url = s.length > 0 ? s : prompt("Enter video URL", "");
      return decorator().youtube(url);
    });

    addButton("Block Quote", "quote-left", (s) => decorator().blockquote(s));

    addButton("Code", "code", (selection) => {
      let lang = prompt(
        "Enter language (leave blank for no syntax highlighting)",
        ""
      );
      return decorator().code(selection, lang);
    });

    addButton("Spoiler", "warning", (s) => decorator().spoiler(s));

    addButton("Emoticons", "smile-o", (selection) => {
      emojiBar.slideToggle(100);
      return ["", selection, ""];
    });

    $(Sugar).on("quote", function(event, data) {
      let [prefix, replacement, postfix] = decorator().quote(
        data.text,
        data.html,
        data.username,
        data.permalink
      );
      replaceSelection(textarea, prefix, replacement, postfix);
      textarea.scrollTop = textarea.scrollHeight;
    });

    let addEmojiButton = (name, image) => {
      let link = $(
        `<a title="${name}"><img alt="${name}" class="emoji" ` +
        `src="${image}" width="16" height="16"></a>`
      );
      link.click(function() {
        replaceSelection(textarea, "", ":" + name + ": ", "");
      });
      $("<li class=\"button\"></li>").append(link).appendTo(emojiBar);
    };


    for (var j = 0; j < icons.length; j++) {
      addEmojiButton(icons[j].name, icons[j].image);
    }

    if (Sugar.Configuration.uploads) {
      bindUploads(textarea, decorator);
    }
  };

  $(Sugar).bind('ready modified', function() {
    $('textarea.rich').each(function() {
      new Sugar.RichTextArea(this);
    });
  });
}).call(this);
