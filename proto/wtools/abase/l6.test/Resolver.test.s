( function _Resolver_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  _.include( 'wTesting' );
  _.include( 'wLogger' );

  require( '../l6/Resolver.s' );

}

const _global = _global_;
const _ = _global_.wTools;

// --
// tests
// --

function trivial( test )
{

  /* */

  test.case = 'basic';

  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
  }

  var exp = 'Hello';
  var got = _.resolver.resolve
  ({
    src,
    selector : 'dir/val1',
  });
  test.identical( got, exp );

  /* */

  test.case = 'implicit';

  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
  }

  var exp = 'Hello';
  var got = _.resolver.resolve( src, 'dir/val1' );
  test.identical( got, exp );

  /* */

  test.case = 'composite';

  var src =
  {
    dir :
    {
      val1 : 'Hello'
    },
    val2 : 'here',
    val3 : '{dir/val1} from {val2}!',
  }

  var exp = 'Hello from here!';
  // debugger;
  var got = _.resolver.resolve
  ({
    src,
    selector : '{val3}',
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite(),
    onSelectorDown : _.resolver.functor.onSelectorDownComposite(),
    recursive : 10,
  });
  // debugger;
  test.identical( got, exp );

  /* */

}

//

function resolveMultiple( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }

  /* - */

  test.open( 'array' );

  /* */

  test.case = 'first level selector';
  var expected = [ { b1 : 1, b2 : 'b2' }, { c1 : 1, c2 : 'c2' } ];
  var got = _.resolve( src, [ 'b', 'c' ] );
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b );
  test.true( got[ 1 ] === src.c );

  /* */

  test.case = 'second level selector';
  var expected = [ 'b2', { c1 : 1, c2 : 'c2' } ];
  var got = _.resolve( src, [ 'b/b2', 'c' ] );
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ] === src.c );

  /* */

  test.case = 'complex selector';
  var expected = [ 'b2', { a : { c1 : 1, c2 : 'c2' }, b : { name : 'name1' } } ];
  var got = _.resolve( src, [ 'b/b2', { a : 'c', b : 'a/map' } ] );
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ][ 'a' ] === src.c );
  test.true( got[ 1 ][ 'b' ] === src.a.map );

  /* */

  test.case = 'self selector';
  var expected = [ 'b2', { a : src } ];
  var got = _.resolve( src, [ 'b/b2', { a : '/' } ] );
  test.identical( got, expected );
  test.true( got[ 1 ].a === src );
  test.true( got.length === 2 );

  // yyy
  // test.case = 'self and empty selectors';
  // var expected = [ 'b2', { a : src } ];
  // var got = _.resolve( src, [ 'b/b2', { a : '/', b : '' } ] );
  // test.identical( got, expected );
  // test.true( got[ 1 ].a === src );
  // test.true( got.length === 2 );

  /* */

  test.close( 'array' );

  /* - */

  test.open( 'map' );

  /* */

  test.case = 'first level selector';
  var expected = { b : { b1 : 1, b2 : 'b2' }, c : { c1 : 1, c2 : 'c2' } };
  var got = _.resolve( src, { b : 'b', c : 'c' } );
  test.identical( got, expected );
  test.true( got.b === src.b );
  test.true( got.c === src.c );

  /* */

  test.case = 'second level selector';
  var expected = { b2 : 'b2', c : { c1 : 1, c2 : 'c2' } };
  var got = _.resolve( src, { b2 : 'b/b2', c : 'c' } );
  test.identical( got, expected );
  test.true( got.b2 === src.b.b2 );
  test.true( got.c === src.c );

  /* */

  test.case = 'complex selector';
  var expected = { b : 'b2', array : [ { c1 : 1, c2 : 'c2' }, { name : 'name1' } ] };
  var got = _.resolve( src, { b : 'b/b2', array : [ 'c', 'a/map' ] } );
  test.identical( got, expected );
  test.true( got[ 'b' ] === src.b.b2 );
  test.true( got[ 'array' ][ 0 ] === src.c );
  test.true( got[ 'array' ][ 1 ] === src.a.map );

  /* */

  test.case = 'self selector';
  var expected = { array : [ src ] };
  var got = _.resolve( src, { array : [ '/' ] } );
  test.identical( got, expected );
  test.true( got.array[ 0 ] === src );
  test.true( got.array.length === 1 );

  // yyy
  // test.case = 'self and empty selectors';
  // var expected = { array : [ src ] };
  // var got = _.resolve( src, { b : '', array : [ '/', '' ] } );
  // test.identical( got, expected );
  // test.true( got.array[ 0 ] === src );
  // test.true( got.array.length === 1 );

  /* */

  test.close( 'map' );

  /* - */

}

