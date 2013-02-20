class Gflu::WeekDatesController < ApplicationController
  def index
    @weeks = Week.all
    @weekDates =
        @weeks.collect{|week|
          {'date' => week['date']} }
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @weekDates }
    end

  end
end
