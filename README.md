
# wResolver [![Build Status](https://travis-ci.org/Wandalen/wResolver.svg?branch=master)](https://travis-ci.org/Wandalen/wResolver)

Collection of routines to resolve complex data structures.

## Sample

```js

var _ = require( 'wresolverextra' );
var src =
{
  dir :
  {
    val1 : 'Hello'
  },
}

var resolved = _.resolver.resolve( src, 'dir/val1' );
console.log( resolved );

/*
log : `Hello`
*/

```

## Try out

```
npm install
node sample/Sample.js
```