//

function iteratorResult( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }

  /* */

  test.case = 'control';
  var expected = [ 'b2', { a : { c1 : 1, c2 : 'c2' }, b : { name : 'name1' } } ];
  var got = _.resolve( src, [ 'b/b2', { a : 'c', b : 'a/map' } ] );
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ][ 'a' ] === src.c );
  test.true( got[ 1 ][ 'b' ] === src.a.map );

  var expected =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }
  test.identical( src, expected );

  /* */

  test.case = 'iterator.result';
  var expected = [ 'b2', { a : { c1 : 1, c2 : 'c2' }, b : { name : 'name1' } } ];
  var it = _.resolve.head( _.resolve, [ src, [ 'b/b2', { a : 'c', b : 'a/map' } ] ] );
  var got = it.perform();
  test.true( got === it );
  test.identical( it.result, expected );
  var got = it.result;
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ][ 'a' ] === src.c );
  test.true( got[ 1 ][ 'b' ] === src.a.map );

  var expected =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }
  test.identical( src, expected );

  /* - */

}

//

function resolveComposite( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : false, c2 : [ 'c21', 'c22' ] },
    complex : { bools : [ true, false ], string : 'is', numbers : [ 1, 3 ], strings : [ 'or', 'and' ], empty : [] },
  }

  /* */

  test.case = 'compositeSelecting : 0, custom onSelectorReplicate';
  var expected = [ 'Some test with inlined', 'b2', '.' ];
  var selector = 'Some test with inlined {b/b2}.';
  var got = _.resolve({ src, selector, onSelectorReplicate, compositeSelecting : 0 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1';
  var expected = 'Some test with inlined b2.';
  var selector = 'Some test with inlined {b/b2}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, array';
  var expected = [ 'Some test with inlined c21 and b2.', 'Some test with inlined c22 and b2.' ];
  var selector = 'Some test with inlined {c/c2} and {b/b2}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, array + number + boolean';
  var expected =
  [
    'Some test with inlined c21 and 1 and false.',
    'Some test with inlined c22 and 1 and false.'
  ]
  var selector = 'Some test with inlined {c/c2} and {b/b1} and {c/c1}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 0, set manually';
  var expected =
  [
    'Some test with inlined c21 and 1 and false.',
    'Some test with inlined c22 and 1 and false.'
  ]
  var selector = 'Some test with inlined {c/c2} and {b/b1} and {c/c1}.';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite(),
    onSelectorDown : _.resolver.functor.onSelectorDownComposite(),
  });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 0, set manually only onSelectorReplicate';
  var expected =
  [
    'Some test with inlined ',
    [ 'c21', 'c22' ],
    ' and ',
    1,
    ' and ',
    false,
    '.'
  ]
  var selector = 'Some test with inlined {c/c2} and {b/b1} and {c/c1}.';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite(),
  });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, set manually only onSelectorReplicate';
  var expected =
  [
    'Some test with inlined c21 and 1 and false.',
    'Some test with inlined c22 and 1 and false.'
  ]
  var selector = 'Some test with inlined {c/c2} and {b/b1} and {c/c1}.';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite(),
  });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, vector of array + vector of number + vector of boolean';
  var expected =
  [
    'This is combination of bools true, a string is, a numbers 1 and strings or.',
    'This is combination of bools false, a string is, a numbers 3 and strings and.'
  ]
  var selector = 'This is combination of bools {complex/bools}, a string {complex/string}, a numbers {complex/numbers} and strings {complex/strings}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, empty vector';
  var expected = [];
  var selector = 'This is empty {complex/empty}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  /* */

  test.case = 'compositeSelecting : 1, string and empty vector';
  var expected = [];
  var selector = 'This is combination a string {complex/string} and empty {complex/empty}.';
  var got = _.resolve({ src, selector, compositeSelecting : 1 });
  test.identical( got, expected );

  // complex : { bools : [ true, false ], string : 'is', numbers : [ 1, 3 ], strings : [ 'or', 'and' ] },

  /* */

  function onSelectorReplicate( o )
  {
    let it = this;
    let selector = o.selector;

    if( !_.strIs( selector ) )
    return;

    let selector2 = _.strSplit( selector, [ '{', '}' ] );

    if( selector2.length < 5 )
    return;

    if( selector2.length === 5 )
    if( selector2[ 0 ] === '' && selector2[ 1 ] === '{' && selector2[ 3 ] === '}' && selector2[ 4 ] === '' )
    return selector2[ 2 ];

    selector2 = _.strSplitsCoupledGroup({ splits : selector2, prefix : '{', postfix : '}' });
    selector2 = selector2.map( ( els ) => _.arrayIs( els ) ? els.join( '' ) : els );

    return selector2;
  }

}

