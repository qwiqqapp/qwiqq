//= require jquery.js
//= require jquery.cycle.js

$.fn.scrollAfter = function (pos) {
  var $this = this, $window = $(window), top = this.position().top;
  $window.fixTo(function(e) {
    if ($window.scrollTop() > pos) {
      $this.css({ position: "absolute", top: pos + top });
    } else {
      $this.css({ position: "fixed", top: top });
    }
  });
};

$(function() {
  $("#screenshots").cycle("fade");

  sliderHeight = $("#slider").height();
  infoHeight = $("#info").height();
  $("#info").fixTo(sliderHeight - infoHeight);
});

