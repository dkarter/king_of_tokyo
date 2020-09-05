import '../css/app.scss';

import 'phoenix_html';
import { Socket } from 'phoenix';
import LiveSocket from 'phoenix_live_view';
import Clipboard from 'clipboard';
import { Notyf } from 'notyf';

import NProgress from 'nprogress';

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', () => NProgress.start());
window.addEventListener('phx:page-loading-stop', () => NProgress.done());

const notyf = new Notyf({
  duration: 3000,
  position: {
    x: 'right',
    y: 'top',
  },
});

const clipboard = new Clipboard('#copy-link', {
  text: () => {
    notyf.success('Copied link!');
    return window.location;
  },
});

clipboard.on('success', e => {
  console.log(e.trigger.innerHTML);
  e.trigger.innerHTML = 'Copied!';
  e.trigger.setAttribute('disabled', 'disabled');
  setTimeout(() => {
    e.trigger.innerHTML = 'Copy Link';
    e.trigger.removeAttribute('disabled');
  }, 1000);
});

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');

const Hooks = {
  GameContainer: {
    mounted() {
      notyf.success('Joined game!');
    },
  },
  ChatHistory: {
    mounted() {
      this.el.scrollTop = this.el.scrollHeight;
    },
    updated() {
      this.el.scrollTop = this.el.scrollHeight;
    },
  },
  ChatFormTextArea: {
    mounted() {
      this.el.focus();
    },
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
