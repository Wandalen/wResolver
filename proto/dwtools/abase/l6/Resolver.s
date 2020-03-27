( function _Resolver_s_() {

'use strict';


/**
 * Collection of routines to resolve complex data structures.
  @module Tools/base/Resolver
*/

/**
 * @file l6/Resolver.s.
 */

/**
 * Collection of routines to resolve a sub-structure from a complex data structure.
  @namespace Tools( module::Resolver )
  @memberof module:Tools/base/Resolver
*/

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../dwtools/Tools.s' );

  _.include( 'wLooker' );
  _.include( 'wReplicator' );

  _.include( 'wSelector' );
  _.include( 'wPathTools' );

}

let _global = _global_;
let _ = _global_.wTools;
let Parent = _.Replicator;
_.resolver = _.resolver || Object.create( null );
_.resolver.functor = _.resolver.functor || Object.create( null );

_.assert( !!_realGlobal_ );

// --
// extend looker
// --

function resolve_pre( routine, args )
{

  let o = args[ 0 ]
  if( args.length === 2 )
  {
    if( Self.iterationIs( args[ 0 ] ) )
    o = { it : args[ 0 ], selector : args[ 1 ] }
    else
    o = { src : args[ 0 ], selector : args[ 1 ] }
  }

  _.routineOptionsPreservingUndefines( routine, o );

  if( o.root === null )
  o.root = o.src;

  if( o.compositeSelecting )
  {

    if( o.onSelectorReplicate === onSelectorReplicate || o.onSelectorReplicate === null )
    o.onSelectorReplicate = _.resolver.functor.onSelectorReplicateComposite();
    if( o.onSelectorDown === null )
    o.onSelectorDown = _.resolver.functor.onSelectorDownComposite();

    _.assert( _.routineIs( o.onSelectorReplicate ) );
    _.assert( _.routineIs( o.onSelectorDown ) );

  }

  return o;
}

//

function resolve_body( o )
{

  _.assert( !o.recursive || !!o.onSelectorReplicate, () => 'For recursive selection onSelectorReplicate should be defined' );
  _.assert( o.it === null || o.it.constructor === Self.constructor );

  return multipleSelect( o.selector );

  /* */

  function multipleSelect( selector )
  {
    let o2 =
    {
      src : selector,
      onUp,
      onDown,
    }

    o2.iterationPreserve = Object.create( null );
    o2.iterationPreserve.composite = false;
    o2.iterationPreserve.compositeRoot = null;

    o2.iteratorExtension = Object.create( null );
    o2.iteratorExtension.selectMultipleOptions = o;

    let it = _.replicateIt( o2 );

    return it.dst;
  }

  /* */

  function singleOptions()
  {
    let it = this;
    let single = _.mapExtend( null, o );
    single.replicateIteration = it;

    single.selector = null;
    single.visited = null;
    single.selected = false;

    delete single.onSelectorUp;
    delete single.onSelectorDown;
    delete single.onSelectorReplicate;
    delete single.recursive;
    delete single.dst;
    delete single.root;
    delete single.compositeSelecting;
    delete single.compositePrefix;
    delete single.compositePostfix;

    _.assert( !single.it || single.it.constructor === Self.constructor );

    return single;
  }

  /* */

  function selectSingle( visited )
  {
    let it = this;

    _.assert( _.strIs( it.src ) );
    _.assert( arguments.length === 1 );

    let op = singleOptions.call( it );
    op.selector = it.src;
    op.visited = visited;
    op.selected = false;

    if( _.longHas( visited, op.selector ) )
    return op;

    _.assert( _.strIs( op.selector ) );
    _.assert( !_.longHas( visited, op.selector ), () => `Loop selecting ${op.selector}` );

    visited.push( op.selector );

    _.assert( _.strIs( op.selector ) );

    op.result = _.selectSingle( op );
    op.selected = true;

    return op;
  }

  /* */

  function onUp()
  {
    let it = this;
    let selector
    let visited = [];
    let counter = 0;

    // if( _.strIs( it.src ) && _.strHas( it.src, '*::' ) )
    // debugger;
    selector = o.onSelectorReplicate.call( it, { selector : it.src, counter } );

    do
    {

      if( _.strIs( selector ) )
      {
        {
          it.src = selector;
          it.iterable = null;
          it.srcChanged();
          let single = selectSingle.call( it, visited );
          selector = undefined;
          if( single.result !== undefined && o.recursive && visited.length <= o.recursive )
          {
            counter += 1;
            selector = o.onSelectorReplicate.call( it, { selector : single.result, counter } );
            if( selector === undefined )
            {
              if( single.selected )
              it.dst = single.result;
              it.continue = false;
              it.dstMaking = false; /* xxx */
            }
          }
          else
          {
            if( single.selected )
            it.dst = single.result;
            it.continue = false;
            it.dstMaking = false; /* xxx */
          }
        }
      }
      else if( selector !== undefined )
      {
        if( selector && selector.composite === _.resolver.composite )
        {
          if( !it.compositeRoot )
          it.compositeRoot = it;
          it.composite = true;
        }
        it.src = selector;
        it.iterable = null;
        it.srcChanged();
        selector = undefined;
      }

    }
    while( selector !== undefined );

    if( o.onSelectorUp )
    o.onSelectorUp.call( it, o );
  }

  /* */

  function onDown()
  {
    let it = this;
    if( o.onSelectorDown )
    o.onSelectorDown.call( it, o );
  }

  /* */

}

_.routineExtend( resolve_body, _.selector.selectSingle.body );

var defaults = resolve_body.defaults;
defaults.root = null;
defaults.onSelectorUp = null;
defaults.onSelectorDown = null;
defaults.onSelectorReplicate = onSelectorReplicate;
defaults.onSelectorUndecorate = _.selector.onSelectorUndecorate;
defaults.recursive = 0;
defaults.compositeSelecting = 0;

_.assert( _.routineIs( defaults.onSelectorUndecorate ) );

//

/**
 * @summary Selects elements from source object( src ) using provided pattern( selector ).
 * @param {} src Source entity.
 * @param {String} selector Pattern that matches against elements in a entity.
 *
 * @example //resolve element with key 'a1'
 * _.resolve( { a1 : 1, a2 : 2 }, 'a1' ); // 1
 *
 * @example //resolve any that starts with 'a'
 * _.resolve( { a1 : 1, a2 : 2 }, 'a*' ); // { a1 : 1, a2 : 1 }
 *
 * @example //resolve with constraint, only one element should be selected
 * _.resolve( { a1 : 1, a2 : 2 }, 'a*=1' ); // error
 *
 * @example //resolve with constraint, two elements
 * _.resolve( { a1 : 1, a2 : 2 }, 'a*=2' ); // { a1 : 1, a2 : 1 }
 *
 * @example //resolve inner element using path selector
 * _.resolve( { a : { b : { c : 1 } } }, 'a/b' ); //{ c : 1 }
 *
 * @example //resolve value of each property with name 'x'
 * _.resolve( { a : { x : 1 }, b : { x : 2 }, c : { x : 3 } }, '*\/x' ); //{a: 1, b: 2, c: 3}
 *
 * @example // resolve root
 * _.resolve( { a : { b : { c : 1 } } }, '/' );
 *
 * @function resolve
 * @memberof module:Tools/base/Resolver.Tools( module::Resolver )
*/

let resolve = _.routineFromPreAndBody( resolve_pre, resolve_body );

//

function onSelectorReplicate( o )
{
  let it = this;
  if( _.strIs( o.selector ) )
  return o.selector;
}

//

function onSelectorReplicateComposite( fop )
{

  fop = _.routineOptions( onSelectorReplicateComposite, arguments );
  fop.prefix = _.arrayAs( fop.prefix );
  fop.postfix = _.arrayAs( fop.postfix );
  fop.onSelectorReplicate = fop.onSelectorReplicate || onSelectorReplicate;

  _.assert( _.strsAreAll( fop.prefix ) );
  _.assert( _.strsAreAll( fop.postfix ) );
  _.assert( _.routineIs( fop.onSelectorReplicate ) );

  return function onSelectorReplicateComposite( o )
  {
    let it = this;
    let selector = o.selector;

    if( !_.strIs( selector ) )
    return;

    let selector2 = _.strSplitFast
    ({
      src : selector,
      delimeter : _.arrayAppendArrays( [], [ fop.prefix, fop.postfix ] ),
    });

    if( selector2[ 0 ] === '' )
    selector2.splice( 0, 1 );
    if( selector2[ selector2.length-1 ] === '' )
    selector2.pop();

    if( selector2.length < 3 )
    {
      if( fop.isStrippedSelector )
      return fop.onSelectorReplicate.call( it, o );
      else
      return;
    }

    if( selector2.length === 3 )
    if( _.strsEquivalentAny( fop.prefix, selector2[ 0 ] ) && _.strsEquivalentAny( fop.postfix, selector2[ 2 ] ) )
    {
      return fop.onSelectorReplicate.call( it, _.mapExtend( null, o, { selector : selector2[ 1 ] } ) );
    }

    selector2 = _.strSplitsCoupledGroup({ splits : selector2, prefix : '{', postfix : '}' });

    if( fop.onSelectorReplicate )
    selector2 = selector2.map( ( split ) =>
    {
      if( !_.arrayIs( split ) )
      return split;

      _.assert( split.length === 3 );

      let split1 = fop.onSelectorReplicate.call( it, _.mapExtend( null, o, { selector : split[ 1 ] } ) );
      if( split1 === undefined )
      {
        return split.join( '' );
      }
      else
      {
        if( fop.rewrapping )
        return split[ 0 ] + split1 + split[ 2 ];
        else
        return split;
      }
    });

    selector2 = selector2.map( ( split ) => _.arrayIs( split ) ? split.join( '' ) : split );
    selector2.composite = _.resolver.composite;

    return selector2;
  }

  function onSelectorReplicate( o )
  {
    return o.selector;
  }

}

onSelectorReplicateComposite.defaults =
{
  prefix : '{',
  postfix : '}',
  onSelectorReplicate : null,
  isStrippedSelector : 0, /* treat selector beyond affixes like "pre::c/c2" as selector */
  rewrapping : 1,
}

//

function onSelectorDownComposite( fop )
{
  return function onSelectorDownComposite()
  {
    let it = this;
    if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolver.composite )
    {
      it.dst = _.strJoin( it.dst );
    }
  }
}

// --
// declare looker
// --

let Resolver = Object.create( Parent );

let Iterator = Resolver.Iterator = _.mapExtend( null, Resolver.Iterator );

let Iteration = Resolver.Iteration = _.mapExtend( null, Resolver.Iteration );

let IterationPreserve = Resolver.IterationPreserve = _.mapExtend( null, Resolver.IterationPreserve );

// --
// declare
// --

let composite = Symbol.for( 'composite' );

var FunctorExtension =
{
  ... _.selector.functor,
  onSelectorReplicateComposite,
  onSelectorDownComposite,
}

let ResolverExtension =
{

  resolve,

  onSelectorReplicate,
  composite,

}

let SupplementTools =
{

  Resolver,
  resolve,

}

let Self = Resolver;
_.mapSupplement( _, SupplementTools );
_.mapSupplement( _.resolver, ResolverExtension );
_.mapSupplement( _.resolver.functor, FunctorExtension );

if( _.accessor && _.accessor.forbid )
{
  _.accessor.forbid( _.select, { composite : 'composite' } );
  _.accessor.forbid( _.selector, { composite : 'composite' } );
}

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
