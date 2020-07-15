
# module::Resolver [![Status](https://github.com/Wandalen/wResolver/workflows/Publish/badge.svg)](https://github.com/Wandalen/wResolver/actions?query=workflow%3APublish) [![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

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
node sample/Sample.s
```
