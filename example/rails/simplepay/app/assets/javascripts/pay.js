jQuery(document).ready(function() {
    var token = jQuery("#snap_token").val();

    jQuery('.checkout-button').on('click', function() {
        snap.pay(token, {
            onSuccess: function(res) {
                console.log("SUCCESS", res);
                alert("Payment accepted!");
            },
            onPending: function(res) {
                console.log("PENDING", res);
            },
            onError: function(res) {
                console.log("ERROR", res);
            }
        })
    })
});
