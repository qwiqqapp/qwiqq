//= require jquery.js
//= require jquery.cycle.js

$.fn.fixTo = function (pos) {
  var $this = this, $window = $(window), position = $this.position();
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
  sliderHeight = $("#slider").height();
  infoHeight = $("#info").height();
  $("#info").fixTo(sliderHeight - infoHeight);
});

