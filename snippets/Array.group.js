// http://jsfiddle.net/montefuscolo/ogtzpt4t/

Object.defineProperty(
    Array.prototype, 
    'group',
    {
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
    }
);