// = require_self

(() => {
  $(".selection-criteria-list input[type=number]").bind('keyup change', (e) => {
    const v = parseInt(e.currentTarget.value);
    const amount_left_hint = $(e.currentTarget).closest(`#selection-criteria-${e.currentTarget.dataset["key"]}`).find(".participants-left-hint");
    const excess_amount_hint = $(e.currentTarget).closest(`#selection-criteria-${e.currentTarget.dataset["key"]}`).find(".excess-participants-hint");

    let sum = 0;
    const inputs = $(e.currentTarget).closest(`#selection-criteria-${e.currentTarget.dataset["key"]}-values`).find("input[type=number]");
    inputs.each((index, el) => sum += (parseInt(el.value) || 0));

    if (sum < e.currentTarget.max) {
      amount_left_hint.find(".amount-left").text(e.currentTarget.max - sum);
      amount_left_hint.css('display', 'inline-block');
      excess_amount_hint.hide();
    } else if (sum > e.currentTarget.max) {
      amount_left_hint.hide();
      excess_amount_hint.find(".excess-amount").text(sum - e.currentTarget.max);
      excess_amount_hint.css('display', 'inline-block');
    } else {
      amount_left_hint.hide();
      excess_amount_hint.hide();
    }

  });

})();
