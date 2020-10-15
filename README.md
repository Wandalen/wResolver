
# module::Resolver [![status](https://github.com/Wandalen/wResolver/workflows/publish/badge.svg)](https://github.com/Wandalen/wResolver/actions?query=workflow%3Apublish) [![experimental](https://img.shields.io/badge/stability-experimental-orange.svg)](https://github.com/emersion/stability-badges#experimental)

Collection of cross-platform routines to resolve complex data structures.

## Sample

```js

let _ = require( 'wresolverextra' );
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

## To add to your project
```
npm add 'wresolver@alpha'
```

