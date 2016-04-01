//= require jquery
//= require jquery_ujs
//= require underscore
//= require backbone

//= require vendor/jquery.libraries
//= require vendor/jquery.timeago
//= require vendor/jquery.filedrop

//= require backbone/sugar
//= require sugar
//= require sugar/facebook
//= require sugar/rich_text
//= require sugar/timestamps
//= require sugar/user

window.toggleNavigation = function () {
  $("#navigation").toggleClass("active");
  return false;
};

// Amazon Associates referral code
function addReferralIds() {
  let referralId = Sugar.Configuration.amazonAssociatesId;
  let ptrn = /https?:\/\/([\w\d\-\.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//

  let needsReferral = function (link) {
    return (
      !$.data(link, 'amazon_associates_referral_id') &&
      link.href.match(ptrn)
    );
  }

  if (referralId) {
    $('.post .body a').each(function () {
      let link = this;
      if (needsReferral(link)) {
        $.data(link, 'amazon_associates_referral_id', referralId);
        if (link.href.match(/(\?|&)tag=/)) {
          return;
        }

        link.href += link.href.match(/\?/) ? '&' : '?';
        link.href += 'tag=' + referralId;
      }
    });
  }
}

function resizeYoutube() {
  $(
    "embed[src*=\"youtube.com\"], " +
    "iframe[src*=\"youtube.com\"], " +
    "iframe[src*=\"vimeo.com\"]"
  ).each(function () {
    let maxWidth = $(this).closest('.body').width();

    if (!this.proportions) {
      this.proportions = ($(this).width() / $(this).height());
    }
    this.width = maxWidth;
    this.height = maxWidth / this.proportions;
  });
};

function wrapInstagramEmbeds() {
  $(".post .body iframe[src*='//instagram.com/']").each(function () {
    if (!$(this).parent().hasClass("instagram-wrapper")) {
      $(this).wrap('<div class="instagram-wrapper">');
    }
  });
};

function getImageSize(img) {
  if (!img.originalWidth) {
    if ($(img).attr('width')) {
      img.originalWidth = parseInt($(img).attr('width'), 10);
    } else if ($(img).width() > 0) {
      img.originalWidth = $(img).width();
    }
  }

  if (!img.originalHeight) {
    if ($(img).attr('height')) {
      img.originalHeight = parseInt($(img).attr('height'), 10);
    } else if ($(img).height() > 0) {
      img.originalHeight = $(img).height();
    }
  }

  return (
    img.originalWidth &&
    img.originalWidth > 0 &&
    img.originalHeight &&
    img.originalHeight > 0
  );
};

function resizeImage(img) {
  var maxWidth = $(document).width();
  if ($(img).parent().width() < maxWidth) {
    maxWidth = $(img).parent().width();
  }
  if (!img.proportions) {
    img.proportions = img.originalWidth / img.originalHeight;
  }
  if (img.originalWidth > maxWidth) {
    $(img).css({
      width:  maxWidth + 'px',
      height: parseInt((maxWidth / img.proportions), 10) + 'px'
    });
  }
};

function resizeImages() {
  $(".post .body img").each(function () {
    var img = this;
    if (getImageSize(img)) {
      return resizeImage(img);
    } else {
      if (!img.resizeInterval) {
        img.resizeInterval = setInterval(function () {
          if (getImageSize(img)) {
            clearInterval(img.resizeInterval);
            resizeImage(img);
          }
        }, 500);
      }
    }
  });
};

function parsePost(body) {
  // Embed Instagram photos directly when a share URL is pasted
  body = body.replace(
    /\b(https?:\/\/instagram\.com\/p\/[^\/]+\/)/g,
    function (match, url) {
      return '<a href="' + url + '">' +
             '<img width="612" height="612" src="' + url + 'media?size=l">' +
             '</a>';
    }
  );
  // Embed Twitter statuses directly when a URL is pasted
  body = body.replace(
    /^https?:\/\/(mobile\.)?twitter\.com\/([\w\d_]+)\/status(es)?\/([\d]+)/gm,
    function (match, mobile, username, statuses, id) {
      return '<blockquote class="twitter-tweet" lang="en">' +
             '<a href="https://twitter.com/' + username + '/statuses/' +
             id + '">https://twitter.com/' + username + '/statuses/' + id +
             '</a></blockquote>';
    }
  );
  return body;
};

$(document).ready(function () {
  let updateLayout = function () {
    if ((window.orientation != null)) {
      if (window.orientation === 90 || window.orientation === -90) {
        document.body.setAttribute("orient", "landscape");
      } else {
        document.body.setAttribute("orient", "portrait");
      }
    }
    resizeYoutube();
    resizeImages();
  };

  $(window).bind('orientationchange', updateLayout);
  $(window).bind('resize', updateLayout);
  updateLayout();

  $('.toggle-navigation').click(function () {
    window.toggleNavigation();
  });

  // Open images when clicked
  $('.post .body img').click(function () {
    document.location = this.src;
  });

  // Larger click targets on discussion overview
  $(".discussions .discussion h2 a").each(function () {
    var url = this.href;
    $(this.parentNode.parentNode).click(function () {
      document.location = url;
    });
  });

  // Scroll past the Safari chrome
  if (!document.location.toString().match(/\#/)) {
    setTimeout(scrollTo, 100, 0, 1);
  }

  // Search mode
  $("#search_mode").change(function () {
    this.parentNode.action = this.value;
  });

  // Post quoting
  $(".post .functions a.quote_post").click(function () {
    let stripWhitespace = function (string) {
      return string.replace(/^[\s]*/, '').replace(/[\s]*$/, '');
    };

    let post = $(this).closest(".post");
    let username = post.find(".post_info .username a").text();
    let permalink = post.find(".post_info .permalink a")
                        .get()[0]
                        .href
                        .replace(/^https?:\/\/([\w\d\.:\-]*)/, "");

    var text = stripWhitespace(post.find('.body').text());
    var html = stripWhitespace(post.find('.body').html());

    // Hide spoilers
    text = text.replace(/class="spoiler revealed"/g, 'class="spoiler"');
    html = html.replace(/class="spoiler revealed"/g, 'class="spoiler"');

    $(Sugar).trigger("quote", {
      username: username,
      permalink: permalink,
      text: text,
      html: html
    });

    return false;
  });

  // Posting
  $('form.new_post').submit(function () {
    let body = $(this).find('#compose-body');
    body.val(parsePost(body.val()));
    return true;
  });

  // Spoiler tags
  $(".spoiler").click(function () {
    $(this).toggleClass('revealed');
  });


  // Confirm regular site
  $('a.regular_site').click(function () {
    return confirm(
      'Are you sure you want to navigate away from the mobile version?'
    );
  });

  addReferralIds();
  wrapInstagramEmbeds();
  resizeYoutube();
  Sugar.init();
});
