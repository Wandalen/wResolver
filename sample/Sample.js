
var _ = require( '..' /* './Resolver.s' */ );
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
