Sugar.Views.Post = Backbone.View.extend({
  el: $('div.post'),
  editing: false,

  events: {
    'click a.quote_post': 'quote',
    'click a.edit_post': 'edit'
  },

  initialize: function () {
    if ($(this.el).data('post_id')) {
      this.model = this.modelFromExistingElement();
    } else {
      this.model = new Sugar.Models.Post();
    }
  },

  modelFromExistingElement: function () {
    return new Sugar.Models.Post({
      id: $(this.el).data('post_id'),
      user_id: $(this.el).data('user_id'),
      exchange_id: $(this.el).data('exchange_id'),
      exchange_type: $(this.el).data('exchange_type'),
      body: this.stripWhitespace(this.$('.body .content').text())
    });
  },

  stripWhitespace: function (string) {
    return string.replace(/^[\s]*/, '').replace(/[\s]*$/, '')
  },

  render: function () {
    let view = this;
    this.$('.post_functions').each(function() {
      let currentUser = Sugar.getCurrentUser();
      var links = [];
      if (currentUser) {
        if (view.model.editableBy(currentUser)) {
          links.push('<a href="#" class="edit_post">Edit</a>');
        }
        links.push('<a href="#" class="quote_post">Quote</a>');
      }
      return $(this).html(links.join(' | '));
    });
    this.applyAmazonReferralCode();
    this.applySpoiler();
    this.embedGifvVideos();
    return this;
  },

  edit: function (event) {
    event.preventDefault();
    if (!this.editing) {
      this.$('.body').hide();
      $(this.el).append(
        "<div class=\"edit\"><span class=\"ticker\">Loading...</span></div>"
      );
      this.$('.edit').load(this.model.editUrl({ timestamp: true }), function() {
        $(Sugar).trigger('modified');
      });
      this.editing = true;
    }
  },

  quote: function (event) {
    event.preventDefault();
    var html, permalink, text, username;

    if ((window.getSelection != null) &&
        window.getSelection().containsNode(this.el, true)) {
      text = window.getSelection().toString();
      html = text;
    }

    if ((text == null) || text.trim() === "") {
      text = this.stripWhitespace(this.$('.body .content').text());
      html = this.stripWhitespace(this.$('.body .content').html());
    }

    if ($(this.el).hasClass('me_post')) {
      username = $(this.el).find('.body .poster').text();
      permalink = null;
    } else {
      username = $(this.el).find('.post_info .username a').text();
      permalink = $(this.el).find('.post_info .permalink')
                            .get()[0]
                            .href
                             .replace(/^https?:\/\/([\w\d\.:\-]*)/, '');
    }

    text = text.replace(/class="spoiler revealed"/g, 'class="spoiler"');
    html = html.replace(/class="spoiler revealed"/g, 'class="spoiler"');
    text = text.replace(/<img alt="([\w+-]+)" class="emoji"([^>]*)>/g,
                        ":$1:");
    html = html.replace(/<img alt="([\w+-]+)" class="emoji"([^>]*)>/g,
                        ":$1:");
    html = html.replace(/<(twitterwidget|iframe).*data-tweet-id="(\d+).*<\/(twitterwidget|iframe)>/g, 'https://twitter.com/statuses/$2');
    text = text.replace(/<(twitterwidget|iframe).*data-tweet-id="(\d+).*<\/(twitterwidget|iframe)>/g, 'https://twitter.com/statuses/$2');

    $(Sugar).trigger("quote", {
      username: username,
      permalink: permalink,
      text: text,
      html: html
    });
  },

  applySpoiler: function () {
    return $(this.el).find('.spoiler')
                     .click(function () { $(this).toggleClass('revealed') });
  },

  applyAmazonReferralCode: function () {
    let referralId = Sugar.Configuration.amazonAssociatesId;
    let exp = /https?:\/\/([\w\d\-\.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//

    if (referralId) {
      $(this.el).find('.body a').each(function() {
        let link = this;
        if (!$.data(link, 'amazon_associates_referral_id') &&
            link.href.match(exp)) {
          $.data(link, 'amazon_associates_referral_id', referralId);
          if (link.href.match(/(\?|&)tag=/)) {
            return;
          }
          link.href += link.href.match(/\?/) ? '&' : '?';
          link.href += 'tag=' + referralId;
        }
      });
    }
  },

  embedGifvVideos: function () {
    let testElem = window.videoTestElement ||
                   (window.videoTestElement = document.createElement("video"));

    let canPlay = (type) =>
      testElem.canPlayType && testElem.canPlayType(type);

    if (canPlay('video/webm') || canPlay('video/mp4')) {
      $(this.el).find("img").each(function() {
        if (this.src.match(/imgur\.com\/.*\.(gif)$/i)) {
          this.src += "v";
        }
        if (this.src.match(/\.gifv$/)) {
          let baseUrl = this.src.replace(/\.gifv$/, '');
          $(this).replaceWith(
            `<a href="${baseUrl}.gif"><video autoplay loop muted>` +
            `<source type="video/webm" src="${baseUrl}.webm">` +
            `<source type="video/mp4" src="${baseUrl}.mp4"></video></a>`
          );
        }
      });
    }
  }
});
