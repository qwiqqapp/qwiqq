//= require jquery.js
//= require jquery.cycle.js

$.fn.freeAt = function (pos) {
  var $this = this, $window = $(window);
  var position = $this.position();
  if (!position) return;
  $window.scroll(function(e) {
    if ($window.scrollTop() > pos) {
      $this.css({ position: "absolute", top: pos + position.top });
    } else {
      $this.css({ position: "fixed", top: position.top });
    }
  });
};

$(function() {
  // cycle screenshots
  $("#screenshots").cycle("fade");

  // free fixed divs at certain positions
  var sliderHeight = $("#slider").height();
  var containerHeight = $("#fixed-container").height();
  $("#fixed-container").freeAt(sliderHeight - containerHeight);
});
