/**
 * Very simple string formatter
 * 
 * Examples:
 * 
 * "I have {0} dogs, {1} cats and {2} brother.".format(2, 3, 1) === "I have 2 dogs, 3 cats and 1 brother."
 * "I have {0} dogs, {1} cats and {2} brother.".format(2, [3, 1]) === "I have 2 dogs, 3 cats and 1 brother."
 * "I have {0} dogs, {1} cats and {2} brother.".format([2, 3], 1) === "I have 2 dogs, 3 cats and 1 brother."
 * "I have {0} dogs, {1} cats and {2} brother.".format([2, 3, 1]) === "I have 2 dogs, 3 cats and 1 brother."
 */
String.prototype.format = function () {
    if( arguments.length < 1)
        return this.toString();

    function to_flat_array(o1, o2) {
        if(o2.constructor === Array)
            return o1.concat(o2);
        return o1.concat([o2]);
    }

    var replacements = Array.prototype.reduce.call(arguments, to_flat_array, []);

    return this.replace(/\{(\d+)\}/g, function(region, index){
        index = parseInt(index, 10);
        if (index >= replacements.length) {
            return region;
        }
        return replacements[index];
    });
};
