class ChallengesController < ApplicationController
  before_action :require_authentication, only: %i[ new create ]

  def index
    @active, @finished = my_challenges.partition { |challenge| !challenge.finished? }
    @greeting_name = my_latest_name
    @pending_today = @active.count { |challenge| challenge.running? && !current_participant_for(challenge)&.checked_in_on?(challenge.today) }
  end

  def new
    @challenge = Challenge.new(starts_on: Date.tomorrow, days: 21)
  end

  def create
    participant_name = params[:participant_name].to_s.strip
    @challenge = current_user.challenges.new(challenge_params)

    if participant_name.blank?
      @challenge.errors.add(:base, "conta pra gente como você quer ser chamado")
      return render :new, status: :unprocessable_entity
    end

    Challenge.transaction do
      @challenge.save!
      @challenge.join name: participant_name, person_token: person_token, user: current_user
    end

    redirect_to @challenge
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    @challenge = Challenge.find(params[:id])
    @participant = current_participant_for(@challenge)

    redirect_to root_path if @participant.nil?
  end

  private
    def challenge_params
      params.expect(challenge: %i[ name starts_on days ])
    end

    def my_challenges
      Challenge.involving(person_token: cookies.signed[:person_token], user: current_user).latest_first
    end

    def my_latest_name
      matches = Participant.where(person_token: cookies.signed[:person_token])
      matches = matches.or(Participant.where(user: current_user)) if signed_in?
      matches.order(:created_at).last&.name
    end
end
