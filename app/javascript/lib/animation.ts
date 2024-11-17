export function slideDown(element: HTMLElement) {
  const height =
    element.clientHeight -
    (parseFloat(getComputedStyle(element).paddingTop) +
      parseFloat(getComputedStyle(element).paddingBottom));

  element.style.setProperty("--final-height", `${height}px`);
  element.classList.add("slide-down");
}
