const specialKeys = {
  8: "backspace",
  9: "tab",
  10: "return",
  13: "return",
  16: "shift",
  17: "ctrl",
  18: "alt",
  19: "pause",
  20: "capslock",
  27: "esc",
  32: "space",
  33: "pageup",
  34: "pagedown",
  35: "end",
  36: "home",
  37: "left",
  38: "up",
  39: "right",
  40: "down",
  45: "insert",
  46: "del",
  59: ";",
  61: "=",
  96: "0",
  97: "1",
  98: "2",
  99: "3",
  100: "4",
  101: "5",
  102: "6",
  103: "7",
  104: "8",
  105: "9",
  106: "*",
  107: "+",
  109: "-",
  110: ".",
  111: "/",
  112: "f1",
  113: "f2",
  114: "f3",
  115: "f4",
  116: "f5",
  117: "f6",
  118: "f7",
  119: "f8",
  120: "f9",
  121: "f10",
  122: "f11",
  123: "f12",
  144: "numlock",
  145: "scroll",
  173: "-",
  186: ";",
  187: "=",
  188: ",",
  189: "-",
  190: ".",
  191: "/",
  192: "`",
  219: "[",
  220: "\\",
  221: "]",
  222: "'"
};

function matchModifier(modifier: string, hotkey: string, event: KeyboardEvent) {
  if (
    (hotkey.includes(`${modifier}+`) && !event[`${modifier}Key`]) ||
    (!hotkey.includes(`${modifier}+`) && event[`${modifier}Key`])
  ) {
    return false;
  }
  return true;
}

function matchKey(hotkey: string, event: KeyboardEvent) {
  const key = hotkey.replace(/(shift|alt|ctrl|meta)\+/, "").toLowerCase();
  if (
    !matchModifier("shift", hotkey, event) ||
    !matchModifier("ctrl", hotkey, event) ||
    !matchModifier("alt", hotkey, event) ||
    !matchModifier("meta", hotkey, event)
  ) {
    return false;
  }
  if (event.keyCode in specialKeys) {
    return specialKeys[event.keyCode] === key;
  } else {
    return String.fromCharCode(event.keyCode).toLowerCase() === key;
  }
}

export default function bindKey(
  hotkey: string,
  fn: (evt: KeyboardEvent) => void
) {
  document.addEventListener("keydown", (evt: KeyboardEvent) => {
    if (
      matchKey(hotkey, evt) &&
      "tagName" in evt.target &&
      ["INPUT", "TEXTAREA", "SELECT"].indexOf(evt.target.tagName) === -1
    ) {
      fn(evt);
    }
  });
}
