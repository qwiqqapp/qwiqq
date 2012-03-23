//= require jquery.js
//= require jquery.cycle.js

jQuery.fn.exists = function() { 
  return this.length > 0; 
}


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