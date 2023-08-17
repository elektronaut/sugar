type ReadyHandlerFn = () => void;

const readyHandlers: ReadyHandlerFn[] = [];

const runHandlers = () => {
  while (readyHandlers.length > 0) {
    readyHandlers.shift()();
  }
};

const handleState = () => {
  if (["interactive", "complete"].indexOf(document.readyState) > -1) {
    window.setTimeout(runHandlers);
    document.removeEventListener("DOMContentLoaded", handleState);
  }
};

class ReadyHandler {
  start(handler: ReadyHandlerFn | null) {
    if (handler) {
      this.ready(handler);
    }
    document.addEventListener("DOMContentLoaded", handleState);
  }

  ready(handler: ReadyHandlerFn) {
    readyHandlers.push(handler);
    handleState();
  }
}

export default new ReadyHandler();