//

function resolveDecoratedFixes( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : 1, c2 : 'c2' },
  }

  function onSelectorReplicate( o )
  {
    let it = this;
    let selector = o.selector;
    if( !_.strIs( selector ) )
    return;
    selector = _.strUnjoin( selector, [ '{', _.any, '}' ] );
    if( selector )
    return selector[ 1 ];
  }

  /* */

  test.open( 'primitive' );

  /* */

  test.case = 'first level';
  var expected = { map : { name : 'name1' }, value : 13 };
  var selector = '{a}';
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got === src.a );

  /* */

  test.case = 'second level';
  var expected = { name : 'name1' };
  var selector = '{a/map}';
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got === src.a.map );

  test.close( 'primitive' );

  /* */

  test.open( 'primitive, lack of fixes' );

  /* */

  test.case = 'first level, lack of fixes';
  var expected = 'a';
  var selector = 'a';
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );

  /* */

  test.case = 'second level, lack of fixes';
  var expected = 'a/map';
  var selector = 'a/map';
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );

  test.close( 'primitive, lack of fixes' );

  /* */

  test.open( 'array' );

  /* */

  test.case = 'first level selector';
  var expected = [ { b1 : 1, b2 : 'b2' }, { c1 : 1, c2 : 'c2' } ];
  var selector = [ '{b}', '{c}' ];
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b );
  test.true( got[ 1 ] === src.c );

  /* */

  test.case = 'second level selector';
  var expected = [ 'b2', { c1 : 1, c2 : 'c2' } ];
  var selector = [ '{b/b2}', '{c}' ];
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ] === src.c );

  /* */

  test.case = 'complex selector';
  var expected = [ 'b2', { a : { c1 : 1, c2 : 'c2' }, b : { name : 'name1' } } ];
  var selector = [ '{b/b2}', { a : '{c}', b : '{a/map}' } ];
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got[ 0 ] === src.b.b2 );
  test.true( got[ 1 ][ 'a' ] === src.c );
  test.true( got[ 1 ][ 'b' ] === src.a.map );

  test.close( 'array' );

  /* */

  test.open( 'array, lack of fixes' );

  /* */

  test.case = 'first level selector';
  var selector = [ 'b', 'c' ];
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  /* */

  test.case = 'second level selector';
  var selector = [ 'b/b2', 'c' ];
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  /* */

  test.case = 'complex selector';
  var selector = [ 'b/b2', { a : 'c', b : 'a/map' } ];
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  test.close( 'array, lack of fixes' );

  /* */

  test.open( 'map' );

  /* */

  test.case = 'first level selector';
  var expected = { b : { b1 : 1, b2 : 'b2' }, c : { c1 : 1, c2 : 'c2' } };
  var selector = { b : '{b}', c : '{c}' };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got.b === src.b );
  test.true( got.c === src.c );

  /* */

  test.case = 'second level selector';
  var expected = { b2 : 'b2', c : { c1 : 1, c2 : 'c2' } };
  var selector = { b2 : '{b/b2}', c : '{c}' };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got.b2 === src.b.b2 );
  test.true( got.c === src.c );

  /* */

  test.case = 'complex selector';
  var expected = { b : 'b2', array : [ { c1 : 1, c2 : 'c2' }, { name : 'name1' } ] };
  var selector = { b : '{b/b2}', array : [ '{c}', '{a/map}' ] };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got[ 'b' ] === src.b.b2 );
  test.true( got[ 'array' ][ 0 ] === src.c );
  test.true( got[ 'array' ][ 1 ] === src.a.map );

  test.close( 'map' );

  /* */

  test.open( 'map, lack of fixes' );

  /* */

  test.case = 'first level selector';
  var selector = { b : 'b', c : 'c' };
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  /* */

  test.case = 'second level selector';
  var selector = { b2 : 'b/b2', c : 'c' };
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  /* */

  test.case = 'complex selector';
  var selector = { b : 'b/b2', array : [ 'c', 'a/map' ] };
  var expected = selector;
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, selector );
  test.true( got !== selector );

  test.close( 'map, lack of fixes' );

  /* */

  test.open( 'mixed lack of fixes' );

  /* */

  test.case = 'first level selector';
  var expected = { b : 'b', c : { c1 : 1, c2 : 'c2' } };
  var selector = { b : 'b', c : '{c}' };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got.c === src.c );

  /* */

  test.case = 'second level selector';
  var expected = { b2 : 'b2', c : 'c' };
  var selector = { b2 : '{b/b2}', c : 'c' };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got.b2 === src.b.b2 );

  /* */

  test.case = 'complex selector';
  var expected = { b : 'b2', array : [ 'c', { name : 'name1' } ] };
  var selector = { b : '{b/b2}', array : [ 'c', '{a/map}' ] };
  var got = _.resolve({ src, selector, onSelectorReplicate });
  test.identical( got, expected );
  test.true( got.b === src.b.b2 );
  test.true( got.array[ 1 ] === src.a.map );

  test.close( 'mixed lack of fixes' );

}

