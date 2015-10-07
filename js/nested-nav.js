$(function (){
    $(".nav-nested li a").click(function (evt) {

    var $parent = $(evt.currentTarget.parentElement);
    var subNav = $parent.contents().filter(".nav");

    if (subNav.hasClass("active") || subNav.length == 0) {
      return true;
    }

    $(".nav .nav").removeClass("active");
    subNav.addClass("active");

    evt.stopImmediatePropagation();
    return false; 
  });
});
