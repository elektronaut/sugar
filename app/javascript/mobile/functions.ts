import $ from "jquery";
import Sugar from "../sugar";

function toggleNavigation() {
  $("#navigation").toggleClass("active");
}

// Amazon Associates referral code
function addReferralIds() {
  const referralId = Sugar.Configuration.amazonAssociatesId as string;
  const ptrn = /https?:\/\/([\w\d\-.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//;

  const needsReferral = function (link: HTMLLinkElement): boolean {
    return (
      !$.data(link, "amazon_associates_referral_id") &&
      link.href.match(ptrn)
    );
  };

  const applyReferral = (_, link: HTMLLinkElement) => {
    if (needsReferral(link)) {
      $.data(link, "amazon_associates_referral_id", referralId);
      if (link.href.match(/(\?|&)tag=/)) {
        return;
      }
      link.href += link.href.match(/\?/) ? "&" : "?";
      link.href += "tag=" + referralId;
    }
  };

  if (referralId) {
    $(".post .body a").each(applyReferral);
  }
}

function wrapEmbeds() {
  const selectors: string[] = [ "iframe[src*=\"bandcamp.com\"]",
                    "iframe[src*=\"player.vimeo.com\"]",
                    "iframe[src*=\"youtube.com\"]",
                    "iframe[src*=\"youtube-nocookie.com\"]",
                    "iframe[src*=\"kickstarter.com\"][src*=\"video.html\"]" ];

  const embeds = [...document.querySelectorAll(selectors.join(","))];

  function wrapEmbed(embed: HTMLElement): HTMLDivElement {
    const wrapper = document.createElement("div");
    embed.parentNode.replaceChild(wrapper, embed);
    wrapper.appendChild(embed);
    return wrapper;
  }

  embeds.forEach(function (embed: HTMLElement) {
    const parent = embed.parentNode as HTMLElement;
    if (parent && parent.classList.contains("responsive-embed")) {
      return;
    }

    const width = embed.offsetWidth;
    const height = embed.offsetHeight;
    const ratio = height / width;
    const wrapper = wrapEmbed(embed);

    wrapper.classList.add("responsive-embed");
    wrapper.style.position = "relative";
    wrapper.style.width = "100%";
    wrapper.style.paddingBottom = `${ratio * 100}%`;

    embed.style.position = "absolute";
    embed.style.width = "100%";
    embed.style.height = "100%";
    embed.style.top = "0";
    embed.style.left = "0";
  });
}

$(document).ready(function () {
  const updateLayout = function () {
    if ((window.orientation != null)) {
      if (window.orientation === 90 || window.orientation === -90) {
        document.body.setAttribute("orient", "landscape");
      } else {
        document.body.setAttribute("orient", "portrait");
      }
    }
  };

  $(window).bind("orientationchange", updateLayout);
  $(window).bind("resize", updateLayout);
  updateLayout();

  $(".toggle-navigation").click(function () {
    toggleNavigation();
  });

  // Open images when clicked
  $(".post .body img").click(function (_, img: HTMLImageElement) {
    document.location = img.src;
  });

  // Larger click targets on discussion overview
  $(".discussions .discussion h2 a").each(function (_, link: HTMLLinkElement) {
    $(this.parentNode.parentNode).click(function () {
      document.location = link.href;
    });
  });

  // Scroll past the Safari chrome
  if (!document.location.toString().match(/#/)) {
    setTimeout(scrollTo, 100, 0, 1);
  }

  // Search mode
  $("#search_mode").change(function (_, elem: HTMLSelectElement) {
    const parent = elem.parentNode as HTMLFormElement;
    parent.action = elem.value;
  });

  // Post quoting
  $(".post .functions a.quote_post").click(function () {
    const stripWhitespace = function (str: string) {
      return str.replace(/^[\s]*/, "").replace(/[\s]*$/, "");
    };

    const post = $(this).closest(".post");
    const username = post.find(".post_info .username a").text();
    const permalinkElem = post.find(".post_info .permalink").get()[0] as HTMLLinkElement;
    const permalink = permalinkElem.href.replace(/^https?:\/\/([\w\d.:-]*)/, "");

    let text = stripWhitespace(post.find(".body").text());
    let html = stripWhitespace(post.find(".body").html());

    // Hide spoilers
    text = text.replace(/class="spoiler revealed"/g, "class=\"spoiler\"");
    html = html.replace(/class="spoiler revealed"/g, "class=\"spoiler\"");

    $(Sugar).trigger("quote", {
      username: username,
      permalink: permalink,
      text: text,
      html: html
    });

    return false;
  });

  // Muted posts
  $(".post").each(function () {
    const userId = $(this).data("user_id") as string;
    const mutedUsers = window.mutedUsers as number[] | null;
    if (mutedUsers && mutedUsers.indexOf(userId) !== -1) {
      const notice = document.createElement("div");
      const showLink = document.createElement("a");
      const username = this.querySelector(".username a").textContent;

      showLink.innerHTML = "Show";
      showLink.addEventListener("click", (evt) => {
        evt.preventDefault();
        this.classList.remove("muted");
      });

      notice.classList.add("muted-notice");
      notice.innerHTML = `This post by <strong>${username}</strong> has been muted. `;
      notice.appendChild(showLink);

      this.classList.add("muted");
      this.appendChild(notice);
    }
  });

  // Posting
  $("form.new_post").submit(function () {
    // let body = $(this).find("#compose-body");
    return true;
  });

  // Spoiler tags
  $(".spoiler").click(function () {
    $(this).toggleClass("revealed");
  });

  // Login
  $("section.login").each(function () {
    function forgotPassword() {
      $("#login").toggle();
      $("#password-reminder").toggle();
    }
    $("#password-reminder").hide();
    $(".forgot-password").click(forgotPassword);
  });

  // Confirm regular site
  $("a.regular_site").click(function () {
    return confirm(
      "Are you sure you want to navigate away from the mobile version?"
    );
  });

  addReferralIds();
  wrapEmbeds();
  Sugar.init();
});
