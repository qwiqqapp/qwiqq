$(function() {
  // scroll speed and positions
  var speed = 500;
  var positions = {
    top: 0,
    app: 800,
    deals: 1650,
    contact: 2500
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
    $("#navigation a").removeClass("active");  
    var top = $(document).scrollTop();
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

  // cycle screenshots
  $("#screenshots").cycle("fade");

  // deals
  $(".deal").hover(
    function() {
      $(".image", this).fadeOut(0);
      $(".details", this).fadeIn(0);
    },
    function() {
      $(".image", this).fadeIn(0);
      $(".details", this).fadeOut(0);
    })
});