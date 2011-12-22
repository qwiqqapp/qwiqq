//= require jquery
//= require jquery.cycle

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

jQuery.fn.exists = function() { 
  return this.length > 0; 
}

$(function() {
  // cycle screenshots
  $("#screenshots").cycle("fade");

  // free fixed divs at certain positions
  var sliderHeight = $("#slider").height();
  var containerHeight = $("#fixed-container").height();
  $("#fixed-container").freeAt(sliderHeight - containerHeight);

  // render nearby deals
  if ($("#posts").exists()) {
    $.get("/posts/nearby", function(data) {
      if (data != "") {
        $("#posts").html(data);
      }
    });
  }
});

