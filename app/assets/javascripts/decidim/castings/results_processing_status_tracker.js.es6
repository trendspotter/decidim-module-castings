// = require_self

(() => {
  const el = document.getElementById('results-processing-status-tracker');
  const casting_id = el.dataset.casting_id;

  if (el && casting_id) {
    const is_scheduled = el.dataset.is_processing_scheduled_status === 'true';
    const path = `/admin/castings/${casting_id}/results_processing_status.json`;

    let cancel = setInterval(() => {
      fetch(window.location.origin + path)
        .then(response => response.json())
        .then(data => {
          if (data.casting.status !== 'processing' || (is_scheduled && data.casting.status !== 'processing_scheduled')) {
            clearInterval(cancel);
            window.location.reload()
          } else { // processing
            const best_result = data.casting.best_result;

            if (data.casting.status === 'processing_scheduled') {
              $(el).find("#processing_scheduled_title").show();
              $(el).find("#preparing_data_title").hide();
              $(el).find("#processing_title").hide();
            } else if (data.casting.status === 'processing') {
              $(el).find("#processing_scheduled_title").hide();
              if (data.casting.max_run_number === 0) {
                $(el).find("#preparing_data_title").show();
                $(el).find("#processing_title").hide();
              } else {
                $(el).find("#preparing_data_title").hide();
                $(el).find("#processing_title").show();
              }
            }

            if (data.casting.max_run_number > 0) $(el).find('#processing_run').show();
            $(el).find('#processing_run_number').text(data.casting.max_run_number);
            if (best_result) {
              $(el).find('#run_number').text(best_result.run_number);
              $(el).find('#participants_found').text(best_result.statistics.total_candidates);
              $(el).find('#substitutes_found').text(best_result.statistics.total_substitutes);
            }
          }
        });
    }, 5000);
  }
})();
