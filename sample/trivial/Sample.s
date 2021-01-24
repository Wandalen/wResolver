
// let _ = require( 'wresolverextra' );
let _ = require( 'wresolver' );
var src =
{
  dir :
  {
    val1 : 'Hello'
  },
}

var resolved = _.resolver.resolve( src, 'dir/val1' )
console.log( resolved );

/*
log : `Hello`
*/
