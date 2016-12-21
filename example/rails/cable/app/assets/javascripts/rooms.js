function makeSubscription() {
    App.globalChat = App.cable.subscriptions.create({
        channel: 'RoomsTextingChannel',
    }, {
        connected: function() {},

        disconnected: function() {},

        received: function(data) {
            jQuery('.chats').append(data.chat);
            scrollToBottom(jQuery('.chats'));
        },

        sendMessage: function(message) {
            return this.perform('send_message', {
                message: message,
            });
        }
    });
}

function makeFormSubmitCallback(form) {
    var messageTextArea = form.find('#chat-input-text');
    messageTextArea.on('keypress', function(e) {
        if (e.keyCode == 13) {
            e.preventDefault();
            form.submit();
        }
    });

    form.submit(function(e) {
        e.preventDefault();

        var messageText = messageTextArea.val();
        // tidak boleh mengirim text kosong
        if (jQuery.trim(messageText).length > 1) {
            App.globalChat.sendMessage(messageTextArea.val());
            messageTextArea.val('');
        } else {
            console.error("Blank message, cannot send it");
        }

        return false;
    });
}

function scrollToBottom(element) {
    element.scrollTop(element.prop('scrollHeight'));
}

jQuery(document).ready(function() {
    makeSubscription();
    makeFormSubmitCallback(jQuery('#new_chat'));
    scrollToBottom(jQuery('.chats'));
})