//

function resolveDecoratedInfix( test )
{

  var src =
  {
    a : { map : { name : 'name1' }, value : 13 },
    b : { b1 : 1, b2 : 'b2' },
    c : { c1 : false, c2 : [ 'c21', 'c22' ] },
  }

  /* */

  test.open( 'compositeSelecting : 1' );

  /* */

  test.case = '{head::b/b1}';
  var expected = 1;
  var selector = '{head::b/b1}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'b';
  var expected = 'b';
  var selector = 'b';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate,
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = '{head::c/c2}';
  var expected =
  [
    'c21',
    'c22'
  ]
  var selector = '{head::c/c2}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::c/c2, isStrippedSelector : 0';
  var expected = 'head::c/c2';
  var selector = 'head::c/c2';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate, isStrippedSelector : 0 }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::c/c2, isStrippedSelector : 1';
  var expected =
  [
    'c21',
    'c22'
  ]
  var selector = 'head::c/c2';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate, isStrippedSelector : 1 }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'composite selector';
  var expected =
  [
    'Some test with inlined c21 and 1 and false.',
    'Some test with inlined c22 and 1 and false.'
  ]
  var selector = 'Some test with inlined {head::c/c2} and {head::b/b1} and {head::c/c1}.';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  test.close( 'compositeSelecting : 1' );

  /* - */

  test.open( 'compositeSelecting : 0' );

  /* */

  test.case = 'head::b/b1';
  var expected = 1;
  var selector = 'head::b/b1';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate,
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'b';
  var expected = 'b';
  var selector = 'b';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate,
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::c/c2';
  var expected =
  [
    'c21',
    'c22'
  ]
  var selector = 'head::c/c2';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate,
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = '{head::c/c2';
  var expected =
  [
    'c21',
    'c22'
  ]
  var selector = '{head::c/c2';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    onSelectorReplicate,
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.close( 'compositeSelecting : 0' );

  function onSelectorReplicate( o )
  {
    let selector = o.selector;
    if( !_.strHas( selector, '::' ) )
    return;
    // return _.strIsolateRightOrAll( selector, '::' )[ 2 ];
    return selector;
  }

  function onSelectorUndecorate()
  {
    let it = this;
    if( !_.strHas( it.selector, '::' ) )
    return;
    it.selector = _.strIsolateRightOrAll( it.selector, '::' )[ 2 ];
  }

}

