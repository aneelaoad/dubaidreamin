$(document).ready(function() {

    AOS.init();
  

    // mobile menu

    // $('.menuIcon').on('click', function (e) {
    //     $('body').addClass('hidden');
    //     $('.headerFr').slideDown();
    // });

    // $('.closeNav').on('click', function (e) {
    //     $('body').removeClass('hidden');
    //     $('.headerFr').slideUp();
    // });



    // checkout code 
    // $('.checkoutBtnn').on('click', function (e) { 
    //     $('.ticket_table_flShow').hide();
    //     $('.ticket_table_flCheckout').show();
    // });
    // $('.backtoCheckout').on('click', function (e) { 
    //     $('.ticket_table_flShow').show();
    //     $('.ticket_table_flCheckout').hide();
    // });


    document.querySelectorAll('.checkoutBtnn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.ticket_table_flShow').forEach(function(element) {
                element.style.display = 'none';
            });
            document.querySelectorAll('.ticket_table_flCheckout').forEach(function(element) {
                element.style.display = 'block';
            });
        });
    });
    
    document.querySelectorAll('.backtoCheckout').forEach(function(btn) {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.ticket_table_flShow').forEach(function(element) {
                element.style.display = 'block';
            });
            document.querySelectorAll('.ticket_table_flCheckout').forEach(function(element) {
                element.style.display = 'none';
            });
        });
    });
     

  


});




 







 
 

  
   // sticky header
   window.addEventListener('scroll', function() {
    if (window.scrollY >= 10) {
        document.querySelector('.wrapper').classList.add('fixed_header');
    } else {
        document.querySelector('.wrapper').classList.remove('fixed_header');
    }
});

//    $(window).scroll(function() {
//     if ($(window).scrollTop() >= 10) {

//         $('.wrapper').addClass('fixed_header');
//     } else {
//         $('.wrapper').removeClass('fixed_header');
//     }
// }); 




 











