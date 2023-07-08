import readyHandler from "../lib/readyHandler";
import Sugar from "../sugar";

const urlPattern =
  /https?:\/\/([\w\d\-.])*(amazon|junglee)(\.com?)*\.([\w]{2,3})\//;

function needsReferral(link: HTMLLinkElement) {
  return !link.dataset.amazonReferralId && link.href.match(urlPattern)
    ? true
    : false;
}

function applyReferral(link: HTMLLinkElement) {
  const referralId = Sugar.Configuration.amazonAssociatesId as string;

  if (referralId && needsReferral(link)) {
    link.dataset.amazonReferralId = referralId;
    if (link.href.match(/(\?|&)tag=/)) {
      return;
    }
    link.href += link.href.match(/\?/) ? "&" : "?";
    link.href += "tag=" + referralId;
  }
}

export function applyReferrals() {
  document.querySelectorAll("a").forEach((elem) => {
    applyReferral(elem);
  });
}

readyHandler.ready(applyReferrals);
document.addEventListener("postsloaded", applyReferrals);
