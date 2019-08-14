
# wResolver [![Build Status](https://travis-ci.org/Wandalen/wResolver.svg?branch=master)](https://travis-ci.org/Wandalen/wResolver)

Collection of routines to resolve complex data structures. It takes a complex data structure, traverses it and resolves all strings having inlined special substrings. Use the module to resolve your templates.

## Sample

```
var _ = require( 'wresolver' );
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
node sample/Sample.s
```
