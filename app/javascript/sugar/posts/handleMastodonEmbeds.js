export default function handleMastodonEmbeds () {
  const iframes = new Map();

  const iframeId = () => {
    const idBuffer = new Uint32Array(1);
    let id = 0;
    while (id === 0 || iframes.has(id)) {
      id = crypto.getRandomValues(idBuffer)[0];
    }
    return id;
  };

  const receiveMessage = (evt) => {
    var data = evt.data || {};

    if (typeof data !== "object" || data.type !== "setHeight" || !iframes.has(data.id)) {
      return;
    }

    var iframe = iframes.get(data.id);

    if ("source" in evt && iframe.contentWindow !== evt.source) {
      return;
    }

    iframe.height = data.height;
  };

  window.addEventListener("message", receiveMessage);

  document.querySelectorAll("iframe.mastodon-embed").forEach(iframe => {
    const id = iframeId();

    iframes.set(id, iframe);

    iframe.scrolling = "no";
    iframe.style.overflow = "hidden";

    iframe.onload = function () {
      iframe.contentWindow.postMessage({
        type: "setHeight",
        id: id,
      }, "*");
    };

    iframe.onload();
  });
}
