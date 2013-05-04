//= require jquery.js
//= require jquery.cycle.js

jQuery.fn.exists = function() { 
  return this.length > 0; 
}

if (window.location.href.indexOf('#_=_') > 0) {

window.location = window.location.href.replace(/#.*/, '');

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
window.onload = DetectIphone()
function DetectIphone()
{
   var uagent = navigator.userAgent.toLowerCase();
   if (uagent.search("iphone") > -1)
     $("#header-small").html('#{escape_javascript(render :partial => "mobile")}');
   
   else
     $("%body").html('#{escape_javascript(render :partial => "mobile")}');
}