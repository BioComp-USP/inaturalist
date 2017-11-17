import isomorphicFetch from "isomorphic-fetch";
import _ from "lodash";

// Light wrapper around isomorphic fetch to ensure credentials are always passed through
const fetch = ( url, options ) =>
  isomorphicFetch( url, Object.assign( {}, options, { credentials: "same-origin" } ) );

function updateSession( params ) {
  const data = new FormData( );
  data.append( "authenticity_token", $( "meta[name=csrf-token]" ).attr( "content" ) );
  for ( const key in params ) {
    data.append( key, params[key] );
  }
  fetch( "/users/update_session", {
    method: "PUT",
    body: data
  } );
}

// Basically serialize an object so it can be used for deep object comparison,
// e.g. when deciding whether to udpate a react component
function objectToComparable( object = {} ) {
  return _.map( _.keys( object ).sort( ), k => {
    const v = object[k];
    if ( typeof( v ) === "object" ) {
      return `(${k}-${objectToComparable( v )})`;
    } else if ( _.isNil( v ) ) {
      return `(${k}-)`;
    }
    return `(${k}-${v})`;
  } ).sort( ).join( "," );
}

function resizeUpload( file, opts, callback ) {
  const options = opts || { };
  options.quality = options.quality || 0.9;
  const reader = new FileReader( );
  reader.onload = readerEvent => {
    const image = new Image();
    image.onload = ( ) => {
      // Resize the image
      const canvas = document.createElement( "canvas" );
      const maxDimension = 400;
      let width = image.width;
      let height = image.height;
      if ( width > height ) {
        if ( width > maxDimension ) {
          height *= maxDimension / width;
          width = maxDimension;
        }
      } else {
        if ( height > maxDimension ) {
          width *= maxDimension / height;
          height = maxDimension;
        }
      }
      canvas.width = width * 2;
      canvas.height = height * 2;
      const context = canvas.getContext( "2d" );
      context.scale( 2, 2 );
      context.drawImage( image, 0, 0, width, height );
      if ( options.blob ) {
        canvas.toBlob( callback, "image/jpeg", options.quality );
      } else {
        callback( canvas.toDataURL( "image/jpeg", options.quality ) );
      }
    };
    image.src = readerEvent.target.result;
  };
  reader.readAsDataURL( file );
}

function isBlank( val ) {
  return _.isNumber( val ) ? !_.isFinite( val ) : _.isEmpty( val );
}

export {
  fetch,
  updateSession,
  objectToComparable,
  resizeUpload,
  isBlank
};
