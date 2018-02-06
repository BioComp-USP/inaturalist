import _ from "lodash";
import React, { PropTypes } from "react";
import { Button, Tabs, Tab } from "react-bootstrap";
import moment from "moment-timezone";
import TaxonAutocomplete from "../../uploader/components/taxon_autocomplete";
import UserImage from "../../../shared/components/user_image";
import ActivityItem from "./activity_item";

class Activity extends React.Component {
  constructor( ) {
    super( );
    this.setUpMentionsAutocomplete = this.setUpMentionsAutocomplete.bind( this );
  }

  componentDidMount( ) {
    this.setUpMentionsAutocomplete( );
  }

  componentDidUpdate( ) {
    this.setUpMentionsAutocomplete( );
  }

  setUpMentionsAutocomplete( ) {
    $( ".comment_id_panel textarea" ).textcompleteUsers( );
  }

  currentUserIcon( ) {
    const config = this.props.config;
    return config ? (
      <div className="icon">
        <UserImage user={ config.currentUser } />
      </div>
    ) : (
      <div className="icon"><div className="UserImage" /></div>
    );
  }

  doneButton( ) {
    const config = this.props.config;
    return config && config.currentUser ? (
      <Button className="comment_id" bsSize="small" onClick={
        ( ) => {
          if ( $( ".comment_tab" ).is( ":visible" ) ) {
            const comment = $( ".comment_tab textarea" ).val( );
            if ( comment ) {
              this.props.addComment( $( ".comment_tab textarea" ).val( ) );
              $( ".comment_tab textarea" ).val( "" );
            }
          } else {
            const input = $( ".id_tab input[name='taxon_name']" );
            const selectedTaxon = input.data( "uiAutocomplete" ).selectedItem;
            if ( selectedTaxon ) {
              this.props.addID( selectedTaxon, { body: $( ".id_tab textarea" ).val( ) } );
              input.trigger( "resetSelection" );
              input.val( "" );
              input.data( "uiAutocomplete" ).selectedItem = null;
              $( ".id_tab textarea" ).val( "" );
            }
          }
        } }
      >
        { I18n.t( "done" ) }
      </Button> ) : null;
  }

  review( ) {
    const { observation, config } = this.props;
    return config && config.currentUser ? (
      <div className="review">
        <input
          type="checkbox"
          id="reviewed"
          name="reviewed"
          checked={ _.includes( observation.reviewed_by, config.currentUser.id ) }
          onChange={ ( ) => {
            if ( $( "#reviewed" ).is( ":checked" ) ) {
              this.props.review( );
            } else {
              this.props.unreview( );
            }
          }}
        />
        <label htmlFor="reviewed">
          { I18n.t( "mark_as_reviewed" ) }
        </label>
      </div> ) : null;
  }

  render( ) {
    const observation = this.props.observation;
    if ( !observation ) { return ( <div /> ); }
    const config = this.props.config;
    const loggedIn = config && config.currentUser;
    const currentUserID = loggedIn && _.findLast( observation.identifications, i => (
      i.current && i.user && i.user.id === config.currentUser.id
    ) );
    let activity = _.compact( ( observation.identifications || [] ).
      concat( observation.comments ) );
    activity = _.sortBy( activity, a => ( moment.parseZone( a.created_at ) ) );
    // attempting to match the logic in the computervision/score_observation endpoint
    // so we don't attempt to fetch vision results for obs which will have no results
    const visionEligiblePhotos = _.compact( _.map( observation.photos, p => {
      if ( !p.url || p.preview ) { return null; }
      const mediumUrl = p.photoUrl( "medium" );
      if ( mediumUrl && mediumUrl.match( /static\.inaturalist.*\/medium\.jpe?g[\?$]/i ) ) {
        return p;
      }
      return null;
    } ) );
    const commentContent = loggedIn ?
      (
        <div className="form-group">
          <textarea
            placeholder={ I18n.t( "leave_a_comment" ) }
            className="form-control"
          />
        </div>
      ) : (
        <span className="log-in">
          <a href="/login">
            { I18n.t( "log_in" ) }
          </a> { I18n.t( "or" ) } <a href="/signup">
            { I18n.t( "sign_up" ) }
          </a> { I18n.t( "to_add_comments" ) }.
        </span>
      );
    const idContent = loggedIn ?
      (
        <div>
          <TaxonAutocomplete
            bootstrap
            searchExternal
            perPage={ 6 }
            resetOnChange={ false }
            visionParams={ visionEligiblePhotos.length > 0 ?
              { observationID: observation.id } : null }
            config={ config }
          />
          <div className="form-group">
            <textarea
              placeholder={ I18n.t( "tell_us_why" ) }
              className="form-control"
            />
          </div>
        </div>
      ) : (
        <span className="log-in">
          <a href="/login">
            { I18n.t( "log_in" ) }
          </a> { I18n.t( "or" ) } <a href="/signup">
            { I18n.t( "sign_up" ) }
          </a> { I18n.t( "to_suggest_an_identification" ) }.
        </span>
      );
    const tabs = (
      <Tabs activeKey={ this.props.commentIDPanel.activeTab } onSelect={ key => {
        this.props.setActiveTab( key );
      } }
      >
        <Tab eventKey="comment" title={ I18n.t( "comment_" ) } className="comment_tab">
          { commentContent }
        </Tab>
        <Tab eventKey="add_id" title={ I18n.t( "suggest_an_identification" ) } className="id_tab">
          { idContent }
        </Tab>
      </Tabs>
    );
    const taxonIDsDisplayed = { };
    return (
      <div className="Activity">
        <h3>{ I18n.t( "activity" ) }</h3>
        <div className={`activity ${activity.length === 0 ? "empty" : ""}`}>
          { activity.map( item => {
            let firstDisplay;
            if ( item.taxon && item.current ) {
              firstDisplay = !taxonIDsDisplayed[item.taxon.id];
              taxonIDsDisplayed[item.taxon.id] = true;
            }
            return ( <ActivityItem
              key={ `activity-${item.id}` }
              item={ item }
              currentUserID={ currentUserID }
              firstDisplay={ firstDisplay }
              { ...this.props }
            /> );
          } ) }
        </div>
        { this.currentUserIcon( ) }
        <div className="comment_id_panel">
          { tabs }
        </div>
        { this.doneButton( ) }
        { this.review( ) }
      </div>
    );
  }
}

Activity.propTypes = {
  observation: PropTypes.object,
  config: PropTypes.object,
  commentIDPanel: PropTypes.object,
  observation_places: PropTypes.object,
  addComment: PropTypes.func,
  addID: PropTypes.func,
  createFlag: PropTypes.func,
  deleteComment: PropTypes.func,
  deleteFlag: PropTypes.func,
  deleteID: PropTypes.func,
  restoreID: PropTypes.func,
  review: PropTypes.func,
  setActiveTab: PropTypes.func,
  setFlaggingModalState: PropTypes.func,
  unreview: PropTypes.func
};

export default Activity;
