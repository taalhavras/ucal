/-  *hora, *ucal, *ucal-almanac, *resource
|%
::
::
+$  calendar-patch
  $:  =calendar-code
      title=(unit @t)
  ==
::
+$  event-patch
  $:  =calendar-code
      =event-code
      ::  fields of detail
      title=(unit title)
      desc=(unit (unit @t))
      loc=(unit (unit location))
      ::
      when=(unit moment)
      era=(unit (unit era))
      tzid=(unit tape)
  ==
::
+$  rsvp-change
  $:  =calendar-code
      =event-code
      who=@p
      :: if ~, then the @p is uninvited
      :: if [~ ~], the @p is added to invites without a status
      status=(unit (unit rsvp))
  ==
::
+$  permission-change
  $:  =calendar-code
      ::  %change with unit means revoke all permissions for the @p
      $%  [%change who=@p role=(unit calendar-role)]
          [%make-public ~]
          [%make-private ~]
      ==
  ==
::
+$  action
  $%  $:  %create-calendar
          title=@t
          :: should be used for testing only
          calendar-code=(unit calendar-code)
          permissions=calendar-permissions
      ==
      ::
      $:  %update-calendar
          patch=calendar-patch
      ==
      ::
      $:  %delete-calendar
          =calendar-code
      ==
      ::
      $:  %create-event
          =calendar-code
          ::  should be used for testing only
          event-code=(unit event-code)
          organizer=@p
          =detail
          when=moment
          era=(unit era)
          invited=(set @p)
          tzid=tape
      ==
      ::
      $:  %update-event
          patch=event-patch
      ==
      ::
      :: - delete event
      $:  %delete-event
          =calendar-code
          =event-code
      ==
      :: - change rsvp
      $:  %change-rsvp
          =calendar-code
          =event-code
          who=@p
          ::  if &, invite the @p to the event
          ::  if |, uninvite the @p from the event
          invite=flag
      ==
      :: - import calendar from file
      $:  %import-from-ics
          cc=(unit calendar-code)
          $%  [%path =path]
              [%data data=@t]
              ::  This is needed b/c we cannot directly fetch from i.e.
              ::  gcal URLs from the frontend due to CORS
              ::  TODO get rid of the %data poke since we can do this
              ::  now?
              [%url url=tape]
          ==
      ==
      ::
      $:  %change-permissions
          change=permission-change
      ==
  ==
::
::  $to-subscriber: sent to subscribers - union of entire
::  payload and periodic updates.
::
+$  to-subscriber
  $:  =resource
      $%  [%entire =calendar events=(list event)]
          [%update =update]
      ==
  ==
::
::  $update: updates sent to subscribers
::
+$  update
  $%  [%calendar-changed =calendar-patch modify-time=@da]
      [%calendar-removed =calendar-code]
      [%event-added =event]
      [%event-changed =event-patch modify-time=@da]
      [%event-removed =calendar-code =event-code]
      [%rsvp-changed =rsvp-change]
      [%permissions-changed =calendar-code =calendar-permissions]
  ==
::  $invitation: sent to ships invited to a particular event. if the
::  event is changed, new invitations will be sent. rsvp-required should
::  be true if a new rsvp is needed (i.e. if the time has changed) - it
::  should always be true on the initial invitation.
::
+$  invitation
  $%  [%invited =event rsvp-required=flag]
      :: indicates that you've been removed from the event or that the
      :: event no longer exists - either way you don't have access to it
      :: anymore.
      [%removed =calendar-code =event-code]
  ==
::  $invitation-reply: sent by ships who are invited to an event,
::  indicating whether they can attend or not.
::
+$  invitation-reply
  $:  status=rsvp
      =calendar-code
      =event-code
      ::  mug of the moment and era of the event this is a response to.
      ::  this is used by the host to determine if the reply is for the
      ::  latest version of the event. consider the following scenario.
      ::  1. ~sovmep invites ~marnus to an event.
      ::  2. ~marnus sends a reply indicating they can attend
      ::  3. while ~marnus's reply is in flight, ~sovmep updates
      ::     the time of the event, sending a new invitation to ~marnus
      ::  4. ~sovmep receives ~marnus's initial reply. ~sovmep needs
      ::     a way to know whether this reply is based on the most
      ::     recent version of the event - hence the mug.
      hash=@
  ==
--
