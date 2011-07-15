$(function() {
  var scroll = 0;
  var count = 4;
  var width = 520;
  var leftArrow = $("<a href='#' class='arrow' id='left-arrow'></a>");
  var rightArrow = $("<a href='#' class='arrow' id='right-arrow'></a>");
  $("#facebook").append(leftArrow);
  $("#facebook").append(rightArrow);
  leftArrow.click(function() {
    if (scroll > 0) {
      scroll -= width;
      $("#gallery-scroller").animate({"scrollLeft": scroll});
    } else {
      scroll = width * (count - 1);
      $("#gallery-scroller").animate({"scrollLeft": scroll});
    }

    return false;
  });

  rightArrow.click(function() {
    if (scroll < width * (count - 1)) {
      scroll += width;
      $("#gallery-scroller").animate({"scrollLeft": scroll});
    } else {
      scroll = 0;
      $("#gallery-scroller").animate({"scrollLeft": scroll});
    }

    return false;
  });
});
