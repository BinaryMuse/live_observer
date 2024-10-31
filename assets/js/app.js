import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

function easeInOutCubic(t) {
  return t < 0.5 ? 4 * t * t * t : (t - 1) * (2 * t - 2) * (2 * t - 2) + 1;
}

function easeUpdate(element, src, dest, duration) {
  const startTime = Date.now();

  function update() {
    const elapsedTime = Date.now() - startTime;
    const progress = Math.min(elapsedTime / duration, 1);

    value = easeInOutCubic(progress);
    const diff = dest - src;
    const current = src + diff * value;
    element.innerText = current.toFixed(2);

    if (progress < 1) {
      requestAnimationFrame(update);
    }
  }

  requestAnimationFrame(update);
}

let Hooks = {};
Hooks.PidMemory = {
  updated() {
    const currentMemory = parseFloat(this.el.innerText);
    const newMemory = parseFloat(this.el.dataset.newHeapSize);

    easeUpdate(this.el, currentMemory, newMemory, 1000);
  },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();
