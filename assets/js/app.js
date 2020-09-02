// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.scss';

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import { Socket } from 'phoenix';
import LiveSocket from 'phoenix_live_view';

import NProgress from 'nprogress';

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', info => NProgress.start());
window.addEventListener('phx:page-loading-stop', info => NProgress.done());

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');

const Hooks = {
  ChatHistory: {
    updated() {
      this.el.scrollTop = this.el.scrollHeight;
    },
  },
  ChatFormTextArea: {
    updated() {
      this.el.value = this.el.dataset.pendingVal;
    },
  },
};

const keyEventMetadata = e => {
  return {
    altGraphKey: e.altGraphKey,
    altKey: e.altKey,
    code: e.code,
    ctrlKey: e.ctrlKey,
    key: e.key,
    keyIdentifier: e.keyIdentifier,
    keyLocation: e.keyLocation,
    location: e.location,
    metaKey: e.metaKey,
    repeat: e.repeat,
    shiftKey: e.shiftKey,
  };
};

let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
  metadata: {
    click: e => {
      return {
        altKey: e.altKey,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        metaKey: e.metaKey,
        x: e.x || e.clientX,
        y: e.y || e.clientY,
        pageX: e.pageX,
        pageY: e.pageY,
        screenX: e.screenX,
        screenY: e.screenY,
        offsetX: e.offsetX,
        offsetY: e.offsetY,
        detail: e.detail || 1,
      };
    },
    keydown: keyEventMetadata,
    keyup: keyEventMetadata,
  },
});
liveSocket.connect();
