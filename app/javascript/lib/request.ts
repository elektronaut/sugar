type FetchOptions = {
  method: string;
  headers: Record<string, string>;
  body?: string;
};

export function csrfToken(): string {
  const elem =
    typeof document !== "undefined" &&
    document.querySelector("[name=csrf-token]");

  if (!elem) {
    return "";
  }

  return elem.getAttribute("content") || "";
}

function jsonFetchOptions(): FetchOptions {
  return {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-CSRF-Token": csrfToken()
    }
  };
}

export async function postJson(url: string, data: unknown) {
  const options = { ...jsonFetchOptions(), method: "POST" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}

export async function putJson(url: string, data: unknown) {
  const options = { ...jsonFetchOptions(), method: "PUT" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}
