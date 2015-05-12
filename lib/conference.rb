class ConfHelper

  # Return the SID of the current conference
  # The first time, fetches from Twilio, then caches in the DB
  # Returns a Twilio conference object
  def self.current_conference(db, room)
    if room[:conference_sid]
      room[:conference_sid]
      conference = TwilioClient.account.conferences.get(room[:conference_sid])
      if conference.status != 'in-progress'
        db[:rooms].where(:id => room[:id]).update(:conference_sid => nil)
        nil
      else
        conference
      end
    else
      conferences = TwilioClient.account.conferences.list(
        :FriendlyName => room[:dial_code],
        :Status => 'in-progress'
      )
      if conferences[0]
        db[:rooms].where(:id => room[:id]).update(:conference_sid => conferences[0].sid)
        conferences[0]
      else
        db[:rooms].where(:id => room[:id]).update(:conference_sid => nil)
        nil
      end
    end
  end

  def self.mute(db, conference, caller_sid)
    participant = conference.participants.get(caller_sid)
    participant.mute()
  end

  def self.unmute(db, conference, caller_sid)
    participant = conference.participants.get(caller_sid)
    participant.unmute()
  end

end