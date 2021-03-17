( function _Resolver_s_()
{

'use strict';


/**
 * Collection of cross-platform routines to resolve complex data structures.
  @module Tools/base/Resolver
 */

/**
 * Collection of cross-platform routines to resolve a sub-structure from a complex data structure.
  @namespace Tools.Resolver
  @memberof module:Tools/base/Resolver
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  _.include( 'wLooker' );
  _.include( 'wReplicator' );
  _.include( 'wSelector' );
  _.include( 'wPathTools' );

}

let _global = _global_;
let _ = _global_.wTools;
let ParentReplicator = _.replicator.Replicator; /* xxx0 : inherit from looker directly? */
let ParentSelector = _.selector.Selector;
_.resolver = _.resolver || Object.create( _.replicator );
_.resolver.functor = _.resolver.functor || Object.create( _.selector.functor );

_.assert( !!_realGlobal_ );
_.assert( !!ParentReplicator );
_.assert( !!ParentSelector );

// --
// relations
// --

let Prime =
{

  ... _.mapExtend( null, _.selector.Looker.Prime ),
  ... _.mapExtend( null, _.replicator.Looker.Prime ),

  missingAction : 'throw',
  onSelectorUp : null,
  onSelectorDown : null,
  onSelectorReplicate : _onSelectorReplicateDefault,
  onSelectorUndecorate : _.selector.onSelectorUndecorate,
  onQuantitativeFail : null,
  recursive : 0,
  compositeSelecting : 0,

}

//

let SelectorPrime = Object.create( null );

SelectorPrime.replicateIteration = null;

// --
// extend looker
// --

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

// --
// extend looker
// --

function head( routine, args )
{
  _.assert( arguments.length === 2 );
  let o = routine.defaults.Looker.optionsFromArguments( args );

  if( _.routineIs( routine ) )
  o.Looker = o.Looker || routine.defaults;
  else if( _.objectIs( routine ) )
  o.Looker = o.Looker || routine;
  else _.assert( 0 );

  _.assert( _.routineIs( routine ) || _.auxIs( routine ) );
  if( _.routineIs( routine ) ) /* zzz : remove "if" later */
  _.assertMapHasOnly( o, routine.defaults );
  else if( routine !== null )
  _.assertMapHasOnly( o, routine );

  let it = o.Looker.optionsToIteration( null, o );

  return it;
}

// //
//
// function exec_body( it )
// {
//   debugger;
//   it.execIt.body.call( this, it );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   if( it.error && it.error !== true )
//   if( it.missingAction === 'throw' )
//   throw it.error;
//   return it.result;
// }

//

function optionsFromArguments( args )
{
  let o = args[ 0 ]
  if( args.length === 2 )
  {
    _.assert( !_.resolver.iterationIs( args[ 0 ] ) );
    o = { src : args[ 0 ], selector : args[ 1 ] }
  }

  _.assert( args.length === 1 || args.length === 2 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  return o;
}

//

function optionsToIteration( iterator, o )
{
  let it = ParentReplicator.optionsToIteration.call( this, iterator, o );
  _.assert( arguments.length === 2 );
  _.assert( it.compositeRoot !== undefined );
  _.assert( it.resolve1Options === undefined );
  _.assert( it.replicateIteration === undefined );
  _.assert( it.recursive === Infinity );

  _.assert( it.optionsForSelect === null );
  let optionsForSelect = it.iterator.optionsForSelect = it.selectorOptionsForSelectFrom( it );
  _.assert( it.optionsForSelect === it.iterator.optionsForSelect );

  return it;
}

//

function iteratorInitEnd( iterator )
{
  let looker = this;

  _.assert( iterator.iteratorProper( iterator ) );
  _.assert( !iterator.recursive || !!iterator.onSelectorReplicate, () => 'For recursive selection onSelectorReplicate should be defined' );
  _.assert( iterator.onUp2 === null ); /* xxx0 : hide this defaults. write test */
  _.assert( iterator.onDown2 === null );
  _.assert( iterator.Resolver === undefined );
  _.assert( iterator.resolvingRecursive === null );
  _.assert
  (
    _.longHas( [ 'undefine', 'ignore', 'throw', 'error' ], iterator.missingAction ),
    'Unknown value of option missing action', iterator.missingAction  /* qqq : template string in all files */
  );

  iterator.onUp2 = iterator.onUp;
  iterator.onDown2 = iterator.onDown;

  if( iterator.root === undefined )
  iterator.root = iterator.src;

  iterator.onUp = iterator._replicateUp;
  iterator.onDown = iterator._replicateDown;

  if( iterator.compositeSelecting )
  {

    if( iterator.onSelectorReplicate === iterator._onSelectorReplicateDefault || iterator.onSelectorReplicate === null )
    iterator.onSelectorReplicate = _.resolver.functor.onSelectorReplicateComposite();
    if( iterator.onSelectorDown === null )
    iterator.onSelectorDown = _.resolver.functor.onSelectorDownComposite();

    _.assert( _.routineIs( iterator.onSelectorReplicate ) );
    _.assert( _.routineIs( iterator.onSelectorDown ) );

  }

  iterator.srcForSelect = iterator.src;
  iterator.resolvingRecursive = iterator.recursive;
  iterator.recursive = Infinity;
  iterator.src = iterator.selector;

  return ParentReplicator.iteratorInitEnd.call( this, iterator );
}

//

function _replicateUp()
{
  let it = this;
  let selector
  let visited = [];
  let counter = 0;

  _.assert( !it.rit );

  selector = it.onSelectorReplicate({ selector : it.src, counter } );

  do
  {

    if( _.strIs( selector ) )
    {
      if( it.src !== selector )
      {
        it.src = selector;
        it.iterable = null;
        it.srcChanged();
      }
      let sit = it._select( visited );
      selector = undefined;
      /* xxx : write test resolving undefined */
      /* xxx : use sit.error? */
      // if( sit.result !== undefined && it.resolvingRecursive && visited.length <= it.resolvingRecursive )
      if( sit.error )
      {
        // if( !sit.error )
        it.errResolvingHandle
        ({
          missingAction : it.missingAction,
          selector : it.selector,
          err : sit.error,
        });
        if( it.missingAction === 'error' )
        it.dst = it.error;
        else
        it.dst = undefined;
        it.continue = false;
        it.dstMaking = false; /* xxx0 */
      }
      else
      {
        if( it.resolvingRecursive && visited.length <= it.resolvingRecursive )
        {
          counter += 1;
          selector = it.onSelectorReplicate({ selector : sit.result, counter });
          if( selector === undefined )
          {
            // if( !sit.error )
            it.dst = sit.result;
            it.continue = false;
            it.dstMaking = false; /* xxx0 */
          }
        }
        else
        {
          it.dst = sit.result;
          it.continue = false;
          it.dstMaking = false; /* xxx0 */
        }
      }
    }
    else if( selector !== undefined )
    {
      if( selector && selector.composite === _.resolver.compositeSymbol )
      {
        if( !it.compositeRoot )
        it.compositeRoot = it;
        it.composite = true;
      }
      if( it.src !== selector )
      {
        it.src = selector;
        it.iterable = null;
        it.srcChanged();
      }
      selector = undefined;
    }

  }
  while( selector !== undefined );

  if( it.onSelectorUp )
  it.onSelectorUp();

  if( it.onUp2 )
  it.onUp2.apply( it, arguments );

}

//

function _replicateDown()
{
  let it = this;

  if( it.onDown2 )
  it.onDown2.apply( it, arguments );

  if( it.onSelectorDown )
  it.onSelectorDown();
}

//

function selectorOptionsForSelectFrom( o ) /* xxx0 : redesign? */
{
  let it = this;

  _.assert( !!o.Looker.Selector );
  _.assert( !!o.Looker.Selector );

  let o2 = _.mapOnly_( null, o, it.Selector.Prime );
  o2.src = o.srcForSelect;
  o2.Looker = o.Looker.Selector;
  o2.recursive = Infinity;
  o2.onSelectorUndecorate = o.onSelectorUndecorate;
  o2.onQuantitativeFail = o.onQuantitativeFail;
  o2.onDownEnd = o.onDownEnd;
  o2.onUpBegin = o.onUpBegin;
  o2.onUpEnd = o.onUpEnd;

  delete o2.Looker;
  delete o2.recursive;
  delete o2.onUp;
  delete o2.onDown;
  delete o2.root;

  _.assert( !o2.it );
  _.assert( !o2.iterator );

  return o2;
}

//

function selectorIterate()
{
  let it = this;
  let result = ParentSelector.iterate.apply( it, arguments );
  _.assert( it.composite === undefined );
  _.assert( it.compositeRoot === undefined );
  return result;
}

//

function perform()
{
  let it = this;

  it.performBegin();

  try
  {
    it.iterate();
  }
  catch( err )
  {
    let err2 = it.errResolvingMake
    ({
      selector : it.selector,
      err,
    });
    if( !it.iterator.error || it.iterator.error === true )
    it.iterator.error = err2;
    throw err2;
  }

  it.performEnd();

  return it;
}

//

function performBegin()
{
  let it = this;
  ParentReplicator.performBegin.apply( it, arguments );
  _.assert( arguments.length === 0 );
  _.assert( it.compositeRoot !== undefined );
  return it;
}

//

function performEnd()
{
  let it = this;
  _.assert( it.compositeRoot !== undefined );
  ParentReplicator.performEnd.apply( it, arguments );
  return it;
}

//

function _select( visited )
{
  let it = this;

  _.assert( _.strIs( it.src ) );
  _.assert( arguments.length === 1 );

  if( _.longHas( visited, it.src ) ) /* qqq : cover please */
  return;

  let op = _.mapExtend( null, it.optionsForSelect ); /* xxx0 : optimize */
  op.replicateIteration = it;
  op.selector = it.src;
  op.visited = visited;

  _.assert( _.strIs( op.selector ) );
  _.assert( !_.longHas( visited, op.selector ), () => `Loop selecting ${op.selector}` );

  visited.push( op.selector );

  _.assert( _.strIs( op.selector ) );
  _.assert( !!it.Selector );

  op.Looker = it.Selector;
  _.assert( _.routineIs( op.Looker.exec ) );

  let sit = op.Looker.execIt( op );

  _.assert( sit.iterator === op );
  _.assert( sit.iterator.state === 2 );

  return sit;
}

// --
// err
// --

function errResolvingMake( o )
{
  let it = this;
  let rit = it.replicateIteration ? it.replicateIteration : it;
  _.assertRoutineOptions( errResolvingMake, arguments );
  _.assert( arguments.length === 1 );

  if( o.err && o.err.ResolvingError )
  return o.err;

  o.err = it.errMake( 'Failed to resolve', _.ct.format( _.entity.exportStringShort( o.selector ), 'path' ), '\n', o.err );
  _._errFields( o.err, { ResolvingError : true } );

  return o.err;
}

errResolvingMake.defaults =
{
  selector : null,
  err : null,
}

//

function errResolvingHandle( o )
{
  let it = this;

  _.assertRoutineOptions( errResolvingHandle, arguments );
  _.assert( arguments.length === 1 );

  if( o.missingAction === 'undefine' || o.missingAction === 'ignore' )
  {
    it.iterator.error = it.error || true;
    return;
  }

  if( o.missingAction === 'throw' )
  throw errMake();
  else
  return errMake();

  function errMake()
  {
    if( it.error && it.error !== true )
    return it.error;
    if( _.routineIs( o.err ) )
    o.err = o.err();
    if( !o.err || !o.err.ResolvingErrror )
    o.err = it.errResolvingMake
    ({
      selector : o.selector,
      err : o.err,
    });
    it.iterator.error = o.err;
    return o.err;
  }

}

errResolvingHandle.defaults =
{
  missingAction : null,
  selector : null,
  err : null,
}

// --
//
// --

function _onSelectorReplicateDefault( o )
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
    _.assert( !it.rit );
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
    selector2.composite = _.resolver.compositeSymbol;

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
  isStrippedSelector : 0, /* treat selector beyond affixes like "head::c/c2" as selector */
  rewrapping : 1,
}

//

function onSelectorDownComposite( fop )
{
  return function onSelectorDownComposite()
  {
    let it = this;
    if( it.continue && _.arrayIs( it.dst ) && it.src.composite === _.resolver.compositeSymbol )
    {
      it.dst = _.strJoin( it.dst );
    }
  }
}

//

function classDefine( o )
{

  _.routineOptions( classDefine, o );
  _.assert( _.objectIs( this.Resolver ) );
  _.assert( _.objectIs( this.Resolver.Selector ) );

  o.replicator = o.replicator || Object.create( null );
  o.replicator.parent = o.replicator.parent || this.Resolver;

  o.selector = o.selector || Object.create( null );
  o.selector.parent = o.selector.parent || this.Resolver.Selector;

  let replicator = _.replicator.classDefine( o.replicator );
  let selector = _.selector.classDefine( o.selector );

  replicator.Selector = selector;
  replicator.Replicator = replicator;
  selector.Selector = selector;
  selector.Replicator = replicator;

  return replicator;
}

classDefine.defaults =
{
  selector : null,
  replicator : null,
}

// --
// relations
// --

let LookerResolverSelector =
{
  constructor : function Selector(){},
  selectorOptionsForSelectFrom,
  iterate : selectorIterate,
  /* xxx0 : introduce iteratorInitEnd for Selector? */
}

let IteratorResolverSelector =
{
  replicateIteration : null,
}

let IterationResolverSelector =
{
}

let IterationPreserveResolverSelector =
{
}

let ResolverSelectorPreserve = /* xxx0 */
{
}

let Selector = _.looker.classDefine
({
  name : 'Selector',
  parent : ParentSelector,
  prime : SelectorPrime,
  looker : LookerResolverSelector,
  iterator : IteratorResolverSelector,
  iteration : IterationResolverSelector,
  iterationPreserve : IterationPreserveResolverSelector,
});

_.assert( Selector.exec.defaults.missingAction !== undefined );
_.assert( Selector.exec.defaults.replicateIteration !== undefined );

//

let compositeSymbol = Symbol.for( 'composite' );

let LookerResolverReplicator =
{
  constructor : function Replicator(){},
  head,
  optionsFromArguments,
  optionsToIteration,
  iteratorInitEnd,
  _replicateUp,
  _replicateDown,
  selectorOptionsForSelectFrom,
  perform,
  performBegin,
  performEnd,
  _select,

  errResolvingMake,
  errResolvingHandle,

  _onSelectorReplicateDefault,

  Selector,
  compositeSymbol,
}

let IteratorResolverReplicator =
{
  resolvingRecursive : null,
  selector : null,
  srcForSelect : null,
  optionsForSelect : null,
  onUp2 : null,
  onDown2 : null,
}

let IterationResolverReplicator =
{
}

let IterationPreserveResolverReplicator =
{
  composite : false,
  compositeRoot : null,
}

let Resolver = _.looker.classDefine
({
  name : 'Resolver',
  parent : ParentReplicator,
  prime : Prime,
  looker : LookerResolverReplicator,
  iterator : IteratorResolverReplicator,
  iteration : IterationResolverReplicator,
  iterationPreserve : IterationPreserveResolverReplicator,
});

_.assert( Resolver.selector === null );
_.assert( Resolver.Iteration.compositeRoot === undefined );
_.assert( Resolver.Iterator.compositeRoot === undefined );
_.assert( Resolver.compositeRoot !== undefined );
_.assert( Resolver.missingAction !== undefined );
_.assert( Resolver._onSelectorReplicateDefault === _onSelectorReplicateDefault );

//

Selector.Selector = Selector;
Selector.Replicator = Resolver;
Selector.ResolverSelectorPreserve = ResolverSelectorPreserve;

Resolver.Selector = Selector;
Resolver.Replicator = Resolver;
Resolver.ResolverSelectorPreserve = ResolverSelectorPreserve;

_.assert( Resolver.exec.defaults.missingAction === 'throw' );
_.assert( Resolver.exec.body.defaults.missingAction === 'throw' );
_.assert( _.property.has( Selector.Iterator, 'result' ) && Selector.Iterator.result === undefined );
_.assert( _.property.has( Resolver.Iterator, 'result' ) && Resolver.Iterator.result === undefined );
_.assert( Selector.result === undefined );
_.assert( Resolver.result === undefined );
_.assert( _.property.has( Selector.Iteration, 'dst' ) && Selector.Iteration.dst === undefined );
_.assert( _.property.has( Resolver.Iteration, 'dst' ) && Resolver.Iteration.dst === undefined );
_.assert( Selector.dst === undefined );
_.assert( Resolver.dst === undefined );

const resolve = Resolver.exec;
const resolveIt = Resolver.execIt;
let resolveMaybe = _.routine.uniteInheriting( Resolver.exec.head, Resolver.exec.body );
var defaults = resolveMaybe.defaults;
defaults.Looker = defaults;
defaults.missingAction = 'undefine';
_.assert( resolveMaybe.body !== Resolver.exec.body );
_.assert( resolveMaybe.defaults.missingAction === 'undefine' );
_.assert( resolveMaybe.body.defaults === resolveMaybe.defaults );
_.assert( Resolver.exec.body.defaults.missingAction === 'throw' );
_.assert( Resolver.exec.defaults.missingAction === 'throw' );

//

var FunctorExtension =
{
  onSelectorReplicateComposite,
  onSelectorDownComposite,
}

let ResolverExtension =
{

  name : 'resolver',
  Looker : Resolver,
  Resolver,

  classDefine,
  resolve,
  resolveIt,
  resolveMaybe,

  // onSelectorReplicate,
  compositeSymbol,

}

let ToolsExtension =
{

  resolve,

}

let Self = Resolver;
_.mapExtend( _, ToolsExtension );
_.mapExtend( _.resolver, ResolverExtension );
_.mapExtend( _.resolver.functor, FunctorExtension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = _;

})();
