
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
  val2 : 'here',
}

let resolved = _.Resolver.resolve
({
  src : src,
  selector : '{::dir/val1} from {::val2}!',
});

console.log( resolved );

/*
`Hello from here!`
*/
```

## Try out

```
npm install
node sample/Sample.js
```
