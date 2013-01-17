//= require jquery.js
//= require jquery.cycle.js

jQuery.fn.exists = function() { 
  return this.length > 0; 
}

function testJavascript() {
  name = '#{deal.test_email}' ;
  alert(name);
}
      

$(function() {
  // cycle screenshots
  $("#screenshots").cycle("fade");
  
  // JS callback disabled, currently using featured posts
  // TODO restore this code once HTML5 location is added
  // render nearby deals
  // if ($("#posts").exists()) {
  //    $.get("/posts/nearby", function(data) {
  //      if (data != "") {
  //        $("#posts").html(data);
  //      }
  //    });
  //  }
});