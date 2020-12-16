// = require_self

(() => {
  let el = document.getElementById('page-refresh-counter');
  let seconds = parseInt(el.dataset.seconds) || 30;

  if (el) {
    let cancel = setInterval(() => {
      seconds -= 1;
      if (seconds === 0) {
        clearInterval(cancel);
        window.location.reload()
      } else {
        el.innerText = seconds;
      }
    }, 1000);
  }
})();
