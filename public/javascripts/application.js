$(function() {
  var speed = 500;
  var positions = {
    top: 0,
    app: 800,
    deals: 1650,
    contact: 2450
  }

  $("a#top").click(function() {
    $(document).scrollTo(positions.top, speed);
    return false;
  });
  
  $("a#app").click(function() {
    $(document).scrollTo(positions.app, speed);
    return false;
  });
  
  $("a#deals").click(function() {
    $(document).scrollTo(positions.deals, speed);
    return false;
  });
  
  $("a#contact").click(function() {
    $(document).scrollTo(positions.contact, speed);
    return false;
  });

  $(document).scroll(function() {
    var top = $(document).scrollTop();
    $("#navigation a").removeClass("active");  
    if (top >= positions.contact) {
      $("#navigation a#contact").addClass("active");
    }
    else if (top >= positions.deals) {
      $("#navigation a#deals").addClass("active");
    }
    else if (top >= positions.app) {
      $("#navigation a#app").addClass("active");
    }
  });
});