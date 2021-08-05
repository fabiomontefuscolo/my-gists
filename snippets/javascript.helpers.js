Object.defineProperty(Element.prototype, 'outerHeight', {
    'get': function(){
        var height = this.clientHeight;
        var computedStyle = window.getComputedStyle(this); 
        height += parseInt(computedStyle.marginTop, 10);
        height += parseInt(computedStyle.marginBottom, 10);
        height += parseInt(computedStyle.borderTopWidth, 10);
        height += parseInt(computedStyle.borderBottomWidth, 10);
        return height;
    }
});


Object.defineProperty(Array.prototype, 'group', {
    enumerable: false,
    value: function (n) {
        var initial = [
            []
        ];
    
        function reducer(m, e) {
            if (m[m.length - 1].length < n) {
                m[m.length - 1].push(e);
            } else {
                m.push([e]);
            }
            return m;
        }
        
        return this.reduce(reducer, initial);
    }
});


Object.defineProperty(
    Object.prototype, 'resolveprop', {
        enumerable: false,
        value: function (path) {
            var props = [];
            if(path && path.constructor) {
                if(path.constructor === String) {
                    props = path.split('.');
                }
            }

            var prop;
            var count = 0;
            var current = this;

            while(count < props.length && current !== undefined) {
                prop = props[count];
                current = current[prop];
                count++;
            }

            if(this !== current && count === props.length){
                return current
            }
        }
    }
);


Object.defineProperty(Array.prototype, 'pathjoin', {
    enumerable: false,
    value: function (glue) {
        glue = glue || '/';
        var pieces = this;

        return pieces.reduce(function (str, piece) {
            if(!str) {
                str = '';
            } else if(!str.endsWith(glue)) {
                str += glue;
            }

            if(!piece) {
                return str;
            } else if(piece.startsWith(glue)) {
                return str + piece.slice(glue.length);
            }

            return str + piece;
        });
    }
});
