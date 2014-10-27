$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hits();
});

function player_hits() {
  $(document).on('click', '#hit_form input', function(event) {
      event.preventDefault();
      $.ajax({
        type: 'POST',
        url: '/game/player/hit'
      }).done(function(msg) {
        $('#game').html(msg);
      });
    });
}

function player_stays() {
  $(document).on('click', '#stay_form input', function(event) {
    event.preventDefault();
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg) {
      $('#game').html(msg);
    });
  });
}

function dealer_hits() {
  $(document).on('click', '#dealer_form input', function(event) {
    event.preventDefault();
    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'
    }).done(function(msg) {
      $('#game').replaceWith(msg);
    });
  });
}