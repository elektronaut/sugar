type ReadyHandlerFn = () => void;

const readyHandlers: ReadyHandlerFn[] = [];

const handleState = () => {
  if (["interactive", "complete"].indexOf(document.readyState) > -1) {
    while (readyHandlers.length > 0) {
      readyHandlers.shift()();
    }
  }
};

class ReadyHandler {
  start(handler: ReadyHandlerFn | null) {
    if (handler) {
      this.ready(handler);
    }
    document.onreadystatechange = handleState;
  }

  ready(handler: ReadyHandlerFn) {
    readyHandlers.push(handler);
    handleState();
  }
}

export default new ReadyHandler();
