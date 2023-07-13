const monthNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

const zeroPad = (num: number | string) => {
  let s = num.toString();
  while (s.length < 2) {
    s = "0" + s;
  }
  return s;
};

export function formatDate(arg: string) {
  const date = new Date(arg);

  return `${
    monthNames[date.getMonth()]
  } ${date.getDate()},  ${date.getFullYear()}`;
}

export function formatTime(arg: string) {
  const date = new Date(arg);
  return [zeroPad(date.getHours()), zeroPad(date.getMinutes())].join(":");
}

export function formatDateTime(arg: string) {
  return `${formatDate(arg)}, ${formatTime(arg)}`;
}
