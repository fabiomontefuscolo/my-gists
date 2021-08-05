/**
 * Very simple Date formatter to use with Date instances.
 * 
 * warning: is undone and untested
 * 
 * Example:
 * 
 * var date = new Date('Thu Dec 19 2013 13:40:40 GMT-0200 (BRST)')
 * date.strftime('Today, %d/%m/%Y, I had the lunch, at %I:%M:%S %p')
 */ 
Date.prototype.strftime = function(format) {

    var that = this;

    var nierror = function(o) { return function() { throw new Error('"'+o+'" is not implemented');};};
    var zeroPad = function(n) { return n < 10 ? '0'.concat(n) : n; };

    var replacements = {
        '%a': function() { return that.toDateString().split(' ')[0]; },
        '%A': nierror('%A'),
        '%w': function() { return that.getDay() + 1; },
        '%d': function() { return zeroPad(that.getDate()); },
        '%b': function() { return that.toDateString().split(' ')[1]; },
        '%B': nierror('%B'),
        '%m': function() { return zeroPad(that.getMonth()+1); },
        '%y': function() { return that.getFullYear() % 1000; },
        '%Y': function() { return that.getFullYear(); },
        '%H': function() { return zeroPad(that.getHours()); },
        '%I': function() { return that.getHours() > 12 ? zeroPad(that.getHours() - 12) : zeroPad(that.getHours()); },
        '%p': function() { return that.getHours() < 12 ? 'am' : 'pm'; },
        '%M': function() { return zeroPad(that.getMinutes()); },
        '%S': function() { return zeroPad(that.getSeconds()); },
        '%f': nierror('%f'),
        '%z': nierror('%z'),
        '%Z': nierror('%Z'),
        '%j': nierror('%j'),
        '%U': nierror('%U'),
        '%W': nierror('%W'),
        '%c': nierror('%c'),
        '%x': nierror('%x'),
        '%X': nierror('%X'),
        '%%': function() { return '%'; }
    };

    return format.replace(/%[aAwdbBmyYHIpMSfzZjUWcxX%]/g, function(region){
        return replacements[region]();
    });
};
