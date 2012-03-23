//= require jquery
//= require jquery.cycle

$(function() {
  // cycle screenshots
  $("#screenshots").cycle("fade");

  // render nearby deals
  if ($("#posts").exists()) {
    $.get("/posts/nearby", function(data) {
      if (data != "") {
        $("#posts").html(data);
      }
    });
  }
});