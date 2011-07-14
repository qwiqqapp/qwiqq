$(function() {
  $("a#top").click(function() {
    $(document).scrollTo(0, 500);
    return false;
  });
  
  $("a#app").click(function() {
    $(document).scrollTo(800, 500);
    return false;
  });
  
  $("a#deals").click(function() {
    $(document).scrollTo(1650, 500);
    return false;
  });
  
  $("a#contact").click(function() {
    $(document).scrollTo("max", 500);
    return false;
  })
});