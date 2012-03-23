//= require jquery
//= require jquery.cycle

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