//

function resolveRecursive( test )
{

  /* - */

  test.open( 'compositeSelecting : 0' );

  var src =
  {
    a : { map : { name : '::c/c2/#0' }, value : 13 },
    b : { b1 : '::a/map/name', b2 : 'b2' },
    c : { c1 : false, c2 : [ 'c21', 'c22' ] },
  }

  /* */

  test.case = 'head::b/b1';
  var expected = 'c21';
  var selector = 'head::b/b1';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    recursive : Infinity,
    onSelectorUndecorate,
    onSelectorReplicate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::b/b1, recursive : 0';
  var expected = '::a/map/name';
  var selector = 'head::b/b1';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    recursive : 0,
    onSelectorUndecorate,
    onSelectorReplicate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::b/b1, recursive : 1';
  var expected = '::c/c2/#0';
  var selector = 'head::b/b1';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    recursive : 1,
    onSelectorUndecorate,
    onSelectorReplicate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'head::b/b1, recursive : 2';
  var expected = 'c21';
  var selector = 'head::b/b1';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 0,
    recursive : 2,
    onSelectorUndecorate,
    onSelectorReplicate,
  });
  test.identical( got, expected );

  /* */

  test.close( 'compositeSelecting : 0' );

  /* - */

  test.open( 'compositeSelecting : 1' );

  var src =
  {
    a : { map : { name : '{::c/c2/#0}' }, value : 13 },
    b : { b1 : '{::a/map/name}', b2 : 'b2' },
    c : { c1 : false, c2 : [ 'c21', 'c22' ] },
  }

  /* */

  test.case = '{head::b/b1}';
  var expected = 'c21';
  var selector = '{head::b/b1}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : Infinity,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = '{head::b/b1}, recursive : 0';
  var expected = '{::a/map/name}';
  var selector = '{head::b/b1}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 0,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = '{head::b/b1}, recursive : 1';
  var expected = '{::c/c2/#0}';
  var selector = '{head::b/b1}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = '{head::b/b1}, recursive : 2';
  var expected = 'c21';
  var selector = '{head::b/b1}';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 2,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.close( 'compositeSelecting : 1' );

  /* - */

  test.open( 'compositeSelecting : 1, composite strings' );

  var src =
  {
    a : { map : { name : '{::c/c2/#0}' }, value : 13 },
    b : { b1 : '{::a/map/name}', b2 : [ 'b2-a', 'b2-b' ] },
    c : { c1 : false, c2 : [ 'c21', 'c22' ] },
  }

  /* */

  test.case = 'begin {head::b/b1} mid {b/b2} end';
  var expected = [ 'begin c21 mid b2-a end', 'begin c21 mid b2-b end' ];
  var selector = 'begin {head::b/b1} mid {::b/b2} end';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : Infinity,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'begin {head::b/b1} mid {b/b2} end, recursive : 0';
  var expected = [ 'begin {::a/map/name} mid b2-a end', 'begin {::a/map/name} mid b2-b end' ];
  var selector = 'begin {head::b/b1} mid {::b/b2} end';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 0,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'begin {head::b/b1} mid {b/b2} end, recursive : 1';
  var expected = [ 'begin {::c/c2/#0} mid b2-a end', 'begin {::c/c2/#0} mid b2-b end' ];
  var selector = 'begin {head::b/b1} mid {::b/b2} end';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.case = 'begin {head::b/b1} mid {b/b2} end, recursive : 2';
  var expected = [ 'begin c21 mid b2-a end', 'begin c21 mid b2-b end' ];
  var selector = 'begin {head::b/b1} mid {::b/b2} end';
  var got = _.resolve
  ({
    src,
    selector,
    compositeSelecting : 1,
    recursive : 2,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, expected );

  /* */

  test.close( 'compositeSelecting : 1, composite strings' );

  /* - */

  test.open( 'compositeSelecting : 1, composite strings, deep' );

  var src =
  {
    var :
    {
      dir :
      {
        x : 13,
      }
    },
    about :
    {
      user : 'user1',
    },
    result :
    {
      dir :
      {
        userX : '{::about/::user} - {::var/::dir/::x}'
      }
    },
  }

  /* */

  test.case = 'explicit';
  var exp = 'user1 - 13 !';
  var got = _.resolve
  ({
    src,
    selector : '{::result/::dir/::userX} !',
    compositeSelecting : 1,
    recursive : Infinity,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, exp );
  console.log( got );

  /* */

  test.case = 'implicit';
  var exp = '{::about/::user} - {::var/::dir/::x} !';
  var got = _.resolve
  ({
    src,
    selector : '{::result/::dir/::userX} !',
    compositeSelecting : 1,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, exp );
  console.log( got );

  /* */

  test.case = 'recursive : 0';
  var exp = '{::about/::user} - {::var/::dir/::x} !';
  var got = _.resolve
  ({
    src,
    selector : '{::result/::dir/::userX} !',
    compositeSelecting : 1,
    recursive : 0,
    onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
    onSelectorUndecorate,
  });
  test.identical( got, exp );
  console.log( got );

  /* */

  test.case = 'error';

  var src =
  {
    var :
    {
      dir :
      {
        x : 13,
      }
    },
    about :
    {
      user : 'user1',
    },
    result :
    {
      dir :
      {
        userX : '{::about/::user} - {::var/::dir/::x}'
      }
    },
  }

  test.shouldThrowErrorSync
  (
    () =>
    {
      var got = _.resolve
      ({
        src,
        selector : '{result::dir/userX} !',
        compositeSelecting : 1,
        recursive : Infinity,
        onSelectorReplicate : _.resolver.functor.onSelectorReplicateComposite({ onSelectorReplicate }),
        onSelectorUndecorate,
        missingAction : 'throw',
      });
    },
    ( err ) =>
    {
      let exp =
`
      Failed to resolve {result::dir/userX} !
      Cant select result::dir/userX from {- Map.polluted with 3 elements -}
        because result::dir does not exist
        fall at "/dir"
`
      test.equivalent( _.ct.strip( err.originalMessage ), exp );
    }
  );

  /* */

  test.close( 'compositeSelecting : 1, composite strings, deep' );

  /* - */

  function onSelectorReplicate( o )
  {
    let selector = o.selector;
    if( !_.strIs( selector ) )
    return;
    if( !_.strHas( selector, '::' ) )
    return;
    return selector;
  }

  function onSelectorUndecorate()
  {
    let it = this;
    if( !_.strIs( it.selector ) )
    return;
    if( !_.strHas( it.selector, '::' ) )
    return;
    it.selector = _.strIsolateRightOrAll( it.selector, '::' )[ 2 ];
  }

}

//

function resolveMaybe( test )
{

  /* */

  test.case = 'control';

  var src =
  {
    b : { b1 : 1, b2 : '1' },
    c : { c1 : 1, c2 : '2' },
  }

  test.shouldThrowErrorSync
  (
    () =>
    {
      var options =
      {
        src,
        selector : 'd',
      }
      var got = _.resolve( options );
    },
    ( err ) =>
    {
      var exp =
`
Failed to resolve d
Cant select d from {- Map.polluted with 2 elements -}
  because d does not exist
  fall at "/d"
`
      test.equivalent( _.ct.strip( err.originalMessage ), exp );
    }
  );

  /* */

  test.case = 'basic';
  var src =
  {
    b : { b1 : 1, b2 : '1' },
    c : { c1 : 1, c2 : '2' },
  }
  var expected = undefined;
  var options =
  {
    src,
    selector : 'd',
  }
  var got = _.resolver.resolveMaybe( options );
  test.identical( got, expected );

  /* */

}

//

/* xxx : implement similar test for selector */
function optionMissingAction( test )
{

  /* */

  test.case = `control`;

  var src =
  {
    k1 : '1'
  }
  var exp = '1';
  var got = _.resolver.resolve
  ({
    src,
    selector : 'k1',
  });
  test.identical( got, exp );

  /* */

  act({ missingAction : 'ignore' });
  act({ missingAction : 'undefine' });
  act({ missingAction : 'error' });
  act({ missingAction : 'throw' });

  /* - */

  function act( env )
  {

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, basic`;
    try
    {
      var errorMessage =
`
      Failed to resolve k2
      Cant select k2 from {- Map.polluted with 1 elements -}
      because k2 does not exist
      fall at "/k2"
`;

      var src =
      {
        k1 : '1'
      }
      var iterator =
      {
        src,
        selector : 'k2',
        missingAction : env.missingAction,
      }
      var got = _.resolver.resolve( iterator );
      var exp = undefined;
      if( env.missingAction === 'error' )
      {
        test.true( _.errIs( got ) );
        test.true( got instanceof _.looker.LookingError );
        test.identical( got.LookingError, true );
        test.identical( got.ResolvingError, true );
        test.equivalent( _.ct.strip( got.originalMessage ), errorMessage );
        test.true( got === iterator.error );
      }
      else
      {
        test.identical( got, exp );
      }

      test.nil( env.missingAction, 'throw' );

    }
    catch( got )
    {
      test.true( _.errIs( got ) );
      test.identical( env.missingAction, 'throw' );
      test.true( got instanceof _.looker.LookingError );
      test.identical( got.LookingError, true );
      test.identical( got.ResolvingError, true );
      test.true( got === iterator.error );
      test.equivalent( _.ct.strip( got.originalMessage ), errorMessage );
      if( env.missingAction !== 'throw' )
      throw got;
    }

    /* */

  }

}

//

function resolveUndefined( test )
{

  /* xxx : similar test for resolverAdv */

  act({ missingAction : 'ignore' });
  act({ missingAction : 'undefine' });
  act({ missingAction : 'error' });
  act({ missingAction : 'throw' });

  /* - */

  function act( env )
  {

    /* */

    test.case = `${_.entity.exportStringSolo( env )}, basic`;

    var src =
    {
      k1 : undefined,
    }
    var iterator =
    {
      src,
      selector : 'k1',
      missingAction : env.missingAction,
    }
    var got = _.resolver.resolve( iterator );
    var exp = undefined;
    test.identical( got, exp );
    test.identical( iterator.error, null );

    /* */

  }

}

// --
// declare
// --

const Proto =
{

  name : 'Tools.l6.Resolver',
  silencing : 1,
  routineTimeOut : 15000,

  context :
  {
  },

  tests :
  {

    trivial,
    resolveMultiple,
    iteratorResult,
    resolveComposite,
    resolveDecoratedFixes,
    resolveDecoratedInfix,
    resolveRecursive,
    resolveMaybe,
    optionMissingAction,
    resolveUndefined,

  }

}

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
