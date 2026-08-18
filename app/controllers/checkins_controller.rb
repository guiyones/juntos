class CheckinsController < ApplicationController
  def create
    challenge = Challenge.find(params.expect(:challenge_id))

    if participant = current_participant_for(challenge)
      participant.checkins.create(date: date_for(challenge))
      redirect_to challenge
    else
      head :forbidden
    end
  end

  def destroy
    checkin = Checkin.find(params[:id])

    if checkin.participant == current_participant_for(checkin.challenge)
      checkin.destroy
      redirect_to checkin.challenge
    else
      head :forbidden
    end
  end

  private
    def date_for(challenge)
      params[:date] == "yesterday" ? challenge.today - 1 : challenge.today
    end
end
