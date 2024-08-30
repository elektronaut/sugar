export function csrfToken(): string {
  const elem =
    typeof document !== "undefined" &&
    document.querySelector("[name=csrf-token]");

  if (!elem) {
    return "";
  }

  return elem.getAttribute("content") || "";
}

function jsonFetchOptions() {
  return {
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "X-CSRF-Token": csrfToken()
    }
  };
}

export async function postJson(url: string, data: Record<string, string>) {
  const options = { ...jsonFetchOptions(), method: "POST" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}

export async function putJson(url: string, data: Record<string, string>) {
  const options = { ...jsonFetchOptions(), method: "PUT" };
  if (data) {
    options.body = JSON.stringify(data);
  }
  const response = await fetch(url, options);
  return response.json();
}

export async function post(url: string, data: Record<string, string>) {
  const response = await fetch(url, {
    method: "POST",
    body: data,
    headers: { "X-CSRF-Token": csrfToken() }
  });
  return response.json();
}
