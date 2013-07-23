// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
  $('form#new_message').submit(function(e) {
    e.preventDefault();
    $.ajax({
      type: "POST",
      url: $(this).attr('action'),
      data: $(this).serialize(),
      success: function(html) {
        $('#messages').append(html);
        $('#message_content').val('');
      }
    });
  });
});
