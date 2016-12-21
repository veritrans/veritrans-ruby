function snapTokenGeneratorOnClickFor(elementQualifier) {
    $(document).on("click", elementQualifier, function(event) {
        var element = jQuery(this);
        var chatId = element.data("chat-id");
        var token = element.data("token");

        if (token == "" || token == undefined) {
            $.ajax({
                url: '/chats/' + chatId + '/generate_checkout_token',
                data: {},
                success: function(data) {
                    var token = data.token;
                    element.data('token', token);
                    showSnapDialog(element);
                }
            });
        } else { showSnapDialog(element); }
    });
}

function showSnapDialog(element) {
    var token = element.data("token");
    console.log(token);
    snap.pay(token, {
        onSuccess: function(res) {
        
        },
        onPending: function(res) {
        
        },
        onError: function(res) {
        
        }
    });
}

jQuery(document).ready(function() {
    snapTokenGeneratorOnClickFor('.buy-chat-items');
})
