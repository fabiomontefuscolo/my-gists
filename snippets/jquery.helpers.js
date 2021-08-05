(function ($) {
    $.shuffle = function shuffle(array) {
        if(!array) {
            if ($.isArray(this)) {
                array = this
            } else {
                array = $(this);
            }
        }

        var i = array.length;
        var temp = null;
        var rand = null;

        while (0 !== i) {
            rand = Math.floor(Math.random() * i);
            i -= 1;

            temp = array[i];
            array[i] = array[rand];
            array[rand] = temp;
        }
        return $(array);
    };

    $.fn.shuffle = function () {
        return $.shuffle(this);
    };
})(jQuery)