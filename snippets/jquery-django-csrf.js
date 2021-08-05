(function($){
    if(!$) {
        return;
    }

    var match = document.cookie.match(/csrftoken=(\w+)/);
    var token = match ? match[1] : '';

    $.ajaxSetup({
        headers: { 'X-CSRFToken': token }
    });

})(window.jQuery);