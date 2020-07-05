
# module::Resolver [![Status](https://github.com/Wandalen/wResolver/workflows/Test/badge.svg)](https://github.com/Wandalen/wResolver}/actions?query=workflow%3ATest)

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
