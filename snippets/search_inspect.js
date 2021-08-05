Object.defineProperty(
    Object.prototype, 'inspect_walk', {
        enumerable: false,
        value: function (compare, callback) {
            var visited = [];

            var stack = [{
                'path'  : [],
                'key'   : '',
                'value' : this
            }];
            
            var last, keys, key, val;

            while(stack.length > 0) {
                last = stack[ stack.length - 1 ];

                if(last.value && visited.indexOf(last.value) < 0 && typeof last.value === 'object') {
                    keys = Object.keys(last.value);
                    visited.push(last.value)

                    for(var i = 0; i < keys.length; i++) {
                        key = keys[i];
                        val = last.value[key];

                        stack.push({
                            'parent': last,
                            'path'  : last.path.concat(key),
                            'key'   : key,
                            'value' : val
                        });
                    }
                } else {
                    cur = stack.pop();
                    if (compare(cur)) {
                        callback(cur);
                    }
                }
            }

        }
    }
);
