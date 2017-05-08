// Veritrans is defined in https://api.midtrans.com/v2/assets/js/midtrans.min.js
// and it has no JS dependecies, but this example uses jquery for simplicity

//= require jquery

$(document).ready(function () {

  function VT_createTokenData() {
    return {
      // Optional params:
      // secure: true
      // bank: 'MANDIRI'
      // gross_amount: 1000

      card_number: $('#credit_card_number').val(),
      card_cvv: $('#credit_card_cvv').val(),
      card_exp_month: $('#credit_card_expire').val().match(/(\d+) \//)[1],
      card_exp_year: '20' + $('#credit_card_expire').val().match(/\/ (\d+)/)[1],
      gross_amount: $('#payment_amount').val(),
      secure: $('#payment_credit_card_secure')[0].checked
    };
  }

  $('.veritrans-payment-form').on('submit', function (event) {
    event.preventDefault();

    var form = this;
    var button = $(form).find('input[type=submit]:last');
    var buttonValBefore = button.val();
    button.val("Processing ...");
    button.attr('disabled', true); // prevent double submit

    Veritrans.token(VT_createTokenData, function (data) {
      //console.log('Get token response:');
      //console.log(JSON.stringify(VT_createTokenData()));
      //console.log(JSON.stringify(data));

      // if we get redirect_url then it's 3d-secure transaction
      // so we need to open that page
      // this callback function will be called again after user confirm 3d-secure
      // you can also redirect on server side

      if (data.redirect_url) {
        // it works nice with lightbox js libraries
        $('#3d-secure-iframe').attr('src', data.redirect_url).show();
      // if no redirect_url and we have token_id then just make charge request
      } else if (data.token_id) {
        $('#payment_token_id').val(data.token_id);
        form.submit();
      // if no redirect_url and no token_id, then it should be error
      } else {
        alert(data.validation_messages ? data.validation_messages.join("\n") : data.status_message);
        button.removeAttr('disabled').val(buttonValBefore);
      }
    });
  });
});