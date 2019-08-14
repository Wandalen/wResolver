( function _Resolver_test_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wLogger' );

  require( '../l6/Resolver.s' );

}

var _global = _global_;
var _ = _global_.wTools;

// --
// tests
// --

function selectorParse( test )
{
  let self = this;
  let r = _.Resolver;

  test.case = 'single inline, single split';
  var expected =
  [
    [
      [ "a", "::", "b" ]
    ]
  ]
  var got = r.selectorParse( '{a::b}' );
  test.identical( got, expected );

  test.case = 'implicit inline, single split';
  var expected =
  [
    [
      [ "a", "::", "b" ]
    ]
  ]
  var got = r.selectorParse( 'a::b' );
  test.identical( got, expected );

  test.case = 'single inline, several splits';
  var expected =
  [
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
  ]
  var got = r.selectorParse( '{a::b/c::d}' );
  test.identical( got, expected );

  test.case = 'implicit inline, several splits';
  var expected =
  [
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
  ]
  var got = r.selectorParse( 'a::b/c::d' );
  test.identical( got, expected );

  test.case = 'single inline, several splits, non-selector sides';
  var expected =
  [
    'x',
    [
      [ 'a', '::', 'b' ],
      [ 'c', '::', 'd' ]
    ],
    'y'
  ]
  var got = r.selectorParse( 'x{a::b/c::d}y' );
  test.identical( got, expected );

  test.case = 'several inlines';
  var expected =
  [
    "x",
    [
      [ "a", "::", "b" ],
      [ "c", "::", "d" ]
    ],
    "y",
    [
      [ "ee", "::", "ff" ],
      [ "gg", "::", "hhh" ]
    ],
    "z",
  ]
  var got = r.selectorParse( 'x{a::b/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'several inlines, split without ::';
  var expected =
  [
    "x",
    [
      [ "a", "::", "b" ],
      [ "", "", "mid" ],
      [ "c", "::", "d" ]
    ],
    "y",
    [
      [ "ee", "::", "ff" ],
      [ "gg", "::", "hhh" ]
    ],
    "z",
  ]
  var got = r.selectorParse( 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'critical, no ::';
  var expected =
  [
    'x{mid}y{}z',
  ]
  var got = r.selectorParse( 'x{mid}y{}z' );
  test.identical( got, expected );

  test.case = 'critical, empty side';
  var expected =
  [
    'x',
    [
      [ 'aa', '::', '' ]
    ],
    'y',
    [
      [ '', '::', 'bb' ]
    ],
    'z',
    [
      [ '', '::', '' ]
    ]
  ]
  var got = r.selectorParse( 'x{aa::}y{::bb}z{::}' );
  test.identical( got, expected );

}

//

function selectorNormalize( test )
{
  let self = this;
  let r = _.Resolver;

  test.case = 'single inline, single split';
  var expected = '{a::b}';
  var got = r.selectorNormalize( '{a::b}' );
  test.identical( got, expected );

  test.case = 'implicit inline, single split';
  var expected = '{a::b}'
  var got = r.selectorNormalize( 'a::b' );
  test.identical( got, expected );

  test.case = 'single inline, several splits';
  var expected = '{a::b/c::d}';
  var got = r.selectorNormalize( '{a::b/c::d}' );
  test.identical( got, expected );

  test.case = 'implicit inline, several splits';
  var expected = '{a::b/c::d}';
  var got = r.selectorNormalize( 'a::b/c::d' );
  test.identical( got, expected );

  test.case = 'single inline, several splits, non-selector sides';
  var expected = 'x{a::b/c::d}y';
  var got = r.selectorNormalize( 'x{a::b/c::d}y' );
  test.identical( got, expected );

  test.case = 'several inlines';
  var expected = 'x{a::b/c::d}y{ee::ff/gg::hhh}z';
  var got = r.selectorNormalize( 'x{a::b/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'several inlines, split without ::';
  var expected = 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z';
  var got = r.selectorNormalize( 'x{a::b/mid/c::d}y{ee::ff/gg::hhh}z' );
  test.identical( got, expected );

  test.case = 'critical, no ::';
  var expected = 'x{mid}y{}z';
  var got = r.selectorNormalize( 'x{mid}y{}z' );
  test.identical( got, expected );

  test.case = 'critical, empty side';
  var expected = 'x{aa::}y{::bb}z{::}';
  var got = r.selectorNormalize( 'x{aa::}y{::bb}z{::}' );
  test.identical( got, expected );

}

// --
// declare
// --

var Self =
{

  name : 'Tools/base/l7/Resolver',
  silencing : 1,

  context :
  {
  },

  tests :
  {

    selectorParse,
    selectorNormalize,

  }

}

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
