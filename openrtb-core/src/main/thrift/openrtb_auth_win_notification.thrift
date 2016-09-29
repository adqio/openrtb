/*
 * Copyright 2016 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

option java_outer_classname = "OpenRtb";
package com.google.openrtb;

// OpenRTB extensions ("ext" fields in the spec & JSON representation)
// are represented here by Protocol Buffer extensions. This proto only
// reserves the range of IDs 100-9999 at every extensible object.
// Reserved ranges:
//   100-199: Reserved for Google, including the openrtb-doubleclick
//            library (DcExt) and Open Bidder project (ObExt).
//   200-999: Free for use with other exchanges or projects.
//   1000-1999: Reserved for Google.
//   2000-9999: Free for use with other exchanges or projects.

// OpenRTB 2.0: The top-level bid request object contains a globally unique
// bid request or auction ID. This id attribute is required as is at least one
// impression object (Section 3.2.2). Other attributes in this top-level object
// establish rules and restrictions that apply to all impressions being offered.
//
// There are also several subordinate objects that provide detailed data to
// potential buyers. Among these are the Site and App objects, which describe
// the type of published media in which the impression(s) appear.
// These objects are highly recommended, but only one applies to a given
// bid request depending on whether the media is browser-based web content
// or a non-browser application, respectively.
message BidRequest {
  // Unique ID of the bid request, provided by the exchange.
  // REQUIRED by the OpenRTB specification.
  // [AdX: BidRequest.id - AdX is binary, OpenRTB is base64 (no padding)]
  required string id = 1;

  // Array of Imp objects (Section 3.2.2) representing the impressions offered.
  // At least 1 Imp object is required.
  // [AdX: BidRequest.AdSlot]
  repeated Imp imp = 2;

  oneof distributionchannel_oneof {
    // Details via a Site object (Section 3.2.6) about the publisher's website.
    // Only applicable and recommended for websites.
    // [AdX: BidRequest]
    Site site = 3;

    // Details via an App object (Section 3.2.7) about the publisher's app
    // (non-browser applications). Only applicable and recommended for apps.
    // [AdX: BidRequest, BidRequest.Mobile]
    App app = 4;
  }

  // Details via a Device object (Section 3.2.11) about the user's
  // device to which the impression will be delivered.
  // [AdX: BidRequest.Mobile, BidRequest.Device]
  optional Device device = 5;

  // A Regs object (Section 3.2.16) that specifies any industry, legal,
  // or governmental regulations in force for this request.
  optional Regs regs = 14;

  // Details via a User object (Section 3.2.13) about the human
  // user of the device; the advertising audience.
  // [AdX: BidRequest]
  optional User user = 6;

  // Auction type, where 1 = First Price, 2 = Second Price Plus.
  // Exchange-specific auction types can be defined using values > 500.
  // [AdX: 2]
  optional AuctionType at = 7 [default = SECOND_PRICE];

  // Maximum time in milliseconds to submit a bid to avoid timeout.
  // This value is commonly communicated offline.
  // [AdX: not mapped, but fixed to 100ms]
  optional int32 tmax = 8;

  // Whitelist of buyer seats (e.g., advertisers, agencies) allowed to
  // bid on this impression. IDs of seats and knowledge of the
  // buyer's customers to which they refer must be coordinated
  // between bidders and the exchange a priori.
  // Omission implies no seat restrictions.
  repeated string wseat = 9;

  // Flag to indicate if Exchange can verify that the impressions offered
  // represent all of the impressions available in context (e.g., all on the
  // web page, all video spots such as pre/mid/post roll) to support
  // road-blocking. 0 = no or unknown, 1 = yes, the impressions offered
  // represent all that are available.
  // [AdX: 0]
  optional bool allimps = 10 [default = false];

  // Array of allowed currencies for bids on this bid request using ISO-4217
  // alpha codes. Recommended only if the exchange accepts multiple currencies.
  repeated string cur = 11;

  // Blocked advertiser categories using the IAB content categories.
  // Refer to enum ContentCategory.
  // [AdX: BidRequest.AdSlot.excluded_sensitive_category,
  //       BidRequest.AdSlot.excluded_product_category]
  repeated string bcat = 12;

  // Block list of advertisers by their domains (e.g., "ford.com").
  repeated string badv = 13;

  // Block list of applications by their platform-specific exchange
  // independent application identifiers. On Android, these should
  // be bundle or package names (e.g., com.foo.mygame).
  // On iOS, these are numeric IDs.
  repeated string bapp = 16;

  // Indicator of test mode in which auctions are not billable,
  // where 0 = live mode, 1 = test mode.
  // [AdX: BidRequest.is_test]
  optional bool test = 15 [default = false];

  // Extensions.
  extensions 100 to 9999;

  // OpenRTB 2.0: This object describes an ad placement or impression
  // being auctioned.  A single bid request can include multiple Imp objects,
  // a use case for which might be an exchange that supports selling all
  // ad positions on a given page.  Each Imp object has a required ID so that
  // bids can reference them individually.
  //
  // The presence of Banner (Section 3.2.3), Video (Section 3.2.4),
  // and/or Native (Section 3.2.5) objects subordinate to the Imp object
  // indicates the type of impression being offered. The publisher can choose
  // one such type which is the typical case or mix them at their discretion.
  // Any given bid for the impression must conform to one of the offered types.
  message Imp {
    // A unique identifier for this impression within the context of the bid
    // request (typically, value starts with 1, and increments up to n
    // for n impressions).
    // [AdX: BidRequest.AdSlot.id]
    required string id = 1;

    // A Banner object (Section 3.2.3); required if this impression is
    // offered as a banner ad opportunity.
    // [AdX: BidRequest.AdSlot]
    optional Banner banner = 2;

    // A Video object (Section 3.2.4); required if this impression is
    // offered as a video ad opportunity.
    // [AdX: BidRequest.AdSlot, BidRequest.Video]
    optional Video video = 3;

    // An Audio object; required if this impression is offered
    // as an audio ad opportunity.
    optional Audio audio = 15;

    // Name of ad mediation partner, SDK technology, or player responsible
    // for rendering ad (typically video or mobile). Used by some ad servers
    // to customize ad code by partner. Recommended for video and/or apps.
    optional string displaymanager = 4;

    // Version of ad mediation partner, SDK technology, or player responsible
    // for rendering ad (typically video or mobile). Used by some ad servers
    // to customize ad code by partner. Recommended for video and/or apps.
    optional string displaymanagerver = 5;

    // 1 = the ad is interstitial or full screen, 0 = not interstitial.
    // [AdX: BidRequest.AdSlot.Mobile.is_interstitial_request]
    optional bool instl = 6;

    // Identifier for specific ad placement or ad tag that was used to
    // initiate the auction. This can be useful for debugging of any issues,
    // or for optimization by the buyer.
    // [AdX: BidRequest.AdSlot.ad_block_key]
    optional string tagid = 7;

    // Minimum bid for this impression expressed in CPM.
    // [AdX: min(BidRequest.AdSlot.matching_ad_data.minimum_cpm_micros) *
    //       1,000,000]
    optional double bidfloor = 8 [default = 0];

    // Currency specified using ISO-4217 alpha codes. This may be different
    // from bid currency returned by bidder if this is allowed by the exchange.
    // [AdX: A single currency, obtained from the included billing_id]
    optional string bidfloorcur = 9 [default = "USD"];

    // Indicates the type of browser opened upon clicking the
    // creative in an app, where 0 = embedded, 1 = native.
    // Note that the Safari View Controller in iOS 9.x devices is considered
    // a native browser for purposes of this attribute.
    optional bool clickbrowser = 16;

    // Flag to indicate if the impression requires secure HTTPS URL creative
    // assets and markup, where 0 = non-secure, 1 = secure.  If omitted,
    // the secure state is unknown, but non-secure HTTP support can be assumed.
    optional bool secure = 12;

    // Array of exchange-specific names of supported iframe busters.
    // [AdX: Unsupported; use macro %%CACHEBUSTER%% in the snippet]
    repeated string iframebuster = 10;

    // A Pmp object (Section 3.2.17) containing any private marketplace deals
    // in effect for this impression.
    // [AdX: BidRequest.AdSlot.MatchingAdData]
    optional Pmp pmp = 11;

    // A Native object (Section 3.2.5); required if this impression is
    // offered as a native ad opportunity.
    // [AdX: BidRequest.AdSlot.NativeAdTemplate]
    optional Native native = 13;

    // Advisory as to the number of seconds that may elapse
    // between the auction and the actual impression.
    optional int32 exp = 14;

    // Extensions.
    extensions 100 to 9999;

    // OpenRTB 2.0: This object represents the most general type of
    // impression.  Although the term "banner" may have very specific meaning
    // in other contexts, here it can be many things including a simple static
    // image, an expandable ad unit, or even in-banner video (refer to the Video
    // object in Section 3.2.4 for the more generalized and full featured video
    // ad units). An array of Banner objects can also appear within the Video
    // to describe optional companion ads defined in the VAST specification.
    //
    // The presence of a Banner as a subordinate of the Imp object indicates
    // that this impression is offered as a banner type impression.
    // At the publisher's discretion, that same impression may also be offered
    // as video and/or native by also including as Imp subordinates the Video
    // and/or Native objects, respectively. However, any given bid for the
    // impression must conform to one of the offered types.
    message Banner {
      // Width in device independent pixels (DIPS).
      // If no format objects are specified, this is an exact width
      // requirement. Otherwise it is a preferred width.
      // [AdX: BidRequest.AdSlot.width[0]]
      optional int32 w = 1;

      // Height in device independent pixels (DIPS).
      // If no format objects are specified, this is an exact height
      // requirement. Otherwise it is a preferred height.
      // [AdX: BidRequest.AdSlot.height[0]]
      optional int32 h = 2;

      // Array of format objects representing the banner sizes permitted.
      // If none are specified, then use of the h and w attributes
      // is highly recommended.
      repeated Format format = 15;

      // NOTE: Deprecated in favor of the format array.
      // Maximum width in device independent pixels (DIPS).
      // [AdX: max(BidRequest.AdSlot.width) if |width| > 1]
      optional int32 wmax = 11 [deprecated = true];

      // NOTE: Deprecated in favor of the format array.
      // Maximum height in device independent pixels (DIPS).
      // [AdX: max(BidRequest.AdSlot.height) if |height| > 1]
      optional int32 hmax = 12 [deprecated = true];

      // NOTE: Deprecated in favor of the format array.
      // Minimum width in device independent pixels (DIPS).
      // [AdX: min(BidRequest.AdSlot.width) if |width| > 1]
      optional int32 wmin = 13 [deprecated = true];

      // NOTE: Deprecated in favor of the format array.
      // Minimum height in device independent pixels (DIPS).
      // [AdX: min(BidRequest.AdSlot.height) if |height| > 1]
      optional int32 hmin = 14 [deprecated = true];

      // Unique identifier for this banner object. Recommended when Banner
      // objects are used with a Video object (Section 3.2.4) to represent
      // an array of companion ads. Values usually start at 1 and increase
      // with each object; should be unique within an impression.
      // [AdX: BidRequest.AdSlot.id]
      optional string id = 3;

      // Ad position on screen.
      // [AdX: BidRequest.AdSlot.slot_visibility]
      optional AdPosition pos = 4;

      // Blocked banner ad types.
      repeated BannerAdType btype = 5 [packed = true];

      // Blocked creative attributes.
      // [AdX: BidRequest.AdSlot.excluded_attribute]
      repeated CreativeAttribute battr = 6 [packed = true];

      // Whitelist of content MIME types supported. Popular MIME types include,
      // but are not limited to "image/jpg", "image/gif" and
      // "application/x-shockwave-flash".
      // [AdX: Only mapped for BidRequest.Video.companionad:
      //       BidRequest.Video.companionad.creative_format,
      //       BidRequest.AdSlot.excluded_attribute / VPAID]
      repeated string mimes = 7;

      // Specify if the banner is delivered in the top frame (true)
      // or in an iframe (false).
      // [AdX: BidRequest.AdSlot.iframing_state
      //       NO_IFRAME: false
      //       SAME_DOMAIN_IFRAME, CROSS_DOMAIN_IFRAME: true]
      optional bool topframe = 8;

      // Directions in which the banner may expand.
      // [AdX: BidRequest.AdSlot.excluded_attribute / EXPANDING_*]
      repeated ExpandableDirection expdir = 9 [packed = true];

      // List of supported API frameworks for this impression.
      // If an API is not explicitly listed, it is assumed not to be supported.
      // [AdX: BidRequest.AdSlot.excluded_attribute / MRAID_1_0]
      repeated APIFramework api = 10 [packed = true];

      // Extensions.
      extensions 100 to 9999;

      // OpenRTB 2.4: This object represents an allowed size (i.e.,
      // height and width combination) for a banner impression.
      // These are typically used in an array for an impression where
      // multiple sizes are permitted.
      message Format {
        // Width in device independent pixels (DIPS).
        optional int32 w = 1;

        // Height in device independent pixels (DIPS).
        optional int32 h = 2;

        // Extensions.
        extensions 100 to 9999;
      }
    }

    // OpenRTB 2.0: This object represents an in-stream video impression.
    // Many of the fields are non-essential for minimally viable transactions,
    // but are included to offer fine control when needed. Video in OpenRTB
    // generally assumes compliance with the VAST standard. As such, the notion
    // of companion ads is supported by optionally including an array of Banner
    // objects (refer to the Banner object in Section 3.2.3) that define these
    // companion ads.
    //
    // The presence of a Video as a subordinate of the Imp object indicates
    // that this impression is offered as a video type impression. At the
    // publisher's discretion, that same impression may also be offered as
    // banner and/or native by also including as Imp subordinates the Banner
    // and/or Native objects, respectively. However, any given bid for the
    // impression must conform to one of the offered types.
    message Video {
      // Whitelist of content MIME types supported. Popular MIME types include,
      // but are not limited to "image/jpg", "image/gif" and
      // "application/x-shockwave-flash".
      // REQUIRED by the OpenRTB specification: at least 1 element.
      // [AdX: BidRequest.Video.allowed_video_formats,
      //       BidRequest.AdSlot.excluded_attribute / VPAID]
      repeated string mimes = 1;

      // Indicates if the impression must be linear, nonlinear, etc.
      // If none specified, assume all are allowed.
      optional VideoLinearity linearity = 2;

      // Minimum video ad duration in seconds.
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: BidRequest.Video.min_ad_duration]
      optional int32 minduration = 3;

      // Maximum video ad duration in seconds.
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: BidRequest.Video.max_ad_duration]
      optional int32 maxduration = 4;

      // Deprecated; use protocols.
      optional Protocol protocol = 5 [deprecated = true];

      // Array of supported video bid response protocols.
      // At least one supported protocol must be specified.
      // [AdX: {VAST_2_0, VAST_3_0, VAST_2_0_WRAPPER, VAST_3_0_WRAPPER}]
      repeated Protocol protocols = 21 [packed = true];

      // Width of the video player in device independent pixels (DIPS).
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: BidRequest.AdSlot.width[0]]
      optional int32 w = 6;

      // Height of the video player in device independent pixels (DIPS).
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: BidRequest.AdSlot.height[0]]
      optional int32 h = 7;

      // Indicates the start delay in seconds for pre-roll, mid-roll, or
      // post-roll ad placements.
      // Refer to enum StartDelay for generic values.
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: BidRequest.Video.videoad_start_delay
      //       0: PRE_ROLL
      //       1: GENERIC_MID_ROLL
      //       -1: GENERIC_POST_ROLL
      //       Other values: videoad_start_delay / 1,000]
      optional int32 startdelay = 8;

      // Indicates if the player will allow the video to be skipped,
      // where 0 = no, 1 = yes.
      // If a bidder sends markup/creative that is itself skippable, the
      // Bid object should include the attr array with an element of
      // 16 indicating skippable video.
      // [AdX: BidRequest.Video.video_ad_skippable
      //       0: ALLOW_SKIPPABLE
      //       1: REQUIRE_SKIPPABLE
      //       2: BLOCK_SKIPPABLE]
      optional bool skip = 23;

      // Videos of total duration greater than this number of seconds
      // can be skippable; only applicable if the ad is skippable.
      optional int32 skipmin = 24;

      // Number of seconds a video must play before skipping is
      // enabled; only applicable if the ad is skippable.
      optional int32 skipafter = 25;

      // If multiple ad impressions are offered in the same bid request,
      // the sequence number will allow for the coordinated delivery of
      // multiple creatives.
      optional int32 sequence = 9 [default = 1];

      // Blocked creative attributes.
      // [AdX: BidRequest.AdSlot.excluded_attribute]
      repeated CreativeAttribute battr = 10 [packed = true];

      // Maximum extended video ad duration, if extension is allowed.
      // If blank or 0, extension is not allowed. If -1, extension is allowed,
      // and there is no time limit imposed. If greater than 0, then the value
      // represents the number of seconds of extended play supported beyond
      // the maxduration value.
      optional int32 maxextended = 11;

      // Minimum bit rate in Kbps.
      optional int32 minbitrate = 12;

      // Maximum bit rate in Kbps.
      optional int32 maxbitrate = 13;

      // Indicates if letter-boxing of 4:3 content into a 16:9 window is
      // allowed, where 0 = no, 1 = yes.
      optional bool boxingallowed = 14 [default = true];

      // Playback methods that may be in use. If none are specified, any
      // method may be used. Only one method is typically used in practice.
      // As a result, this array may be converted to an integer in a future
      // version of the specification.
      // [AdX: BidRequest.Video.playback_method]
      repeated PlaybackMethod playbackmethod = 15 [packed = true];

      // Supported delivery methods (e.g., streaming, progressive).
      // If none specified, assume all are supported.
      repeated ContentDeliveryMethod delivery = 16 [packed = true];

      // Ad position on screen.
      // [AdX: BidRequest.AdSlot.slot_visibility]
      optional AdPosition pos = 17;

      // Array of Banner objects (Section 3.2.3) if companion ads are available.
      // [AdX: BidRequest.Video.companion_slot]
      repeated Banner companionad = 18;

      // Companion ads in OpenRTB 2.1 format. (Or to be precise, interpretations
      // based on the buggy sample message in 5.1.4, fixed later in 2.2.)
      optional CompanionAd companionad_21 = 22 [deprecated = true];

      // List of supported API frameworks for this impression.
      // If an API is not explicitly listed, it is assumed not to be supported.
      // [AdX: BidRequest.AdSlot.excluded_attribute / MRAID_1_0]
      repeated APIFramework api = 19 [packed = true];

      // Supported VAST companion ad types.  Recommended if companion Banner
      // objects are included via the companionad array.
      // [AdX: BidRequest.Video.companion_slot.creative_format]
      repeated CompanionType companiontype = 20 [packed = true];

      // Extensions.
      extensions 100 to 9999;

      // OpenRTB 2.1 compatibility.
      message CompanionAd {
        repeated Banner banner = 1;
        extensions 100 to 9999;
      }
    }

    // This object represents an audio type impression. Many of the fields
    // are non-essential for minimally viable transactions, but are included
    // to offer fine control when needed. Audio in OpenRTB generally assumes
    // compliance with the DAAST standard. As such, the notion of companion
    // ads is supported by optionally including an array of Banner objects
    // that define these companion ads.
    //
    // The presence of a Audio as a subordinate of the Imp object indicates
    // that this impression is offered as an audio type impression.
    // At the publisher’s discretion, that same impression may also be offered
    // as banner, video, and/or native by also including as Imp subordinates
    // objects of those types. However, any given bid for the impression must
    // conform to one of the offered types.
    message Audio {
      // Content MIME types supported (e.g., "audio/mp4").
      // REQUIRED by the OpenRTB specification: at least 1 element.
      repeated string mimes = 1;

      // Minimum audio ad duration in seconds.
      // RECOMMENDED by the OpenRTB specification.
      optional int32 minduration = 2;

      // Maximum audio ad duration in seconds.
      // RECOMMENDED by the OpenRTB specification.
      optional int32 maxduration = 3;

      // Array of supported audio protocols.
      // RECOMMENDED by the OpenRTB specification.
      repeated Protocol protocols = 4 [packed = true];

      // Indicates the start delay in seconds for pre-roll, mid-roll, or
      // post-roll ad placements.
      // Refer to enum StartDelay for generic values.
      // RECOMMENDED by the OpenRTB specification.
      optional int32 startdelay = 5;

      // If multiple ad impressions are offered in the same bid request,
      // the sequence number will allow for the coordinated delivery of
      // multiple creatives.
      optional int32 sequence = 6 [default = 1];

      // Blocked creative attributes.
      repeated CreativeAttribute battr = 7 [packed = true];

      // Maximum extended video ad duration, if extension is allowed.
      // If blank or 0, extension is not allowed. If -1, extension is allowed,
      // and there is no time limit imposed. If greater than 0, then the value
      // represents the number of seconds of extended play supported beyond
      // the maxduration value.
      optional int32 maxextended = 8;

      // Minimum bit rate in Kbps.
      optional int32 minbitrate = 9;

      // Maximum bit rate in Kbps.
      optional int32 maxbitrate = 10;

      // Supported delivery methods (e.g., streaming, progressive).
      // If none specified, assume all are supported.
      repeated ContentDeliveryMethod delivery = 11 [packed = true];

      // Array of Banner objects if companion ads are available.
      repeated Banner companionad = 12;

      // List of supported API frameworks for this impression.
      // If an API is not explicitly listed, it is assumed not to be supported.
      repeated APIFramework api = 13 [packed = true];

      // Supported DAAST companion ad types.  Recommended if companion Banner
      // objects are included via the companionad array.
      repeated CompanionType companiontype = 20 [packed = true];

      // The maximum number of ads that can be played in an ad pod.
      optional int32 maxseq = 21;

      // Type of audio feed.
      optional FeedType feed = 22;

      // Indicates if the ad is stitched with audio content or delivered
      // independently, where 0 = no, 1 = yes.
      optional bool stitched = 23;

      // Volume normalization mode.
      optional VolumeNormalizationMode nvol = 24;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB 2.3: This object represents a native type impression.
    // Native ad units are intended to blend seamlessly into the surrounding
    // content (e.g., a sponsored Twitter or Facebook post). As such, the
    // response must be well-structured to afford the publisher fine-grained
    // control over rendering.
    //
    // The Native Subcommittee has developed a companion specification to
    // OpenRTB called the Native Ad Specification. It defines the request
    // parameters and response markup structure of native ad units.
    // This object provides the means of transporting request parameters as an
    // opaque string so that the specific parameters can evolve separately
    // under the auspices of the Native Ad Specification. Similarly, the
    // ad markup served will be structured according to that specification.
    //
    // The presence of a Native as a subordinate of the Imp object indicates
    // that this impression is offered as a native type impression.
    // At the publisher's discretion, that same impression may also be offered
    // as banner and/or video by also including as Imp subordinates the Banner
    // and/or Video objects, respectively. However, any given bid for the
    // impression must conform to one of the offered types.
    message Native {
      oneof request_oneof {
        // Request payload complying with the Native Ad Specification.
        // Exactly one of {request, request_native} should be used;
        // this is the OpenRTB-compliant field for JSON serialization.
        // [AdX: BidRequest.AdSlot.NativeAdTemplate]
        string request = 1;

        // Request payload complying with the Native Ad Specification.
        // Exactly one of {request, request_native} should be used;
        // this is an alternate field preferred for Protobuf serialization.
        // [AdX: BidRequest.AdSlot.NativeAdTemplate]
        NativeRequest request_native = 50;
      }

      // Version of the Native Ad Specification to which request complies.
      // RECOMMENDED by the OpenRTB specification.
      // [AdX: "1.0" for OpenRTB 2.3; "1.1" for OpenRTB 2.4]
      optional string ver = 2;

      // List of supported API frameworks for this impression.
      // If an API is not explicitly listed, it is assumed not to be supported.
      // [AdX: BidRequest.AdSlot.excluded_attribute / MRAID_1_0]
      repeated APIFramework api = 3 [packed = true];

      // Blocked creative attributes.
      // [AdX: BidRequest.AdSlot.excluded_attribute]
      repeated CreativeAttribute battr = 4 [packed = true];

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB 2.2: This object is the private marketplace container for
    // direct deals between buyers and sellers that may pertain to this
    // impression. The actual deals are represented as a collection of
    // Deal objects. Refer to Section 7.2 for more details.
    message Pmp {
      // Indicator of auction eligibility to seats named in the Direct Deals
      // object, where 0 = all bids are accepted, 1 = bids are restricted to
      // the deals specified and the terms thereof.
      optional bool private_auction = 1 [default = false];

      // Array of Deal (Section 3.2.18) objects that convey the specific deals
      // applicable to this impression.
      // [AdX: BidRequest.AdSlot.MatchingAdData.DirectDeal]
      repeated Deal deals = 2;

      // Extensions.
      extensions 100 to 9999;

      // OpenRTB 2.2: This object constitutes a specific deal that was struck
      // a priori between a buyer and a seller. Its presence with the Pmp
      // collection indicates that this impression is available under the terms
      // of that deal. Refer to Section 7.2 for more details.
      message Deal {
        // A unique identifier for the direct deal.
        // REQUIRED by the OpenRTB specification.
        // [AdX: BidRequest.AdSlot.MatchingAdData.DirectDeal.direct_deal_id]
        required string id = 1;

        // Minimum bid for this impression expressed in CPM.
        // [AdX: BidRequest.AdSlot.MatchingAdData.DirectDeal.fixed_cpm_micros *
        //       1,000,000]
        optional double bidfloor = 2 [default = 0];

        // Currency specified using ISO-4217 alpha codes. This may be different
        // from bid currency returned by bidder if this is allowed
        // by the exchange.
        // [AdX: A single currency, obtained from the included billing_id]
        optional string bidfloorcur = 3 [default = "USD"];

        // Whitelist of buyer seats (e.g., advertisers, agencies) allowed to
        // bid on this deal. IDs of seats and knowledge of the buyer's
        // customers to which they refer must be coordinated between bidders
        // and the exchange a priori. Omission implies no seat restrictions.
        repeated string wseat = 4;

        // Array of advertiser domains (e.g., advertiser.com) allowed to
        // bid on this deal. Omission implies no advertiser restrictions.
        repeated string wadomain = 5;

        // Optional override of the overall auction type of the bid request,
        // where 1 = First Price, 2 = Second Price Plus, 3 = the value passed
        // in bidfloor is the agreed upon deal price. Additional auction types
        // can be defined by the exchange.
        // [AdX: BidRequest.AdSlot.MatchingAdData.DirectDeal.deal_type]
        optional AuctionType at = 6;

        // Extensions.
        extensions 100 to 9999;
      }
    }
  }

  // OpenRTB 2.0: This object should be included if the ad supported content
  // is a website as opposed to a non-browser application. A bid request must
  // not contain both a Site and an App object. At a minimum, it is useful to
  // provide a site ID or page URL, but this is not strictly required.
  message Site {
    // Site ID on the exchange.
    // RECOMMENDED by the OpenRTB specification.
    optional string id = 1;

    // Site name (may be masked at publisher's request).
    // [AdX: BidRequest.anonymous_id]
    optional string name = 2;

    // Domain of the site, used for advertiser side blocking.
    // For example, "foo.com".
    optional string domain = 3;

    // Array of IAB content categories of the site.
    // See enum ContentCategory.
    repeated string cat = 4;

    // Array of IAB content categories that describe the current section
    // of the site.
    // See enum ContentCategory.
    repeated string sectioncat = 5;

    // Array of IAB content categories that describe the current page or view
    // of the site.
    // See enum ContentCategory.
    repeated string pagecat = 6;

    // URL of the page where the impression will be shown.
    // [AdX: BidRequest.url]
    optional string page = 7;

    // Indicates if the site has a privacy policy, where 0 = no, 1 = yes.
    optional bool privacypolicy = 8;

    // Referrer URL that caused navigation to the current page.
    optional string ref = 9;

    // Search string that caused navigation to the current page.
    optional string search = 10;

    // Details about the Publisher (Section 3.2.8) of the site.
    // [AdX: BidRequest]
    optional Publisher publisher = 11;

    // Details about the Content (Section 3.2.9) within the site.
    // [AdX: BidRequest]
    optional Content content = 12;

    // Comma separated list of keywords about this site.
    // Note: OpenRTB 2.2 allowed an array-of-strings as alternate implementation
    // but this was fixed in 2.3+ where it's definitely a single string with CSV
    // content again. Compatibility with some OpenRTB 2.2 exchanges that adopted
    // the alternate representation may require custom handling of the JSON.
    optional string keywords = 13;

    // Indicates if the site has been programmed to optimize layout
    // when viewed on mobile devices, where 0 = no, 1 = yes.
    // [AdX: BidRequest.Mobile.is_mobile_web_optimized]
    optional bool mobile = 15;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object should be included if the ad supported content
  // is a non-browser application (typically in mobile) as opposed to a website.
  // A bid request must not contain both an App and a Site object.
  // At a minimum, it is useful to provide an App ID or bundle,
  // but this is not strictly required.
  message App {
    // Application ID on the exchange.
    // RECOMMENDED by the OpenRTB specification.
    optional string id = 1;

    // Application name (may be aliased at publisher's request).
    // [AdX: BidRequest.Mobile.app_name]
    optional string name = 2;

    // Domain of the application. For example, "mygame.foo.com".
    optional string domain = 3;

    // Array of IAB content categories of the app.
    // See enum ContentCategory.
    repeated string cat = 4;

    // Array of IAB content categories that describe the current section
    // of the app.
    // See enum ContentCategory.
    repeated string sectioncat = 5;

    // Array of IAB content categories that describe the current page or view
    // of the app.
    // See enum ContentCategory.
    repeated string pagecat = 6;

    // Application version.
    optional string ver = 7;

    // A platform-specific application identifier intended to be
    // unique to the app and independent of the exchange. On Android,
    // this should be a bundle or package name (e.g., com.foo.mygame).
    // On iOS, it is a numeric ID.
    // [AdX: BidRequest.Mobile.app_id]
    optional string bundle = 8;

    // Indicates if the app has a privacy policy, where 0 = no, 1 = yes.
    optional bool privacypolicy = 9;

    // 0 = app is free, 1 = the app is a paid version.
    optional bool paid = 10;

    // Details about the Publisher (Section 3.2.8) of the app.
    // [AdX: BidRequest]
    optional Publisher publisher = 11;

    // Details about the Content (Section 3.2.9) within the app.
    // [AdX: BidRequest]
    optional Content content = 12;

    // Comma separated list of keywords about the app.
    optional string keywords = 13;

    // App store URL for an installed app; for QAG 1.5 compliance.
    optional string storeurl = 16;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object describes the publisher of the media in which
  // the ad will be displayed. The publisher is typically the seller
  // in an OpenRTB transaction.
  message Publisher {
    // Exchange-specific publisher ID.
    // [AdX: BidRequest.seller_network_id]
    optional string id = 1;

    // Publisher name (may be aliased at publisher's request).
    optional string name = 2;

    // Array of IAB content categories that describe the publisher.
    // See enum ContentCategory.
    repeated string cat = 3;

    // Highest level domain of the publisher (e.g., "publisher.com").
    optional string domain = 4;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object describes the content in which the impression
  // will appear, which may be syndicated or non-syndicated content.
  // This object may be useful when syndicated content contains impressions and
  // does not necessarily match the publisher's general content.
  // The exchange might or might not have knowledge of the page where the
  // content is running, as a result of the syndication method.
  // For example might be a video impression embedded in an iframe on an
  // unknown web property or device.
  message Content {
    // ID uniquely identifying the content.
    // [AdX: (Only App.content) BidRequest.anonymous_id]
    optional string id = 1;

    // Content episode number (typically applies to video content).
    optional int32 episode = 2;

    // Content title.
    // Video Examples: "Search Committee" (television), "A New Hope" (movie),
    // or "Endgame" (made for web).
    // Non-Video Example: "Why an Antarctic Glacier Is Melting So Quickly"
    // (Time magazine article).
    // [AdX: BidRequest.Video.ContentAttributes.title]
    optional string title = 3;

    // Content series.
    // Video Examples: "The Office" (television), "Star Wars" (movie),
    // or "Arby 'N' The Chief" (made for web).
    // Non-Video Example: "Ecocentric" (Time Magazine blog).
    optional string series = 4;

    // Content season; typically for video content (e.g., "Season 3").
    optional string season = 5;

    // Artist credited with the content.
    optional string artist = 21;

    // Genre that best describes the content (e.g., rock, pop, etc).
    optional string genre = 22;

    // Album to which the content belongs; typically for audio.
    optional string album = 23;

    // International Standard Recording Code conforming to ISO-3901.
    optional string isrc = 24;

    // URL of the content, for buy-side contextualization or review.
    // [AdX: (Only App.content) BidRequest.url]
    optional string url = 6;

    // Array of IAB content categories that describe the content.
    // See enum ContentCategory.
    repeated string cat = 7;

    // Production quality.
    optional ProductionQuality prodq = 25;

    // NOTE: Deprecated in favor of prodq.
    // Video quality per IAB's classification.
    optional ProductionQuality videoquality = 8 [deprecated = true];

    // Comma separated list of keywords describing the content.
    // Note: OpenRTB 2.2 allowed an array-of-strings as alternate implementation
    // but this was fixed in 2.3+ where it's definitely a single string with CSV
    // content again. Compatibility with some OpenRTB 2.2 exchanges that adopted
    // the alternate representation may require custom handling of the JSON.
    // [AdX: BidRequest.Video.ContentAttributes.keywords]
    optional string keywords = 9;

    // Content rating (e.g., MPAA).
    // [AdX: BidRequest.detected_content_label
    //       39: "DV_G", 40: "DV_PG", 41: "DV_T", 42: "DV_MA", 43: "DV_UNRATED"]
    optional string contentrating = 10;

    // User rating of the content (e.g., number of stars, likes, etc.).
    // [AdX: (Only App.content) BidRequest.Mobile.app_rating]
    optional string userrating = 11;

    // Type of content (game, video, text, etc.).
    optional ContentContext context = 20;

    // OpenRTB <= 2.2 compatibility; use context for 2.3+.
    optional string context_22 = 12;

    // 0 = not live, 1 = content is live (e.g., stream, live blog).
    optional bool livestream = 13;

    // 0 = indirect, 1 = direct.
    optional bool sourcerelationship = 14;

    // Details about the content Producer (Section 3.2.10).
    optional Producer producer = 15;

    // Length of content in seconds; appropriate for video or audio.
    // [AdX: BidRequest.Video.ContentAttributes.duration_seconds]
    optional int32 len = 16;

    // Media rating per QAG guidelines.
    optional QAGMediaRating qagmediarating = 17;

    // Indicator of whether or not the content is embeddable (e.g., an
    // embeddable video player), where 0 = no, 1 = yes.
    optional bool embeddable = 18;

    // Content language using ISO-639-1-alpha-2.
    // [AdX: BidRequest.detected_language]
    optional string language = 19;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object defines the producer of the content in which
  // the ad will be shown. This is particularly useful when the content is
  // syndicated and may be distributed through different publishers and thus
  // when the producer and publisher are not necessarily the same entity.
  message Producer {
    // Content producer or originator ID. Useful if content is syndicated,
    // and may be posted on a site using embed tags.
    optional string id = 1;

    // Content producer or originator name (e.g., "Warner Bros").
    optional string name = 2;

    // Array of IAB content categories that describe the content producer.
    // See enum ContentCategory.
    repeated string cat = 3;

    // Highest level domain of the content producer (e.g., "producer.com").
    optional string domain = 4;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object provides information pertaining to the device
  // through which the user is interacting. Device information includes its
  // hardware, platform, location, and carrier data. The device can refer to a
  // mobile handset, a desktop computer, set top box, or other digital device.
  message Device {
    // Standard "Do Not Track" flag as set in the header by the browser,
    // where 0 = tracking is unrestricted, 1 = do not track.
    // RECOMMENDED by the OpenRTB specification.
    // [AdX: Unsupported; See Cookie Guide, google_error=1:
    //       https://developers.google.com/ad-exchange/rtb/cookie-guide]
    optional bool dnt = 1;

    // Browser user agent string.
    // RECOMMENDED by the OpenRTB specification.
    optional string ua = 2;

    // IPv4 address closest to device.
    // RECOMMENDED by the OpenRTB specification.
    // [AdX: BidRequest.ip
    //     - AdX truncates to first 3 octets; OpenRTB is "X.X.X.0"]
    optional string ip = 3;

    // Location of the device assumed to be the user's current location defined
    // by a Geo object (Section 3.2.12).
    // RECOMMENDED by the OpenRTB specification.
    // [AdX: BidRequest]
    optional Geo geo = 4;

    // Hardware device ID (e.g., IMEI); hashed via SHA1.
    optional string didsha1 = 5;

    // Hardware device ID (e.g., IMEI); hashed via MD5.
    optional string didmd5 = 6;

    // Platform device ID (e.g., Android ID); hashed via SHA1.
    optional string dpidsha1 = 7;

    // Platform device ID (e.g., Android ID); hashed via MD5.
    // [AdX: BidRequest.Mobile.hashed_idfa
    //     - AdX is binary, OpenRTB is base16 (lowercase hex)
    //       This is the hashed version of ifa. Either dpidmd5 or ifa is
    //       available depending on the mobile SDK version.]
    optional string dpidmd5 = 8;

    // IPv6 address closest to device.
    // [AdX: BidRequest.ip
    //     - AdX truncates to first 6 octets; OpenRTB is "X:X:X:::::"]
    optional string ipv6 = 9;

    // Carrier or ISP, e.g. "VERIZON", specified using Mobile Network Code (MNC).
    // "WIFI" is often used in mobile to indicate high bandwidth
    // (e.g., video friendly vs. cellular).
    // [AdX: BidRequest.Device.carrier_id
    //     - IDs will be the same Criterion IDs as in AdX protocol, see:
    // https://developers.google.com/adwords/api/docs/appendix/mobilecarriers]
    optional string carrier = 10;

    // Browser language using ISO-639-1-alpha-2.
    optional string language = 11;

    // Device make (e.g., "Apple").
    // [AdX: BidRequest.Device.brand]
    optional string make = 12;

    // Device model (e.g., "iPhone").
    // [AdX: BidRequest.Device.model]
    optional string model = 13;

    // Device operating system (e.g., "iOS").
    // [AdX: BidRequest.Device.platform]
    optional string os = 14;

    // Device operating system version (e.g., "3.1.2").
    // [AdX: BidRequest.Device.os_version]
    optional string osv = 15;

    // Hardware version of the device (e.g., "5S" for iPhone 5S).
    // [AdX: BidRequest.Device.hardware_version]
    optional string hwv = 24;

    // Physical width of the screen in pixels.
    // [AdX: BidRequest.Device.screen_width]
    optional int32 w = 25;

    // Physical height of the screen in pixels.
    // [AdX: BidRequest.Device.screen_height]
    optional int32 h = 26;

    // Screen size as pixels per linear inch.
    optional int32 ppi = 27;

    // The ratio of physical pixels to device independent pixels.
    // [AdX: BidRequest.Device.screen_pixel_ratio_millis / 1,000]
    optional double pxratio = 28;

    // Support for JavaScript, where 0 = no, 1 = yes.
    optional bool js = 16;

    // Indicates if the geolocation API will be available to JavaScript
    // code running in the banner, where 0 = no, 1 = yes.
    optional bool geofetch = 29;

    // Network connection type.
    optional ConnectionType connectiontype = 17;

    // The general type of device.
    // [AdX: BidRequest.Device.device_type]
    optional DeviceType devicetype = 18;

    // Version of Flash supported by the browser.
    optional string flashver = 19;

    // ID sanctioned for advertiser use in the clear (i.e., not hashed).
    // [AdX: BidRequest.Mobile.advertising_id
    //     - AdX is binary, OpenRTB is 36-char UUID (Android ID: all lowercase,
    //       IDFA: all uppercase).
    //       ifa is either Android ID or Apple's IDFA, and either dpidmd5 or ifa
    //       is available depending on the mobile SDK version.]
    optional string ifa = 20;

    // MAC address of the device; hashed via SHA1.
    optional string macsha1 = 21;

    // MAC address of the device; hashed via MD5.
    optional string macmd5 = 22;

    // "Limit Ad Tracking" signal commercially endorsed (e.g., iOS, Android),
    // where 0 = tracking is unrestricted, 1 = tracking must be limited per
    // commercial guidelines.
    // RECOMMENDED by the OpenRTB specification.
    optional bool lmt = 23;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object encapsulates various methods for specifying a
  // geographic location. When subordinate to a Device object, it indicates the
  // location of the device which can also be interpreted as the user's current
  // location. When subordinate to a User object, it indicates the location of
  // the user's home base (i.e., not necessarily their current location).
  //
  // The lat/lon attributes should only be passed if they conform to the
  // accuracy depicted in the type attribute. For example, the centroid of a
  // geographic region such as postal code should not be passed.
  //
  // [AdX: Fine geolocation information is limited by the same constraints that
  //       apply to the AdX Hyperlocal object: not all requests have this info,
  //       and lat/lon represent some point (not necessarily center) of an area
  //       the size of which is inversely proportional to population density.
  //       That's good enough for targeting but not for individual tracking.]
  message Geo {
    // Latitude from -90.0 to +90.0, where negative is south.
    // [AdX: BidRequest.[encrypted_]hyperlocal_set.center_point.latitude]
    optional double lat = 1;

    // Longitude from -180.0 to +180.0, where negative is west.
    // [AdX: BidRequest.[encrypted_]hyperlocal_set.center_point.longitude]
    optional double lon = 2;

    // Country using ISO-3166-1 Alpha-3.
    // [AdX: BidRequest.geo_criteria_id via geo-table.csv]
    optional string country = 3;

    // Region code using ISO-3166-2; 2-letter state code if USA.
    // [AdX: BidRequest.geo_criteria_id via geo-table.csv]
    optional string region = 4;

    // Region of a country using FIPS 10-4 notation. While OpenRTB supports
    // this attribute, it has been withdrawn by NIST in 2008.
    optional string regionfips104 = 5;

    // Google metro code; similar to but not exactly Nielsen DMAs.
    // See Appendix A for a link to the codes.
    // (http://code.google.com/apis/adwords/docs/appendix/metrocodes.html).
    // [AdX: BidRequest.geo_criteria_id via geo-table.csv, cities-dma-regions.csv]
    optional string metro = 6;

    // City using United Nations Code for Trade & Transport Locations.
    // See Appendix A for a link to the codes.
    // (http://www.unece.org/cefact/locode/service/location.htm).
    // [AdX: BidRequest.geo_criteria_id via geo-table.csv]
    optional string city = 7;

    // Zip/postal code.
    // [AdX: BidRequest.postal_code, BidRequest.postal_code_prefix]
    optional string zip = 8;

    // Source of location data; recommended when passing lat/lon.
    optional LocationType type = 9;

    // Estimated location accuracy in meters; recommended when lat/lon
    // are specified and derived from a device’s location services
    // (i.e., type = 1). Note that this is the accuracy as reported
    // from the device. Consult OS specific documentation
    // (e.g., Android, iOS) for exact interpretation.
    optional int32 accuracy = 11;

    // Number of seconds since this geolocation fix was established.
    // Note that devices may cache location data across multiple fetches.
    // Ideally, this value should be from the time the actual fix was taken.
    optional int32 lastfix = 12;

    // Service or provider used to determine geolocation from IP
    // address if applicable (i.e., type = 2).
    optional LocationService ipservice = 13;

    // Local time as the number +/- of minutes from UTC.
    // [AdX: BidRequest.timezone_offset]
    optional int32 utcoffset = 10;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: This object contains information known or derived about
  // the human user of the device (i.e., the audience for advertising).
  // The user id is an exchange artifact and may be subject to rotation or other
  // privacy policies. However, this user ID must be stable long enough to serve
  // reasonably as the basis for frequency capping and retargeting.
  message User {
    // Exchange-specific ID for the user. At least one of id or buyerid
    // is recommended.
    // [AdX: BidRequest.[constrained_usage_]google_user_id]
    optional string id = 1;

    // Buyer-specific ID for the user as mapped by the exchange for the buyer.
    // At least one of buyerid or id is recommended.
    optional string buyeruid = 2;

    // Year of birth as a 4-digit integer.
    // [AdX: BidRequest.UserDemographic.age_high if present, if not
    //       BidRequest.UserDemographic.age_low; subtracted from current year]
    optional int32 yob = 3;

    // Gender as "M" male, "F" female, "O" Other. (Null indicates unknown)
    // [AdX: BidRequest.UserDemographic.gender]
    optional string gender = 4;

    // Comma separated list of keywords, interests, or intent.
    // Note: OpenRTB 2.2 allowed an array-of-strings as alternate implementation
    // but this was fixed in 2.3+ where it's definitely a single string with CSV
    // content again. Compatibility with some OpenRTB 2.2 exchanges that adopted
    // the alternate representation may require custom handling of the JSON.
    optional string keywords = 5;

    // Optional feature to pass bidder data set in the exchange's cookie.
    // The string must be in base85 cookie safe characters and be in any format.
    // Proper JSON encoding must be used to include "escaped" quotation marks.
    // [AdX: BidRequest.[constrained_usage_]hosted_match_data
    //     - AdX is binary, OpenRTB is base64 (no padding)]
    optional string customdata = 6;

    // Location of the user's home base defined by a Geo object
    // (Section 3.2.12). This is not necessarily their current location.
    optional Geo geo = 7;

    // Additional user data. Each Data object (Section 3.2.14) represents a
    // different data source.
    // [AdX: BidRequest.Vertical ->
    //       (id: "DetectedVertical", name: "DoubleClick",
    //        segment[n]: (id: dv[n].id, value: dv[n].weight))]
    repeated Data data = 8;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB 2.0: The data and segment objects together allow additional data
  // about the user to be specified. This data may be from multiple sources
  // whether from the exchange itself or third party providers as specified by
  // the id field. A bid request can mix data objects from multiple providers.
  // The specific data providers in use should be published by the exchange
  // a priori to its bidders.
  message Data {
    // Exchange-specific ID for the data provider.
    optional string id = 1;

    // Exchange-specific name for the data provider.
    optional string name = 2;

    // Array of Segment (Section 3.2.15) objects that contain the actual
    // data values.
    repeated Segment segment = 3;

    // Extensions.
    extensions 100 to 9999;

    // OpenRTB 2.0: Segment objects are essentially key-value pairs that
    // convey specific units of data about the user. The parent Data object
    // is a collection of such values from a given data provider.
    // The specific segment names and value options must be published by the
    // exchange a priori to its bidders.
    message Segment {
      // ID of the data segment specific to the data provider.
      optional string id = 1;

      // Name of the data segment specific to the data provider.
      optional string name = 2;

      // String representation of the data segment value.
      optional string value = 3;

      // Extensions.
      extensions 100 to 9999;
    }
  }

  // OpenRTB 2.2: This object contains any legal, governmental, or industry
  // regulations that apply to the request. The coppa flag signals whether
  // or not the request falls under the United States Federal Trade Commission's
  // regulations for the United States Children's Online Privacy Protection Act
  // ("COPPA"). Refer to Section 7.1 for more information.
  message Regs {
    // Flag indicating if this request is subject to the COPPA regulations
    // established by the USA FTC, where 0 = no, 1 = yes.
    // [AdX: BidRequest.user_data_treatment / TAG_FOR_CHILD_DIRECTED_TREATMENT]
    optional bool coppa = 1;

    // Extensions.
    extensions 100 to 9999;
  }
}

// OpenRTB 2.0: This object is the top-level bid response object (i.e., the
// unnamed outer JSON object). The id attribute is a reflection of the bid
// request ID for logging purposes. Similarly, bidid is an optional response
// tracking ID for bidders. If specified, it can be included in the subsequent
// win notice call if the bidder wins. At least one seatbid object is required,
// which contains at least one bid for an impression. Other attributes are
// optional. To express a "no-bid", the options are to return an empty response
// with HTTP 204. Alternately if the bidder wishes to convey to the exchange a
// reason for not bidding, just a BidResponse object is returned with a
// reason code in the nbr attribute.
message BidResponse {
  // ID of the bid request to which this is a response.
  // REQUIRED by the OpenRTB specification.
  // [AdX: Not mapped to any field, but validated against the BidRequest.id]
  required string id = 1;

  // Array of seatbid objects; 1+ required if a bid is to be made.
  // [AdX: BidResponse.Ad]
  repeated SeatBid seatbid = 2;

  // Bidder generated response ID to assist with logging/tracking.
  // [AdX: BidResponse.debug_string]
  optional string bidid = 3;

  // Bid currency using ISO-4217 alpha codes.
  optional string cur = 4;

  // Optional feature to allow a bidder to set data in the exchange's cookie.
  // The string must be in base85 cookie safe characters and be in any format.
  // Proper JSON encoding must be used to include "escaped" quotation marks.
  optional string customdata = 5;

  // Reason for not bidding.
  optional NoBidReason nbr = 6;

  // Extensions.
  extensions 100 to 9999;

  // OpenRTB 2.0: A bid response can contain multiple SeatBid objects, each on
  // behalf of a different bidder seat and each containing one or more
  // individual bids. If multiple impressions are presented in the request, the
  // group attribute can be used to specify if a seat is willing to accept any
  // impressions that it can win (default) or if it is only interested in
  // winning any if it can win them all as a group.
  message SeatBid {
    // Array of 1+ Bid objects (Section 4.2.3) each related to an impression.
    // Multiple bids can relate to the same impression.
    // [AdX: BidResponse.Ad]
    repeated Bid bid = 1;

    // ID of the buyer seat (e.g., advertiser, agency) on whose behalf
    // this bid is made.
    optional string seat = 2;

    // 0 = impressions can be won individually; 1 = impressions must be won or
    // lost as a group.
    optional bool group = 3 [default = false];

    // Extensions.
    extensions 100 to 9999;

    // OpenRTB 2.0: A SeatBid object contains one or more Bid objects,
    // each of which relates to a specific impression in the bid request
    // via the impid attribute and constitutes an offer to buy that impression
    // for a given price.
    message Bid {
      // Bidder generated bid ID to assist with logging/tracking.
      // REQUIRED by the OpenRTB specification.
      required string id = 1;

      // ID of the Imp object in the related bid request.
      // REQUIRED by the OpenRTB specification.
      // [AdX: BidResponse.Ad.AdSlot.id]
      required string impid = 2;

      // Bid price expressed as CPM although the actual transaction is for a
      // unit impression only. Note that while the type indicates float, integer
      // math is highly recommended when handling currencies
      // (e.g., BigDecimal in Java).
      // REQUIRED by the OpenRTB specification.
      // [AdX: BidResponse.Ad.AdSlot.max_cpm_micros * 1,000,000]
      required double price = 3;

      // ID of a preloaded ad to be served if the bid wins.
      optional string adid = 4;

      // Win notice URL called by the exchange if the bid wins; optional means
      // of serving ad markup.
      // [AdX: BidResponse.Ad.impression_tracking_url
      //     - DoubleClick doesn't support win notices;
      //       use %%WINNING_PRICE%% in snippet's impression URL.]
      optional string nurl = 5;

      oneof adm_oneof {
        // Optional means of conveying ad markup in case the bid wins;
        // supersedes the win notice if markup is included in both.
        // For native ad bids, exactly one of {adm, adm_native} should be used;
        // this is the OpenRTB-compliant field for JSON serialization.
        // [AdX: BidResponse.Ad.html_snippet,
        //    or BidResponse.Ad.video_url,
        //    or BidResponse.Ad.native_ad]
        string adm = 6;

        // Native ad response.
        // For native ad bids, exactly one of {adm, adm_native} should be used;
        // this is an alternate field preferred for Protobuf serialization.
        // [AdX: BidResponse.Ad.native_ad]
        NativeResponse adm_native = 50;
      }

      // Advertiser domain for block list checking (e.g., "ford.com"). This can
      // be an array of for the case of rotating creatives. Exchanges can
      // mandate that only one domain is allowed.
      // [AdX: BidResponse.Ad.click_through_url
      //     - OpenRTB spec only allows domain names in adomain;
      //       AdX support full URLs too.]
      repeated string adomain = 7;

      // A platform-specific application identifier intended to be
      // unique to the app and independent of the exchange. On Android,
      // this should be a bundle or package name (e.g., com.foo.mygame).
      // On iOS, it is a numeric ID.
      optional string bundle = 14;

      // URL without cache-busting to an image that is representative of the
      // content of the campaign for ad quality/safety checking.
      optional string iurl = 8;

      // Campaign ID to assist with ad quality checking; the collection of
      // creatives for which iurl should be representative.
      // [AdX: BidResponse.Ad.AdSlot.billing_id]
      optional string cid = 9;

      // Creative ID to assist with ad quality checking.
      // [AdX: BidResponse.Ad.buyer_creative_id]
      optional string crid = 10;

      // IAB content categories of the creative.
      repeated string cat = 15;

      // Set of attributes describing the creative.
      // [AdX: BidResponse.Ad.attribute]
      repeated CreativeAttribute attr = 11 [packed = true];

      // API required by the markup if applicable.
      optional APIFramework api = 18;

      // Video response protocol of the markup if applicable.
      optional Protocol protocol = 19;

      // Creative media rating per QAG guidelines.
      optional QAGMediaRating qagmediarating = 20;

      // Reference to the deal.id from the bid request if this bid pertains to a
      // private marketplace direct deal.
      // [AdX: BidResponse.Ad.AdSlot.deal_id]
      optional string dealid = 13;

      // Width of the creative in device independent pixels (DIPS).
      // [AdX: BidResponse.Ad.width - only required if the impression is multisize]
      optional int32 w = 16;

      // Height of the creative in device independent pixels (DIPS).
      // [AdX: BidResponse.Ad.height - only required if the impression is multisize]
      optional int32 h = 17;

      // Advisory as to the number of seconds the bidder is willing to
      // wait between the auction and the actual impression.
      optional int32 exp = 21;

      // Extensions.
      extensions 100 to 9999;
    }
  }
}

// OpenRTB Native 1.0: The Native Object defines the native advertising
// opportunity available for bid via this bid request. It must be included
// directly in the impression object if the impression offered for auction
// is a native ad format.
message NativeRequest {
  // Version of the Native Markup version in use.
  // [AdX: "1.0" for OpenRTB 2.3; "1.1" for OpenRTB 2.4]
  optional string ver = 1;

  // The Layout ID of the native ad unit.
  // RECOMMENDED by OpenRTB Native 1.0; optional in 1.1, to be deprecated.
  optional LayoutId layout = 2;

  // The Ad unit ID of the native ad unit. This corresponds to one of
  // IAB Core-6 native ad units.
  // RECOMMENDED by OpenRTB Native 1.0; optional in 1.1, to be deprecated.
  optional AdUnitId adunit = 3;

  // The context in which the ad appears.
  optional ContextType context = 7;

  // A more detailed context in which the ad appears.
  optional ContextSubtype contextsubtype = 8;

  // The design/format/layout of the ad unit being offered.
  // RECOMMENDED by the OpenRTB Native specification.
  optional PlacementType plcmttype = 9;

  // The number of identical placements in this Layout.
  optional int32 plcmtcnt = 4 [default = 1];

  // 0 for the first ad, 1 for the second ad, and so on. Note this would
  // generally NOT be used in combination with plcmtcnt - either you are
  // auctioning multiple identical placements (in which case
  // plcmtcnt>1, seq=0) or you are holding separate auctions for distinct
  // items in the feed (in which case plcmtcnt=1, seq>=1).
  optional int32 seq = 5 [default = 0];

  // Any bid must comply with the array of elements expressed by the Exchange.
  // REQUIRED by the OpenRTB Native specification: at least 1 element.
  // [AdX: BidRequest.AdSlot.native_ad_template[0]
  //     - AdX supports multiple templates, only the first will be mapped.
  //       Each field specified in the template is mapped to a separate Asset.]
  repeated Asset assets = 6;

  // Extensions.
  extensions 100 to 9999;

  // OpenRTB Native 1.0: The main container object for each asset requested or
  // supported by Exchange on behalf of the rendering client.
  // Any object that is required is to be flagged as such. Only one of the
  // {title,img,video,data} objects should be present in each object.
  // All others should be null/absent. The id is to be unique within the
  // Asset array so that the response can be aligned.
  message Asset {
    // Unique asset ID, assigned by exchange. Typically a counter for the array.
    // REQUIRED by the OpenRTB Native specification.
    // [AdX: 1..N for N assets in unspecified order, corresponding to recommended
    //       or required fields in the first NativeAdTemplate.]
    required int32 id = 1;

    // Set to true if asset is required
    // (exchange will not accept a bid without it).
    // [AdX: BidRequest.AdSlot.native_ad_template[0].required_fields]
    optional bool required = 2 [default = false];

    // RECOMMENDED by the OpenRTB Native specification.
    oneof asset_oneof {
      // Title object for title assets.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of type HEADLINE]
      Title title = 3;

      // Image object for image assets.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of types
      //       MAIN/IMAGE, ICON/APP_ICON, LOGO/LOGO]
      Image img = 4;

      // Video object for video assets.
      // Note that in-stream video ads are not part of Native.
      // Native ads may contain a video as the ad creative itself.
      BidRequest.Imp.Video video = 5;

      // Data object for ratings, prices etc.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of types
      //       ADDRESS/STORE, CTATEXT/CALL_TO_ACTION, DESC/BODY,
      //       SPONSORED/ADVERTISER, PRICE/PRICE, RATING/STAR_RATING]
      Data data = 6;
    }

    // Extensions.
    extensions 100 to 9999;

    // OpenRTB Native 1.0: The Title object is to be used for title element
    // of the Native ad.
    message Title {
      // Maximum length of the text in the title element.
      // RECOMMENDED that the value be either of: 25, 90, 140.
      // REQUIRED by the OpenRTB Native specification.
      // [AdX: BidRequest.AdSlot.native_ad_template[0].headline_max_safe_length]
      required int32 len = 1;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB Native 1.0: The Image object to be used for all image elements
    // of the Native ad such as Icons, Main Image, etc.
    message Image {
      // Type ID of the image element supported by the publisher.
      // The publisher can display this information in an appropriate format.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] field type]
      optional ImageAssetType type = 1;

      // Width of the image in pixels.
      optional int32 w = 2;

      // Height of the image in pixels.
      optional int32 h = 3;

      // The minimum requested width of the image in pixels. This option should
      // be used for any rescaling of images by the client. Either w or wmin
      // should be transmitted. If only w is included, it should be considered
      // an exact requirement.
      // RECOMMENDED by the OpenRTB Native specification.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of type:
      //       MAIN/IMAGE: image_width
      //       LOGO/LOGO: logo_width
      //       ICON/APP_ICON: app_icon_width]
      optional int32 wmin = 4;

      // The minimum requested height of the image in pixels. This option should
      // be used for any rescaling of images by the client. Either h or hmin
      // should be transmitted. If only h is included, it should be considered
      // an exact requirement.
      // RECOMMENDED by the OpenRTB Native specification.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of type:
      //       MAIN/IMAGE: image_width
      //       LOGO/LOGO: logo_width
      //       ICON/APP_ICON: app_icon_width]
      optional int32 hmin = 5;

      // Whitelist of content MIME types supported. Popular MIME types include,
      // but are not limited to "image/jpg" and "image/gif". Each implementing
      // Exchange should have their own list of supported types in the
      // integration docs. See Wikipedia's MIME page for more information and
      // links to all IETF RFCs. If blank, assume all types are allowed.
      repeated string mimes = 6;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB Native 1.0: The Data Object is to be used for all non-core
    // elements of the native unit such as Ratings, Review Count, Stars,
    // Download count, descriptions etc. It is also generic for future of Native
    // elements not contemplated at the time of the writing of this document.
    message Data {
      // Type ID of the element supported by the publisher. The publisher can
      // display this information in an appropriate format.
      // REQUIRED by the OpenRTB Native specification.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] field type]
      required DataAssetType type = 1;

      // Maximum length of the text in the element's response.
      // [AdX: BidRequest.AdSlot.native_ad_template[0] of type:
      //       DESC/BODY: body_max_safe_length
      //       CTATEXT/CALL_TO_ACTION: call_to_action_max_safe_length
      //       SPONSORED/ADVERTISER: advertiser_max_safe_length
      //       PRICE/PRICE: price_max_safe_length
      //       ADDRESS/STORE: store_max_safe_length
      //     - Note: not used for RATING/STAR_RATING, AdX needs a double 0..5]
      optional int32 len = 2;

      // Extensions.
      extensions 100 to 9999;
    }
  }
}

// OpenRTB Native 1.0: The native response object is the top level JSON object
// which identifies an native response.
message NativeResponse {
  // Version of the Native Markup version in use.
  // [AdX: "1.0" for OpenRTB 2.3; "1.1" for OpenRTB 2.4]
  optional string ver = 1;

  // List of native ad's assets.
  // [AdX: BidResponse.Ad.native_ad[0]
  //     - All assets are mapped to fields of a single NativeAd.]
  repeated Asset assets = 2;

  // Destination Link.
  // REQUIRED by the OpenRTB Native specification.
  // [AdX: BidResponse.Ad.native_ad[0]]
  required Link link = 3;

  // Array of impression tracking URLs, expected to return a 1x1 image or
  // 204 response - typically only passed when using 3rd party trackers.
  // [AdX: BidResponse.Ad.impression_tracking_url]
  repeated string imptrackers = 4;

  // Optional javascript impression tracker. Contains <script> tags to be
  // executed at impression time where it can be supported.
  optional string jstracker = 5;

  // Extensions.
  extensions 100 to 9999;

  // OpenRTB Native 1.0: Used for "call to action" assets, or other links from
  // the Native ad. This Object should be associated to its peer object in the
  // parent Asset Object. When that peer object is activated (clicked)
  // the action should take the user to the location of the link.
  message Link {
    // Landing URL of the clickable link.
    // [AdX: (NativeResponse.link)
    //           BidResponse.Ad.click_through_url
    //       (NativeResponse.Asset.link, for asset of type STORE)
    //           BidResponse.Ad.native_ad[0].store]
    optional string url = 1;

    // Third-party tracker URLs to be fired on click of the URL. Google click
    // trackers redirect HTTP 30x to the bidder's tracker. Google only maps the
    // first click tracking url and the remaining are ignored.
    // [AdX: (NativeResponse.link)
    //           BidResponse.Ad.NativeAd.click_tracking_url[0]]
    repeated string clicktrackers = 2;

    // Fallback URL for deeplink. To be used if the URL given in url is not
    // supported by the device.
    optional string fallback = 3;

    // Extensions.
    extensions 100 to 9999;
  }

  // OpenRTB Native 1.0: Corresponds to the Asset Object in the request.
  // The main container object for each asset requested or supported by Exchange
  // on behalf of the rendering client. Any object that is required is to be
  // flagged as such. Only one of the {title,img,video,data} objects should be
  // present in each object. All others should be null/absent. The id is to be
  // unique within the Asset array so that the response can be aligned.
  message Asset {
    // Unique asset ID, assigned by exchange, must match one of the asset IDs
    // in request.
    // REQUIRED by the OpenRTB Native specification.
    required int32 id = 1;

    // Set to 1 if asset is required. (bidder requires it to be displayed).
    optional bool required = 2 [default = false];

    // RECOMMENDED by the OpenRTB Native specification.
    oneof asset_oneof {
      // Title object for title assets.
      // [AdX: BidResponse.Ad.native_ad[0] / HEADLINE]
      Title title = 3;

      // Image object for image assets.
      // [AdX: BidResponse.Ad.native_ad[0] / IMAGE|LOGO|APP_ICON]
      Image img = 4;

      // Video object for video assets. Note that in-stream video ads are not part
      // of Native. Native ads may contain a video as the ad creative itself.
      Video video = 5;

      // Data object for ratings, prices etc.
      // [AdX: BidResponse.Ad.native_ad[0] /
      //       BODY|CALL_TO_ACTION|ADVERTISER|STAR_RATING_PRICE_STORE]
      Data data = 6;
    }

    // Link object for call to actions. This link is to associated to the other
    // populated field within the object.
    // [AdX: BidResponse.Ad.native_ad[0]]
    optional Link link = 7;

    // Extensions.
    extensions 100 to 9999;

    // OpenRTB Native 1.0: Corresponds to the Title Object in the request,
    // with the value filled in.
    message Title {
      // The text associated with the text element.
      // REQUIRED by the OpenRTB Native specification.
      // [AdX: BidResponse.Ad.native_ad[0].headline]
      required string text = 1;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB Native 1.0: Corresponds to the Image Object in the request.
    // The Image object to be used for all image elements of the Native ad
    // such as Icons, Main Image, etc.
    message Image {
      // URL of the image asset.
      // REQUIRED by the OpenRTB Native specification.
      // [AdX: BidResponse.Ad.native_ad[0] for request asset type:
      //       MAIN/IMAGE: image.url
      //       ICON/APP_ICON: app_icon.url
      //       LOGO/LOGO: logo.url]
      required string url = 1;

      // Width of the image in pixels.
      // RECOMMENDED by the OpenRTB Native specification.
      // [AdX: BidResponse.Ad.native_ad[0] for request asset type:
      //       MAIN/IMAGE: image.url
      //       ICON/APP_ICON: app_icon.url
      //       LOGO/LOGO: logo.url]
      optional int32 w = 2;

      // Height of the image in pixels.
      // RECOMMENDED by the OpenRTB Native specification.
      // [AdX: BidResponse.Ad.native_ad[0] for request asset type:
      //       MAIN/IMAGE: image.url
      //       ICON/APP_ICON: app_icon.url
      //       LOGO/LOGO: logo.url]
      optional int32 h = 3;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB Native 1.0: Corresponds to the Data Object in the request, with
    // the value filled in. The Data Object is to be used for all miscellaneous
    // elements of the native unit such as Ratings, Review Count, Stars,
    // Downloads, Price count etc. It is also generic for future of Native
    // elements not contemplated at the time of the writing of this document.
    message Data {
      // The optional formatted string name of the data type to be displayed.
      optional string label = 1;

      // The formatted string of data to be displayed. Can contain a formatted
      // value such as "5 stars" or "$10" or "3.4 stars out of 5".
      // REQUIRED by the OpenRTB Native specification.
      // [AdX: BidResponse.Ad.native_ad[0] for request asset type OpenRTB/AdX:
      //       CTATEXT/CALL_TO_ACTION: call_to_action
      //       DESC/BODY: body
      //       SPONSORED/ADVERTISER: advertiser
      //       PRICE/PRICE: price
      //       RATING/STAR_RATING: star_rating (AdX requires a double 0..5)
      //     - Note: ADDRESS/STORE not mapped via data.value, use asset.link.url]
      required string value = 2;

      // Extensions.
      extensions 100 to 9999;
    }

    // OpenRTB Native 1.0: Corresponds to the Video Object in the request,
    // yet containing a value of a conforming VAST tag as a value.
    message Video {
      // VAST xml.
      // REQUIRED by the OpenRTB Native specification.
      required string vasttag = 1;

      // Extensions.
      extensions 100 to 9999;
    }
  }
}

// ***** OpenRTB Core enums ****************************************************

// OpenRTB 2.0: The following list represents the IAB's contextual taxonomy for
// categorization. Standard IDs have been adopted to easily support the
// communication of primary and secondary categories for various objects.
//
// This OpenRTB table has values derived from the IAB Quality Assurance
// Guidelines (QAG). Practitioners should keep in sync with updates to the
// QAG values as published on IAB.net.
enum ContentCategory {
  UNDEFINED = 0;   // This value is not part of the specification.
  IAB1 = 1;        // Arts & Entertainment
  IAB1_1 = 2;      // Books & Literature
  IAB1_2 = 3;      // Celebrity Fan/Gossip
  IAB1_3 = 4;      // Fine Art
  IAB1_4 = 5;      // Humor
  IAB1_5 = 6;      // Movies
  IAB1_6 = 7;      // Music
  IAB1_7 = 8;      // Television
  IAB2 = 9;        // Automotive
  IAB2_1 = 10;     // Auto Parts
  IAB2_2 = 11;     // Auto Repair
  IAB2_3 = 12;     // Buying/Selling Cars
  IAB2_4 = 13;     // Car Culture
  IAB2_5 = 14;     // Certified Pre-Owned
  IAB2_6 = 15;     // Convertible
  IAB2_7 = 16;     // Coupe
  IAB2_8 = 17;     // Crossover
  IAB2_9 = 18;     // Diesel
  IAB2_10 = 19;    // Electric Vehicle
  IAB2_11 = 20;    // Hatchback
  IAB2_12 = 21;    // Hybrid
  IAB2_13 = 22;    // Luxury
  IAB2_14 = 23;    // MiniVan
  IAB2_15 = 24;    // Motorcycles
  IAB2_16 = 25;    // Off-Road Vehicles
  IAB2_17 = 26;    // Performance Vehicles
  IAB2_18 = 27;    // Pickup
  IAB2_19 = 28;    // Road-Side Assistance
  IAB2_20 = 29;    // Sedan
  IAB2_21 = 30;    // Trucks & Accessories
  IAB2_22 = 31;    // Vintage Cars
  IAB2_23 = 32;    // Wagon
  IAB3 = 33;       // Business
  IAB3_1 = 34;     // Advertising
  IAB3_2 = 35;     // Agriculture
  IAB3_3 = 36;     // Biotech/Biomedical
  IAB3_4 = 37;     // Business Software
  IAB3_5 = 38;     // Construction
  IAB3_6 = 39;     // Forestry
  IAB3_7 = 40;     // Government
  IAB3_8 = 41;     // Green Solutions
  IAB3_9 = 42;     // Human Resources
  IAB3_10 = 43;    // Logistics
  IAB3_11 = 44;    // Marketing
  IAB3_12 = 45;    // Metals
  IAB4 = 46;       // Careers
  IAB4_1 = 47;     // Career Planning
  IAB4_2 = 48;     // College
  IAB4_3 = 49;     // Financial  Aid
  IAB4_4 = 50;     // Job Fairs
  IAB4_5 = 51;     // Job Search
  IAB4_6 = 52;     // Resume Writing/Advice
  IAB4_7 = 53;     // Nursing
  IAB4_8 = 54;     // Scholarships
  IAB4_9 = 55;     // Telecommuting
  IAB4_10 = 56;    // U.S. Military
  IAB4_11 = 57;    // Career Advice
  IAB5 = 58;       // Education
  IAB5_1 = 59;     // 7-12 Education
  IAB5_2 = 60;     // Adult Education
  IAB5_3 = 61;     // Art History
  IAB5_4 = 62;     // College Administration
  IAB5_5 = 63;     // College Life
  IAB5_6 = 64;     // Distance Learning
  IAB5_7 = 65;     // English as a 2nd Language
  IAB5_8 = 66;     // Language Learning
  IAB5_9 = 67;     // Graduate School
  IAB5_10 = 68;    // Homeschooling
  IAB5_11 = 69;    // Homework/Study Tips
  IAB5_12 = 70;    // K-6 Educators
  IAB5_13 = 71;    // Private School
  IAB5_14 = 72;    // Special Education
  IAB5_15 = 73;    // Studying Business
  IAB6 = 74;       // Family & Parenting
  IAB6_1 = 75;     // Adoption
  IAB6_2 = 76;     // Babies & Toddlers
  IAB6_3 = 77;     // Daycare/Pre School
  IAB6_4 = 78;     // Family Internet
  IAB6_5 = 79;     // Parenting - K-6 Kids
  IAB6_6 = 80;     // Parenting teens
  IAB6_7 = 81;     // Pregnancy
  IAB6_8 = 82;     // Special Needs Kids
  IAB6_9 = 83;     // Eldercare
  IAB7 = 84;       // Health & Fitness
  IAB7_1 = 85;     // Exercise
  IAB7_2 = 86;     // A.D.D.
  IAB7_3 = 87;     // AIDS/HIV
  IAB7_4 = 88;     // Allergies
  IAB7_5 = 89;     // Alternative Medicine
  IAB7_6 = 90;     // Arthritis
  IAB7_7 = 91;     // Asthma
  IAB7_8 = 92;     // Autism/PDD
  IAB7_9 = 93;     // Bipolar Disorder
  IAB7_10 = 94;    // Brain Tumor
  IAB7_11 = 95;    // Cancer
  IAB7_12 = 96;    // Cholesterol
  IAB7_13 = 97;    // Chronic Fatigue Syndrome
  IAB7_14 = 98;    // Chronic Pain
  IAB7_15 = 99;    // Cold & Flu
  IAB7_16 = 100;   // Deafness
  IAB7_17 = 101;   // Dental Care
  IAB7_18 = 102;   // Depression
  IAB7_19 = 103;   // Dermatology
  IAB7_20 = 104;   // Diabetes
  IAB7_21 = 105;   // Epilepsy
  IAB7_22 = 106;   // GERD/Acid Reflux
  IAB7_23 = 107;   // Headaches/Migraines
  IAB7_24 = 108;   // Heart Disease
  IAB7_25 = 109;   // Herbs for Health
  IAB7_26 = 110;   // Holistic Healing
  IAB7_27 = 111;   // IBS/Crohn's Disease
  IAB7_28 = 112;   // Incest/Abuse Support
  IAB7_29 = 113;   // Incontinence
  IAB7_30 = 114;   // Infertility
  IAB7_31 = 115;   // Men's Health
  IAB7_32 = 116;   // Nutrition
  IAB7_33 = 117;   // Orthopedics
  IAB7_34 = 118;   // Panic/Anxiety Disorders
  IAB7_35 = 119;   // Pediatrics
  IAB7_36 = 120;   // Physical Therapy
  IAB7_37 = 121;   // Psychology/Psychiatry
  IAB7_38 = 122;   // Senor Health
  IAB7_39 = 123;   // Sexuality
  IAB7_40 = 124;   // Sleep Disorders
  IAB7_41 = 125;   // Smoking Cessation
  IAB7_42 = 126;   // Substance Abuse
  IAB7_43 = 127;   // Thyroid Disease
  IAB7_44 = 128;   // Weight Loss
  IAB7_45 = 129;   // Women's Health
  IAB8 = 130;      // Food & Drink
  IAB8_1 = 131;    // American Cuisine
  IAB8_2 = 132;    // Barbecues & Grilling
  IAB8_3 = 133;    // Cajun/Creole
  IAB8_4 = 134;    // Chinese Cuisine
  IAB8_5 = 135;    // Cocktails/Beer
  IAB8_6 = 136;    // Coffee/Tea
  IAB8_7 = 137;    // Cuisine-Specific
  IAB8_8 = 138;    // Desserts & Baking
  IAB8_9 = 139;    // Dining Out
  IAB8_10 = 140;   // Food Allergies
  IAB8_11 = 141;   // French Cuisine
  IAB8_12 = 142;   // Health/Lowfat Cooking
  IAB8_13 = 143;   // Italian Cuisine
  IAB8_14 = 144;   // Japanese Cuisine
  IAB8_15 = 145;   // Mexican Cuisine
  IAB8_16 = 146;   // Vegan
  IAB8_17 = 147;   // Vegetarian
  IAB8_18 = 148;   // Wine
  IAB9 = 149;      // Hobbies & Interests
  IAB9_1 = 150;    // Art/Technology
  IAB9_2 = 151;    // Arts & Crafts
  IAB9_3 = 152;    // Beadwork
  IAB9_4 = 153;    // Birdwatching
  IAB9_5 = 154;    // Board Games/Puzzles
  IAB9_6 = 155;    // Candle & Soap Making
  IAB9_7 = 156;    // Card Games
  IAB9_8 = 157;    // Chess
  IAB9_9 = 158;    // Cigars
  IAB9_10 = 159;   // Collecting
  IAB9_11 = 160;   // Comic Books
  IAB9_12 = 161;   // Drawing/Sketching
  IAB9_13 = 162;   // Freelance Writing
  IAB9_14 = 163;   // Geneaology
  IAB9_15 = 164;   // Getting Published
  IAB9_16 = 165;   // Guitar
  IAB9_17 = 166;   // Home Recording
  IAB9_18 = 167;   // Investors & Patents
  IAB9_19 = 168;   // Jewelry Making
  IAB9_20 = 169;   // Magic & Illusion
  IAB9_21 = 170;   // Needlework
  IAB9_22 = 171;   // Painting
  IAB9_23 = 172;   // Photography
  IAB9_24 = 173;   // Radio
  IAB9_25 = 174;   // Roleplaying Games
  IAB9_26 = 175;   // Sci-Fi & Fantasy
  IAB9_27 = 176;   // Scrapbooking
  IAB9_28 = 177;   // Screenwriting
  IAB9_29 = 178;   // Stamps & Coins
  IAB9_30 = 179;   // Video & Computer Games
  IAB9_31 = 180;   // Woodworking
  IAB10 = 181;     // Home & Garden
  IAB10_1 = 182;   // Appliances
  IAB10_2 = 183;   // Entertaining
  IAB10_3 = 184;   // Environmental Safety
  IAB10_4 = 185;   // Gardening
  IAB10_5 = 186;   // Home Repair
  IAB10_6 = 187;   // Home Theater
  IAB10_7 = 188;   // Interior  Decorating
  IAB10_8 = 189;   // Landscaping
  IAB10_9 = 190;   // Remodeling & Construction
  IAB11 = 191;     // Law, Gov't & Politics
  IAB11_1 = 192;   // Immigration
  IAB11_2 = 193;   // Legal Issues
  IAB11_3 = 194;   // U.S. Government Resources
  IAB11_4 = 195;   // Politics
  IAB11_5 = 196;   // Commentary
  IAB12 = 197;     // News
  IAB12_1 = 198;   // International News
  IAB12_2 = 199;   // National News
  IAB12_3 = 200;   // Local News
  IAB13 = 201;     // Personal Finance
  IAB13_1 = 202;   // Beginning Investing
  IAB13_2 = 203;   // Credit/Debt & Loans
  IAB13_3 = 204;   // Financial News
  IAB13_4 = 205;   // Financial Planning
  IAB13_5 = 206;   // Hedge Fund
  IAB13_6 = 207;   // Insurance
  IAB13_7 = 208;   // Investing
  IAB13_8 = 209;   // Mutual Funds
  IAB13_9 = 210;   // Options
  IAB13_10 = 211;  // Retirement Planning
  IAB13_11 = 212;  // Stocks
  IAB13_12 = 213;  // Tax Planning
  IAB14 = 214;     // Society
  IAB14_1 = 215;   // Dating
  IAB14_2 = 216;   // Divorce Support
  IAB14_3 = 217;   // Gay Life
  IAB14_4 = 218;   // Marriage
  IAB14_5 = 219;   // Senior Living
  IAB14_6 = 220;   // Teens
  IAB14_7 = 221;   // Weddings
  IAB14_8 = 222;   // Ethnic Specific
  IAB15 = 223;     // Science
  IAB15_1 = 224;   // Astrology
  IAB15_2 = 225;   // Biology
  IAB15_3 = 226;   // Chemistry
  IAB15_4 = 227;   // Geology
  IAB15_5 = 228;   // Paranormal Phenomena
  IAB15_6 = 229;   // Physics
  IAB15_7 = 230;   // Space/Astronomy
  IAB15_8 = 231;   // Geography
  IAB15_9 = 232;   // Botany
  IAB15_10 = 233;  // Weather
  IAB16 = 234;     // Pets
  IAB16_1 = 235;   // Aquariums
  IAB16_2 = 236;   // Birds
  IAB16_3 = 237;   // Cats
  IAB16_4 = 238;   // Dogs
  IAB16_5 = 239;   // Large Animals
  IAB16_6 = 240;   // Reptiles
  IAB16_7 = 241;   // Veterinary Medicine
  IAB17 = 242;     // Sports
  IAB17_1 = 243;   // Auto Racing
  IAB17_2 = 244;   // Baseball
  IAB17_3 = 245;   // Bicycling
  IAB17_4 = 246;   // Bodybuilding
  IAB17_5 = 247;   // Boxing
  IAB17_6 = 248;   // Canoeing/Kayaking
  IAB17_7 = 249;   // Cheerleading
  IAB17_8 = 250;   // Climbing
  IAB17_9 = 251;   // Cricket
  IAB17_10 = 252;  // Figure Skating
  IAB17_11 = 253;  // Fly Fishing
  IAB17_12 = 254;  // Football
  IAB17_13 = 255;  // Freshwater Fishing
  IAB17_14 = 256;  // Game & Fish
  IAB17_15 = 257;  // Golf
  IAB17_16 = 258;  // Horse Racing
  IAB17_17 = 259;  // Horses
  IAB17_18 = 260;  // Hunting/Shooting
  IAB17_19 = 261;  // Inline  Skating
  IAB17_20 = 262;  // Martial Arts
  IAB17_21 = 263;  // Mountain Biking
  IAB17_22 = 264;  // NASCAR Racing
  IAB17_23 = 265;  // Olympics
  IAB17_24 = 266;  // Paintball
  IAB17_25 = 267;  // Power & Motorcycles
  IAB17_26 = 268;  // Pro Basketball
  IAB17_27 = 269;  // Pro Ice Hockey
  IAB17_28 = 270;  // Rodeo
  IAB17_29 = 271;  // Rugby
  IAB17_30 = 272;  // Running/Jogging
  IAB17_31 = 273;  // Sailing
  IAB17_32 = 274;  // Saltwater Fishing
  IAB17_33 = 275;  // Scuba Diving
  IAB17_34 = 276;  // Skateboarding
  IAB17_35 = 277;  // Skiing
  IAB17_36 = 278;  // Snowboarding
  IAB17_37 = 279;  // Surfing/Bodyboarding
  IAB17_38 = 280;  // Swimming
  IAB17_39 = 281;  // Table Tennis/Ping-Pong
  IAB17_40 = 282;  // Tennis
  IAB17_41 = 283;  // Volleyball
  IAB17_42 = 284;  // Walking
  IAB17_43 = 285;  // Waterski/Wakeboard
  IAB17_44 = 286;  // World Soccer
  IAB18 = 287;     // Style & Fashion
  IAB18_1 = 288;   // Beauty
  IAB18_2 = 289;   // Body Art
  IAB18_3 = 290;   // Fashion
  IAB18_4 = 291;   // Jewelry
  IAB18_5 = 292;   // Clothing
  IAB18_6 = 293;   // Accessories
  IAB19 = 294;     // Technology & Computing
  IAB19_1 = 295;   // 3-D Graphics
  IAB19_2 = 296;   // Animation
  IAB19_3 = 297;   // Antivirus Software
  IAB19_4 = 298;   // C/C++
  IAB19_5 = 299;   // Cameras & Camcorders
  IAB19_6 = 300;   // Cell  Phones
  IAB19_7 = 301;   // Computer Certification
  IAB19_8 = 302;   // Computer Networking
  IAB19_9 = 303;   // Computer Peripherals
  IAB19_10 = 304;  // Computer Reviews
  IAB19_11 = 305;  // Data Centers
  IAB19_12 = 306;  // Databases
  IAB19_13 = 307;  // Desktop Publishing
  IAB19_14 = 308;  // Desktop Video
  IAB19_15 = 309;  // Email
  IAB19_16 = 310;  // Graphics Software
  IAB19_17 = 311;  // Home Video/DVD
  IAB19_18 = 312;  // Internet Technology
  IAB19_19 = 313;  // Java
  IAB19_20 = 314;  // Javascript
  IAB19_21 = 315;  // Mac Support
  IAB19_22 = 316;  // MP3/MIDI
  IAB19_23 = 317;  // Net Conferencing
  IAB19_24 = 318;  // Net for Beginners
  IAB19_25 = 319;  // Network Security
  IAB19_26 = 320;  // Palmtops/PDAs
  IAB19_27 = 321;  // PC Support
  IAB19_28 = 322;  // Portable
  IAB19_29 = 323;  // Entertainment
  IAB19_30 = 324;  // Shareware/Freeware
  IAB19_31 = 325;  // Unix
  IAB19_32 = 326;  // Visual Basic
  IAB19_33 = 327;  // Web Clip Art
  IAB19_34 = 328;  // Web Design/HTML
  IAB19_35 = 329;  // Web Search
  IAB19_36 = 330;  // Windows
  IAB20 = 331;     // Travel
  IAB20_1 = 332;   // Adventure Travel
  IAB20_2 = 333;   // Africa
  IAB20_3 = 334;   // Air Travel
  IAB20_4 = 335;   // Australia & New Zealand
  IAB20_5 = 336;   // Bed & Breakfasts
  IAB20_6 = 337;   // Budget Travel
  IAB20_7 = 338;   // Business Travel
  IAB20_8 = 339;   // By US Locale
  IAB20_9 = 340;   // Camping
  IAB20_10 = 341;  // Canada
  IAB20_11 = 342;  // Caribbean
  IAB20_12 = 343;  // Cruises
  IAB20_13 = 344;  // Eastern  Europe
  IAB20_14 = 345;  // Europe
  IAB20_15 = 346;  // France
  IAB20_16 = 347;  // Greece
  IAB20_17 = 348;  // Honeymoons/Getaways
  IAB20_18 = 349;  // Hotels
  IAB20_19 = 350;  // Italy
  IAB20_20 = 351;  // Japan
  IAB20_21 = 352;  // Mexico & Central America
  IAB20_22 = 353;  // National Parks
  IAB20_23 = 354;  // South America
  IAB20_24 = 355;  // Spas
  IAB20_25 = 356;  // Theme Parks
  IAB20_26 = 357;  // Traveling with Kids
  IAB20_27 = 358;  // United Kingdom
  IAB21 = 359;     // Real Estate
  IAB21_1 = 360;   // Apartments
  IAB21_2 = 361;   // Architects
  IAB21_3 = 362;   // Buying/Selling Homes
  IAB22 = 363;     // Shopping
  IAB22_1 = 364;   // Contests & Freebies
  IAB22_2 = 365;   // Couponing
  IAB22_3 = 366;   // Comparison
  IAB22_4 = 367;   // Engines
  IAB23 = 368;     // Religion & Spirituality
  IAB23_1 = 369;   // Alternative Religions
  IAB23_2 = 370;   // Atheism/Agnosticism
  IAB23_3 = 371;   // Buddhism
  IAB23_4 = 372;   // Catholicism
  IAB23_5 = 373;   // Christianity
  IAB23_6 = 374;   // Hinduism
  IAB23_7 = 375;   // Islam
  IAB23_8 = 376;   // Judaism
  IAB23_9 = 377;   // Latter-Day Saints
  IAB23_10 = 378;  // Paga/Wiccan
  IAB24 = 379;     // Uncategorized
  IAB25 = 380;     // Non-Standard Content
  IAB25_1 = 381;   // Unmoderated UGC
  IAB25_2 = 382;   // Extreme Graphic/Explicit Violence
  IAB25_3 = 383;   // Pornography
  IAB25_4 = 384;   // Profane Content
  IAB25_5 = 385;   // Hate Content
  IAB25_6 = 386;   // Under Construction
  IAB25_7 = 387;   // Incentivized
  IAB26 = 388;     // Illegal Content
  IAB26_1 = 389;   // Illegal Content
  IAB26_2 = 390;   // Warez
  IAB26_3 = 391;   // Spyware/Malware
  IAB26_4 = 392;   // Copyright Infringement
}

enum AuctionType {
  FIRST_PRICE = 1;

  // [AdX: DealType.PRIVATE_AUCTION]
  SECOND_PRICE = 2;

  // [AdX: DealType.PREFERRED_DEAL]
  FIXED_PRICE = 3;
}

// OpenRTB 2.0: types of ads that can be accepted by the exchange unless
// restricted by publisher site settings.
enum BannerAdType {
  // "Usually mobile".
  XHTML_TEXT_AD = 1;
  // "Usually mobile".
  XHTML_BANNER_AD = 2;
  // Javascript must be valid XHTML (ie, script tags included).
  JAVASCRIPT_AD = 3;
  // Iframe.
  IFRAME = 4;
}

// OpenRTB 2.0: The following table specifies a standard list of creative
// attributes that can describe an ad being served or serve as restrictions
// of thereof.
enum CreativeAttribute {
  AUDIO_AUTO_PLAY = 1;
  AUDIO_USER_INITIATED = 2;
  EXPANDABLE_AUTOMATIC = 3;
  EXPANDABLE_CLICK_INITIATED = 4;

  // [AdX: 28/ROLLOVER_TO_EXPAND]
  EXPANDABLE_ROLLOVER_INITIATED = 5;

  // [AdX: 22/VAST_VIDEO]
  VIDEO_IN_BANNER_AUTO_PLAY = 6;

  // [AdX: 22/VAST_VIDEO]
  VIDEO_IN_BANNER_USER_INITIATED = 7;

  POP = 8;  // Pop (e.g., Over, Under, or upon Exit).
  PROVOCATIVE_OR_SUGGESTIVE = 9;

  // Defined as "Shaky, Flashing, Flickering, Extreme Animation, Smileys".
  ANNOYING = 10;

  SURVEYS = 11;
  TEXT_ONLY = 12;
  USER_INTERACTIVE = 13;  // Eg, embedded games.

  WINDOWS_DIALOG_OR_ALERT_STYLE = 14;
  HAS_AUDIO_ON_OFF_BUTTON = 15;
  AD_CAN_BE_SKIPPED = 16;

  FLASH = 17;
}

// OpenRTB 2.0: The following table is a list of API frameworks supported
// by the publisher.  Note that MRAID-1 is a subset of MRAID-2.
// In OpenRTB 2.1 and prior, value "3" was "MRAID".  However, not all
// MRAID capable APIs understand MRAID-2 features and as such the only
// safe interpretation of value "3" is MRAID-1. In OpenRTB 2.2, this was
// made explicit and MRAID-2 has been added as value "5".
enum APIFramework {
  // [AdX: attribute 30/VPAID]
  VPAID_1 = 1;

  // [AdX: attribute 30/VPAID]
  VPAID_2 = 2;

  // [AdX: attribute 32/MRAID]
  MRAID_1 = 3;

  ORMMA = 4;

  // [AdX: attribute 32/MRAID (OpenRTB 2.3+)]
  MRAID_2 = 5;
};

// OpenRTB 2.0: The following table specifies the position of the ad as a
// relative measure of visibility or prominence.
//
// This OpenRTB table has values derived from the IAB Quality Assurance
// Guidelines (QAG). Practitioners should keep in sync with updates to the
// QAG values as published on IAB.net. Values "3" - "6" apply to apps
// per the mobile addendum to QAG version 1.5.
enum AdPosition {
  // [AdX: SlotVisibility.NO_DETECTION]
  UNKNOWN = 0;

  // [AdX: SlotVisibility.ABOVE_THE_FOLD]
  ABOVE_THE_FOLD = 1;

  // May or may not be immediately visible depending on screen size and
  // resolution.
  // @deprecated
  DEPRECATED_LIKELY_BELOW_THE_FOLD = 2;

  // [AdX: SlotVisibility.BELOW_THE_FOLD]
  BELOW_THE_FOLD = 3;

  // [OpenRTB->AdX: SlotVisibility.ABOVE_THE_FOLD]
  HEADER = 4;

  // [OpenRTB->AdX: SlotVisibility.ABOVE_THE_FOLD]
  FOOTER = 5;

  // [OpenRTB->AdX: SlotVisibility.ABOVE_THE_FOLD]
  SIDEBAR = 6;

  // [OpenRTB->AdX: SlotVisibility.ABOVE_THE_FOLD]
  AD_POSITION_FULLSCREEN = 7;
}

// OpenRTB 2.0: The following table indicates the options for video
// linearity. "In-stream" or "linear" video refers to pre-roll, post-roll,
// or mid-roll video ads where the user is forced to watch ad in order to
// see the video content. "Overlay" or "non-linear" refer to ads that are
// shown on top of the video content.
//
// This field is optional. The following is the interpretation of the
// bidder based upon presence or absence of the field in the bid request:
// - If no value is set, any ad (linear or not) can be present
//   in the response.
// - If a value is set, only ads of the corresponding type can be present
//   in the response.
//
// This OpenRTB table has values derived from the IAB Quality Assurance
// Guidelines (QAG). Practitioners should keep in sync with updates to the
// QAG values as published on IAB.net.
enum VideoLinearity {
  LINEAR = 1;      // Linear/In-stream
  NON_LINEAR = 2;  // Non-linear/Overlay
}

// OpenRTB 2.0: The following table lists the options for the various
// bid response protocols that could be supported by an exchange.
enum Protocol {
  VAST_1_0 = 1;
  VAST_2_0 = 2;
  VAST_3_0 = 3;
  VAST_1_0_WRAPPER = 4;
  VAST_2_0_WRAPPER = 5;
  VAST_3_0_WRAPPER = 6;
  VAST_4_0 = 7;
  VAST_4_0_WRAPPER = 8;
  DAAST_1_0 = 9;
  DAAST_1_0_WRAPPER = 10;
}

// OpenRTB 2.0: The following table lists the various playback methods.
enum PlaybackMethod {
  // [AdX: VideoPlaybackMethod.AUTO_PLAY_SOUND_ON]
  AUTO_PLAY_SOUND_ON = 1;

  // [AdX: VideoPlaybackMethod.AUTO_PLAY_SOUND_OFF]
  AUTO_PLAY_SOUND_OFF = 2;

  // [AdX: VideoPlaybackMethod.CLICK_TO_PLAY]
  CLICK_TO_PLAY = 3;

  MOUSE_OVER = 4;
}

// OpenRTB 2.0: The following table lists the various options for the
// audio/video start delay.  If the start delay value is greater than 0,
// then the position is mid-roll and the value indicates the start delay.
enum StartDelay {
  PRE_ROLL = 0;
  GENERIC_MID_ROLL = -1;
  GENERIC_POST_ROLL = -2;
}

// OpenRTB 2.0: The following table lists the various options for the
// type of device connectivity.
enum ConnectionType {
  CONNECTION_UNKNOWN = 0;
  ETHERNET = 1;
  WIFI = 2;
  CELL_UNKNOWN = 3;
  CELL_2G = 4;
  CELL_3G = 5;
  CELL_4G = 6;
}

// OpenRTB 2.0: The following table lists the directions in which an
// expandable ad may expand, given the positioning of the ad unit on the
// page and constraints imposed by the content.
enum ExpandableDirection {
  // [AdX: attribute 15/EXPANDING_LEFT, also 17,19,26,27/EXPANDING_*LEFT*]
  LEFT = 1;

  // [AdX: attribute 16/EXPANDING_RIGHT, also 18,20,26,27/EXPANDING_*RIGHT*]
  RIGHT = 2;

  // [AdX: attribute 13/EXPANDING_UP, also 17,18,25,27/EXPANDING_*UP*]
  UP = 3;

  // [AdX: attribute 14/EXPANDING_DOWN, also 19,20,25,27/EXPANDING_*DOWN*]
  DOWN = 4;

  EXPANDABLE_FULLSCREEN = 5;
}

// OpenRTB 2.0: The following table lists the various options for the
// delivery of video content.
enum ContentDeliveryMethod {
  STREAMING = 1;
  PROGRESSIVE = 2;
}

// OpenRTB 2.0: The following table lists the various options for
// indicating the type of content in which the impression will appear.
//
// This OpenRTB table has values derived from the IAB Quality Assurance
// Guidelines (QAG). Practitioners should keep in sync with updates to the
// QAG values as published on IAB.net.
enum ContentContext {
  VIDEO = 1;
  GAME = 2;
  MUSIC = 3;
  APPLICATION = 4;
  TEXT = 5;
  OTHER = 6;
  CONTEXT_UNKNOWN = 7;
}

// OpenRTB 2.0: The following table lists the options for content quality.
// These values are defined by the IAB -
// http://www.iab.net/media/file/long-form-video-final.pdf.
enum ProductionQuality {
  QUALITY_UNKNOWN = 0;
  PROFESSIONAL = 1;
  PROSUMER = 2;
  USER_GENERATED = 3;
}

// OpenRTB 2.0: The following table lists the options to indicate how the
// geographic information was determined.
enum LocationType {
  GPS_LOCATION = 1;
  IP = 2;
  USER_PROVIDED = 3;
}

// OpenRTB 2.4: The following table lists the services and/or vendors used for
// resolving IP addresses to geolocations.
enum LocationService {
  IP2LOCATION = 1;
  NEUSTAR = 2;
  MAXMIND = 3;
  NETAQUITY = 4;
}

// OpenRTB 2.0: The following table lists the type of device from which the
// impression originated.
//
// OpenRTB version 2.2 of the specification added distinct values for Mobile
// and Tablet. It is recommended that any bidder adding support for 2.2
// treat a value of 1 as an acceptable alias of 4 & 5.
//
// This OpenRTB table has values derived from the IAB Quality Assurance
// Guidelines (QAG). Practitioners should keep in sync with updates to the
// QAG values as published on IAB.net.
enum DeviceType {
  // Mobile (OpenRTB 2.2+: obsolete, alias for PHONE or TABLET).
  MOBILE = 1;

  // Personal Computer.
  // [AdX: DeviceType.PERSONAL_COMPUTER]
  PERSONAL_COMPUTER = 2;

  // Connected TV.
  // [AdX: DeviceType.CONNECTED_TV]
  CONNECTED_TV = 3;

  // Phone.
  // [AdX: DeviceType.HIGHEND_PHONE]
  HIGHEND_PHONE = 4;

  // Tablet.
  // [AdX: DeviceType.TABLET]
  TABLET = 5;

  // Connected device.
  // [AdX->OpenRTB: DeviceType.GAME_CONSOLE; OpenRTB->AdX: none]
  CONNECTED_DEVICE = 6;

  // Set top box.
  // [AdX->OpenRTB: none; OpenRTB->AdX: DeviceType.CONNECTED_TV]
  SET_TOP_BOX = 7;
}

// OpenRTB 2.1: The following table lists the options for the
// video quality. These values are defined by the IAB -
// http://www.iab.net/media/file/long-form-video-final.pdf.
enum CompanionType {
  // [AdX: CreativeFormat.IMAGE_CREATIVE]
  STATIC = 1;

  // [AdX: CreativeFormat.FLASH_CREATIVE, CreativeFormat.HTML_CREATIVE]
  HTML = 2;

  COMPANION_IFRAME = 3;
}

// OpenRTB 2.1: The following table lists the media ratings used in
// describing content based on the QAG categorization.
// Refer to http://www.iab.net/ne_guidelines for more information.
enum QAGMediaRating {
  ALL_AUDIENCES = 1;
  EVERYONE_OVER_12 = 2;
  MATURE = 3;
}

// OpenRTB 2.2: The following table lists the options for a bidder to signal
// the exchange as to why it did not offer a bid for the impression.
enum NoBidReason {
  UNKNOWN_ERROR = 0;
  TECHNICAL_ERROR = 1;
  INVALID_REQUEST = 2;
  KNOWN_WEB_SPIDER = 3;
  SUSPECTED_NONHUMAN_TRAFFIC = 4;
  CLOUD_DATACENTER_PROXYIP = 5;
  UNSUPPORTED_DEVICE = 6;
  BLOCKED_PUBLISHER = 7;
  UNMATCHED_USER = 8;
}

// OpenRTB 2.4: The following table lists the types of feeds,
// typically for audio.
enum FeedType {
  MUSIC_SERVICE = 1;
  BROADCAST = 2;
  PODCAST = 3;
}

// OpenRTB 2.4: The following table lists the types of volume normalization
// modes, typically for audio.
enum VolumeNormalizationMode {
  NONE = 0;
  AVERAGE_VOLUME = 1;
  PEAK_VOLUME = 2;
  LOUDNESS = 3;
  CUSTOM_VOLUME = 4;
}

// ***** OpenRTB Native enums **************************************************

// OpenRTB Native 1.0: Core layouts. An implementing exchange may not
// support all asset variants or introduce new ones unique to that system.
// To be deprecated.
enum LayoutId {
  CONTENT_WALL = 1;
  APP_WALL = 2;
  NEWS_FEED = 3;
  CHAT_LIST = 4;
  CAROUSEL = 5;
  CONTENT_STREAM = 6;
  GRID = 7;
  // Exchange-specific values above 500.
}

// OpenRTB Native 1.0: Below is a list of the core ad unit ids described by
// IAB: http://www.iab.net/media/file/IABNativeAdvertisingPlaybook120413.pdf
// In feed unit is essentially a layout, it has been removed from the list.
// In feed units can be identified via the layout parameter on the request.
// An implementing exchange may not support all asset variants or introduce
// new ones unique to that system.
// To be deprecated.
enum AdUnitId {
  PAID_SEARCH_UNIT = 1;
  RECOMMENDATION_WIDGET = 2;
  PROMOTED_LISTING = 3;
  IAB_IN_AD_NATIVE = 4;
  ADUNITID_CUSTOM = 5;
  // Exchange-specific values above 500.
}

// OpenRTB Native 1.1: The context in which the ad appears - what type
// of content is surrounding the ad on the page at a high level.
// This maps directly to the new Deep Dive on In-Feed Ad Units.
// This denotes the primary context, but does not imply other content
// may not exist on the page - for example it's expected that most
// content platforms have some social components, etc.
enum ContextType {
  // Content-centric context such as newsfeed, article, image gallery,
  // video gallery, or similar.
  CONTENT = 1;
  // Social-centric context such as social network feed, email,
  // chat, or similar.
  SOCIAL = 2;
  // Product context such as product listings, details, recommendations,
  // reviews, or similar.
  PRODUCT = 3;
}

// OpenRTB Native 1.1: Next-level context in which the ad appears.
// Again this reflects the primary context, and does not imply no presence
// of other elements. For example, an article is likely to contain images
// but is still first and foremost an article. SubType should only be
// combined with the primary context type as indicated (ie for a context
// type of 1, only context subtypes that start with 1 are valid).
enum ContextSubtype {
  CONTENT_GENERAL_OR_MIXED = 10;
  CONTENT_ARTICLE = 11;
  CONTENT_VIDEO = 12;
  CONTENT_AUDIO = 13;
  CONTENT_IMAGE = 14;
  CONTENT_USER_GENERATED = 15;

  SOCIAL_GENERAL = 20;
  SOCIAL_EMAIL = 21;
  SOCIAL_CHAT_IM = 22;

  PRODUCT_SELLING = 30;
  PRODUCT_MARKETPLACE = 31;
  PRODUCT_REVIEW = 32;
}

// OpenRTB Native 1.1: The FORMAT of the ad you are purchasing,
// separate from the surrounding context.
enum PlacementType {
  // In the feed of content - for example as an item inside the organic
  // feed/grid/listing/carousel.
  IN_FEED = 1;
  // In the atomic unit of the content - IE in the article page
  // or single image page.
  ATOMIC_UNIT = 2;
  // Outside the core content - for example in the ads section on the
  // right rail, as a banner-style placement near the content, etc.
  OUTSIDE = 3;
  // Recommendation widget, most commonly presented below
  // the article content.
  RECOMMENDATION = 4;
}

// OpenRTB Native 1.0: Common asset element types of native advertising.
// This list is non-exhaustive and intended to be extended by the buyers
// and sellers as the format evolves. An implementing exchange may not
// support all asset variants or introduce new ones unique to that system.
enum DataAssetType {
  // Sponsored By message where response should contain the brand name
  // of the sponsor.
  // Format: Text; Max length: 25 or longer.
  // [AdX: Fields.ADVERTISER]
  SPONSORED = 1;

  // Descriptive text associated with the product or service being advertised.
  // Format: Text; Max length: 140 or longer.
  // [AdX: Fields.BODY]
  DESC = 2;

  // Rating of the product being offered to the user.
  // For example an app's rating in an app store from 0-5.
  // Format: Number (1-5 digits) formatted as string.
  // [AdX: Fields.STAR_RATING]
  RATING = 3;

  // Number of social ratings or "likes" of product being offered to the user.
  // Format: Number formatted as string.
  LIKES = 4;

  // Number downloads/installs of this product.
  // Format: Number formatted as string.
  DOWNLOADS = 5;

  // Price for product / app / in-app purchase.
  // Value should include currency symbol in localised format.
  // Format: Number formatted as string.
  // [AdX: Fields.PRICE]
  PRICE = 6;

  // Sale price that can be used together with price to indicate a discounted
  // price compared to a regular price. Value should include currency symbol
  // in localised format.
  // Format: Number formatted as string.
  SALEPRICE = 7;

  // Phone number.
  // Format: Formatted string.
  PHONE = 8;

  // Address.
  // Format: Text.
  // [AdX: Fields.STORE]
  ADDRESS = 9;

  // Additional descriptive text associated with the product or service
  // being advertised.
  // Format: Text.
  DESC2 = 10;

  // Display URL for the text ad.
  // Format: Text.
  DISPLAYURL = 11;

  // Text describing a 'call to action' button for the destination URL.
  // Format: Text.
  // [AdX: Fields.CALL_TO_ACTION]
  CTATEXT = 12;

  // Exchange-specific values above 500.
}

// OpenRTB Native 1.0: Common image asset element types of native advertising
// at the time of writing this spec. This list is non-exhaustive and intended
// to be extended by the buyers and sellers as the format evolves.
enum ImageAssetType {
  // Icon image.
  // Max height: at least 50; Aspect ratio: 1:1.
  // [AdX: Fields.APP_ICON]
  ICON = 1;

  // Logo image for the brand/app.
  // To be deprecated in a future version - use type 1 / ICON.
  // [AdX: Fields.LOGO]
  LOGO = 2;

  // Large image preview for the ad.
  // At least one of 2 size variants required:
  // Small Variant: max height: 200+, max width: 200+, 267, or 382,
  //                aspect ratio: 1:1, 4:3, or 1.91:1.
  // Large Variant: max height: 627+, max width: 627+, 836, or 1198,
  //                aspect ratio: 1:1, 4:3, or 1.91:1.
  // [AdX: Fields.IMAGE]
  MAIN = 3;

  // Exchange-specific values above 500.
}
