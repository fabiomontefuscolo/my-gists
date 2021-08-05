<?php
/**
 * Given some parameters, return the first valid one
 * Ex.:
 *  echo first_of(false, 0, null, 'is valid', 'me too');
 *  >> is_valid
 * 
 * @param type|mixed any param
 * @return type|mixed the first valid param
 */
function first_of() {
    $args = func_get_args();
    $arg = null;

    for($i=0; $i < count($args); $i += 1)     {
        $arg = func_get_arg($i);
        if ($arg) {
            return $arg;
        }
    }
    return $arg;
}

/**
 * Get an item or property from an array or object
 * 
 * @param type|mixed $holder an array or object with items
 * @param type|mixed $key an string or integer
 * @param type|mixed $fallback 
 * @return type|mixed
 */
function getitem($holder, $key, $fallback=null) {
    if( in_array(gettype($key), array('integer', 'string')) ) {
        if(is_object($holder)) {
            if(isset($holder->{$key})) {
                return $holder->{$key};
            }
        }
        else if(is_array($holder) && array_key_exists($key, $holder)) {
            return $holder[$key];
        }
    }

    return $fallback;
}

/**
 * Generate a random string
 * 
 * @param type|int $length the length of generated string
 * @param type|string $type 'alnum' for alphanumeric or 'print' for any printable
 * @return type|string
 */
function randstr($length=32, $type='alnum') {
    $str = '';
    $length = max($length, 1);

    $filters = array(
        'print' => function($n) {
            return chr(($n % 95) + 32);
        },
        'alnum' => function($n) {
            if ($n % 3 == 0) { return chr(($n % 10) + 48); }
            if ($n % 3 == 1) { return chr(($n % 26) + 65); }
            return chr(($n % 26) + 97);
        }
    );
    $filter = isset($filters[$type]) ? $filters[$type] : $filters['alnum'];

    while(strlen($str) < $length) {
        $str .= $filter(rand());
    }

    return substr($str, 0, $length);
}

/**
 * One level copy or update values from $src to $target
 * 
 * @param type|array $target 
 * @param type|array $src 
 * @return type|array
 */
function extend($target, $src) {
    if(!$target) {
        $target = array();
    }
    foreach ($src as $key => $value) {
        $target[$key] = $src[$key];
    }
    return $target;
}

/**
 * Deep Copy or update values from $src to $target
 * 
 * @param type|array $target 
 * @param type|array $src 
 * @return type|array
 */
function array_update($target, $src) {
    $current = null;

    $stack = array(
       array(&$target, $src)                           // empilha
    );

    while(count($stack) > 0) {
        $current = array_pop($stack);

        $to = &$current[0];
        $from = &$current[1];

        foreach ($from as $key => $value) {
            if(isset($to[$key]) && is_array($to[$key]) && is_array($value)) {
                $stack[] = array(&$to[$key], $value);  // empilha
            } else {
                $to[$key] = $value;                    // copia
            }
        }
    }
    return $target;
}


/**
 * Transform a matrix in a associative array
 * 
 * @param type|array $matrix
 * @param type|int $idx_key
 * @param type|int $val_key
 * @return array
 */
function dict($matrix, $idx_key=0, $val_key=1) {
    return array_reduce($matrix, function($dict, $arr) use ($idx_key, $val_key) {

        if( is_object($arr) ) {
            $arr = (array) $arr;
        }

        if( is_array($arr) ) {
            if ( isset($arr[$idx_key]) ) {
                $idx = $arr[$idx_key];
                $val = isset($arr[$val_key]) ? $arr[$val_key] : null;

                $dict[$idx] = $val;
            }
        }

        return $dict;
    }, array());
}