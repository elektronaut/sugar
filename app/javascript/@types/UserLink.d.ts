/* eslint-disable @typescript-eslint/no-unused-vars */

namespace UserLink {
  interface Link {
    id: number | null,
    label: string,
    name: string,
    url: string,
    deleted: boolean,
    handle: string
  }

  interface State {
    editing: boolean,
    userLinks: Link[]
  }

  interface Action {
    type: string,
    payload?: Link[] | Link
  }
}

/* eslint-enable @typescript-eslint/no-unused-vars */
